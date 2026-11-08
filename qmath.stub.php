<?php

/**
 * @generate-class-entries
 */

namespace pocketmine\math {
    final class Axis
    {
        /** @var int */
        public const Y = 0;
        /** @var int */
        public const Z = 1;
        /** @var int */
        public const X = 2;

        private function __construct() {}

        public static function toString(int $axis): string {}
    }

    final class Facing
    {
        /** @var int */
        public const FLAG_AXIS_POSITIVE = 1;
        /** @var int */
        public const DOWN = 0;
        /** @var int */
        public const UP = 1;
        /** @var int */
        public const NORTH = 2;
        /** @var int */
        public const SOUTH = 3;
        /** @var int */
        public const WEST = 4;
        /** @var int */
        public const EAST = 5;
        /** @var array */
        public const ALL = [0, 1, 2, 3, 4, 5];
        /** @var array */
        public const HORIZONTAL = [2, 3, 4, 5];
        /** @var array */
        public const OFFSET = [[0, -1, 0], [0, 1, 0], [0, 0, -1], [0, 0, 1], [-1, 0, 0], [1, 0, 0]];

        private function __construct() {}

        public static function axis(int $direction): int {}

        public static function isPositive(int $direction): bool {}

        public static function opposite(int $direction): int {}

        public static function rotate(int $direction, int $axis, bool $clockwise): int {}

        public static function rotateY(int $direction, bool $clockwise): int {}

        public static function rotateZ(int $direction, bool $clockwise): int {}

        public static function rotateX(int $direction, bool $clockwise): int {}

        public static function validate(int $facing): void {}

        public static function toString(int $facing): string {}
    }

    final class Math
    {
        private function __construct() {}

        public static function floorFloat(mixed $n): int {}

        public static function ceilFloat(mixed $n): int {}

        public static function solveQuadratic(float $a, float $b, float $c): array {}
    }

    final class VectorMath
    {
        private function __construct() {}

        public static function getDirection2D(float $azimuth): Vector2 {}

        /** Same formula as Entity::getDirectionVector(), angles in degrees. */
        public static function getDirection3D(float $yaw, float $pitch): Vector3 {}
    }

    class Vector2 implements \Stringable
    {
        public float $x;
        public float $y;

        public function __construct(float $x, float $y) {}

        public function getX(): float {}

        public function getY(): float {}

        public function getFloorX(): int {}

        public function getFloorY(): int {}

        public function add(float $x, float $y): Vector2 {}

        public function addVector(Vector2 $vector2): Vector2 {}

        public function subtract(float $x, float $y): Vector2 {}

        public function subtractVector(Vector2 $vector2): Vector2 {}

        public function ceil(): Vector2 {}

        public function floor(): Vector2 {}

        public function round(): Vector2 {}

        public function abs(): Vector2 {}

        public function multiply(float $number): Vector2 {}

        public function divide(float $number): Vector2 {}

        public function distance(Vector2 $pos): float {}

        public function distanceSquared(Vector2 $pos): float {}

        public function length(): float {}

        public function lengthSquared(): float {}

        public function normalize(): Vector2 {}

        public function dot(Vector2 $v): float {}

        public function lerp(Vector2 $to, float $t): Vector2 {}

        public function __toString(): string {}
    }

    class Vector3 implements \Stringable
    {
        public float|int $x;
        public float|int $y;
        public float|int $z;

        public function __construct(float|int $x, float|int $y, float|int $z) {}

        public static function zero(): Vector3 {}

        public function getX(): float|int {}

        public function getY(): float|int {}

        public function getZ(): float|int {}

        public function getFloorX(): int {}

        public function getFloorY(): int {}

        public function getFloorZ(): int {}

        public function add(float|int $x, float|int $y, float|int $z): Vector3 {}

        public function addVector(Vector3 $v): Vector3 {}

        public function subtract(float|int $x, float|int $y, float|int $z): Vector3 {}

        public function subtractVector(Vector3 $v): Vector3 {}

        public function multiply(float $number): Vector3 {}

        public function divide(float $number): Vector3 {}

        public function ceil(): Vector3 {}

        public function floor(): Vector3 {}

        public function round(int $precision = 0, int $mode = PHP_ROUND_HALF_UP): Vector3 {}

        public function abs(): Vector3 {}

