--TEST--
Extension loads and exposes the expected classes
--SKIPIF--
<?php if (!extension_loaded('qmath')) die('skip qmath not loaded'); ?>
--FILE--
<?php
var_dump(extension_loaded('qmath'), phpversion('qmath'));
foreach (['pocketmine\math\Vector3', 'pocketmine\math\AxisAlignedBB', 'pocketmine\math\Facing', 'pocketmine\color\Color', 'qmath\CollisionRegion', 'qmath\VoxelRayIterator'] as $c) {
    $r = new ReflectionClass($c);
    echo $c, ' internal=', var_export($r->isInternal(), true), ' final=', var_export($r->isFinal(), true), "\n";
}
$m = new ReflectionMethod('pocketmine\math\Vector3', 'getSide');
var_dump($m->hasReturnType(), $m->getParameters()[1]->getDefaultValue());
var_dump((string) (new ReflectionMethod('pocketmine\math\Vector3', 'round'))->getParameters()[1]);
var_dump((string) (new ReflectionProperty('pocketmine\math\Vector3', 'x'))->getType());
var_dump(pocketmine\math\Facing::ALL, pocketmine\math\Facing::HORIZONTAL, pocketmine\math\Facing::OFFSET[pocketmine\math\Facing::WEST]);
var_dump(new pocketmine\math\Vector3(1, 2, 3) instanceof Stringable, new pocketmine\math\Matrix(1, 1) instanceof ArrayAccess, is_subclass_of('qmath\CollisionDataException', 'RuntimeException'));
ob_start();
phpinfo(INFO_MODULES);
$info = ob_get_clean();
var_dump(str_contains($info, 'qmath support => enabled'));
--EXPECT--
bool(true)
string(5) "0.1.0"
pocketmine\math\Vector3 internal=true final=false
pocketmine\math\AxisAlignedBB internal=true final=true
pocketmine\math\Facing internal=true final=true
pocketmine\color\Color internal=true final=true
qmath\CollisionRegion internal=true final=true
qmath\VoxelRayIterator internal=true final=true
bool(false)
int(1)
string(57) "Parameter #1 [ <optional> int $mode = PHP_ROUND_HALF_UP ]"
string(9) "int|float"
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
bool(true)
