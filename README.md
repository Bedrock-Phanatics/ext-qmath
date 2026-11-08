# ext-qmath

Native math, geometry and physics for [Quark](https://github.com/Bedrock-Phanatics/Quark) v6, written in
Zig 0.17.1 with [phpz](https://github.com/happystraw/phpz) for PHP 8.4.

- **Drop-in replacements** for `pocketmine\math\*` ([QuarkMath](https://github.com/Bedrock-Phanatics/QuarkMath))
  and `pocketmine\color\Color`. They have the same names, properties, signatures and results, so existing
  imports, subclasses such as `Position` and `Location`, and serialized data keep working.
- **`qmath\*` APIs** for Quark's hot paths:
  - a sparse `CollisionRegion` and `Collision::move()`, the `Entity::move()` solver
  - swept collision tests
  - voxel and block raycasts, batched raycasts
  - explosion ray tracing and exposure
  - Simplex noise and sampled grids
  - entity overlap filters and motion formulas

Every port is checked against the PHP original by differential tests, and results match bit for bit.
`docs/QUARK_INTEGRATION.md` describes how to adopt each part in Quark.

## Building

You need Zig 0.17.1, PHP 8.4 and its headers. phpz is pinned in `build.zig.zon`.

```sh
# Linux and macOS
zig build -Doptimize=ReleaseSafe -Dphp-include-dir="$(php-config --include-dir)"
# -> modules/qmath.so
```

```powershell
# Windows: use the devel pack that matches your PHP build (TS or NTS)
zig build -Doptimize=ReleaseSafe -Dtarget=native-windows-msvc `
  -Dphp-include-dir=C:\php-devel\include -Dphp-lib-dir=C:\php-devel\lib -Dwindows-zts=true
# -> modules\php_qmath.dll
```

Load it with `extension=qmath` (or a full path) in `php.ini`, then check:

```sh
php -m | grep qmath
php --ri qmath
```

`ReleaseSafe` is recommended for servers. It keeps Zig's runtime safety checks, at about 20% of native time
compared to `ReleaseFast`. Floating-point math is IEEE-strict in every mode, with no fast-math.

## Testing

```sh
zig build test                                   # Zig unit tests for the native core, no PHP needed
zig build run-tests -Dphp-include-dir=...        # PHPT integration tests
QUARKMATH_SRC=../QuarkMath/src PMCOLOR_SRC=../Color/src \
  php tests/diff/run.php --ext=modules/qmath.so  # differential tests against the PHP originals
```

The differential suite runs the same deterministic cases in two processes, one on QuarkMath and
pocketmine/color and one on the extension, and compares every result bit for bit, including int vs float.
Inputs include NaN, ±INF, `PHP_INT_MIN`/`MAX`, negative zero, zero-length rays and invalid facings.

It also compares the qmath APIs with copies of the Quark algorithms they replace:
- `Entity::move()` collision, including the step retry
- `World::getBlockCollisionBoxes()`, including fence overflow
- `Projectile::move()` block and entity passes
- `Explosion::explodeA()` with seeded `mt_rand`
- `Explosion::getExposure()`
- `Simplex` and `Noise` sampling
- the motion formulas and `getNearbyEntities()`

Those comparisons run on random worlds with slabs, stairs, fences, carpets, panes, negative coordinates and chunk borders.

Verified so far: Windows PHP 8.4.14 ZTS (Debug, ReleaseSafe, ReleaseFast) and Linux PHP 8.4.14 ZTS debug build
(Debug, ReleaseSafe). Every run passed the PHPT suite and had 0 differential mismatches over more than 200,000
cases. On the debug PHP build the PHPT suite also passes Zend's memory leak checks. CI runs Linux NTS/ZTS and Windows TS/NTS.

## Benchmarks

`php bench/run.php --ext=...`, timings in µs per operation. "Native classes" runs Quark's PHP code unchanged on
the extension's `pocketmine\math` classes. "Native" uses the qmath API. Measured on a Ryzen 5 5500 with
Windows 11, PHP 8.4.14 ZTS CLI without opcache, and a ReleaseFast build. Runs on this machine vary by up to
about 30%.

| Benchmark | QuarkMath | Native classes | Native | Gain |
|---|---:|---:|---:|---:|
| `Vector3` construct | 0.148 | 0.123 | | 1.2x |
| `add()->multiply()->distanceSquared()` | 0.564 | 0.273 | | 2.1x |
| property reads | 0.052 | 0.053 | | 1.0x |
| `normalize()->floor()->up()` | 1.075 | 0.219 | | 4.9x |
| `AxisAlignedBB::calculateIntercept()` | 2.371 | 0.180 | | 13.2x |
| entity move, dense terrain | 51.2 | 40.2 | 0.98 | 52x |
| projectile block raycast | 15.4 | 5.9 | 0.46 (0.22 batched) | 70x |
| explosion exposure, per entity | 502 | 143 | 7.0 | 72x |
| explosion rays, radius 4 | 8541 | 8969 | 400 | 21x |
| noise chunk 16×128×16 | 5422 | 5235 | 310 (85 packed) | 64x |
| nearby filter, 500 entities | 65 | 67 | 25 | 2.6x |
| motion step | 0.54 | 0.57 | 0.11 | 4.8x |

Filling a region costs PHP time: 0.2–0.5 ms per cell-by-cell build of a 17×13×17 area, or roughly 1 ms per
16³ section in the test helper. It is paid once and reused until something invalidates it.

## API overview

`qmath.stub.php` is the complete, IDE-friendly API. It is never loaded at run time. The short version:

```php
use pocketmine\math\{Vector3, AxisAlignedBB};
use qmath\{CollisionRegion, Collision, Raycast};

$region = new CollisionRegion();
$region->setSection($sx, $sy, $sz, $infos, $boxes);          // or setCell(), fillBox()
$region->missingSections(Collision::queryBox($bb, $dx, $dy, $dz, 0.6));
$result = Collision::move($region, $bb, $dx, $dy, $dz, 0.6, $onGround);
$hit = Raycast::blocks($region, $start, $end);                 // qmath\VoxelHit extends RayTraceResult
```

## Behaviour notes

- `Vector3::sides()`, `sidesAroundAxis()` and `VoxelRayTrace` return `\Iterator` instead of `\Generator`. Code
  that iterates them is unaffected. Zero-length rays still throw only once they are iterated.
- Native methods dispatch to an overridden `getSide()`. Other internal calls are not virtual, which Quark never relies on.
- Missing collision data is never treated as air. Queries that touch unknown cells throw `qmath\CollisionDataException`.
- `CollisionRegion`, `ResistanceGrid`, `Simplex` and `VoxelRayIterator` hold native memory. They cannot be
  serialized or shared between threads, so create them on the thread that uses them. Vectors, boxes and colours
  are plain property objects and copy between threads as before.
- PHP leaves the NaN sign bit unspecified when two NaNs meet. NaN results are still NaN.

## License

LGPL-3.0, like QuarkMath, pocketmine/math and Quark, whose code this ports. phpz is MIT.
