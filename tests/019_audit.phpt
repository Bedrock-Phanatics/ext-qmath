--TEST--
Audit fixes: iterator re-entry and GC, bounded exposure work, exact integer equality
--SKIPIF--
<?php if (!extension_loaded('qmath')) die('skip qmath not loaded'); ?>
--FILE--
<?php
use quark\math\AxisAlignedBB;
use quark\math\Vector3;
use quark\math\VoxelRayTrace;
use quark\math\collision\CollisionRegion;
use quark\math\physics\ExplosionMath;

// a destructor re-entering the iterator while its cached vector is released
class D { public $it; public function __destruct() { echo "dtor\n"; $this->it->next(); } }
$it = VoxelRayTrace::betweenPoints(new Vector3(0, 0, 0), new Vector3(5, 0, 0));
$it->rewind();
$v = $it->current();
$d = new D;
$d->it = $it;
@$v->d = $d;
unset($d, $v);
$it->next();
for ($i = 0; $i < 3; $i++) { $x = new stdClass; $y = new Vector3(1, 2, 3); }
echo "key ", $it->key(), "\n";
unset($it);

// cycles through the cached vector are collectable
gc_collect_cycles();
$before = memory_get_usage();
for ($i = 0; $i < 2000; $i++) {
    $it = VoxelRayTrace::betweenPoints(new Vector3(0, 0, 0), new Vector3(5, 0, 0));
    $c = $it->current();
    @$c->it = $it;
    unset($it, $c);
}
var_dump(gc_collect_cycles() >= 2000, memory_get_usage() - $before < 65536);

// exposure work is bounded per call instead of running for minutes
$r = new CollisionRegion();
$r->fillBox(-150, -150, -150, 150, 150, 150, CollisionRegion::INFO_NONE);
$t = hrtime(true);
try { ExplosionMath::exposure($r, new Vector3(-140, -140, -140), new AxisAlignedBB(0, 0, 0, 79, 79, 79)); } catch (ValueError $e) { echo $e->getMessage(), "\n"; }
var_dump((hrtime(true) - $t) / 1e9 < 30);
try { ExplosionMath::exposures($r, new Vector3(-140, -140, -140), array_fill(0, 64, new AxisAlignedBB(0, 0, 0, 20, 20, 20))); } catch (ValueError $e) { echo $e->getMessage(), "\n"; }
var_dump(ExplosionMath::exposure($r, new Vector3(0.5, 0.5, 0.5), new AxisAlignedBB(2, 0, 2, 2.6, 1.8, 2.6)));

// integer components compare exactly, like PHP ==
var_dump((new Vector3(9007199254740993, 0, 0))->equals(new Vector3(9007199254740992, 0, 0)));
var_dump((new Vector3(9007199254740993, 0, 0))->equals(new Vector3(9007199254740992.0, 0, 0)));
var_dump((new Vector3(1, 2, 3))->equals(new Vector3(1.0, 2.0, 3.0)));
--EXPECT--
dtor
key 2
bool(true)
bool(true)
The call visits more than 16777216 voxels
bool(true)
The call visits more than 16777216 voxels
float(1)
bool(false)
bool(true)
bool(true)
