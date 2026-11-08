<?php

declare(strict_types=1);

namespace qmath\test;

use pocketmine\color\Color;
use pocketmine\math\Axis;
use pocketmine\math\AxisAlignedBB;
use pocketmine\math\Facing;
use pocketmine\math\Math;
use pocketmine\math\Matrix;
use pocketmine\math\Vector2;
use pocketmine\math\Vector3;
use pocketmine\math\VectorMath;
use pocketmine\math\VoxelRayTrace;

function native() : bool{
	return extension_loaded('qmath');
}

/** Mirrors Quark's Position: getSide() is overridden and must be honoured by up(), sides() etc. */
class Pos extends Vector3{
	public ?string $world = null;

	public function __construct(float|int $x, float|int $y, float|int $z, ?string $world){
		parent::__construct($x, $y, $z);
		$this->world = $world;
	}

	public function getSide(int $side, int $step = 1){
		$v = parent::getSide($side, $step);
		return new Pos($v->x, $v->y, $v->z, $this->world);
	}

	public function equals(Vector3 $v) : bool{
		return parent::equals($v) && (!($v instanceof Pos) || $v->world === $this->world);
	}
}

function vec(Gen $g) : Vector3{
	return new Vector3($g->num(), $g->num(), $g->num());
}

function fvec(Gen $g, float $r = 20) : Vector3{
	return new Vector3($g->float(-$r, $r), $g->float(-$r, $r), $g->float(-$r, $r));
}

function box(Gen $g, float $r = 8) : AxisAlignedBB{
	$x = $g->finite() * $r / 32;
	$y = $g->finite() * $r / 32;
	$z = $g->finite() * $r / 32;
	return new AxisAlignedBB($x, $y, $z, $x + $g->float(0, 3), $y + $g->float(0, 3), $z + $g->float(0, 3));
}

function suiteVector3(Gen $g, int $n) : void{
	for($i = 0; $i < $n; ++$i){
		$v = $g->chance(15) ? new Pos($g->num(), $g->num(), $g->num(), "w") : vec($g);
		$w = vec($g);
		$f = $g->pick([$g->finite(), 0.0, -0.0, 2.0, 1e300, NAN, INF]);
		$side = $g->int(-1, 7);
		$step = $g->pick([1, 2, -1, 0, $g->int(-5, 5), PHP_INT_MAX]);
		$cases = [
			'ctor' => fn() => new Vector3($v->x, $v->y, $v->z),
			'getXYZ' => fn() => [$v->getX(), $v->getY(), $v->getZ()],
			'floorXYZ' => fn() => [$v->getFloorX(), $v->getFloorY(), $v->getFloorZ()],
			'add' => fn() => $v->add($w->x, $w->y, $w->z),
			'addVector' => fn() => $v->addVector($w),
			'subtract' => fn() => $v->subtract($w->x, $w->y, $w->z),
			'subtractVector' => fn() => $v->subtractVector($w),
			'multiply' => fn() => $v->multiply($f),
			'divide' => fn() => $v->divide($f),
			'ceil' => fn() => $v->ceil(),
			'floor' => fn() => $v->floor(),
			'round' => fn() => $v->round(),
			'roundP' => fn() => $v->round($g->int(-3, 5), $g->int(1, 9)),
			'abs' => fn() => $v->abs(),
			'getSide' => fn() => $v->getSide($side, $step),
			'dirs' => fn() => [$v->down(), $v->up($step), $v->north(), $v->south(), $v->west(2), $v->east()],
			'sides' => fn() => $v->sides($step),
			'sidesArray' => fn() => [$v->sidesArray(), $v->sidesArray(true, 2)],
			'sidesAroundAxis' => fn() => $v->sidesAroundAxis($g->int(-1, 3), $step),
			'asVector3' => fn() => $v->asVector3(),
			'distance' => fn() => [$v->distance($w), $v->distanceSquared($w)],
			'maxPlain3' => fn() => $v->maxPlainDistance($w),
			'maxPlain2' => fn() => $v->maxPlainDistance(new Vector2($g->finite(), $g->finite())),
			'maxPlainF' => fn() => $v->maxPlainDistance($g->finite(), $g->finite()),
			'length' => fn() => [$v->length(), $v->lengthSquared()],
			'normalize' => fn() => $v->normalize(),
			'dot' => fn() => $v->dot($w),
			'cross' => fn() => $v->cross($w),
			'equals' => fn() => [$v->equals($w), $v->equals($v->asVector3()), $v->equals(new Vector3((float) $v->x, (float) $v->y, (float) $v->z))],
			'interX' => fn() => $v->getIntermediateWithXValue($w, $f),
			'interY' => fn() => $v->getIntermediateWithYValue($w, $g->finite()),
			'interZ' => fn() => $v->getIntermediateWithZValue($w, $g->finite()),
			'toString' => fn() => (string) $v,
			'with' => fn() => $v->withComponents($g->chance(50) ? null : $g->num(), $g->chance(50) ? null : $g->num(), $g->chance(50) ? null : $g->num()),
			'withNone' => fn() => $v->withComponents(null, null, null) === $v,
			'max' => fn() => Vector3::maxComponents($v, $w, ...array_map(fn() => vec($g), range(1, $g->int(0, 2)))),
			'min' => fn() => Vector3::minComponents($v, $w, ...array_map(fn() => vec($g), range(1, $g->int(0, 2)))),
			'sum' => fn() => Vector3::sum(...array_map(fn() => vec($g), range(0, $g->int(0, 3)))),
			'zero' => fn() => Vector3::zero(),
		];
		foreach($cases as $label => $fn){
			out("v3", $i, $label, run($fn));
		}
	}
}

