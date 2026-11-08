<?php

// php bench.php ref|ext [filter]
// ref runs PHP code on QuarkMath. ext runs the same PHP code on the native classes ("php")
// and, where one exists, the native qmath API ("native").

declare(strict_types=1);

namespace qmath\test;

use pocketmine\math\AxisAlignedBB;
use pocketmine\math\Vector3;
use pocketmine\math\VoxelRayTrace;

[, $mode, $filter] = $argv + [null, "ext", ""];
if($mode === "ref"){
	$src = getenv("QUARKMATH_SRC") ?: __DIR__ . "/../../QuarkMath/src";
	foreach(["Axis", "Facing", "Math", "Vector2", "Vector3", "VectorMath", "AxisAlignedBB", "RayTraceResult", "VoxelRayTrace", "Matrix"] as $class){
		require "$src/$class.php";
	}
}
require __DIR__ . "/../tests/diff/lib.php";
require __DIR__ . "/../tests/diff/reference.php";
$native = $mode === "ext";

function bench(string $name, string $variant, int $iterations, callable $fn) : void{
	global $filter;
	if($filter !== "" && !str_contains($name, $filter)){
		return;
	}
	$fn(max(1, intdiv($iterations, 20)));
	$times = [];
	$peak = 0;
	for($r = 0; $r < 5; ++$r){
		gc_collect_cycles();
		memory_reset_peak_usage();
		$base = memory_get_usage();
		$t = hrtime(true);
		$fn($iterations);
		$times[] = (hrtime(true) - $t) / 1e9;
		$peak = max($peak, memory_get_peak_usage() - $base);
	}
	sort($times);
	echo json_encode(["name" => $name, "variant" => $variant, "iterations" => $iterations, "seconds" => $times[2], "peak" => $peak]), "\n";
}

$g = new Gen(7);
$vectors = [];
for($i = 0; $i < 256; ++$i){
	$vectors[] = new Vector3($g->float(-100, 100), $g->float(-100, 100), $g->float(-100, 100));
}
$boxes = [];
for($i = 0; $i < 256; ++$i){
	$boxes[] = entityBoxBench($g);
}

function entityBoxBench(Gen $g) : AxisAlignedBB{
	$x = $g->float(-3, 3);
	$y = $g->float(0, 3);
	$z = $g->float(-3, 3);
	return new AxisAlignedBB($x - 0.3, $y, $z - 0.3, $x + 0.3, $y + 1.8, $z + 0.3);
}

bench("vector3 construct", "php", 1_000_000, function(int $n) : void{
	for($i = 0; $i < $n; ++$i){
		$v = new Vector3($i, $i + 0.5, -$i);
	}
});
bench("vector3 add/multiply/distance", "php", 500_000, function(int $n) use ($vectors) : void{
	$s = 0.0;
	for($i = 0; $i < $n; ++$i){
		$v = $vectors[$i & 255];
		$s += $v->add(1, 2, 3)->multiply(0.5)->distanceSquared($vectors[($i + 1) & 255]);
	}
});
bench("vector3 property reads", "php", 1_000_000, function(int $n) use ($vectors) : void{
	$s = 0.0;
	for($i = 0; $i < $n; ++$i){
		$v = $vectors[$i & 255];
		$s += $v->x + $v->y + $v->z;
	}
});
bench("vector3 normalize/floor/side", "php", 500_000, function(int $n) use ($vectors) : void{
	for($i = 0; $i < $n; ++$i){
		$v = $vectors[$i & 255];
		$v->normalize()->floor()->up();
	}
});
bench("aabb intersectsWith", "php", 1_000_000, function(int $n) use ($boxes) : void{
	$c = 0;
	for($i = 0; $i < $n; ++$i){
		$c += (int) $boxes[$i & 255]->intersectsWith($boxes[($i * 7) & 255]);
	}
});
bench("aabb calculate offsets", "php", 1_000_000, function(int $n) use ($boxes) : void{
	$d = 0.0;
	for($i = 0; $i < $n; ++$i){
		$d += $boxes[$i & 255]->calculateYOffset($boxes[($i * 7) & 255], -0.5);
	}
});
bench("aabb calculateIntercept", "php", 200_000, function(int $n) use ($boxes, $vectors) : void{
	for($i = 0; $i < $n; ++$i){
		$boxes[$i & 255]->calculateIntercept($vectors[$i & 255], $vectors[($i + 3) & 255]);
	}
});

