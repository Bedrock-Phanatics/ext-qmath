--TEST--
quark API: side arrays, removed legacy methods, immutable hits and solver axis order
--SKIPIF--
<?php if (!extension_loaded('qmath')) die('skip qmath not loaded'); ?>
--FILE--
<?php
declare(strict_types=1);
use quark\math\AxisAlignedBB;
use quark\math\Axis;
use quark\math\Facing;
use quark\math\Vector3;
use quark\math\collision\CollisionRegion;
use quark\math\collision\CollisionSolver;
use quark\math\collision\Raycast;
use quark\math\collision\VoxelHit;

function t(callable $f) { try { var_dump($f()); } catch (Throwable $e) { echo get_class($e), ": ", $e->getMessage(), "\n"; } }

// sides() is a plain array keyed by facing, sidesAroundAxis() drops the two faces on the axis
$v = new Vector3(0, 0, 0);
$sides = $v->sides();
var_dump(array_keys($sides), (string) $sides[Facing::NORTH], (string) $v->sides(-2)[Facing::EAST]);
var_dump(array_keys($v->sidesAroundAxis(Axis::Y)), array_keys($v->sidesAroundAxis(Axis::X)));
t(fn() => $v->sidesAroundAxis(3));
t(fn() => $v->sidesAroundAxis(-1));

// removed legacy methods are gone rather than silently aliased
foreach (['getX', 'getY', 'getZ', 'sidesArray', 'maxPlainDistance', 'getIntermediateWithXValue'] as $m) {
    var_dump(method_exists(Vector3::class, $m));
}
var_dump(method_exists(AxisAlignedBB::class, 'isVectorInYZ'), method_exists(quark\math\RayTraceResult::class, 'getHitFace'));

// block hits are immutable results
$r = new CollisionRegion();
$r->fillBox(-2, -2, -2, 4, 4, 4, CollisionRegion::INFO_NONE);
$r->fillBox(2, 0, 0, 2, 0, 0, CollisionRegion::INFO_CUBE);
$hit = Raycast::blocks($r, new Vector3(0.5, 0.5, 0.5), new Vector3(3.5, 0.5, 0.5));
var_dump($hit instanceof VoxelHit, [$hit->blockX, $hit->blockY, $hit->blockZ, $hit->hitFace], (string) $hit->hitVector);
t(function () use ($hit) { $hit->blockX = 5; });
$own = new VoxelHit(AxisAlignedBB::one(), Facing::UP, new Vector3(0, 1, 0), 0, 0, 0);
t(fn() => $own->__construct(AxisAlignedBB::one(), Facing::UP, new Vector3(0, 1, 0), 1, 1, 1));
var_dump($own->blockX);

// the solver keeps Minecraft's axis order: Y first, then X, then Z
$box = new AxisAlignedBB(0.2, 1.0, 0.2, 0.8, 2.8, 0.8);
$m = CollisionSolver::move($r, $box, 2.0, -1.0, 0.0);
var_dump($m->dx, $m->dy, $m->onGround, $m->collidedX, $m->boundingBox->minX);
var_dump($box->minY);
--EXPECT--
array(6) {
  [0]=>
  int(0)
  [1]=>
  int(1)
  [2]=>
  int(2)
  [3]=>
  int(3)
  [4]=>
  int(4)
  [5]=>
  int(5)
}
string(21) "Vector3(x=0,y=0,z=-1)"
string(21) "Vector3(x=-2,y=0,z=0)"
array(4) {
  [0]=>
  int(2)
  [1]=>
  int(3)
  [2]=>
  int(4)
  [3]=>
  int(5)
}
array(4) {
  [0]=>
  int(0)
  [1]=>
  int(1)
  [2]=>
  int(2)
  [3]=>
  int(3)
}
InvalidArgumentException: Invalid axis 3
InvalidArgumentException: Invalid axis -1
bool(false)
bool(false)
bool(false)
bool(false)
bool(false)
bool(false)
bool(false)
bool(false)
bool(true)
array(4) {
  [0]=>
  int(2)
  [1]=>
  int(0)
  [2]=>
  int(0)
  [3]=>
  int(4)
}
string(24) "Vector3(x=2,y=0.5,z=0.5)"
Error: Cannot modify readonly property quark\math\collision\VoxelHit::$blockX
Error: Cannot modify readonly property quark\math\RayTraceResult::$bb
int(0)
float(1.2)
float(-1)
bool(false)
bool(true)
float(1.4)
float(1)
