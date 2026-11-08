<?php

declare(strict_types=1);

// gen_stub.php can't emit non-empty array constants, so they're registered natively and
// stripped from the copy it gets.

$root = dirname(__DIR__);
$stub = file_get_contents("$root/qmath.stub.php");
if ($stub === false) {
    fwrite(STDERR, "cannot read qmath.stub.php\n");
    exit(1);
}

$filtered = preg_replace('~^\s*/\*\* @var array \*/\R\s*public const \w+ = \[.*\];\R~m', '', $stub, -1, $count);
if ($filtered === null || $count !== 3) {
    fwrite(STDERR, "expected 3 array constants in the stub, found " . (int) $count . "\n");
    exit(1);
}

$tmp = "$root/build/qmath.stub.php";
file_put_contents($tmp, $filtered);
passthru(escapeshellarg(PHP_BINARY) . " " . escapeshellarg("$root/build/gen_stub.php") . " " . escapeshellarg($tmp), $status);
if ($status !== 0) {
    exit($status);
}
// Hash of the real stub, not the stripped copy.
$arginfo = file_get_contents("$root/build/qmath_arginfo.h");
$hash = sha1(str_replace("\r\n", "\n", $stub));
$arginfo = preg_replace('~\* Stub hash: [0-9a-f]+ \*/~', "* Stub hash: $hash */", $arginfo, 1);
file_put_contents("$root/qmath_arginfo.h", $arginfo);
unlink("$root/build/qmath_arginfo.h");
unlink($tmp);
