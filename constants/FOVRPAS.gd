extends Node
#godot implementation of rpas from https://github.com/MoyTW/roguebasin_rpas/ including most comments because I never comment D:

# Changing the radius-fudge changes how smooth the edges of the vision bubble are.
#
# RADIUS_FUDGE should always be a value between 0 and 1.
const RADIUS_FUDGE = 1.0 / 5.0

# If this is False, some cells will unexpectedly be visible.
#
# For example, let's say you you have obstructions blocking (0.0 - 0.25) and (.33 - 1.0).
# A far off cell with (near=0.25, center=0.3125, far=0.375) will have both its near and center unblocked.
#
# On certain restrictiveness settings this will mean that it will be visible, but the blocks in front of it will
# not, which is unexpected and probably not desired.
#
# Setting it to True, however, makes the algorithm more restrictive.
const NOT_VISIBLE_BLOCKS_VISION = true

# Determines how restrictive the algorithm is.
#
# 0 - if you have a line to the near, center, or far, it will return as visible
# 1 - if you have a line to the center and at least one other corner it will return as visible
# 2 - if you have a line to all the near, center, and far, it will return as visible
#
# If any other value is given, it will treat it as a 2.
const RESTRICTIVENESS = 0

# If VISIBLE_ON_EQUAL is False, an obstruction will obstruct its endpoints. If True, it will not.
#
# For example, if there is an obstruction (0.0 - 0.25) and a square at (0.25 - 0.5), the square's near angle will
# be unobstructed in True, and obstructed on False.
#
# Setting this to False will make the algorithm more restrictive.
const VISIBLE_ON_EQUAL = false

enum FOVOctantType {NNW=0, NWW, SWW, SSW, SSE, SEE, NEE, NNE, MAX}

const FOVOctants = {
	FOVOctantType.NNW: {x = -1, y = -1, flip = false, shift=false, min_a = deg2rad(270), max_a = deg2rad(315) },
	FOVOctantType.NWW: {x = -1, y = -1, flip = true, shift=true, min_a = deg2rad(315), max_a = TAU },
	FOVOctantType.SWW: {x = -1, y = 1, flip = true, shift=false, min_a = 0, max_a = deg2rad(45) },
	FOVOctantType.SSW: {x = -1, y = 1, flip = false, shift=true, min_a = deg2rad(45), max_a = deg2rad(90) },
	FOVOctantType.SSE: {x = 1, y = 1, flip = false, shift=false, min_a = deg2rad(90), max_a = deg2rad(135) },
	FOVOctantType.SEE: {x = 1, y = 1, flip = true, shift=true, min_a = deg2rad(135), max_a = deg2rad(180) },
	FOVOctantType.NEE: {x = 1, y = -1, flip = true, shift=false, min_a = deg2rad(180), max_a = deg2rad(225) },
	FOVOctantType.NNE: {x = 1, y = -1, flip = false, shift=true, min_a = deg2rad(225), max_a = deg2rad(270) },
}

class CellAngles extends Reference:
	var near
	var far
	var center
	
	func _init(near, center, far):
		self.near = near
		self.center = center
		self.far = far

# Parameter tiles should be multidimensional array of each tile's visibility 
#
# Returns an array with all Vect2 visible from the centerpoint.
static func calc_visible_cells_from(x_center, y_center, radius, tiles) ->PoolVector2Array:
#	var cells = _visible_cells_in_quadrant_from(x_center, y_center, 1, 1, radius, tiles)
#	cells.append_array(_visible_cells_in_quadrant_from(x_center, y_center, 1, -1, radius, tiles))
#	cells.append_array(_visible_cells_in_quadrant_from(x_center, y_center, -1, -1, radius, tiles))
#	cells.append_array(_visible_cells_in_quadrant_from(x_center, y_center, -1, 1, radius, tiles))
	var cells = PoolVector2Array()
	for oct in FOVOctants.values():
		cells.append_array(_visible_cells_in_octant_from(x_center, y_center, oct, radius, tiles))
	cells.append(Vector2(x_center, y_center))
	print("Total cells: " + str(cells.size()))
	return cells

