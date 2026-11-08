--TEST--
ResistanceGrid: sections from chunk palettes match per-cell filling
--SKIPIF--
<?php if (!extension_loaded('qmath')) die('skip qmath not loaded'); ?>
--FILE--
<?php
declare(strict_types=1);
use quark\math\Vector3;
use quark\math\physics\ExplosionMath;
use quark\math\physics\ResistanceGrid;

function t(callable $f) { try { var_dump($f()); } catch (Throwable $e) { echo get_class($e), ": ", $e->getMessage(), "\n"; } }

// 2 bits per block: entry 0 air, 1 obsidian, 2 unloaded
$words = '';
mt_srand(3);
$cells = [];
for ($w = 0; $w < 256; ++$w) {
    $word = 0;
    for ($j = 0; $j < 16; ++$j) {
        $v = mt_rand(0, 9) === 0 ? 1 : (mt_rand(0, 30) === 0 ? 2 : 0);
        $cells[$w * 16 + $j] = $v;
        $word |= $v << ($j * 2);
    }
    $words .= pack("V", $word);
}
$res = [0.0, 1200.0, NAN];

$a = new ResistanceGrid(-12, -12, -12, 12, 12, 12);
$b = new ResistanceGrid(-12, -12, -12, 12, 12, 12);
for ($sx = -1; $sx <= 0; ++$sx) for ($sy = -1; $sy <= 0; ++$sy) for ($sz = -1; $sz <= 0; ++$sz) {
    $a->setSectionPalette($sx, $sy, $sz, 2, $words, pack("e*", ...$res));
}
for ($x = -12; $x <= 12; ++$x) for ($y = -12; $y <= 12; ++$y) for ($z = -12; $z <= 12; ++$z) {
    $v = $res[$cells[(($x & 15) << 8) | (($z & 15) << 4) | ($y & 15)]];
    is_nan($v) ? $b->setInvalid($x, $y, $z) : $b->set($x, $y, $z, $v);
}
mt_srand(9);
$ra = ExplosionMath::traceRays($a, new Vector3(0.5, 0.5, 0.5), 4.0);
$na = mt_rand();
mt_srand(9);
$rb = ExplosionMath::traceRays($b, new Vector3(0.5, 0.5, 0.5), 4.0);
var_dump($ra === $rb, $na === mt_rand(), count($ra) > 0);

// sections outside the grid are ignored, single-entry palettes need no words
$a->setSectionPalette(5, 5, 5, 0, "", pack("e", 1.0));
$c = new ResistanceGrid(0, 0, 0, 3, 3, 3);
$c->setSectionPalette(0, 0, 0, 0, "", pack("e", NAN));
t(fn() => ExplosionMath::traceRays($c, new Vector3(1.5, 1.5, 1.5), 0.5));

t(fn() => $a->setSectionPalette(0, 0, 0, 2, $words, ""));
t(fn() => $a->setSectionPalette(0, 0, 0, 2, $words, "abc"));
t(fn() => $a->setSectionPalette(0, 0, 0, 2, $words, pack("e", 1.0)));
t(fn() => $a->setSectionPalette(0, 0, 0, 5, $words, pack("e*", ...$res)));
t(fn() => $a->setSectionPalette(PHP_INT_MAX, 0, 0, 0, "", pack("e", 1.0)));
?>
--EXPECT--
bool(true)
bool(true)
bool(true)
array(0) {
}
ValueError: resistances must hold between 1 and 4096 doubles
ValueError: resistances must hold between 1 and 4096 doubles
ValueError: Word array does not match 2 bits per block and the palette
ValueError: Word array does not match 5 bits per block and the palette
ValueError: Section 9223372036854775807 0 0 is out of range
