--TEST--
Matrix port
--SKIPIF--
<?php if (!extension_loaded('qmath')) die('skip qmath not loaded'); ?>
--FILE--
<?php
declare(strict_types=1);
use pocketmine\math\Matrix;

function t(callable $f) { try { var_dump($f()); } catch (Throwable $e) { echo get_class($e), ": ", $e->getMessage(), "\n"; } }

$m = new Matrix(2, 2, [[1, 2], [3, 4]]);
$o = new Matrix(2, 2, [[0.5, 0], [0, 0.5]]);
echo $m, "\n", $m->add($o), "\n", $m->subtract($o), "\n", $m->multiplyScalar(2), "\n", $m->transpose(), "\n", $m->product($o), "\n";
var_dump($m->determinant(), (new Matrix(3, 3, [[2, 0, 1], [1, 3, 2], [1, 1, 1]]))->determinant(), $m->getElement(1, 0), $m->isSquare());
$m[1] = [9, 9];
var_dump($m[1], isset($m[1]), isset($m[7]));
unset($m[1]);
var_dump(isset($m[1]));
t(fn() => (new Matrix(2, 3))->determinant());
t(fn() => (new Matrix(4, 4))->determinant());
t(fn() => $o->divideScalar(0));
t(fn() => $o->setElement(5, 0, 1.0));
t(fn() => $o->product(new Matrix(3, 1)));
var_dump((new Matrix(0, -5))->getRows(), (string) new Matrix(1, 2));
--EXPECT--
Matrix(2x2;1,2;3,4)
Matrix(2x2;1.5,2;3,4.5)
Matrix(2x2;0.5,2;3,3.5)
Matrix(2x2;2,4;6,8)
Matrix(2x2;1,3;2,4)
Matrix(2x2;0.5,1;1.5,2)
float(-2)
float(0)
float(3)
bool(true)
array(2) {
  [0]=>
  int(9)
  [1]=>
  int(9)
}
bool(true)
bool(false)
bool(false)
LogicException: Cannot calculate determinant of a non-square matrix
LogicException: Not implemented
DivisionByZeroError: Division by zero
InvalidArgumentException: Row or column out of bounds (have 2 rows 2 columns)
InvalidArgumentException: Expected a matrix with 2 rows
int(1)
string(15) "Matrix(1x2;0,0)"
