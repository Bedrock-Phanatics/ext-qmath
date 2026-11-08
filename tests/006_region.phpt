--TEST--
CollisionRegion storage, validation and invalidation
--SKIPIF--
<?php if (!extension_loaded('qmath')) die('skip qmath not loaded'); ?>
--FILE--
<?php
declare(strict_types=1);
use pocketmine\math\AxisAlignedBB;
use qmath\CollisionRegion;

function t(callable $f) { try { var_dump($f()); } catch (Throwable $e) { echo get_class($e), ": ", $e->getMessage(), "\n"; } }

$r = new CollisionRegion();
var_dump($r->getVersion(), $r->getSectionCount(), $r->isKnown(0, 0, 0), $r->getCellInfo(0, 0, 0));
t(fn() => $r->getCollisionBoxes(new AxisAlignedBB(0, 0, 0, 1, 1, 1)));
var_dump($r->missingSections(new AxisAlignedBB(0.5, 0.5, 0.5, 1, 1, 1)));
$r->fillBox(-16, -16, -16, 15, 15, 15, CollisionRegion::INFO_NONE);
var_dump($r->getSectionCount(), $r->missingSections(new AxisAlignedBB(0.5, 0.5, 0.5, 1, 1, 1)));
$r->setCell(0, 0, 0, CollisionRegion::INFO_CUBE);
$r->setCell(1, 0, 0, CollisionRegion::INFO_CUSTOM, [new AxisAlignedBB(1, 0, 0, 2, 0.5, 1)]);
$r->setCellPacked(-1, 0, 0, CollisionRegion::INFO_MAY_OVERFLOW, pack("e*", -0.625, 0, 0.375, -0.375, 1.5, 0.625));
var_dump($r->getVersion() > 0, $r->getCellInfo(1, 0, 0), count($r->getCellBoxes(0, 0, 0)), (string) $r->getCellBoxes(1, 0, 0)[0]);
// the fence post overflows into the cell above it, World lists it twice
foreach ($r->getCollisionBoxes(new AxisAlignedBB(-1.5, 0, 0, 1.5, 2, 1)) as $b) echo $b, "\n";
var_dump($r->collides(new AxisAlignedBB(0.2, 1.2, 0.2, 0.8, 1.4, 0.8)), $r->collides(new AxisAlignedBB(-0.6, 1.2, 0.4, -0.4, 1.4, 0.6)));
var_dump($r->isComplete(new AxisAlignedBB(0, 0, 0, 1, 1, 1)), $r->isComplete(new AxisAlignedBB(0, 0, 0, 1, 20, 1)));
t(fn() => $r->getCollisionBoxes(new AxisAlignedBB(0, 0, 0, 1, 20, 1)));
var_dump($r->missingSections(new AxisAlignedBB(0, 0, 0, 1, 20, 1)));

// whole sections, indexed like SubChunk: (x << 8) | (z << 4) | y
$infos = str_repeat(chr(CollisionRegion::INFO_NONE), 4096);
$infos[(3 << 8) | (4 << 4) | 5] = chr(CollisionRegion::INFO_CUSTOM);
$infos[0] = chr(CollisionRegion::INFO_CUBE);
$r->setSection(1, 0, 0, $infos, [(3 << 8) | (4 << 4) | 5 => [new AxisAlignedBB(19, 5, 4, 20, 5.5, 5)]]);
var_dump($r->getCellInfo(16, 0, 0), $r->getCellInfo(19, 5, 4), (string) $r->getCellBoxes(19, 5, 4)[0], $r->getCellInfo(17, 0, 0));
$r->setSection(2, 0, 0, str_repeat(chr(CollisionRegion::INFO_CUBE), 4096));
var_dump($r->getCellInfo(40, 9, 3), $r->getSectionCount());

