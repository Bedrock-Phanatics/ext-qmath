--TEST--
Raycast against blocks and entity boxes
--SKIPIF--
<?php if (!extension_loaded('qmath')) die('skip qmath not loaded'); ?>
--FILE--
<?php
declare(strict_types=1);
use pocketmine\math\AxisAlignedBB;
use pocketmine\math\Vector3;
use qmath\Raycast;
use qmath\CollisionRegion as R;

function t(callable $f) { try { var_dump($f()); } catch (Throwable $e) { echo get_class($e), ": ", $e->getMessage(), "\n"; } }

$r = new R(-8, -1, -8, 8, 8, 8);
$r->fill(R::INFO_NONE);
$r->setCell(4, 2, 0, R::INFO_CUBE);
$r->setCell(2, 2, 0, R::INFO_CUSTOM, [new AxisAlignedBB(2, 2, 0, 3, 2.5, 1)]);

$hit = Raycast::blocks($r, new Vector3(0.5, 2.25, 0.5), new Vector3(7.5, 2.25, 0.5));
var_dump(get_class($hit), $hit instanceof pocketmine\math\RayTraceResult, $hit->blockX, $hit->blockY, $hit->blockZ, $hit->hitFace, (string) $hit->hitVector, (string) $hit->bb);
$hit = Raycast::blocks($r, new Vector3(0.5, 2.75, 0.5), new Vector3(7.5, 2.75, 0.5));
var_dump($hit->blockX, $hit->getHitFace());
var_dump(Raycast::blocks($r, new Vector3(0.5, 4.5, 0.5), new Vector3(7.5, 4.5, 0.5)));
var_dump(Raycast::lineOfSight($r, new Vector3(0.5, 4.5, 0.5), new Vector3(7.5, 4.5, 0.5)), Raycast::lineOfSight($r, new Vector3(0.5, 2.75, 0.5), new Vector3(7.5, 2.75, 0.5)), Raycast::lineOfSight($r, new Vector3(1, 1, 1), new Vector3(1, 1, 1)));
t(fn() => Raycast::blocks($r, new Vector3(1, 1, 1), new Vector3(1, 1, 1)));
t(fn() => Raycast::blocks($r, new Vector3(0.5, 2.75, 0.5), new Vector3(30, 2.75, 0.5)));
$r->invalidateCell(3, 2, 0);
t(fn() => Raycast::blocks($r, new Vector3(0.5, 2.75, 0.5), new Vector3(7.5, 2.75, 0.5)));
$r->setCell(3, 2, 0, R::INFO_NONE);

// entity boxes keep their keys and the nearest hit wins
$boxes = ['far' => new AxisAlignedBB(6, 0, 0, 7, 2, 1), 'near' => new AxisAlignedBB(3, 0, 0, 4, 2, 1), 9 => new AxisAlignedBB(0, 5, 0, 1, 6, 1)];
[$key, $res] = Raycast::boxes(new Vector3(0.5, 1, 0.5), new Vector3(9.5, 1, 0.5), $boxes, 0.3);
var_dump($key, (string) $res->hitVector, (string) $res->bb);
var_dump(Raycast::boxes(new Vector3(0.5, 3, 0.5), new Vector3(9.5, 3, 0.5), $boxes));
t(fn() => Raycast::boxes(new Vector3(0, 0, 0), new Vector3(1, 1, 1), [1]));

// batched rays use packed buffers
$segments = pack("e*", 0.5, 2.25, 0.5, 7.5, 2.25, 0.5) . pack("e*", 0.5, 4.5, 0.5, 7.5, 4.5, 0.5);
$out = Raycast::batchBlocks($r, $segments);
var_dump(strlen($out), unpack("qface/qx/qy/qz/ehx/ehy/ehz", $out), unpack("qface", substr($out, 56))["face"]);
t(fn() => Raycast::batchBlocks($r, "short"));
var_dump(Raycast::batchBlocks($r, ""));
--EXPECT--
string(14) "qmath\VoxelHit"
bool(true)
int(2)
int(2)
int(0)
int(4)
string(25) "Vector3(x=2,y=2.25,z=0.5)"
string(33) "AxisAlignedBB(2, 2, 0, 3, 2.5, 1)"
int(4)
int(4)
NULL
bool(true)
bool(false)
bool(true)
InvalidArgumentException: Start and end points are the same, giving a zero direction vector
object(qmath\VoxelHit)#3 (6) {
  ["bb"]=>
  object(pocketmine\math\AxisAlignedBB)#6 (6) {
    ["minX"]=>
    float(4)
    ["minY"]=>
    float(2)
    ["minZ"]=>
    float(0)
    ["maxX"]=>
    float(5)
    ["maxY"]=>
    float(3)
    ["maxZ"]=>
    float(1)
  }
  ["hitFace"]=>
  int(4)
  ["hitVector"]=>
  object(pocketmine\math\Vector3)#10 (3) {
    ["x"]=>
    float(4)
    ["y"]=>
    float(2.75)
    ["z"]=>
    float(0.5)
  }
  ["blockX"]=>
  int(4)
  ["blockY"]=>
  int(2)
  ["blockZ"]=>
  int(0)
}
qmath\CollisionDataException: The query needs a cell with no collision data
string(4) "near"
string(24) "Vector3(x=2.7,y=1,z=0.5)"
string(45) "AxisAlignedBB(2.7, -0.3, -0.3, 4.3, 2.3, 1.3)"
NULL
TypeError: qmath\Raycast::boxes(): Argument #3 ($boxes) must contain only pocketmine\math\AxisAlignedBB, int found
int(112)
array(7) {
  ["face"]=>
  int(4)
  ["x"]=>
  int(2)
  ["y"]=>
  int(2)
  ["z"]=>
  int(0)
  ["hx"]=>
  float(2)
  ["hy"]=>
  float(2.25)
  ["hz"]=>
  float(0.5)
}
int(-1)
ValueError: Segments must be a multiple of 48 bytes
string(0) ""
