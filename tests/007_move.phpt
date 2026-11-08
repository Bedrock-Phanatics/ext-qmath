--TEST--
CollisionSolver::move against blocks, slabs, stairs, fences and gaps
--SKIPIF--
<?php if (!extension_loaded('qmath')) die('skip qmath not loaded'); ?>
--FILE--
<?php
declare(strict_types=1);
use quark\math\AxisAlignedBB;
use quark\math\collision\CollisionSolver;
use quark\math\collision\CollisionRegion as R;

function t(callable $f) { try { var_dump($f()); } catch (Throwable $e) { echo get_class($e), ": ", $e->getMessage(), "\n"; } }

/** Flat floor at y = 63 with a few shapes on top */
function world() : R {
    $r = new R();
    $r->fillBox(-20, 40, -20, 20, 72, 20, R::INFO_NONE);
    $r->fillBox(-20, 63, -20, 20, 63, 20, R::INFO_CUBE);
    $r->setCell(2, 64, 0, R::INFO_CUSTOM, [new AxisAlignedBB(2, 64, 0, 3, 64.5, 1)]);                    // slab
    $r->setCell(4, 64, 0, R::INFO_CUSTOM, [new AxisAlignedBB(4, 64, 0, 5, 64.5, 1), new AxisAlignedBB(4, 64.5, 0, 5, 65, 0.5)]); // stairs
    $r->setCell(6, 64, 0, R::INFO_MAY_OVERFLOW, [new AxisAlignedBB(6.375, 64, 0.375, 6.625, 65.5, 0.625)]); // fence post
    $r->setCell(-1, 64, -1, R::INFO_CUBE);                                                             // block across the chunk corner
    $r->setCell(0, 66, 5, R::INFO_CUBE);                                                               // ceiling
    for ($y = 64; $y <= 66; ++$y) { $r->setCell(10, $y, 0, R::INFO_CUBE); $r->setCell(10, $y, 2, R::INFO_CUBE); } // narrow gap at z = 1
    return $r;
}

function player(float $x, float $y, float $z, float $w = 0.6, float $h = 1.8) : AxisAlignedBB {
    return new AxisAlignedBB($x - $w / 2, $y, $z - $w / 2, $x + $w / 2, $y + $h, $z + $w / 2);
}

function show(string $label, quark\math\collision\MoveResult $m) : void {
    printf("%-14s d=(%.4f %.4f %.4f) min=(%.4f %.4f %.4f) h=%d v=%d ground=%d step=%d xyz=%d%d%d\n", $label, $m->dx, $m->dy, $m->dz,
        $m->boundingBox->minX, $m->boundingBox->minY, $m->boundingBox->minZ,
        $m->collidedHorizontally, $m->collidedVertically, $m->onGround, $m->stepped, $m->collidedX, $m->collidedY, $m->collidedZ);
}

$r = world();
show("land", CollisionSolver::move($r, player(0.5, 64.3, 0.5), 0, -0.5, 0));
show("fall fast", CollisionSolver::move($r, player(0.5, 70, 0.5), 0, -15, 0, 0.6, false));
show("slab step", CollisionSolver::move($r, player(1.5, 64, 0.5), 0.6, 0, 0, 0.6, true));
show("slab no step", CollisionSolver::move($r, player(1.5, 64, 0.5), 0.6, 0, 0, 0.0, true));
show("stairs", CollisionSolver::move($r, player(3.5, 64, 0.5), 0.6, 0, 0, 0.6, true));
show("fence", CollisionSolver::move($r, player(5.5, 64, 0.5), 0.6, 0, 0, 0.6, true));
show("corner", CollisionSolver::move($r, player(0.5, 64, 0.5), -1.0, 0, -1.0, 0.6, true));
show("ceiling", CollisionSolver::move($r, player(0.5, 64, 5.5), 0, 0.5, 0));
show("gap fits", CollisionSolver::move($r, player(9.5, 64, 1.5, 0.6, 1.8), 1.5, 0, 0, 0.6, true));
show("gap too thin", CollisionSolver::move($r, player(8.5, 64, 1.5, 1.2, 1.8), 1.5, 0, 0, 0.6, true));
show("negative", CollisionSolver::move($r, player(-15.5, 64.2, -15.5), -0.3, -0.4, -0.3));
show("diagonal", CollisionSolver::move($r, player(0.5, 64, 0.5), 3.0, -0.08, 0.2, 0.6, true));
show("airborne", CollisionSolver::move($r, player(0.5, 66, 0.5), 0.2, 0.3, 0.2));

