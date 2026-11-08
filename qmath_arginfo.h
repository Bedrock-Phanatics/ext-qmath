/* This is a generated file, edit the .stub.php file instead.
 * Stub hash: b599a3e064b844ccda65116b4996369a1e916e09 */

ZEND_BEGIN_ARG_INFO_EX(arginfo_class_quark_math_Axis___construct, 0, 0, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_Axis_toString, 0, 1, IS_STRING, 0)
	ZEND_ARG_TYPE_INFO(0, axis, IS_LONG, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_Facing___construct arginfo_class_quark_math_Axis___construct

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_Facing_axis, 0, 1, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, direction, IS_LONG, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_Facing_isPositive, 0, 1, _IS_BOOL, 0)
	ZEND_ARG_TYPE_INFO(0, direction, IS_LONG, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_Facing_opposite arginfo_class_quark_math_Facing_axis

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_Facing_rotate, 0, 3, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, direction, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, axis, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, clockwise, _IS_BOOL, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_Facing_rotateY, 0, 2, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, direction, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, clockwise, _IS_BOOL, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_Facing_rotateZ arginfo_class_quark_math_Facing_rotateY

#define arginfo_class_quark_math_Facing_rotateX arginfo_class_quark_math_Facing_rotateY

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_Facing_validate, 0, 1, IS_VOID, 0)
	ZEND_ARG_TYPE_INFO(0, facing, IS_LONG, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_Facing_toString, 0, 1, IS_STRING, 0)
	ZEND_ARG_TYPE_INFO(0, facing, IS_LONG, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_Math___construct arginfo_class_quark_math_Axis___construct

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_Math_floorFloat, 0, 1, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, n, IS_MIXED, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_Math_ceilFloat arginfo_class_quark_math_Math_floorFloat

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_Math_solveQuadratic, 0, 3, IS_ARRAY, 0)
	ZEND_ARG_TYPE_INFO(0, a, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, b, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, c, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_VectorMath___construct arginfo_class_quark_math_Axis___construct

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_VectorMath_getDirection2D, 0, 1, quark\\math\\Vector2, 0)
	ZEND_ARG_TYPE_INFO(0, azimuth, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_VectorMath_getDirection3D, 0, 2, quark\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO(0, yaw, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, pitch, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_INFO_EX(arginfo_class_quark_math_Vector2___construct, 0, 0, 2)
	ZEND_ARG_TYPE_INFO(0, x, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_Vector2_getFloorX, 0, 0, IS_LONG, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_Vector2_getFloorY arginfo_class_quark_math_Vector2_getFloorX

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_Vector2_add, 0, 2, quark\\math\\Vector2, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_Vector2_addVector, 0, 1, quark\\math\\Vector2, 0)
	ZEND_ARG_OBJ_INFO(0, vector2, quark\\math\\Vector2, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_Vector2_subtract arginfo_class_quark_math_Vector2_add

#define arginfo_class_quark_math_Vector2_subtractVector arginfo_class_quark_math_Vector2_addVector

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_Vector2_ceil, 0, 0, quark\\math\\Vector2, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_Vector2_floor arginfo_class_quark_math_Vector2_ceil

#define arginfo_class_quark_math_Vector2_round arginfo_class_quark_math_Vector2_ceil

#define arginfo_class_quark_math_Vector2_abs arginfo_class_quark_math_Vector2_ceil

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_Vector2_multiply, 0, 1, quark\\math\\Vector2, 0)
	ZEND_ARG_TYPE_INFO(0, number, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_Vector2_divide arginfo_class_quark_math_Vector2_multiply

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_Vector2_distance, 0, 1, IS_DOUBLE, 0)
	ZEND_ARG_OBJ_INFO(0, pos, quark\\math\\Vector2, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_Vector2_distanceSquared arginfo_class_quark_math_Vector2_distance

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_Vector2_length, 0, 0, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_Vector2_lengthSquared arginfo_class_quark_math_Vector2_length

#define arginfo_class_quark_math_Vector2_normalize arginfo_class_quark_math_Vector2_ceil

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_Vector2_dot, 0, 1, IS_DOUBLE, 0)
	ZEND_ARG_OBJ_INFO(0, v, quark\\math\\Vector2, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_Vector2_lerp, 0, 2, quark\\math\\Vector2, 0)
	ZEND_ARG_OBJ_INFO(0, to, quark\\math\\Vector2, 0)
	ZEND_ARG_TYPE_INFO(0, t, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_Vector2___toString, 0, 0, IS_STRING, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_INFO_EX(arginfo_class_quark_math_Vector3___construct, 0, 0, 3)
	ZEND_ARG_TYPE_MASK(0, x, MAY_BE_DOUBLE|MAY_BE_LONG, NULL)
	ZEND_ARG_TYPE_MASK(0, y, MAY_BE_DOUBLE|MAY_BE_LONG, NULL)
	ZEND_ARG_TYPE_MASK(0, z, MAY_BE_DOUBLE|MAY_BE_LONG, NULL)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_Vector3_zero, 0, 0, quark\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_Vector3_getFloorX arginfo_class_quark_math_Vector2_getFloorX

#define arginfo_class_quark_math_Vector3_getFloorY arginfo_class_quark_math_Vector2_getFloorX

#define arginfo_class_quark_math_Vector3_getFloorZ arginfo_class_quark_math_Vector2_getFloorX

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_Vector3_add, 0, 3, quark\\math\\Vector3, 0)
	ZEND_ARG_TYPE_MASK(0, x, MAY_BE_DOUBLE|MAY_BE_LONG, NULL)
	ZEND_ARG_TYPE_MASK(0, y, MAY_BE_DOUBLE|MAY_BE_LONG, NULL)
	ZEND_ARG_TYPE_MASK(0, z, MAY_BE_DOUBLE|MAY_BE_LONG, NULL)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_Vector3_addVector, 0, 1, quark\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, v, quark\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_Vector3_subtract arginfo_class_quark_math_Vector3_add

#define arginfo_class_quark_math_Vector3_subtractVector arginfo_class_quark_math_Vector3_addVector

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_Vector3_multiply, 0, 1, quark\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO(0, number, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_Vector3_divide arginfo_class_quark_math_Vector3_multiply

#define arginfo_class_quark_math_Vector3_ceil arginfo_class_quark_math_Vector3_zero

#define arginfo_class_quark_math_Vector3_floor arginfo_class_quark_math_Vector3_zero

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_Vector3_round, 0, 0, quark\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, precision, IS_LONG, 0, "0")
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, mode, IS_LONG, 0, "PHP_ROUND_HALF_UP")
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_Vector3_abs arginfo_class_quark_math_Vector3_zero

ZEND_BEGIN_ARG_INFO_EX(arginfo_class_quark_math_Vector3_getSide, 0, 0, 1)
	ZEND_ARG_TYPE_INFO(0, side, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, step, IS_LONG, 0, "1")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_INFO_EX(arginfo_class_quark_math_Vector3_down, 0, 0, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, step, IS_LONG, 0, "1")
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_Vector3_up arginfo_class_quark_math_Vector3_down

#define arginfo_class_quark_math_Vector3_north arginfo_class_quark_math_Vector3_down

#define arginfo_class_quark_math_Vector3_south arginfo_class_quark_math_Vector3_down

#define arginfo_class_quark_math_Vector3_west arginfo_class_quark_math_Vector3_down

#define arginfo_class_quark_math_Vector3_east arginfo_class_quark_math_Vector3_down

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_Vector3_sides, 0, 0, IS_ARRAY, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, step, IS_LONG, 0, "1")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_Vector3_sidesAroundAxis, 0, 1, IS_ARRAY, 0)
	ZEND_ARG_TYPE_INFO(0, axis, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, step, IS_LONG, 0, "1")
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_Vector3_asVector3 arginfo_class_quark_math_Vector3_zero

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_Vector3_distance, 0, 1, IS_DOUBLE, 0)
	ZEND_ARG_OBJ_INFO(0, pos, quark\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_Vector3_distanceSquared arginfo_class_quark_math_Vector3_distance

#define arginfo_class_quark_math_Vector3_length arginfo_class_quark_math_Vector2_length

#define arginfo_class_quark_math_Vector3_lengthSquared arginfo_class_quark_math_Vector2_length

#define arginfo_class_quark_math_Vector3_normalize arginfo_class_quark_math_Vector3_zero

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_Vector3_dot, 0, 1, IS_DOUBLE, 0)
	ZEND_ARG_OBJ_INFO(0, v, quark\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_Vector3_cross arginfo_class_quark_math_Vector3_addVector

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_Vector3_equals, 0, 1, _IS_BOOL, 0)
	ZEND_ARG_OBJ_INFO(0, v, quark\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_Vector3___toString arginfo_class_quark_math_Vector2___toString

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_Vector3_withComponents, 0, 3, quark\\math\\Vector3, 0)
	ZEND_ARG_TYPE_MASK(0, x, MAY_BE_DOUBLE|MAY_BE_LONG|MAY_BE_NULL, NULL)
	ZEND_ARG_TYPE_MASK(0, y, MAY_BE_DOUBLE|MAY_BE_LONG|MAY_BE_NULL, NULL)
	ZEND_ARG_TYPE_MASK(0, z, MAY_BE_DOUBLE|MAY_BE_LONG|MAY_BE_NULL, NULL)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_Vector3_maxComponents, 0, 1, quark\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, vector, quark\\math\\Vector3, 0)
	ZEND_ARG_VARIADIC_OBJ_INFO(0, vectors, quark\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_Vector3_minComponents arginfo_class_quark_math_Vector3_maxComponents

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_Vector3_sum, 0, 0, quark\\math\\Vector3, 0)
	ZEND_ARG_VARIADIC_OBJ_INFO(0, vector3s, quark\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_Vector3_lerp, 0, 2, quark\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, to, quark\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO(0, t, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_Vector3_normalizeOrNull, 0, 0, quark\\math\\Vector3, 1)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_Vector3_project, 0, 1, quark\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, onto, quark\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_Vector3_reject, 0, 1, quark\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, from, quark\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_Vector3_reflect, 0, 1, quark\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, normal, quark\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_Vector3_angle arginfo_class_quark_math_Vector3_dot

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_Vector3_clamp, 0, 2, quark\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, min, quark\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, max, quark\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_Vector3_moveTowards, 0, 2, quark\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, target, quark\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO(0, maxDistance, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_Vector3_isFinite, 0, 0, _IS_BOOL, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_INFO_EX(arginfo_class_quark_math_RayTraceResult___construct, 0, 0, 3)
	ZEND_ARG_OBJ_INFO(0, bb, quark\\math\\AxisAlignedBB, 0)
	ZEND_ARG_TYPE_INFO(0, hitFace, IS_LONG, 0)
	ZEND_ARG_OBJ_INFO(0, hitVector, quark\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_INFO_EX(arginfo_class_quark_math_AxisAlignedBB___construct, 0, 0, 6)
	ZEND_ARG_TYPE_INFO(0, minX, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, minY, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, minZ, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, maxX, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, maxY, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, maxZ, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_AxisAlignedBB_addCoord, 0, 3, quark\\math\\AxisAlignedBB, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_AxisAlignedBB_expand arginfo_class_quark_math_AxisAlignedBB_addCoord

#define arginfo_class_quark_math_AxisAlignedBB_expandedCopy arginfo_class_quark_math_AxisAlignedBB_addCoord

#define arginfo_class_quark_math_AxisAlignedBB_offset arginfo_class_quark_math_AxisAlignedBB_addCoord

#define arginfo_class_quark_math_AxisAlignedBB_offsetCopy arginfo_class_quark_math_AxisAlignedBB_addCoord

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_AxisAlignedBB_offsetTowards, 0, 2, quark\\math\\AxisAlignedBB, 0)
	ZEND_ARG_TYPE_INFO(0, face, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, distance, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_AxisAlignedBB_offsetTowardsCopy arginfo_class_quark_math_AxisAlignedBB_offsetTowards

#define arginfo_class_quark_math_AxisAlignedBB_contract arginfo_class_quark_math_AxisAlignedBB_addCoord

#define arginfo_class_quark_math_AxisAlignedBB_contractedCopy arginfo_class_quark_math_AxisAlignedBB_addCoord

#define arginfo_class_quark_math_AxisAlignedBB_extend arginfo_class_quark_math_AxisAlignedBB_offsetTowards

#define arginfo_class_quark_math_AxisAlignedBB_extendedCopy arginfo_class_quark_math_AxisAlignedBB_offsetTowards

#define arginfo_class_quark_math_AxisAlignedBB_trim arginfo_class_quark_math_AxisAlignedBB_offsetTowards

#define arginfo_class_quark_math_AxisAlignedBB_trimmedCopy arginfo_class_quark_math_AxisAlignedBB_offsetTowards

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_AxisAlignedBB_stretch, 0, 2, quark\\math\\AxisAlignedBB, 0)
	ZEND_ARG_TYPE_INFO(0, axis, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, distance, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_AxisAlignedBB_stretchedCopy arginfo_class_quark_math_AxisAlignedBB_stretch

#define arginfo_class_quark_math_AxisAlignedBB_squash arginfo_class_quark_math_AxisAlignedBB_stretch

#define arginfo_class_quark_math_AxisAlignedBB_squashedCopy arginfo_class_quark_math_AxisAlignedBB_stretch

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_AxisAlignedBB_calculateXOffset, 0, 2, IS_DOUBLE, 0)
	ZEND_ARG_OBJ_INFO(0, bb, quark\\math\\AxisAlignedBB, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_AxisAlignedBB_calculateYOffset, 0, 2, IS_DOUBLE, 0)
	ZEND_ARG_OBJ_INFO(0, bb, quark\\math\\AxisAlignedBB, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_AxisAlignedBB_calculateZOffset, 0, 2, IS_DOUBLE, 0)
	ZEND_ARG_OBJ_INFO(0, bb, quark\\math\\AxisAlignedBB, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_AxisAlignedBB_intersectsWith, 0, 1, _IS_BOOL, 0)
	ZEND_ARG_OBJ_INFO(0, bb, quark\\math\\AxisAlignedBB, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, epsilon, IS_DOUBLE, 0, "1.0E-5")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_AxisAlignedBB_isVectorInside, 0, 1, _IS_BOOL, 0)
	ZEND_ARG_OBJ_INFO(0, vector, quark\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_AxisAlignedBB_getAverageEdgeLength arginfo_class_quark_math_Vector2_length

#define arginfo_class_quark_math_AxisAlignedBB_getXLength arginfo_class_quark_math_Vector2_length

#define arginfo_class_quark_math_AxisAlignedBB_getYLength arginfo_class_quark_math_Vector2_length

#define arginfo_class_quark_math_AxisAlignedBB_getZLength arginfo_class_quark_math_Vector2_length

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_AxisAlignedBB_isCube, 0, 0, _IS_BOOL, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, epsilon, IS_DOUBLE, 0, "1.0E-6")
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_AxisAlignedBB_getVolume arginfo_class_quark_math_Vector2_length

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_AxisAlignedBB_calculateIntercept, 0, 2, quark\\math\\RayTraceResult, 1)
	ZEND_ARG_OBJ_INFO(0, pos1, quark\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, pos2, quark\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_AxisAlignedBB___toString arginfo_class_quark_math_Vector2___toString

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_AxisAlignedBB_one, 0, 0, quark\\math\\AxisAlignedBB, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_AxisAlignedBB_getCenter arginfo_class_quark_math_Vector3_zero

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_AxisAlignedBB_closestPoint, 0, 1, quark\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, point, quark\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_AxisAlignedBB_distanceSquaredTo, 0, 1, IS_DOUBLE, 0)
	ZEND_ARG_OBJ_INFO(0, point, quark\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_AxisAlignedBB_intersectsSphere, 0, 2, _IS_BOOL, 0)
	ZEND_ARG_OBJ_INFO(0, center, quark\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO(0, radius, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_AxisAlignedBB_intersectsSegment, 0, 2, _IS_BOOL, 0)
	ZEND_ARG_OBJ_INFO(0, start, quark\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, end, quark\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_AxisAlignedBB_union, 0, 1, quark\\math\\AxisAlignedBB, 0)
	ZEND_ARG_OBJ_INFO(0, bb, quark\\math\\AxisAlignedBB, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_AxisAlignedBB_isFinite arginfo_class_quark_math_Vector3_isFinite

#define arginfo_class_quark_math_VoxelRayTrace___construct arginfo_class_quark_math_Axis___construct

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_VoxelRayTrace_inDirection, 0, 3, Iterator, 0)
	ZEND_ARG_OBJ_INFO(0, start, quark\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, directionVector, quark\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO(0, maxDistance, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_VoxelRayTrace_betweenPoints, 0, 2, Iterator, 0)
	ZEND_ARG_OBJ_INFO(0, start, quark\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, end, quark\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_VoxelRayIterator___construct arginfo_class_quark_math_Axis___construct

#define arginfo_class_quark_math_VoxelRayIterator_current arginfo_class_quark_math_Vector3_normalizeOrNull

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_VoxelRayIterator_key, 0, 0, IS_LONG, 1)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_VoxelRayIterator_next, 0, 0, IS_VOID, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_VoxelRayIterator_rewind arginfo_class_quark_math_VoxelRayIterator_next

#define arginfo_class_quark_math_VoxelRayIterator_valid arginfo_class_quark_math_Vector3_isFinite

ZEND_BEGIN_ARG_INFO_EX(arginfo_class_quark_math_collision_CollisionRegion___construct, 0, 0, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, maxSections, IS_LONG, 0, "16384")
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_collision_CollisionRegion_getVersion arginfo_class_quark_math_Vector2_getFloorX

#define arginfo_class_quark_math_collision_CollisionRegion_getSectionCount arginfo_class_quark_math_Vector2_getFloorX

#define arginfo_class_quark_math_collision_CollisionRegion_isFrozen arginfo_class_quark_math_Vector3_isFinite

#define arginfo_class_quark_math_collision_CollisionRegion_freeze arginfo_class_quark_math_VoxelRayIterator_next

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_collision_CollisionRegion_snapshot, 0, 0, quark\\math\\collision\\CollisionRegion, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_collision_CollisionRegion_isKnown, 0, 3, _IS_BOOL, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_LONG, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_collision_CollisionRegion_setCell, 0, 4, IS_VOID, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, info, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, boxes, IS_ARRAY, 0, "[]")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_collision_CollisionRegion_setCellPacked, 0, 5, IS_VOID, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, info, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, boxes, IS_STRING, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_collision_CollisionRegion_setSection, 0, 4, IS_VOID, 0)
	ZEND_ARG_TYPE_INFO(0, sectionX, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, sectionY, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, sectionZ, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, infos, IS_STRING, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, boxes, IS_ARRAY, 0, "[]")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_collision_CollisionRegion_fillBox, 0, 7, IS_VOID, 0)
	ZEND_ARG_TYPE_INFO(0, minX, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, minY, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, minZ, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, maxX, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, maxY, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, maxZ, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, info, IS_LONG, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_collision_CollisionRegion_missingSections, 0, 1, IS_ARRAY, 0)
	ZEND_ARG_OBJ_INFO(0, bb, quark\\math\\AxisAlignedBB, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_collision_CollisionRegion_invalidateCell, 0, 3, IS_VOID, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_LONG, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_collision_CollisionRegion_invalidateBlock arginfo_class_quark_math_collision_CollisionRegion_invalidateCell

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_collision_CollisionRegion_invalidateSection, 0, 3, IS_VOID, 0)
	ZEND_ARG_TYPE_INFO(0, sectionX, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, sectionY, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, sectionZ, IS_LONG, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_collision_CollisionRegion_invalidateChunk, 0, 2, IS_VOID, 0)
	ZEND_ARG_TYPE_INFO(0, chunkX, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, chunkZ, IS_LONG, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_collision_CollisionRegion_invalidateAll arginfo_class_quark_math_VoxelRayIterator_next

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_collision_CollisionRegion_isComplete, 0, 1, _IS_BOOL, 0)
	ZEND_ARG_OBJ_INFO(0, bb, quark\\math\\AxisAlignedBB, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_collision_CollisionRegion_getCollisionBoxes arginfo_class_quark_math_collision_CollisionRegion_missingSections

#define arginfo_class_quark_math_collision_CollisionRegion_collides arginfo_class_quark_math_collision_CollisionRegion_isComplete

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_collision_CollisionRegion_getCellBoxes, 0, 3, IS_ARRAY, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_LONG, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_collision_CollisionRegion_getCellInfo, 0, 3, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_LONG, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_collision_MoveResult___construct arginfo_class_quark_math_Axis___construct

#define arginfo_class_quark_math_collision_SweepResult___construct arginfo_class_quark_math_Axis___construct

#define arginfo_class_quark_math_collision_CollisionSolver___construct arginfo_class_quark_math_Axis___construct

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_collision_CollisionSolver_move, 0, 5, quark\\math\\collision\\MoveResult, 0)
	ZEND_ARG_OBJ_INFO(0, region, quark\\math\\collision\\CollisionRegion, 0)
	ZEND_ARG_OBJ_INFO(0, bb, quark\\math\\AxisAlignedBB, 0)
	ZEND_ARG_TYPE_INFO(0, dx, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, dy, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, dz, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, stepHeight, IS_DOUBLE, 0, "0.0")
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, onGround, _IS_BOOL, 0, "false")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_collision_CollisionSolver_sweep, 0, 5, quark\\math\\collision\\SweepResult, 1)
	ZEND_ARG_OBJ_INFO(0, region, quark\\math\\collision\\CollisionRegion, 0)
	ZEND_ARG_OBJ_INFO(0, bb, quark\\math\\AxisAlignedBB, 0)
	ZEND_ARG_TYPE_INFO(0, dx, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, dy, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, dz, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_collision_CollisionSolver_queryBox, 0, 4, quark\\math\\AxisAlignedBB, 0)
	ZEND_ARG_OBJ_INFO(0, bb, quark\\math\\AxisAlignedBB, 0)
	ZEND_ARG_TYPE_INFO(0, dx, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, dy, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, dz, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, stepHeight, IS_DOUBLE, 0, "0.0")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_collision_CollisionSolver_sweepBoxes, 0, 5, quark\\math\\collision\\SweepResult, 1)
	ZEND_ARG_OBJ_INFO(0, bb, quark\\math\\AxisAlignedBB, 0)
	ZEND_ARG_TYPE_INFO(0, dx, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, dy, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, dz, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, boxes, IS_ARRAY, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_INFO_EX(arginfo_class_quark_math_collision_VoxelHit___construct, 0, 0, 6)
	ZEND_ARG_OBJ_INFO(0, bb, quark\\math\\AxisAlignedBB, 0)
	ZEND_ARG_TYPE_INFO(0, hitFace, IS_LONG, 0)
	ZEND_ARG_OBJ_INFO(0, hitVector, quark\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO(0, blockX, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, blockY, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, blockZ, IS_LONG, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_collision_Raycast___construct arginfo_class_quark_math_Axis___construct

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_collision_Raycast_voxels, 0, 2, IS_ARRAY, 0)
	ZEND_ARG_OBJ_INFO(0, start, quark\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, end, quark\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, limit, IS_LONG, 0, "4096")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_collision_Raycast_blocks, 0, 3, quark\\math\\collision\\VoxelHit, 1)
	ZEND_ARG_OBJ_INFO(0, region, quark\\math\\collision\\CollisionRegion, 0)
	ZEND_ARG_OBJ_INFO(0, start, quark\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, end, quark\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_collision_Raycast_lineOfSight, 0, 3, _IS_BOOL, 0)
	ZEND_ARG_OBJ_INFO(0, region, quark\\math\\collision\\CollisionRegion, 0)
	ZEND_ARG_OBJ_INFO(0, start, quark\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, end, quark\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_collision_Raycast_boxes, 0, 3, IS_ARRAY, 1)
	ZEND_ARG_OBJ_INFO(0, start, quark\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, end, quark\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO(0, boxes, IS_ARRAY, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, expand, IS_DOUBLE, 0, "0.0")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_collision_Raycast_batchBlocks, 0, 2, IS_STRING, 0)
	ZEND_ARG_OBJ_INFO(0, region, quark\\math\\collision\\CollisionRegion, 0)
	ZEND_ARG_TYPE_INFO(0, segments, IS_STRING, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_collision_Spatial___construct arginfo_class_quark_math_Axis___construct

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_collision_Spatial_overlapping, 0, 2, IS_ARRAY, 0)
	ZEND_ARG_TYPE_INFO(0, objects, IS_ARRAY, 0)
	ZEND_ARG_OBJ_INFO(0, bb, quark\\math\\AxisAlignedBB, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, exclude, IS_OBJECT, 1, "null")
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, property, IS_STRING, 0, "\"boundingBox\"")
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, epsilon, IS_DOUBLE, 0, "1.0E-5")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_collision_Spatial_overlappingBoxes, 0, 2, IS_ARRAY, 0)
	ZEND_ARG_OBJ_INFO(0, bb, quark\\math\\AxisAlignedBB, 0)
	ZEND_ARG_TYPE_INFO(0, boxes, IS_ARRAY, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, epsilon, IS_DOUBLE, 0, "1.0E-5")
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_physics_Physics___construct arginfo_class_quark_math_Axis___construct

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_physics_Physics_motionStep, 0, 3, quark\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, motion, quark\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO(0, drag, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, gravity, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, gravityEnabled, _IS_BOOL, 0, "true")
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, dragBeforeGravity, _IS_BOOL, 0, "false")
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, groundFriction, IS_DOUBLE, 0, "1.0")
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, threshold, IS_DOUBLE, 0, "1.0E-5")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_physics_Physics_knockBack, 0, 3, quark\\math\\Vector3, 1)
	ZEND_ARG_OBJ_INFO(0, motion, quark\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, force, IS_DOUBLE, 0, "0.4")
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, verticalLimit, IS_DOUBLE, 1, "0.4")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_math_physics_Physics_directionPlane, 0, 1, quark\\math\\Vector2, 0)
	ZEND_ARG_TYPE_INFO(0, yaw, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_physics_Physics_horizontalFacing, 0, 1, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, yaw, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_physics_Physics_lookAt, 0, 2, IS_ARRAY, 0)
	ZEND_ARG_OBJ_INFO(0, eye, quark\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, target, quark\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_physics_Physics_motionRotation, 0, 1, IS_ARRAY, 0)
	ZEND_ARG_OBJ_INFO(0, motion, quark\\math\\Vector3, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_physics_Physics_predictTrajectory, 0, 5, IS_STRING, 0)
	ZEND_ARG_OBJ_INFO(0, position, quark\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, motion, quark\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO(0, drag, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, gravity, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, ticks, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, dragBeforeGravity, _IS_BOOL, 0, "false")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_INFO_EX(arginfo_class_quark_math_physics_ResistanceGrid___construct, 0, 0, 6)
	ZEND_ARG_TYPE_INFO(0, minX, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, minY, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, minZ, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, maxX, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, maxY, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, maxZ, IS_LONG, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_physics_ResistanceGrid_getBounds, 0, 0, IS_ARRAY, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_physics_ResistanceGrid_set, 0, 4, IS_VOID, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, resistance, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_physics_ResistanceGrid_setInvalid arginfo_class_quark_math_collision_CollisionRegion_invalidateCell

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_physics_ResistanceGrid_fill, 0, 1, IS_VOID, 0)
	ZEND_ARG_TYPE_INFO(0, resistance, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_physics_ResistanceGrid_setPacked, 0, 1, IS_VOID, 0)
	ZEND_ARG_TYPE_INFO(0, values, IS_STRING, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_math_physics_ExplosionMath___construct arginfo_class_quark_math_Axis___construct

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_physics_ExplosionMath_traceRays, 0, 3, IS_ARRAY, 0)
	ZEND_ARG_OBJ_INFO(0, grid, quark\\math\\physics\\ResistanceGrid, 0)
	ZEND_ARG_OBJ_INFO(0, source, quark\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO(0, radius, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, rays, IS_LONG, 0, "16")
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, stepLen, IS_DOUBLE, 0, "0.3")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_physics_ExplosionMath_traceRay, 0, 6, IS_ARRAY, 0)
	ZEND_ARG_OBJ_INFO(0, grid, quark\\math\\physics\\ResistanceGrid, 0)
	ZEND_ARG_OBJ_INFO(0, source, quark\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO(0, radius, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, i, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, j, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, k, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, rays, IS_LONG, 0, "16")
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, stepLen, IS_DOUBLE, 0, "0.3")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_physics_ExplosionMath_rayCount, 0, 0, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, rays, IS_LONG, 0, "16")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_physics_ExplosionMath_exposure, 0, 3, IS_DOUBLE, 0)
	ZEND_ARG_OBJ_INFO(0, region, quark\\math\\collision\\CollisionRegion, 0)
	ZEND_ARG_OBJ_INFO(0, origin, quark\\math\\Vector3, 0)
	ZEND_ARG_OBJ_INFO(0, bb, quark\\math\\AxisAlignedBB, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_physics_ExplosionMath_exposures, 0, 3, IS_ARRAY, 0)
	ZEND_ARG_OBJ_INFO(0, region, quark\\math\\collision\\CollisionRegion, 0)
	ZEND_ARG_OBJ_INFO(0, origin, quark\\math\\Vector3, 0)
	ZEND_ARG_TYPE_INFO(0, boxes, IS_ARRAY, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_INFO_EX(arginfo_class_quark_math_noise_Simplex___construct, 0, 0, 7)
	ZEND_ARG_TYPE_MASK(0, permutation, MAY_BE_ARRAY|MAY_BE_STRING, NULL)
	ZEND_ARG_TYPE_INFO(0, offsetX, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, offsetY, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, offsetZ, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, octaves, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, persistence, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, expansion, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_noise_Simplex_getNoise2D, 0, 2, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_noise_Simplex_getNoise3D, 0, 3, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_noise_Simplex_noise2D, 0, 2, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, normalized, _IS_BOOL, 0, "false")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_noise_Simplex_noise3D, 0, 3, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, normalized, _IS_BOOL, 0, "false")
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_noise_Simplex_getFastNoise1D, 0, 5, IS_ARRAY, 0)
	ZEND_ARG_TYPE_INFO(0, xSize, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, samplingRate, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_LONG, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_noise_Simplex_getFastNoise2D, 0, 6, IS_ARRAY, 0)
	ZEND_ARG_TYPE_INFO(0, xSize, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, zSize, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, samplingRate, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, x, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, y, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, z, IS_LONG, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_noise_Simplex_getFastNoise3D, 0, 9, IS_ARRAY, 0)
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

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_math_noise_Simplex_getFastNoise3DPacked, 0, 9, IS_STRING, 0)
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