        /** @return Vector3 */
        public function getSide(int $side, int $step = 1) {}

        /** @return Vector3 */
        public function down(int $step = 1) {}

        /** @return Vector3 */
        public function up(int $step = 1) {}

        /** @return Vector3 */
        public function north(int $step = 1) {}

        /** @return Vector3 */
        public function south(int $step = 1) {}

        /** @return Vector3 */
        public function west(int $step = 1) {}

        /** @return Vector3 */
        public function east(int $step = 1) {}

        /** @return \Iterator<int, Vector3> */
        public function sides(int $step = 1): \Iterator {}

        /** @return array<int, Vector3> */
        public function sidesArray(bool $keys = false, int $step = 1): array {}

        /** @return \Iterator<int, Vector3> */
        public function sidesAroundAxis(int $axis, int $step = 1): \Iterator {}

        public function asVector3(): Vector3 {}

        public function distance(Vector3 $pos): float {}

        public function distanceSquared(Vector3 $pos): float {}

        public function maxPlainDistance(Vector3|Vector2|float $x, float $z = 0): float {}

        public function length(): float {}

        public function lengthSquared(): float {}

        public function normalize(): Vector3 {}

        public function dot(Vector3 $v): float {}

        public function cross(Vector3 $v): Vector3 {}

        public function equals(Vector3 $v): bool {}

        public function getIntermediateWithXValue(Vector3 $v, float $x): ?Vector3 {}

        public function getIntermediateWithYValue(Vector3 $v, float $y): ?Vector3 {}

        public function getIntermediateWithZValue(Vector3 $v, float $z): ?Vector3 {}

        public function __toString(): string {}

        public function withComponents(float|int|null $x, float|int|null $y, float|int|null $z): Vector3 {}

        public static function maxComponents(Vector3 $vector, Vector3 ...$vectors): Vector3 {}

        public static function minComponents(Vector3 $vector, Vector3 ...$vectors): Vector3 {}

        public static function sum(Vector3 ...$vector3s): Vector3 {}

        public function lerp(Vector3 $to, float $t): Vector3 {}

        /** Returns null instead of a zero vector when the length is zero or not finite. */
        public function normalizeOrNull(): ?Vector3 {}

        public function project(Vector3 $onto): Vector3 {}

        public function reject(Vector3 $from): Vector3 {}

        public function reflect(Vector3 $normal): Vector3 {}

        /** Angle between the two vectors in radians, 0 when either is zero-length. */
        public function angle(Vector3 $v): float {}

        public function clamp(Vector3 $min, Vector3 $max): Vector3 {}

        public function moveTowards(Vector3 $target, float $maxDistance): Vector3 {}

        public function isFinite(): bool {}
    }

    class RayTraceResult
    {
        public AxisAlignedBB $bb;
        public int $hitFace;
        public Vector3 $hitVector;

        public function __construct(AxisAlignedBB $bb, int $hitFace, Vector3 $hitVector) {}

        public function getBoundingBox(): AxisAlignedBB {}

        public function getHitFace(): int {}

        public function getHitVector(): Vector3 {}
    }

    final class AxisAlignedBB implements \Stringable
    {
        public float $minX;
        public float $minY;
        public float $minZ;
        public float $maxX;
        public float $maxY;
        public float $maxZ;

        public function __construct(float $minX, float $minY, float $minZ, float $maxX, float $maxY, float $maxZ) {}

        public function addCoord(float $x, float $y, float $z): AxisAlignedBB {}

        public function expand(float $x, float $y, float $z): AxisAlignedBB {}

        public function expandedCopy(float $x, float $y, float $z): AxisAlignedBB {}

        public function offset(float $x, float $y, float $z): AxisAlignedBB {}

        public function offsetCopy(float $x, float $y, float $z): AxisAlignedBB {}

        public function offsetTowards(int $face, float $distance): AxisAlignedBB {}

        public function offsetTowardsCopy(int $face, float $distance): AxisAlignedBB {}

        public function contract(float $x, float $y, float $z): AxisAlignedBB {}

        public function contractedCopy(float $x, float $y, float $z): AxisAlignedBB {}

        public function extend(int $face, float $distance): AxisAlignedBB {}

        public function extendedCopy(int $face, float $distance): AxisAlignedBB {}

        public function trim(int $face, float $distance): AxisAlignedBB {}

