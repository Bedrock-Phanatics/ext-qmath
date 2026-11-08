--TEST--
Physics formulas and spatial filters
--SKIPIF--
<?php if (!extension_loaded('qmath')) die('skip qmath not loaded'); ?>
--FILE--
<?php
declare(strict_types=1);
use quark\math\AxisAlignedBB;
use quark\math\Vector3;
use quark\math\physics\Physics;
use quark\math\collision\Spatial;

function t(callable $f) { try { var_dump($f()); } catch (Throwable $e) { echo get_class($e), ": ", $e->getMessage(), "\n"; } }

// tiny components collapse to int 0 like Entity::onUpdate()
var_dump(Physics::motionStep(new Vector3(0.5, 0.0, 0.000001), 0.02, 0.08));
var_dump(Physics::motionStep(new Vector3(0.5, 0.2, 0), 0.02, 0.08, true, true)->y, Physics::motionStep(new Vector3(0.5, 0.2, 0), 0.02, 0.08, true, false)->y);
var_dump(Physics::motionStep(new Vector3(1, 0, 1), 0.02, 0.08, false, false, 0.6)->x);
var_dump(Physics::knockBack(new Vector3(0, 1, 0), 1, 0), Physics::knockBack(new Vector3(0, 0, 0), 0, 0), Physics::knockBack(new Vector3(0, 0, 0), 0, 1, 0.5, null)->y);
var_dump(Physics::horizontalFacing(-90.0), Physics::horizontalFacing(180.0), Physics::directionPlane(90.0));
var_dump(Physics::lookAt(new Vector3(0, 1.62, 0), new Vector3(0, 1.62, 10)), Physics::motionRotation(new Vector3(1, 0, 0)));
var_dump(quark\math\VectorMath::getDirection3D(0.0, 90.0));
$path = unpack("e*", Physics::predictTrajectory(new Vector3(0, 64, 0), new Vector3(1, 0.5, 0), 0.01, 0.05, 3, true));
var_dump(count($path), $path[1] > 0, $path[8] < $path[2] + 1);
t(fn() => Physics::predictTrajectory(new Vector3(0, 0, 0), new Vector3(0, 0, 0), 0.01, 0.05, -1));

class Mob { public function __construct(public AxisAlignedBB $boundingBox) {} }
class Hidden { protected AxisAlignedBB $boundingBox; public function __construct() { $this->boundingBox = AxisAlignedBB::one(); } }
$mobs = ['a' => new Mob(new AxisAlignedBB(0, 0, 0, 1, 2, 1)), 'b' => new Mob(new AxisAlignedBB(5, 0, 5, 6, 2, 6)), 'c' => new Mob(new AxisAlignedBB(0.5, 1, 0.5, 1.5, 3, 1.5))];
$near = Spatial::overlapping($mobs, new AxisAlignedBB(-1, -1, -1, 2, 2, 2));
var_dump(count($near), $near[0] === $mobs['a'], array_keys($near));
var_dump(count(Spatial::overlapping($mobs, new AxisAlignedBB(-1, -1, -1, 2, 2, 2), $mobs['a'])));
var_dump(Spatial::overlappingBoxes(new AxisAlignedBB(-1, -1, -1, 2, 2, 2), array_map(fn($m) => $m->boundingBox, $mobs)));
var_dump(Spatial::overlappingBoxes(AxisAlignedBB::one(), [new AxisAlignedBB(1, 0, 0, 2, 1, 1)], 0.0), Spatial::overlappingBoxes(AxisAlignedBB::one(), [new AxisAlignedBB(1, 0, 0, 2, 1, 1)], -0.1));
t(fn() => Spatial::overlapping([new Hidden], AxisAlignedBB::one()));
t(fn() => Spatial::overlapping([1], AxisAlignedBB::one()));
t(fn() => Spatial::overlapping([new stdClass], AxisAlignedBB::one(), null, "missing"));
--EXPECTF--
object(quark\math\Vector3)#2 (3) {
  ["x"]=>
  float(0.49)
  ["y"]=>
  float(-0.0784)
  ["z"]=>
  int(0)
}
float(0.116)
float(0.11760000000000001)
float(0.588)
object(quark\math\Vector3)#2 (3) {
  ["x"]=>
  float(0.4)
  ["y"]=>
  float(0.4)
  ["z"]=>
  float(0)
}
NULL
float(0.5)
int(5)
int(2)
object(quark\math\Vector2)#2 (2) {
  ["x"]=>
  float(-1)
  ["y"]=>
  float(-0)
}
array(2) {
  [0]=>
  float(0)
  [1]=>
  float(-0)
}
array(2) {
  [0]=>
  float(90)
  [1]=>
  float(0)
}
object(quark\math\Vector3)#3 (3) {
  ["x"]=>
  float(-0)
  ["y"]=>
  float(-1)
  ["z"]=>
  float(6.123233995736766E-17)
}
int(9)
bool(true)
bool(true)
ValueError: ticks must be between 0 and 1000000
int(2)
bool(true)
array(2) {
  [0]=>
  int(0)
  [1]=>
  int(1)
}
int(1)
array(2) {
  [0]=>
  string(1) "a"
  [1]=>
  string(1) "c"
}
array(0) {
}
array(1) {
  [0]=>
  int(0)
}
Error: Cannot access protected property Hidden::$boundingBox
TypeError: quark\math\collision\Spatial::overlapping(): Argument #1 ($objects) must contain only objects, int found

Warning: Undefined property: stdClass::$missing in %s on line %d
TypeError: stdClass::$missing must be a quark\math\AxisAlignedBB
