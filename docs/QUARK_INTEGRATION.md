# Integrating ext-qmath into Quark v6

This is the plan for moving Quark onto ext-qmath. Nothing in Quark has been changed yet. Line numbers refer to
Quark `v6.0.0` (commit `5fe7a30`).

ext-qmath does two separate things:

1. It defines `pocketmine\math\*` and `pocketmine\color\Color` natively. They are drop-in replacements for the
   PHP packages, so the 439 Quark files that import `pocketmine\math` and the 22 that import `Color` stay as they are.
2. It adds `qmath\*` APIs for the hot paths: block collision, projectile raycasts, explosions, noise, entity
   overlap filters and motion formulas. Quark has to opt into these one call site at a time.

Everything is single-threaded per PHP thread. Nothing in ext-qmath holds a reference to a World, Block or Entity.

## 1. Replacing pocketmine/math (QuarkMath) and pocketmine/color

`composer.lock` currently pins `pocketmine/math 1.0.0` (pmmp/Math) and `pocketmine/color 0.3.1`. ext-qmath
follows the `stable` branch of QuarkMath, which differs from 1.0.0 only in a few internal expressions (`$x * $x`
instead of `$x ** 2`, `=== 0.0` instead of `== 0`). The differential suite reports 0 mismatches against both
QuarkMath `stable` and pmmp/Math `1.0.0`.

### composer.json

```json
"require": {
    "ext-qmath": "^0.1.0"
},
"replace": {
    "pocketmine/math": "1.0.0",
    "pocketmine/color": "0.3.1"
}
```

Remove `pocketmine/math` and `pocketmine/color` from `require`. `replace` stops Composer from installing the
PHP copies, and still satisfies dependencies such as the protocol library that require them. Even if the PHP
copies were installed, the autoloader would never load them, because the classes already exist.

### Startup check

Add `"qmath" => "qmath"` to the required extension list in `src/Quark.php` (around line 124), and
`"qmath" => ["0.1.0", "0.2.0"]` to the version table (around line 160).

### PHPStan

Copy `qmath.stub.php` to `tests/phpstan/stubs/qmath.stub` and list it under both `scanFiles` and `stubFiles`
in `phpstan.neon.dist`. That way analysis works even when the extension is not loaded.

### What stays exactly the same

- Class names, constants (including `Facing::ALL`, `HORIZONTAL`, `OFFSET`), method signatures, `final` flags,
  and the int/float type of every result. Arithmetic overflows from int to float exactly like PHP.
- State lives in the declared properties `x`, `y`, `z`, `minX`…`maxZ`, and Color's private `a`, `r`, `g`,
  `b`. Mutation, `clone`, `serialize`, `var_export`, `json_encode` and `(array)` casts behave as before. Data
  serialized by the old classes unserializes into the new ones.
- `Position` and `Location` keep extending `Vector3`. `up()`, `down()`, `north()`, `south()`, `west()`,
  `east()`, `sides()`, `sidesArray()` and `sidesAroundAxis()` call the subclass's `getSide()`, so
  `Position::up()` still returns a `Position`. Subclasses that add PHP 8.4 hooks to `x`, `y` or `z` are honoured.
- pmmpthread copies these objects between threads like any other property-only object.

### What changes

| Item | Before | After | Quark impact |
|---|---|---|---|
| `Vector3::sides()`, `sidesAroundAxis()` | `\Generator` | `\Iterator` (an `ArrayIterator`) | All 7 call sites use `foreach`. None needed |
| `VoxelRayTrace::betweenPoints()`, `inDirection()` | `\Generator` | `\Iterator` (`qmath\VoxelRayIterator`, lazy) | All 5 call sites use `foreach`. None needed |
| Internal virtual calls | `subtract()` calls `$this->add()`, etc. | Only `getSide()` is dispatched virtually | Quark only overrides `getSide`, `equals` and `__toString`. None needed |
| Lazy objects | allowed | PHP forbids lazy instances of internal classes and their subclasses | Quark does not use them |
| NaN bit patterns | | Same NaN/non-NaN results. The sign bit is kept for `-$x` | None |

`Matrix` is ported with the same array-backed storage, warnings and errors. Quark does not use it.

