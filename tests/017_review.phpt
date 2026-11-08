--TEST--
Range checks, compaction, destructor writes and weak mode coercion
--SKIPIF--
<?php if (!extension_loaded('qmath')) die('skip qmath not loaded'); ?>
--FILE--
<?php
use quark\math\AxisAlignedBB as BB;
use quark\math\Vector3;
use quark\math\VoxelRayTrace;
use quark\math\collision\CollisionRegion as R;
use quark\math\collision\Raycast;

function t(callable $f) { try { var_dump($f()); } catch (Throwable $e) { echo get_class($e), ": ", $e->getMessage(), "\n"; } }
function boxes(R $r, int $x) { return implode(" ", array_map(fn($b) => "$b->minY-$b->maxY", $r->getCellBoxes($x, 0, 0))); }

// boxes written out of cell order survive compaction and snapshots
$r = new R();
$r->fillBox(0, 0, 0, 15, 15, 15, R::INFO_NONE);
$r->setCell(2, 0, 0, R::INFO_CUSTOM, [new BB(2, 0, 0, 3, 0.5, 1), new BB(2, 0.5, 0, 2.5, 1, 0.5)]);
$r->setCell(1, 0, 0, R::INFO_CUSTOM, [new BB(1, 0, 0, 2, 0.25, 1)]);
$r->setCell(3, 0, 0, R::INFO_CUSTOM, [new BB(3, 0, 0, 4, 0.75, 1)]);
$r->setCell(3, 0, 0, R::INFO_CUSTOM, []);
$s = $r->snapshot();
echo boxes($s, 1), " | ", boxes($s, 2), " | ", count($s->getCellBoxes(3, 0, 0)), "\n";
for ($i = 0; $i < 300; ++$i) $r->setCell($i % 16, 1, 0, R::INFO_CUSTOM, [new BB($i % 16, 1, 0, $i % 16 + 1, 1 + ($i % 7 + 1) / 8, 1)]);
echo boxes($r, 1), " | ", boxes($r, 2), " | ", $r->getCellBoxes(15, 1, 0)[0]->maxY, "\n";

// coordinates that cannot be represented are rejected instead of wrapping
t(fn() => $r->getCollisionBoxes(new BB(1000, 0, 0, 2 ** 64, 1, 1)));
t(fn() => $r->missingSections(new BB(-2 ** 64, 0, 0, 1, 1, 1)));
t(fn() => $r->fillBox(PHP_INT_MIN, PHP_INT_MIN, 0, PHP_INT_MAX, PHP_INT_MAX, 0, R::INFO_NONE));
$r->invalidateSection(0, 0, 1 << 22);
$r->invalidateSection(0, -1000000, 0);
var_dump($r->isKnown(0, 0, 0));

// a fill that runs out of sections still changes the version
$small = new R(1);
$small->fillBox(0, 0, 0, 15, 15, 15, R::INFO_NONE);
$v = $small->getVersion();
t(fn() => $small->fillBox(0, 0, 0, 31, 15, 15, R::INFO_CUBE));
var_dump($small->getVersion() !== $v, $small->getCellInfo(0, 0, 0));

t(fn() => $s->__construct());
var_dump($s->isFrozen());

// rays of infinite length fail instead of spinning
t(fn() => Raycast::blocks($r, new Vector3(0.5, 0.5, 0.5), new Vector3(INF, 0.5, 0.5)));
t(fn() => Raycast::lineOfSight($r, new Vector3(-INF, 0.5, 0.5), new Vector3(0.5, 0.5, 0.5)));
t(fn() => strlen(Raycast::batchBlocks($r, pack('e*', 0.5, 0.5, 0.5, NAN, 0.5, 0.5))));

// a zero length ray throws once and then behaves like a finished generator
$it = VoxelRayTrace::betweenPoints(new Vector3(1, 1, 1), new Vector3(1, 1, 1));
for ($pass = 0; $pass < 2; ++$pass) {
    try { $n = 0; foreach ($it as $_) ++$n; echo "pass $pass: $n\n"; } catch (Throwable $e) { echo "pass $pass: ", get_class($e), "\n"; }
}

// int|float parameters coerce like the PHP methods in weak mode
var_dump(new Vector3("1", "2.5", true), (new Vector3(1, 2, 3))->add("1", 2, 3)->x, (new Vector3(1, 2, 3))->withComponents("4", null, null)->x);
t(fn() => new Vector3(null, 1, 1));
t(fn() => (new Vector3(1, 2, 3))->subtract("a", 1, 1));

// long float strings are not truncated
ini_set('precision', '100');
var_dump(strlen((string) new Vector3(1.2345678901234567e-200, 0, 0)), strlen((string) new BB(1.2345678901234567e-200, 0, 0, 1, 1, 1)));
ini_set('precision', '14');

// grid bounds near PHP_INT_MAX and oversized explosions
var_dump((new quark\math\physics\ResistanceGrid(PHP_INT_MAX, 0, 0, PHP_INT_MAX, 0, 0))->getBounds()[3]);
$g = new quark\math\physics\ResistanceGrid(-1, -1, -1, 1, 1, 1);
$g->fill(0);
t(fn() => quark\math\physics\ExplosionMath::traceRays($g, new Vector3(0, 0, 0), 46, 64, 8e-5));
$noise = new quark\math\noise\Simplex(range(0, 255), 0.0, 0.0, 0.0, 1, 0.5, 1.0);
t(fn() => count($noise->getFastNoise1D(1 << 21, 1, 0, 0, 0)));
--EXPECT--
0-0.25 | 0-0.5 0.5-1 | 0
0-0.25 | 0-0.5 0.5-1 | 1.125
ValueError: Coordinates are outside the supported world range
ValueError: Coordinates are outside the supported world range
ValueError: Coordinates are outside the supported world range
bool(true)
quark\math\collision\CollisionDataException: The region holds its maximum number of sections
bool(true)
int(1)
Error: CollisionRegion is already constructed
bool(true)
ValueError: Coordinates are outside the supported world range
ValueError: Coordinates are outside the supported world range
InvalidArgumentException: Start and end points are the same, giving a zero direction vector
pass 0: InvalidArgumentException
pass 1: 0
object(quark\math\Vector3)#4 (3) {
  ["x"]=>
  int(1)
  ["y"]=>
  float(2.5)
  ["z"]=>
  int(1)
}
int(2)
int(4)
TypeError: quark\math\Vector3::__construct(): Argument #1 ($x) must be of type int|float, null given
TypeError: quark\math\Vector3::subtract(): Argument #1 ($x) must be of type int|float, string given
int(125)
int(136)
int(9223372036854775807)
ValueError: Invalid explosion parameters: radius and stepLen must be positive and finite, rays between 2 and 64, and the rays at most 1e8 steps long in total
ValueError: Sample grid is too large
