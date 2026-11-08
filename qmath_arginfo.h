/* This is a generated file, edit the .stub.php file instead.
 * Stub hash: f0cc419b43ebe18079019d59775f2c1425f95135 */

ZEND_BEGIN_ARG_INFO_EX(arginfo_class_pocketmine_math_Axis___construct, 0, 0, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_Axis_toString, 0, 1, IS_STRING, 0)
	ZEND_ARG_TYPE_INFO(0, axis, IS_LONG, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_Facing___construct arginfo_class_pocketmine_math_Axis___construct

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_Facing_axis, 0, 1, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, direction, IS_LONG, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_Facing_isPositive, 0, 1, _IS_BOOL, 0)
	ZEND_ARG_TYPE_INFO(0, direction, IS_LONG, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_Facing_opposite arginfo_class_pocketmine_math_Facing_axis

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_Facing_rotate, 0, 3, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, direction, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, axis, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, clockwise, _IS_BOOL, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_Facing_rotateY, 0, 2, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, direction, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, clockwise, _IS_BOOL, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_Facing_rotateZ arginfo_class_pocketmine_math_Facing_rotateY

#define arginfo_class_pocketmine_math_Facing_rotateX arginfo_class_pocketmine_math_Facing_rotateY

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_Facing_validate, 0, 1, IS_VOID, 0)
	ZEND_ARG_TYPE_INFO(0, facing, IS_LONG, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_Facing_toString, 0, 1, IS_STRING, 0)
	ZEND_ARG_TYPE_INFO(0, facing, IS_LONG, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_Math___construct arginfo_class_pocketmine_math_Axis___construct

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_Math_floorFloat, 0, 1, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, n, IS_MIXED, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_Math_ceilFloat arginfo_class_pocketmine_math_Math_floorFloat

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_Math_solveQuadratic, 0, 3, IS_ARRAY, 0)
	ZEND_ARG_TYPE_INFO(0, a, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, b, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, c, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_VectorMath___construct arginfo_class_pocketmine_math_Axis___construct

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_VectorMath_getDirection2D, 0, 1, pocketmine\\math\\Vector2, 0)
	ZEND_ARG_TYPE_INFO(0, azimuth, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_VectorMath_getDirection3D, 0, 2, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO(0, yaw, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, pitch, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_INFO_EX(arginfo_class_pocketmine_math_Vector2___construct, 0, 0, 2)
	ZEND_ARG_TYPE_INFO(0, x, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_Vector2_getX, 0, 0, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_Vector2_getY arginfo_class_pocketmine_math_Vector2_getX

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_Vector2_getFloorX, 0, 0, IS_LONG, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_Vector2_getFloorY arginfo_class_pocketmine_math_Vector2_getFloorX

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_Vector2_add, 0, 2, pocketmine\\math\\Vector2, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_Vector2_addVector, 0, 1, pocketmine\\math\\Vector2, 0)
	ZEND_ARG_OBJ_INFO(0, vector2, pocketmine\\math\\Vector2, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_Vector2_subtract arginfo_class_pocketmine_math_Vector2_add

#define arginfo_class_pocketmine_math_Vector2_subtractVector arginfo_class_pocketmine_math_Vector2_addVector

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_Vector2_ceil, 0, 0, pocketmine\\math\\Vector2, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_Vector2_floor arginfo_class_pocketmine_math_Vector2_ceil

#define arginfo_class_pocketmine_math_Vector2_round arginfo_class_pocketmine_math_Vector2_ceil

#define arginfo_class_pocketmine_math_Vector2_abs arginfo_class_pocketmine_math_Vector2_ceil

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_Vector2_multiply, 0, 1, pocketmine\\math\\Vector2, 0)
	ZEND_ARG_TYPE_INFO(0, number, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_Vector2_divide arginfo_class_pocketmine_math_Vector2_multiply

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_Vector2_distance, 0, 1, IS_DOUBLE, 0)
	ZEND_ARG_OBJ_INFO(0, pos, pocketmine\\math\\Vector2, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_Vector2_distanceSquared arginfo_class_pocketmine_math_Vector2_distance

#define arginfo_class_pocketmine_math_Vector2_length arginfo_class_pocketmine_math_Vector2_getX

#define arginfo_class_pocketmine_math_Vector2_lengthSquared arginfo_class_pocketmine_math_Vector2_getX

#define arginfo_class_pocketmine_math_Vector2_normalize arginfo_class_pocketmine_math_Vector2_ceil

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_Vector2_dot, 0, 1, IS_DOUBLE, 0)
	ZEND_ARG_OBJ_INFO(0, v, pocketmine\\math\\Vector2, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_Vector2_lerp, 0, 2, pocketmine\\math\\Vector2, 0)
	ZEND_ARG_OBJ_INFO(0, to, pocketmine\\math\\Vector2, 0)
	ZEND_ARG_TYPE_INFO(0, t, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_Vector2___toString, 0, 0, IS_STRING, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_INFO_EX(arginfo_class_pocketmine_math_Vector3___construct, 0, 0, 3)
	ZEND_ARG_TYPE_MASK(0, x, MAY_BE_DOUBLE|MAY_BE_LONG, NULL)
	ZEND_ARG_TYPE_MASK(0, y, MAY_BE_DOUBLE|MAY_BE_LONG, NULL)
	ZEND_ARG_TYPE_MASK(0, z, MAY_BE_DOUBLE|MAY_BE_LONG, NULL)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_Vector3_zero, 0, 0, pocketmine\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_MASK_EX(arginfo_class_pocketmine_math_Vector3_getX, 0, 0, MAY_BE_DOUBLE|MAY_BE_LONG)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_Vector3_getY arginfo_class_pocketmine_math_Vector3_getX

#define arginfo_class_pocketmine_math_Vector3_getZ arginfo_class_pocketmine_math_Vector3_getX

#define arginfo_class_pocketmine_math_Vector3_getFloorX arginfo_class_pocketmine_math_Vector2_getFloorX

#define arginfo_class_pocketmine_math_Vector3_getFloorY arginfo_class_pocketmine_math_Vector2_getFloorX

#define arginfo_class_pocketmine_math_Vector3_getFloorZ arginfo_class_pocketmine_math_Vector2_getFloorX

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_Vector3_add, 0, 3, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_TYPE_MASK(0, x, MAY_BE_DOUBLE|MAY_BE_LONG, NULL)
	ZEND_ARG_TYPE_MASK(0, y, MAY_BE_DOUBLE|MAY_BE_LONG, NULL)
	ZEND_ARG_TYPE_MASK(0, z, MAY_BE_DOUBLE|MAY_BE_LONG, NULL)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_Vector3_addVector, 0, 1, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, v, pocketmine\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_Vector3_subtract arginfo_class_pocketmine_math_Vector3_add

#define arginfo_class_pocketmine_math_Vector3_subtractVector arginfo_class_pocketmine_math_Vector3_addVector

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_Vector3_multiply, 0, 1, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO(0, number, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_Vector3_divide arginfo_class_pocketmine_math_Vector3_multiply

#define arginfo_class_pocketmine_math_Vector3_ceil arginfo_class_pocketmine_math_Vector3_zero

#define arginfo_class_pocketmine_math_Vector3_floor arginfo_class_pocketmine_math_Vector3_zero

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_Vector3_round, 0, 0, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, precision, IS_LONG, 0, "0")
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, mode, IS_LONG, 0, "PHP_ROUND_HALF_UP")
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_Vector3_abs arginfo_class_pocketmine_math_Vector3_zero

ZEND_BEGIN_ARG_INFO_EX(arginfo_class_pocketmine_math_Vector3_getSide, 0, 0, 1)
	ZEND_ARG_TYPE_INFO(0, side, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, step, IS_LONG, 0, "1")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_INFO_EX(arginfo_class_pocketmine_math_Vector3_down, 0, 0, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, step, IS_LONG, 0, "1")
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_Vector3_up arginfo_class_pocketmine_math_Vector3_down

#define arginfo_class_pocketmine_math_Vector3_north arginfo_class_pocketmine_math_Vector3_down

#define arginfo_class_pocketmine_math_Vector3_south arginfo_class_pocketmine_math_Vector3_down

#define arginfo_class_pocketmine_math_Vector3_west arginfo_class_pocketmine_math_Vector3_down

#define arginfo_class_pocketmine_math_Vector3_east arginfo_class_pocketmine_math_Vector3_down

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_Vector3_sides, 0, 0, Iterator, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, step, IS_LONG, 0, "1")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_Vector3_sidesArray, 0, 0, IS_ARRAY, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, keys, _IS_BOOL, 0, "false")
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, step, IS_LONG, 0, "1")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_Vector3_sidesAroundAxis, 0, 1, Iterator, 0)
	ZEND_ARG_TYPE_INFO(0, axis, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, step, IS_LONG, 0, "1")
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_Vector3_asVector3 arginfo_class_pocketmine_math_Vector3_zero

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_Vector3_distance, 0, 1, IS_DOUBLE, 0)
	ZEND_ARG_OBJ_INFO(0, pos, pocketmine\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_Vector3_distanceSquared arginfo_class_pocketmine_math_Vector3_distance

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_Vector3_maxPlainDistance, 0, 1, IS_DOUBLE, 0)
	ZEND_ARG_OBJ_TYPE_MASK(0, x, pocketmine\\math\\Vector3|pocketmine\\math\\Vector2, MAY_BE_DOUBLE, NULL)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, z, IS_DOUBLE, 0, "0")
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_Vector3_length arginfo_class_pocketmine_math_Vector2_getX

#define arginfo_class_pocketmine_math_Vector3_lengthSquared arginfo_class_pocketmine_math_Vector2_getX

