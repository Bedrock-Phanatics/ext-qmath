<?php

/*
 * Reference copies of Quark v6 algorithms (LGPL-3.0), reduced to the math they perform.
 * They run on whichever pocketmine\math implementation is loaded.
 */

declare(strict_types=1);

namespace qmath\test;

use pocketmine\math\AxisAlignedBB;
use pocketmine\math\Facing;
use pocketmine\math\RayTraceResult;
use pocketmine\math\Vector2;
use pocketmine\math\Vector3;
use pocketmine\math\VoxelRayTrace;

const COLLISION_CUSTOM = 0;
const COLLISION_CUBE = 1;
const COLLISION_NONE = 2;
const COLLISION_MAY_OVERFLOW = 3;

/** A small block world: per cell collision info and the block's own boxes, cell relative. */
final class World{
	/** @var array<string, array{int, list<array{float,float,float,float,float,float}>}> */
	public array $cells = [];

	public function __construct(public int $minX, public int $minY, public int $minZ, public int $maxX, public int $maxY, public int $maxZ){}

	public static function random(Gen $g, int $size = 8, int $height = 6) : self{
		$w = new self(-$size, -6, -$size, $size, $height, $size);
		for($x = -$size; $x <= $size; ++$x){
			for($z = -$size; $z <= $size; ++$z){
				$w->set($x, 0, $z, COLLISION_CUBE, []);
				for($y = 1; $y < $height - 1; ++$y){
					if(!$g->chance($y === 1 ? 35 : 15)){
						continue;
					}
					[$info, $boxes] = $g->pick(self::shapes($g));
					$w->set($x, $y, $z, $info, $boxes);
				}
			}
		}
		return $w;
	}

	/** @return list<array{int, list<array{float,float,float,float,float,float}>}> */
	private static function shapes(Gen $g) : array{
		$arm = $g->pick([[0.375, 0.0, 0.0, 0.625, 1.5, 0.375], [0.625, 0.0, 0.375, 1.0, 1.5, 0.625], [0.0, 0.0, 0.375, 0.375, 1.5, 0.625]]);
		return [
			[COLLISION_CUBE, []],
			[COLLISION_CUSTOM, [[0.0, 0.0, 0.0, 1.0, 0.5, 1.0]]],
			[COLLISION_CUSTOM, [[0.0, 0.5, 0.0, 1.0, 1.0, 1.0]]],
			[COLLISION_CUSTOM, [[0.0, 0.0, 0.0, 1.0, 0.5, 1.0], [0.0, 0.5, 0.5, 1.0, 1.0, 1.0]]],
			[COLLISION_CUSTOM, [[0.0, 0.0, 0.0, 1.0, 0.0625, 1.0]]],
			[COLLISION_CUSTOM, [[0.4375, 0.0, 0.0, 0.5625, 1.0, 1.0]]],
			[COLLISION_MAY_OVERFLOW, [[0.375, 0.0, 0.375, 0.625, 1.5, 0.625], $arm]],
			[COLLISION_MAY_OVERFLOW, [[0.25, 0.0, 0.25, 0.75, 1.5, 0.75]]],
		];
	}

	/** @param list<array{float,float,float,float,float,float}> $boxes */
	public function set(int $x, int $y, int $z, int $info, array $boxes) : void{
		$this->cells["$x:$y:$z"] = [$info, $boxes];
	}

	public function info(int $x, int $y, int $z) : int{
		return $this->cells["$x:$y:$z"][0] ?? COLLISION_NONE;
	}

	/** Block::getCollisionBoxes() @return list<AxisAlignedBB> */
	public function ownBoxes(int $x, int $y, int $z) : array{
		$cell = $this->cells["$x:$y:$z"] ?? [COLLISION_NONE, []];
		if($cell[0] === COLLISION_CUBE){
			return [AxisAlignedBB::one()->offset($x, $y, $z)];
		}
		$out = [];
		foreach($cell[1] as [$a, $b, $c, $d, $e, $f]){
			$out[] = (new AxisAlignedBB($a, $b, $c, $d, $e, $f))->offset($x, $y, $z);
		}
		return $out;
	}

