<?php

// Usage: php main.php ref|ext <seed> <scale>
// ref needs QUARKMATH_SRC and PMCOLOR_SRC, ext needs the qmath extension

declare(strict_types=1);

namespace qmath\test;

[, $mode, $seed, $scale] = $argv + [null, "ext", "1", "1"];
if($mode === "ref"){
	if(extension_loaded("qmath")){
		fwrite(STDERR, "the reference run must not load qmath\n");
		exit(2);
	}
	$src = getenv("QUARKMATH_SRC") ?: __DIR__ . "/../../../QuarkMath/src";
	// The PHP originals live in pocketmine\, so alias them to the names the extension registers.
	foreach(["Axis", "Facing", "Math", "Vector2", "Vector3", "VectorMath", "AxisAlignedBB", "RayTraceResult", "VoxelRayTrace"] as $class){
		require "$src/$class.php";
		class_alias("pocketmine\\math\\$class", "quark\\math\\$class");
	}
	require (getenv("PMCOLOR_SRC") ?: __DIR__ . "/../../../Color/src") . "/Color.php";
	class_alias("pocketmine\\color\\Color", "quark\\color\\Color");
}elseif(!extension_loaded("qmath")){
	fwrite(STDERR, "qmath is not loaded\n");
	exit(2);
}

ini_set("precision", "14");
ini_set("serialize_precision", "-1");
$qmathWarnings = [];
set_error_handler(function(int $no, string $str) use (&$qmathWarnings) : bool{
	$GLOBALS["qmathWarnings"][] = $str;
	return true;
});

require __DIR__ . "/lib.php";
require __DIR__ . "/reference.php";
require __DIR__ . "/suites.php";

$k = max(1, (int) $scale);
$g = new Gen((int) $seed);
suiteVector3($g, 120 * $k);
suiteVector2($g, 60 * $k);
suiteAABB($g, 150 * $k);
suiteFacing();
suiteMath($g, 60 * $k);
suiteVoxel($g, 120 * $k);
suiteColor($g, 60 * $k);
suiteCollision($g, 4 * $k, 60);
suiteProjectile($g, 3 * $k, 80);
suiteExposure($g, 2 * $k, 20);
suiteExplosion($g, 6 * $k);
suiteNoise($g, 6 * $k);
suitePhysics($g, 120 * $k);
suiteSpatial($g, 80 * $k);
echo "done\n";