#define arginfo_class_pocketmine_math_Vector3_normalize arginfo_class_pocketmine_math_Vector3_zero

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_Vector3_dot, 0, 1, IS_DOUBLE, 0)
	ZEND_ARG_OBJ_INFO(0, v, pocketmine\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_Vector3_cross arginfo_class_pocketmine_math_Vector3_addVector

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_Vector3_equals, 0, 1, _IS_BOOL, 0)
	ZEND_ARG_OBJ_INFO(0, v, pocketmine\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_Vector3_getIntermediateWithXValue, 0, 2, pocketmine\\math\\Vector3, 1)
	ZEND_ARG_OBJ_INFO(0, v, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_Vector3_getIntermediateWithYValue, 0, 2, pocketmine\\math\\Vector3, 1)
	ZEND_ARG_OBJ_INFO(0, v, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_Vector3_getIntermediateWithZValue, 0, 2, pocketmine\\math\\Vector3, 1)
	ZEND_ARG_OBJ_INFO(0, v, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_Vector3___toString arginfo_class_pocketmine_math_Vector2___toString

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_Vector3_withComponents, 0, 3, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_TYPE_MASK(0, x, MAY_BE_DOUBLE|MAY_BE_LONG|MAY_BE_NULL, NULL)
	ZEND_ARG_TYPE_MASK(0, y, MAY_BE_DOUBLE|MAY_BE_LONG|MAY_BE_NULL, NULL)
	ZEND_ARG_TYPE_MASK(0, z, MAY_BE_DOUBLE|MAY_BE_LONG|MAY_BE_NULL, NULL)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_Vector3_maxComponents, 0, 1, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, vector, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_VARIADIC_OBJ_INFO(0, vectors, pocketmine\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_Vector3_minComponents arginfo_class_pocketmine_math_Vector3_maxComponents

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_Vector3_sum, 0, 0, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_VARIADIC_OBJ_INFO(0, vector3s, pocketmine\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_Vector3_lerp, 0, 2, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, to, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO(0, t, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_Vector3_normalizeOrNull, 0, 0, pocketmine\\math\\Vector3, 1)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_Vector3_project, 0, 1, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, onto, pocketmine\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_Vector3_reject, 0, 1, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, from, pocketmine\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_Vector3_reflect, 0, 1, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, normal, pocketmine\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_Vector3_angle arginfo_class_pocketmine_math_Vector3_dot

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_Vector3_clamp, 0, 2, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, min, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, max, pocketmine\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_Vector3_moveTowards, 0, 2, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, target, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO(0, maxDistance, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_Vector3_isFinite, 0, 0, _IS_BOOL, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_INFO_EX(arginfo_class_pocketmine_math_RayTraceResult___construct, 0, 0, 3)
	ZEND_ARG_OBJ_INFO(0, bb, pocketmine\\math\\AxisAlignedBB, 0)
	ZEND_ARG_TYPE_INFO(0, hitFace, IS_LONG, 0)
	ZEND_ARG_OBJ_INFO(0, hitVector, pocketmine\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_RayTraceResult_getBoundingBox, 0, 0, pocketmine\\math\\AxisAlignedBB, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_RayTraceResult_getHitFace arginfo_class_pocketmine_math_Vector2_getFloorX

#define arginfo_class_pocketmine_math_RayTraceResult_getHitVector arginfo_class_pocketmine_math_Vector3_zero

ZEND_BEGIN_ARG_INFO_EX(arginfo_class_pocketmine_math_AxisAlignedBB___construct, 0, 0, 6)
	ZEND_ARG_TYPE_INFO(0, minX, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, minY, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, minZ, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, maxX, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, maxY, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, maxZ, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_AxisAlignedBB_addCoord, 0, 3, pocketmine\\math\\AxisAlignedBB, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_AxisAlignedBB_expand arginfo_class_pocketmine_math_AxisAlignedBB_addCoord

#define arginfo_class_pocketmine_math_AxisAlignedBB_expandedCopy arginfo_class_pocketmine_math_AxisAlignedBB_addCoord

#define arginfo_class_pocketmine_math_AxisAlignedBB_offset arginfo_class_pocketmine_math_AxisAlignedBB_addCoord

#define arginfo_class_pocketmine_math_AxisAlignedBB_offsetCopy arginfo_class_pocketmine_math_AxisAlignedBB_addCoord

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_AxisAlignedBB_offsetTowards, 0, 2, pocketmine\\math\\AxisAlignedBB, 0)
	ZEND_ARG_TYPE_INFO(0, face, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, distance, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_AxisAlignedBB_offsetTowardsCopy arginfo_class_pocketmine_math_AxisAlignedBB_offsetTowards

#define arginfo_class_pocketmine_math_AxisAlignedBB_contract arginfo_class_pocketmine_math_AxisAlignedBB_addCoord

#define arginfo_class_pocketmine_math_AxisAlignedBB_contractedCopy arginfo_class_pocketmine_math_AxisAlignedBB_addCoord

#define arginfo_class_pocketmine_math_AxisAlignedBB_extend arginfo_class_pocketmine_math_AxisAlignedBB_offsetTowards

#define arginfo_class_pocketmine_math_AxisAlignedBB_extendedCopy arginfo_class_pocketmine_math_AxisAlignedBB_offsetTowards

#define arginfo_class_pocketmine_math_AxisAlignedBB_trim arginfo_class_pocketmine_math_AxisAlignedBB_offsetTowards

#define arginfo_class_pocketmine_math_AxisAlignedBB_trimmedCopy arginfo_class_pocketmine_math_AxisAlignedBB_offsetTowards

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_AxisAlignedBB_stretch, 0, 2, pocketmine\\math\\AxisAlignedBB, 0)
	ZEND_ARG_TYPE_INFO(0, axis, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, distance, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_AxisAlignedBB_stretchedCopy arginfo_class_pocketmine_math_AxisAlignedBB_stretch

#define arginfo_class_pocketmine_math_AxisAlignedBB_squash arginfo_class_pocketmine_math_AxisAlignedBB_stretch

#define arginfo_class_pocketmine_math_AxisAlignedBB_squashedCopy arginfo_class_pocketmine_math_AxisAlignedBB_stretch

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_AxisAlignedBB_calculateXOffset, 0, 2, IS_DOUBLE, 0)
	ZEND_ARG_OBJ_INFO(0, bb, pocketmine\\math\\AxisAlignedBB, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_AxisAlignedBB_calculateYOffset, 0, 2, IS_DOUBLE, 0)
	ZEND_ARG_OBJ_INFO(0, bb, pocketmine\\math\\AxisAlignedBB, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_AxisAlignedBB_calculateZOffset, 0, 2, IS_DOUBLE, 0)
	ZEND_ARG_OBJ_INFO(0, bb, pocketmine\\math\\AxisAlignedBB, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_AxisAlignedBB_intersectsWith, 0, 1, _IS_BOOL, 0)
	ZEND_ARG_OBJ_INFO(0, bb, pocketmine\\math\\AxisAlignedBB, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, epsilon, IS_DOUBLE, 0, "1.0E-5")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_AxisAlignedBB_isVectorInside, 0, 1, _IS_BOOL, 0)
	ZEND_ARG_OBJ_INFO(0, vector, pocketmine\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_AxisAlignedBB_getAverageEdgeLength arginfo_class_pocketmine_math_Vector2_getX

#define arginfo_class_pocketmine_math_AxisAlignedBB_getXLength arginfo_class_pocketmine_math_Vector2_getX

#define arginfo_class_pocketmine_math_AxisAlignedBB_getYLength arginfo_class_pocketmine_math_Vector2_getX

#define arginfo_class_pocketmine_math_AxisAlignedBB_getZLength arginfo_class_pocketmine_math_Vector2_getX

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_AxisAlignedBB_isCube, 0, 0, _IS_BOOL, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, epsilon, IS_DOUBLE, 0, "1.0E-6")
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_AxisAlignedBB_getVolume arginfo_class_pocketmine_math_Vector2_getX

#define arginfo_class_pocketmine_math_AxisAlignedBB_isVectorInYZ arginfo_class_pocketmine_math_AxisAlignedBB_isVectorInside

#define arginfo_class_pocketmine_math_AxisAlignedBB_isVectorInXZ arginfo_class_pocketmine_math_AxisAlignedBB_isVectorInside

#define arginfo_class_pocketmine_math_AxisAlignedBB_isVectorInXY arginfo_class_pocketmine_math_AxisAlignedBB_isVectorInside

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_AxisAlignedBB_calculateIntercept, 0, 2, pocketmine\\math\\RayTraceResult, 1)
	ZEND_ARG_OBJ_INFO(0, pos1, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, pos2, pocketmine\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_AxisAlignedBB___toString arginfo_class_pocketmine_math_Vector2___toString

#define arginfo_class_pocketmine_math_AxisAlignedBB_one arginfo_class_pocketmine_math_RayTraceResult_getBoundingBox

#define arginfo_class_pocketmine_math_AxisAlignedBB_getCenter arginfo_class_pocketmine_math_Vector3_zero

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_AxisAlignedBB_closestPoint, 0, 1, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, point, pocketmine\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_AxisAlignedBB_distanceSquaredTo, 0, 1, IS_DOUBLE, 0)
	ZEND_ARG_OBJ_INFO(0, point, pocketmine\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_AxisAlignedBB_intersectsSphere, 0, 2, _IS_BOOL, 0)
	ZEND_ARG_OBJ_INFO(0, center, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO(0, radius, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_AxisAlignedBB_intersectsSegment, 0, 2, _IS_BOOL, 0)
	ZEND_ARG_OBJ_INFO(0, start, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, end, pocketmine\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_AxisAlignedBB_union, 0, 1, pocketmine\\math\\AxisAlignedBB, 0)
	ZEND_ARG_OBJ_INFO(0, bb, pocketmine\\math\\AxisAlignedBB, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_AxisAlignedBB_isFinite arginfo_class_pocketmine_math_Vector3_isFinite

#define arginfo_class_pocketmine_math_VoxelRayTrace___construct arginfo_class_pocketmine_math_Axis___construct

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_VoxelRayTrace_inDirection, 0, 3, Iterator, 0)
	ZEND_ARG_OBJ_INFO(0, start, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, directionVector, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO(0, maxDistance, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_VoxelRayTrace_betweenPoints, 0, 2, Iterator, 0)
	ZEND_ARG_OBJ_INFO(0, start, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, end, pocketmine\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_Matrix_offsetExists, 0, 1, _IS_BOOL, 0)
	ZEND_ARG_TYPE_INFO(0, offset, IS_MIXED, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_Matrix_offsetGet, 0, 1, IS_MIXED, 0)
	ZEND_ARG_TYPE_INFO(0, offset, IS_MIXED, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_Matrix_offsetSet, 0, 2, IS_VOID, 0)
	ZEND_ARG_TYPE_INFO(0, offset, IS_MIXED, 0)
	ZEND_ARG_TYPE_INFO(0, value, IS_MIXED, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_Matrix_offsetUnset, 0, 1, IS_VOID, 0)
	ZEND_ARG_TYPE_INFO(0, offset, IS_MIXED, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_INFO_EX(arginfo_class_pocketmine_math_Matrix___construct, 0, 0, 2)
	ZEND_ARG_TYPE_INFO(0, rows, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, columns, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, set, IS_ARRAY, 0, "[]")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_Matrix_set, 0, 1, IS_VOID, 0)
	ZEND_ARG_TYPE_INFO(0, m, IS_ARRAY, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_Matrix_getRows arginfo_class_pocketmine_math_Vector2_getFloorX

#define arginfo_class_pocketmine_math_Matrix_getColumns arginfo_class_pocketmine_math_Vector2_getFloorX

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_Matrix_setElement, 0, 3, IS_VOID, 0)
	ZEND_ARG_TYPE_INFO(0, row, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, column, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, value, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_math_Matrix_getElement, 0, 2, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, row, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, column, IS_LONG, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_Matrix_isSquare arginfo_class_pocketmine_math_Vector3_isFinite

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_Matrix_add, 0, 1, pocketmine\\math\\Matrix, 0)
	ZEND_ARG_OBJ_INFO(0, matrix, pocketmine\\math\\Matrix, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_Matrix_subtract arginfo_class_pocketmine_math_Matrix_add

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_Matrix_multiplyScalar, 0, 1, pocketmine\\math\\Matrix, 0)
	ZEND_ARG_TYPE_INFO(0, number, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_Matrix_divideScalar arginfo_class_pocketmine_math_Matrix_multiplyScalar

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_math_Matrix_transpose, 0, 0, pocketmine\\math\\Matrix, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_math_Matrix_product arginfo_class_pocketmine_math_Matrix_add

#define arginfo_class_pocketmine_math_Matrix_determinant arginfo_class_pocketmine_math_Vector2_getX

#define arginfo_class_pocketmine_math_Matrix___toString arginfo_class_pocketmine_math_Vector2___toString

ZEND_BEGIN_ARG_INFO_EX(arginfo_class_pocketmine_color_Color___construct, 0, 0, 3)
	ZEND_ARG_TYPE_INFO(0, r, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, g, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, b, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, a, IS_LONG, 0, "0xff")
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_color_Color_getA arginfo_class_pocketmine_math_Vector2_getFloorX

#define arginfo_class_pocketmine_color_Color_getR arginfo_class_pocketmine_math_Vector2_getFloorX

#define arginfo_class_pocketmine_color_Color_getG arginfo_class_pocketmine_math_Vector2_getFloorX

#define arginfo_class_pocketmine_color_Color_getB arginfo_class_pocketmine_math_Vector2_getFloorX

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_color_Color_mix, 0, 1, pocketmine\\color\\Color, 0)
	ZEND_ARG_OBJ_INFO(0, color1, pocketmine\\color\\Color, 0)
	ZEND_ARG_VARIADIC_OBJ_INFO(0, colors, pocketmine\\color\\Color, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_color_Color_fromRGB, 0, 1, pocketmine\\color\\Color, 0)
	ZEND_ARG_TYPE_INFO(0, code, IS_LONG, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_color_Color_fromARGB arginfo_class_pocketmine_color_Color_fromRGB

#define arginfo_class_pocketmine_color_Color_toARGB arginfo_class_pocketmine_math_Vector2_getFloorX

#define arginfo_class_pocketmine_color_Color_fromRGBA arginfo_class_pocketmine_color_Color_fromRGB

#define arginfo_class_pocketmine_color_Color_toRGBA arginfo_class_pocketmine_math_Vector2_getFloorX

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_color_Color_equals, 0, 1, _IS_BOOL, 0)
	ZEND_ARG_OBJ_INFO(0, other, pocketmine\\color\\Color, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_color_Color_toRGB arginfo_class_pocketmine_math_Vector2_getFloorX

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_color_Color_lerp, 0, 2, pocketmine\\color\\Color, 0)
	ZEND_ARG_OBJ_INFO(0, to, pocketmine\\color\\Color, 0)
	ZEND_ARG_TYPE_INFO(0, t, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_color_Color_blend, 0, 1, pocketmine\\color\\Color, 0)
	ZEND_ARG_OBJ_INFO(0, over, pocketmine\\color\\Color, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_pocketmine_color_Color_toHSV, 0, 0, IS_ARRAY, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_color_Color_fromHSV, 0, 3, pocketmine\\color\\Color, 0)
	ZEND_ARG_TYPE_INFO(0, hue, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, saturation, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, value, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, a, IS_LONG, 0, "0xff")
ZEND_END_ARG_INFO()

#define arginfo_class_pocketmine_color_Color_toHSL arginfo_class_pocketmine_color_Color_toHSV

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_pocketmine_color_Color_fromHSL, 0, 3, pocketmine\\color\\Color, 0)
	ZEND_ARG_TYPE_INFO(0, hue, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, saturation, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, lightness, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, a, IS_LONG, 0, "0xff")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_INFO_EX(arginfo_class_qmath_CollisionRegion___construct, 0, 0, 6)
	ZEND_ARG_TYPE_INFO(0, minX, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, minY, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, minZ, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, maxX, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, maxY, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, maxZ, IS_LONG, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_qmath_CollisionRegion_getBounds arginfo_class_pocketmine_color_Color_toHSV

#define arginfo_class_qmath_CollisionRegion_getVersion arginfo_class_pocketmine_math_Vector2_getFloorX

#define arginfo_class_qmath_CollisionRegion_isFrozen arginfo_class_pocketmine_math_Vector3_isFinite

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_CollisionRegion_freeze, 0, 0, IS_VOID, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_qmath_CollisionRegion_snapshot, 0, 0, qmath\\CollisionRegion, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_CollisionRegion_contains, 0, 3, _IS_BOOL, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_LONG, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_qmath_CollisionRegion_isKnown arginfo_class_qmath_CollisionRegion_contains

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_CollisionRegion_setCell, 0, 4, IS_VOID, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, info, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, boxes, IS_ARRAY, 0, "[]")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_CollisionRegion_setCellPacked, 0, 5, IS_VOID, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, info, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, boxes, IS_STRING, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_CollisionRegion_fill, 0, 1, IS_VOID, 0)
	ZEND_ARG_TYPE_INFO(0, info, IS_LONG, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_CollisionRegion_invalidateCell, 0, 3, IS_VOID, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_LONG, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_qmath_CollisionRegion_invalidateBlock arginfo_class_qmath_CollisionRegion_invalidateCell

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_CollisionRegion_invalidateChunk, 0, 2, IS_VOID, 0)
	ZEND_ARG_TYPE_INFO(0, chunkX, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, chunkZ, IS_LONG, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_qmath_CollisionRegion_invalidateAll arginfo_class_qmath_CollisionRegion_freeze

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_CollisionRegion_isComplete, 0, 1, _IS_BOOL, 0)
	ZEND_ARG_OBJ_INFO(0, bb, pocketmine\\math\\AxisAlignedBB, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_CollisionRegion_getCollisionBoxes, 0, 1, IS_ARRAY, 0)
	ZEND_ARG_OBJ_INFO(0, bb, pocketmine\\math\\AxisAlignedBB, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_qmath_CollisionRegion_collides arginfo_class_qmath_CollisionRegion_isComplete

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_CollisionRegion_getCellBoxes, 0, 3, IS_ARRAY, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_LONG, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_CollisionRegion_getCellInfo, 0, 3, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_LONG, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_qmath_MoveResult___construct arginfo_class_pocketmine_math_Axis___construct

#define arginfo_class_qmath_SweepResult___construct arginfo_class_pocketmine_math_Axis___construct

#define arginfo_class_qmath_Collision___construct arginfo_class_pocketmine_math_Axis___construct

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_qmath_Collision_move, 0, 5, qmath\\MoveResult, 0)
	ZEND_ARG_OBJ_INFO(0, region, qmath\\CollisionRegion, 0)
	ZEND_ARG_OBJ_INFO(0, bb, pocketmine\\math\\AxisAlignedBB, 0)
	ZEND_ARG_TYPE_INFO(0, dx, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, dy, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, dz, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, stepHeight, IS_DOUBLE, 0, "0.0")
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, onGround, _IS_BOOL, 0, "false")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_qmath_Collision_sweep, 0, 5, qmath\\SweepResult, 1)
	ZEND_ARG_OBJ_INFO(0, region, qmath\\CollisionRegion, 0)
	ZEND_ARG_OBJ_INFO(0, bb, pocketmine\\math\\AxisAlignedBB, 0)
	ZEND_ARG_TYPE_INFO(0, dx, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, dy, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, dz, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_qmath_Collision_sweepBoxes, 0, 5, qmath\\SweepResult, 1)
	ZEND_ARG_OBJ_INFO(0, bb, pocketmine\\math\\AxisAlignedBB, 0)
	ZEND_ARG_TYPE_INFO(0, dx, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, dy, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, dz, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, boxes, IS_ARRAY, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_INFO_EX(arginfo_class_qmath_VoxelHit___construct, 0, 0, 6)
	ZEND_ARG_OBJ_INFO(0, bb, pocketmine\\math\\AxisAlignedBB, 0)
	ZEND_ARG_TYPE_INFO(0, hitFace, IS_LONG, 0)
	ZEND_ARG_OBJ_INFO(0, hitVector, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO(0, blockX, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, blockY, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, blockZ, IS_LONG, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_qmath_VoxelRayIterator___construct arginfo_class_pocketmine_math_Axis___construct

#define arginfo_class_qmath_VoxelRayIterator_current arginfo_class_pocketmine_math_Vector3_normalizeOrNull

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_VoxelRayIterator_key, 0, 0, IS_LONG, 1)
ZEND_END_ARG_INFO()

#define arginfo_class_qmath_VoxelRayIterator_next arginfo_class_qmath_CollisionRegion_freeze

#define arginfo_class_qmath_VoxelRayIterator_rewind arginfo_class_qmath_CollisionRegion_freeze

#define arginfo_class_qmath_VoxelRayIterator_valid arginfo_class_pocketmine_math_Vector3_isFinite

#define arginfo_class_qmath_Raycast___construct arginfo_class_pocketmine_math_Axis___construct

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_Raycast_voxels, 0, 2, IS_ARRAY, 0)
	ZEND_ARG_OBJ_INFO(0, start, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, end, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, limit, IS_LONG, 0, "4096")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_qmath_Raycast_blocks, 0, 3, qmath\\VoxelHit, 1)
	ZEND_ARG_OBJ_INFO(0, region, qmath\\CollisionRegion, 0)
	ZEND_ARG_OBJ_INFO(0, start, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, end, pocketmine\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_Raycast_lineOfSight, 0, 3, _IS_BOOL, 0)
	ZEND_ARG_OBJ_INFO(0, region, qmath\\CollisionRegion, 0)
	ZEND_ARG_OBJ_INFO(0, start, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, end, pocketmine\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_Raycast_boxes, 0, 3, IS_ARRAY, 1)
	ZEND_ARG_OBJ_INFO(0, start, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, end, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO(0, boxes, IS_ARRAY, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, expand, IS_DOUBLE, 0, "0.0")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_Raycast_batchBlocks, 0, 2, IS_STRING, 0)
	ZEND_ARG_OBJ_INFO(0, region, qmath\\CollisionRegion, 0)
	ZEND_ARG_TYPE_INFO(0, segments, IS_STRING, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_qmath_ResistanceGrid___construct arginfo_class_qmath_CollisionRegion___construct

#define arginfo_class_qmath_ResistanceGrid_getBounds arginfo_class_pocketmine_color_Color_toHSV

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_ResistanceGrid_set, 0, 4, IS_VOID, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, resistance, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_qmath_ResistanceGrid_setInvalid arginfo_class_qmath_CollisionRegion_invalidateCell

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_ResistanceGrid_fill, 0, 1, IS_VOID, 0)
	ZEND_ARG_TYPE_INFO(0, resistance, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_ResistanceGrid_setPacked, 0, 1, IS_VOID, 0)
	ZEND_ARG_TYPE_INFO(0, values, IS_STRING, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_qmath_ExplosionMath___construct arginfo_class_pocketmine_math_Axis___construct

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_ExplosionMath_traceRays, 0, 3, IS_ARRAY, 0)
	ZEND_ARG_OBJ_INFO(0, grid, qmath\\ResistanceGrid, 0)
	ZEND_ARG_OBJ_INFO(0, source, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO(0, radius, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, rays, IS_LONG, 0, "16")
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, stepLen, IS_DOUBLE, 0, "0.3")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_ExplosionMath_traceRay, 0, 6, IS_ARRAY, 0)
	ZEND_ARG_OBJ_INFO(0, grid, qmath\\ResistanceGrid, 0)
	ZEND_ARG_OBJ_INFO(0, source, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO(0, radius, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, i, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, j, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, k, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, rays, IS_LONG, 0, "16")
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, stepLen, IS_DOUBLE, 0, "0.3")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_ExplosionMath_rayCount, 0, 0, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, rays, IS_LONG, 0, "16")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_ExplosionMath_exposure, 0, 3, IS_DOUBLE, 0)
	ZEND_ARG_OBJ_INFO(0, region, qmath\\CollisionRegion, 0)
	ZEND_ARG_OBJ_INFO(0, origin, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, bb, pocketmine\\math\\AxisAlignedBB, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_ExplosionMath_exposures, 0, 3, IS_ARRAY, 0)
	ZEND_ARG_OBJ_INFO(0, region, qmath\\CollisionRegion, 0)
	ZEND_ARG_OBJ_INFO(0, origin, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO(0, boxes, IS_ARRAY, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_INFO_EX(arginfo_class_qmath_Simplex___construct, 0, 0, 7)
	ZEND_ARG_TYPE_MASK(0, permutation, MAY_BE_ARRAY|MAY_BE_STRING, NULL)
	ZEND_ARG_TYPE_INFO(0, offsetX, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, offsetY, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, offsetZ, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, octaves, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, persistence, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, expansion, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_Simplex_getNoise2D, 0, 2, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_Simplex_getNoise3D, 0, 3, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_Simplex_noise2D, 0, 2, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, normalized, _IS_BOOL, 0, "false")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_Simplex_noise3D, 0, 3, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, normalized, _IS_BOOL, 0, "false")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_Simplex_getFastNoise1D, 0, 5, IS_ARRAY, 0)
	ZEND_ARG_TYPE_INFO(0, xSize, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, samplingRate, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_LONG, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_Simplex_getFastNoise2D, 0, 6, IS_ARRAY, 0)
	ZEND_ARG_TYPE_INFO(0, xSize, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, zSize, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, samplingRate, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_LONG, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_Simplex_getFastNoise3D, 0, 9, IS_ARRAY, 0)
	ZEND_ARG_TYPE_INFO(0, xSize, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, ySize, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, zSize, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, xSamplingRate, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, ySamplingRate, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, zSamplingRate, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_LONG, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_Simplex_getFastNoise3DPacked, 0, 9, IS_STRING, 0)
	ZEND_ARG_TYPE_INFO(0, xSize, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, ySize, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, zSize, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, xSamplingRate, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, ySamplingRate, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, zSamplingRate, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_LONG, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_qmath_Spatial___construct arginfo_class_pocketmine_math_Axis___construct

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_Spatial_overlapping, 0, 2, IS_ARRAY, 0)
	ZEND_ARG_TYPE_INFO(0, objects, IS_ARRAY, 0)
	ZEND_ARG_OBJ_INFO(0, bb, pocketmine\\math\\AxisAlignedBB, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, exclude, IS_OBJECT, 1, "null")
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, property, IS_STRING, 0, "\"boundingBox\"")
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, epsilon, IS_DOUBLE, 0, "1.0E-5")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_Spatial_overlappingBoxes, 0, 2, IS_ARRAY, 0)
	ZEND_ARG_OBJ_INFO(0, bb, pocketmine\\math\\AxisAlignedBB, 0)
	ZEND_ARG_TYPE_INFO(0, boxes, IS_ARRAY, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, epsilon, IS_DOUBLE, 0, "1.0E-5")
