--TEST--
Axis, Facing and Math
--SKIPIF--
<?php if (!extension_loaded('qmath')) die('skip qmath not loaded'); ?>
--FILE--
<?php
declare(strict_types=1);
use pocketmine\math\Axis;
use pocketmine\math\Facing;
use pocketmine\math\Math;

function t(callable $f) { try { var_dump($f()); } catch (Throwable $e) { echo get_class($e), ": ", $e->getMessage(), "\n"; } }

foreach (Facing::ALL as $f) echo Facing::toString($f), " axis=", Axis::toString(Facing::axis($f)), " opposite=", Facing::toString(Facing::opposite($f)), " positive=", var_export(Facing::isPositive($f), true), "\n";
echo Facing::toString(Facing::rotateY(Facing::NORTH, true)), " ", Facing::toString(Facing::rotateX(Facing::UP, false)), " ", Facing::toString(Facing::rotateZ(Facing::EAST, true)), "\n";
t(fn() => Facing::rotate(Facing::UP, Axis::Y, true));
t(fn() => Facing::rotate(9, Axis::Y, true));
t(fn() => Facing::rotate(Facing::UP, 3, true));
t(fn() => Facing::validate(6));
t(fn() => Axis::toString(3));
t(fn() => (new ReflectionClass(Facing::class))->newInstance());
var_dump(Math::floorFloat(-0.5), Math::ceilFloat(-0.5), Math::floorFloat(3), Math::floorFloat("2.5"), Math::floorFloat(NAN), Math::solveQuadratic(1, 2, 1), Math::solveQuadratic(1, 0, 1));
t(fn() => Math::solveQuadratic(0, 1, 1));
--EXPECT--
down axis=y opposite=up positive=false
up axis=y opposite=down positive=true
north axis=z opposite=south positive=false
south axis=z opposite=north positive=true
west axis=x opposite=east positive=false
east axis=x opposite=west positive=true
east south down
InvalidArgumentException: Cannot rotate facing "up" around axis "y"
InvalidArgumentException: Invalid facing 9
InvalidArgumentException: Invalid axis 3
InvalidArgumentException: Invalid direction 6
InvalidArgumentException: Invalid axis 3
ReflectionException: Access to non-public constructor of class pocketmine\math\Facing
int(-1)
int(0)
int(3)
int(2)
int(-1)
array(1) {
  [0]=>
  float(-1)
}
array(0) {
}
InvalidArgumentException: Coefficient a cannot be 0!