# Parameters quad_x, quad_y should only be 1 or -1. The combination of the two determines the quadrant.
# Returns an array of Vect2.
#static func _visible_cells_in_quadrant_from(x_center, y_center, quad_x, quad_y, radius, tiles) -> PoolVector2Array:
#	var cells = _visible_cells_in_octant_from(x_center, y_center, quad_x, quad_y, radius, tiles, true)
#	cells.append_array(_visible_cells_in_octant_from(x_center, y_center, quad_x, quad_y, radius, tiles, false))
#	return cells

# Returns an array of Vect2
# Utilizes the NOT_VISIBLE_BLOCKS_VISION constant.
static func  _visible_cells_in_octant_from(x_center, y_center, oct, radius, tiles) -> PoolVector2Array:
	var iteration = 1
	var visible_cells = []
	var obstructions = []
	var max_x = tiles.size()
	var max_y = tiles[0].size()
	# End conditions:
	#   iteration > radius
	#   Full obstruction coverage (indicated by one object in the obstruction list covering the full angle from 0
	#      to 1)
	while iteration <= radius and not (obstructions.size() == 1 and
										obstructions[0].near == 0.0 and obstructions[0].far == 1.0):
		var num_cells_in_row = iteration + 1
		var angle_allocation = 1.0 / float(num_cells_in_row)

		# Start at the center (vertical or horizontal line) and step outwards
		for step in range(iteration + 1):
			var cell = _cell_at(x_center, y_center, oct, step, iteration)
			if _cell_in_radius(x_center, y_center, cell, radius):
				var cell_angles = CellAngles.new((float(step) * angle_allocation),
											(float(step + .5) * angle_allocation),
											(float(step + 1) * angle_allocation))
				if _cell_is_visible(cell_angles, obstructions):
					if (!oct.shift and step == num_cells_in_row - 1) or (oct.shift and step == 0):
						pass
					else:
						visible_cells.append(cell)
					if cell.x < 0 or cell.y < 0 or cell.x >= max_x or cell.y >= max_y or tiles[cell.x][cell.y]:
						obstructions = _add_obstruction(obstructions, cell_angles)
				elif NOT_VISIBLE_BLOCKS_VISION:
					obstructions = _add_obstruction(obstructions, cell_angles)

		iteration += 1

	return visible_cells

static func  _reverse_cast(x_center, y_center, t_x, t_y, oct, radius, tiles) -> PoolVector2Array:
	var target_iteration = _iteration_at(x_center, y_center, t_x, t_y, oct)
	var target_step = _step_at(x_center, y_center, t_x, t_y, oct)
	var target_allocation = 1.0 / float(target_iteration + 1)
	var target_angles = CellAngles.new(float(target_step) * target_allocation, float(target_step+0.5) * target_allocation, float(target_step + 1) * target_allocation)
	var target_cells = PoolVector2Array()
	var prefer_x = false
	if !tiles[t_x][t_y]:
		target_cells.append(Vector2(t_x, t_y))
	var origin_cell = Vector2(x_center, y_center)
	var max_x = tiles.size()
	var max_y = tiles[0].size()
	# End conditions:
	#   iteration > radius
	#   Full obstruction coverage (indicated by one object in the obstruction list covering the full angle from 0
	#      to 1)
	for iteration in range(target_iteration - 1, 0, -1):
		var num_cells_in_row = iteration + 1
		var angle_allocation = 1.0 / float(num_cells_in_row)
		var closest_dist = INF
		var best_cell = null
		var best_step = 0
		# Start at the center (vertical or horizontal line) and step outwards
		for step in range(floor(target_angles.near * num_cells_in_row), ceil(target_angles.far * num_cells_in_row)):
			var cell = _cell_at(x_center, y_center, oct, step, iteration)
			if !tiles[cell.x][cell.y]:
				var cell_dist = abs(target_angles.center - (float(step) * angle_allocation))
				if cell_dist < closest_dist:
					closest_dist = cell_dist
					best_cell = cell
					best_step = step
		if best_cell:
			target_cells.append(best_cell)
			target_angles = CellAngles.new(float(best_step) * angle_allocation, float(best_step+0.5)* angle_allocation, float(best_step + 1.0) * angle_allocation)
		else:
			target_cells = PoolVector2Array()
			var new_center_step = int(target_angles.center*num_cells_in_row)
			target_angles = CellAngles.new(float(new_center_step - 0.5) * angle_allocation, float(new_center_step) * angle_allocation, float(new_center_step + 0.5) * angle_allocation)
			
	return target_cells
	
