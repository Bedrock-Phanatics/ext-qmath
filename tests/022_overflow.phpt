--TEST--
Overflowing shapes, complete sections, exact integers and rejected non-finite input
--SKIPIF--
<?php if (!extension_loaded('qmath')) die('skip qmath not loaded'); ?>
--FILE--
<?php
use quark\math\AxisAlignedBB as BB;
use quark\math\Vector3;
use quark\math\VoxelRayTrace;
use quark\math\collision\CollisionRegion as R;
use quark\math\collision\CollisionSolver;
use quark\math\collision\Raycast;
use quark\math\noise\Simplex;
use quark\math\physics\ExplosionMath;
use quark\math\physics\Physics;
use quark\math\physics\ResistanceGrid;

function t(callable $f) { try { var_dump($f()); } catch (Throwable $e) { echo get_class($e), ": ", $e->getMessage(), "\n"; } }
function hit(?quark\math\collision\VoxelHit $h) { echo $h === null ? "miss" : "$h->blockX $h->blockY $h->blockZ face $h->hitFace at $h->hitVector", "\n"; }

$r = new R();
$r->fillBox(-16, -16, -16, 31, 31, 31, R::INFO_NONE);
$r->fillBox(-16, 0, -16, 31, 0, 31, R::INFO_CUBE);
$fence = new BB(5.375, 1, 1.375, 5.625, 2.5, 1.625);
$r->setCell(5, 1, 1, R::INFO_MAY_OVERFLOW, [$fence]);

echo "-- rays meet the half of a fence that stands in the cell above\n";
hit(Raycast::blocks($r, new Vector3(0.5, 2.25, 1.5), new Vector3(10.5, 2.25, 1.5)));
hit(Raycast::blocks($r, new Vector3(0.5, 2.75, 1.5), new Vector3(10.5, 2.75, 1.5)));
hit(Raycast::blocks($r, new Vector3(5.5, 4.5, 1.5), new Vector3(5.5, 1.5, 1.5)));
var_dump(Raycast::lineOfSight($r, new Vector3(0.5, 2.25, 1.5), new Vector3(10.5, 2.25, 1.5)));
var_dump(unpack("qface/q3block/e3hit", Raycast::batchBlocks($r, pack("e6", 10.5, 2.25, 1.5, 0.5, 2.25, 1.5)))["block2"]);
var_dump(ExplosionMath::exposure($r, new Vector3(5.5, 2.25, 0.5), new BB(5.4, 2.1, 2.2, 5.6, 2.4, 2.4)));

echo "-- the nearest box wins over one reaching in from an earlier voxel\n";
$r->setCell(5, 2, 1, R::INFO_CUSTOM, [new BB(5.65, 2, 1, 5.9, 2.02, 2)]);
hit(Raycast::blocks($r, new Vector3(5.9, 1.9, 1.5), new Vector3(5.1, 2.3, 1.5)));
$r->setCell(5, 2, 1, R::INFO_NONE);
hit(Raycast::blocks($r, new Vector3(5.9, 1.9, 1.5), new Vector3(5.1, 2.3, 1.5)));

echo "-- rays starting inside or flush against a box\n";
hit(Raycast::blocks($r, new Vector3(5.5, 2.2, 1.5), new Vector3(9.5, 2.2, 1.5)));
hit(Raycast::blocks($r, new Vector3(5.625, 2.2, 1.5), new Vector3(9.5, 2.2, 1.5)));
hit(Raycast::blocks($r, new Vector3(5.7, 2.2, 1.5), new Vector3(9.5, 2.2, 1.5)));

