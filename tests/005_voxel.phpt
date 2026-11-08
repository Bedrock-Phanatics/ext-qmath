--TEST--
Voxel ray iterator semantics
--SKIPIF--
<?php if (!extension_loaded('qmath')) die('skip qmath not loaded'); ?>
--FILE--
<?php
declare(strict_types=1);
use quark\math\Vector3;
use quark\math\VoxelRayTrace;

$it = VoxelRayTrace::betweenPoints(new Vector3(0.5, 0.5, 0.5), new Vector3(-1.5, 2.5, 0.5));
var_dump(get_class($it), $it instanceof Iterator);
foreach ($it as $k => $v) echo $k, ":", $v, "\n";
var_dump($it->valid(), $it->current(), $it->key());
echo count(iterator_to_array($it)), "\n";
$it->rewind();
var_dump($it->current() === $it->current(), $it->current()->x);
foreach (VoxelRayTrace::inDirection(new Vector3(0, 70.2, 0), new Vector3(1, 0, 0), 1000.0) as $k => $v) {
    if ($k === 3) { echo $v, "\n"; break; }
}
// like the original generator, zero-length rays only throw when iterated
$zero = VoxelRayTrace::betweenPoints(new Vector3(1, 2, 3), new Vector3(1, 2, 3));
echo "created\n";
try { foreach ($zero as $v) {} } catch (InvalidArgumentException $e) { echo $e->getMessage(), "\n"; }
var_dump($zero->valid());
try { new quark\math\VoxelRayIterator(); } catch (Error $e) { echo get_class($e), "\n"; }
var_dump(quark\math\collision\Raycast::voxels(new Vector3(0.5, 0.5, 0.5), new Vector3(2.5, 0.5, 0.5)));
try { quark\math\collision\Raycast::voxels(new Vector3(0, 0, 0), new Vector3(100, 0, 0), 10); } catch (ValueError $e) { echo $e->getMessage(), "\n"; }
--EXPECT--
string(27) "quark\math\VoxelRayIterator"
bool(true)
0:Vector3(x=0,y=0,z=0)
1:Vector3(x=0,y=1,z=0)
2:Vector3(x=-1,y=1,z=0)
3:Vector3(x=-1,y=2,z=0)
4:Vector3(x=-2,y=2,z=0)
bool(false)
NULL
NULL
5
bool(true)
int(0)
Vector3(x=3,y=70,z=0)
created
Start and end points are the same, giving a zero direction vector
bool(false)
Error
array(9) {
  [0]=>
  int(0)
  [1]=>
  int(0)
  [2]=>
  int(0)
  [3]=>
  int(1)
  [4]=>
  int(0)
  [5]=>
  int(0)
  [6]=>
  int(2)
  [7]=>
  int(0)
  [8]=>
  int(0)
}
The ray visits more than 10 voxels