	public function toRegion() : \qmath\CollisionRegion{
		$r = new \qmath\CollisionRegion($this->minX - 1, $this->minY - 1, $this->minZ - 1, $this->maxX + 1, $this->maxY + 1, $this->maxZ + 1);
		$r->fill(\qmath\CollisionRegion::INFO_NONE);
		foreach($this->cells as $key => [$info, $_]){
			[$x, $y, $z] = array_map('intval', explode(":", $key));
			$r->setCell($x, $y, $z, $info, $info === COLLISION_CUBE ? [] : $this->ownBoxes($x, $y, $z));
		}
		return $r;
	}
}

/** World::getBlockCollisionBoxesForCell() */
function cellBoxes(World $w, int $x, int $y, int $z) : array{
	$info = $w->info($x, $y, $z);
	$boxes = match($info){
		COLLISION_NONE => [],
		COLLISION_CUBE => [AxisAlignedBB::one()->offset($x, $y, $z)],
		default => $w->ownBoxes($x, $y, $z)
	};
	if($info !== COLLISION_CUBE){
		$cellBB = null;
		foreach(Facing::OFFSET as [$dx, $dy, $dz]){
			$ox = $x + $dx;
			$oy = $y + $dy;
			$oz = $z + $dz;
			if($w->info($ox, $oy, $oz) === COLLISION_MAY_OVERFLOW){
				$cellBB ??= AxisAlignedBB::one()->offset($x, $y, $z);
				foreach($w->ownBoxes($ox, $oy, $oz) as $extra){
					if($extra->intersectsWith($cellBB)){
						$boxes[] = $extra;
					}
				}
			}
		}
	}
	return $boxes;
}

/** World::getBlockCollisionBoxes() */
function blockCollisionBoxes(World $w, AxisAlignedBB $bb) : array{
	$minX = (int) floor($bb->minX);
	$minY = (int) floor($bb->minY);
	$minZ = (int) floor($bb->minZ);
	$maxX = (int) floor($bb->maxX);
	$maxY = (int) floor($bb->maxY);
	$maxZ = (int) floor($bb->maxZ);
	$collides = [];
	for($z = $minZ; $z <= $maxZ; ++$z){
		for($x = $minX; $x <= $maxX; ++$x){
			for($y = $minY; $y <= $maxY; ++$y){
				foreach(cellBoxes($w, $x, $y, $z) as $blockBB){
					if($blockBB->intersectsWith($bb)){
						$collides[] = $blockBB;
					}
				}
			}
		}
	}
	return $collides;
}

/** Collision part of Entity::move() and checkGroundState(). */
function move(World $w, AxisAlignedBB $boundingBox, float $dx, float $dy, float $dz, float $stepHeight, bool $onGround) : array{
	$wantedX = $dx;
	$wantedY = $dy;
	$wantedZ = $dz;
	$moveBB = clone $boundingBox;
	$list = blockCollisionBoxes($w, $moveBB->addCoord($dx, $dy, $dz));
	foreach($list as $bb){
		$dy = $bb->calculateYOffset($moveBB, $dy);
	}
	$moveBB->offset(0, $dy, 0);
	$fallingFlag = ($onGround || ($dy !== $wantedY && $wantedY < 0));
	foreach($list as $bb){
		$dx = $bb->calculateXOffset($moveBB, $dx);
	}
	$moveBB->offset($dx, 0, 0);
	foreach($list as $bb){
		$dz = $bb->calculateZOffset($moveBB, $dz);
	}
	$moveBB->offset(0, 0, $dz);
	$stepped = false;
	if($stepHeight > 0 && $fallingFlag && ($wantedX !== $dx || $wantedZ !== $dz)){
		$cx = $dx;
		$cy = $dy;
		$cz = $dz;
		$dx = $wantedX;
		$dy = $stepHeight;
		$dz = $wantedZ;
		$stepBB = clone $boundingBox;
		$list = blockCollisionBoxes($w, $stepBB->addCoord($dx, $dy, $dz));
		foreach($list as $bb){
			$dy = $bb->calculateYOffset($stepBB, $dy);
		}
		$stepBB->offset(0, $dy, 0);
		foreach($list as $bb){
			$dx = $bb->calculateXOffset($stepBB, $dx);
		}
		$stepBB->offset($dx, 0, 0);
		foreach($list as $bb){
			$dz = $bb->calculateZOffset($stepBB, $dz);
		}
		$stepBB->offset(0, 0, $dz);
		$reverseDY = -$dy;
		foreach($list as $bb){
			$reverseDY = $bb->calculateYOffset($stepBB, $reverseDY);
		}
		$dy += $reverseDY;
		$stepBB->offset(0, $reverseDY, 0);
		if(($cx ** 2 + $cz ** 2) >= ($dx ** 2 + $dz ** 2)){
			$dx = $cx;
			$dy = $cy;
			$dz = $cz;
		}else{
			$moveBB = $stepBB;
			$stepped = true;
		}
	}
	return [
		$dx, $dy, $dz, $moveBB,
		$wantedX !== $dx, $wantedY !== $dy, $wantedZ !== $dz,
		($wantedX !== $dx || $wantedZ !== $dz), $wantedY !== $dy, ($wantedY !== $dy && $wantedY < 0), $stepped,
	];
}

