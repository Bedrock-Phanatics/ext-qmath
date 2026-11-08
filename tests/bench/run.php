<?php

// php tests/bench/run.php --ext=modules/php_qmath.so [--php=php] [--filter=name]
// Needs QUARKMATH_SRC pointing at QuarkMath's src/ for the baseline.

declare(strict_types=1);

$opt = getopt("", ["ext:", "php::", "filter::"]);
$php = $opt["php"] ?? PHP_BINARY;
$ext = $opt["ext"] ?? null;
if($ext === null){
	fwrite(STDERR, "--ext is required\n");
	exit(2);
}
$filter = $opt["filter"] ?? "";

$run = function(array $args) use ($php, $filter) : array{
	$cmd = array_merge([$php, "-n", "-d", "memory_limit=2G", "-d", "opcache.enable_cli=0"], $args, [$filter]);
	$out = shell_exec(implode(" ", array_map('escapeshellarg', $cmd)));
	$rows = [];
	foreach(explode("\n", trim((string) $out)) as $line){
		$r = json_decode($line, true);
		if(is_array($r)){
			$rows[] = $r;
		}else{
			fwrite(STDERR, $line . "\n");
		}
	}
	return $rows;
};

$table = [];
foreach($run([__DIR__ . "/bench.php", "ref"]) as $r){
	$table[$r["name"]]["QuarkMath"] = $r;
}
foreach($run(["-d", "extension=$ext", __DIR__ . "/bench.php", "ext"]) as $r){
	$table[$r["name"]][$r["variant"] === "php" ? "native classes" : $r["variant"]] = $r;
}

$cols = ["QuarkMath", "native classes", "native", "native batch", "native packed"];
printf("%-34s", "benchmark (us per op)");
foreach($cols as $c){
	printf(" %15s", $c);
}
printf(" %9s %12s\n", "best gain", "peak KiB");
foreach($table as $name => $variants){
	printf("%-34s", $name);
	$base = isset($variants["QuarkMath"]) ? $variants["QuarkMath"]["seconds"] / $variants["QuarkMath"]["iterations"] : null;
	$best = null;
	$peak = [];
	foreach($cols as $c){
		if(!isset($variants[$c])){
			printf(" %15s", "-");
			continue;
		}
		$per = $variants[$c]["seconds"] / $variants[$c]["iterations"];
		printf(" %15.3f", $per * 1e6);
		if($c !== "QuarkMath"){
			$best = $best === null ? $per : min($best, $per);
		}
		$peak[] = (int) round($variants[$c]["peak"] / 1024);
	}
	printf(" %8sx %12s\n", $base !== null && $best !== null ? number_format($base / $best, 1) : "-", implode("/", $peak));
}