ZEND_END_ARG_INFO()

#define arginfo_class_qmath_Physics___construct arginfo_class_pocketmine_math_Axis___construct

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_qmath_Physics_motionStep, 0, 3, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, motion, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO(0, drag, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, gravity, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, gravityEnabled, _IS_BOOL, 0, "true")
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, dragBeforeGravity, _IS_BOOL, 0, "false")
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, groundFriction, IS_DOUBLE, 0, "1.0")
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, threshold, IS_DOUBLE, 0, "1.0E-5")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_qmath_Physics_knockBack, 0, 3, pocketmine\\math\\Vector3, 1)
	ZEND_ARG_OBJ_INFO(0, motion, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, force, IS_DOUBLE, 0, "0.4")
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, verticalLimit, IS_DOUBLE, 1, "0.4")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_qmath_Physics_directionPlane, 0, 1, pocketmine\\math\\Vector2, 0)
	ZEND_ARG_TYPE_INFO(0, yaw, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_Physics_horizontalFacing, 0, 1, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, yaw, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_Physics_lookAt, 0, 2, IS_ARRAY, 0)
	ZEND_ARG_OBJ_INFO(0, eye, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, target, pocketmine\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_Physics_motionRotation, 0, 1, IS_ARRAY, 0)
	ZEND_ARG_OBJ_INFO(0, motion, pocketmine\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_qmath_Physics_predictTrajectory, 0, 5, IS_STRING, 0)
	ZEND_ARG_OBJ_INFO(0, position, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, motion, pocketmine\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO(0, drag, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, gravity, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, ticks, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, dragBeforeGravity, _IS_BOOL, 0, "false")
ZEND_END_ARG_INFO()

ZEND_METHOD(pocketmine_math_Axis, __construct);
ZEND_METHOD(pocketmine_math_Axis, toString);
ZEND_METHOD(pocketmine_math_Facing, __construct);
ZEND_METHOD(pocketmine_math_Facing, axis);
ZEND_METHOD(pocketmine_math_Facing, isPositive);
ZEND_METHOD(pocketmine_math_Facing, opposite);
ZEND_METHOD(pocketmine_math_Facing, rotate);
ZEND_METHOD(pocketmine_math_Facing, rotateY);
ZEND_METHOD(pocketmine_math_Facing, rotateZ);
ZEND_METHOD(pocketmine_math_Facing, rotateX);
ZEND_METHOD(pocketmine_math_Facing, validate);
ZEND_METHOD(pocketmine_math_Facing, toString);
ZEND_METHOD(pocketmine_math_Math, __construct);
ZEND_METHOD(pocketmine_math_Math, floorFloat);
ZEND_METHOD(pocketmine_math_Math, ceilFloat);
ZEND_METHOD(pocketmine_math_Math, solveQuadratic);
ZEND_METHOD(pocketmine_math_VectorMath, __construct);
ZEND_METHOD(pocketmine_math_VectorMath, getDirection2D);
ZEND_METHOD(pocketmine_math_VectorMath, getDirection3D);
ZEND_METHOD(pocketmine_math_Vector2, __construct);
ZEND_METHOD(pocketmine_math_Vector2, getX);
ZEND_METHOD(pocketmine_math_Vector2, getY);
ZEND_METHOD(pocketmine_math_Vector2, getFloorX);
ZEND_METHOD(pocketmine_math_Vector2, getFloorY);
ZEND_METHOD(pocketmine_math_Vector2, add);
ZEND_METHOD(pocketmine_math_Vector2, addVector);
ZEND_METHOD(pocketmine_math_Vector2, subtract);
ZEND_METHOD(pocketmine_math_Vector2, subtractVector);
ZEND_METHOD(pocketmine_math_Vector2, ceil);
ZEND_METHOD(pocketmine_math_Vector2, floor);
ZEND_METHOD(pocketmine_math_Vector2, round);
ZEND_METHOD(pocketmine_math_Vector2, abs);
ZEND_METHOD(pocketmine_math_Vector2, multiply);
ZEND_METHOD(pocketmine_math_Vector2, divide);
ZEND_METHOD(pocketmine_math_Vector2, distance);
ZEND_METHOD(pocketmine_math_Vector2, distanceSquared);
ZEND_METHOD(pocketmine_math_Vector2, length);
ZEND_METHOD(pocketmine_math_Vector2, lengthSquared);
ZEND_METHOD(pocketmine_math_Vector2, normalize);
ZEND_METHOD(pocketmine_math_Vector2, dot);
ZEND_METHOD(pocketmine_math_Vector2, lerp);
ZEND_METHOD(pocketmine_math_Vector2, __toString);
ZEND_METHOD(pocketmine_math_Vector3, __construct);
ZEND_METHOD(pocketmine_math_Vector3, zero);
ZEND_METHOD(pocketmine_math_Vector3, getX);
ZEND_METHOD(pocketmine_math_Vector3, getY);
ZEND_METHOD(pocketmine_math_Vector3, getZ);
ZEND_METHOD(pocketmine_math_Vector3, getFloorX);
ZEND_METHOD(pocketmine_math_Vector3, getFloorY);
ZEND_METHOD(pocketmine_math_Vector3, getFloorZ);
ZEND_METHOD(pocketmine_math_Vector3, add);
ZEND_METHOD(pocketmine_math_Vector3, addVector);
ZEND_METHOD(pocketmine_math_Vector3, subtract);
ZEND_METHOD(pocketmine_math_Vector3, subtractVector);
ZEND_METHOD(pocketmine_math_Vector3, multiply);
ZEND_METHOD(pocketmine_math_Vector3, divide);
ZEND_METHOD(pocketmine_math_Vector3, ceil);
ZEND_METHOD(pocketmine_math_Vector3, floor);
ZEND_METHOD(pocketmine_math_Vector3, round);
ZEND_METHOD(pocketmine_math_Vector3, abs);
ZEND_METHOD(pocketmine_math_Vector3, getSide);
ZEND_METHOD(pocketmine_math_Vector3, down);
ZEND_METHOD(pocketmine_math_Vector3, up);
ZEND_METHOD(pocketmine_math_Vector3, north);
ZEND_METHOD(pocketmine_math_Vector3, south);
ZEND_METHOD(pocketmine_math_Vector3, west);
ZEND_METHOD(pocketmine_math_Vector3, east);
ZEND_METHOD(pocketmine_math_Vector3, sides);
ZEND_METHOD(pocketmine_math_Vector3, sidesArray);
ZEND_METHOD(pocketmine_math_Vector3, sidesAroundAxis);
ZEND_METHOD(pocketmine_math_Vector3, asVector3);
ZEND_METHOD(pocketmine_math_Vector3, distance);
ZEND_METHOD(pocketmine_math_Vector3, distanceSquared);
ZEND_METHOD(pocketmine_math_Vector3, maxPlainDistance);
ZEND_METHOD(pocketmine_math_Vector3, length);
ZEND_METHOD(pocketmine_math_Vector3, lengthSquared);
ZEND_METHOD(pocketmine_math_Vector3, normalize);
ZEND_METHOD(pocketmine_math_Vector3, dot);
ZEND_METHOD(pocketmine_math_Vector3, cross);
ZEND_METHOD(pocketmine_math_Vector3, equals);
ZEND_METHOD(pocketmine_math_Vector3, getIntermediateWithXValue);
ZEND_METHOD(pocketmine_math_Vector3, getIntermediateWithYValue);
ZEND_METHOD(pocketmine_math_Vector3, getIntermediateWithZValue);
ZEND_METHOD(pocketmine_math_Vector3, __toString);
ZEND_METHOD(pocketmine_math_Vector3, withComponents);
ZEND_METHOD(pocketmine_math_Vector3, maxComponents);
ZEND_METHOD(pocketmine_math_Vector3, minComponents);
ZEND_METHOD(pocketmine_math_Vector3, sum);
ZEND_METHOD(pocketmine_math_Vector3, lerp);
ZEND_METHOD(pocketmine_math_Vector3, normalizeOrNull);
ZEND_METHOD(pocketmine_math_Vector3, project);
ZEND_METHOD(pocketmine_math_Vector3, reject);
ZEND_METHOD(pocketmine_math_Vector3, reflect);
ZEND_METHOD(pocketmine_math_Vector3, angle);
ZEND_METHOD(pocketmine_math_Vector3, clamp);
ZEND_METHOD(pocketmine_math_Vector3, moveTowards);
ZEND_METHOD(pocketmine_math_Vector3, isFinite);
ZEND_METHOD(pocketmine_math_RayTraceResult, __construct);
ZEND_METHOD(pocketmine_math_RayTraceResult, getBoundingBox);
ZEND_METHOD(pocketmine_math_RayTraceResult, getHitFace);
ZEND_METHOD(pocketmine_math_RayTraceResult, getHitVector);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, __construct);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, addCoord);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, expand);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, expandedCopy);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, offset);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, offsetCopy);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, offsetTowards);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, offsetTowardsCopy);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, contract);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, contractedCopy);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, extend);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, extendedCopy);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, trim);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, trimmedCopy);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, stretch);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, stretchedCopy);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, squash);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, squashedCopy);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, calculateXOffset);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, calculateYOffset);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, calculateZOffset);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, intersectsWith);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, isVectorInside);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, getAverageEdgeLength);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, getXLength);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, getYLength);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, getZLength);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, isCube);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, getVolume);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, isVectorInYZ);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, isVectorInXZ);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, isVectorInXY);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, calculateIntercept);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, __toString);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, one);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, getCenter);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, closestPoint);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, distanceSquaredTo);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, intersectsSphere);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, intersectsSegment);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, union);
ZEND_METHOD(pocketmine_math_AxisAlignedBB, isFinite);
ZEND_METHOD(pocketmine_math_VoxelRayTrace, __construct);
ZEND_METHOD(pocketmine_math_VoxelRayTrace, inDirection);
ZEND_METHOD(pocketmine_math_VoxelRayTrace, betweenPoints);
ZEND_METHOD(pocketmine_math_Matrix, offsetExists);
ZEND_METHOD(pocketmine_math_Matrix, offsetGet);
ZEND_METHOD(pocketmine_math_Matrix, offsetSet);
ZEND_METHOD(pocketmine_math_Matrix, offsetUnset);
ZEND_METHOD(pocketmine_math_Matrix, __construct);
ZEND_METHOD(pocketmine_math_Matrix, set);
ZEND_METHOD(pocketmine_math_Matrix, getRows);
ZEND_METHOD(pocketmine_math_Matrix, getColumns);
ZEND_METHOD(pocketmine_math_Matrix, setElement);
ZEND_METHOD(pocketmine_math_Matrix, getElement);
ZEND_METHOD(pocketmine_math_Matrix, isSquare);
ZEND_METHOD(pocketmine_math_Matrix, add);
ZEND_METHOD(pocketmine_math_Matrix, subtract);
ZEND_METHOD(pocketmine_math_Matrix, multiplyScalar);
ZEND_METHOD(pocketmine_math_Matrix, divideScalar);
ZEND_METHOD(pocketmine_math_Matrix, transpose);
ZEND_METHOD(pocketmine_math_Matrix, product);
ZEND_METHOD(pocketmine_math_Matrix, determinant);
ZEND_METHOD(pocketmine_math_Matrix, __toString);
ZEND_METHOD(pocketmine_color_Color, __construct);
ZEND_METHOD(pocketmine_color_Color, getA);
ZEND_METHOD(pocketmine_color_Color, getR);
ZEND_METHOD(pocketmine_color_Color, getG);
ZEND_METHOD(pocketmine_color_Color, getB);
ZEND_METHOD(pocketmine_color_Color, mix);
ZEND_METHOD(pocketmine_color_Color, fromRGB);
ZEND_METHOD(pocketmine_color_Color, fromARGB);
ZEND_METHOD(pocketmine_color_Color, toARGB);
ZEND_METHOD(pocketmine_color_Color, fromRGBA);
ZEND_METHOD(pocketmine_color_Color, toRGBA);
ZEND_METHOD(pocketmine_color_Color, equals);
ZEND_METHOD(pocketmine_color_Color, toRGB);
ZEND_METHOD(pocketmine_color_Color, lerp);
ZEND_METHOD(pocketmine_color_Color, blend);
ZEND_METHOD(pocketmine_color_Color, toHSV);
ZEND_METHOD(pocketmine_color_Color, fromHSV);
ZEND_METHOD(pocketmine_color_Color, toHSL);
ZEND_METHOD(pocketmine_color_Color, fromHSL);
ZEND_METHOD(qmath_CollisionRegion, __construct);
ZEND_METHOD(qmath_CollisionRegion, getBounds);
ZEND_METHOD(qmath_CollisionRegion, getVersion);
ZEND_METHOD(qmath_CollisionRegion, isFrozen);
ZEND_METHOD(qmath_CollisionRegion, freeze);
ZEND_METHOD(qmath_CollisionRegion, snapshot);
ZEND_METHOD(qmath_CollisionRegion, contains);
ZEND_METHOD(qmath_CollisionRegion, isKnown);
ZEND_METHOD(qmath_CollisionRegion, setCell);
ZEND_METHOD(qmath_CollisionRegion, setCellPacked);
ZEND_METHOD(qmath_CollisionRegion, fill);
ZEND_METHOD(qmath_CollisionRegion, invalidateCell);
ZEND_METHOD(qmath_CollisionRegion, invalidateBlock);
ZEND_METHOD(qmath_CollisionRegion, invalidateChunk);
ZEND_METHOD(qmath_CollisionRegion, invalidateAll);
ZEND_METHOD(qmath_CollisionRegion, isComplete);
ZEND_METHOD(qmath_CollisionRegion, getCollisionBoxes);
ZEND_METHOD(qmath_CollisionRegion, collides);
ZEND_METHOD(qmath_CollisionRegion, getCellBoxes);
ZEND_METHOD(qmath_CollisionRegion, getCellInfo);
ZEND_METHOD(qmath_MoveResult, __construct);
ZEND_METHOD(qmath_SweepResult, __construct);
ZEND_METHOD(qmath_Collision, __construct);
ZEND_METHOD(qmath_Collision, move);
ZEND_METHOD(qmath_Collision, sweep);
ZEND_METHOD(qmath_Collision, sweepBoxes);
ZEND_METHOD(qmath_VoxelHit, __construct);
ZEND_METHOD(qmath_VoxelRayIterator, __construct);
ZEND_METHOD(qmath_VoxelRayIterator, current);
ZEND_METHOD(qmath_VoxelRayIterator, key);
ZEND_METHOD(qmath_VoxelRayIterator, next);
ZEND_METHOD(qmath_VoxelRayIterator, rewind);
ZEND_METHOD(qmath_VoxelRayIterator, valid);
ZEND_METHOD(qmath_Raycast, __construct);
ZEND_METHOD(qmath_Raycast, voxels);
ZEND_METHOD(qmath_Raycast, blocks);
ZEND_METHOD(qmath_Raycast, lineOfSight);
ZEND_METHOD(qmath_Raycast, boxes);
ZEND_METHOD(qmath_Raycast, batchBlocks);
ZEND_METHOD(qmath_ResistanceGrid, __construct);
ZEND_METHOD(qmath_ResistanceGrid, getBounds);
ZEND_METHOD(qmath_ResistanceGrid, set);
ZEND_METHOD(qmath_ResistanceGrid, setInvalid);
ZEND_METHOD(qmath_ResistanceGrid, fill);
ZEND_METHOD(qmath_ResistanceGrid, setPacked);
ZEND_METHOD(qmath_ExplosionMath, __construct);
ZEND_METHOD(qmath_ExplosionMath, traceRays);
ZEND_METHOD(qmath_ExplosionMath, traceRay);
ZEND_METHOD(qmath_ExplosionMath, rayCount);
ZEND_METHOD(qmath_ExplosionMath, exposure);
ZEND_METHOD(qmath_ExplosionMath, exposures);
ZEND_METHOD(qmath_Simplex, __construct);
ZEND_METHOD(qmath_Simplex, getNoise2D);
ZEND_METHOD(qmath_Simplex, getNoise3D);
ZEND_METHOD(qmath_Simplex, noise2D);
ZEND_METHOD(qmath_Simplex, noise3D);
ZEND_METHOD(qmath_Simplex, getFastNoise1D);
ZEND_METHOD(qmath_Simplex, getFastNoise2D);
ZEND_METHOD(qmath_Simplex, getFastNoise3D);
ZEND_METHOD(qmath_Simplex, getFastNoise3DPacked);
ZEND_METHOD(qmath_Spatial, __construct);
ZEND_METHOD(qmath_Spatial, overlapping);
ZEND_METHOD(qmath_Spatial, overlappingBoxes);
ZEND_METHOD(qmath_Physics, __construct);
ZEND_METHOD(qmath_Physics, motionStep);
ZEND_METHOD(qmath_Physics, knockBack);
ZEND_METHOD(qmath_Physics, directionPlane);
ZEND_METHOD(qmath_Physics, horizontalFacing);
ZEND_METHOD(qmath_Physics, lookAt);
ZEND_METHOD(qmath_Physics, motionRotation);
ZEND_METHOD(qmath_Physics, predictTrajectory);