ZEND_BEGIN_ARG_INFO_EX(arginfo_class_quark_color_Color___construct, 0, 0, 3)
	ZEND_ARG_TYPE_INFO(0, r, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, g, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, b, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, a, IS_LONG, 0, "0xff")
ZEND_END_ARG_INFO()

#define arginfo_class_quark_color_Color_getA arginfo_class_quark_math_Vector2_getFloorX

#define arginfo_class_quark_color_Color_getR arginfo_class_quark_math_Vector2_getFloorX

#define arginfo_class_quark_color_Color_getG arginfo_class_quark_math_Vector2_getFloorX

#define arginfo_class_quark_color_Color_getB arginfo_class_quark_math_Vector2_getFloorX

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_color_Color_mix, 0, 1, quark\\color\\Color, 0)
	ZEND_ARG_OBJ_INFO(0, color1, quark\\color\\Color, 0)
	ZEND_ARG_VARIADIC_OBJ_INFO(0, colors, quark\\color\\Color, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_color_Color_fromRGB, 0, 1, quark\\color\\Color, 0)
	ZEND_ARG_TYPE_INFO(0, code, IS_LONG, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_color_Color_fromARGB arginfo_class_quark_color_Color_fromRGB

#define arginfo_class_quark_color_Color_toARGB arginfo_class_quark_math_Vector2_getFloorX

#define arginfo_class_quark_color_Color_fromRGBA arginfo_class_quark_color_Color_fromRGB

#define arginfo_class_quark_color_Color_toRGBA arginfo_class_quark_math_Vector2_getFloorX

ZEND_BEGIN_ARG_WITH_RETURN_TYPE_INFO_EX(arginfo_class_quark_color_Color_equals, 0, 1, _IS_BOOL, 0)
	ZEND_ARG_OBJ_INFO(0, other, quark\\color\\Color, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_color_Color_toRGB arginfo_class_quark_math_Vector2_getFloorX

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_color_Color_lerp, 0, 2, quark\\color\\Color, 0)
	ZEND_ARG_OBJ_INFO(0, to, quark\\color\\Color, 0)
	ZEND_ARG_TYPE_INFO(0, t, IS_DOUBLE, 0)
ZEND_END_ARG_INFO()

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_color_Color_blend, 0, 1, quark\\color\\Color, 0)
	ZEND_ARG_OBJ_INFO(0, over, quark\\color\\Color, 0)