static func lerp_line(x_center, y_center, t_x, t_y, oct, radius, tiles) -> PoolVector2Array:
	var target_iteration = _iteration_at(x_center, y_center, t_x, t_y, oct)
	var target_step = _step_at(x_center, y_center, t_x, t_y, oct)
	var target_allocation = 1.0 / float(target_iteration + 1)
	var target_angles = CellAngles.new(float(target_step) * target_allocation, float(target_step+0.5) * target_allocation, float(target_step + 1) * target_allocation)
	var target_cells = PoolVector2Array()
	var prefer_x = false
	var last_cell = Vector2(t_x, t_y)
	if !tiles[t_x][t_y]:
		target_cells.append(last_cell)
	var origin_cell = Vector2(x_center, y_center)
	var max_x = tiles.size()
	var max_y = tiles[0].size()
	var dx = t_x - x_center
	var dy = t_y - y_center
	var N = max(abs(dx), abs(dy))
	for iteration in range(target_iteration, 0, -1):
		var num_cells_in_row = iteration + 1
		var angle_allocation = 1.0 / float(num_cells_in_row)
		var closest_dist = INF
		var best_cell = null
		var best_step = 0
		var t = float(iteration)/float(N)
		var lerp_target_cell = Vector2(round(lerp(t_x, x_center, t)), round(lerp(t_y, y_center, t)))
		# Start at the center (vertical or horizontal line) and step outwards
		target_step = _step_at(x_center, y_center, lerp_target_cell.x, lerp_target_cell.y, oct)
		for step in range(floor(target_angles.near * num_cells_in_row), ceil(target_angles.far * num_cells_in_row)):
			var cell = _cell_at(x_center, y_center, oct, step, iteration)
			if !tiles[cell.x][cell.y]:
				if cell == lerp_target_cell:
					best_cell = cell
					best_step = step
					break
				var cell_dist = abs(target_angles.center - (float(step) * angle_allocation))
				if cell_dist < closest_dist:
					closest_dist = cell_dist
					best_cell = cell
					best_step = step
		if best_cell:
			target_cells.append(best_cell)
			last_cell = best_cell
		else:
			target_cells = PoolVector2Array()
			
	return target_cells