static const zend_function_entry class_pocketmine_math_Axis_methods[] = {
	ZEND_ME(pocketmine_math_Axis, __construct, arginfo_class_pocketmine_math_Axis___construct, ZEND_ACC_PRIVATE)
	ZEND_ME(pocketmine_math_Axis, toString, arginfo_class_pocketmine_math_Axis_toString, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_FE_END
};

static const zend_function_entry class_pocketmine_math_Facing_methods[] = {
	ZEND_ME(pocketmine_math_Facing, __construct, arginfo_class_pocketmine_math_Facing___construct, ZEND_ACC_PRIVATE)
	ZEND_ME(pocketmine_math_Facing, axis, arginfo_class_pocketmine_math_Facing_axis, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(pocketmine_math_Facing, isPositive, arginfo_class_pocketmine_math_Facing_isPositive, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(pocketmine_math_Facing, opposite, arginfo_class_pocketmine_math_Facing_opposite, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(pocketmine_math_Facing, rotate, arginfo_class_pocketmine_math_Facing_rotate, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(pocketmine_math_Facing, rotateY, arginfo_class_pocketmine_math_Facing_rotateY, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(pocketmine_math_Facing, rotateZ, arginfo_class_pocketmine_math_Facing_rotateZ, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(pocketmine_math_Facing, rotateX, arginfo_class_pocketmine_math_Facing_rotateX, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(pocketmine_math_Facing, validate, arginfo_class_pocketmine_math_Facing_validate, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(pocketmine_math_Facing, toString, arginfo_class_pocketmine_math_Facing_toString, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_FE_END
};

static const zend_function_entry class_pocketmine_math_Math_methods[] = {
	ZEND_ME(pocketmine_math_Math, __construct, arginfo_class_pocketmine_math_Math___construct, ZEND_ACC_PRIVATE)
	ZEND_ME(pocketmine_math_Math, floorFloat, arginfo_class_pocketmine_math_Math_floorFloat, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(pocketmine_math_Math, ceilFloat, arginfo_class_pocketmine_math_Math_ceilFloat, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(pocketmine_math_Math, solveQuadratic, arginfo_class_pocketmine_math_Math_solveQuadratic, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_FE_END
};

static const zend_function_entry class_pocketmine_math_VectorMath_methods[] = {
	ZEND_ME(pocketmine_math_VectorMath, __construct, arginfo_class_pocketmine_math_VectorMath___construct, ZEND_ACC_PRIVATE)
	ZEND_ME(pocketmine_math_VectorMath, getDirection2D, arginfo_class_pocketmine_math_VectorMath_getDirection2D, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(pocketmine_math_VectorMath, getDirection3D, arginfo_class_pocketmine_math_VectorMath_getDirection3D, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_FE_END
};

static const zend_function_entry class_pocketmine_math_Vector2_methods[] = {
	ZEND_ME(pocketmine_math_Vector2, __construct, arginfo_class_pocketmine_math_Vector2___construct, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector2, getX, arginfo_class_pocketmine_math_Vector2_getX, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector2, getY, arginfo_class_pocketmine_math_Vector2_getY, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector2, getFloorX, arginfo_class_pocketmine_math_Vector2_getFloorX, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector2, getFloorY, arginfo_class_pocketmine_math_Vector2_getFloorY, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector2, add, arginfo_class_pocketmine_math_Vector2_add, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector2, addVector, arginfo_class_pocketmine_math_Vector2_addVector, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector2, subtract, arginfo_class_pocketmine_math_Vector2_subtract, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector2, subtractVector, arginfo_class_pocketmine_math_Vector2_subtractVector, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector2, ceil, arginfo_class_pocketmine_math_Vector2_ceil, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector2, floor, arginfo_class_pocketmine_math_Vector2_floor, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector2, round, arginfo_class_pocketmine_math_Vector2_round, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector2, abs, arginfo_class_pocketmine_math_Vector2_abs, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector2, multiply, arginfo_class_pocketmine_math_Vector2_multiply, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector2, divide, arginfo_class_pocketmine_math_Vector2_divide, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector2, distance, arginfo_class_pocketmine_math_Vector2_distance, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector2, distanceSquared, arginfo_class_pocketmine_math_Vector2_distanceSquared, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector2, length, arginfo_class_pocketmine_math_Vector2_length, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector2, lengthSquared, arginfo_class_pocketmine_math_Vector2_lengthSquared, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector2, normalize, arginfo_class_pocketmine_math_Vector2_normalize, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector2, dot, arginfo_class_pocketmine_math_Vector2_dot, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector2, lerp, arginfo_class_pocketmine_math_Vector2_lerp, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector2, __toString, arginfo_class_pocketmine_math_Vector2___toString, ZEND_ACC_PUBLIC)
	ZEND_FE_END
};

static const zend_function_entry class_pocketmine_math_Vector3_methods[] = {
	ZEND_ME(pocketmine_math_Vector3, __construct, arginfo_class_pocketmine_math_Vector3___construct, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, zero, arginfo_class_pocketmine_math_Vector3_zero, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(pocketmine_math_Vector3, getX, arginfo_class_pocketmine_math_Vector3_getX, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, getY, arginfo_class_pocketmine_math_Vector3_getY, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, getZ, arginfo_class_pocketmine_math_Vector3_getZ, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, getFloorX, arginfo_class_pocketmine_math_Vector3_getFloorX, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, getFloorY, arginfo_class_pocketmine_math_Vector3_getFloorY, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, getFloorZ, arginfo_class_pocketmine_math_Vector3_getFloorZ, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, add, arginfo_class_pocketmine_math_Vector3_add, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, addVector, arginfo_class_pocketmine_math_Vector3_addVector, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, subtract, arginfo_class_pocketmine_math_Vector3_subtract, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, subtractVector, arginfo_class_pocketmine_math_Vector3_subtractVector, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, multiply, arginfo_class_pocketmine_math_Vector3_multiply, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, divide, arginfo_class_pocketmine_math_Vector3_divide, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, ceil, arginfo_class_pocketmine_math_Vector3_ceil, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, floor, arginfo_class_pocketmine_math_Vector3_floor, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, round, arginfo_class_pocketmine_math_Vector3_round, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, abs, arginfo_class_pocketmine_math_Vector3_abs, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, getSide, arginfo_class_pocketmine_math_Vector3_getSide, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, down, arginfo_class_pocketmine_math_Vector3_down, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, up, arginfo_class_pocketmine_math_Vector3_up, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, north, arginfo_class_pocketmine_math_Vector3_north, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, south, arginfo_class_pocketmine_math_Vector3_south, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, west, arginfo_class_pocketmine_math_Vector3_west, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, east, arginfo_class_pocketmine_math_Vector3_east, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, sides, arginfo_class_pocketmine_math_Vector3_sides, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, sidesArray, arginfo_class_pocketmine_math_Vector3_sidesArray, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, sidesAroundAxis, arginfo_class_pocketmine_math_Vector3_sidesAroundAxis, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, asVector3, arginfo_class_pocketmine_math_Vector3_asVector3, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, distance, arginfo_class_pocketmine_math_Vector3_distance, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, distanceSquared, arginfo_class_pocketmine_math_Vector3_distanceSquared, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, maxPlainDistance, arginfo_class_pocketmine_math_Vector3_maxPlainDistance, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, length, arginfo_class_pocketmine_math_Vector3_length, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, lengthSquared, arginfo_class_pocketmine_math_Vector3_lengthSquared, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, normalize, arginfo_class_pocketmine_math_Vector3_normalize, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, dot, arginfo_class_pocketmine_math_Vector3_dot, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, cross, arginfo_class_pocketmine_math_Vector3_cross, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, equals, arginfo_class_pocketmine_math_Vector3_equals, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, getIntermediateWithXValue, arginfo_class_pocketmine_math_Vector3_getIntermediateWithXValue, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, getIntermediateWithYValue, arginfo_class_pocketmine_math_Vector3_getIntermediateWithYValue, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, getIntermediateWithZValue, arginfo_class_pocketmine_math_Vector3_getIntermediateWithZValue, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, __toString, arginfo_class_pocketmine_math_Vector3___toString, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, withComponents, arginfo_class_pocketmine_math_Vector3_withComponents, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, maxComponents, arginfo_class_pocketmine_math_Vector3_maxComponents, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(pocketmine_math_Vector3, minComponents, arginfo_class_pocketmine_math_Vector3_minComponents, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(pocketmine_math_Vector3, sum, arginfo_class_pocketmine_math_Vector3_sum, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(pocketmine_math_Vector3, lerp, arginfo_class_pocketmine_math_Vector3_lerp, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, normalizeOrNull, arginfo_class_pocketmine_math_Vector3_normalizeOrNull, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, project, arginfo_class_pocketmine_math_Vector3_project, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, reject, arginfo_class_pocketmine_math_Vector3_reject, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, reflect, arginfo_class_pocketmine_math_Vector3_reflect, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, angle, arginfo_class_pocketmine_math_Vector3_angle, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, clamp, arginfo_class_pocketmine_math_Vector3_clamp, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, moveTowards, arginfo_class_pocketmine_math_Vector3_moveTowards, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Vector3, isFinite, arginfo_class_pocketmine_math_Vector3_isFinite, ZEND_ACC_PUBLIC)
	ZEND_FE_END
};

static const zend_function_entry class_pocketmine_math_RayTraceResult_methods[] = {
	ZEND_ME(pocketmine_math_RayTraceResult, __construct, arginfo_class_pocketmine_math_RayTraceResult___construct, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_RayTraceResult, getBoundingBox, arginfo_class_pocketmine_math_RayTraceResult_getBoundingBox, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_RayTraceResult, getHitFace, arginfo_class_pocketmine_math_RayTraceResult_getHitFace, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_RayTraceResult, getHitVector, arginfo_class_pocketmine_math_RayTraceResult_getHitVector, ZEND_ACC_PUBLIC)
	ZEND_FE_END
};

static const zend_function_entry class_pocketmine_math_AxisAlignedBB_methods[] = {
	ZEND_ME(pocketmine_math_AxisAlignedBB, __construct, arginfo_class_pocketmine_math_AxisAlignedBB___construct, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, addCoord, arginfo_class_pocketmine_math_AxisAlignedBB_addCoord, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, expand, arginfo_class_pocketmine_math_AxisAlignedBB_expand, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, expandedCopy, arginfo_class_pocketmine_math_AxisAlignedBB_expandedCopy, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, offset, arginfo_class_pocketmine_math_AxisAlignedBB_offset, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, offsetCopy, arginfo_class_pocketmine_math_AxisAlignedBB_offsetCopy, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, offsetTowards, arginfo_class_pocketmine_math_AxisAlignedBB_offsetTowards, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, offsetTowardsCopy, arginfo_class_pocketmine_math_AxisAlignedBB_offsetTowardsCopy, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, contract, arginfo_class_pocketmine_math_AxisAlignedBB_contract, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, contractedCopy, arginfo_class_pocketmine_math_AxisAlignedBB_contractedCopy, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, extend, arginfo_class_pocketmine_math_AxisAlignedBB_extend, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, extendedCopy, arginfo_class_pocketmine_math_AxisAlignedBB_extendedCopy, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, trim, arginfo_class_pocketmine_math_AxisAlignedBB_trim, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, trimmedCopy, arginfo_class_pocketmine_math_AxisAlignedBB_trimmedCopy, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, stretch, arginfo_class_pocketmine_math_AxisAlignedBB_stretch, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, stretchedCopy, arginfo_class_pocketmine_math_AxisAlignedBB_stretchedCopy, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, squash, arginfo_class_pocketmine_math_AxisAlignedBB_squash, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, squashedCopy, arginfo_class_pocketmine_math_AxisAlignedBB_squashedCopy, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, calculateXOffset, arginfo_class_pocketmine_math_AxisAlignedBB_calculateXOffset, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, calculateYOffset, arginfo_class_pocketmine_math_AxisAlignedBB_calculateYOffset, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, calculateZOffset, arginfo_class_pocketmine_math_AxisAlignedBB_calculateZOffset, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, intersectsWith, arginfo_class_pocketmine_math_AxisAlignedBB_intersectsWith, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, isVectorInside, arginfo_class_pocketmine_math_AxisAlignedBB_isVectorInside, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, getAverageEdgeLength, arginfo_class_pocketmine_math_AxisAlignedBB_getAverageEdgeLength, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, getXLength, arginfo_class_pocketmine_math_AxisAlignedBB_getXLength, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, getYLength, arginfo_class_pocketmine_math_AxisAlignedBB_getYLength, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, getZLength, arginfo_class_pocketmine_math_AxisAlignedBB_getZLength, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, isCube, arginfo_class_pocketmine_math_AxisAlignedBB_isCube, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, getVolume, arginfo_class_pocketmine_math_AxisAlignedBB_getVolume, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, isVectorInYZ, arginfo_class_pocketmine_math_AxisAlignedBB_isVectorInYZ, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, isVectorInXZ, arginfo_class_pocketmine_math_AxisAlignedBB_isVectorInXZ, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, isVectorInXY, arginfo_class_pocketmine_math_AxisAlignedBB_isVectorInXY, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, calculateIntercept, arginfo_class_pocketmine_math_AxisAlignedBB_calculateIntercept, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, __toString, arginfo_class_pocketmine_math_AxisAlignedBB___toString, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, one, arginfo_class_pocketmine_math_AxisAlignedBB_one, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, getCenter, arginfo_class_pocketmine_math_AxisAlignedBB_getCenter, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, closestPoint, arginfo_class_pocketmine_math_AxisAlignedBB_closestPoint, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, distanceSquaredTo, arginfo_class_pocketmine_math_AxisAlignedBB_distanceSquaredTo, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, intersectsSphere, arginfo_class_pocketmine_math_AxisAlignedBB_intersectsSphere, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, intersectsSegment, arginfo_class_pocketmine_math_AxisAlignedBB_intersectsSegment, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, union, arginfo_class_pocketmine_math_AxisAlignedBB_union, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_AxisAlignedBB, isFinite, arginfo_class_pocketmine_math_AxisAlignedBB_isFinite, ZEND_ACC_PUBLIC)
	ZEND_FE_END
};

static const zend_function_entry class_pocketmine_math_VoxelRayTrace_methods[] = {
	ZEND_ME(pocketmine_math_VoxelRayTrace, __construct, arginfo_class_pocketmine_math_VoxelRayTrace___construct, ZEND_ACC_PRIVATE)
	ZEND_ME(pocketmine_math_VoxelRayTrace, inDirection, arginfo_class_pocketmine_math_VoxelRayTrace_inDirection, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(pocketmine_math_VoxelRayTrace, betweenPoints, arginfo_class_pocketmine_math_VoxelRayTrace_betweenPoints, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_FE_END
};

static const zend_function_entry class_pocketmine_math_Matrix_methods[] = {
	ZEND_ME(pocketmine_math_Matrix, offsetExists, arginfo_class_pocketmine_math_Matrix_offsetExists, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Matrix, offsetGet, arginfo_class_pocketmine_math_Matrix_offsetGet, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Matrix, offsetSet, arginfo_class_pocketmine_math_Matrix_offsetSet, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Matrix, offsetUnset, arginfo_class_pocketmine_math_Matrix_offsetUnset, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Matrix, __construct, arginfo_class_pocketmine_math_Matrix___construct, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Matrix, set, arginfo_class_pocketmine_math_Matrix_set, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Matrix, getRows, arginfo_class_pocketmine_math_Matrix_getRows, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Matrix, getColumns, arginfo_class_pocketmine_math_Matrix_getColumns, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Matrix, setElement, arginfo_class_pocketmine_math_Matrix_setElement, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Matrix, getElement, arginfo_class_pocketmine_math_Matrix_getElement, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Matrix, isSquare, arginfo_class_pocketmine_math_Matrix_isSquare, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Matrix, add, arginfo_class_pocketmine_math_Matrix_add, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Matrix, subtract, arginfo_class_pocketmine_math_Matrix_subtract, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Matrix, multiplyScalar, arginfo_class_pocketmine_math_Matrix_multiplyScalar, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Matrix, divideScalar, arginfo_class_pocketmine_math_Matrix_divideScalar, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Matrix, transpose, arginfo_class_pocketmine_math_Matrix_transpose, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Matrix, product, arginfo_class_pocketmine_math_Matrix_product, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Matrix, determinant, arginfo_class_pocketmine_math_Matrix_determinant, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_math_Matrix, __toString, arginfo_class_pocketmine_math_Matrix___toString, ZEND_ACC_PUBLIC)
	ZEND_FE_END
};

static const zend_function_entry class_pocketmine_color_Color_methods[] = {
	ZEND_ME(pocketmine_color_Color, __construct, arginfo_class_pocketmine_color_Color___construct, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_color_Color, getA, arginfo_class_pocketmine_color_Color_getA, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_color_Color, getR, arginfo_class_pocketmine_color_Color_getR, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_color_Color, getG, arginfo_class_pocketmine_color_Color_getG, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_color_Color, getB, arginfo_class_pocketmine_color_Color_getB, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_color_Color, mix, arginfo_class_pocketmine_color_Color_mix, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(pocketmine_color_Color, fromRGB, arginfo_class_pocketmine_color_Color_fromRGB, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(pocketmine_color_Color, fromARGB, arginfo_class_pocketmine_color_Color_fromARGB, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(pocketmine_color_Color, toARGB, arginfo_class_pocketmine_color_Color_toARGB, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_color_Color, fromRGBA, arginfo_class_pocketmine_color_Color_fromRGBA, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(pocketmine_color_Color, toRGBA, arginfo_class_pocketmine_color_Color_toRGBA, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_color_Color, equals, arginfo_class_pocketmine_color_Color_equals, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_color_Color, toRGB, arginfo_class_pocketmine_color_Color_toRGB, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_color_Color, lerp, arginfo_class_pocketmine_color_Color_lerp, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_color_Color, blend, arginfo_class_pocketmine_color_Color_blend, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_color_Color, toHSV, arginfo_class_pocketmine_color_Color_toHSV, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_color_Color, fromHSV, arginfo_class_pocketmine_color_Color_fromHSV, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(pocketmine_color_Color, toHSL, arginfo_class_pocketmine_color_Color_toHSL, ZEND_ACC_PUBLIC)
	ZEND_ME(pocketmine_color_Color, fromHSL, arginfo_class_pocketmine_color_Color_fromHSL, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_FE_END
};

static const zend_function_entry class_qmath_CollisionRegion_methods[] = {
	ZEND_ME(qmath_CollisionRegion, __construct, arginfo_class_qmath_CollisionRegion___construct, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_CollisionRegion, getBounds, arginfo_class_qmath_CollisionRegion_getBounds, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_CollisionRegion, getVersion, arginfo_class_qmath_CollisionRegion_getVersion, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_CollisionRegion, isFrozen, arginfo_class_qmath_CollisionRegion_isFrozen, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_CollisionRegion, freeze, arginfo_class_qmath_CollisionRegion_freeze, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_CollisionRegion, snapshot, arginfo_class_qmath_CollisionRegion_snapshot, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_CollisionRegion, contains, arginfo_class_qmath_CollisionRegion_contains, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_CollisionRegion, isKnown, arginfo_class_qmath_CollisionRegion_isKnown, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_CollisionRegion, setCell, arginfo_class_qmath_CollisionRegion_setCell, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_CollisionRegion, setCellPacked, arginfo_class_qmath_CollisionRegion_setCellPacked, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_CollisionRegion, fill, arginfo_class_qmath_CollisionRegion_fill, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_CollisionRegion, invalidateCell, arginfo_class_qmath_CollisionRegion_invalidateCell, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_CollisionRegion, invalidateBlock, arginfo_class_qmath_CollisionRegion_invalidateBlock, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_CollisionRegion, invalidateChunk, arginfo_class_qmath_CollisionRegion_invalidateChunk, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_CollisionRegion, invalidateAll, arginfo_class_qmath_CollisionRegion_invalidateAll, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_CollisionRegion, isComplete, arginfo_class_qmath_CollisionRegion_isComplete, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_CollisionRegion, getCollisionBoxes, arginfo_class_qmath_CollisionRegion_getCollisionBoxes, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_CollisionRegion, collides, arginfo_class_qmath_CollisionRegion_collides, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_CollisionRegion, getCellBoxes, arginfo_class_qmath_CollisionRegion_getCellBoxes, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_CollisionRegion, getCellInfo, arginfo_class_qmath_CollisionRegion_getCellInfo, ZEND_ACC_PUBLIC)
	ZEND_FE_END
};

static const zend_function_entry class_qmath_MoveResult_methods[] = {
	ZEND_ME(qmath_MoveResult, __construct, arginfo_class_qmath_MoveResult___construct, ZEND_ACC_PRIVATE)
	ZEND_FE_END
};

static const zend_function_entry class_qmath_SweepResult_methods[] = {
	ZEND_ME(qmath_SweepResult, __construct, arginfo_class_qmath_SweepResult___construct, ZEND_ACC_PRIVATE)
	ZEND_FE_END
};

static const zend_function_entry class_qmath_Collision_methods[] = {
	ZEND_ME(qmath_Collision, __construct, arginfo_class_qmath_Collision___construct, ZEND_ACC_PRIVATE)
	ZEND_ME(qmath_Collision, move, arginfo_class_qmath_Collision_move, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(qmath_Collision, sweep, arginfo_class_qmath_Collision_sweep, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(qmath_Collision, sweepBoxes, arginfo_class_qmath_Collision_sweepBoxes, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_FE_END
};

static const zend_function_entry class_qmath_VoxelHit_methods[] = {
	ZEND_ME(qmath_VoxelHit, __construct, arginfo_class_qmath_VoxelHit___construct, ZEND_ACC_PUBLIC)
	ZEND_FE_END
};

static const zend_function_entry class_qmath_VoxelRayIterator_methods[] = {
	ZEND_ME(qmath_VoxelRayIterator, __construct, arginfo_class_qmath_VoxelRayIterator___construct, ZEND_ACC_PRIVATE)
	ZEND_ME(qmath_VoxelRayIterator, current, arginfo_class_qmath_VoxelRayIterator_current, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_VoxelRayIterator, key, arginfo_class_qmath_VoxelRayIterator_key, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_VoxelRayIterator, next, arginfo_class_qmath_VoxelRayIterator_next, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_VoxelRayIterator, rewind, arginfo_class_qmath_VoxelRayIterator_rewind, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_VoxelRayIterator, valid, arginfo_class_qmath_VoxelRayIterator_valid, ZEND_ACC_PUBLIC)
	ZEND_FE_END
};

static const zend_function_entry class_qmath_Raycast_methods[] = {
	ZEND_ME(qmath_Raycast, __construct, arginfo_class_qmath_Raycast___construct, ZEND_ACC_PRIVATE)
	ZEND_ME(qmath_Raycast, voxels, arginfo_class_qmath_Raycast_voxels, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(qmath_Raycast, blocks, arginfo_class_qmath_Raycast_blocks, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(qmath_Raycast, lineOfSight, arginfo_class_qmath_Raycast_lineOfSight, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(qmath_Raycast, boxes, arginfo_class_qmath_Raycast_boxes, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(qmath_Raycast, batchBlocks, arginfo_class_qmath_Raycast_batchBlocks, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_FE_END
};

static const zend_function_entry class_qmath_ResistanceGrid_methods[] = {
	ZEND_ME(qmath_ResistanceGrid, __construct, arginfo_class_qmath_ResistanceGrid___construct, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_ResistanceGrid, getBounds, arginfo_class_qmath_ResistanceGrid_getBounds, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_ResistanceGrid, set, arginfo_class_qmath_ResistanceGrid_set, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_ResistanceGrid, setInvalid, arginfo_class_qmath_ResistanceGrid_setInvalid, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_ResistanceGrid, fill, arginfo_class_qmath_ResistanceGrid_fill, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_ResistanceGrid, setPacked, arginfo_class_qmath_ResistanceGrid_setPacked, ZEND_ACC_PUBLIC)
	ZEND_FE_END
};

static const zend_function_entry class_qmath_ExplosionMath_methods[] = {
	ZEND_ME(qmath_ExplosionMath, __construct, arginfo_class_qmath_ExplosionMath___construct, ZEND_ACC_PRIVATE)
	ZEND_ME(qmath_ExplosionMath, traceRays, arginfo_class_qmath_ExplosionMath_traceRays, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(qmath_ExplosionMath, traceRay, arginfo_class_qmath_ExplosionMath_traceRay, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(qmath_ExplosionMath, rayCount, arginfo_class_qmath_ExplosionMath_rayCount, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(qmath_ExplosionMath, exposure, arginfo_class_qmath_ExplosionMath_exposure, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(qmath_ExplosionMath, exposures, arginfo_class_qmath_ExplosionMath_exposures, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_FE_END
};

static const zend_function_entry class_qmath_Simplex_methods[] = {
	ZEND_ME(qmath_Simplex, __construct, arginfo_class_qmath_Simplex___construct, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_Simplex, getNoise2D, arginfo_class_qmath_Simplex_getNoise2D, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_Simplex, getNoise3D, arginfo_class_qmath_Simplex_getNoise3D, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_Simplex, noise2D, arginfo_class_qmath_Simplex_noise2D, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_Simplex, noise3D, arginfo_class_qmath_Simplex_noise3D, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_Simplex, getFastNoise1D, arginfo_class_qmath_Simplex_getFastNoise1D, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_Simplex, getFastNoise2D, arginfo_class_qmath_Simplex_getFastNoise2D, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_Simplex, getFastNoise3D, arginfo_class_qmath_Simplex_getFastNoise3D, ZEND_ACC_PUBLIC)
	ZEND_ME(qmath_Simplex, getFastNoise3DPacked, arginfo_class_qmath_Simplex_getFastNoise3DPacked, ZEND_ACC_PUBLIC)
	ZEND_FE_END
};

static const zend_function_entry class_qmath_Spatial_methods[] = {
	ZEND_ME(qmath_Spatial, __construct, arginfo_class_qmath_Spatial___construct, ZEND_ACC_PRIVATE)
	ZEND_ME(qmath_Spatial, overlapping, arginfo_class_qmath_Spatial_overlapping, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(qmath_Spatial, overlappingBoxes, arginfo_class_qmath_Spatial_overlappingBoxes, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_FE_END
};

static const zend_function_entry class_qmath_Physics_methods[] = {
	ZEND_ME(qmath_Physics, __construct, arginfo_class_qmath_Physics___construct, ZEND_ACC_PRIVATE)
	ZEND_ME(qmath_Physics, motionStep, arginfo_class_qmath_Physics_motionStep, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(qmath_Physics, knockBack, arginfo_class_qmath_Physics_knockBack, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(qmath_Physics, directionPlane, arginfo_class_qmath_Physics_directionPlane, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(qmath_Physics, horizontalFacing, arginfo_class_qmath_Physics_horizontalFacing, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(qmath_Physics, lookAt, arginfo_class_qmath_Physics_lookAt, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(qmath_Physics, motionRotation, arginfo_class_qmath_Physics_motionRotation, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(qmath_Physics, predictTrajectory, arginfo_class_qmath_Physics_predictTrajectory, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_FE_END
};

static zend_class_entry *register_class_pocketmine_math_Axis(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "pocketmine\\math", "Axis", class_pocketmine_math_Axis_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, ZEND_ACC_FINAL);

	zval const_Y_value;
	ZVAL_LONG(&const_Y_value, 0);
	zend_string *const_Y_name = zend_string_init_interned("Y", sizeof("Y") - 1, 1);
	zend_declare_class_constant_ex(class_entry, const_Y_name, &const_Y_value, ZEND_ACC_PUBLIC, NULL);
	zend_string_release(const_Y_name);

	zval const_Z_value;
	ZVAL_LONG(&const_Z_value, 1);
	zend_string *const_Z_name = zend_string_init_interned("Z", sizeof("Z") - 1, 1);
	zend_declare_class_constant_ex(class_entry, const_Z_name, &const_Z_value, ZEND_ACC_PUBLIC, NULL);
	zend_string_release(const_Z_name);

	zval const_X_value;
	ZVAL_LONG(&const_X_value, 2);
	zend_string *const_X_name = zend_string_init_interned("X", sizeof("X") - 1, 1);
	zend_declare_class_constant_ex(class_entry, const_X_name, &const_X_value, ZEND_ACC_PUBLIC, NULL);
	zend_string_release(const_X_name);

	return class_entry;
}

static zend_class_entry *register_class_pocketmine_math_Facing(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "pocketmine\\math", "Facing", class_pocketmine_math_Facing_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, ZEND_ACC_FINAL);

	zval const_FLAG_AXIS_POSITIVE_value;
	ZVAL_LONG(&const_FLAG_AXIS_POSITIVE_value, 1);
	zend_string *const_FLAG_AXIS_POSITIVE_name = zend_string_init_interned("FLAG_AXIS_POSITIVE", sizeof("FLAG_AXIS_POSITIVE") - 1, 1);
	zend_declare_class_constant_ex(class_entry, const_FLAG_AXIS_POSITIVE_name, &const_FLAG_AXIS_POSITIVE_value, ZEND_ACC_PUBLIC, NULL);
	zend_string_release(const_FLAG_AXIS_POSITIVE_name);

	zval const_DOWN_value;
	ZVAL_LONG(&const_DOWN_value, 0);
	zend_string *const_DOWN_name = zend_string_init_interned("DOWN", sizeof("DOWN") - 1, 1);
	zend_declare_class_constant_ex(class_entry, const_DOWN_name, &const_DOWN_value, ZEND_ACC_PUBLIC, NULL);
	zend_string_release(const_DOWN_name);

	zval const_UP_value;
	ZVAL_LONG(&const_UP_value, 1);
	zend_string *const_UP_name = zend_string_init_interned("UP", sizeof("UP") - 1, 1);
	zend_declare_class_constant_ex(class_entry, const_UP_name, &const_UP_value, ZEND_ACC_PUBLIC, NULL);
	zend_string_release(const_UP_name);

	zval const_NORTH_value;
	ZVAL_LONG(&const_NORTH_value, 2);
	zend_string *const_NORTH_name = zend_string_init_interned("NORTH", sizeof("NORTH") - 1, 1);
	zend_declare_class_constant_ex(class_entry, const_NORTH_name, &const_NORTH_value, ZEND_ACC_PUBLIC, NULL);
	zend_string_release(const_NORTH_name);

	zval const_SOUTH_value;
	ZVAL_LONG(&const_SOUTH_value, 3);
	zend_string *const_SOUTH_name = zend_string_init_interned("SOUTH", sizeof("SOUTH") - 1, 1);
	zend_declare_class_constant_ex(class_entry, const_SOUTH_name, &const_SOUTH_value, ZEND_ACC_PUBLIC, NULL);
	zend_string_release(const_SOUTH_name);

	zval const_WEST_value;
	ZVAL_LONG(&const_WEST_value, 4);
	zend_string *const_WEST_name = zend_string_init_interned("WEST", sizeof("WEST") - 1, 1);
	zend_declare_class_constant_ex(class_entry, const_WEST_name, &const_WEST_value, ZEND_ACC_PUBLIC, NULL);
	zend_string_release(const_WEST_name);

	zval const_EAST_value;
	ZVAL_LONG(&const_EAST_value, 5);
	zend_string *const_EAST_name = zend_string_init_interned("EAST", sizeof("EAST") - 1, 1);
	zend_declare_class_constant_ex(class_entry, const_EAST_name, &const_EAST_value, ZEND_ACC_PUBLIC, NULL);
	zend_string_release(const_EAST_name);

	return class_entry;
}

static zend_class_entry *register_class_pocketmine_math_Math(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "pocketmine\\math", "Math", class_pocketmine_math_Math_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, ZEND_ACC_FINAL);

	return class_entry;
}

static zend_class_entry *register_class_pocketmine_math_VectorMath(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "pocketmine\\math", "VectorMath", class_pocketmine_math_VectorMath_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, ZEND_ACC_FINAL);

	return class_entry;
}

static zend_class_entry *register_class_pocketmine_math_Vector2(zend_class_entry *class_entry_Stringable)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "pocketmine\\math", "Vector2", class_pocketmine_math_Vector2_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, 0);
	zend_class_implements(class_entry, 1, class_entry_Stringable);

	zval property_x_default_value;
	ZVAL_UNDEF(&property_x_default_value);
	zend_string *property_x_name = zend_string_init("x", sizeof("x") - 1, 1);
	zend_declare_typed_property(class_entry, property_x_name, &property_x_default_value, ZEND_ACC_PUBLIC, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_DOUBLE));
	zend_string_release(property_x_name);

	zval property_y_default_value;
	ZVAL_UNDEF(&property_y_default_value);
	zend_string *property_y_name = zend_string_init("y", sizeof("y") - 1, 1);
	zend_declare_typed_property(class_entry, property_y_name, &property_y_default_value, ZEND_ACC_PUBLIC, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_DOUBLE));
	zend_string_release(property_y_name);

	return class_entry;
}

static zend_class_entry *register_class_pocketmine_math_Vector3(zend_class_entry *class_entry_Stringable)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "pocketmine\\math", "Vector3", class_pocketmine_math_Vector3_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, 0);
	zend_class_implements(class_entry, 1, class_entry_Stringable);

	zval property_x_default_value;
	ZVAL_UNDEF(&property_x_default_value);
	zend_string *property_x_name = zend_string_init("x", sizeof("x") - 1, 1);
	zend_declare_typed_property(class_entry, property_x_name, &property_x_default_value, ZEND_ACC_PUBLIC, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_DOUBLE|MAY_BE_LONG));
	zend_string_release(property_x_name);

	zval property_y_default_value;
	ZVAL_UNDEF(&property_y_default_value);
	zend_string *property_y_name = zend_string_init("y", sizeof("y") - 1, 1);
	zend_declare_typed_property(class_entry, property_y_name, &property_y_default_value, ZEND_ACC_PUBLIC, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_DOUBLE|MAY_BE_LONG));
	zend_string_release(property_y_name);

	zval property_z_default_value;
	ZVAL_UNDEF(&property_z_default_value);
	zend_string *property_z_name = zend_string_init("z", sizeof("z") - 1, 1);
	zend_declare_typed_property(class_entry, property_z_name, &property_z_default_value, ZEND_ACC_PUBLIC, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_DOUBLE|MAY_BE_LONG));
	zend_string_release(property_z_name);

	return class_entry;
}

static zend_class_entry *register_class_pocketmine_math_RayTraceResult(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "pocketmine\\math", "RayTraceResult", class_pocketmine_math_RayTraceResult_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, 0);

	zval property_bb_default_value;
	ZVAL_UNDEF(&property_bb_default_value);
	zend_string *property_bb_name = zend_string_init("bb", sizeof("bb") - 1, 1);
	zend_string *property_bb_class_pocketmine_math_AxisAlignedBB = zend_string_init("pocketmine\\math\\AxisAlignedBB", sizeof("pocketmine\\math\\AxisAlignedBB")-1, 1);
	zend_declare_typed_property(class_entry, property_bb_name, &property_bb_default_value, ZEND_ACC_PUBLIC, NULL, (zend_type) ZEND_TYPE_INIT_CLASS(property_bb_class_pocketmine_math_AxisAlignedBB, 0, 0));
	zend_string_release(property_bb_name);

	zval property_hitFace_default_value;
	ZVAL_UNDEF(&property_hitFace_default_value);
	zend_string *property_hitFace_name = zend_string_init("hitFace", sizeof("hitFace") - 1, 1);
	zend_declare_typed_property(class_entry, property_hitFace_name, &property_hitFace_default_value, ZEND_ACC_PUBLIC, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_LONG));
	zend_string_release(property_hitFace_name);

	zval property_hitVector_default_value;
	ZVAL_UNDEF(&property_hitVector_default_value);
	zend_string *property_hitVector_name = zend_string_init("hitVector", sizeof("hitVector") - 1, 1);
	zend_string *property_hitVector_class_pocketmine_math_Vector3 = zend_string_init("pocketmine\\math\\Vector3", sizeof("pocketmine\\math\\Vector3")-1, 1);
	zend_declare_typed_property(class_entry, property_hitVector_name, &property_hitVector_default_value, ZEND_ACC_PUBLIC, NULL, (zend_type) ZEND_TYPE_INIT_CLASS(property_hitVector_class_pocketmine_math_Vector3, 0, 0));
	zend_string_release(property_hitVector_name);

	return class_entry;
}

static zend_class_entry *register_class_pocketmine_math_AxisAlignedBB(zend_class_entry *class_entry_Stringable)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "pocketmine\\math", "AxisAlignedBB", class_pocketmine_math_AxisAlignedBB_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, ZEND_ACC_FINAL);
	zend_class_implements(class_entry, 1, class_entry_Stringable);

	zval property_minX_default_value;
	ZVAL_UNDEF(&property_minX_default_value);
	zend_string *property_minX_name = zend_string_init("minX", sizeof("minX") - 1, 1);
	zend_declare_typed_property(class_entry, property_minX_name, &property_minX_default_value, ZEND_ACC_PUBLIC, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_DOUBLE));
	zend_string_release(property_minX_name);

	zval property_minY_default_value;
	ZVAL_UNDEF(&property_minY_default_value);
	zend_string *property_minY_name = zend_string_init("minY", sizeof("minY") - 1, 1);
	zend_declare_typed_property(class_entry, property_minY_name, &property_minY_default_value, ZEND_ACC_PUBLIC, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_DOUBLE));
	zend_string_release(property_minY_name);

	zval property_minZ_default_value;
	ZVAL_UNDEF(&property_minZ_default_value);
	zend_string *property_minZ_name = zend_string_init("minZ", sizeof("minZ") - 1, 1);
	zend_declare_typed_property(class_entry, property_minZ_name, &property_minZ_default_value, ZEND_ACC_PUBLIC, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_DOUBLE));
	zend_string_release(property_minZ_name);

	zval property_maxX_default_value;
	ZVAL_UNDEF(&property_maxX_default_value);
	zend_string *property_maxX_name = zend_string_init("maxX", sizeof("maxX") - 1, 1);
	zend_declare_typed_property(class_entry, property_maxX_name, &property_maxX_default_value, ZEND_ACC_PUBLIC, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_DOUBLE));
	zend_string_release(property_maxX_name);

	zval property_maxY_default_value;
	ZVAL_UNDEF(&property_maxY_default_value);
	zend_string *property_maxY_name = zend_string_init("maxY", sizeof("maxY") - 1, 1);
	zend_declare_typed_property(class_entry, property_maxY_name, &property_maxY_default_value, ZEND_ACC_PUBLIC, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_DOUBLE));
	zend_string_release(property_maxY_name);

	zval property_maxZ_default_value;
	ZVAL_UNDEF(&property_maxZ_default_value);
	zend_string *property_maxZ_name = zend_string_init("maxZ", sizeof("maxZ") - 1, 1);
	zend_declare_typed_property(class_entry, property_maxZ_name, &property_maxZ_default_value, ZEND_ACC_PUBLIC, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_DOUBLE));
	zend_string_release(property_maxZ_name);

	return class_entry;
}

static zend_class_entry *register_class_pocketmine_math_VoxelRayTrace(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "pocketmine\\math", "VoxelRayTrace", class_pocketmine_math_VoxelRayTrace_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, ZEND_ACC_FINAL);

	return class_entry;
}

static zend_class_entry *register_class_pocketmine_math_Matrix(zend_class_entry *class_entry_ArrayAccess)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "pocketmine\\math", "Matrix", class_pocketmine_math_Matrix_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, 0);
	zend_class_implements(class_entry, 1, class_entry_ArrayAccess);

	zval property_matrix_default_value;
	ZVAL_EMPTY_ARRAY(&property_matrix_default_value);
	zend_string *property_matrix_name = zend_string_init("matrix", sizeof("matrix") - 1, 1);
	zend_declare_typed_property(class_entry, property_matrix_name, &property_matrix_default_value, ZEND_ACC_PRIVATE, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_ARRAY));
	zend_string_release(property_matrix_name);

	zval property_rows_default_value;
	ZVAL_UNDEF(&property_rows_default_value);
	zend_string *property_rows_name = zend_string_init("rows", sizeof("rows") - 1, 1);
	zend_declare_typed_property(class_entry, property_rows_name, &property_rows_default_value, ZEND_ACC_PRIVATE, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_LONG));
	zend_string_release(property_rows_name);

	zval property_columns_default_value;
	ZVAL_UNDEF(&property_columns_default_value);
	zend_string *property_columns_name = zend_string_init("columns", sizeof("columns") - 1, 1);
	zend_declare_typed_property(class_entry, property_columns_name, &property_columns_default_value, ZEND_ACC_PRIVATE, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_LONG));
	zend_string_release(property_columns_name);

	return class_entry;
}

static zend_class_entry *register_class_pocketmine_color_Color(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "pocketmine\\color", "Color", class_pocketmine_color_Color_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, ZEND_ACC_FINAL);

	zval property_a_default_value;
	ZVAL_UNDEF(&property_a_default_value);
	zend_string *property_a_name = zend_string_init("a", sizeof("a") - 1, 1);
	zend_declare_typed_property(class_entry, property_a_name, &property_a_default_value, ZEND_ACC_PRIVATE, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_LONG));
	zend_string_release(property_a_name);

	zval property_r_default_value;
	ZVAL_UNDEF(&property_r_default_value);
	zend_string *property_r_name = zend_string_init("r", sizeof("r") - 1, 1);
	zend_declare_typed_property(class_entry, property_r_name, &property_r_default_value, ZEND_ACC_PRIVATE, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_LONG));
	zend_string_release(property_r_name);

	zval property_g_default_value;
	ZVAL_UNDEF(&property_g_default_value);
	zend_string *property_g_name = zend_string_init("g", sizeof("g") - 1, 1);
	zend_declare_typed_property(class_entry, property_g_name, &property_g_default_value, ZEND_ACC_PRIVATE, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_LONG));
	zend_string_release(property_g_name);

	zval property_b_default_value;
	ZVAL_UNDEF(&property_b_default_value);
	zend_string *property_b_name = zend_string_init("b", sizeof("b") - 1, 1);
	zend_declare_typed_property(class_entry, property_b_name, &property_b_default_value, ZEND_ACC_PRIVATE, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_LONG));
	zend_string_release(property_b_name);

	return class_entry;
}

static zend_class_entry *register_class_qmath_CollisionDataException(zend_class_entry *class_entry_RuntimeException)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "qmath", "CollisionDataException", NULL);
	class_entry = zend_register_internal_class_with_flags(&ce, class_entry_RuntimeException, 0);

	return class_entry;
}

static zend_class_entry *register_class_qmath_CollisionRegion(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "qmath", "CollisionRegion", class_qmath_CollisionRegion_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, ZEND_ACC_FINAL);

	zval const_INFO_CUSTOM_value;
	ZVAL_LONG(&const_INFO_CUSTOM_value, 0);
	zend_string *const_INFO_CUSTOM_name = zend_string_init_interned("INFO_CUSTOM", sizeof("INFO_CUSTOM") - 1, 1);
	zend_declare_class_constant_ex(class_entry, const_INFO_CUSTOM_name, &const_INFO_CUSTOM_value, ZEND_ACC_PUBLIC, NULL);
	zend_string_release(const_INFO_CUSTOM_name);

	zval const_INFO_CUBE_value;
	ZVAL_LONG(&const_INFO_CUBE_value, 1);
	zend_string *const_INFO_CUBE_name = zend_string_init_interned("INFO_CUBE", sizeof("INFO_CUBE") - 1, 1);
	zend_declare_class_constant_ex(class_entry, const_INFO_CUBE_name, &const_INFO_CUBE_value, ZEND_ACC_PUBLIC, NULL);
	zend_string_release(const_INFO_CUBE_name);

	zval const_INFO_NONE_value;
	ZVAL_LONG(&const_INFO_NONE_value, 2);
	zend_string *const_INFO_NONE_name = zend_string_init_interned("INFO_NONE", sizeof("INFO_NONE") - 1, 1);
	zend_declare_class_constant_ex(class_entry, const_INFO_NONE_name, &const_INFO_NONE_value, ZEND_ACC_PUBLIC, NULL);
	zend_string_release(const_INFO_NONE_name);

	zval const_INFO_MAY_OVERFLOW_value;
	ZVAL_LONG(&const_INFO_MAY_OVERFLOW_value, 3);
	zend_string *const_INFO_MAY_OVERFLOW_name = zend_string_init_interned("INFO_MAY_OVERFLOW", sizeof("INFO_MAY_OVERFLOW") - 1, 1);
	zend_declare_class_constant_ex(class_entry, const_INFO_MAY_OVERFLOW_name, &const_INFO_MAY_OVERFLOW_value, ZEND_ACC_PUBLIC, NULL);
	zend_string_release(const_INFO_MAY_OVERFLOW_name);

	zval const_MAX_CELLS_value;
	ZVAL_LONG(&const_MAX_CELLS_value, 4194304);
	zend_string *const_MAX_CELLS_name = zend_string_init_interned("MAX_CELLS", sizeof("MAX_CELLS") - 1, 1);
	zend_declare_class_constant_ex(class_entry, const_MAX_CELLS_name, &const_MAX_CELLS_value, ZEND_ACC_PUBLIC, NULL);
	zend_string_release(const_MAX_CELLS_name);

	zval const_MAX_BOXES_PER_CELL_value;
	ZVAL_LONG(&const_MAX_BOXES_PER_CELL_value, 64);
	zend_string *const_MAX_BOXES_PER_CELL_name = zend_string_init_interned("MAX_BOXES_PER_CELL", sizeof("MAX_BOXES_PER_CELL") - 1, 1);
	zend_declare_class_constant_ex(class_entry, const_MAX_BOXES_PER_CELL_name, &const_MAX_BOXES_PER_CELL_value, ZEND_ACC_PUBLIC, NULL);
	zend_string_release(const_MAX_BOXES_PER_CELL_name);

	return class_entry;
}

static zend_class_entry *register_class_qmath_MoveResult(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "qmath", "MoveResult", class_qmath_MoveResult_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, ZEND_ACC_FINAL);

	zval property_dx_default_value;
	ZVAL_UNDEF(&property_dx_default_value);
	zend_string *property_dx_name = zend_string_init("dx", sizeof("dx") - 1, 1);
	zend_declare_typed_property(class_entry, property_dx_name, &property_dx_default_value, ZEND_ACC_PUBLIC|ZEND_ACC_READONLY, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_DOUBLE));
	zend_string_release(property_dx_name);

	zval property_dy_default_value;
	ZVAL_UNDEF(&property_dy_default_value);
	zend_string *property_dy_name = zend_string_init("dy", sizeof("dy") - 1, 1);
	zend_declare_typed_property(class_entry, property_dy_name, &property_dy_default_value, ZEND_ACC_PUBLIC|ZEND_ACC_READONLY, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_DOUBLE));
	zend_string_release(property_dy_name);

	zval property_dz_default_value;
	ZVAL_UNDEF(&property_dz_default_value);
	zend_string *property_dz_name = zend_string_init("dz", sizeof("dz") - 1, 1);
	zend_declare_typed_property(class_entry, property_dz_name, &property_dz_default_value, ZEND_ACC_PUBLIC|ZEND_ACC_READONLY, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_DOUBLE));
	zend_string_release(property_dz_name);

	zval property_boundingBox_default_value;
	ZVAL_UNDEF(&property_boundingBox_default_value);
	zend_string *property_boundingBox_name = zend_string_init("boundingBox", sizeof("boundingBox") - 1, 1);
	zend_string *property_boundingBox_class_pocketmine_math_AxisAlignedBB = zend_string_init("pocketmine\\math\\AxisAlignedBB", sizeof("pocketmine\\math\\AxisAlignedBB")-1, 1);
	zend_declare_typed_property(class_entry, property_boundingBox_name, &property_boundingBox_default_value, ZEND_ACC_PUBLIC|ZEND_ACC_READONLY, NULL, (zend_type) ZEND_TYPE_INIT_CLASS(property_boundingBox_class_pocketmine_math_AxisAlignedBB, 0, 0));
	zend_string_release(property_boundingBox_name);

	zval property_collidedX_default_value;
	ZVAL_UNDEF(&property_collidedX_default_value);
	zend_string *property_collidedX_name = zend_string_init("collidedX", sizeof("collidedX") - 1, 1);
	zend_declare_typed_property(class_entry, property_collidedX_name, &property_collidedX_default_value, ZEND_ACC_PUBLIC|ZEND_ACC_READONLY, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_BOOL));
	zend_string_release(property_collidedX_name);

	zval property_collidedY_default_value;
	ZVAL_UNDEF(&property_collidedY_default_value);
	zend_string *property_collidedY_name = zend_string_init("collidedY", sizeof("collidedY") - 1, 1);
	zend_declare_typed_property(class_entry, property_collidedY_name, &property_collidedY_default_value, ZEND_ACC_PUBLIC|ZEND_ACC_READONLY, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_BOOL));
	zend_string_release(property_collidedY_name);

	zval property_collidedZ_default_value;
	ZVAL_UNDEF(&property_collidedZ_default_value);
	zend_string *property_collidedZ_name = zend_string_init("collidedZ", sizeof("collidedZ") - 1, 1);
	zend_declare_typed_property(class_entry, property_collidedZ_name, &property_collidedZ_default_value, ZEND_ACC_PUBLIC|ZEND_ACC_READONLY, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_BOOL));
	zend_string_release(property_collidedZ_name);

	zval property_collidedHorizontally_default_value;
	ZVAL_UNDEF(&property_collidedHorizontally_default_value);
	zend_string *property_collidedHorizontally_name = zend_string_init("collidedHorizontally", sizeof("collidedHorizontally") - 1, 1);
	zend_declare_typed_property(class_entry, property_collidedHorizontally_name, &property_collidedHorizontally_default_value, ZEND_ACC_PUBLIC|ZEND_ACC_READONLY, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_BOOL));
	zend_string_release(property_collidedHorizontally_name);

	zval property_collidedVertically_default_value;
	ZVAL_UNDEF(&property_collidedVertically_default_value);
	zend_string *property_collidedVertically_name = zend_string_init("collidedVertically", sizeof("collidedVertically") - 1, 1);
	zend_declare_typed_property(class_entry, property_collidedVertically_name, &property_collidedVertically_default_value, ZEND_ACC_PUBLIC|ZEND_ACC_READONLY, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_BOOL));
	zend_string_release(property_collidedVertically_name);

	zval property_onGround_default_value;
	ZVAL_UNDEF(&property_onGround_default_value);
	zend_string *property_onGround_name = zend_string_init("onGround", sizeof("onGround") - 1, 1);
	zend_declare_typed_property(class_entry, property_onGround_name, &property_onGround_default_value, ZEND_ACC_PUBLIC|ZEND_ACC_READONLY, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_BOOL));
	zend_string_release(property_onGround_name);

	zval property_stepped_default_value;
	ZVAL_UNDEF(&property_stepped_default_value);
	zend_string *property_stepped_name = zend_string_init("stepped", sizeof("stepped") - 1, 1);
	zend_declare_typed_property(class_entry, property_stepped_name, &property_stepped_default_value, ZEND_ACC_PUBLIC|ZEND_ACC_READONLY, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_BOOL));
	zend_string_release(property_stepped_name);

	return class_entry;
}

static zend_class_entry *register_class_qmath_SweepResult(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "qmath", "SweepResult", class_qmath_SweepResult_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, ZEND_ACC_FINAL);

	zval property_time_default_value;
	ZVAL_UNDEF(&property_time_default_value);
	zend_string *property_time_name = zend_string_init("time", sizeof("time") - 1, 1);
	zend_declare_typed_property(class_entry, property_time_name, &property_time_default_value, ZEND_ACC_PUBLIC|ZEND_ACC_READONLY, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_DOUBLE));
	zend_string_release(property_time_name);

	zval property_face_default_value;
	ZVAL_UNDEF(&property_face_default_value);
	zend_string *property_face_name = zend_string_init("face", sizeof("face") - 1, 1);
	zend_declare_typed_property(class_entry, property_face_name, &property_face_default_value, ZEND_ACC_PUBLIC|ZEND_ACC_READONLY, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_LONG));
	zend_string_release(property_face_name);

	zval property_box_default_value;
	ZVAL_UNDEF(&property_box_default_value);
	zend_string *property_box_name = zend_string_init("box", sizeof("box") - 1, 1);
	zend_string *property_box_class_pocketmine_math_AxisAlignedBB = zend_string_init("pocketmine\\math\\AxisAlignedBB", sizeof("pocketmine\\math\\AxisAlignedBB")-1, 1);
	zend_declare_typed_property(class_entry, property_box_name, &property_box_default_value, ZEND_ACC_PUBLIC|ZEND_ACC_READONLY, NULL, (zend_type) ZEND_TYPE_INIT_CLASS(property_box_class_pocketmine_math_AxisAlignedBB, 0, 0));
	zend_string_release(property_box_name);

	zval property_key_default_value;
	ZVAL_UNDEF(&property_key_default_value);
	zend_declare_typed_property(class_entry, ZSTR_KNOWN(ZEND_STR_KEY), &property_key_default_value, ZEND_ACC_PUBLIC|ZEND_ACC_READONLY, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_LONG|MAY_BE_STRING));

	return class_entry;
}

