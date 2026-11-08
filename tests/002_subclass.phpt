--TEST--
Vector3 subclasses, overrides, hooks and serialization
--SKIPIF--
<?php if (!extension_loaded('qmath')) die('skip qmath not loaded'); ?>
--FILE--
<?php
declare(strict_types=1);
use quark\math\Vector3;

class World { public function __construct(public string $name) {} }
class Position extends Vector3 {
    public ?World $world = null;
    public function __construct(float|int $x, float|int $y, float|int $z, ?World $world) {
        parent::__construct($x, $y, $z);
        $this->world = $world;
    }
    public static function fromObject(Vector3 $pos, ?World $world) { return new Position($pos->x, $pos->y, $pos->z, $world); }
    public function getSide(int $side, int $step = 1) { return Position::fromObject(parent::getSide($side, $step), $this->world); }
    public function __toString() { return "Position(world=" . ($this->world?->name ?? "null") . ",x=" . $this->x . ",y=" . $this->y . ",z=" . $this->z . ")"; }
    public function equals(Vector3 $v) : bool { return $v instanceof Position ? parent::equals($v) && $v->world === $this->world : parent::equals($v); }
}
class Location extends Position {
    public float $yaw;
    public float $pitch;
    public function __construct(float $x, float $y, float $z, ?World $world, float $yaw, float $pitch) {
        $this->yaw = $yaw;
        $this->pitch = $pitch;
        parent::__construct($x, $y, $z, $world);
    }
}

$w = new World("overworld");
$p = new Position(1, 64, -3, $w);
echo $p, "\n", $p->up(), "\n", get_class($p->down(2)), "\n";
echo get_class($p->add(1, 0, 0)), " ", get_class($p->getSide(5)), "\n";
foreach ($p->sides() as $face => $s) echo $face, ":", get_class($s), " ";
echo "\n";
foreach ($p->sidesAroundAxis(0) as $face => $s) echo $face, " ";
echo "\n", gettype($p->sides()), " ", count($p->sides(2)), "\n";
var_dump($p->equals(new Position(1, 64, -3, $w)), $p->equals(new Position(1, 64, -3, null)), $p->equals(new Vector3(1.0, 64.0, -3.0)));

$l = new Location(0.5, 70, 0.5, $w, 90.0, 10.0);
var_dump($l->x, $l->yaw, (array) $l === ['x' => 0.5, 'y' => 70.0, 'z' => 0.5, 'world' => $w, 'yaw' => 90.0, 'pitch' => 10.0]);
echo $l->distance(new Vector3(0.5, 72, 0.5)), "\n";

$v = unserialize(serialize(new Vector3(1, 2.5, -3)));
var_dump($v, unserialize(serialize($l))->yaw, json_encode(new Vector3(1, 2.5, 3)));
var_export(new Vector3(1, 2, 3.5));
echo "\n";
$c = clone $p;
$c->x = 99;
var_dump($p->x, $c->x, $c->world === $p->world);

// 8.4 subclasses may add hooks to inherited properties, native code must honour them
class Hooked extends Vector3 {
    public float|int $x { get => $this->x * 10; set(float|int $value) { $this->x = $value; } }
}
$h = new Hooked(1, 2, 3);
var_dump($h->x, $h->add(0, 0, 0)->x, $h->distance(new Vector3(0, 2, 3)));
--EXPECT--
Position(world=overworld,x=1,y=64,z=-3)
Position(world=overworld,x=1,y=65,z=-3)
Position
quark\math\Vector3 Position
0:Position 1:Position 2:Position 3:Position 4:Position 5:Position 
2 3 4 5 
array 6
bool(true)
bool(false)
bool(true)
float(0.5)
float(90)
bool(true)
2
object(quark\math\Vector3)#6 (3) {
  ["x"]=>
  int(1)
  ["y"]=>
  float(2.5)
  ["z"]=>
  int(-3)
}
float(90)
string(21) "{"x":1,"y":2.5,"z":3}"
\quark\math\Vector3::__set_state(array(
   'x' => 1,
   'y' => 2,
   'z' => 3.5,
))
int(1)
int(99)
bool(true)
int(10)
int(10)
float(10)
