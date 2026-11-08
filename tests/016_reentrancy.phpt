--TEST--
PHP code running inside native calls cannot invalidate their state
--SKIPIF--
<?php if (!extension_loaded('qmath')) die('skip qmath not loaded'); ?>
--FILE--
<?php
declare(strict_types=1);
use pocketmine\math\AxisAlignedBB;
use pocketmine\math\Matrix;
use pocketmine\math\RayTraceResult;
use pocketmine\math\Vector2;
use pocketmine\math\Vector3;

function t(callable $f) { try { var_dump($f()); } catch (Throwable $e) { echo get_class($e), ": ", $e->getMessage(), "\n"; } }

// PHP code run from inside Matrix::__toString() replaces the row being printed
class Evil { public function __toString() : string { global $m; $m[0] = [1]; $m->set([[7, 8]]); return "evil"; } }
$m = new Matrix(1, 2);
$m[0] = [new Evil, 2];
echo $m, "\n", $m, "\n";

// warnings raised while reading an incomplete matrix may run a handler that rewrites it
$h = new Matrix(2, 2);
unset($h[1]);
set_error_handler(function () use ($h) { $h->set([[5, 5], [5, 5]]); return true; });
t(fn() => (string) $h->transpose());
t(fn() => $h->determinant());
restore_error_handler();

class SubMatrix extends Matrix {}
$s = new SubMatrix(2, 2, [[1, 2], [3, 4]]);
var_dump($s->getRows(), $s->determinant(), (string) $s);

// a negative column count set by reflection is not fatal
$r = new ReflectionProperty(Matrix::class, 'columns');
$n = new Matrix(1, 1);
$r->setValue($n, -1);
t(fn() => $n->set([[1]]));

// Spatial keeps objects alive while a hook drops the last outside reference
class Ghost {
    public AxisAlignedBB $boundingBox { get { global $ghost; $ghost = null; return AxisAlignedBB::one(); } }
}
$ghost = new Ghost;
$list = [&$ghost];
var_dump(count(qmath\Spatial::overlapping($list, AxisAlignedBB::one()->expand(1, 1, 1))));

// oversized noise grids are rejected before any arithmetic
$noise = new qmath\Simplex(range(0, 255), 0.0, 0.0, 0.0, 1, 0.5, 1.0);
t(fn() => $noise->getFastNoise2D(PHP_INT_MAX, 0, 1, 0, 0, 0));
t(fn() => $noise->getFastNoise3D(PHP_INT_MAX, 0, 0, 1, 1, 1, 0, 0, 0));
t(fn() => $noise->getFastNoise1D(PHP_INT_MAX, 1, 0, 0, 0));

// string keys returned by sweepBoxes are owned correctly
for ($i = 0; $i < 3; ++$i) {
    $boxes = [str_repeat("far", 3) . $i => new AxisAlignedBB(-1, 0, 50, 1, 2, 50.1), str_repeat("near", 3) . $i => new AxisAlignedBB(-1, 0, 20, 1, 2, 20.1)];
    echo qmath\Collision::sweepBoxes(new AxisAlignedBB(-0.3, 0, -0.3, 0.3, 1.8, 0.3), 0, 0, 100, $boxes)->key, "\n";
}

class HookedV2 extends Vector2 {
    public float $x { get => $this->x * 2; }
}
var_dump((new HookedV2(1.5, 2.0))->length(), (new HookedV2(3.0, 4.0))->getX());
class HookedHit extends RayTraceResult {
    public int $hitFace { get => $this->hitFace + 100; }
}
var_dump((new HookedHit(AxisAlignedBB::one(), 2, new Vector3(0, 0, 0)))->getHitFace());

// __get returning by reference does not leak from the getters
class LazyHit extends RayTraceResult {
    private array $store = [];
    public function __construct() { unset($this->hitFace); $this->store['f'] = 4; }
    public function &__get($name) { return $this->store['f']; }
}
var_dump((new LazyHit)->getHitFace());
--EXPECT--
Matrix(1x2;evil,2)
Matrix(1x2;7,8)
TypeError: pocketmine\math\Matrix::setElement(): Argument #3 ($value) must be of type float, null given
float(0)
int(2)
float(-2)
string(19) "Matrix(2x2;1,2;3,4)"
NULL
int(1)
ValueError: Sample grid is too large
ValueError: Sample grid is too large
ValueError: Sample grid is too large
nearnearnear0
nearnearnear1
nearnearnear2
float(3.605551275463989)
float(6)
int(102)
int(4)