ZEND_END_ARG_INFO()

#define arginfo_class_quark_color_Color_toHSV arginfo_class_quark_math_physics_ResistanceGrid_getBounds

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_color_Color_fromHSV, 0, 3, quark\\color\\Color, 0)
	ZEND_ARG_TYPE_INFO(0, hue, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, saturation, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, value, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, a, IS_LONG, 0, "0xff")
ZEND_END_ARG_INFO()

#define arginfo_class_quark_color_Color_toHSL arginfo_class_quark_math_physics_ResistanceGrid_getBounds

ZEND_BEGIN_ARG_WITH_RETURN_OBJ_INFO_EX(arginfo_class_quark_color_Color_fromHSL, 0, 3, quark\\color\\Color, 0)
	ZEND_ARG_TYPE_INFO(0, hue, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, saturation, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO(0, lightness, IS_DOUBLE, 0)
	ZEND_ARG_TYPE_INFO_WITH_DEFAULT_VALUE(0, a, IS_LONG, 0, "0xff")
ZEND_END_ARG_INFO()

ZEND_METHOD(quark_math_Axis, __construct);
ZEND_METHOD(quark_math_Axis, toString);
ZEND_METHOD(quark_math_Facing, __construct);
ZEND_METHOD(quark_math_Facing, axis);
ZEND_METHOD(quark_math_Facing, isPositive);
ZEND_METHOD(quark_math_Facing, opposite);
ZEND_METHOD(quark_math_Facing, rotate);
ZEND_METHOD(quark_math_Facing, rotateY);
ZEND_METHOD(quark_math_Facing, rotateZ);
ZEND_METHOD(quark_math_Facing, rotateX);
ZEND_METHOD(quark_math_Facing, validate);
ZEND_METHOD(quark_math_Facing, toString);
ZEND_METHOD(quark_math_Math, __construct);
ZEND_METHOD(quark_math_Math, floorFloat);
ZEND_METHOD(quark_math_Math, ceilFloat);
ZEND_METHOD(quark_math_Math, solveQuadratic);
ZEND_METHOD(quark_math_VectorMath, __construct);
ZEND_METHOD(quark_math_VectorMath, getDirection2D);
ZEND_METHOD(quark_math_VectorMath, getDirection3D);
ZEND_METHOD(quark_math_Vector2, __construct);
ZEND_METHOD(quark_math_Vector2, getFloorX);
ZEND_METHOD(quark_math_Vector2, getFloorY);
ZEND_METHOD(quark_math_Vector2, add);
ZEND_METHOD(quark_math_Vector2, addVector);
ZEND_METHOD(quark_math_Vector2, subtract);
ZEND_METHOD(quark_math_Vector2, subtractVector);
ZEND_METHOD(quark_math_Vector2, ceil);
ZEND_METHOD(quark_math_Vector2, floor);
ZEND_METHOD(quark_math_Vector2, round);
ZEND_METHOD(quark_math_Vector2, abs);
ZEND_METHOD(quark_math_Vector2, multiply);
ZEND_METHOD(quark_math_Vector2, divide);
ZEND_METHOD(quark_math_Vector2, distance);
ZEND_METHOD(quark_math_Vector2, distanceSquared);
ZEND_METHOD(quark_math_Vector2, length);
ZEND_METHOD(quark_math_Vector2, lengthSquared);
ZEND_METHOD(quark_math_Vector2, normalize);
ZEND_METHOD(quark_math_Vector2, dot);
ZEND_METHOD(quark_math_Vector2, lerp);
ZEND_METHOD(quark_math_Vector2, __toString);
ZEND_METHOD(quark_math_Vector3, __construct);
ZEND_METHOD(quark_math_Vector3, zero);
ZEND_METHOD(quark_math_Vector3, getFloorX);
ZEND_METHOD(quark_math_Vector3, getFloorY);
ZEND_METHOD(quark_math_Vector3, getFloorZ);
ZEND_METHOD(quark_math_Vector3, add);
ZEND_METHOD(quark_math_Vector3, addVector);
ZEND_METHOD(quark_math_Vector3, subtract);
ZEND_METHOD(quark_math_Vector3, subtractVector);
ZEND_METHOD(quark_math_Vector3, multiply);
ZEND_METHOD(quark_math_Vector3, divide);
ZEND_METHOD(quark_math_Vector3, ceil);
ZEND_METHOD(quark_math_Vector3, floor);
ZEND_METHOD(quark_math_Vector3, round);
ZEND_METHOD(quark_math_Vector3, abs);
ZEND_METHOD(quark_math_Vector3, getSide);
ZEND_METHOD(quark_math_Vector3, down);
ZEND_METHOD(quark_math_Vector3, up);
ZEND_METHOD(quark_math_Vector3, north);
ZEND_METHOD(quark_math_Vector3, south);
ZEND_METHOD(quark_math_Vector3, west);
ZEND_METHOD(quark_math_Vector3, east);
ZEND_METHOD(quark_math_Vector3, sides);
ZEND_METHOD(quark_math_Vector3, sidesAroundAxis);
ZEND_METHOD(quark_math_Vector3, asVector3);
ZEND_METHOD(quark_math_Vector3, distance);
ZEND_METHOD(quark_math_Vector3, distanceSquared);
ZEND_METHOD(quark_math_Vector3, length);
ZEND_METHOD(quark_math_Vector3, lengthSquared);
ZEND_METHOD(quark_math_Vector3, normalize);
ZEND_METHOD(quark_math_Vector3, dot);
ZEND_METHOD(quark_math_Vector3, cross);
ZEND_METHOD(quark_math_Vector3, equals);
ZEND_METHOD(quark_math_Vector3, __toString);
ZEND_METHOD(quark_math_Vector3, withComponents);
ZEND_METHOD(quark_math_Vector3, maxComponents);
ZEND_METHOD(quark_math_Vector3, minComponents);
ZEND_METHOD(quark_math_Vector3, sum);
ZEND_METHOD(quark_math_Vector3, lerp);
ZEND_METHOD(quark_math_Vector3, normalizeOrNull);
ZEND_METHOD(quark_math_Vector3, project);
ZEND_METHOD(quark_math_Vector3, reject);
ZEND_METHOD(quark_math_Vector3, reflect);
ZEND_METHOD(quark_math_Vector3, angle);
ZEND_METHOD(quark_math_Vector3, clamp);
ZEND_METHOD(quark_math_Vector3, moveTowards);
ZEND_METHOD(quark_math_Vector3, isFinite);
ZEND_METHOD(quark_math_RayTraceResult, __construct);
ZEND_METHOD(quark_math_AxisAlignedBB, __construct);
ZEND_METHOD(quark_math_AxisAlignedBB, addCoord);
ZEND_METHOD(quark_math_AxisAlignedBB, expand);
ZEND_METHOD(quark_math_AxisAlignedBB, expandedCopy);
ZEND_METHOD(quark_math_AxisAlignedBB, offset);
ZEND_METHOD(quark_math_AxisAlignedBB, offsetCopy);
ZEND_METHOD(quark_math_AxisAlignedBB, offsetTowards);
ZEND_METHOD(quark_math_AxisAlignedBB, offsetTowardsCopy);
ZEND_METHOD(quark_math_AxisAlignedBB, contract);
ZEND_METHOD(quark_math_AxisAlignedBB, contractedCopy);
ZEND_METHOD(quark_math_AxisAlignedBB, extend);
ZEND_METHOD(quark_math_AxisAlignedBB, extendedCopy);
ZEND_METHOD(quark_math_AxisAlignedBB, trim);
ZEND_METHOD(quark_math_AxisAlignedBB, trimmedCopy);
ZEND_METHOD(quark_math_AxisAlignedBB, stretch);
ZEND_METHOD(quark_math_AxisAlignedBB, stretchedCopy);
ZEND_METHOD(quark_math_AxisAlignedBB, squash);
ZEND_METHOD(quark_math_AxisAlignedBB, squashedCopy);
ZEND_METHOD(quark_math_AxisAlignedBB, calculateXOffset);
ZEND_METHOD(quark_math_AxisAlignedBB, calculateYOffset);
ZEND_METHOD(quark_math_AxisAlignedBB, calculateZOffset);
ZEND_METHOD(quark_math_AxisAlignedBB, intersectsWith);
ZEND_METHOD(quark_math_AxisAlignedBB, isVectorInside);
ZEND_METHOD(quark_math_AxisAlignedBB, getAverageEdgeLength);
ZEND_METHOD(quark_math_AxisAlignedBB, getXLength);
ZEND_METHOD(quark_math_AxisAlignedBB, getYLength);
ZEND_METHOD(quark_math_AxisAlignedBB, getZLength);
ZEND_METHOD(quark_math_AxisAlignedBB, isCube);
ZEND_METHOD(quark_math_AxisAlignedBB, getVolume);
ZEND_METHOD(quark_math_AxisAlignedBB, calculateIntercept);
ZEND_METHOD(quark_math_AxisAlignedBB, __toString);
ZEND_METHOD(quark_math_AxisAlignedBB, one);
ZEND_METHOD(quark_math_AxisAlignedBB, getCenter);
ZEND_METHOD(quark_math_AxisAlignedBB, closestPoint);
ZEND_METHOD(quark_math_AxisAlignedBB, distanceSquaredTo);
ZEND_METHOD(quark_math_AxisAlignedBB, intersectsSphere);
ZEND_METHOD(quark_math_AxisAlignedBB, intersectsSegment);
ZEND_METHOD(quark_math_AxisAlignedBB, union);
ZEND_METHOD(quark_math_AxisAlignedBB, isFinite);
ZEND_METHOD(quark_math_VoxelRayTrace, __construct);
ZEND_METHOD(quark_math_VoxelRayTrace, inDirection);
ZEND_METHOD(quark_math_VoxelRayTrace, betweenPoints);
ZEND_METHOD(quark_math_VoxelRayIterator, __construct);
ZEND_METHOD(quark_math_VoxelRayIterator, current);
ZEND_METHOD(quark_math_VoxelRayIterator, key);
ZEND_METHOD(quark_math_VoxelRayIterator, next);
ZEND_METHOD(quark_math_VoxelRayIterator, rewind);
ZEND_METHOD(quark_math_VoxelRayIterator, valid);
ZEND_METHOD(quark_math_collision_CollisionRegion, __construct);
ZEND_METHOD(quark_math_collision_CollisionRegion, getVersion);
ZEND_METHOD(quark_math_collision_CollisionRegion, getSectionCount);
ZEND_METHOD(quark_math_collision_CollisionRegion, isFrozen);
ZEND_METHOD(quark_math_collision_CollisionRegion, freeze);
ZEND_METHOD(quark_math_collision_CollisionRegion, snapshot);
ZEND_METHOD(quark_math_collision_CollisionRegion, isKnown);
ZEND_METHOD(quark_math_collision_CollisionRegion, setCell);
ZEND_METHOD(quark_math_collision_CollisionRegion, setCellPacked);
ZEND_METHOD(quark_math_collision_CollisionRegion, setSection);
ZEND_METHOD(quark_math_collision_CollisionRegion, fillBox);
ZEND_METHOD(quark_math_collision_CollisionRegion, missingSections);
ZEND_METHOD(quark_math_collision_CollisionRegion, invalidateCell);
ZEND_METHOD(quark_math_collision_CollisionRegion, invalidateBlock);
ZEND_METHOD(quark_math_collision_CollisionRegion, invalidateSection);
ZEND_METHOD(quark_math_collision_CollisionRegion, invalidateChunk);
ZEND_METHOD(quark_math_collision_CollisionRegion, invalidateAll);
ZEND_METHOD(quark_math_collision_CollisionRegion, isComplete);
ZEND_METHOD(quark_math_collision_CollisionRegion, getCollisionBoxes);
ZEND_METHOD(quark_math_collision_CollisionRegion, collides);
ZEND_METHOD(quark_math_collision_CollisionRegion, getCellBoxes);
ZEND_METHOD(quark_math_collision_CollisionRegion, getCellInfo);
ZEND_METHOD(quark_math_collision_MoveResult, __construct);
ZEND_METHOD(quark_math_collision_SweepResult, __construct);
ZEND_METHOD(quark_math_collision_CollisionSolver, __construct);
ZEND_METHOD(quark_math_collision_CollisionSolver, move);
ZEND_METHOD(quark_math_collision_CollisionSolver, sweep);
ZEND_METHOD(quark_math_collision_CollisionSolver, queryBox);
ZEND_METHOD(quark_math_collision_CollisionSolver, sweepBoxes);
ZEND_METHOD(quark_math_collision_VoxelHit, __construct);
ZEND_METHOD(quark_math_collision_Raycast, __construct);
ZEND_METHOD(quark_math_collision_Raycast, voxels);
ZEND_METHOD(quark_math_collision_Raycast, blocks);
ZEND_METHOD(quark_math_collision_Raycast, lineOfSight);
ZEND_METHOD(quark_math_collision_Raycast, boxes);
ZEND_METHOD(quark_math_collision_Raycast, batchBlocks);
ZEND_METHOD(quark_math_collision_Spatial, __construct);
ZEND_METHOD(quark_math_collision_Spatial, overlapping);
ZEND_METHOD(quark_math_collision_Spatial, overlappingBoxes);
ZEND_METHOD(quark_math_physics_Physics, __construct);
ZEND_METHOD(quark_math_physics_Physics, motionStep);
ZEND_METHOD(quark_math_physics_Physics, knockBack);
ZEND_METHOD(quark_math_physics_Physics, directionPlane);
ZEND_METHOD(quark_math_physics_Physics, horizontalFacing);
ZEND_METHOD(quark_math_physics_Physics, lookAt);
ZEND_METHOD(quark_math_physics_Physics, motionRotation);
ZEND_METHOD(quark_math_physics_Physics, predictTrajectory);
ZEND_METHOD(quark_math_physics_ResistanceGrid, __construct);
ZEND_METHOD(quark_math_physics_ResistanceGrid, getBounds);
ZEND_METHOD(quark_math_physics_ResistanceGrid, set);
ZEND_METHOD(quark_math_physics_ResistanceGrid, setInvalid);
ZEND_METHOD(quark_math_physics_ResistanceGrid, fill);
ZEND_METHOD(quark_math_physics_ResistanceGrid, setPacked);
ZEND_METHOD(quark_math_physics_ExplosionMath, __construct);
ZEND_METHOD(quark_math_physics_ExplosionMath, traceRays);
ZEND_METHOD(quark_math_physics_ExplosionMath, traceRay);
ZEND_METHOD(quark_math_physics_ExplosionMath, rayCount);
ZEND_METHOD(quark_math_physics_ExplosionMath, exposure);
ZEND_METHOD(quark_math_physics_ExplosionMath, exposures);
ZEND_METHOD(quark_math_noise_Simplex, __construct);
ZEND_METHOD(quark_math_noise_Simplex, getNoise2D);
ZEND_METHOD(quark_math_noise_Simplex, getNoise3D);
ZEND_METHOD(quark_math_noise_Simplex, noise2D);
ZEND_METHOD(quark_math_noise_Simplex, noise3D);
ZEND_METHOD(quark_math_noise_Simplex, getFastNoise1D);
ZEND_METHOD(quark_math_noise_Simplex, getFastNoise2D);
ZEND_METHOD(quark_math_noise_Simplex, getFastNoise3D);
ZEND_METHOD(quark_math_noise_Simplex, getFastNoise3DPacked);
ZEND_METHOD(quark_color_Color, __construct);
ZEND_METHOD(quark_color_Color, getA);
ZEND_METHOD(quark_color_Color, getR);
ZEND_METHOD(quark_color_Color, getG);
ZEND_METHOD(quark_color_Color, getB);
ZEND_METHOD(quark_color_Color, mix);
ZEND_METHOD(quark_color_Color, fromRGB);
ZEND_METHOD(quark_color_Color, fromARGB);
ZEND_METHOD(quark_color_Color, toARGB);
ZEND_METHOD(quark_color_Color, fromRGBA);
ZEND_METHOD(quark_color_Color, toRGBA);
ZEND_METHOD(quark_color_Color, equals);
ZEND_METHOD(quark_color_Color, toRGB);
ZEND_METHOD(quark_color_Color, lerp);
ZEND_METHOD(quark_color_Color, blend);
ZEND_METHOD(quark_color_Color, toHSV);
ZEND_METHOD(quark_color_Color, fromHSV);
ZEND_METHOD(quark_color_Color, toHSL);
ZEND_METHOD(quark_color_Color, fromHSL);

static const zend_function_entry class_quark_math_Axis_methods[] = {
	ZEND_ME(quark_math_Axis, __construct, arginfo_class_quark_math_Axis___construct, ZEND_ACC_PRIVATE)
	ZEND_ME(quark_math_Axis, toString, arginfo_class_quark_math_Axis_toString, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_FE_END
};

static const zend_function_entry class_quark_math_Facing_methods[] = {
	ZEND_ME(quark_math_Facing, __construct, arginfo_class_quark_math_Facing___construct, ZEND_ACC_PRIVATE)
	ZEND_ME(quark_math_Facing, axis, arginfo_class_quark_math_Facing_axis, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_Facing, isPositive, arginfo_class_quark_math_Facing_isPositive, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_Facing, opposite, arginfo_class_quark_math_Facing_opposite, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_Facing, rotate, arginfo_class_quark_math_Facing_rotate, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_Facing, rotateY, arginfo_class_quark_math_Facing_rotateY, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_Facing, rotateZ, arginfo_class_quark_math_Facing_rotateZ, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_Facing, rotateX, arginfo_class_quark_math_Facing_rotateX, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_Facing, validate, arginfo_class_quark_math_Facing_validate, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_Facing, toString, arginfo_class_quark_math_Facing_toString, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_FE_END
};

static const zend_function_entry class_quark_math_Math_methods[] = {
	ZEND_ME(quark_math_Math, __construct, arginfo_class_quark_math_Math___construct, ZEND_ACC_PRIVATE)
	ZEND_ME(quark_math_Math, floorFloat, arginfo_class_quark_math_Math_floorFloat, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_Math, ceilFloat, arginfo_class_quark_math_Math_ceilFloat, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_Math, solveQuadratic, arginfo_class_quark_math_Math_solveQuadratic, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_FE_END
};

static const zend_function_entry class_quark_math_VectorMath_methods[] = {
	ZEND_ME(quark_math_VectorMath, __construct, arginfo_class_quark_math_VectorMath___construct, ZEND_ACC_PRIVATE)
	ZEND_ME(quark_math_VectorMath, getDirection2D, arginfo_class_quark_math_VectorMath_getDirection2D, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_VectorMath, getDirection3D, arginfo_class_quark_math_VectorMath_getDirection3D, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_FE_END
};

static const zend_function_entry class_quark_math_Vector2_methods[] = {
	ZEND_ME(quark_math_Vector2, __construct, arginfo_class_quark_math_Vector2___construct, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector2, getFloorX, arginfo_class_quark_math_Vector2_getFloorX, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector2, getFloorY, arginfo_class_quark_math_Vector2_getFloorY, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector2, add, arginfo_class_quark_math_Vector2_add, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector2, addVector, arginfo_class_quark_math_Vector2_addVector, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector2, subtract, arginfo_class_quark_math_Vector2_subtract, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector2, subtractVector, arginfo_class_quark_math_Vector2_subtractVector, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector2, ceil, arginfo_class_quark_math_Vector2_ceil, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector2, floor, arginfo_class_quark_math_Vector2_floor, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector2, round, arginfo_class_quark_math_Vector2_round, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector2, abs, arginfo_class_quark_math_Vector2_abs, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector2, multiply, arginfo_class_quark_math_Vector2_multiply, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector2, divide, arginfo_class_quark_math_Vector2_divide, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector2, distance, arginfo_class_quark_math_Vector2_distance, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector2, distanceSquared, arginfo_class_quark_math_Vector2_distanceSquared, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector2, length, arginfo_class_quark_math_Vector2_length, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector2, lengthSquared, arginfo_class_quark_math_Vector2_lengthSquared, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector2, normalize, arginfo_class_quark_math_Vector2_normalize, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector2, dot, arginfo_class_quark_math_Vector2_dot, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector2, lerp, arginfo_class_quark_math_Vector2_lerp, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector2, __toString, arginfo_class_quark_math_Vector2___toString, ZEND_ACC_PUBLIC)
	ZEND_FE_END
};

static const zend_function_entry class_quark_math_Vector3_methods[] = {
	ZEND_ME(quark_math_Vector3, __construct, arginfo_class_quark_math_Vector3___construct, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, zero, arginfo_class_quark_math_Vector3_zero, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_Vector3, getFloorX, arginfo_class_quark_math_Vector3_getFloorX, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, getFloorY, arginfo_class_quark_math_Vector3_getFloorY, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, getFloorZ, arginfo_class_quark_math_Vector3_getFloorZ, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, add, arginfo_class_quark_math_Vector3_add, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, addVector, arginfo_class_quark_math_Vector3_addVector, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, subtract, arginfo_class_quark_math_Vector3_subtract, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, subtractVector, arginfo_class_quark_math_Vector3_subtractVector, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, multiply, arginfo_class_quark_math_Vector3_multiply, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, divide, arginfo_class_quark_math_Vector3_divide, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, ceil, arginfo_class_quark_math_Vector3_ceil, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, floor, arginfo_class_quark_math_Vector3_floor, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, round, arginfo_class_quark_math_Vector3_round, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, abs, arginfo_class_quark_math_Vector3_abs, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, getSide, arginfo_class_quark_math_Vector3_getSide, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, down, arginfo_class_quark_math_Vector3_down, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, up, arginfo_class_quark_math_Vector3_up, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, north, arginfo_class_quark_math_Vector3_north, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, south, arginfo_class_quark_math_Vector3_south, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, west, arginfo_class_quark_math_Vector3_west, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, east, arginfo_class_quark_math_Vector3_east, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, sides, arginfo_class_quark_math_Vector3_sides, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, sidesAroundAxis, arginfo_class_quark_math_Vector3_sidesAroundAxis, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, asVector3, arginfo_class_quark_math_Vector3_asVector3, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, distance, arginfo_class_quark_math_Vector3_distance, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, distanceSquared, arginfo_class_quark_math_Vector3_distanceSquared, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, length, arginfo_class_quark_math_Vector3_length, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, lengthSquared, arginfo_class_quark_math_Vector3_lengthSquared, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, normalize, arginfo_class_quark_math_Vector3_normalize, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, dot, arginfo_class_quark_math_Vector3_dot, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, cross, arginfo_class_quark_math_Vector3_cross, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, equals, arginfo_class_quark_math_Vector3_equals, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, __toString, arginfo_class_quark_math_Vector3___toString, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, withComponents, arginfo_class_quark_math_Vector3_withComponents, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, maxComponents, arginfo_class_quark_math_Vector3_maxComponents, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_Vector3, minComponents, arginfo_class_quark_math_Vector3_minComponents, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_Vector3, sum, arginfo_class_quark_math_Vector3_sum, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_Vector3, lerp, arginfo_class_quark_math_Vector3_lerp, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, normalizeOrNull, arginfo_class_quark_math_Vector3_normalizeOrNull, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, project, arginfo_class_quark_math_Vector3_project, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, reject, arginfo_class_quark_math_Vector3_reject, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, reflect, arginfo_class_quark_math_Vector3_reflect, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, angle, arginfo_class_quark_math_Vector3_angle, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, clamp, arginfo_class_quark_math_Vector3_clamp, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, moveTowards, arginfo_class_quark_math_Vector3_moveTowards, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_Vector3, isFinite, arginfo_class_quark_math_Vector3_isFinite, ZEND_ACC_PUBLIC)
	ZEND_FE_END
};

static const zend_function_entry class_quark_math_RayTraceResult_methods[] = {
	ZEND_ME(quark_math_RayTraceResult, __construct, arginfo_class_quark_math_RayTraceResult___construct, ZEND_ACC_PUBLIC)
	ZEND_FE_END
};

static const zend_function_entry class_quark_math_AxisAlignedBB_methods[] = {
	ZEND_ME(quark_math_AxisAlignedBB, __construct, arginfo_class_quark_math_AxisAlignedBB___construct, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, addCoord, arginfo_class_quark_math_AxisAlignedBB_addCoord, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, expand, arginfo_class_quark_math_AxisAlignedBB_expand, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, expandedCopy, arginfo_class_quark_math_AxisAlignedBB_expandedCopy, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, offset, arginfo_class_quark_math_AxisAlignedBB_offset, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, offsetCopy, arginfo_class_quark_math_AxisAlignedBB_offsetCopy, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, offsetTowards, arginfo_class_quark_math_AxisAlignedBB_offsetTowards, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, offsetTowardsCopy, arginfo_class_quark_math_AxisAlignedBB_offsetTowardsCopy, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, contract, arginfo_class_quark_math_AxisAlignedBB_contract, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, contractedCopy, arginfo_class_quark_math_AxisAlignedBB_contractedCopy, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, extend, arginfo_class_quark_math_AxisAlignedBB_extend, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, extendedCopy, arginfo_class_quark_math_AxisAlignedBB_extendedCopy, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, trim, arginfo_class_quark_math_AxisAlignedBB_trim, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, trimmedCopy, arginfo_class_quark_math_AxisAlignedBB_trimmedCopy, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, stretch, arginfo_class_quark_math_AxisAlignedBB_stretch, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, stretchedCopy, arginfo_class_quark_math_AxisAlignedBB_stretchedCopy, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, squash, arginfo_class_quark_math_AxisAlignedBB_squash, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, squashedCopy, arginfo_class_quark_math_AxisAlignedBB_squashedCopy, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, calculateXOffset, arginfo_class_quark_math_AxisAlignedBB_calculateXOffset, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, calculateYOffset, arginfo_class_quark_math_AxisAlignedBB_calculateYOffset, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, calculateZOffset, arginfo_class_quark_math_AxisAlignedBB_calculateZOffset, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, intersectsWith, arginfo_class_quark_math_AxisAlignedBB_intersectsWith, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, isVectorInside, arginfo_class_quark_math_AxisAlignedBB_isVectorInside, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, getAverageEdgeLength, arginfo_class_quark_math_AxisAlignedBB_getAverageEdgeLength, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, getXLength, arginfo_class_quark_math_AxisAlignedBB_getXLength, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, getYLength, arginfo_class_quark_math_AxisAlignedBB_getYLength, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, getZLength, arginfo_class_quark_math_AxisAlignedBB_getZLength, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, isCube, arginfo_class_quark_math_AxisAlignedBB_isCube, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, getVolume, arginfo_class_quark_math_AxisAlignedBB_getVolume, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, calculateIntercept, arginfo_class_quark_math_AxisAlignedBB_calculateIntercept, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, __toString, arginfo_class_quark_math_AxisAlignedBB___toString, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, one, arginfo_class_quark_math_AxisAlignedBB_one, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_AxisAlignedBB, getCenter, arginfo_class_quark_math_AxisAlignedBB_getCenter, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, closestPoint, arginfo_class_quark_math_AxisAlignedBB_closestPoint, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, distanceSquaredTo, arginfo_class_quark_math_AxisAlignedBB_distanceSquaredTo, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, intersectsSphere, arginfo_class_quark_math_AxisAlignedBB_intersectsSphere, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, intersectsSegment, arginfo_class_quark_math_AxisAlignedBB_intersectsSegment, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, union, arginfo_class_quark_math_AxisAlignedBB_union, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_AxisAlignedBB, isFinite, arginfo_class_quark_math_AxisAlignedBB_isFinite, ZEND_ACC_PUBLIC)
	ZEND_FE_END
};

static const zend_function_entry class_quark_math_VoxelRayTrace_methods[] = {
	ZEND_ME(quark_math_VoxelRayTrace, __construct, arginfo_class_quark_math_VoxelRayTrace___construct, ZEND_ACC_PRIVATE)
	ZEND_ME(quark_math_VoxelRayTrace, inDirection, arginfo_class_quark_math_VoxelRayTrace_inDirection, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_VoxelRayTrace, betweenPoints, arginfo_class_quark_math_VoxelRayTrace_betweenPoints, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_FE_END
};

static const zend_function_entry class_quark_math_VoxelRayIterator_methods[] = {
	ZEND_ME(quark_math_VoxelRayIterator, __construct, arginfo_class_quark_math_VoxelRayIterator___construct, ZEND_ACC_PRIVATE)
	ZEND_ME(quark_math_VoxelRayIterator, current, arginfo_class_quark_math_VoxelRayIterator_current, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_VoxelRayIterator, key, arginfo_class_quark_math_VoxelRayIterator_key, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_VoxelRayIterator, next, arginfo_class_quark_math_VoxelRayIterator_next, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_VoxelRayIterator, rewind, arginfo_class_quark_math_VoxelRayIterator_rewind, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_VoxelRayIterator, valid, arginfo_class_quark_math_VoxelRayIterator_valid, ZEND_ACC_PUBLIC)
	ZEND_FE_END
};

static const zend_function_entry class_quark_math_collision_CollisionRegion_methods[] = {
	ZEND_ME(quark_math_collision_CollisionRegion, __construct, arginfo_class_quark_math_collision_CollisionRegion___construct, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_collision_CollisionRegion, getVersion, arginfo_class_quark_math_collision_CollisionRegion_getVersion, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_collision_CollisionRegion, getSectionCount, arginfo_class_quark_math_collision_CollisionRegion_getSectionCount, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_collision_CollisionRegion, isFrozen, arginfo_class_quark_math_collision_CollisionRegion_isFrozen, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_collision_CollisionRegion, freeze, arginfo_class_quark_math_collision_CollisionRegion_freeze, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_collision_CollisionRegion, snapshot, arginfo_class_quark_math_collision_CollisionRegion_snapshot, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_collision_CollisionRegion, isKnown, arginfo_class_quark_math_collision_CollisionRegion_isKnown, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_collision_CollisionRegion, setCell, arginfo_class_quark_math_collision_CollisionRegion_setCell, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_collision_CollisionRegion, setCellPacked, arginfo_class_quark_math_collision_CollisionRegion_setCellPacked, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_collision_CollisionRegion, setSection, arginfo_class_quark_math_collision_CollisionRegion_setSection, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_collision_CollisionRegion, fillBox, arginfo_class_quark_math_collision_CollisionRegion_fillBox, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_collision_CollisionRegion, missingSections, arginfo_class_quark_math_collision_CollisionRegion_missingSections, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_collision_CollisionRegion, invalidateCell, arginfo_class_quark_math_collision_CollisionRegion_invalidateCell, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_collision_CollisionRegion, invalidateBlock, arginfo_class_quark_math_collision_CollisionRegion_invalidateBlock, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_collision_CollisionRegion, invalidateSection, arginfo_class_quark_math_collision_CollisionRegion_invalidateSection, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_collision_CollisionRegion, invalidateChunk, arginfo_class_quark_math_collision_CollisionRegion_invalidateChunk, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_collision_CollisionRegion, invalidateAll, arginfo_class_quark_math_collision_CollisionRegion_invalidateAll, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_collision_CollisionRegion, isComplete, arginfo_class_quark_math_collision_CollisionRegion_isComplete, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_collision_CollisionRegion, getCollisionBoxes, arginfo_class_quark_math_collision_CollisionRegion_getCollisionBoxes, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_collision_CollisionRegion, collides, arginfo_class_quark_math_collision_CollisionRegion_collides, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_collision_CollisionRegion, getCellBoxes, arginfo_class_quark_math_collision_CollisionRegion_getCellBoxes, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_collision_CollisionRegion, getCellInfo, arginfo_class_quark_math_collision_CollisionRegion_getCellInfo, ZEND_ACC_PUBLIC)
	ZEND_FE_END
};

static const zend_function_entry class_quark_math_collision_MoveResult_methods[] = {
	ZEND_ME(quark_math_collision_MoveResult, __construct, arginfo_class_quark_math_collision_MoveResult___construct, ZEND_ACC_PRIVATE)
	ZEND_FE_END
};

static const zend_function_entry class_quark_math_collision_SweepResult_methods[] = {
	ZEND_ME(quark_math_collision_SweepResult, __construct, arginfo_class_quark_math_collision_SweepResult___construct, ZEND_ACC_PRIVATE)
	ZEND_FE_END
};

static const zend_function_entry class_quark_math_collision_CollisionSolver_methods[] = {
	ZEND_ME(quark_math_collision_CollisionSolver, __construct, arginfo_class_quark_math_collision_CollisionSolver___construct, ZEND_ACC_PRIVATE)
	ZEND_ME(quark_math_collision_CollisionSolver, move, arginfo_class_quark_math_collision_CollisionSolver_move, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_collision_CollisionSolver, sweep, arginfo_class_quark_math_collision_CollisionSolver_sweep, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_collision_CollisionSolver, queryBox, arginfo_class_quark_math_collision_CollisionSolver_queryBox, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_collision_CollisionSolver, sweepBoxes, arginfo_class_quark_math_collision_CollisionSolver_sweepBoxes, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_FE_END
};

static const zend_function_entry class_quark_math_collision_VoxelHit_methods[] = {
	ZEND_ME(quark_math_collision_VoxelHit, __construct, arginfo_class_quark_math_collision_VoxelHit___construct, ZEND_ACC_PUBLIC)
	ZEND_FE_END
};

static const zend_function_entry class_quark_math_collision_Raycast_methods[] = {
	ZEND_ME(quark_math_collision_Raycast, __construct, arginfo_class_quark_math_collision_Raycast___construct, ZEND_ACC_PRIVATE)
	ZEND_ME(quark_math_collision_Raycast, voxels, arginfo_class_quark_math_collision_Raycast_voxels, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_collision_Raycast, blocks, arginfo_class_quark_math_collision_Raycast_blocks, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_collision_Raycast, lineOfSight, arginfo_class_quark_math_collision_Raycast_lineOfSight, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_collision_Raycast, boxes, arginfo_class_quark_math_collision_Raycast_boxes, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_collision_Raycast, batchBlocks, arginfo_class_quark_math_collision_Raycast_batchBlocks, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_FE_END
};

static const zend_function_entry class_quark_math_collision_Spatial_methods[] = {
	ZEND_ME(quark_math_collision_Spatial, __construct, arginfo_class_quark_math_collision_Spatial___construct, ZEND_ACC_PRIVATE)
	ZEND_ME(quark_math_collision_Spatial, overlapping, arginfo_class_quark_math_collision_Spatial_overlapping, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_collision_Spatial, overlappingBoxes, arginfo_class_quark_math_collision_Spatial_overlappingBoxes, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_FE_END
};

static const zend_function_entry class_quark_math_physics_Physics_methods[] = {
	ZEND_ME(quark_math_physics_Physics, __construct, arginfo_class_quark_math_physics_Physics___construct, ZEND_ACC_PRIVATE)
	ZEND_ME(quark_math_physics_Physics, motionStep, arginfo_class_quark_math_physics_Physics_motionStep, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_physics_Physics, knockBack, arginfo_class_quark_math_physics_Physics_knockBack, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_physics_Physics, directionPlane, arginfo_class_quark_math_physics_Physics_directionPlane, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_physics_Physics, horizontalFacing, arginfo_class_quark_math_physics_Physics_horizontalFacing, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_physics_Physics, lookAt, arginfo_class_quark_math_physics_Physics_lookAt, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_physics_Physics, motionRotation, arginfo_class_quark_math_physics_Physics_motionRotation, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_physics_Physics, predictTrajectory, arginfo_class_quark_math_physics_Physics_predictTrajectory, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_FE_END
};

static const zend_function_entry class_quark_math_physics_ResistanceGrid_methods[] = {
	ZEND_ME(quark_math_physics_ResistanceGrid, __construct, arginfo_class_quark_math_physics_ResistanceGrid___construct, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_physics_ResistanceGrid, getBounds, arginfo_class_quark_math_physics_ResistanceGrid_getBounds, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_physics_ResistanceGrid, set, arginfo_class_quark_math_physics_ResistanceGrid_set, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_physics_ResistanceGrid, setInvalid, arginfo_class_quark_math_physics_ResistanceGrid_setInvalid, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_physics_ResistanceGrid, fill, arginfo_class_quark_math_physics_ResistanceGrid_fill, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_physics_ResistanceGrid, setPacked, arginfo_class_quark_math_physics_ResistanceGrid_setPacked, ZEND_ACC_PUBLIC)
	ZEND_FE_END
};

static const zend_function_entry class_quark_math_physics_ExplosionMath_methods[] = {
	ZEND_ME(quark_math_physics_ExplosionMath, __construct, arginfo_class_quark_math_physics_ExplosionMath___construct, ZEND_ACC_PRIVATE)
	ZEND_ME(quark_math_physics_ExplosionMath, traceRays, arginfo_class_quark_math_physics_ExplosionMath_traceRays, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_physics_ExplosionMath, traceRay, arginfo_class_quark_math_physics_ExplosionMath_traceRay, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_physics_ExplosionMath, rayCount, arginfo_class_quark_math_physics_ExplosionMath_rayCount, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_physics_ExplosionMath, exposure, arginfo_class_quark_math_physics_ExplosionMath_exposure, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_math_physics_ExplosionMath, exposures, arginfo_class_quark_math_physics_ExplosionMath_exposures, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_FE_END
};

static const zend_function_entry class_quark_math_noise_Simplex_methods[] = {
	ZEND_ME(quark_math_noise_Simplex, __construct, arginfo_class_quark_math_noise_Simplex___construct, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_noise_Simplex, getNoise2D, arginfo_class_quark_math_noise_Simplex_getNoise2D, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_noise_Simplex, getNoise3D, arginfo_class_quark_math_noise_Simplex_getNoise3D, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_noise_Simplex, noise2D, arginfo_class_quark_math_noise_Simplex_noise2D, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_noise_Simplex, noise3D, arginfo_class_quark_math_noise_Simplex_noise3D, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_noise_Simplex, getFastNoise1D, arginfo_class_quark_math_noise_Simplex_getFastNoise1D, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_noise_Simplex, getFastNoise2D, arginfo_class_quark_math_noise_Simplex_getFastNoise2D, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_noise_Simplex, getFastNoise3D, arginfo_class_quark_math_noise_Simplex_getFastNoise3D, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_math_noise_Simplex, getFastNoise3DPacked, arginfo_class_quark_math_noise_Simplex_getFastNoise3DPacked, ZEND_ACC_PUBLIC)
	ZEND_FE_END
};

static const zend_function_entry class_quark_color_Color_methods[] = {
	ZEND_ME(quark_color_Color, __construct, arginfo_class_quark_color_Color___construct, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_color_Color, getA, arginfo_class_quark_color_Color_getA, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_color_Color, getR, arginfo_class_quark_color_Color_getR, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_color_Color, getG, arginfo_class_quark_color_Color_getG, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_color_Color, getB, arginfo_class_quark_color_Color_getB, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_color_Color, mix, arginfo_class_quark_color_Color_mix, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_color_Color, fromRGB, arginfo_class_quark_color_Color_fromRGB, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_color_Color, fromARGB, arginfo_class_quark_color_Color_fromARGB, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_color_Color, toARGB, arginfo_class_quark_color_Color_toARGB, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_color_Color, fromRGBA, arginfo_class_quark_color_Color_fromRGBA, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_color_Color, toRGBA, arginfo_class_quark_color_Color_toRGBA, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_color_Color, equals, arginfo_class_quark_color_Color_equals, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_color_Color, toRGB, arginfo_class_quark_color_Color_toRGB, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_color_Color, lerp, arginfo_class_quark_color_Color_lerp, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_color_Color, blend, arginfo_class_quark_color_Color_blend, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_color_Color, toHSV, arginfo_class_quark_color_Color_toHSV, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_color_Color, fromHSV, arginfo_class_quark_color_Color_fromHSV, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_ME(quark_color_Color, toHSL, arginfo_class_quark_color_Color_toHSL, ZEND_ACC_PUBLIC)
	ZEND_ME(quark_color_Color, fromHSL, arginfo_class_quark_color_Color_fromHSL, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	ZEND_FE_END
};

static zend_class_entry *register_class_quark_math_Axis(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "quark\\math", "Axis", class_quark_math_Axis_methods);
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

static zend_class_entry *register_class_quark_math_Facing(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "quark\\math", "Facing", class_quark_math_Facing_methods);
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

static zend_class_entry *register_class_quark_math_Math(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "quark\\math", "Math", class_quark_math_Math_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, ZEND_ACC_FINAL);

	return class_entry;
}

static zend_class_entry *register_class_quark_math_VectorMath(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "quark\\math", "VectorMath", class_quark_math_VectorMath_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, ZEND_ACC_FINAL);

	return class_entry;
}

static zend_class_entry *register_class_quark_math_Vector2(zend_class_entry *class_entry_Stringable)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "quark\\math", "Vector2", class_quark_math_Vector2_methods);
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

static zend_class_entry *register_class_quark_math_Vector3(zend_class_entry *class_entry_Stringable)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "quark\\math", "Vector3", class_quark_math_Vector3_methods);
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

static zend_class_entry *register_class_quark_math_RayTraceResult(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "quark\\math", "RayTraceResult", class_quark_math_RayTraceResult_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, 0);

	zval property_bb_default_value;
	ZVAL_UNDEF(&property_bb_default_value);
	zend_string *property_bb_name = zend_string_init("bb", sizeof("bb") - 1, 1);
	zend_string *property_bb_class_quark_math_AxisAlignedBB = zend_string_init("quark\\math\\AxisAlignedBB", sizeof("quark\\math\\AxisAlignedBB")-1, 1);
	zend_declare_typed_property(class_entry, property_bb_name, &property_bb_default_value, ZEND_ACC_PUBLIC|ZEND_ACC_READONLY, NULL, (zend_type) ZEND_TYPE_INIT_CLASS(property_bb_class_quark_math_AxisAlignedBB, 0, 0));
	zend_string_release(property_bb_name);

	zval property_hitFace_default_value;
	ZVAL_UNDEF(&property_hitFace_default_value);
	zend_string *property_hitFace_name = zend_string_init("hitFace", sizeof("hitFace") - 1, 1);
	zend_declare_typed_property(class_entry, property_hitFace_name, &property_hitFace_default_value, ZEND_ACC_PUBLIC|ZEND_ACC_READONLY, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_LONG));
	zend_string_release(property_hitFace_name);

	zval property_hitVector_default_value;
	ZVAL_UNDEF(&property_hitVector_default_value);
	zend_string *property_hitVector_name = zend_string_init("hitVector", sizeof("hitVector") - 1, 1);
	zend_string *property_hitVector_class_quark_math_Vector3 = zend_string_init("quark\\math\\Vector3", sizeof("quark\\math\\Vector3")-1, 1);
	zend_declare_typed_property(class_entry, property_hitVector_name, &property_hitVector_default_value, ZEND_ACC_PUBLIC|ZEND_ACC_READONLY, NULL, (zend_type) ZEND_TYPE_INIT_CLASS(property_hitVector_class_quark_math_Vector3, 0, 0));
	zend_string_release(property_hitVector_name);

	return class_entry;
}

static zend_class_entry *register_class_quark_math_AxisAlignedBB(zend_class_entry *class_entry_Stringable)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "quark\\math", "AxisAlignedBB", class_quark_math_AxisAlignedBB_methods);
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

static zend_class_entry *register_class_quark_math_VoxelRayTrace(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "quark\\math", "VoxelRayTrace", class_quark_math_VoxelRayTrace_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, ZEND_ACC_FINAL);

	return class_entry;
}

static zend_class_entry *register_class_quark_math_VoxelRayIterator(zend_class_entry *class_entry_Iterator)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "quark\\math", "VoxelRayIterator", class_quark_math_VoxelRayIterator_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, ZEND_ACC_FINAL);
	zend_class_implements(class_entry, 1, class_entry_Iterator);

	return class_entry;
}

static zend_class_entry *register_class_quark_math_collision_CollisionDataException(zend_class_entry *class_entry_RuntimeException)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "quark\\math\\collision", "CollisionDataException", NULL);
	class_entry = zend_register_internal_class_with_flags(&ce, class_entry_RuntimeException, 0);

	return class_entry;
}

static zend_class_entry *register_class_quark_math_collision_CollisionRegion(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "quark\\math\\collision", "CollisionRegion", class_quark_math_collision_CollisionRegion_methods);
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

	zval const_MAX_BOXES_PER_CELL_value;
	ZVAL_LONG(&const_MAX_BOXES_PER_CELL_value, 64);
	zend_string *const_MAX_BOXES_PER_CELL_name = zend_string_init_interned("MAX_BOXES_PER_CELL", sizeof("MAX_BOXES_PER_CELL") - 1, 1);
	zend_declare_class_constant_ex(class_entry, const_MAX_BOXES_PER_CELL_name, &const_MAX_BOXES_PER_CELL_value, ZEND_ACC_PUBLIC, NULL);
	zend_string_release(const_MAX_BOXES_PER_CELL_name);

	return class_entry;
}