function suiteVector2(Gen $g, int $n) : void{
	for($i = 0; $i < $n; ++$i){
		$a = new Vector2((float) $g->num(), (float) $g->num());
		$b = new Vector2($g->finite(), $g->finite());
		$f = $g->pick([$g->finite(), 0.0, 3.0, NAN]);
		$cases = [
			'get' => fn() => [$a->getX(), $a->getY(), $a->getFloorX(), $a->getFloorY()],
			'add' => fn() => [$a->add($b->x, $b->y), $a->addVector($b), $a->subtract($b->x, $b->y), $a->subtractVector($b)],
			'round' => fn() => [$a->ceil(), $a->floor(), $a->round(), $a->abs()],
			'scale' => fn() => [$a->multiply($f), $a->divide($f)],
			'dist' => fn() => [$a->distance($b), $a->distanceSquared($b), $a->length(), $a->lengthSquared(), $a->dot($b)],
			'normalize' => fn() => $a->normalize(),
			'str' => fn() => (string) $a,
			'dir' => fn() => VectorMath::getDirection2D($g->finite()),
		];
		foreach($cases as $label => $fn){
			out("v2", $i, $label, run($fn));
		}
	}
}

function suiteAABB(Gen $g, int $n) : void{
	for($i = 0; $i < $n; ++$i){
		$a = box($g);
		$b = box($g);
		$v = $g->chance(70) ? fvec($g, 6) : vec($g);
		$d = [$g->finite() / 4, $g->finite() / 4, $g->finite() / 4];
		$face = $g->int(-1, 6);
		$axis = $g->int(-1, 3);
		$dist = $g->finite() / 8;
		$p1 = fvec($g, 8);
		$p2 = $g->chance(20) ? clone $p1 : fvec($g, 8);
		$cases = [
			'ctor' => fn() => new AxisAlignedBB($g->finite(), $g->finite(), $g->finite(), $g->finite(), $g->finite(), $g->finite()),
			'addCoord' => fn() => $a->addCoord(...$d),
			'expand' => fn() => [(clone $a)->expand(...$d), $a->expandedCopy(...$d), $a],
			'offset' => fn() => [(clone $a)->offset(...$d), $a->offsetCopy(...$d)],
			'offsetTowards' => fn() => [(clone $a)->offsetTowards($face, $dist), $a->offsetTowardsCopy($face, $dist)],
			'contract' => fn() => [(clone $a)->contract(...$d), $a->contractedCopy(...$d)],
			'extend' => fn() => [(clone $a)->extend($face, $dist), $a->extendedCopy($face, $dist), (clone $a)->trim($face, $dist), $a->trimmedCopy($face, $dist)],
			'stretch' => fn() => [(clone $a)->stretch($axis, $dist), $a->stretchedCopy($axis, $dist), (clone $a)->squash($axis, $dist), $a->squashedCopy($axis, $dist)],
			'offsets' => fn() => [$a->calculateXOffset($b, $d[0]), $a->calculateYOffset($b, $d[1]), $a->calculateZOffset($b, $d[2])],
			'intersects' => fn() => [$a->intersectsWith($b), $a->intersectsWith($b, $g->pick([0.0, 0.1, -0.1]))],
			'inside' => fn() => [$a->isVectorInside($v), $a->isVectorInYZ($v), $a->isVectorInXZ($v), $a->isVectorInXY($v)],
			'lengths' => fn() => [$a->getAverageEdgeLength(), $a->getXLength(), $a->getYLength(), $a->getZLength(), $a->getVolume(), $a->isCube(), $a->isCube(0.5)],
			'intercept' => fn() => $a->calculateIntercept($p1, $p2),
			'str' => fn() => (string) $a,
			'one' => fn() => AxisAlignedBB::one(),
		];
		foreach($cases as $label => $fn){
			out("bb", $i, $label, run($fn));
		}
	}
}

