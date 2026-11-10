--TEST--
Extension loads and registers every class exactly once
--SKIPIF--
<?php if (!extension_loaded('qmath')) die('skip qmath not loaded'); ?>
--FILE--
<?php
var_dump(extension_loaded('qmath'), phpversion('qmath'));
// phpz registers an internal guard class whose name cannot be referenced from PHP
$names = array_values(array_filter((new ReflectionExtension('qmath'))->getClassNames(), fn($n) => !str_starts_with($n, 'PhpzGuard')));
sort($names);
var_dump(count($names) === count(array_unique($names)));
foreach ($names as $c) {
    $r = new ReflectionClass($c);
    echo $c, $r->isFinal() ? ' final' : '', $r->isInstantiable() ? '' : ' static', "\n";
}
foreach (['pocketmine\math\Vector3', 'pocketmine\color\Color', 'qmath\Collision', 'quark\math\Matrix'] as $old) {
    var_dump(class_exists($old));
}
$m = new ReflectionMethod('quark\math\Vector3', 'getSide');
var_dump($m->hasReturnType(), $m->getParameters()[1]->getDefaultValue());
var_dump((string) (new ReflectionMethod('quark\math\Vector3', 'round'))->getParameters()[1]);
var_dump((string) (new ReflectionProperty('quark\math\Vector3', 'x'))->getType());
var_dump((new ReflectionProperty('quark\math\RayTraceResult', 'hitFace'))->isReadOnly());
var_dump(quark\math\Facing::ALL, quark\math\Facing::HORIZONTAL, quark\math\Facing::OFFSET[quark\math\Facing::WEST]);
var_dump(new quark\math\Vector3(1, 2, 3) instanceof Stringable, is_subclass_of('quark\math\collision\CollisionDataException', 'RuntimeException'));
ob_start();
phpinfo(INFO_MODULES);
$info = ob_get_clean();
var_dump(str_contains($info, 'qmath support => enabled'));
--EXPECT--
bool(true)
string(5) "0.3.1"
bool(true)
quark\color\Color final
quark\math\Axis final static
quark\math\AxisAlignedBB final
quark\math\Facing final static
quark\math\Math final static
quark\math\RayTraceResult
quark\math\Vector2
quark\math\Vector3
quark\math\VectorMath final static
quark\math\VoxelRayIterator final static
quark\math\VoxelRayTrace final static
quark\math\collision\CollisionDataException
quark\math\collision\CollisionRegion final
quark\math\collision\CollisionSolver final static
quark\math\collision\MoveResult final static
quark\math\collision\Raycast final static
quark\math\collision\Spatial final static
quark\math\collision\SweepResult final static
quark\math\collision\VoxelHit final
quark\math\noise\Simplex final
quark\math\physics\ExplosionMath final static
quark\math\physics\Physics final static
quark\math\physics\ResistanceGrid final
bool(false)
bool(false)
bool(false)
bool(false)
bool(false)
int(1)
string(57) "Parameter #1 [ <optional> int $mode = PHP_ROUND_HALF_UP ]"
string(9) "int|float"
bool(true)
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
array(3) {
  [0]=>
  int(-1)
  [1]=>
  int(0)
  [2]=>
  int(0)
}
bool(true)
bool(true)
bool(true)