// validation
t(fn() => $r->setCell(1 << 40, 0, 0, CollisionRegion::INFO_NONE));
t(fn() => $r->setCell(0, 0, 0, 7));
t(fn() => $r->setCell(0, 0, 0, CollisionRegion::INFO_CUBE, [AxisAlignedBB::one()]));
t(fn() => $r->setCell(0, 0, 0, CollisionRegion::INFO_CUSTOM, [new stdClass]));
t(fn() => $r->setCell(0, 0, 0, CollisionRegion::INFO_CUSTOM, array_fill(0, 65, AxisAlignedBB::one())));
t(fn() => $r->setCell(0, 0, 0, CollisionRegion::INFO_CUSTOM, [new AxisAlignedBB(NAN, 0, 0, 1, 1, 1)]));
t(fn() => $r->setCellPacked(0, 0, 0, CollisionRegion::INFO_CUSTOM, "abc"));
t(fn() => $r->setCellPacked(0, 0, 0, CollisionRegion::INFO_CUSTOM, pack("e*", 1, 0, 0, 0, 1, 1)));
t(fn() => $r->setSection(0, 0, 0, "short"));
t(fn() => $r->setSection(0, 0, 0, str_repeat("\x09", 4096)));
t(fn() => $r->setSection(0, 0, 0, str_repeat("\x02", 4096), [5 => [AxisAlignedBB::one()]]));
t(fn() => $r->setSection(0, 0, 0, str_repeat("\x00", 4096), [4096 => []]));
t(fn() => $r->getCollisionBoxes(new AxisAlignedBB(0, 0, 0, INF, 1, 1)));
t(fn() => $r->getCollisionBoxes(new AxisAlignedBB(-1e6, 0, -1e6, 1e6, 1, 1e6)));
t(fn() => $r->fillBox(0, 0, 0, 1, 1, 1, CollisionRegion::INFO_CUSTOM));
t(fn() => $r->fillBox(0, 0, 0, 100000, 100, 100000, CollisionRegion::INFO_NONE));
t(fn() => new CollisionRegion(0));
$small = new CollisionRegion(1);
$small->setCell(0, 0, 0, CollisionRegion::INFO_NONE);
t(fn() => $small->setCell(16, 0, 0, CollisionRegion::INFO_NONE));
t(fn() => (new ReflectionClass(CollisionRegion::class))->newInstanceWithoutConstructor());

// invalidation forgets the block and its neighbours
$r->invalidateBlock(0, 1, 0);
var_dump($r->isKnown(0, 1, 0), $r->isKnown(0, 0, 0), $r->isKnown(1, 1, 0), $r->isKnown(1, 0, 0));
t(fn() => $r->getCollisionBoxes(new AxisAlignedBB(0.2, 0.2, 0.2, 0.8, 0.8, 0.8)));
var_dump($r->missingSections(new AxisAlignedBB(0.2, 0.2, 0.2, 0.8, 0.8, 0.8)));
$before = $r->getSectionCount();
$r->invalidateChunk(-1, -1);
var_dump($before - $r->getSectionCount(), $r->isKnown(-1, 2, -1), $r->isKnown(0, 2, 0));
$r->invalidateSection(1, 0, 0);
var_dump($r->isKnown(16, 0, 0));
$r->invalidateAll();
var_dump($r->getSectionCount());