static zend_class_entry *register_class_qmath_Collision(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "qmath", "Collision", class_qmath_Collision_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, ZEND_ACC_FINAL);

	return class_entry;
}

static zend_class_entry *register_class_qmath_VoxelHit(zend_class_entry *class_entry_pocketmine_math_RayTraceResult)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "qmath", "VoxelHit", class_qmath_VoxelHit_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, class_entry_pocketmine_math_RayTraceResult, ZEND_ACC_FINAL);

	zval property_blockX_default_value;
	ZVAL_UNDEF(&property_blockX_default_value);
	zend_string *property_blockX_name = zend_string_init("blockX", sizeof("blockX") - 1, 1);
	zend_declare_typed_property(class_entry, property_blockX_name, &property_blockX_default_value, ZEND_ACC_PUBLIC, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_LONG));
	zend_string_release(property_blockX_name);

	zval property_blockY_default_value;
	ZVAL_UNDEF(&property_blockY_default_value);
	zend_string *property_blockY_name = zend_string_init("blockY", sizeof("blockY") - 1, 1);
	zend_declare_typed_property(class_entry, property_blockY_name, &property_blockY_default_value, ZEND_ACC_PUBLIC, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_LONG));
	zend_string_release(property_blockY_name);

	zval property_blockZ_default_value;
	ZVAL_UNDEF(&property_blockZ_default_value);
	zend_string *property_blockZ_name = zend_string_init("blockZ", sizeof("blockZ") - 1, 1);
	zend_declare_typed_property(class_entry, property_blockZ_name, &property_blockZ_default_value, ZEND_ACC_PUBLIC, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_LONG));
	zend_string_release(property_blockZ_name);

	return class_entry;
}

