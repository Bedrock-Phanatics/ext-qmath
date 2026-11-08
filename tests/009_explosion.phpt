--TEST--
Explosion ray tracing and exposure
--SKIPIF--
<?php if (!extension_loaded('qmath')) die('skip qmath not loaded'); ?>
--FILE--
<?php
declare(strict_types=1);
use quark\math\AxisAlignedBB;
use quark\math\Vector3;
use quark\math\physics\ExplosionMath;
use quark\math\physics\ResistanceGrid;
use quark\math\collision\CollisionRegion as R;

function t(callable $f) { try { var_dump($f()); } catch (Throwable $e) { echo get_class($e), ": ", $e->getMessage(), "\n"; } }

$g = new ResistanceGrid(-10, -10, -10, 10, 10, 10);
var_dump($g->getBounds()[3]);
t(fn() => ExplosionMath::traceRays($g, new Vector3(0.5, 0.5, 0.5), 4.0));
$g->fill(0.0);
$g->set(3, 0, 0, 6000.0);
$g->setInvalid(0, 5, 0);

mt_srand(42);
$a = ExplosionMath::traceRays($g, new Vector3(0.5, 0.5, 0.5), 4.0);
$after = mt_rand();
mt_srand(42);
$b = ExplosionMath::traceRays($g, new Vector3(0.5, 0.5, 0.5), 4.0);
var_dump($a === $b, $after === mt_rand(), count($a) % 3, count($a) > 300);
$cells = array_chunk($a, 3);
var_dump(in_array([0, 0, 0], $cells, true), in_array([3, 0, 0], $cells, true), in_array([4, 0, 0], $cells, true), in_array([0, 5, 0], $cells, true));

// one ray at a time consumes one mt_rand() call each, so Quark can interleave its own RNG use
mt_srand(42);
$per = ExplosionMath::traceRay($g, new Vector3(0.5, 0.5, 0.5), 4.0, 0, 0, 0);
var_dump(count($per) > 0, ExplosionMath::rayCount(), ExplosionMath::rayCount(4));
t(fn() => ExplosionMath::traceRay($g, new Vector3(0.5, 0.5, 0.5), 4.0, 5, 5, 5));
t(fn() => ExplosionMath::traceRays($g, new Vector3(0.5, 0.5, 0.5), 0.0));
t(fn() => ExplosionMath::traceRays($g, new Vector3(0.5, 0.5, 0.5), 4.0, 1));
t(fn() => ExplosionMath::traceRays($g, new Vector3(0.5, 0.5, 0.5), 4.0, 16, 1e-12));
t(fn() => ExplosionMath::traceRays($g, new Vector3(0.5, 0.5, 0.5), 9.0));
t(fn() => $g->set(0, 0, 0, NAN));
t(fn() => $g->setPacked("x"));
$small = new ResistanceGrid(0, 0, 0, 1, 1, 0);
$small->setPacked(pack("e*", 1.0, NAN, 2.0, 3.0));

$r = new R();
$r->fillBox(-8, -2, -8, 8, 8, 8, R::INFO_NONE);
$e = new AxisAlignedBB(3.7, 0, 0.2, 4.3, 1.8, 0.8);
var_dump(ExplosionMath::exposure($r, new Vector3(0.5, 0.5, 0.5), $e));
for ($y = -2; $y <= 8; ++$y) for ($z = -8; $z <= 8; ++$z) $r->setCell(2, $y, $z, R::INFO_CUBE);
var_dump(ExplosionMath::exposure($r, new Vector3(0.5, 0.5, 0.5), $e));
var_dump(ExplosionMath::exposures($r, new Vector3(0.5, 0.5, 0.5), ['zombie' => $e, 7 => new AxisAlignedBB(0, 0, 0.6, 1, 1, 1.6)]));
t(fn() => ExplosionMath::exposure($r, new Vector3(0.5, 0.5, 0.5), new AxisAlignedBB(0, 0, 0, 5000, 1, 1)));
--EXPECT--
int(10)
quark\math\collision\CollisionDataException: The explosion reaches a cell with no resistance data
bool(true)
bool(true)
int(0)
bool(true)
bool(true)
bool(false)
bool(false)
bool(false)
bool(true)
int(1352)
int(56)
ValueError: (5, 5, 5) is not one of the explosion's rays
ValueError: Invalid explosion parameters: radius and stepLen must be positive and finite, rays between 2 and 64, and the rays at most 1e8 steps long in total
ValueError: Invalid explosion parameters: radius and stepLen must be positive and finite, rays between 2 and 64, and the rays at most 1e8 steps long in total
ValueError: Invalid explosion parameters: radius and stepLen must be positive and finite, rays between 2 and 64, and the rays at most 1e8 steps long in total
quark\math\collision\CollisionDataException: The explosion reaches outside the resistance grid
ValueError: Resistance must not be NAN, use setInvalid()
ValueError: Expected 74088 bytes, one double per cell
float(1)
float(0)
array(2) {
  ["zombie"]=>
  float(0)
  [7]=>
  float(1)
}
ValueError: Bounding box is too large to sample