function suiteFacing() : void{
	$i = 0;
	foreach(range(-2, 7) as $f){
		out("facing", $i, "basic$f", run(fn() => [Facing::axis($f), Facing::isPositive($f), Facing::opposite($f)]));
		out("facing", $i, "str$f", run(fn() => Facing::toString($f)));
		out("facing", $i, "validate$f", run(fn() => Facing::validate($f)));
		out("axis", $i, "str$f", run(fn() => Axis::toString($f)));
		foreach(range(-1, 3) as $axis){
			foreach([true, false] as $cw){
				out("facing", $i, "rot$f.$axis." . (int) $cw, run(fn() => Facing::rotate($f, $axis, $cw)));
			}
		}
		out("facing", $i, "rotXYZ$f", run(fn() => [Facing::rotateY($f, true), Facing::rotateZ($f, false), Facing::rotateX($f, true)]));
		++$i;
	}
	out("facing", 0, "consts", run(fn() => [Facing::ALL, Facing::HORIZONTAL, Facing::OFFSET, Facing::DOWN, Facing::EAST, Facing::FLAG_AXIS_POSITIVE, Axis::X, Axis::Y, Axis::Z]));
}

function suiteMath(Gen $g, int $n) : void{
	$values = [0, 1, -1, 1.5, -1.5, 2.0, -2.0, 0.0, -0.0, 1e-300, PHP_INT_MAX, PHP_INT_MIN, 1e19, -1e19, NAN, INF, -INF, 9.2233720368547758E+18, -9.2233720368547758E+18, "1.5", "-2.5", " 3", "abc", true, false, null, [], "9999999999999999999"];
	foreach($values as $i => $v){
		out("math", $i, "floor", run(fn() => Math::floorFloat($v)));
		out("math", $i, "ceil", run(fn() => Math::ceilFloat($v)));
	}
	for($i = 0; $i < $n; ++$i){
		$a = $g->pick([0.0, -0.0, $g->finite(), 1.0]);
		$b = $g->pick([$g->finite(), -2.0, 2.0]);
		$c = $g->pick([$g->finite(), 1.0, 0.0]);
		out("math", $i, "quad", run(fn() => Math::solveQuadratic($a, $b, $c)));
	}
}

function suiteVoxel(Gen $g, int $n) : void{
	for($i = 0; $i < $n; ++$i){
		$s = $g->chance(80) ? fvec($g, 30) : vec($g);
		$e = $g->chance(10) ? clone $s : ($g->chance(20) ? new Vector3((int) floor($s->x) + $g->int(-3, 3), $s->y, $g->int(-20, 20)) : fvec($g, 30));
		if($e->distance($s) > 200 || !is_finite($e->distance($s))){
			$e = fvec($g, 30);
			$s = fvec($g, 30);
		}
		out("voxel", $i, "between", run(fn() => VoxelRayTrace::betweenPoints($s, $e)));
		out("voxel", $i, "dir", run(fn() => VoxelRayTrace::inDirection($s, fvec($g, 1)->normalize(), $g->float(0, 30))));
	}
}

