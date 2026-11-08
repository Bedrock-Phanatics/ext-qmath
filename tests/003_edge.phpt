--TEST--
Vector3 typed property, reference and arithmetic edge cases
--SKIPIF--
<?php if (!extension_loaded('qmath')) die('skip qmath not loaded'); ?>
--FILE--
<?php
declare(strict_types=1);
use pocketmine\math\Vector3;
use pocketmine\math\AxisAlignedBB;

function t(callable $f) { try { var_dump($f()); } catch (Throwable $e) { echo get_class($e), ": ", $e->getMessage(), "\n"; } }

$r = new ReflectionClass(Vector3::class);
$u = $r->newInstanceWithoutConstructor();
t(fn() => $u->add(1, 1, 1));
t(fn() => $u->length());
$v = new Vector3(1, 2, 3);
unset($v->y);
t(fn() => $v->lengthSquared());

// internal classes and their subclasses cannot be lazy
class Sub extends Vector3 {}
t(fn() => (new ReflectionClass(Sub::class))->newLazyGhost(function (Sub $o) { $o->__construct(3, 4, 0); }));

// typed references are respected on in-place writes
$bb = new AxisAlignedBB(0, 0, 0, 1, 1, 1);
$ref = &$bb->minX;
$bb->offset(2, 0, 0);
var_dump($ref, $bb->minX);
$ref = 5.0;
var_dump($bb->minX);

// int and float are preserved like PHP arithmetic
var_dump((new Vector3(PHP_INT_MAX, 1, 1))->add(1, 0, 0)->x, (new Vector3(PHP_INT_MIN, 0, 0))->abs()->x, (new Vector3(1, 2, 3))->cross(new Vector3(4, 5, 6)));
t(fn() => (new Vector3(1, 2, 3))->divide(0));
t(fn() => (new Vector3(1, 2, 3))->round(0, 42));
t(fn() => (new Vector3(1.25, 2.5, -2.5))->round(1));
t(fn() => (new Vector3(1.5, 2.5, -2.5))->round());
t(fn() => (new Vector3(1, 2, 3))->getSide(9));
t(fn() => (new Vector3(1, 2, 3))->addVector(new stdClass));
t(fn() => (new Vector3(1, 2, 3))->withComponents(null, 5, null));
t(fn() => (new Vector3(1, 1, 1))->lerp(new Vector3(3, 1, -1), 0.5));
t(fn() => (new Vector3(0, 0, 0))->normalizeOrNull());
t(fn() => [(new Vector3(2, 0, 0))->angle(new Vector3(0, 3, 0)), (new Vector3(1, 1, 0))->project(new Vector3(2, 0, 0))->x, (new Vector3(0, 10, 0))->moveTowards(new Vector3(0, 0, 0), 4)->y]);
t(fn() => (new Vector3(5, -5, 0))->clamp(new Vector3(0, 0, 0), new Vector3(2, 2, 2)));
t(fn() => [(new Vector3(1, 2, 3))->isFinite(), (new Vector3(INF, 2, 3))->isFinite()]);
--EXPECT--
Error: Typed property pocketmine\math\Vector3::$x must not be accessed before initialization
Error: Typed property pocketmine\math\Vector3::$x must not be accessed before initialization
Error: Typed property pocketmine\math\Vector3::$y must not be accessed before initialization
Error: Cannot make instance of internal class lazy: Sub inherits internal class pocketmine\math\Vector3
float(2)
float(2)
float(5)
float(9.223372036854776E+18)
float(9.223372036854776E+18)
object(pocketmine\math\Vector3)#4 (3) {
  ["x"]=>
  int(-3)
  ["y"]=>
  int(6)
  ["z"]=>
  int(-3)
}
DivisionByZeroError: Division by zero
ValueError: round(): Argument #3 ($mode) must be a valid rounding mode (RoundingMode::*)
object(pocketmine\math\Vector3)#4 (3) {
  ["x"]=>
  float(1.3)
  ["y"]=>
  float(2.5)
  ["z"]=>
  float(-2.5)
}
object(pocketmine\math\Vector3)#6 (3) {
  ["x"]=>
  int(2)
  ["y"]=>
  int(3)
  ["z"]=>
  int(-3)
}
object(pocketmine\math\Vector3)#4 (3) {
  ["x"]=>
  int(1)
  ["y"]=>
  int(2)
  ["z"]=>
  int(3)
}
TypeError: pocketmine\math\Vector3::addVector(): Argument #1 ($v) must be of type pocketmine\math\Vector3, stdClass given
object(pocketmine\math\Vector3)#6 (3) {
  ["x"]=>
  int(1)
  ["y"]=>
  int(5)
  ["z"]=>
  int(3)
}
object(pocketmine\math\Vector3)#4 (3) {
  ["x"]=>
  float(2)
  ["y"]=>
  float(1)
  ["z"]=>
  float(0)
}
NULL
array(3) {
  [0]=>
  float(1.5707963267948966)
  [1]=>
  float(1)
  [2]=>
  float(6)
}
object(pocketmine\math\Vector3)#9 (3) {
  ["x"]=>
  float(2)
  ["y"]=>
  float(0)
  ["z"]=>
  float(0)
}
array(2) {
  [0]=>
  bool(true)
  [1]=>
  bool(false)
}