// snapshots are frozen copies, clones are independent
$r->fillBox(-16, -16, -16, 15, 15, 15, CollisionRegion::INFO_CUBE);
$s = $r->snapshot();
var_dump($s->isFrozen(), $r->isFrozen());
t(fn() => $s->setCell(0, 0, 0, CollisionRegion::INFO_NONE));
$c = clone $r;
$c->setCell(0, 0, 0, CollisionRegion::INFO_NONE);
var_dump($c->getCellInfo(0, 0, 0), $r->getCellInfo(0, 0, 0), $s->getCellInfo(0, 0, 0));
$r->freeze();
t(fn() => $r->invalidateAll());
t(fn() => serialize($r));
--EXPECT--
int(0)
int(0)
bool(false)
int(-1)
qmath\CollisionDataException: The query needs a cell with no collision data
array(24) {
  [0]=>
  int(-1)
  [1]=>
  int(-1)
  [2]=>
  int(-1)
  [3]=>
  int(-1)
  [4]=>
  int(0)
  [5]=>
  int(-1)
  [6]=>
  int(-1)
  [7]=>
  int(-1)
  [8]=>
  int(0)
  [9]=>
  int(-1)
  [10]=>
  int(0)
  [11]=>
  int(0)
  [12]=>
  int(0)
  [13]=>
  int(-1)
  [14]=>
  int(-1)
  [15]=>
  int(0)
  [16]=>
  int(0)
  [17]=>
  int(-1)
  [18]=>
  int(0)
  [19]=>
  int(-1)
  [20]=>
  int(0)
  [21]=>
  int(0)
  [22]=>
  int(0)
  [23]=>
  int(0)
}
int(8)
array(0) {
}
bool(true)
int(0)
int(1)
string(33) "AxisAlignedBB(1, 0, 0, 2, 0.5, 1)"
AxisAlignedBB(-0.625, 0, 0.375, -0.375, 1.5, 0.625)
AxisAlignedBB(-0.625, 0, 0.375, -0.375, 1.5, 0.625)
AxisAlignedBB(0, 0, 0, 1, 1, 1)
AxisAlignedBB(1, 0, 0, 2, 0.5, 1)
bool(false)
bool(true)
bool(true)
bool(false)
qmath\CollisionDataException: The query needs a cell with no collision data
array(12) {
  [0]=>
  int(-1)
  [1]=>
  int(1)
  [2]=>
  int(-1)
  [3]=>
  int(-1)
  [4]=>
  int(1)
  [5]=>
  int(0)
  [6]=>
  int(0)
  [7]=>
  int(1)
  [8]=>
  int(-1)
  [9]=>
  int(0)
  [10]=>
  int(1)
  [11]=>
  int(0)
}
int(1)
int(0)
string(35) "AxisAlignedBB(19, 5, 4, 20, 5.5, 5)"
int(2)
int(1)
int(10)
ValueError: Cell 1099511627776 0 0 is outside the supported world range
ValueError: Invalid collision info 7
ValueError: Invalid collision info, or boxes given for INFO_CUBE or INFO_NONE
TypeError: qmath\CollisionRegion::setCell(): Argument #5 ($boxes) must contain only pocketmine\math\AxisAlignedBB, stdClass found
ValueError: Too many collision boxes for one cell
ValueError: Bounding boxes must be finite with min <= max
ValueError: Packed boxes must be a multiple of 48 bytes
ValueError: Bounding boxes must be finite with min <= max
ValueError: infos must be exactly 4096 bytes
ValueError: Invalid collision info 9
ValueError: Boxes were given for a cell that is not INFO_CUSTOM or INFO_MAY_OVERFLOW
ValueError: Box keys must be cell indexes between 0 and 4095
ValueError: Bounding boxes must be finite with min <= max
qmath\CollisionDataException: The region is full, or the query spans too many sections
ValueError: fillBox() only accepts INFO_NONE or INFO_CUBE
ValueError: fillBox() covers too many cells
ValueError: maxSections must be between 1 and 16777216
qmath\CollisionDataException: The region is full, or the query spans too many sections
ReflectionException: Class qmath\CollisionRegion is an internal class marked as final that cannot be instantiated without invoking its constructor
bool(false)
bool(false)
bool(false)
bool(true)
qmath\CollisionDataException: The query needs a cell with no collision data
array(9) {
  [0]=>
  int(-1)
  [1]=>
  int(0)
  [2]=>
  int(0)
  [3]=>
  int(0)
  [4]=>
  int(0)
  [5]=>
  int(-1)
  [6]=>
  int(0)
  [7]=>
  int(0)
  [8]=>
  int(0)
}
int(2)
bool(false)
bool(false)
bool(false)
int(0)
bool(true)
bool(false)
LogicException: Cannot modify a frozen collision region
int(2)
int(1)
int(1)
LogicException: Cannot modify a frozen collision region
Exception: Serialization of 'qmath\CollisionRegion' is not allowed