function suiteMatrix(Gen $g, int $n) : void{
	$cell = fn() => $g->pick([$g->int(-9, 9), $g->finite(), 0, 2.5]);
	for($i = 0; $i < $n; ++$i){
		$r = $g->int(1, 3);
		$c = $g->int(1, 3);
		$rows = [];
		for($y = 0; $y < $r; ++$y){
			for($x = 0; $x < $c; ++$x){
				$rows[$y][$x] = $cell();
			}
		}
		$m = new Matrix($r, $c, $rows);
		$o = new Matrix($r, $c, $rows);
		$o->setElement(0, 0, $g->finite());
		$sq = new Matrix($r, $r, $rows);
		$t = new Matrix($c, $g->int(1, 3), $rows);
		$cases = [
			'str' => fn() => (string) $m,
			'dims' => fn() => [$m->getRows(), $m->getColumns(), $m->isSquare()],
			'get' => fn() => [$m->getElement(0, 0), $m->getElement($r - 1, $c - 1)],
			'getOob' => fn() => $m->getElement($g->int(-1, $r + 1), $g->int(-1, $c + 1)),
			'add' => fn() => (string) $m->add($o),
			'sub' => fn() => (string) $m->subtract($o),
			'mul' => fn() => (string) $m->multiplyScalar($g->finite()),
			'div' => fn() => (string) $m->divideScalar($g->pick([$g->finite(), 0.0])),
			'transpose' => fn() => (string) $m->transpose(),
			'product' => fn() => (string) $m->product($t),
			'productBad' => fn() => (string) $m->product($m),
			'det' => fn() => $sq->determinant(),
			'detBad' => fn() => $m->determinant(),
			'array' => fn() => [isset($m[0]), isset($m[5]), $m[0], $m["0"]],
			'shape' => fn() => (string) $m->add(new Matrix($r + 1, $c)),
		];
		foreach($cases as $label => $fn){
			out("matrix", $i, $label, run($fn));
		}
	}
}

function suiteColor(Gen $g, int $n) : void{
	for($i = 0; $i < $n; ++$i){
		$code = $g->pick([$g->int(0, 0xffffffff), $g->int(-0xffffff, 0xffffff), -1, PHP_INT_MAX, 0]);
		$c = new Color($g->int(-300, 300), $g->int(0, 255), $g->int(0, 512), $g->int(-1, 300));
		$d = Color::fromARGB($code);
		$cases = [
			'ctor' => fn() => [$c, $c->getA(), $c->getR(), $c->getG(), $c->getB()],
			'codes' => fn() => [Color::fromRGB($code), Color::fromARGB($code), Color::fromRGBA($code), $c->toARGB(), $c->toRGBA()],
			'mix' => fn() => Color::mix($c, $d, ...array_map(fn() => Color::fromRGB($g->int(0, 0xffffff)), range(1, $g->int(0, 3)))),
			'mix1' => fn() => Color::mix($d),
			'equals' => fn() => [$c->equals($d), $c->equals(clone $c)],
		];
		foreach($cases as $label => $fn){
			out("color", $i, $label, run($fn));
		}
	}
}

function entityBox(Gen $g, float $x, float $y, float $z) : AxisAlignedBB{
	[$w, $h] = $g->pick([[0.6, 1.8], [0.98, 0.98], [0.25, 0.25], [0.6, 1.5], [1.4, 0.9]]);
	return new AxisAlignedBB($x - $w / 2, $y, $z - $w / 2, $x + $w / 2, $y + $h, $z + $w / 2);
}

function moveResult(\qmath\MoveResult $r) : array{
	return [$r->dx, $r->dy, $r->dz, $r->boundingBox, $r->collidedX, $r->collidedY, $r->collidedZ, $r->collidedHorizontally, $r->collidedVertically, $r->onGround, $r->stepped];
}

function suiteCollision(Gen $g, int $worlds, int $moves) : void{
	for($wi = 0; $wi < $worlds; ++$wi){
		$world = World::random($g);
		$region = native() ? ($wi % 2 === 0 ? $world->toRegion() : $world->toRegionSections()) : null;
		for($i = 0; $i < $moves; ++$i){
			$bb = entityBox($g, $g->float(-4, 4), $g->pick([1.0, 1.5, 2.0, $g->float(1, 3), 0.9999999]), $g->float(-4, 4));
			$step = $g->pick([0.0, 0.6, 0.5625, 1.0]);
			$onGround = $g->chance(50);
			for($t = 0; $t < 4; ++$t){
				$dx = $g->pick([$g->float(-0.6, 0.6), $g->float(-2, 2), 0.0]);
				$dy = $g->pick([-0.0784, $g->float(-1, 0.5), -3.0, 0.42, 0.0, -0.5]);
				$dz = $g->pick([$g->float(-0.6, 0.6), $g->float(-2, 2), 0.0]);
				$result = null;
				$res = run(function() use (&$result, $region, $world, $bb, $dx, $dy, $dz, $step, $onGround){
					return $result = native() ? moveResult(\qmath\Collision::move($region, $bb, $dx, $dy, $dz, $step, $onGround)) : move($world, $bb, $dx, $dy, $dz, $step, $onGround);
				});
				out("move", $wi * 1000 + $i, "t$t", $res);
				if($result === null){
					break;
				}
				$bb = $result[3];
				$onGround = $result[9];
				if(abs($bb->minX) > 5 || abs($bb->minZ) > 5 || $bb->minY < 0.5 || $bb->maxY > 5){
					break;
				}
			}
			$q = entityBox($g, $g->float(-5, 5), $g->float(0, 3), $g->float(-5, 5))->expand($g->float(0, 1), $g->float(0, 1), $g->float(0, 1));
			out("boxes", $wi * 1000 + $i, "list", run(fn() => native() ? $region->getCollisionBoxes($q) : blockCollisionBoxes($world, $q)));
		}
	}
}