t(fn() => CollisionSolver::move($r, player(0.5, 64, 0.5), NAN, 0, 0));
t(fn() => CollisionSolver::move($r, player(0.5, 64, 0.5), 0, 0, 0, INF));
t(fn() => CollisionSolver::move($r, player(0.5, 64, 0.5), 0, -100, 0));
t(fn() => CollisionSolver::move(new R(), player(0.5, 0, 0.5), 0, 0, 0));

// prefetch: the query box covers the step retry too, missingSections() lists what to load
$q = CollisionSolver::queryBox(player(0.5, 64, 0.5), 0.4, -0.08, 0.0, 0.6);
echo $q, "
";
var_dump(count(world()->missingSections($q)), count((new R())->missingSections($q)) / 3);
$m = CollisionSolver::move($r, player(0.5, 64, 0.5), 0, 0, 0);
t(fn() => $m->dx = 1.0);

// continuous sweeps catch thin obstacles at any speed
$s = CollisionSolver::sweep($r, player(-10.5, 64, 0.5), 30, 0, 0);
var_dump($s->face, round($s->time, 6), (string) $s->box, $s->key);
var_dump(CollisionSolver::sweep($r, player(0.5, 66, 0.5), 0, 1, 0));
$s = CollisionSolver::sweepBoxes(player(0, 0, 0), 0, 0, 100, ['a' => new AxisAlignedBB(-1, 0, 50, 1, 2, 50.1), 'b' => new AxisAlignedBB(-1, 0, 20, 1, 2, 20.1)]);
var_dump($s->key, $s->face, round($s->time, 6));
var_dump(CollisionSolver::sweepBoxes(player(0, 0, 0), 1, 0, 0, [new AxisAlignedBB(0, 0, 0, 1, 1, 1)])->face);
--EXPECT--
land           d=(0.0000 -0.3000 0.0000) min=(0.2000 64.0000 0.2000) h=0 v=1 ground=1 step=0 xyz=010
fall fast      d=(0.0000 -6.0000 0.0000) min=(0.2000 64.0000 0.2000) h=0 v=1 ground=1 step=0 xyz=010
slab step      d=(0.6000 0.5000 0.0000) min=(1.8000 64.5000 0.2000) h=0 v=1 ground=0 step=1 xyz=010
slab no step   d=(0.2000 0.0000 0.0000) min=(1.4000 64.0000 0.2000) h=1 v=0 ground=0 step=0 xyz=100
stairs         d=(0.2000 0.0000 0.0000) min=(3.4000 64.0000 0.2000) h=1 v=0 ground=0 step=0 xyz=100
fence          d=(0.5750 0.0000 0.0000) min=(5.7750 64.0000 0.2000) h=1 v=0 ground=0 step=0 xyz=100
corner         d=(-1.0000 0.0000 -0.2000) min=(-0.8000 64.0000 0.0000) h=1 v=0 ground=0 step=0 xyz=001
ceiling        d=(0.0000 0.2000 0.0000) min=(0.2000 64.2000 5.2000) h=0 v=1 ground=0 step=0 xyz=010
gap fits       d=(1.5000 0.0000 0.0000) min=(10.7000 64.0000 1.2000) h=0 v=0 ground=0 step=0 xyz=000
gap too thin   d=(0.9000 0.0000 0.0000) min=(8.8000 64.0000 0.9000) h=1 v=0 ground=0 step=0 xyz=100
negative       d=(-0.3000 -0.2000 -0.3000) min=(-16.1000 64.0000 -16.1000) h=0 v=1 ground=1 step=0 xyz=010
diagonal       d=(3.0000 0.0000 0.2000) min=(3.2000 64.0000 0.4000) h=0 v=1 ground=1 step=1 xyz=010
airborne       d=(0.2000 0.3000 0.2000) min=(0.4000 66.3000 0.4000) h=0 v=0 ground=0 step=0 xyz=000
ValueError: dx must be finite
ValueError: stepHeight must be finite
quark\math\collision\CollisionDataException: The query needs a cell with no collision data
quark\math\collision\CollisionDataException: The query needs a cell with no collision data
AxisAlignedBB(0.2, 63.92, 0.2, 1.2, 66.4, 0.8)
int(12)
int(8)
Error: Cannot modify readonly property quark\math\collision\MoveResult::$dx
int(4)
float(0.406667)
string(35) "AxisAlignedBB(2, 64, 0, 3, 64.5, 1)"
int(0)
NULL
string(1) "b"
int(2)
float(0.197)
int(-1)