static zend_class_entry *register_class_quark_math_collision_MoveResult(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "quark\\math\\collision", "MoveResult", class_quark_math_collision_MoveResult_methods);
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
	zend_string *property_boundingBox_class_quark_math_AxisAlignedBB = zend_string_init("quark\\math\\AxisAlignedBB", sizeof("quark\\math\\AxisAlignedBB")-1, 1);
	zend_declare_typed_property(class_entry, property_boundingBox_name, &property_boundingBox_default_value, ZEND_ACC_PUBLIC|ZEND_ACC_READONLY, NULL, (zend_type) ZEND_TYPE_INIT_CLASS(property_boundingBox_class_quark_math_AxisAlignedBB, 0, 0));
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

static zend_class_entry *register_class_quark_math_collision_SweepResult(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "quark\\math\\collision", "SweepResult", class_quark_math_collision_SweepResult_methods);
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
	zend_string *property_box_class_quark_math_AxisAlignedBB = zend_string_init("quark\\math\\AxisAlignedBB", sizeof("quark\\math\\AxisAlignedBB")-1, 1);
	zend_declare_typed_property(class_entry, property_box_name, &property_box_default_value, ZEND_ACC_PUBLIC|ZEND_ACC_READONLY, NULL, (zend_type) ZEND_TYPE_INIT_CLASS(property_box_class_quark_math_AxisAlignedBB, 0, 0));
	zend_string_release(property_box_name);

	zval property_key_default_value;
	ZVAL_UNDEF(&property_key_default_value);
	zend_declare_typed_property(class_entry, ZSTR_KNOWN(ZEND_STR_KEY), &property_key_default_value, ZEND_ACC_PUBLIC|ZEND_ACC_READONLY, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_LONG|MAY_BE_STRING));

	return class_entry;
}