        public function trimmedCopy(int $face, float $distance): AxisAlignedBB {}

        public function stretch(int $axis, float $distance): AxisAlignedBB {}

        public function stretchedCopy(int $axis, float $distance): AxisAlignedBB {}

        public function squash(int $axis, float $distance): AxisAlignedBB {}

        public function squashedCopy(int $axis, float $distance): AxisAlignedBB {}

        public function calculateXOffset(AxisAlignedBB $bb, float $x): float {}

        public function calculateYOffset(AxisAlignedBB $bb, float $y): float {}

        public function calculateZOffset(AxisAlignedBB $bb, float $z): float {}

        public function intersectsWith(AxisAlignedBB $bb, float $epsilon = 0.00001): bool {}

        public function isVectorInside(Vector3 $vector): bool {}

        public function getAverageEdgeLength(): float {}

        public function getXLength(): float {}

        public function getYLength(): float {}

        public function getZLength(): float {}

        public function isCube(float $epsilon = 0.000001): bool {}

        public function getVolume(): float {}

        public function isVectorInYZ(Vector3 $vector): bool {}

        public function isVectorInXZ(Vector3 $vector): bool {}

        public function isVectorInXY(Vector3 $vector): bool {}

        public function calculateIntercept(Vector3 $pos1, Vector3 $pos2): ?RayTraceResult {}

        public function __toString(): string {}

        public static function one(): AxisAlignedBB {}

        public function getCenter(): Vector3 {}

        public function closestPoint(Vector3 $point): Vector3 {}

        public function distanceSquaredTo(Vector3 $point): float {}

        public function intersectsSphere(Vector3 $center, float $radius): bool {}

        public function intersectsSegment(Vector3 $start, Vector3 $end): bool {}

        public function union(AxisAlignedBB $bb): AxisAlignedBB {}

        public function isFinite(): bool {}
    }

    final class VoxelRayTrace
    {
        private function __construct() {}

        /** @return \Iterator<int, Vector3> */
        public static function inDirection(Vector3 $start, Vector3 $directionVector, float $maxDistance): \Iterator {}

        /** @return \Iterator<int, Vector3> */
        public static function betweenPoints(Vector3 $start, Vector3 $end): \Iterator {}
    }

    class Matrix implements \ArrayAccess
    {
        private array $matrix = [];
        private int $rows;
        private int $columns;

        public function offsetExists(mixed $offset): bool {}

        public function offsetGet(mixed $offset): mixed {}

        public function offsetSet(mixed $offset, mixed $value): void {}

        public function offsetUnset(mixed $offset): void {}

        public function __construct(int $rows, int $columns, array $set = []) {}

        public function set(array $m): void {}

        public function getRows(): int {}

        public function getColumns(): int {}

        public function setElement(int $row, int $column, float $value): void {}

        public function getElement(int $row, int $column): float {}

        public function isSquare(): bool {}

        public function add(Matrix $matrix): Matrix {}

        public function subtract(Matrix $matrix): Matrix {}

        public function multiplyScalar(float $number): Matrix {}

        public function divideScalar(float $number): Matrix {}

        public function transpose(): Matrix {}

        public function product(Matrix $matrix): Matrix {}

        public function determinant(): float {}

        public function __toString(): string {}
    }
}

namespace pocketmine\color {
    final class Color
    {
        private int $a;
        private int $r;
        private int $g;
        private int $b;

        public function __construct(int $r, int $g, int $b, int $a = 0xff) {}

        public function getA(): int {}

        public function getR(): int {}

        public function getG(): int {}

        public function getB(): int {}

        public static function mix(Color $color1, Color ...$colors): Color {}

        public static function fromRGB(int $code): Color {}

        public static function fromARGB(int $code): Color {}

        public function toARGB(): int {}

        public static function fromRGBA(int $code): Color {}

        public function toRGBA(): int {}

        public function equals(Color $other): bool {}

        public function toRGB(): int {}

        /** Linear interpolation per channel, $t is clamped to [0, 1]. */
        public function lerp(Color $to, float $t): Color {}

        /** Source-over alpha compositing of $over on top of this colour. */
        public function blend(Color $over): Color {}

        /** @return array{float, float, float} hue in degrees, saturation and value in [0, 1] */
        public function toHSV(): array {}

        public static function fromHSV(float $hue, float $saturation, float $value, int $a = 0xff): Color {}