/** Block::calculateIntercept() */
function blockIntercept(array $bbs, Vector3 $pos1, Vector3 $pos2) : ?RayTraceResult{
	if(count($bbs) === 0){
		return null;
	}
	$currentHit = null;
	$currentDistance = PHP_INT_MAX;
	foreach($bbs as $bb){
		$nextHit = $bb->calculateIntercept($pos1, $pos2);
		if($nextHit === null){
			continue;
		}
		$nextDistance = $nextHit->hitVector->distanceSquared($pos1);
		if($nextDistance < $currentDistance){
			$currentHit = $nextHit;
			$currentDistance = $nextDistance;
		}
	}
	return $currentHit;
}

/** Block pass of Projectile::move(). */
function projectileBlocks(World $w, Vector3 $start, Vector3 $end) : ?array{
	foreach(VoxelRayTrace::betweenPoints($start, $end) as $v){
		$hit = blockIntercept($w->ownBoxes($v->x, $v->y, $v->z), $start, $end);
		if($hit !== null){
			return [$v->x, $v->y, $v->z, $hit->hitFace, $hit->hitVector, $hit->bb];
		}
	}
	return null;
}

/** Entity pass of Projectile::move(). @param AxisAlignedBB[] $boxes */
function projectileEntities(Vector3 $start, Vector3 $end, array $boxes) : ?array{
	$entityDistance = PHP_INT_MAX;
	$hitResult = null;
	foreach($boxes as $key => $box){
		$entityBB = $box->expandedCopy(0.3, 0.3, 0.3);
		$entityHitResult = $entityBB->calculateIntercept($start, $end);
		if($entityHitResult === null){
			continue;
		}
		$distance = $start->distanceSquared($entityHitResult->hitVector);
		if($distance < $entityDistance){
			$entityDistance = $distance;
			$hitResult = [$key, $entityHitResult];
			$end = $entityHitResult->hitVector;
		}
	}
	return $hitResult;
}

/** Explosion::getExposure() */
function exposure(World $w, Vector3 $origin, AxisAlignedBB $bb) : float{
	$diff = (new Vector3($bb->getXLength(), $bb->getYLength(), $bb->getZLength()))->multiply(2)->add(1, 1, 1);
	$step = new Vector3(1.0 / $diff->x, 1.0 / $diff->y, 1.0 / $diff->z);
	$xOffset = (1.0 - (floor($diff->x) / $diff->x)) / 2.0;
	$zOffset = (1.0 - (floor($diff->z) / $diff->z)) / 2.0;
	$checks = 0.0;
	$hits = 0.0;
	for($x = 0.0; $x <= 1.0; $x += $step->x){
		for($y = 0.0; $y <= 1.0; $y += $step->y){
			for($z = 0.0; $z <= 1.0; $z += $step->z){
				$point = new Vector3(
					lerp($x, $bb->minX, $bb->maxX) + $xOffset,
					lerp($y, $bb->minY, $bb->maxY),
					lerp($z, $bb->minZ, $bb->maxZ) + $zOffset
				);
				$intercepted = false;
				foreach(VoxelRayTrace::betweenPoints($origin, $point) as $pos){
					if(blockIntercept($w->ownBoxes($pos->x, $pos->y, $pos->z), $origin, $point) !== null){
						$intercepted = true;
						break;
					}
				}
				if(!$intercepted){
					$hits++;
				}
				$checks++;
			}
		}
	}
	return $checks > 0.0 ? $hits / $checks : 0.0;
}