echo "-- overflow is read off the boxes, diagonals and section borders included\n";
$r->setCell(15, 15, 15, R::INFO_CUSTOM, [new BB(15.5, 15.5, 15.5, 16.5, 16.5, 16.5)]);
$r->setCell(3, 1, 3, R::INFO_MAY_OVERFLOW, [new BB(3.25, 1, 3.25, 3.75, 2, 3.75)]);
var_dump($r->getCellInfo(15, 15, 15) === R::INFO_MAY_OVERFLOW, $r->getCellInfo(3, 1, 3) === R::INFO_CUSTOM);
hit(Raycast::blocks($r, new Vector3(16.2, 16.2, 17.5), new Vector3(16.2, 16.2, 16.1)));
echo count($r->getCollisionBoxes(new BB(16.1, 16.1, 16.1, 16.4, 16.4, 16.4))), " ", count($r->getCollisionBoxes(new BB(15.1, 15.1, 15.1, 16.9, 16.9, 16.9))), "\n";
$m = CollisionSolver::move($r, new BB(16.1, 16.6, 16.1, 16.4, 17, 16.4), 0.0, -1.0, 0.0);
var_dump($m->boundingBox->minY, $m->onGround);
var_dump(CollisionSolver::sweep($r, new BB(16.1, 17, 16.1, 16.4, 17.5, 16.4), 0.0, -2.0, 0.0)?->time);

echo "-- boxes are cut to the cells around their own\n";
$r->setCell(8, 1, 8, R::INFO_CUSTOM, [new BB(8, 1, 8, 9, 9, 9), new BB(20, 1, 8, 21, 2, 9)]);
echo implode(" | ", $r->getCellBoxes(8, 1, 8)), "\n";

echo "-- sections need boxes for every shaped cell\n";
$infos = substr_replace(str_repeat(chr(R::INFO_NONE), 4096), chr(R::INFO_CUSTOM) . chr(R::INFO_MAY_OVERFLOW), 5, 2);
t(fn() => $r->setSection(3, 3, 3, $infos));
t(fn() => $r->setSection(3, 3, 3, $infos, [5 => [new BB(48, 53, 48, 49, 53.5, 49)]]));
var_dump($r->getCellInfo(48, 53, 48));
$r->setSection(3, 3, 3, $infos, [5 => [new BB(48, 53, 48, 49, 53.5, 49)], 6 => []]);
var_dump($r->getCellInfo(48, 53, 48), $r->getCellInfo(48, 54, 48), count($r->getCellBoxes(48, 54, 48)));

echo "-- grids at the ends of the integer range\n";
$g = new ResistanceGrid(PHP_INT_MAX - 2, PHP_INT_MAX - 2, PHP_INT_MAX - 2, PHP_INT_MAX, PHP_INT_MAX, PHP_INT_MAX);
$g->setSectionPalette(PHP_INT_MAX >> 4, PHP_INT_MAX >> 4, PHP_INT_MAX >> 4, 0, "", pack("e", 1.5));
$g->setSectionPalette(PHP_INT_MIN >> 4, 0, 0, 0, "", pack("e", 1.5));
echo implode(",", $g->getBounds()) === implode(",", [PHP_INT_MAX - 2, PHP_INT_MAX - 2, PHP_INT_MAX - 2, PHP_INT_MAX, PHP_INT_MAX, PHP_INT_MAX]) ? "ok\n" : "bad\n";
$g = new ResistanceGrid(PHP_INT_MIN, PHP_INT_MIN, PHP_INT_MIN, PHP_INT_MIN + 17, PHP_INT_MIN + 1, PHP_INT_MIN + 1);
$g->setSectionPalette(PHP_INT_MIN >> 4, PHP_INT_MIN >> 4, PHP_INT_MIN >> 4, 0, "", pack("e", 1.5));
t(fn() => $g->setSectionPalette(PHP_INT_MAX, 0, 0, 0, "", pack("e", 1.5)));
t(fn() => new ResistanceGrid(PHP_INT_MIN, 0, 0, PHP_INT_MAX, 0, 0));
t(fn() => ExplosionMath::traceRays($g, new Vector3(NAN, 0, 0), 4.0));

echo "-- integers stay exact\n";
$big = new Vector3(PHP_INT_MAX, PHP_INT_MIN, 2 ** 53 + 1);
var_dump($big->floor()->equals($big), $big->ceil()->equals($big), $big->round()->equals($big));
var_dump($big->getFloorX() === PHP_INT_MAX, $big->getFloorY() === PHP_INT_MIN, $big->getFloorZ() === 2 ** 53 + 1);
var_dump(VoxelRayTrace::betweenPoints(new Vector3(2 ** 60 + 1, 0, 0), new Vector3(2 ** 60 + 1, 2, 0))->current()->x === 2 ** 60 + 1);