function suiteProjectile(Gen $g, int $worlds, int $rays) : void{
	for($wi = 0; $wi < $worlds; ++$wi){
		$world = World::random($g);
		$region = native() ? ($wi % 2 === 0 ? $world->toRegion() : $world->toRegionSections()) : null;
		$segments = "";
		$expected = [];
		for($i = 0; $i < $rays; ++$i){
			$s = new Vector3($g->float(-6, 6), $g->float(0.5, 4.5), $g->float(-6, 6));
			$e = $g->chance(5) ? clone $s : new Vector3($g->float(-7, 7), $g->float(-0.5, 5.5), $g->float(-7, 7));
			$res = run(fn() => native() ? hitArray(\qmath\Raycast::blocks($region, $s, $e)) : projectileBlocks($world, $s, $e));
			out("proj", $wi * 1000 + $i, "blocks", $res);
			if($s->distanceSquared($e) > 0){
				$segments .= pack("e6", $s->x, $s->y, $s->z, $e->x, $e->y, $e->z);
				$expected[] = $res;
			}
			$boxes = [];
			for($k = $g->int(0, 5); $k > 0; --$k){
				$boxes[$g->chance(30) ? "e$k" : $k * 3] = entityBox($g, $g->float(-6, 6), $g->float(0, 4), $g->float(-6, 6));
			}
			out("proj", $wi * 1000 + $i, "entities", run(fn() => native() ? \qmath\Raycast::boxes($s, $e, $boxes, 0.3) : projectileEntities($s, $e, $boxes)));
		}
		if(native()){
			$packed = \qmath\Raycast::batchBlocks($region, $segments);
			foreach(str_split($packed, 56) as $k => $rec){
				$u = unpack("qface/qx/qy/qz/ehx/ehy/ehz", $rec);
				$ok = $u["face"] === -1 ? $expected[$k] === "N" : str_starts_with($expected[$k], "[0=i{$u['x']},1=i{$u['y']},2=i{$u['z']},3=i{$u['face']}");
				out("batch", $wi, "rec$k", $ok ? "ok" : "MISMATCH " . json_encode($u));
			}
		}else{
			foreach($expected as $k => $_){
				out("batch", $wi, "rec$k", "ok");
			}
		}
	}
}

function hitArray(?\qmath\VoxelHit $h) : ?array{
	return $h === null ? null : [$h->blockX, $h->blockY, $h->blockZ, $h->hitFace, $h->hitVector, $h->bb];
}

function suiteExposure(Gen $g, int $worlds, int $n) : void{
	for($wi = 0; $wi < $worlds; ++$wi){
		$world = World::random($g);
		$region = native() ? ($wi % 2 === 0 ? $world->toRegion() : $world->toRegionSections()) : null;
		for($i = 0; $i < $n; ++$i){
			$origin = $g->chance(20) ? new Vector3($g->int(-4, 4), $g->int(1, 3), $g->int(-4, 4)) : new Vector3($g->float(-5, 5), $g->float(1, 4), $g->float(-5, 5));
			$bb = entityBox($g, $g->float(-5, 5), $g->float(1, 3), $g->float(-5, 5));
			out("exposure", $wi * 1000 + $i, "e", run(fn() => native() ? \qmath\ExplosionMath::exposure($region, $origin, $bb) : exposure($world, $origin, $bb)));
		}
	}
}