## 2. Entity::move() on the native collision solver

`qmath\Collision::move()` is the collision half of `Entity::move()`:
- the Y, X, Z clipping
- the `stepHeight` retry and its `($cx ** 2 + $cz ** 2) >= ($dx ** 2 + $dz ** 2)` comparison
- the flags `checkGroundState()` derives

It returns the accepted `dx`, `dy`, `dz`, the new bounding box, the collision flags, and whether the step-up
was taken. Over 90,000 differential cases it matches the PHP implementation bit for bit.

### 2.1 World owns a CollisionRegion

The region stores what `World::getBlockCollisionBoxesForCell()` reads: each cell's collision info
(`RuntimeBlockStateRegistry::COLLISION_*`, same values) and the block's own `getCollisionBoxes()`. Overflow
boxes from neighbouring fences and walls are worked out at query time, exactly as World does. Data is stored per
16³ chunk section. Uniform sections (all air or all full cubes) cost a few bytes. Mixed sections cost about 16 KiB.

```php
// World
private \qmath\CollisionRegion $collisionRegion;

// constructor
$this->collisionRegion = new \qmath\CollisionRegion(maxSections: 32768);

/** Makes sure every section a query box can touch is loaded into the region. */
public function prepareCollision(AxisAlignedBB $query) : \qmath\CollisionRegion{
	$missing = $this->collisionRegion->missingSections($query);
	for($i = 0, $n = count($missing); $i < $n; $i += 3){
		$this->exportCollisionSection($missing[$i], $missing[$i + 1], $missing[$i + 2]);
	}
	return $this->collisionRegion;
}

private function exportCollisionSection(int $sx, int $sy, int $sz) : void{
	$collisionInfo = $this->blockStateRegistry->collisionInfo;
	$infos = str_repeat(chr(RuntimeBlockStateRegistry::COLLISION_NONE), 4096);
	$boxes = [];
	for($lx = 0; $lx < 16; ++$lx){
		for($lz = 0; $lz < 16; ++$lz){
			for($ly = 0; $ly < 16; ++$ly){
				$x = ($sx << 4) | $lx;
				$y = ($sy << 4) | $ly;
				$z = ($sz << 4) | $lz;
				$info = $this->getBlockCollisionInfo($x, $y, $z, $collisionInfo); // NONE outside the world or in unloaded chunks
				$index = ($lx << 8) | ($lz << 4) | $ly;
				$infos[$index] = chr($info);
				if($info === RuntimeBlockStateRegistry::COLLISION_CUSTOM || $info === RuntimeBlockStateRegistry::COLLISION_MAY_OVERFLOW){
					$boxes[$index] = $this->getBlockAt($x, $y, $z)->getCollisionBoxes();
				}
			}
		}
	}
	$this->collisionRegion->setSection($sx, $sy, $sz, $infos, $boxes);
}
```

Exporting a section costs about 0.5–1 ms of PHP time, roughly the cost of 25 PHP moves. It is paid once per section and
then reused by every entity until something invalidates it. For a cheaper export, read the SubChunk's palette
and map palette entries through `collisionInfo` instead of calling `getBlockCollisionInfo()` 4096 times.

### 2.2 Invalidation hooks

Every place that touches `$this->blockCollisionBoxCache` needs the matching region call. If one is missed,
entities collide with stale geometry, so this is the main risk of the integration.

| World code (v6.0.0) | Region call |
|---|---|
| `setBlockAt()`, lines 2536–2547 (the block and its six neighbours) | `$this->collisionRegion->invalidateBlock($x, $y, $z)` |
| `setChunk()`, line 3186 | `$this->collisionRegion->invalidateChunk($chunkX, $chunkZ)` |
| chunk load/upgrade, line 3519 | `invalidateChunk($x, $z)` |
| `unloadChunk()`, line 3697 | `invalidateChunk($x, $z)` |
| `clearCache(true)`, line 1408, and the size cap at line 1426 | `invalidateAll()`. Optionally cap with `getSectionCount()` |
| `onUnload()`, line 756 | drop the region |