function lerp(float $scale, float $a, float $b) : float{
	return $a + $scale * ($b - $a);
}

/**
 * Explosion::explodeA() ray march. $resistance maps "x:y:z" to a blast resistance, null for an
 * unreachable cell. Every Block::getAffectedBlocks() includes the block itself.
 * @return list<int>
 */
function explodeA(array $resistance, Vector3 $source, float $radius, int $rays = 16, float $stepLen = 0.3) : array{
	$affected = [];
	$mRays = $rays - 1;
	for($i = 0; $i < $rays; ++$i){
		for($j = 0; $j < $rays; ++$j){
			for($k = 0; $k < $rays; ++$k){
				if($i === 0 || $i === $mRays || $j === 0 || $j === $mRays || $k === 0 || $k === $mRays){
					[$shiftX, $shiftY, $shiftZ] = [$i / $mRays * 2 - 1, $j / $mRays * 2 - 1, $k / $mRays * 2 - 1];
					$len = sqrt($shiftX ** 2 + $shiftY ** 2 + $shiftZ ** 2);
					[$shiftX, $shiftY, $shiftZ] = [($shiftX / $len) * $stepLen, ($shiftY / $len) * $stepLen, ($shiftZ / $len) * $stepLen];
					$pointerX = $source->x;
					$pointerY = $source->y;
					$pointerZ = $source->z;
					for($blastForce = $radius * (mt_rand(700, 1300) / 1000); $blastForce > 0; $blastForce -= $stepLen * 0.75){
						$x = (int) $pointerX;
						$y = (int) $pointerY;
						$z = (int) $pointerZ;
						$vBlockX = $pointerX >= $x ? $x : $x - 1;
						$vBlockY = $pointerY >= $y ? $y : $y - 1;
						$vBlockZ = $pointerZ >= $z ? $z : $z - 1;
						$pointerX += $shiftX;
						$pointerY += $shiftY;
						$pointerZ += $shiftZ;
						$key = "$vBlockX:$vBlockY:$vBlockZ";
						if(!array_key_exists($key, $resistance)){
							throw new \RuntimeException("missing $key");
						}
						if($resistance[$key] === null){
							continue;
						}
						$blastResistance = $resistance[$key];
						if($blastResistance >= 0){
							$blastForce -= ($blastResistance / 5 + 0.3) * $stepLen;
							if($blastForce > 0 && !isset($affected[$key])){
								$affected[$key] = [$vBlockX, $vBlockY, $vBlockZ];
							}
						}
					}
				}
			}
		}
	}
	return array_merge(...array_values($affected));
}

/** Quark's Simplex + Noise with the permutation and offsets supplied directly. */
final class RefSimplex{
	private const grad3 = [
		[1, 1, 0], [-1, 1, 0], [1, -1, 0], [-1, -1, 0],
		[1, 0, 1], [-1, 0, 1], [1, 0, -1], [-1, 0, -1],
		[0, 1, 1], [0, -1, 1], [0, 1, -1], [0, -1, -1]
	];
	private const F2 = 0.5 * (M_SQRT3 - 1);
	private const G2 = (3 - M_SQRT3) / 6;
	private const G22 = self::G2 * 2.0 - 1;
	private const F3 = 1.0 / 3.0;
	private const G3 = 1.0 / 6.0;

	/** @param int[] $perm */
	public function __construct(private array $perm, private float $offsetX, private float $offsetY, private float $offsetZ, private int $octaves, private float $persistence, private float $expansion){}