static func _cone_cast_octant_rot(x_center, y_center, oct, radius, tiles, rotation, width) -> PoolVector2Array:
	var iteration = 1
	var visible_cells = []
	var obstructions = []
	var max_x = tiles.size()
	var max_y = tiles[0].size()
	var origin_cell = Vector2(x_center, y_center)
	# End conditions:
	#   iteration > radius
	#   Full obstruction coverage (indicated by one object in the obstruction list covering the full angle from 0
	#      to 1)
	while iteration <= radius and not (obstructions.size() == 1 and
										obstructions[0].near == 0.0 and obstructions[0].far == 1.0):
		var num_cells_in_row = iteration + 1
		var angle_allocation = 1.0 / float(num_cells_in_row)

		# Start at the center (vertical or horizontal line) and step outwards
		for step in range(ceil((iteration + 1) * width)):
			var cell = _cell_at(x_center, y_center, oct, step, iteration)
			cell = (cell - origin_cell).rotated(rotation) + origin_cell
			cell = Vector2(int(cell.x), int(cell.y))
			if _cell_in_radius(x_center, y_center, cell, radius):
				var cell_angles = CellAngles.new((float(step) * angle_allocation),
											(float(step + .5) * angle_allocation),
											(float(step + 1) * angle_allocation))
				if _cell_is_visible(cell_angles, obstructions):
					if (!oct.shift and step == num_cells_in_row - 1) or (oct.shift and step == 0):
						pass
					else:
						visible_cells.append(cell)
					if cell.x < 0 or cell.y < 0 or cell.x >= max_x or cell.y >= max_y or tiles[cell.x][cell.y]:
						obstructions = _add_obstruction(obstructions, cell_angles)
				elif NOT_VISIBLE_BLOCKS_VISION:
					obstructions = _add_obstruction(obstructions, cell_angles)

		iteration += 1

	return visible_cells

static func _cone_cast_octant(x_center, y_center, oct, radius, tiles, step_cut, iteration_cut) -> PoolVector2Array:
	var iteration = 1
	var visible_cells = []
	var obstructions = []
	var max_x = tiles.size()
	var max_y = tiles[0].size()
	var origin_cell = Vector2(x_center, y_center)
	# End conditions:
	#   iteration > radius
	#   Full obstruction coverage (indicated by one object in the obstruction list covering the full angle from 0
	#      to 1)
	while iteration <= radius and not (obstructions.size() == 1 and
										obstructions[0].near == 0.0 and obstructions[0].far == 1.0):
		var num_cells_in_row = iteration + 1
		var angle_allocation = 1.0 / float(num_cells_in_row)

		# Start at the center (vertical or horizontal line) and step outwards
		for step in range(iteration + 1 ):
			var cell = _cell_at(x_center, y_center, oct, step, iteration)
			cell = Vector2(int(cell.x), int(cell.y))
			if _cell_in_radius(x_center, y_center, cell, radius):
				var cell_angles = CellAngles.new((float(step) * angle_allocation),
											(float(step + .5) * angle_allocation),
											(float(step + 1) * angle_allocation))
				if _cell_is_visible(cell_angles, obstructions):
					if (!oct.shift and step == num_cells_in_row - 1) or (oct.shift and step == 0):
						pass
					elif step <= step_cut and iteration <= iteration_cut:
						visible_cells.append(cell)
					if cell.x < 0 or cell.y < 0 or cell.x >= max_x or cell.y >= max_y or tiles[cell.x][cell.y]:
						obstructions = _add_obstruction(obstructions, cell_angles)
				elif NOT_VISIBLE_BLOCKS_VISION:
					obstructions = _add_obstruction(obstructions, cell_angles)

		iteration += 1
		
	return visible_cells

static func  _visible_cells_in_octant_from_in_range(x_center, y_center, oct, radius, tiles, min_a, max_a, mod_a) -> PoolVector2Array:
	var iteration = 1
	var visible_cells = PoolVector2Array()
	var obstructions = []
	var max_x = tiles.size()
	var max_y = tiles[0].size()
	# End conditions:
	#   iteration > radius
	#   Full obstruction coverage (indicated by one object in the obstruction list covering the full angle from 0
	#      to 1)
	while iteration <= radius and not (obstructions.size() == 1 and
										obstructions[0].near == 0.0 and obstructions[0].far == 1.0):
		var num_cells_in_row = iteration + 1
		var angle_allocation = 1.0 / float(num_cells_in_row)

		# Start at the center (vertical or horizontal line) and step outwards
		for step in range(iteration + 1):
			var cell = _cell_at(x_center, y_center, oct, step, iteration)
			if _cell_in_radius(x_center, y_center, cell, radius):
				var cell_angles = CellAngles.new((float(step) * angle_allocation),
											(float(step + .5) * angle_allocation),
											(float(step + 1) * angle_allocation))
				if _cell_is_visible(cell_angles, obstructions):
					if (!oct.shift and step == num_cells_in_row - 1) or (oct.shift and step == 0):
						pass
					elif _cell_in_angle_range(x_center, y_center, cell, min_a, max_a, mod_a):
						visible_cells.append(cell)
					if cell.x < 0 or cell.y < 0 or cell.x >= max_x or cell.y >= max_y or tiles[cell.x][cell.y]:
							obstructions = _add_obstruction(obstructions, cell_angles)
				elif NOT_VISIBLE_BLOCKS_VISION:
					obstructions = _add_obstruction(obstructions, cell_angles)

		iteration += 1

	return visible_cells