echo "-- rays that could never end\n";
foreach ([[NAN, 0, 0], [INF, 0, 0], [0, -INF, 0], [1e200, 0, 0]] as $end) {
    t(fn() => iterator_count(VoxelRayTrace::betweenPoints(new Vector3(0, 0, 0), new Vector3(...$end))));
}
t(fn() => iterator_count(VoxelRayTrace::inDirection(new Vector3(0, 0, 0), new Vector3(1, 0, 0), INF)));
t(fn() => Raycast::voxels(new Vector3(0, 0, 0), new Vector3(NAN, 0, 0)));
t(fn() => Raycast::voxels(new Vector3(0, 0, 0), new Vector3(1, 0, 0), 1 << 23));
$it = VoxelRayTrace::betweenPoints(new Vector3(0.5, 0.5, 0.5), new Vector3(5e6, 0.5, 0.5));
t(function() use ($it) { $n = 0; foreach ($it as $_) ++$n; return $n; });
var_dump($it->valid());

echo "-- physics rejects values that are not finite\n";
t(fn() => Physics::motionStep(new Vector3(NAN, 0, 0), 0.02, 0.08));
t(fn() => Physics::motionStep(new Vector3(0, 0, 0), INF, 0.08));
t(fn() => Physics::motionStep(new Vector3(0, 0, 0), 0.02, NAN));
t(fn() => Physics::motionStep(new Vector3(0, 0, 0), 0.02, 0.08, true, false, INF));
t(fn() => Physics::motionStep(new Vector3(0, 0, 0), 0.02, 0.08, true, false, 1.0, NAN));
t(fn() => Physics::motionStep(new Vector3(1e308, 0, 0), -9.0, 0.08));
t(fn() => (string) Physics::motionStep(new Vector3(0.5, 0.2, 0), 0.02, 0.08, true, false, 1.0, -1.0));
t(fn() => Physics::knockBack(new Vector3(0, 0, 0), INF, 0.0));
t(fn() => Physics::knockBack(new Vector3(0, 0, 0), 1.0, 0.0, NAN));
t(fn() => Physics::knockBack(new Vector3(0, INF, 0), 1.0, 0.0));
t(fn() => Physics::knockBack(new Vector3(0, 0, 0), 1e200, 1e200));
t(fn() => Physics::knockBack(new Vector3(0, 0, 0), 0.0, 0.0));
t(fn() => Physics::predictTrajectory(new Vector3(0, 0, 0), new Vector3(0, NAN, 0), 0.02, 0.08, 5));
t(fn() => Physics::predictTrajectory(new Vector3(0, 0, 0), new Vector3(1e300, 0, 0), -1e3, 0.08, 100));
t(fn() => strlen(Physics::predictTrajectory(new Vector3(0, 0, 0), new Vector3(1, 1, 1), 0.02, 0.08, 5)));

echo "-- named arguments cannot vanish into a variadic\n";
t(fn() => Vector3::sum(a: new Vector3(1, 2, 3)));
t(fn() => Vector3::maxComponents(new Vector3(1, 2, 3), b: new Vector3(4, 5, 6)));
t(fn() => quark\color\Color::mix(new quark\color\Color(1, 2, 3), b: new quark\color\Color(4, 5, 6)));

echo "-- normalized noise with no amplitude\n";
$flat = new Simplex(range(0, 255), 0.0, 0.0, 0.0, 2, -1.0, 1.0);
t(fn() => $flat->noise2D(1.5, 2.5, true));
t(fn() => $flat->noise3D(1.5, 2.5, 3.5, true));
t(fn() => $flat->getFastNoise3DPacked(4, 4, 4, 4, 4, 4, 0, 0, 0));
t(fn() => is_finite($flat->noise3D(1.5, 2.5, 3.5)));

