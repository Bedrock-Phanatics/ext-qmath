# ext-qmath

Native math, geometry, and physics for [Quark](https://github.com/Bedrock-Phanatics/Quark) v6, built with Zig 0.17.1 and [phpz](https://github.com/happystraw/phpz) for PHP 8.4.

Provides native replacements for `pocketmine\math` and `pocketmine\color`, alongside optimized `qmath` APIs for performance-critical operations.

## Features

- Native vectors, bounding boxes, geometry, and colors
- Entity movement and collision resolution
- Voxel, block, and batched raycasting
- Explosion tracing and exposure calculations
- Simplex noise and grid sampling
- Entity overlap queries and motion calculations

## Benchmarks

| Operation | PHP | Native | Speedup |
|---|---:|---:|---:|
| Vector operations | 0.564 µs | 0.273 µs | 2.1x |
| Vector normalization | 1.075 µs | 0.219 µs | 4.9x |
| Bounding box intercept | 2.371 µs | 0.180 µs | 13.2x |
| Entity movement | 51.2 µs | 0.98 µs | 52x |
| Projectile raycasting (batched) | 15.4 µs | 0.22 µs | 70x |
| Explosion exposure | 502 µs | 7.0 µs | 72x |
| Explosion ray tracing | 8541 µs | 400 µs | 21x |
| Noise generation (packed) | 5422 µs | 85 µs | 64x |
| Entity overlap filtering | 65 µs | 25 µs | 2.6x |
| Motion calculations | 0.54 µs | 0.11 µs | 4.8x |

Measured on a Ryzen 5 5500 with PHP 8.4.14 ZTS and a ReleaseFast build. Results compare the PHP implementations against the corresponding native APIs.

## API

```php
use qmath\{CollisionRegion, Collision, Raycast};

$region = new CollisionRegion();
$region->setSection($sx, $sy, $sz, $infos, $boxes);

$result = Collision::move(
    $region, $bb, $dx, $dy, $dz, 0.6, $onGround
);

$hit = Raycast::blocks($region, $start, $end);
```

See [`qmath.stub.php`](qmath.stub.php) for the complete API.

## Behavior Notes

- **Compatibility:** Native math and color classes preserve the original PHP APIs, including properties, inheritance, and serialization.
- **Iteration:** `Vector3::sides()`, `sidesAroundAxis()`, and `VoxelRayTrace` return `Iterator` instead of `Generator`.
- **Method overrides:** Native methods respect overridden `getSide()` implementations. Other internal calls are not virtual.
- **Collision data:** Missing collision data throws `qmath\CollisionDataException` rather than being treated as air.
- **Native memory:** `CollisionRegion`, `ResistanceGrid`, `Simplex`, and `VoxelRayIterator` cannot be serialized or shared between threads.
- **Floating point:** IEEE-strict math is used without fast-math. NaN results remain NaN, although their sign bits may differ.