static func _cell_in_angle_range(x_center, y_center, cell, min_a, max_a, mod_a):
	var cell_angle = fmod(cell.angle_to_point(Vector2(x_center, y_center))+TAU, TAU) + mod_a
	if cell_angle >= min_a and cell_angle <= max_a:
		return true
	else:
		return false

static func intersect(point, min_a, max_a):
	if min_a > max_a:
		if point >= min_a or point <= max_a:
			return true
	else:
		if point>=min_a and point<=max_a:
			return true
	return false

static func cast_cone(x_center, y_center, radius, angle, tiles, width):
	angle = fmod(angle + TAU, TAU)
	var mod_a = 0
	var min_a = fmod( (angle + TAU) - (width/2), TAU )
	var max_a = fmod( (angle) + (width/2), TAU )
	if min_a >= max_a:
		mod_a = TAU
		max_a += mod_a
	var octs = _get_angle_range_octants(min_a, max_a, mod_a)
	var cells = PoolVector2Array()
	for oct in FOVOctants.values():
		cells.append_array(_visible_cells_in_octant_from_in_range(x_center, y_center, oct, radius, tiles, min_a, max_a, mod_a))
	return cells

static func cast_cone_poorly(x_center, y_center, radius, angle, tiles, width):
	var max_point = Vector2(radius*-1, 0).rotated(angle)
	var right_max = Vector2(max_point.x, max_point.y).rotated(width/2).round()
	var left_max = Vector2(right_max.x, right_max.y).reflect(max_point).round()
	var right_oct = get_octant(Vector2.ZERO, right_max)
	var left_oct = get_octant(Vector2.ZERO, left_max)
	var right_iteration = _iteration_at(0, 0, right_max.x, right_max.y, right_oct)
	var left_iteration = _iteration_at(0, 0, left_max.x, left_max.y, left_oct)
	var right_step = _step_at(0, 0, right_max.x, right_max.y, right_oct)
	var left_step = _step_at(0, 0, left_max.x, left_max.y, left_oct)
	var cells = _cone_cast_octant(x_center, y_center, right_oct, radius, tiles, right_step, right_iteration)
	cells.append_array(_cone_cast_octant(x_center, y_center, left_oct, radius, tiles, left_step, left_iteration))
	return cells
	
# Returns a Vector2.
static func _cell_at(x_center, y_center, oct, step, iteration) -> Vector2:
	var cell
	if oct.flip:
		cell = Vector2(x_center + step * oct.x, y_center + iteration * oct.y)
	else:
		cell = Vector2(x_center + iteration * oct.x, y_center + step * oct.y)
	return cell


static func _iteration_at(x_center, y_center, cell_x, cell_y, oct) -> int:
	var iteration
	if oct.flip:
		iteration = (cell_y - y_center)/oct.y
	else:
		iteration = (cell_x - x_center)/oct.x
	return iteration

static func _step_at(x_center, y_center, cell_x, cell_y, oct) -> int:
	var step
	if oct.flip:
		step = (cell_x - x_center)/oct.x
	else:
		step = (cell_y - y_center)/oct.y
	return step