static zend_class_entry *register_class_quark_math_collision_CollisionSolver(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "quark\\math\\collision", "CollisionSolver", class_quark_math_collision_CollisionSolver_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, ZEND_ACC_FINAL);

	return class_entry;
}

static zend_class_entry *register_class_quark_math_collision_VoxelHit(zend_class_entry *class_entry_quark_math_RayTraceResult)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "quark\\math\\collision", "VoxelHit", class_quark_math_collision_VoxelHit_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, class_entry_quark_math_RayTraceResult, ZEND_ACC_FINAL);

	zval property_blockX_default_value;
	ZVAL_UNDEF(&property_blockX_default_value);
	zend_string *property_blockX_name = zend_string_init("blockX", sizeof("blockX") - 1, 1);
	zend_declare_typed_property(class_entry, property_blockX_name, &property_blockX_default_value, ZEND_ACC_PUBLIC|ZEND_ACC_READONLY, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_LONG));
	zend_string_release(property_blockX_name);

	zval property_blockY_default_value;
	ZVAL_UNDEF(&property_blockY_default_value);
	zend_string *property_blockY_name = zend_string_init("blockY", sizeof("blockY") - 1, 1);
	zend_declare_typed_property(class_entry, property_blockY_name, &property_blockY_default_value, ZEND_ACC_PUBLIC|ZEND_ACC_READONLY, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_LONG));
	zend_string_release(property_blockY_name);

	zval property_blockZ_default_value;
	ZVAL_UNDEF(&property_blockZ_default_value);
	zend_string *property_blockZ_name = zend_string_init("blockZ", sizeof("blockZ") - 1, 1);
	zend_declare_typed_property(class_entry, property_blockZ_name, &property_blockZ_default_value, ZEND_ACC_PUBLIC|ZEND_ACC_READONLY, NULL, (zend_type) ZEND_TYPE_INIT_MASK(MAY_BE_LONG));
	zend_string_release(property_blockZ_name);

	return class_entry;
}