        /** @return array{float, float, float} hue in degrees, saturation and lightness in [0, 1] */
        public function toHSL(): array {}

        public static function fromHSL(float $hue, float $saturation, float $lightness, int $a = 0xff): Color {}
    }
}

namespace qmath {

    /** Thrown when a native query needs collision or grid data that was never provided. */
    class CollisionDataException extends \RuntimeException {}

    /** Sparse block collision data in 16x16x16 sections. Queries touching an unknown cell throw. */
    final class CollisionRegion
    {
        /** @var int */
        public const INFO_CUSTOM = 0;
        /** @var int */
        public const INFO_CUBE = 1;
        /** @var int */
        public const INFO_NONE = 2;
        /** @var int */
        public const INFO_MAY_OVERFLOW = 3;
        /** @var int */
        public const MAX_BOXES_PER_CELL = 64;

        /** @param int $maxSections upper bound on stored sections, about 16 KiB each once they hold mixed cells */
        public function __construct(int $maxSections = 16384) {}

        public function getVersion(): int {}

        public function getSectionCount(): int {}

        public function isFrozen(): bool {}

        public function freeze(): void {}

        public function snapshot(): CollisionRegion {}

        public function isKnown(int $x, int $y, int $z): bool {}

        /** @param list<\pocketmine\math\AxisAlignedBB> $boxes the block's own collision boxes in world coordinates */
        public function setCell(int $x, int $y, int $z, int $info, array $boxes = []): void {}

        /** @param string $boxes six little-endian doubles per box, pack("e*") */
        public function setCellPacked(int $x, int $y, int $z, int $info, string $boxes): void {}

        /**
         * Replaces a chunk section.
         * @param string $infos 4096 collision info bytes indexed (x << 8) | (z << 4) | y, like SubChunk
         * @param array<int, array|string> $boxes AxisAlignedBB lists or packed boxes of custom and may-overflow cells, by the same index
         */
        public function setSection(int $sectionX, int $sectionY, int $sectionZ, string $infos, array $boxes = []): void {}

        /** Marks every cell of an inclusive box as INFO_NONE or INFO_CUBE. */
        public function fillBox(int $minX, int $minY, int $minZ, int $maxX, int $maxY, int $maxZ, int $info): void {}

        /**
         * Sections a query could read that are missing or contain unknown cells, so they can be filled first.
         * @return list<int> flat section x, y, z triples
         */
        public function missingSections(\pocketmine\math\AxisAlignedBB $bb): array {}

        public function invalidateCell(int $x, int $y, int $z): void {}

        /** Invalidates a changed block and its six neighbours, like World's collision cache. */
        public function invalidateBlock(int $x, int $y, int $z): void {}

        public function invalidateSection(int $sectionX, int $sectionY, int $sectionZ): void {}

        public function invalidateChunk(int $chunkX, int $chunkZ): void {}

        public function invalidateAll(): void {}

        /** Whether every cell needed by getCollisionBoxes() for this box is known. */
        public function isComplete(\pocketmine\math\AxisAlignedBB $bb): bool {}

        /** @return list<\pocketmine\math\AxisAlignedBB> same boxes and order as World::getBlockCollisionBoxes() */
        public function getCollisionBoxes(\pocketmine\math\AxisAlignedBB $bb): array {}

        public function collides(\pocketmine\math\AxisAlignedBB $bb): bool {}

        /** @return list<\pocketmine\math\AxisAlignedBB> */
        public function getCellBoxes(int $x, int $y, int $z): array {}

        public function getCellInfo(int $x, int $y, int $z): int {}
    }

    final class MoveResult
    {
        public readonly float $dx;
        public readonly float $dy;
        public readonly float $dz;
        public readonly \pocketmine\math\AxisAlignedBB $boundingBox;
        public readonly bool $collidedX;
        public readonly bool $collidedY;
        public readonly bool $collidedZ;
        public readonly bool $collidedHorizontally;
        public readonly bool $collidedVertically;
        public readonly bool $onGround;
        public readonly bool $stepped;

        private function __construct() {}
    }

    final class SweepResult
    {
        public readonly float $time;
        public readonly int $face;
        public readonly \pocketmine\math\AxisAlignedBB $box;
        public readonly int|string $key;

        private function __construct() {}
    }