function suiteExplosion(Gen $g, int $n) : void{
	for($i = 0; $i < $n; ++$i){
		$radius = $g->pick([1.0, 2.5, 4.0, $g->float(0.5, 6)]);
		$source = $g->chance(25) ? new Vector3($g->int(-2, 2), $g->int(-2, 2), $g->int(-2, 2)) : new Vector3($g->float(-2, 2), $g->float(-2, 2), $g->float(-2, 2));
		$span = (int) ceil($radius * 1.3 / 0.75) + 4;
		$res = [];
		for($x = -$span; $x <= $span; ++$x){
			for($y = -$span; $y <= $span; ++$y){
				for($z = -$span; $z <= $span; ++$z){
					$res["$x:$y:$z"] = $g->pick([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 30.0, 6000.0, null, -1.0, 0.5]);
				}
			}
		}
		$seed = $g->int(0, 1 << 30);
		if(native()){
			$grid = new \qmath\ResistanceGrid(-$span, -$span, -$span, $span, $span, $span);
			foreach($res as $key => $v){
				[$x, $y, $z] = array_map('intval', explode(":", $key));
				$v === null ? $grid->setInvalid($x, $y, $z) : $grid->set($x, $y, $z, $v);
			}
			mt_srand($seed);
			out("explode", $i, "all", run(fn() => \qmath\ExplosionMath::traceRays($grid, $source, $radius)) . " next=" . mt_rand());
			mt_srand($seed);
			$seen = [];
			$flat = [];
			for($a = 0; $a < 16; ++$a){
				for($b = 0; $b < 16; ++$b){
					for($c = 0; $c < 16; ++$c){
						if($a === 0 || $a === 15 || $b === 0 || $b === 15 || $c === 0 || $c === 15){
							foreach(array_chunk(\qmath\ExplosionMath::traceRay($grid, $source, $radius, $a, $b, $c), 3) as [$x, $y, $z]){
								if(!isset($seen["$x:$y:$z"])){
									$seen["$x:$y:$z"] = true;
									array_push($flat, $x, $y, $z);
								}
							}
						}
					}
				}
			}
			out("explode", $i, "perRay", enc($flat) . " next=" . mt_rand());
		}else{
			mt_srand($seed);
			$r = run(fn() => explodeA($res, $source, $radius)) . " next=" . mt_rand();
			out("explode", $i, "all", $r);
			out("explode", $i, "perRay", $r);
		}
	}
}

function suiteNoise(Gen $g, int $n) : void{
	for($i = 0; $i < $n; ++$i){
		$perm = range(0, 255);
		for($k = 255; $k > 0; --$k){
			$j = $g->int(0, $k);
			[$perm[$k], $perm[$j]] = [$perm[$j], $perm[$k]];
		}
		$full = array_merge($perm, $perm);
		$off = [$g->float(0, 256), $g->float(0, 256), $g->float(0, 256)];
		$octaves = $g->int(1, 4);
		$persist = $g->pick([0.25, 0.5, 1 / 3]);
		$exp = $g->pick([1 / 4, 1 / 32, 1 / 64, 1 / 16]);
		$short = $g->chance(50);
		$s = native() ? new \qmath\Simplex($short ? $perm : $full, $off[0], $off[1], $off[2], $octaves, $persist, $exp) : new RefSimplex($full, $off[0], $off[1], $off[2], $octaves, $persist, $exp);
		$pts = [];
		for($k = 0; $k < 8; ++$k){
			$pts[] = [$g->pick([$g->finite() * 100, (float) $g->int(-100000, 100000), -0.5, 1e7 + 0.25]), $g->finite() * 10, $g->finite() * 100];
		}
		$cx = $g->int(-50, 50) * 16;
		$cz = $g->int(-50, 50) * 16;
		$cases = [
			'raw' => fn() => array_map(fn($p) => [$s->getNoise2D($p[0], $p[2]), $s->getNoise3D($p[0], $p[1], $p[2])], $pts),
			'octave' => fn() => array_map(fn($p) => [$s->noise2D($p[0], $p[2]), $s->noise2D($p[0], $p[2], true), $s->noise3D($p[0], $p[1], $p[2]), $s->noise3D($p[0], $p[1], $p[2], true)], $pts),
			'fast1' => fn() => $s->getFastNoise1D(16, 4, $cx, 3, $cz),
			'fast2' => fn() => $s->getFastNoise2D(16, 16, 4, $cx, 0, $cz),
			'fast3' => fn() => $s->getFastNoise3D(16, 16, 16, 4, 8, 4, $cx, $g->pick([0, -8, 64]), $cz),
			'fast3r' => fn() => $s->getFastNoise3D(4, 6, 4, 1, 3, 2, $cx, 1, $cz),
		];
		foreach($cases as $label => $fn){
			out("noise", $i, $label, run($fn));
		}
		if(native()){
			$packed = $s->getFastNoise3DPacked(16, 16, 16, 4, 8, 4, $cx, 0, $cz);
			$nested = $s->getFastNoise3D(16, 16, 16, 4, 8, 4, $cx, 0, $cz);
			$flat = array_merge(...array_merge(...$nested));
			out("noise", $i, "packed", unpack("e*", $packed) === array_combine(range(1, count($flat)), array_map('floatval', $flat)) ? "ok" : "MISMATCH");
		}else{
			out("noise", $i, "packed", "ok");
		}
	}
}