static zend_class_entry *register_class_quark_math_collision_Raycast(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "quark\\math\\collision", "Raycast", class_quark_math_collision_Raycast_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, ZEND_ACC_FINAL);

	return class_entry;
}

static zend_class_entry *register_class_quark_math_collision_Spatial(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "quark\\math\\collision", "Spatial", class_quark_math_collision_Spatial_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, ZEND_ACC_FINAL);

	return class_entry;
}

static zend_class_entry *register_class_quark_math_physics_Physics(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "quark\\math\\physics", "Physics", class_quark_math_physics_Physics_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, ZEND_ACC_FINAL);

	return class_entry;
}

static zend_class_entry *register_class_quark_math_physics_ResistanceGrid(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "quark\\math\\physics", "ResistanceGrid", class_quark_math_physics_ResistanceGrid_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, ZEND_ACC_FINAL);

	return class_entry;
}

static zend_class_entry *register_class_quark_math_physics_ExplosionMath(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "quark\\math\\physics", "ExplosionMath", class_quark_math_physics_ExplosionMath_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, ZEND_ACC_FINAL);

	return class_entry;
}

static zend_class_entry *register_class_quark_math_noise_Simplex(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "quark\\math\\noise", "Simplex", class_quark_math_noise_Simplex_methods);
	class_entry = zend_register_internal_class_with_flags(&ce, NULL, ZEND_ACC_FINAL);

	return class_entry;
}

static zend_class_entry *register_class_quark_color_Color(void)
{
	zend_class_entry ce, *class_entry;

	INIT_NS_CLASS_ENTRY(ce, "quark\\color", "Color", class_quark_color_Color_methods);
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