	public function getNoise3D($x, $y, $z){
		$x += $this->offsetX;
		$y += $this->offsetY;
		$z += $this->offsetZ;
		$s = ($x + $y + $z) * self::F3;
		$i = (int) ($x + $s);
		$j = (int) ($y + $s);
		$k = (int) ($z + $s);
		$t = ($i + $j + $k) * self::G3;
		$x0 = $x - ($i - $t);
		$y0 = $y - ($j - $t);
		$z0 = $z - ($k - $t);
		if($x0 >= $y0){
			if($y0 >= $z0){
				[$i1, $j1, $k1, $i2, $j2, $k2] = [1, 0, 0, 1, 1, 0];
			}elseif($x0 >= $z0){
				[$i1, $j1, $k1, $i2, $j2, $k2] = [1, 0, 0, 1, 0, 1];
			}else{
				[$i1, $j1, $k1, $i2, $j2, $k2] = [0, 0, 1, 1, 0, 1];
			}
		}else{
			if($y0 < $z0){
				[$i1, $j1, $k1, $i2, $j2, $k2] = [0, 0, 1, 0, 1, 1];
			}elseif($x0 < $z0){
				[$i1, $j1, $k1, $i2, $j2, $k2] = [0, 1, 0, 0, 1, 1];
			}else{
				[$i1, $j1, $k1, $i2, $j2, $k2] = [0, 1, 0, 1, 1, 0];
			}
		}
		$x1 = $x0 - $i1 + self::G3;
		$y1 = $y0 - $j1 + self::G3;
		$z1 = $z0 - $k1 + self::G3;
		$x2 = $x0 - $i2 + 2.0 * self::G3;
		$y2 = $y0 - $j2 + 2.0 * self::G3;
		$z2 = $z0 - $k2 + 2.0 * self::G3;
		$x3 = $x0 - 1.0 + 3.0 * self::G3;
		$y3 = $y0 - 1.0 + 3.0 * self::G3;
		$z3 = $z0 - 1.0 + 3.0 * self::G3;
		$ii = $i & 255;
		$jj = $j & 255;
		$kk = $k & 255;
		$n = 0;
		$perm = $this->perm;
		$t0 = 0.6 - $x0 * $x0 - $y0 * $y0 - $z0 * $z0;
		if($t0 > 0){
			$gi0 = self::grad3[$perm[$ii + $perm[$jj + $perm[$kk]]] % 12];
			$n += $t0 * $t0 * $t0 * $t0 * ($gi0[0] * $x0 + $gi0[1] * $y0 + $gi0[2] * $z0);
		}
		$t1 = 0.6 - $x1 * $x1 - $y1 * $y1 - $z1 * $z1;
		if($t1 > 0){
			$gi1 = self::grad3[$perm[$ii + $i1 + $perm[$jj + $j1 + $perm[$kk + $k1]]] % 12];
			$n += $t1 * $t1 * $t1 * $t1 * ($gi1[0] * $x1 + $gi1[1] * $y1 + $gi1[2] * $z1);
		}
		$t2 = 0.6 - $x2 * $x2 - $y2 * $y2 - $z2 * $z2;
		if($t2 > 0){
			$gi2 = self::grad3[$perm[$ii + $i2 + $perm[$jj + $j2 + $perm[$kk + $k2]]] % 12];
			$n += $t2 * $t2 * $t2 * $t2 * ($gi2[0] * $x2 + $gi2[1] * $y2 + $gi2[2] * $z2);
		}
		$t3 = 0.6 - $x3 * $x3 - $y3 * $y3 - $z3 * $z3;
		if($t3 > 0){
			$gi3 = self::grad3[$perm[$ii + 1 + $perm[$jj + 1 + $perm[$kk + 1]]] % 12];
			$n += $t3 * $t3 * $t3 * $t3 * ($gi3[0] * $x3 + $gi3[1] * $y3 + $gi3[2] * $z3);
		}
		return 32.0 * $n;
	}

	public function getNoise2D($x, $y){
		$x += $this->offsetX;
		$y += $this->offsetY;
		$s = ($x + $y) * self::F2;
		$i = (int) ($x + $s);
		$j = (int) ($y + $s);
		$t = ($i + $j) * self::G2;
		$x0 = $x - ($i - $t);
		$y0 = $y - ($j - $t);
		if($x0 > $y0){
			$i1 = 1;
			$j1 = 0;
		}else{
			$i1 = 0;
			$j1 = 1;
		}
		$x1 = $x0 - $i1 + self::G2;
		$y1 = $y0 - $j1 + self::G2;
		$x2 = $x0 + self::G22;
		$y2 = $y0 + self::G22;
		$ii = $i & 255;
		$jj = $j & 255;
		$n = 0;
		$t0 = 0.5 - $x0 * $x0 - $y0 * $y0;
		if($t0 > 0){
			$gi0 = self::grad3[$this->perm[$ii + $this->perm[$jj]] % 12];
			$n += $t0 * $t0 * $t0 * $t0 * ($gi0[0] * $x0 + $gi0[1] * $y0);
		}
		$t1 = 0.5 - $x1 * $x1 - $y1 * $y1;
		if($t1 > 0){
			$gi1 = self::grad3[$this->perm[$ii + $i1 + $this->perm[$jj + $j1]] % 12];
			$n += $t1 * $t1 * $t1 * $t1 * ($gi1[0] * $x1 + $gi1[1] * $y1);
		}
		$t2 = 0.5 - $x2 * $x2 - $y2 * $y2;
		if($t2 > 0){
			$gi2 = self::grad3[$this->perm[$ii + 1 + $this->perm[$jj + 1]] % 12];
			$n += $t2 * $t2 * $t2 * $t2 * ($gi2[0] * $x2 + $gi2[1] * $y2);
		}
		return 70.0 * $n;
	}

