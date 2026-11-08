--TEST--
Repeated native operations do not leak
--SKIPIF--
<?php if (!extension_loaded('qmath')) die('skip qmath not loaded'); ?>
--FILE--
<?php
declare(strict_types=1);
use pocketmine\math\AxisAlignedBB;
use pocketmine\math\Vector3;
use pocketmine\math\VoxelRayTrace;
use qmath\Collision;
use qmath\CollisionRegion as R;

function cycle() : void {
    $r = new R();
    $r->fillBox(-4, -2, -4, 4, 6, 4, R::INFO_NONE);
    for ($x = -4; $x <= 4; ++$x) for ($z = -4; $z <= 4; ++$z) $r->setCell($x, 0, $z, R::INFO_CUSTOM, [new AxisAlignedBB($x, 0, $z, $x + 1, 0.5, $z + 1)]);
    $s = $r->snapshot();
    $bb = new AxisAlignedBB(0.2, 1, 0.2, 0.8, 2.8, 0.8);
    for ($i = 0; $i < 20; ++$i) {
        $bb = Collision::move($s, $bb, 0.1, -0.3, 0.05, 0.6, true)->boundingBox;
        $r->getCollisionBoxes($bb);
        qmath\Raycast::blocks($r, new Vector3(0.5, 3, 0.5), new Vector3(3.5, -1, 2.5));
    }
    foreach (VoxelRayTrace::betweenPoints(new Vector3(0, 0, 0), new Vector3(10, 3, 7)) as $v) { $v->add(1, 1, 1); }
    $it = VoxelRayTrace::betweenPoints(new Vector3(0, 0, 0), new Vector3(10, 3, 7));
    $it->current();
    $g = new qmath\ResistanceGrid(-8, -8, -8, 8, 8, 8);
    $g->fill(0.5);
    qmath\ExplosionMath::traceRays($g, new Vector3(0.5, 0.5, 0.5), 2.0);
    $n = new qmath\Simplex(range(0, 255), 1.0, 2.0, 3.0, 2, 0.5, 0.25);
    $n->getFastNoise3D(16, 32, 16, 4, 8, 4, 0, 0, 0);
    try { $r->setCell(1 << 40, 0, 0, R::INFO_NONE); } catch (ValueError) {}
    $r->setSection(5, 0, 5, str_repeat("\x00", 4096), [7 => [AxisAlignedBB::one()->offset(80, 7, 80)]]);
    $r->invalidateChunk(5, 5);
    $r->missingSections($bb);
    try { Collision::move($r, $bb, 0, -50, 0); } catch (qmath\CollisionDataException) {}
    (new Vector3(1, 2, 3))->sides();
    (string) new pocketmine\math\Matrix(2, 2, [[1, 2], [3, 4]]);
}

cycle();
$before = memory_get_usage();
for ($i = 0; $i < 300; ++$i) cycle();
$growth = memory_get_usage() - $before;
var_dump($growth < 64 * 1024);
--EXPECT--
bool(true)
