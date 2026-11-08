const phpz = @import("phpz");
const extension = @import("extension_info");

const rt = @import("rt.zig");
const vector = @import("vector.zig");
const aabb = @import("aabb.zig");
const math = @import("math.zig");
const raycast = @import("raycast.zig");
const color = @import("color.zig");
const region = @import("region.zig");
const explosion = @import("explosion.zig");
const noise = @import("noise.zig");
const spatial = @import("spatial.zig");

comptime {
    phpz.module(.{
        .name = extension.name,
        .version = extension.version,
        .classes = &.{
            vector.Vector2Class,
            vector.Vector3Class,
            aabb.RayTraceResultClass,
            aabb.AxisAlignedBBClass,
            math.AxisClass,
            math.FacingClass,
            math.MathClass,
            math.VectorMathClass,
            raycast.VoxelRayTraceClass,
            color.ColorClass,
            region.CollisionDataExceptionClass,
            region.CollisionRegionClass,
            region.MoveResultClass,
            region.SweepResultClass,
            region.CollisionSolverClass,
            raycast.VoxelHitClass,
            raycast.VoxelRayIteratorClass,
            raycast.RaycastClass,
            explosion.ResistanceGridClass,
            explosion.ExplosionMathClass,
            noise.SimplexClass,
            spatial.SpatialClass,
            spatial.PhysicsClass,
        },
        .module_startup_fn = startup,
        .module_shutdown_fn = shutdown,
        .info_fn = info,
    });
}

fn startup() !void {
    const libm = @import("core/root.zig").libm;
    libm.init();
    if (!libm.native) rt.c.zend_error(rt.c.E_CORE_WARNING, "qmath: C runtime math functions were not found, trigonometry may differ from PHP in the last bit");
    vector.startup();
    aabb.startup();
    math.startup();
    raycast.startup();
    color.startup();
    region.startup();
    spatial.startup();
}

fn shutdown() !void {
    math.shutdown();
}

fn info(_: *phpz.ModuleEntry) void {
    phpz.info.table.start();
    phpz.info.table.header(.{ "qmath support", "enabled" });
    phpz.info.table.row(.{ "Version", extension.version.ptr });
    phpz.info.table.row(.{ "Thread safety", if (phpz.zts) "enabled" else "disabled" });
    phpz.info.table.row(.{ "Namespaces", "quark\\math, quark\\color" });
    const libm_state: [*:0]const u8 = if (@import("core/root.zig").libm.native) "yes" else "no, results may differ from PHP in the last bit";
    phpz.info.table.row(.{ "C runtime math", libm_state });
    phpz.info.table.end();
}