	public function noise2D($x, $z, $normalized = false){
		$result = 0;
		$amp = 1;
		$freq = 1;
		$max = 0;
		$x *= $this->expansion;
		$z *= $this->expansion;
		for($i = 0; $i < $this->octaves; ++$i){
			$result += $this->getNoise2D($x * $freq, $z * $freq) * $amp;
			$max += $amp;
			$freq *= 2;
			$amp *= $this->persistence;
		}
		if($normalized === true){
			$result /= $max;
		}
		return $result;
	}

	public function noise3D($x, $y, $z, $normalized = false){
		$result = 0;
		$amp = 1;
		$freq = 1;
		$max = 0;
		$x *= $this->expansion;
		$y *= $this->expansion;
		$z *= $this->expansion;
		for($i = 0; $i < $this->octaves; ++$i){
			$result += $this->getNoise3D($x * $freq, $y * $freq, $z * $freq) * $amp;
			$max += $amp;
			$freq *= 2;
			$amp *= $this->persistence;
		}
		if($normalized === true){
			$result /= $max;
		}
		return $result;
	}

	public static function linearLerp($x, $x1, $x2, $q0, $q1){
		return (($x2 - $x) / ($x2 - $x1)) * $q0 + (($x - $x1) / ($x2 - $x1)) * $q1;
	}

	public static function bilinearLerp($x, $y, $q00, $q01, $q10, $q11, $x1, $x2, $y1, $y2){
		$dx1 = (($x2 - $x) / ($x2 - $x1));
		$dx2 = (($x - $x1) / ($x2 - $x1));
		return (($y2 - $y) / ($y2 - $y1)) * (
			$dx1 * $q00 + $dx2 * $q10
		) + (($y - $y1) / ($y2 - $y1)) * (
			$dx1 * $q01 + $dx2 * $q11
		);
	}

	public function getFastNoise1D(int $xSize, int $samplingRate, int $x, int $y, int $z) : array{
		$noiseArray = new \SplFixedArray($xSize + 1);
		for($xx = 0; $xx <= $xSize; $xx += $samplingRate){
			$noiseArray[$xx] = $this->noise3D($xx + $x, $y, $z);
		}
		for($xx = 0; $xx < $xSize; ++$xx){
			if($xx % $samplingRate !== 0){
				$nx = (int) ($xx / $samplingRate) * $samplingRate;
				$noiseArray[$xx] = self::linearLerp(x: $xx, x1: $nx, x2: $nx + $samplingRate, q0: $noiseArray[$nx], q1: $noiseArray[$nx + $samplingRate]);
			}
		}
		return $noiseArray->toArray();
	}

