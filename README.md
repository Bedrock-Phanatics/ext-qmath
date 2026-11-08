# ext-qmath

Native math, geometry, and physics for [Quark](https://github.com/Bedrock-Phanatics/Quark) v6, built with Zig 0.17 and [phpz](https://github.com/happystraw/phpz) for PHP 8.4.

Provides Quark's math and color types natively under `quark\math` and `quark\color`, alongside optimized collision, physics, and noise APIs for performance-critical operations.

## Features

- Native vectors, bounding boxes, geometry, and colors
- Entity movement and collision resolution
- Voxel, block, and batched raycasting
- Explosion tracing and exposure calculations
- Simplex noise and grid sampling
- Entity overlap queries and motion calculations

| Namespace | Classes |
|---|---|
| `quark\math` | `Vector2`, `Vector3`, `Axis`, `Facing`, `AxisAlignedBB`, `RayTraceResult`, `Math`, `VectorMath`, `VoxelRayTrace`, `VoxelRayIterator` |
| `quark\math\collision` | `CollisionRegion`, `CollisionSolver`, `MoveResult`, `SweepResult`, `Raycast`, `VoxelHit`, `Spatial`, `CollisionDataException` |
| `quark\math\physics` | `Physics`, `ExplosionMath`, `ResistanceGrid` |
| `quark\math\noise` | `Simplex` |
| `quark\color` | `Color` |

## Benchmarks

| Operation | PHP | Native | Speedup |
|---|---:|---:|---:|
| Vector operations | 0.475 µs | 0.226 µs | 2.1x |
| Vector normalization | 0.956 µs | 0.201 µs | 4.8x |
| Bounding box intercept | 1.954 µs | 0.162 µs | 12x |
| Entity movement | 40.5 µs | 0.78 µs | 52x |
| Projectile raycasting (batched) | 13.6 µs | 0.17 µs | 81x |
| Explosion exposure | 388 µs | 5.9 µs | 65x |
| Explosion ray tracing | 7085 µs | 316 µs | 22x |
| Noise generation (packed) | 4444 µs | 80 µs | 55x |
| Entity overlap filtering | 56 µs | 16 µs | 3.5x |
| Motion calculations | 0.53 µs | 0.08 µs | 6.5x |

Measured on a Ryzen 5 5500 with PHP 8.4.14 ZTS and a ReleaseFast build, using `tests/bench/run.php`. Results compare the PHP implementations against the corresponding native APIs.

## API

```php
use quark\math\collision\{CollisionRegion, CollisionSolver, Raycast};

$region = new CollisionRegion();
// straight from a SubChunk block layer, returns the cells that still need their boxes
$custom = $region->setSectionPalette($sx, $sy, $sz, $layer->getBitsPerBlock(), $layer->getWordArray(), $paletteInfos);

$result = CollisionSolver::move(
    $region, $bb, $dx, $dy, $dz, 0.6, $onGround
);

$hit = Raycast::blocks($region, $start, $end);
```

See [`qmath.stub.php`](qmath.stub.php) for the complete API.

## Behavior Notes

- **Compatibility:** Results match pmmp/Math 1.0 and pocketmine/color bit for bit. Redundant legacy methods such as `Vector3::getX()`, `sidesArray()` and the `RayTraceResult` getters are removed in favour of properties and `sides()`.
- **Inheritance:** `Vector3` stays mutable and subclassable, its declared properties are the only storage. Native methods respect overridden `getSide()` implementations and property hooks. Other internal calls are not virtual.
- **Results:** `RayTraceResult`, `VoxelHit`, `MoveResult`, and `SweepResult` have readonly properties. `Vector3::sides()` and `sidesAroundAxis()` return arrays keyed by facing.
- **Collision data:** Missing collision data throws `CollisionDataException` rather than being treated as air.
- **Native memory:** `CollisionRegion`, `ResistanceGrid`, `Simplex`, and `VoxelRayIterator` cannot be serialized or shared between threads.
- **Floating point:** IEEE-strict math is used without fast-math. NaN results remain NaN, although their sign bits may differ.