static func _cell_in_radius(x_center, y_center, cell, radius) -> bool:
	var cell_distance = sqrt((x_center - cell.x) * (x_center - cell.x) +
								(y_center - cell.y) * (y_center - cell.y))
	return cell_distance <= float(radius) + RADIUS_FUDGE

# Utilizes the VISIBLE_ON_EQUAL and RESTRICTIVENESS variables.
static func _cell_is_visible(cell_angles, obstructions) -> bool:
	var near_visible = true
	var center_visible = true
	var far_visible = true

	for obstruction in obstructions:
		if VISIBLE_ON_EQUAL:
			if obstruction.near < cell_angles.near and cell_angles.near < obstruction.far:
				near_visible = false
			if obstruction.near < cell_angles.center and cell_angles.center < obstruction.far:
				center_visible = false
			if obstruction.near < cell_angles.far and cell_angles.far < obstruction.far:
				far_visible = false
		else:
			if obstruction.near <= cell_angles.near and cell_angles.near <= obstruction.far:
				near_visible = false
			if obstruction.near < cell_angles.center and cell_angles.center < obstruction.far:
				center_visible = false
			if obstruction.near <= cell_angles.far and cell_angles.far <= obstruction.far:
				far_visible = false

	if RESTRICTIVENESS == 0:
		return center_visible or near_visible or far_visible
	elif RESTRICTIVENESS == 1:
		return (center_visible and near_visible) or (center_visible and far_visible)
	else:
		return center_visible and near_visible and far_visible

# Generates a new array by combining all old obstructions with the new one (removing them if they are combined) and
# adding the resulting obstruction to the list.
#
# Returns the generated list.
static func _add_obstruction(obstructions, new_obstruction):
	var new_list = []#[o for o in obstructions if not self._combine_obstructions(o, new_object)]
	for o in obstructions:
		if not _combine_obstructions(o, new_obstruction):
			new_list.append(o)
	new_list.append(new_obstruction)
	return new_list

# Returns True if you combine, False otherwise
static func _combine_obstructions(old, new) -> bool:
	# Pseudo-sort; if their near values are equal, they overlap
	var low
	var high
	if old.near < new.near:
		low = old
		high = new
	elif new.near < old.near:
		low = new
		high = old
	else:
		new.far = max(old.far, new.far)
		return true

	# If they overlap, combine and return True
	if low.far >= high.near:
		new.near = min(low.near, high.near)
		new.far = max(low.far, high.far)
		return true

	return false
	
static func _get_angle_range(angle, width) -> Array:
	var min_angle = fmod( (angle + TAU) - (width/2), TAU )
	var max_angle = fmod( (angle) + (width/2), TAU )
	return [min_angle, max_angle]

static func _get_angle_range_octants(min_angle, max_angle, a_mod) -> Array:
	var octs = []
	for oct in FOVOctants.values():
		if intersect(max_angle - a_mod, oct.min_a, oct.max_a) or \
			intersect(min_angle, oct.min_a, oct.max_a) or \
			intersect(oct.min_a, min_angle, max_angle - a_mod) or \
			intersect(oct.max_a, min_angle, max_angle - a_mod):
			octs.append(oct)
	return octs

static func can_see_point(from, to, tiles, site_range):
	var oct = get_octant(from, to)
	for tile in _visible_cells_in_octant_from(from.x, from.y, oct, site_range, tiles):
		if tile == to:
			return true
	return false
	
static func get_octant(from, to):
	var mod_x
	var mod_y
	var delta_v = (to - from)
	var delta_abs = delta_v.abs()
	if from.x + (delta_abs.x) == to.x:
		mod_x = 1
	else:
		mod_x = -1
	if from.y + (delta_abs.y) == to.y:
		mod_y = 1
	else:
		mod_y = -1
	var flip = delta_abs.x <= delta_abs.y
	#Probably could have handled this differently
	for oct in FOVOctants.values():
		if oct.x == mod_x and oct.y == mod_y and oct.flip == flip:
			return oct
	return false


	