foreach(["sparse" => 1, "dense" => 9] as $label => $seed){
	$wg = new Gen($seed);
	$world = $label === "sparse" ? World::random(new Gen(0), 8) : World::random($wg, 8);
	if($label === "sparse"){
		$world = new World(-8, -6, -8, 8, 6, 8);
		for($x = -8; $x <= 8; ++$x){
			for($z = -8; $z <= 8; ++$z){
				$world->set($x, 0, $z, COLLISION_CUBE, []);
			}
		}
	}
	$moves = [];
	$mg = new Gen(3);
	for($i = 0; $i < 64; ++$i){
		$x = $mg->float(-3, 3);
		$z = $mg->float(-3, 3);
		$moves[] = [new AxisAlignedBB($x - 0.3, 1.0, $z - 0.3, $x + 0.3, 2.8, $z + 0.3), $mg->float(-0.5, 0.5), -0.0784, $mg->float(-0.5, 0.5)];
	}
	bench("entity move $label", "php", 20_000, function(int $n) use ($world, $moves) : void{
		for($i = 0; $i < $n; ++$i){
			[$bb, $dx, $dy, $dz] = $moves[$i & 63];
			move($world, $bb, $dx, $dy, $dz, 0.6, true);
		}
	});
	if($native){
		$region = $world->toRegion();
		bench("entity move $label", "native", 20_000, function(int $n) use ($region, $moves) : void{
			for($i = 0; $i < $n; ++$i){
				[$bb, $dx, $dy, $dz] = $moves[$i & 63];
				\qmath\Collision::move($region, $bb, $dx, $dy, $dz, 0.6, true);
			}
		});
		bench("region build per cell $label", "native", 50, function(int $n) use ($world) : void{
			for($i = 0; $i < $n; ++$i){
				$world->toRegion();
			}
		});
		bench("region build per section $label", "native", 50, function(int $n) use ($world) : void{
			for($i = 0; $i < $n; ++$i){
				$world->toRegionSections();
			}
		});
	}

	$rays = [];
	$rg = new Gen(5);
	for($i = 0; $i < 64; ++$i){
		$rays[] = [new Vector3($rg->float(-6, 6), $rg->float(1, 4), $rg->float(-6, 6)), new Vector3($rg->float(-7, 7), $rg->float(0, 5), $rg->float(-7, 7))];
	}
	bench("projectile block raycast $label", "php", 10_000, function(int $n) use ($world, $rays) : void{
		for($i = 0; $i < $n; ++$i){
			[$s, $e] = $rays[$i & 63];
			projectileBlocks($world, $s, $e);
		}
	});
	if($native){
		bench("projectile block raycast $label", "native", 10_000, function(int $n) use ($region, $rays) : void{
			for($i = 0; $i < $n; ++$i){
				[$s, $e] = $rays[$i & 63];
				\qmath\Raycast::blocks($region, $s, $e);
			}
		});
		$packed = "";
		foreach($rays as [$s, $e]){
			$packed .= pack("e6", $s->x, $s->y, $s->z, $e->x, $e->y, $e->z);
		}
		bench("projectile block raycast $label", "native batch", 10_000, function(int $n) use ($region, $packed) : void{
			for($i = 0; $i < $n; $i += 64){
				\qmath\Raycast::batchBlocks($region, $packed);
			}
		});
	}
	$origin = new Vector3(0.5, 1.5, 0.5);
	$targets = array_slice($boxes, 0, 16);
	bench("explosion exposure $label", "php", 64, function(int $n) use ($world, $origin, $targets) : void{
		for($i = 0; $i < $n; ++$i){
			exposure($world, $origin, $targets[$i & 15]);
		}
	});
	if($native){
		bench("explosion exposure $label", "native", 64, function(int $n) use ($region, $origin, $targets) : void{
			for($i = 0; $i < $n; ++$i){
				\qmath\ExplosionMath::exposure($region, $origin, $targets[$i & 15]);
			}
		});
	}
}

