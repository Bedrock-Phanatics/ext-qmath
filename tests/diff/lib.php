<?php

declare(strict_types=1);

namespace qmath\test;

/** Deterministic xorshift so both processes generate identical cases without touching mt_rand. */
final class Gen{
	private int $s;

	public function __construct(int $seed){
		$this->s = $seed ^ 0x5DEECE66D;
		if($this->s === 0){
			$this->s = 1;
		}
	}

	public function next() : int{
		$x = $this->s;
		$x ^= ($x << 13) & PHP_INT_MAX;
		$x ^= $x >> 7;
		$x ^= ($x << 17) & PHP_INT_MAX;
		$this->s = $x & PHP_INT_MAX;
		return $this->s;
	}

	public function int(int $min, int $max) : int{
		return $min + $this->next() % ($max - $min + 1);
	}

	public function float(float $min, float $max) : float{
		return $min + ($this->next() / PHP_INT_MAX) * ($max - $min);
	}

	public function chance(int $percent) : bool{
		return $this->int(1, 100) <= $percent;
	}

	/** @template T @param T[] $items @return T */
	public function pick(array $items) : mixed{
		return $items[$this->int(0, count($items) - 1)];
	}

	/** int|float coordinate including awkward values. */
	public function num() : int|float{
		return match($this->int(0, 9)){
			0 => $this->int(-40, 40),
			1 => $this->pick([0, -0.0, 0.0, 0.5, -0.5, 1, -1, 1e-9, -1e-9, 30000000.5, -30000000.5]),
			2 => $this->pick([PHP_INT_MAX, PHP_INT_MIN, 2 ** 53, -(2 ** 53) - 1, 1e19, -1e19, INF, -INF, NAN, 9.999999999999999]),
			3 => (float) $this->int(-40, 40),
			default => round($this->float(-64, 64), $this->int(0, 6)),
		};
	}

	public function finite() : float{
		return $this->chance(30) ? (float) $this->int(-16, 16) + $this->pick([0.0, 0.5, 0.25, 0.3, 0.7]) : $this->float(-32, 32);
	}
}

/** Canonical, bit-exact encoding of a result. */
function enc(mixed $v, int $depth = 0) : string{
	if($depth > 6){
		return "...";
	}
	if($v === null){
		return "N";
	}
	if(is_bool($v)){
		return $v ? "T" : "F";
	}
	if(is_int($v)){
		return "i" . $v;
	}
	if(is_float($v)){
		// NaN sign and payload bits are unspecified when two NaNs meet, so every NaN compares equal
		return is_nan($v) ? "fNAN" : "f" . bin2hex(pack("e", $v));
	}
	if(is_string($v)){
		return "s" . json_encode($v, JSON_INVALID_UTF8_SUBSTITUTE);
	}
	if(is_array($v)){
		$parts = [];
		foreach($v as $k => $item){
			$parts[] = (is_int($k) ? $k : json_encode($k)) . "=" . enc($item, $depth + 1);
		}
		return "[" . implode(",", $parts) . "]";
	}
	if($v instanceof \Iterator){
		$parts = [];
		$n = 0;
		foreach($v as $k => $item){
			$parts[] = enc($k) . "=" . enc($item, $depth + 1);
			if(++$n > 4096){
				$parts[] = "...";
				break;
			}
		}
		return "it[" . implode(",", $parts) . "]";
	}
	if(is_object($v)){
		$class = get_class($v);
		$parts = [];
		foreach((array) $v as $k => $item){
			$parts[] = str_replace("\0", "|", (string) $k) . "=" . enc($item, $depth + 1);
		}
		return $class . "{" . implode(",", $parts) . "}";
	}
	return gettype($v);
}

/** Runs a case and encodes its result or exception. Type errors only compare their class. */
function run(callable $fn) : string{
	global $qmathWarnings;
	$qmathWarnings = [];
	try{
		$r = enc($fn());
	}catch(\TypeError $e){
		$r = "EX:" . get_class($e);
	}catch(\Throwable $e){
		$r = "EX:" . get_class($e) . ":" . $e->getMessage();
	}
	return count($qmathWarnings) > 0 ? $r . " W:" . implode("|", $qmathWarnings) : $r;
}

function out(string $suite, int $i, string $label, string $result) : void{
	echo $suite, "#", $i, " ", $label, " => ", $result, "\n";
}