	public function getFastNoise2D(int $xSize, int $zSize, int $samplingRate, int $x, int $y, int $z) : array{
		$noiseArray = new \SplFixedArray($xSize + 1);
		for($xx = 0; $xx <= $xSize; $xx += $samplingRate){
			$noiseArray[$xx] = new \SplFixedArray($zSize + 1);
			for($zz = 0; $zz <= $zSize; $zz += $samplingRate){
				$noiseArray[$xx][$zz] = $this->noise3D($x + $xx, $y, $z + $zz);
			}
		}
		for($xx = 0; $xx < $xSize; ++$xx){
			if($xx % $samplingRate !== 0){
				$noiseArray[$xx] = new \SplFixedArray($zSize + 1);
			}
			for($zz = 0; $zz < $zSize; ++$zz){
				if($xx % $samplingRate !== 0 || $zz % $samplingRate !== 0){
					$nx = (int) ($xx / $samplingRate) * $samplingRate;
					$nz = (int) ($zz / $samplingRate) * $samplingRate;
					$noiseArray[$xx][$zz] = self::bilinearLerp(
						x: $xx, y: $zz,
						q00: $noiseArray[$nx][$nz], q01: $noiseArray[$nx][$nz + $samplingRate],
						q10: $noiseArray[$nx + $samplingRate][$nz], q11: $noiseArray[$nx + $samplingRate][$nz + $samplingRate],
						x1: $nx, x2: $nx + $samplingRate, y1: $nz, y2: $nz + $samplingRate
					);
				}
			}
		}
		$out = [];
		foreach($noiseArray as $row){
			$out[] = $row->toArray();
		}
		return $out;
	}

	public function getFastNoise3D(int $xSize, int $ySize, int $zSize, int $xSamplingRate, int $ySamplingRate, int $zSamplingRate, int $x, int $y, int $z) : array{
		$noiseArray = array_fill(0, $xSize + 1, array_fill(0, $zSize + 1, array_fill(0, $ySize + 1, 0)));
		for($xx = 0; $xx <= $xSize; $xx += $xSamplingRate){
			for($zz = 0; $zz <= $zSize; $zz += $zSamplingRate){
				for($yy = 0; $yy <= $ySize; $yy += $ySamplingRate){
					$noiseArray[$xx][$zz][$yy] = $this->noise3D($x + $xx, $y + $yy, $z + $zz, true);
				}
			}
		}
		$xLerpStep = 1 / $xSamplingRate;
		$yLerpStep = 1 / $ySamplingRate;
		$zLerpStep = 1 / $zSamplingRate;
		for($leftX = 0; $leftX < $xSize; $leftX += $xSamplingRate){
			$rightX = $leftX + $xSamplingRate;
			for($leftZ = 0; $leftZ < $zSize; $leftZ += $zSamplingRate){
				$rightZ = $leftZ + $zSamplingRate;
				for($leftY = 0; $leftY < $ySize; $leftY += $ySamplingRate){
					$rightY = $leftY + $ySamplingRate;
					$c000 = $noiseArray[$leftX][$leftZ][$leftY];
					$c100 = $noiseArray[$rightX][$leftZ][$leftY];
					$c001 = $noiseArray[$leftX][$leftZ][$rightY];
					$c101 = $noiseArray[$rightX][$leftZ][$rightY];
					$c010 = $noiseArray[$leftX][$rightZ][$leftY];
					$c110 = $noiseArray[$rightX][$rightZ][$leftY];
					$c011 = $noiseArray[$leftX][$rightZ][$rightY];
					$c111 = $noiseArray[$rightX][$rightZ][$rightY];
					for($xStep = 0; $xStep < $xSamplingRate; $xStep++){
						$xx = $leftX + $xStep;
						$dx2 = $xStep * $xLerpStep;
						$dx1 = 1 - $dx2;
						$x00 = ($c000 * $dx1) + ($c100 * $dx2);
						$x01 = ($c001 * $dx1) + ($c101 * $dx2);
						$x10 = ($c010 * $dx1) + ($c110 * $dx2);
						$x11 = ($c011 * $dx1) + ($c111 * $dx2);
						for($zStep = 0; $zStep < $zSamplingRate; $zStep++){
							$zz = $leftZ + $zStep;
							$dz2 = $zStep * $zLerpStep;
							$dz1 = 1 - $dz2;
							$z0 = $x00 * $dz1 + $x10 * $dz2;
							$z1 = $x01 * $dz1 + $x11 * $dz2;
							$yStart = $xStep === 0 && $zStep === 0 ? 1 : 0;
							for($yStep = $yStart; $yStep < $ySamplingRate; $yStep++){
								$yy = $leftY + $yStep;
								$dy2 = $yStep * $yLerpStep;
								$dy1 = 1 - $dy2;
								$noiseArray[$xx][$zz][$yy] = $dy1 * $z0 + $dy2 * $z1;
							}
						}
					}
				}
			}
		}
		return $noiseArray;
	}
}

