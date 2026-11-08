<?php

// php tests/diff/run.php --ext=modules/php_qmath.dll [--php=php] [--seed=1] [--scale=1]

declare(strict_types=1);

$opt = getopt("", ["ext:", "php::", "seed::", "scale::", "dump::"]);
$php = $opt["php"] ?? PHP_BINARY;
$ext = $opt["ext"] ?? null;
if($ext === null){
	fwrite(STDERR, "--ext is required\n");
	exit(2);
}
$seed = $opt["seed"] ?? "1";
$scale = $opt["scale"] ?? "1";
$main = __DIR__ . "/main.php";

$capture = function(array $cmd) : array{
	$p = proc_open($cmd, [1 => ["pipe", "w"], 2 => ["pipe", "w"]], $pipes);
	$out = stream_get_contents($pipes[1]);
	$err = stream_get_contents($pipes[2]);
	$code = proc_close($p);
	return [$out, $err, $code];
};

[$ref, $refErr, $refCode] = $capture([$php, "-n", "-d", "memory_limit=1G", $main, "ref", $seed, $scale]);
[$got, $gotErr, $gotCode] = $capture([$php, "-n", "-d", "memory_limit=1G", "-d", "extension=$ext", $main, "ext", $seed, $scale]);

if($refCode !== 0 || $gotCode !== 0 || !str_ends_with($ref, "done\n") || !str_ends_with($got, "done\n")){
	fwrite(STDERR, "reference exit $refCode: " . substr($refErr . substr($ref, -2000), 0, 4000) . "\n");
	fwrite(STDERR, "extension exit $gotCode: " . substr($gotErr . substr($got, -2000), 0, 4000) . "\n");
	exit(1);
}

if(isset($opt["dump"])){
	file_put_contents($opt["dump"] . "/ref.txt", $ref);
	file_put_contents($opt["dump"] . "/ext.txt", $got);
}

/** @return array<string, string> */
$parse = function(string $output) : array{
	$cases = [];
	foreach(explode("\n", $output) as $line){
		$at = strpos($line, " => ");
		if($at !== false){
			$cases[substr($line, 0, $at)] = substr($line, $at + 4);
		}
	}
	return $cases;
};
$a = $parse($ref);
$b = $parse($got);
$bad = [];
foreach($a + $b as $key => $_){
	if(($a[$key] ?? null) !== ($b[$key] ?? null)){
		$bad[strtok($key, "#")][] = $key;
	}
}
foreach($bad as $suite => $keys){
	printf("%s: %d mismatches\n", $suite, count($keys));
	foreach(array_slice($keys, 0, 3) as $key){
		echo "  $key\n  - ", substr($a[$key] ?? "<missing>", 0, 500), "\n  + ", substr($b[$key] ?? "<missing>", 0, 500), "\n";
	}
}
$total = array_sum(array_map('count', $bad));
printf("%d cases compared, %d mismatches\n", count($a), $total);
exit($total === 0 ? 0 : 1);