function suitePhysics(Gen $g, int $n) : void{
	for($i = 0; $i < $n; ++$i){
		$m = $g->chance(20) ? new Vector3($g->int(-1, 1), $g->int(-1, 1), 0) : new Vector3($g->float(-1, 1), $g->float(-2, 1), $g->pick([$g->float(-1, 1), 0.000001, -0.0000099]));
		$drag = $g->pick([0.02, 0.01, 0.05, 0.25]);
		$gravity = $g->pick([0.08, 0.04, 0.03, 0.05]);
		$ge = $g->chance(80);
		$dbg = $g->chance(40);
		$gf = $g->pick([1.0, 0.6, 0.8, 0.98, 0.546]);
		$yaw = $g->pick([$g->float(-720, 720), 0.0, 45.0, 315.0, -45.0, 360.0, 135.0]);
		$pitch = $g->float(-90, 90);
		$eye = fvec($g, 10);
		$target = $g->chance(10) ? clone $eye : fvec($g, 10);
		$kx = $g->pick([$g->finite(), 0.0]);
		$kz = $g->pick([$g->finite(), 0.0]);
		$limit = $g->pick([0.4, null, 0.1]);
		$cases = native() ? [
			'step' => fn() => \qmath\Physics::motionStep($m, $drag, $gravity, $ge, $dbg, $gf),
			'knock' => fn() => \qmath\Physics::knockBack($m, $kx, $kz, 0.4, $limit),
			'dir' => fn() => VectorMath::getDirection3D($yaw, $pitch),
			'plane' => fn() => \qmath\Physics::directionPlane($yaw),
			'facing' => fn() => \qmath\Physics::horizontalFacing($yaw),
			'look' => fn() => \qmath\Physics::lookAt($eye, $target),
			'rot' => fn() => \qmath\Physics::motionRotation($m),
		] : [
			'step' => fn() => motionStep($m, $drag, $gravity, $ge, $dbg, $gf),
			'knock' => fn() => knockBack($m, $kx, $kz, 0.4, $limit),
			'dir' => fn() => directionVector($yaw, $pitch),
			'plane' => fn() => directionPlane($yaw),
			'facing' => fn() => horizontalFacing($yaw),
			'look' => fn() => lookAt($eye, $target),
			'rot' => fn() => motionRotation($m),
		];
		foreach($cases as $label => $fn){
			out("physics", $i, $label, run($fn));
		}
	}
}

function suiteSpatial(Gen $g, int $n) : void{
	for($i = 0; $i < $n; ++$i){
		$entities = [];
		for($k = $g->int(0, 12); $k > 0; --$k){
			$entities[] = new FakeEntity(entityBox($g, $g->float(-4, 4), $g->float(0, 3), $g->float(-4, 4)));
		}
		$q = entityBox($g, $g->float(-4, 4), $g->float(-1, 3), $g->float(-4, 4))->expand($g->float(0, 2), $g->float(0, 1), $g->float(0, 2));
		$exclude = count($entities) > 0 && $g->chance(50) ? $entities[0] : null;
		$res = native() ? \qmath\Spatial::overlapping($entities, $q, $exclude) : nearby($entities, $q, $exclude);
		out("spatial", $i, "near", enc(array_map(fn($e) => array_search($e, $entities, true), $res)));
		$boxes = array_map(fn($e) => $e->boundingBox, $entities);
		out("spatial", $i, "boxes", enc(native() ? \qmath\Spatial::overlappingBoxes($q, $boxes) : array_map(fn($e) => array_search($e, $entities, true), nearby($entities, $q, null))));
	}
}