Any other code that changes a block's collision shape without `setBlockAt()` must call `invalidateBlock()`
itself. Examples are plugin blocks whose boxes depend on tile data, and anything that writes chunk data
directly. Sections exported while a chunk was unloaded read as air, just as `getBlockCollisionInfo()` reports,
and are replaced by the `invalidateChunk()` call when the chunk loads.

`getVersion()` increases on every mutation if you want to cache derived data. A frozen `snapshot()` gives a
read-only copy.

### 2.3 Entity::move()

Replace the block from `$moveBB = clone $this->boundingBox;` to `$this->boundingBox = $moveBB;` (lines 1269–1344):

```php
$stepHeight = $this->getStepHeight();
$region = $this->getWorld()->prepareCollision(Collision::queryBox($this->boundingBox, $dx, $dy, $dz, $stepHeight));
$result = Collision::move($region, $this->boundingBox, $dx, $dy, $dz, $stepHeight, $this->onGround);
$dx = $result->dx;
$dy = $result->dy;
$dz = $result->dz;
if($result->stepped){
	$this->ySize += $dy;
}
$this->boundingBox = $result->boundingBox;
```

The `keepMovement` branch, `ySize *= STEP_CLIP_MULTIPLIER`, the `assert()`, the Location update,
`checkBlockIntersections()`, `checkGroundState()`, `updateFallState()` and the motion reset all stay as they are.
`moveByPiston()` goes through `move()` and benefits automatically. `Collision::move()` rejects non-finite input
with `ValueError`, and throws `CollisionDataException` if a needed section was not prepared. It never assumes air.

`World::getBlockCollisionBoxes()` can return `$this->prepareCollision($bb)->getCollisionBoxes($bb)` for other
callers. The result has the same boxes, order and duplicates. `World::getCollisionBoxes()` and
`Entity::checkObstruction()` then benefit without further changes.

**Benefit:** the collision part of a move drops from 24–51 µs to 0.7–1.0 µs (bench `entity move`, sparse and dense).
**Validation:** add a debug flag that runs both the PHP path and `Collision::move()` and logs any difference in
`dx`, `dy`, `dz`, the bounding box or the flags. Soak it on a busy server: stairs, slabs, fences, walls,
scaffolding, honey, chunk borders, negative coordinates. Then switch. `tests/diff` is the offline version of
that check.

**Continuous collision:** `Collision::sweep()` and `sweepBoxes()` return time of impact and the hit face. Use them for
anti-cheat or fast custom entities. They are not a replacement for Minecraft's axis clipping, which the client
also uses, and the axis clipping cannot tunnel through static boxes at any speed anyway.

## 3. Projectile::move()

Block pass (lines 176–186). Only use it when the projectile class does not override
`calculateInterceptWithBlock()`. IceBomb does, because it treats water as a full block, so it must keep the PHP loop:

```php
$path = new AxisAlignedBB(min($start->x, $end->x), min($start->y, $end->y), min($start->z, $end->z), max($start->x, $end->x), max($start->y, $end->y), max($start->z, $end->z));
$region = $world->prepareCollision($path);
$hit = \qmath\Raycast::blocks($region, $start, $end);
if($hit !== null){
	$end = $hit->hitVector;
	$hitResult = [$world->getBlockAt($hit->blockX, $hit->blockY, $hit->blockZ), $hit]; // VoxelHit is a RayTraceResult
}
```

The box covers the segment from `$start` to `$end`, which contains every voxel the walk visits.
`missingSections()` adds the one-cell padding. Cache the override check per class, for example
`(new ReflectionMethod(static::class, 'calculateInterceptWithBlock'))->class === Projectile::class`.

Entity pass (lines 194–214): keep `getCollidingEntities()` and the owner check in PHP, then hand the boxes over:

```php
$boxes = [];
foreach($world->getCollidingEntities(...) as $entity){
	if(/* owner check as before */){ continue; }
	$boxes[$entity->getId()] = $entity->boundingBox;
}
if(($found = \qmath\Raycast::boxes($start, $end, $boxes, 0.3)) !== null){
	[$id, $entityHitResult] = $found;
	$hitResult = [$world->getEntity($id), $entityHitResult];
	$end = $entityHitResult->hitVector;
}
```