echo "-- chunks drop whole, failed fills change nothing\n";
$c = new R(512);
$c->fillBox(0, -64, 0, 47, 319, 47, R::INFO_NONE);
$n = $c->getSectionCount();
$c->invalidateChunk(1, 2);
var_dump($n - $c->getSectionCount(), $c->isKnown(16, 0, 32), $c->isKnown(15, 0, 32));
$c->invalidateChunk(PHP_INT_MAX >> 40, 0);
$small = new R(2);
$small->fillBox(0, 0, 0, 31, 15, 15, R::INFO_NONE);
$v = $small->getVersion();
t(fn() => $small->fillBox(0, 0, 0, 40, 15, 15, R::INFO_CUBE));
var_dump($small->getVersion() === $v, $small->getCellInfo(0, 0, 0), $small->getCellInfo(20, 0, 0));
?>
--EXPECT--
-- rays meet the half of a fence that stands in the cell above
5 1 1 face 4 at Vector3(x=5.375,y=2.25,z=1.5)
miss
5 1 1 face 1 at Vector3(x=5.5,y=2.5,z=1.5)
bool(false)
int(1)
float(0)
-- the nearest box wins over one reaching in from an earlier voxel
5 2 1 face 0 at Vector3(x=5.7,y=2,z=1.5)
5 1 1 face 5 at Vector3(x=5.625,y=2.0375,z=1.5)
-- rays starting inside or flush against a box
5 1 1 face 5 at Vector3(x=5.625,y=2.2,z=1.5)
5 1 1 face 5 at Vector3(x=5.625,y=2.2,z=1.5)
miss
-- overflow is read off the boxes, diagonals and section borders included
bool(true)
bool(true)
15 15 15 face 3 at Vector3(x=16.2,y=16.2,z=16.5)
1 1
float(16.5)
bool(true)
float(0.25)
-- boxes are cut to the cells around their own
AxisAlignedBB(8, 1, 8, 9, 3, 9)
-- sections need boxes for every shaped cell
ValueError: Every INFO_CUSTOM or INFO_MAY_OVERFLOW cell needs a box list, an empty one for a shape without boxes
ValueError: Every INFO_CUSTOM or INFO_MAY_OVERFLOW cell needs a box list, an empty one for a shape without boxes
int(-1)
int(0)
int(0)
int(0)
-- grids at the ends of the integer range
ok
ValueError: Section 9223372036854775807 0 0 is out of range
ValueError: Grid bounds are inverted or exceed CollisionRegion::MAX_CELLS
ValueError: The explosion source must be finite
-- integers stay exact
bool(true)
bool(true)
bool(true)
bool(true)
bool(true)
bool(true)
bool(true)
-- rays that could never end
InvalidArgumentException: Start and end points must be finite and less than 1e154 apart
InvalidArgumentException: Start and end points must be finite and less than 1e154 apart
InvalidArgumentException: Start and end points must be finite and less than 1e154 apart
InvalidArgumentException: Start and end points must be finite and less than 1e154 apart
InvalidArgumentException: Start and end points must be finite and less than 1e154 apart
ValueError: Start and end points must be finite and less than 1e154 apart
ValueError: limit must be between 1 and 4194304
ValueError: The ray visits more than 4194304 voxels
bool(false)
-- physics rejects values that are not finite
ValueError: motion must be finite
ValueError: drag must be finite
ValueError: gravity must be finite
ValueError: groundFriction must be finite
ValueError: threshold must not be NAN
ValueError: The resulting motion must be finite
string(28) "Vector3(x=0.49,y=0.1176,z=0)"
ValueError: x must be finite
ValueError: force must be finite
ValueError: motion must be finite
ValueError: x and z are too large to give a direction
NULL
ValueError: motion must be finite
ValueError: The trajectory leaves the finite range at tick 2
int(120)
-- named arguments cannot vanish into a variadic
ArgumentCountError: quark\math\Vector3::sum() does not accept unknown named parameters
ArgumentCountError: quark\math\Vector3::maxComponents() does not accept unknown named parameters
ArgumentCountError: quark\color\Color::mix() does not accept unknown named parameters
-- normalized noise with no amplitude
DivisionByZeroError: Division by zero
DivisionByZeroError: Division by zero
DivisionByZeroError: Division by zero
bool(true)
-- chunks drop whole, failed fills change nothing
int(24)
bool(false)
bool(true)
quark\math\collision\CollisionDataException: The region holds its maximum number of sections
bool(true)
int(2)
int(2)
