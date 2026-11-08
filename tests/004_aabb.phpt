--TEST--
AxisAlignedBB mutation, validation and helpers
--SKIPIF--
<?php if (!extension_loaded('qmath')) die('skip qmath not loaded'); ?>
--FILE--
<?php
declare(strict_types=1);
use pocketmine\math\AxisAlignedBB;
use pocketmine\math\Vector3;
use pocketmine\math\Facing;
use pocketmine\math\Axis;

function t(callable $f) { try { var_dump($f()); } catch (Throwable $e) { echo get_class($e), ": ", $e->getMessage(), "\n"; } }

$bb = new AxisAlignedBB(0, 0, 0, 1, 2, 3);
var_dump($bb->expand(1, 1, 1) === $bb, (string) $bb);
$copy = $bb->offsetCopy(10, 0, 0);
var_dump($copy !== $bb, $bb->minX, $copy->minX);
var_dump((string) $bb->extendedCopy(Facing::UP, 2), (string) $bb->stretchedCopy(Axis::X, 1), (string) $bb->squashedCopy(Axis::Y, 0.5));
t(fn() => new AxisAlignedBB(2, 0, 0, 1, 1, 1));
t(fn() => new AxisAlignedBB(0, 0, 0.5, 1, 1, 0.25));
t(fn() => $bb->extend(7, 1));
t(fn() => $bb->stretch(-1, 1));
t(fn() => $bb->offsetTowards(6, 1));
$one = AxisAlignedBB::one();
var_dump($one->intersectsWith(new AxisAlignedBB(1, 0, 0, 2, 1, 1)), $one->intersectsWith(new AxisAlignedBB(0.5, 0.5, 0.5, 2, 2, 2)));
var_dump($one->calculateIntercept(new Vector3(-1, 0.5, 0.5), new Vector3(2, 0.5, 0.5))->hitFace === Facing::WEST);
var_dump($one->getCenter(), (string) $one->union(new AxisAlignedBB(-1, 0, 0, 0, 3, 1)));
var_dump($one->closestPoint(new Vector3(5, -2, 0.5)), $one->distanceSquaredTo(new Vector3(3, 0.5, 0.5)));
var_dump($one->intersectsSphere(new Vector3(2, 0.5, 0.5), 1.0), $one->intersectsSphere(new Vector3(2.1, 0.5, 0.5), 1.0));
var_dump($one->intersectsSegment(new Vector3(-1, 0.5, 0.5), new Vector3(2, 0.5, 0.5)), $one->intersectsSegment(new Vector3(-1, 1.5, 0.5), new Vector3(2, 1.5, 0.5)));
var_dump($one->isFinite(), (new AxisAlignedBB(-INF, 0, 0, 1, 1, 1))->isFinite());
$u = unserialize(serialize($bb));
var_dump($u == $bb, get_class($u));
--EXPECT--
bool(true)
string(34) "AxisAlignedBB(-1, -1, -1, 2, 3, 4)"
bool(true)
float(-1)
float(9)
string(34) "AxisAlignedBB(-1, -1, -1, 2, 5, 4)"
string(34) "AxisAlignedBB(-2, -1, -1, 3, 3, 4)"
string(38) "AxisAlignedBB(-1, -0.5, -1, 2, 2.5, 4)"
InvalidArgumentException: minX 2 is larger than maxX 1
InvalidArgumentException: minZ 0.5 is larger than maxZ 0.25
InvalidArgumentException: Invalid face 7
InvalidArgumentException: Invalid axis -1
InvalidArgumentException: Invalid Facing 6
bool(false)
bool(true)
bool(true)
object(pocketmine\math\Vector3)#6 (3) {
  ["x"]=>
  float(0.5)
  ["y"]=>
  float(0.5)
  ["z"]=>
  float(0.5)
}
string(32) "AxisAlignedBB(-1, 0, 0, 1, 3, 1)"
object(pocketmine\math\Vector3)#3 (3) {
  ["x"]=>
  float(1)
  ["y"]=>
  float(0)
  ["z"]=>
  float(0.5)
}
float(4)
bool(true)
bool(false)
bool(true)
bool(false)
bool(true)
bool(false)
bool(true)
string(29) "pocketmine\math\AxisAlignedBB"