`Raycast::boxes()` shortens the segment after each hit, exactly like the original loop. The rotation update in
the no-hit branch can use `Physics::motionRotation($this->motion)`.

**Benefit:** the block raycast drops from 14–15 µs to 0.3–0.5 µs. `Raycast::batchBlocks()` handles many segments in one call.
**Validation:** run both paths side by side on arrows and tridents against slabs, fences, panes, chunk borders
and long shots.

`Living` line 829 (target block) and `FireworkRocket` can keep `VoxelRayTrace`, or use `Raycast::voxels()` /
`lineOfSight()` when they only need geometry.

## 4. Explosion

### explodeA()

Fill a `qmath\ResistanceGrid` covering the source ± `ceil(radius * 1.3 * 0.3 / 0.225) + 1`. The farthest a
ray can travel is 1.733 × radius. Use `setInvalid()` where `SubChunkExplorer` returns `INVALID`, and
`set($x, $y, $z, $blockFactory->blastResistance[$state] ?? 0)` everywhere else. Keep the `radius < 0.1` early
return at the top of `explodeA()`, because the native calls trace rays at any radius. Then:

```php
$incendiary = $this->fireChance > 0;
if(!$incendiary){
	$cells = \qmath\ExplosionMath::traceRays($grid, $this->source, $this->radius, $this->rays, $this->stepLen);
	for($i = 0, $n = count($cells); $i < $n; $i += 3){
		$this->affect($cells[$i], $cells[$i + 1], $cells[$i + 2]); // the existing isset()/getAffectedBlocks() body
	}
}else{
	// keep the i/j/k loops so Utils::getRandomFloat() calls interleave with mt_rand() exactly as before
	foreach(/* boundary rays in the original order */ as [$i, $j, $k]){
		foreach(array_chunk(\qmath\ExplosionMath::traceRay($grid, $this->source, $this->radius, $i, $j, $k, $this->rays, $this->stepLen), 3) as [$x, $y, $z]){
			$this->affect($x, $y, $z);
		}
	}
}
```

The native code calls `mt_rand(700, 1300)` once per ray, in the original order, through PHP's own generator.
Seeded results and the RNG state afterwards are therefore identical. `traceRays()` drops cells it has already
returned. That is equivalent to the `isset()` check because every `getAffectedBlocks()` in Quark (Block, Bed,
Door, DoublePlant, SmallDripleaf) includes the block itself. A plugin block whose `getAffectedBlocks()` leaves itself out would
need the per-ray path.

### getExposure()

```php
$o = $this->source;
$region = $this->world->prepareCollision($entity->getBoundingBox()->union(new AxisAlignedBB($o->x, $o->y, $o->z, $o->x, $o->y, $o->z)));
$exposure = \qmath\ExplosionMath::exposure($region, $this->source, $entity->getBoundingBox());
```

`exposures()` takes an array of boxes keyed by entity id and returns the exposures with the same keys.

**Benefit:** ray tracing goes from 8.5 ms to 0.4 ms at radius 4, and exposure from 350–500 µs to 5–7 µs per entity.
**Validation:** seed `mt_srand()`, then compare `affectedBlocks`, the fire ignitions and `mt_rand()` afterwards between both paths.

## 5. World generation noise

Keep `Simplex::__construct()` in PHP, because it consumes `Random` in a fixed order. Then build the native twin from
the same data:

```php
$this->native = new \qmath\Simplex($this->perm, $this->offsetX, $this->offsetY, $this->offsetZ, $octaves, $persistence, $expansion);
```

Delegate `getNoise2D()`, `getNoise3D()`, `noise2D()`, `noise3D()` and `getFastNoise1D/2D/3D()` to it. The 1D and
2D methods return plain arrays instead of `SplFixedArray`, with `null` in the same unfilled slots. Indexing
works the same, so `Normal::generateChunk()` and `Nether` need no changes. `getFastNoise3DPacked()` returns the
same values as little-endian doubles, if a generator is rewritten to read a packed buffer.

Generators run on worker threads. Construct `qmath\Simplex` on the thread that uses it, which Quark already does.
It cannot be serialized or copied between threads.

