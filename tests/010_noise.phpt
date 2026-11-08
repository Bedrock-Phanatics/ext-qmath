--TEST--
Simplex noise sampling and validation
--SKIPIF--
<?php if (!extension_loaded('qmath')) die('skip qmath not loaded'); ?>
--FILE--
<?php
declare(strict_types=1);
use qmath\Simplex;

function t(callable $f) { try { var_dump($f()); } catch (Throwable $e) { echo get_class($e), ": ", $e->getMessage(), "\n"; } }

$perm = [];
for ($i = 0; $i < 256; ++$i) $perm[] = ($i * 151 + 7) % 256;
$a = new Simplex($perm, 12.25, 40.5, 99.75, 4, 0.25, 1 / 32);
$b = new Simplex(array_merge($perm, $perm), 12.25, 40.5, 99.75, 4, 0.25, 1 / 32);
$c = new Simplex(pack("C*", ...$perm), 12.25, 40.5, 99.75, 4, 0.25, 1 / 32);
var_dump($a->noise3D(10, 20, 30, true) === $b->noise3D(10, 20, 30, true), $a->noise2D(-5.5, 7.25) === $c->noise2D(-5.5, 7.25));
$v = $a->noise3D(100, 64, -100, true);
var_dump($v >= -1 && $v <= 1, is_float($a->getNoise2D(1, 2)));

$grid = $a->getFastNoise3D(16, 16, 16, 4, 8, 4, 32, 0, -48);
var_dump(count($grid), count($grid[0]), count($grid[0][0]), $grid[4][8][8] === $a->noise3D(36, 8, -40, true), $grid[16][1][0], $grid[3][5][7] !== 0);
$packed = unpack("e*", $a->getFastNoise3DPacked(16, 16, 16, 4, 8, 4, 32, 0, -48));
var_dump(count($packed), $packed[1] === $grid[0][0][0]);
$g2 = $a->getFastNoise2D(8, 8, 4, 0, 0, 0);
var_dump(count($g2), $g2[8][1], $g2[1][8], is_float($g2[3][3]));
var_dump(count($a->getFastNoise1D(16, 4, 0, 0, 0)));

t(fn() => new Simplex([1, 2, 3], 0, 0, 0, 1, 0.5, 1));
t(fn() => new Simplex(array_fill(0, 256, 300), 0, 0, 0, 1, 0.5, 1));
t(fn() => new Simplex(str_repeat("x", 100), 0, 0, 0, 1, 0.5, 1));
t(fn() => new Simplex($perm, 0, 0, 0, 0, 0.5, 1));
t(fn() => new Simplex($perm, NAN, 0, 0, 1, 0.5, 1));
t(fn() => new Simplex(1.5, 0, 0, 0, 1, 0.5, 1));
t(fn() => $a->getFastNoise1D(16, 0, 0, 0, 0));
t(fn() => $a->getFastNoise1D(15, 4, 0, 0, 0));
t(fn() => $a->getFastNoise3D(16, 16, 16, 4, 0, 4, 0, 0, 0));
t(fn() => $a->getFastNoise3D(4096, 4096, 4096, 4, 4, 4, 0, 0, 0));
t(fn() => (new ReflectionClass(Simplex::class))->newInstanceWithoutConstructor());
--EXPECT--
bool(true)
bool(true)
bool(true)
bool(true)
int(17)
int(17)
int(17)
bool(true)
int(0)
bool(true)
int(4913)
bool(true)
int(9)
NULL
NULL
bool(true)
int(17)
ValueError: Permutation arrays must have 256 or 512 entries
ValueError: Permutation entries must be ints between 0 and 255
ValueError: Permutation strings must be 256 or 512 bytes
ValueError: octaves must be between 1 and 64
ValueError: Offsets must be finite
TypeError: qmath\Simplex::__construct(): Argument #1 ($permutation) must be of type array|string, float given
InvalidArgumentException: samplingRate cannot be 0
InvalidArgumentException: xSize % samplingRate must return 0
ValueError: Sampling rates must be positive
ValueError: Sample grid is too large
ReflectionException: Class qmath\Simplex is an internal class marked as final that cannot be instantiated without invoking its constructor
