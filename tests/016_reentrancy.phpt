--TEST--
PHP code running inside native calls cannot invalidate their state
--SKIPIF--
<?php if (!extension_loaded('qmath')) die('skip qmath not loaded'); ?>
--FILE--
<?php
declare(strict_types=1);
use quark\math\AxisAlignedBB;
use quark\math\RayTraceResult;
use quark\math\Vector2;
use quark\math\Vector3;

function t(callable $f) { try { var_dump($f()); } catch (Throwable $e) { echo get_class($e), ": ", $e->getMessage(), "\n"; } }

// Spatial keeps objects alive while a hook drops the last outside reference
class Ghost {
    public AxisAlignedBB $boundingBox { get { global $ghost; $ghost = null; return AxisAlignedBB::one(); } }
}
$ghost = new Ghost;
$list = [&$ghost];
var_dump(count(quark\math\collision\Spatial::overlapping($list, AxisAlignedBB::one()->expand(1, 1, 1))));

// oversized noise grids are rejected before any arithmetic
$noise = new quark\math\noise\Simplex(range(0, 255), 0.0, 0.0, 0.0, 1, 0.5, 1.0);
t(fn() => $noise->getFastNoise2D(PHP_INT_MAX, 0, 1, 0, 0, 0));
t(fn() => $noise->getFastNoise3D(PHP_INT_MAX, 0, 0, 1, 1, 1, 0, 0, 0));
t(fn() => $noise->getFastNoise1D(PHP_INT_MAX, 1, 0, 0, 0));

// string keys returned by sweepBoxes are owned correctly
for ($i = 0; $i < 3; ++$i) {
    $boxes = [str_repeat("far", 3) . $i => new AxisAlignedBB(-1, 0, 50, 1, 2, 50.1), str_repeat("near", 3) . $i => new AxisAlignedBB(-1, 0, 20, 1, 2, 20.1)];
    echo quark\math\collision\CollisionSolver::sweepBoxes(new AxisAlignedBB(-0.3, 0, -0.3, 0.3, 1.8, 0.3), 0, 0, 100, $boxes)->key, "\n";
}

class HookedV2 extends Vector2 {
    public float $x { get => $this->x * 2; }
}
var_dump((new HookedV2(1.5, 2.0))->length(), (new HookedV2(3.0, 4.0))->multiply(1.0)->x);
// results are immutable, also through subclasses
class SubHit extends RayTraceResult {}
$hit = new SubHit(AxisAlignedBB::one(), 2, new Vector3(0, 0, 0));
t(function () use ($hit) { $hit->hitFace = 3; });
t(fn() => $hit->__construct(AxisAlignedBB::one(), 3, new Vector3(0, 0, 0)));
var_dump((clone $hit)->hitFace);
--EXPECT--
int(1)
ValueError: Sample grid is too large
ValueError: Sample grid is too large
ValueError: Sample grid is too large
nearnearnear0
nearnearnear1
nearnearnear2
float(3.605551275463989)
float(6)
Error: Cannot modify readonly property quark\math\RayTraceResult::$hitFace
Error: Cannot modify readonly property quark\math\RayTraceResult::$bb
int(2)