**Benefit:** a 16×128×16 sampled chunk drops from 5.4 ms to 0.31 ms (0.085 ms packed).
**Validation:** generate a few thousand chunks for several seeds with both implementations and compare chunk hashes.
The differential suite already compares every noise method bit for bit.

## 6. Nearby entities and physics formulas

`World::getNearbyEntities()`: replace the inner `foreach` over `getChunkEntities()` with
`array_push($nearby, ...\qmath\Spatial::overlapping($this->getChunkEntities($x, $z), $bb, $entity))`. It applies the
same `> 0.00001` overlap test and `!==` exclusion, reading the public `boundingBox` property. It skips reading
the excluded entity's box, which only matters if that read has side effects. Keep
`getCollidingEntities()` and `getNearestEntity()` in PHP, because they call entity methods. The result is about
2.6x faster for 500 entities.

Formulas:

| Quark | ext-qmath |
|---|---|
| `Entity::tryChangeMovement()` body | `$this->motion = Physics::motionStep($this->motion, $this->drag, $this->gravity, $this->gravityEnabled, $this->applyDragBeforeGravity(), $this->onGround ? $blockFriction : 1.0, -1.0)` (threshold `-1.0` means no clamp, the `onUpdate()` clamp stays where it is). `ItemEntity` and `ExperienceOrb` still call `checkObstruction()` first |
| `Entity::onUpdate()` MOTION_THRESHOLD clamp | can fold into the call above with the default threshold |
| `Living::knockBack()` after the resistance roll | `Physics::knockBack($this->motion, $x, $z, $force, $verticalLimit)` |
| `Entity::getDirectionVector()` | `VectorMath::getDirection3D($yaw, $pitch)` |
| `Entity::getDirectionPlane()` | `Physics::directionPlane($yaw)` |
| `Entity::getHorizontalFacing()` | `Physics::horizontalFacing($yaw)` |
| `Living::lookAt()` | `[$yaw, $pitch] = Physics::lookAt($eyePos, $target)` |
| `Projectile::move()` rotation | `Physics::motionRotation($this->motion)` |

Each is bit-identical to the original formula. The gains are per call (about 5x for a motion step), so they
matter in entity-heavy worlds.

## 7. pocketmine/color

`pocketmine\color\Color` is implemented natively with the same private properties, so serialized colours and
`DyeColor` usage are unchanged. The `replace` entry in section 1 removes the package. It also adds
`lerp()`, `blend()`, `toRGB()`, and HSV/HSL conversion.

## 8. What stays in PHP

Events, block updates and world mutation, block shape computation (`getCollisionBoxes()`, state registries),
chunk I/O, entity ownership, damage and knockback resistance rolls, fire and drop chances, plugin hooks,
`Player` movement (client authoritative), network movement handling, and everything that decides *whether*
something happens. ext-qmath only computes geometry and formulas over data PHP hands it.

## 9. Integration order

| Step | Change | Benefit | Risk | Validation |
|---|---|---|---|---|
| 1 | Swap pocketmine/math and color for the extension (section 1) | 1.2–13x on math calls (`calculateIntercept` 13x, `normalize/floor/up` 5x, vector arithmetic 2x) | Low. API and behaviour are identical | Quark test suite, PHPStan with the stub, a play session |
| 2 | Physics formulas (section 6) | About 5x per call | Low | Unit tests comparing old and new formulas |
| 3 | CollisionRegion and `Entity::move()` (section 2) | 37–52x on collision, the largest server-wide win | Medium-high: completeness of invalidation | Shadow mode, soak test, `tests/diff` |
| 4 | Projectile raycasts (section 3) | 70–76x | Medium: depends on step 3's region | Shadow mode on projectiles |
| 5 | Explosions (section 4) | 21x on rays, 72–74x on exposure | Low-medium | Seeded comparisons including RNG state |
| 6 | Noise (section 5) | About 64x per chunk | Low: bit-identical | Chunk hash comparison per seed |
| 7 | `getNearbyEntities()` (section 6) | About 2.6x | Low | Compare results in shadow mode |

Build the extension with `-Doptimize=ReleaseSafe` for servers. It keeps Zig's runtime safety checks, costs about 20%
of native time compared to `ReleaseFast`, and turns any internal bug into a clean abort instead of memory corruption.
