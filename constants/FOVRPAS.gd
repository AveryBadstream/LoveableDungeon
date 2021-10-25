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
static func calc_visible_cells_from(x_center, y_center, radius, tiles):
	var cells = _visible_cells_in_quadrant_from(x_center, y_center, 1, 1, radius, tiles)
	cells.append_array(_visible_cells_in_quadrant_from(x_center, y_center, 1, -1, radius, tiles))
	cells.append_array(_visible_cells_in_quadrant_from(x_center, y_center, -1, -1, radius, tiles))
	cells.append_array(_visible_cells_in_quadrant_from(x_center, y_center, -1, 1, radius, tiles))
	cells.append(Vector2(x_center, y_center))
	return cells

# Parameters quad_x, quad_y should only be 1 or -1. The combination of the two determines the quadrant.
# Returns an array of Vect2.
static func _visible_cells_in_quadrant_from(x_center, y_center, quad_x, quad_y, radius, tiles):
	var cells = _visible_cells_in_octant_from(x_center, y_center, quad_x, quad_y, radius, tiles, true)
	cells.append_array(_visible_cells_in_octant_from(x_center, y_center, quad_x, quad_y, radius, tiles, false))
	return cells

# Returns an array of Vect2
# Utilizes the NOT_VISIBLE_BLOCKS_VISION constant.
static func  _visible_cells_in_octant_from(x_center, y_center, quad_x, quad_y, radius, tiles, is_vertical) -> Array:
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
			var cell = _cell_at(x_center, y_center, quad_x, quad_y, step, iteration, is_vertical)

			if _cell_in_radius(x_center, y_center, cell, radius):
				var cell_angles = CellAngles.new((float(step) * angle_allocation),
											(float(step + .5) * angle_allocation),
											(float(step + 1) * angle_allocation))

				if _cell_is_visible(cell_angles, obstructions):
					visible_cells.append(cell)
					if cell.x < 0 or cell.y < 0 or cell.x >= max_x or cell.y >= max_y or tiles[cell.x][cell.y]:
						obstructions = _add_obstruction(obstructions, cell_angles)
				elif NOT_VISIBLE_BLOCKS_VISION:
					obstructions = _add_obstruction(obstructions, cell_angles)

		iteration += 1

	return visible_cells

# Returns a Vector2.
static func _cell_at(x_center, y_center, quad_x, quad_y, step, iteration, is_vertical) -> Vector2:
	var cell
	if is_vertical:
		cell = Vector2(x_center + step * quad_x, y_center + iteration * quad_y)
	else:
		cell = Vector2(x_center + iteration * quad_x, y_center + step * quad_y)
	return cell

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