bench("voxel iteration 100 blocks", "php", 5_000, function(int $n) : void{
	$s = new Vector3(0.5, 64.5, 0.5);
	$e = new Vector3(70.3, 30.1, 60.7);
	for($i = 0; $i < $n; ++$i){
		foreach(VoxelRayTrace::betweenPoints($s, $e) as $v){
		}
	}
});

$res = [];
$span = 12;
$eg = new Gen(4);
for($x = -$span; $x <= $span; ++$x){
	for($y = -$span; $y <= $span; ++$y){
		for($z = -$span; $z <= $span; ++$z){
			$res["$x:$y:$z"] = $eg->chance(80) ? 0.0 : 3.0;
		}
	}
}
$source = new Vector3(0.5, 0.5, 0.5);
bench("explosion rays radius 4", "php", 20, function(int $n) use ($res, $source) : void{
	for($i = 0; $i < $n; ++$i){
		explodeA($res, $source, 4.0);
	}
});
if($native){
	$grid = new \qmath\ResistanceGrid(-$span, -$span, -$span, $span, $span, $span);
	foreach($res as $key => $v){
		[$x, $y, $z] = array_map('intval', explode(":", $key));
		$grid->set($x, $y, $z, $v);
	}
	bench("explosion rays radius 4", "native", 20, function(int $n) use ($grid, $source) : void{
		for($i = 0; $i < $n; ++$i){
			\qmath\ExplosionMath::traceRays($grid, $source, 4.0);
		}
	});
}

$perm = range(0, 255);
$ng = new Gen(2);
for($k = 255; $k > 0; --$k){
	$j = $ng->int(0, $k);
	[$perm[$k], $perm[$j]] = [$perm[$j], $perm[$k]];
}
$ref = new RefSimplex(array_merge($perm, $perm), 10.0, 20.0, 30.0, 4, 0.25, 1 / 32);
bench("noise chunk 16x128x16", "php", 10, function(int $n) use ($ref) : void{
	for($i = 0; $i < $n; ++$i){
		$ref->getFastNoise3D(16, 128, 16, 4, 8, 4, $i * 16, 0, 0);
	}
});
if($native){
	$s = new \qmath\Simplex($perm, 10.0, 20.0, 30.0, 4, 0.25, 1 / 32);
	bench("noise chunk 16x128x16", "native", 10, function(int $n) use ($s) : void{
		for($i = 0; $i < $n; ++$i){
			$s->getFastNoise3D(16, 128, 16, 4, 8, 4, $i * 16, 0, 0);
		}
	});
	bench("noise chunk 16x128x16", "native packed", 10, function(int $n) use ($s) : void{
		for($i = 0; $i < $n; ++$i){
			$s->getFastNoise3DPacked(16, 128, 16, 4, 8, 4, $i * 16, 0, 0);
		}
	});
}

$entities = [];
$sg = new Gen(8);
for($i = 0; $i < 500; ++$i){
	$entities[] = new FakeEntity(entityBoxBench($sg));
}
$query = new AxisAlignedBB(-1, 0, -1, 1, 2, 1);
bench("nearby entities filter 500", "php", 2_000, function(int $n) use ($entities, $query) : void{
	for($i = 0; $i < $n; ++$i){
		nearby($entities, $query, null);
	}
});
if($native){
	bench("nearby entities filter 500", "native", 2_000, function(int $n) use ($entities, $query) : void{
		for($i = 0; $i < $n; ++$i){
			\qmath\Spatial::overlapping($entities, $query);
		}
	});
}

bench("motion step", "php", 500_000, function(int $n) use ($vectors) : void{
	for($i = 0; $i < $n; ++$i){
		motionStep($vectors[$i & 255], 0.02, 0.08, true, false, 1.0);
	}
});
if($native){
	bench("motion step", "native", 500_000, function(int $n) use ($vectors) : void{
		for($i = 0; $i < $n; ++$i){
			\qmath\Physics::motionStep($vectors[$i & 255], 0.02, 0.08);
		}
	});
}