static zend_class_entry *register_class_qmath_VoxelRayIterator(zend_class_entry *class_entry_Iterator)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "qmath", "VoxelRayIterator", class_qmath_VoxelRayIterator_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, ZEND_ACC_FINAL);
	zend_class_implements(class_entry, 1, class_entry_Iterator);

	return class_entry;
}

static zend_class_entry *register_class_qmath_Raycast(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "qmath", "Raycast", class_qmath_Raycast_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, ZEND_ACC_FINAL);

	return class_entry;
}

static zend_class_entry *register_class_qmath_ResistanceGrid(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "qmath", "ResistanceGrid", class_qmath_ResistanceGrid_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, ZEND_ACC_FINAL);

	return class_entry;
}

static zend_class_entry *register_class_qmath_ExplosionMath(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "qmath", "ExplosionMath", class_qmath_ExplosionMath_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, ZEND_ACC_FINAL);

	return class_entry;
}

static zend_class_entry *register_class_qmath_Simplex(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "qmath", "Simplex", class_qmath_Simplex_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, ZEND_ACC_FINAL);

	return class_entry;
}

static zend_class_entry *register_class_qmath_Spatial(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "qmath", "Spatial", class_qmath_Spatial_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, ZEND_ACC_FINAL);

	return class_entry;
}

static zend_class_entry *register_class_qmath_Physics(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "qmath", "Physics", class_qmath_Physics_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, ZEND_ACC_FINAL);

	return class_entry;
}