    final class Collision
    {
        private function __construct() {}

        /** Entity::move() collision resolution: Y, X, Z clipping with step-height retry. */
        public static function move(CollisionRegion $region, \pocketmine\math\AxisAlignedBB $bb, float $dx, float $dy, float $dz, float $stepHeight = 0.0, bool $onGround = false): MoveResult {}

        public static function sweep(CollisionRegion $region, \pocketmine\math\AxisAlignedBB $bb, float $dx, float $dy, float $dz): ?SweepResult {}

        /** The smallest box covering every query move() can make, for CollisionRegion::missingSections(). */
        public static function queryBox(\pocketmine\math\AxisAlignedBB $bb, float $dx, float $dy, float $dz, float $stepHeight = 0.0): \pocketmine\math\AxisAlignedBB {}

        /** @param array<int|string, \pocketmine\math\AxisAlignedBB> $boxes */
        public static function sweepBoxes(\pocketmine\math\AxisAlignedBB $bb, float $dx, float $dy, float $dz, array $boxes): ?SweepResult {}
    }

    final class VoxelHit extends \pocketmine\math\RayTraceResult
    {
        public int $blockX;
        public int $blockY;
        public int $blockZ;

        public function __construct(\pocketmine\math\AxisAlignedBB $bb, int $hitFace, \pocketmine\math\Vector3 $hitVector, int $blockX, int $blockY, int $blockZ) {}
    }

    final class VoxelRayIterator implements \Iterator
    {
        private function __construct() {}

        public function current(): ?\pocketmine\math\Vector3 {}

        public function key(): ?int {}

        public function next(): void {}

        public function rewind(): void {}

        public function valid(): bool {}
    }

    final class Raycast
    {
        private function __construct() {}

        /** @return list<int> flat x, y, z triples in VoxelRayTrace order */
        public static function voxels(\pocketmine\math\Vector3 $start, \pocketmine\math\Vector3 $end, int $limit = 4096): array {}

        /** Projectile::move() block pass: first voxel whose own collision boxes intercept the segment. */
        public static function blocks(CollisionRegion $region, \pocketmine\math\Vector3 $start, \pocketmine\math\Vector3 $end): ?VoxelHit {}

        public static function lineOfSight(CollisionRegion $region, \pocketmine\math\Vector3 $start, \pocketmine\math\Vector3 $end): bool {}

        /**
         * Nearest intercept against a list of boxes, shortening the segment after each hit like Projectile::move().
         * @param array<int|string, \pocketmine\math\AxisAlignedBB> $boxes
         * @return array{int|string, \pocketmine\math\RayTraceResult}|null
         */
        public static function boxes(\pocketmine\math\Vector3 $start, \pocketmine\math\Vector3 $end, array $boxes, float $expand = 0.0): ?array {}

        /**
         * @param string $segments six little-endian doubles per segment: start xyz, end xyz
         * @return string one 56 byte record per segment, unpack("q4e3"): face (-1 for no hit), block xyz, hit xyz
         */
        public static function batchBlocks(CollisionRegion $region, string $segments): string {}
    }

    final class ResistanceGrid
    {
        public function __construct(int $minX, int $minY, int $minZ, int $maxX, int $maxY, int $maxZ) {}

        /** @return array{int, int, int, int, int, int} */
        public function getBounds(): array {}

        public function set(int $x, int $y, int $z, float $resistance): void {}

        /** Marks a cell the explosion cannot reach, like an unloaded chunk or a position outside the world. */
        public function setInvalid(int $x, int $y, int $z): void {}

        public function fill(float $resistance): void {}

        /** @param string $values little-endian doubles with y varying fastest, then z, then x. NAN marks an invalid cell. */
        public function setPacked(string $values): void {}
    }

    final class ExplosionMath
    {
        private function __construct() {}

        /** @return list<int> flat x, y, z triples of cells reached with force left, first-seen order, no duplicates */
        public static function traceRays(ResistanceGrid $grid, \pocketmine\math\Vector3 $source, float $radius, int $rays = 16, float $stepLen = 0.3): array {}

        /**
         * One ray of Explosion::explodeA(), identified by its loop indices. Consumes one mt_rand() call.
         * @return list<int> flat x, y, z triples of cells reached with force left
         */
        public static function traceRay(ResistanceGrid $grid, \pocketmine\math\Vector3 $source, float $radius, int $i, int $j, int $k, int $rays = 16, float $stepLen = 0.3): array {}

