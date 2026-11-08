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

$r = new CollisionRegion(-3, -1, -3, 3, 3, 3);
var_dump($r->getBounds(), $r->getVersion(), $r->contains(3, 3, 3), $r->contains(4, 0, 0), $r->isKnown(0, 0, 0), $r->getCellInfo(0, 0, 0));
t(fn() => $r->getCollisionBoxes(new AxisAlignedBB(0, 0, 0, 1, 1, 1)));
$r->fill(CollisionRegion::INFO_NONE);
$r->setCell(0, 0, 0, CollisionRegion::INFO_CUBE);
$r->setCell(1, 0, 0, CollisionRegion::INFO_CUSTOM, [new AxisAlignedBB(1, 0, 0, 2, 0.5, 1)]);
$r->setCellPacked(-1, 0, 0, CollisionRegion::INFO_MAY_OVERFLOW, pack("e*", -0.625, 0, 0.375, -0.375, 1.5, 0.625));
var_dump($r->getVersion() > 0, $r->getCellInfo(1, 0, 0), count($r->getCellBoxes(0, 0, 0)), (string) $r->getCellBoxes(1, 0, 0)[0]);
// the fence post overflows into the cell above it
foreach ($r->getCollisionBoxes(new AxisAlignedBB(-1.5, 0, 0, 1.5, 2, 1)) as $b) echo $b, "\n";
var_dump($r->collides(new AxisAlignedBB(0.2, 1.2, 0.2, 0.8, 1.4, 0.8)), $r->collides(new AxisAlignedBB(-0.6, 1.2, 0.4, -0.4, 1.4, 0.6)));
var_dump($r->isComplete(new AxisAlignedBB(0, 0, 0, 1, 1, 1)), $r->isComplete(new AxisAlignedBB(0, 0, 0, 1, 5, 1)));
t(fn() => $r->getCollisionBoxes(new AxisAlignedBB(0, 0, 0, 1, 5, 1)));

// validation
t(fn() => $r->setCell(9, 0, 0, CollisionRegion::INFO_NONE));
t(fn() => $r->setCell(0, 0, 0, 7));
t(fn() => $r->setCell(0, 0, 0, CollisionRegion::INFO_CUBE, [AxisAlignedBB::one()]));
t(fn() => $r->setCell(0, 0, 0, CollisionRegion::INFO_CUSTOM, [new stdClass]));
t(fn() => $r->setCell(0, 0, 0, CollisionRegion::INFO_CUSTOM, array_fill(0, 65, AxisAlignedBB::one())));
t(fn() => $r->setCell(0, 0, 0, CollisionRegion::INFO_CUSTOM, [new AxisAlignedBB(NAN, 0, 0, 1, 1, 1)]));
t(fn() => $r->setCellPacked(0, 0, 0, CollisionRegion::INFO_CUSTOM, "abc"));
t(fn() => $r->setCellPacked(0, 0, 0, CollisionRegion::INFO_CUSTOM, pack("e*", 1, 0, 0, 0, 1, 1)));
t(fn() => $r->getCollisionBoxes(new AxisAlignedBB(0, 0, 0, INF, 1, 1)));
t(fn() => $r->fill(CollisionRegion::INFO_CUSTOM));
t(fn() => new CollisionRegion(0, 0, 0, 4096, 4096, 4096));
t(fn() => new CollisionRegion(1, 0, 0, 0, 0, 0));
t(fn() => (new ReflectionClass(CollisionRegion::class))->newInstanceWithoutConstructor()->getVersion());

// invalidation forgets the block and its neighbours
$r->invalidateBlock(0, 1, 0);
var_dump($r->isKnown(0, 1, 0), $r->isKnown(0, 0, 0), $r->isKnown(1, 1, 0), $r->isKnown(1, 0, 0));
t(fn() => $r->getCollisionBoxes(new AxisAlignedBB(0.2, 0.2, 0.2, 0.8, 0.8, 0.8)));
$r->invalidateChunk(-1, -1);
var_dump($r->isKnown(-1, 2, -1), $r->isKnown(0, 2, 0), $r->isKnown(1, 2, 1));
$r->invalidateAll();
var_dump($r->isKnown(3, 3, 3));

// snapshots are frozen copies, clones are independent
$r->fill(CollisionRegion::INFO_CUBE);
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
array(6) {
  [0]=>
  int(-3)
  [1]=>
  int(-1)
  [2]=>
  int(-3)
  [3]=>
  int(3)
  [4]=>
  int(3)
  [5]=>
  int(3)
}
int(0)
bool(true)
bool(false)
bool(false)
int(-1)
qmath\CollisionDataException: The query needs a cell with no collision data
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
qmath\CollisionDataException: The query needs cells outside the region
ValueError: Cell 9 0 0 is outside the region
ValueError: Invalid collision info 7
ValueError: Invalid collision info, or boxes given for INFO_CUBE or INFO_NONE
TypeError: qmath\CollisionRegion::setCell(): Argument #5 ($boxes) must contain only pocketmine\math\AxisAlignedBB, stdClass found
ValueError: Too many collision boxes for one cell
ValueError: Bounding boxes must be finite with min <= max
ValueError: Packed boxes must be a multiple of 48 bytes
ValueError: Bounding boxes must be finite with min <= max
ValueError: Bounding boxes must be finite with min <= max
ValueError: Invalid collision info, or boxes given for INFO_CUBE or INFO_NONE
ValueError: Region bounds are inverted or exceed CollisionRegion::MAX_CELLS
ValueError: Region bounds are inverted or exceed CollisionRegion::MAX_CELLS
ReflectionException: Class qmath\CollisionRegion is an internal class marked as final that cannot be instantiated without invoking its constructor
bool(false)
bool(false)
bool(false)
bool(true)
qmath\CollisionDataException: The query needs a cell with no collision data
bool(false)
bool(false)
bool(true)
bool(false)
bool(true)
bool(false)
LogicException: Cannot modify a frozen collision region
int(2)
int(1)
int(1)
LogicException: Cannot modify a frozen collision region
Exception: Serialization of 'qmath\CollisionRegion' is not allowed
