--TEST--
CollisionRegion: sections from chunk palettes and partial refills
--SKIPIF--
<?php if (!extension_loaded('qmath')) die('skip qmath not loaded'); ?>
--FILE--
<?php
declare(strict_types=1);
use quark\math\AxisAlignedBB;
use quark\math\collision\CollisionRegion as R;

function t(callable $f) { try { var_dump($f()); } catch (Throwable $e) { echo get_class($e), ": ", $e->getMessage(), "\n"; } }

$r = new R();
var_dump($r->unknownCells(0, 0, 0));

// 4 bits per block, 8 cells per word. Cell 0 is stone, cell 1 a slab, cell 8 air
$words = str_repeat("\0", 512 * 4);
$words[0] = chr(0x21);
$palette = chr(R::INFO_NONE) . chr(R::INFO_CUBE) . chr(R::INFO_CUSTOM);
var_dump($r->setSectionPalette(0, 0, 0, 4, $words, $palette));
var_dump($r->getCellInfo(0, 0, 0), $r->getCellInfo(0, 1, 0), $r->getCellInfo(0, 8, 0));
var_dump($r->unknownCells(0, 0, 0));
$r->setCell(0, 1, 0, R::INFO_CUSTOM, [new AxisAlignedBB(0, 1, 0, 1, 1.5, 1)]);
var_dump($r->unknownCells(0, 0, 0), count($r->getCellBoxes(0, 1, 0)));

// a block change only drops the block and its neighbours
$r->invalidateBlock(5, 5, 5);
var_dump(count($r->unknownCells(0, 0, 0)));

// single-entry palettes need no words
var_dump($r->setSectionPalette(0, 1, 0, 0, "", chr(R::INFO_CUBE)), $r->unknownCells(0, 1, 0), $r->getCellInfo(3, 20, 3));
var_dump($r->setSectionPalette(0, 2, 0, 0, "", chr(R::INFO_MAY_OVERFLOW)) === range(0, 4095));

t(fn() => $r->setSectionPalette(0, 0, 0, 4, $words, ""));
t(fn() => $r->setSectionPalette(0, 0, 0, 4, $words, chr(9)));
t(fn() => $r->setSectionPalette(0, 0, 0, 4, substr($words, 4), $palette));
t(fn() => $r->setSectionPalette(0, 0, 0, 7, $words, $palette));
t(fn() => $r->setSectionPalette(0, 0, 0, 1, str_repeat("\xff", 128 * 4), chr(R::INFO_NONE)));
t(fn() => $r->setSectionPalette(1 << 30, 0, 0, 0, "", chr(R::INFO_NONE)));
t(fn() => $r->unknownCells(1 << 40, 0, 0));
var_dump($r->getCellInfo(0, 1, 0));

$f = $r->snapshot();
t(fn() => $f->setSectionPalette(0, 0, 0, 0, "", chr(R::INFO_NONE)));
?>
--EXPECT--
NULL
array(1) {
  [0]=>
  int(1)
}
int(1)
int(-1)
int(2)
array(1) {
  [0]=>
  int(1)
}
array(0) {
}
int(1)
int(7)
array(0) {
}
array(0) {
}
int(1)
bool(true)
ValueError: paletteInfos must hold between 1 and 4096 entries
ValueError: Invalid collision info 9
ValueError: Word array does not match 4 bits per block and the palette
ValueError: Word array does not match 7 bits per block and the palette
ValueError: Word array does not match 1 bits per block and the palette
ValueError: Section 1073741824 0 0 is outside the supported world range
ValueError: Section coordinate 1099511627776 is out of range
int(0)
LogicException: Cannot modify a frozen collision region