        public static function rayCount(int $rays = 16): int {}

        public static function exposure(CollisionRegion $region, \pocketmine\math\Vector3 $origin, \pocketmine\math\AxisAlignedBB $bb): float {}

        /**
         * @param array<int|string, \pocketmine\math\AxisAlignedBB> $boxes
         * @return array<int|string, float> keys preserved
         */
        public static function exposures(CollisionRegion $region, \pocketmine\math\Vector3 $origin, array $boxes): array {}
    }

    final class Simplex
    {
        /** @param array|string $permutation 256 or 512 entries, or a 256 or 512 byte string */
        public function __construct(array|string $permutation, float $offsetX, float $offsetY, float $offsetZ, int $octaves, float $persistence, float $expansion) {}

        public function getNoise2D(float $x, float $y): float {}

        public function getNoise3D(float $x, float $y, float $z): float {}

        public function noise2D(float $x, float $z, bool $normalized = false): float {}

        public function noise3D(float $x, float $y, float $z, bool $normalized = false): float {}

        /** @return list<float> */
        public function getFastNoise1D(int $xSize, int $samplingRate, int $x, int $y, int $z): array {}

        /** @return list<list<float>> */
        public function getFastNoise2D(int $xSize, int $zSize, int $samplingRate, int $x, int $y, int $z): array {}

        /** @return list<list<list<float|int>>> indexed [x][z][y] */
        public function getFastNoise3D(int $xSize, int $ySize, int $zSize, int $xSamplingRate, int $ySamplingRate, int $zSamplingRate, int $x, int $y, int $z): array {}

        /** Same values as getFastNoise3D() as little-endian doubles in [x][z][y] order. */
        public function getFastNoise3DPacked(int $xSize, int $ySize, int $zSize, int $xSamplingRate, int $ySamplingRate, int $zSamplingRate, int $x, int $y, int $z): string {}
    }

    final class Spatial
    {
        private function __construct() {}

        /**
         * World::getNearbyEntities() overlap filter over objects with a public \pocketmine\math\AxisAlignedBB property.
         * @param array<int|string, object> $objects
         * @return list<object>
         */
        public static function overlapping(array $objects, \pocketmine\math\AxisAlignedBB $bb, ?object $exclude = null, string $property = "boundingBox", float $epsilon = 0.00001): array {}

        /**
         * @param array<int|string, \pocketmine\math\AxisAlignedBB> $boxes
         * @return list<int|string> keys of the overlapping boxes
         */
        public static function overlappingBoxes(\pocketmine\math\AxisAlignedBB $bb, array $boxes, float $epsilon = 0.00001): array {}
    }

    final class Physics
    {
        private function __construct() {}

        /** Entity::tryChangeMovement() then the MOTION_THRESHOLD clamp. $groundFriction is 1.0 when airborne. */
        public static function motionStep(\pocketmine\math\Vector3 $motion, float $drag, float $gravity, bool $gravityEnabled = true, bool $dragBeforeGravity = false, float $groundFriction = 1.0, float $threshold = 0.00001): \pocketmine\math\Vector3 {}

        /** Living::knockBack() motion without the resistance roll, null when the direction is zero. */
        public static function knockBack(\pocketmine\math\Vector3 $motion, float $x, float $z, float $force = 0.4, ?float $verticalLimit = 0.4): ?\pocketmine\math\Vector3 {}

        public static function directionPlane(float $yaw): \pocketmine\math\Vector2 {}

        public static function horizontalFacing(float $yaw): int {}

        /** @return array{float, float} yaw and pitch in degrees, Living::lookAt() convention */
        public static function lookAt(\pocketmine\math\Vector3 $eye, \pocketmine\math\Vector3 $target): array {}

        /** @return array{float, float} yaw and pitch for a projectile moving along $motion */
        public static function motionRotation(\pocketmine\math\Vector3 $motion): array {}

        /**
         * Positions after each tick of free flight with no collisions.
         * @return string little-endian doubles, three per tick
         */
        public static function predictTrajectory(\pocketmine\math\Vector3 $position, \pocketmine\math\Vector3 $motion, float $drag, float $gravity, int $ticks, bool $dragBeforeGravity = false): string {}
    }
}