/** Entity::tryChangeMovement() with the block friction supplied, then the onUpdate() clamp. */
function motionStep(Vector3 $motion, float $drag, float $gravity, bool $gravityEnabled, bool $dragBeforeGravity, float $groundFriction) : Vector3{
	$friction = 1 - $drag;
	$mY = $motion->y;
	if($dragBeforeGravity){
		$mY *= $friction;
	}
	if($gravityEnabled){
		$mY -= $gravity;
	}
	if(!$dragBeforeGravity){
		$mY *= $friction;
	}
	if($groundFriction !== 1.0){
		$friction *= $groundFriction;
	}
	$motion = new Vector3($motion->x * $friction, $mY, $motion->z * $friction);
	return $motion->withComponents(
		abs($motion->x) <= 0.00001 ? 0 : null,
		abs($motion->y) <= 0.00001 ? 0 : null,
		abs($motion->z) <= 0.00001 ? 0 : null
	);
}

/** Living::knockBack() after the resistance roll. */
function knockBack(Vector3 $motion, float $x, float $z, float $force, ?float $verticalLimit) : ?Vector3{
	$f = sqrt($x * $x + $z * $z);
	if($f <= 0){
		return null;
	}
	$f = 1 / $f;
	$motionX = $motion->x / 2;
	$motionY = $motion->y / 2;
	$motionZ = $motion->z / 2;
	$motionX += $x * $f * $force;
	$motionY += $force;
	$motionZ += $z * $f * $force;
	$verticalLimit ??= $force;
	if($motionY > $verticalLimit){
		$motionY = $verticalLimit;
	}
	return new Vector3($motionX, $motionY, $motionZ);
}

function directionVector(float $yaw, float $pitch) : Vector3{
	$y = -sin(deg2rad($pitch));
	$xz = cos(deg2rad($pitch));
	$x = -$xz * sin(deg2rad($yaw));
	$z = $xz * cos(deg2rad($yaw));
	return (new Vector3($x, $y, $z))->normalize();
}

function directionPlane(float $yaw) : Vector2{
	return (new Vector2(-cos(deg2rad($yaw) - M_PI_2), -sin(deg2rad($yaw) - M_PI_2)))->normalize();
}

function horizontalFacing(float $yaw) : int{
	$angle = fmod($yaw, 360);
	if($angle < 0){
		$angle += 360.0;
	}
	if((0 <= $angle && $angle < 45) || (315 <= $angle && $angle < 360)){
		return Facing::SOUTH;
	}
	if(45 <= $angle && $angle < 135){
		return Facing::WEST;
	}
	if(135 <= $angle && $angle < 225){
		return Facing::NORTH;
	}
	return Facing::EAST;
}

function lookAt(Vector3 $eye, Vector3 $target) : array{
	$xDist = $target->x - $eye->x;
	$zDist = $target->z - $eye->z;
	$horizontal = sqrt($xDist ** 2 + $zDist ** 2);
	$vertical = $target->y - $eye->y;
	$pitch = -atan2($vertical, $horizontal) / M_PI * 180;
	$yaw = atan2($zDist, $xDist) / M_PI * 180 - 90;
	if($yaw < 0){
		$yaw += 360.0;
	}
	return [$yaw, $pitch];
}

function motionRotation(Vector3 $motion) : array{
	$horizontalSpeed = sqrt(($motion->x ** 2) + ($motion->z ** 2));
	return [atan2($motion->x, $motion->z) * 180 / M_PI, atan2($motion->y, $horizontalSpeed) * 180 / M_PI];
}

final class FakeEntity{
	public function __construct(public AxisAlignedBB $boundingBox){}
}

/** Inlined overlap filter from World::getNearbyEntities(). */
function nearby(array $entities, AxisAlignedBB $bb, ?object $exclude) : array{
	$nearby = [];
	foreach($entities as $ent){
		$entBB = $ent->boundingBox;
		if(
			$ent !== $exclude &&
			$bb->maxX - $entBB->minX > 0.00001 && $entBB->maxX - $bb->minX > 0.00001 &&
			$bb->maxY - $entBB->minY > 0.00001 && $entBB->maxY - $bb->minY > 0.00001 &&
			$bb->maxZ - $entBB->minZ > 0.00001 && $entBB->maxZ - $bb->minZ > 0.00001
		){
			$nearby[] = $ent;
		}
	}
	return $nearby;
}
