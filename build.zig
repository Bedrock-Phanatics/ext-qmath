const std = @import("std");

const Phpz = @import("phpz").Phpz;

const package = @import("build.zig.zon");
const extension_name = @tagName(package.name);
const extension_version = package.version;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const php_include_dir = b.option([]const u8, "php-include-dir", "PHP include directory (main/, Zend/, TSRM/, ext/)") orelse "/usr/include/php";
    const php_lib_dir = b.option([]const u8, "php-lib-dir", "Windows only: PHP SDK library directory containing php8*.lib");
    const windows_zts = b.option(bool, "windows-zts", "Windows only: link against the thread-safe PHP library") orelse false;
    const windows_debug = b.option(bool, "windows-debug", "Windows only: build against a debug PHP SDK") orelse false;
    const libc_file = b.option([]const u8, "libc-file", "Libc paths file for C translation and extension compilation");
    const php_binary = b.option([]const u8, "php", "PHP binary used for PHPT tests and stub generation") orelse "php";

    // The pure Zig core has no PHP dependency, so its tests run without headers.
    const core_tests = b.addTest(.{ .root_module = b.createModule(.{
        .root_source_file = b.path("src/core/root.zig"),
        .target = target,
        .optimize = optimize,
        // libm keeps pow/sin/atan2 identical to the functions PHP itself calls.
        .link_libc = true,
    }) });
    const test_step = b.step("test", "Run Zig unit tests for the native core");
    test_step.dependOn(&b.addRunArtifact(core_tests).step);

    const phpz_dep = b.dependency("phpz", .{});
    const phpz = Phpz.init(phpz_dep, .{
        .translator = .{
            .c_source_file = b.path("qmath.h"),
            .target = target,
            .optimize = optimize,
        },
        .libc_file = if (libc_file) |file| .{ .cwd_relative = file } else null,
        .php_include_dir = .{ .cwd_relative = php_include_dir },
        .php_lib_dir = if (php_lib_dir) |lib_dir| .{ .cwd_relative = lib_dir } else null,
        .windows_zts = windows_zts,
        .windows_debug = windows_debug,
        .shared = true,
    });

    const extension = phpz.addExtension(b, .{
        .name = extension_name,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const extension_info = b.addOptions();
    extension_info.addOption([:0]const u8, "name", extension_name);
    extension_info.addOption([:0]const u8, "version", extension_version);
    extension.root_module.addOptions("extension_info", extension_info);

    const extension_file = std.Build.Step.UpdateSourceFiles.create(b);
    var extension_filename: []const u8 = extension_name ++ ".so";
    if (target.result.os.tag == .windows) {
        extension_filename = "php_" ++ extension_name ++ ".dll";
    }
    extension_file.addCopyFileToSource(extension.getEmittedBin(), b.fmt("modules/{s}", .{extension_filename}));
    b.getInstallStep().dependOn(&extension_file.step);

    const run_tests_step = b.step("run-tests", "Run PHPT tests");
    const phpt = addRunPhpTool(b, php_binary, phpz_dep.path("tools/php/run-tests.php"), "build/run-tests.php");
    phpt.addArgs(&.{ "-q", "--show-diff", "-p", php_binary, "-d", b.fmt("extension=modules/{s}", .{extension_filename}), "tests" });
    phpt.step.dependOn(b.getInstallStep());
    run_tests_step.dependOn(&phpt.step);

    const gen_stub_step = b.step("gen-stub", "Regenerate arginfo from the PHP stub");
    const gen_stub = addRunPhpTool(b, php_binary, phpz_dep.path("tools/php/gen_stub.php"), "build/gen_stub.php");
    gen_stub.addArg(extension_name ++ ".stub.php");
    gen_stub_step.dependOn(&gen_stub.step);
}

// Copy the bundled tool into build/ before running it so PHP resolves its own includes.
fn addRunPhpTool(b: *std.Build, php: []const u8, source: std.Build.LazyPath, destination: []const u8) *std.Build.Step.Run {
    const copy = std.Build.Step.UpdateSourceFiles.create(b);
    copy.addCopyFileToSource(source, destination);

    const run = b.addSystemCommand(&.{ php, destination });
    run.setCwd(b.path("."));
    run.has_side_effects = true;
    run.step.dependOn(&copy.step);
    return run;
}
