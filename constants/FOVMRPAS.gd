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

#Octant lookup, used for finding octants to test in templates
enum FOVOctantType {NNW=0, NWW, SWW, SSW, SSE, SEE, NEE, NNE, MAX}

const FOVOctants = {
	FOVOctantType.NNW: {x = -1, y = -1, flip = false, shift=false, min_a = deg2rad(270), max_a = deg2rad(315), name="NorthNorthWest" },
	FOVOctantType.NWW: {x = -1, y = -1, flip = true, shift=true, min_a = deg2rad(315), max_a = TAU, name="NorthWestWest" },
	FOVOctantType.SWW: {x = -1, y = 1, flip = true, shift=false, min_a = 0, max_a = deg2rad(45), name="SouthWestWest" },
	FOVOctantType.SSW: {x = -1, y = 1, flip = false, shift=true, min_a = deg2rad(45), max_a = deg2rad(90), name="SouthSouthWest" },
	FOVOctantType.SSE: {x = 1, y = 1, flip = false, shift=false, min_a = deg2rad(90), max_a = deg2rad(135), name="SouthSouthEast" },
	FOVOctantType.SEE: {x = 1, y = 1, flip = true, shift=true, min_a = deg2rad(135), max_a = deg2rad(180), name="SouthEastEast" },
	FOVOctantType.NEE: {x = 1, y = -1, flip = true, shift=false, min_a = deg2rad(180), max_a = deg2rad(225), name="NorthEastEast" },
	FOVOctantType.NNE: {x = 1, y = -1, flip = false, shift=true, min_a = deg2rad(225), max_a = deg2rad(270), name="NorthNorthEast" },
}

class CellAngles extends Reference:
	var near
	var far
	var center
	
	func _init(near, center, far):
		self.near = near
		self.center = center
		self.far = far

##############################################################################
#									CAST FUNCTIONS							 #
#Used to find unblocked cells in certain shapes based on a 2d array mask	 #
##############################################################################

#Cast out to radius from origin based on a tile mask tiles.  Used for FOV and 
#explosions 
static func cast_area(origin:Vector2, radius:int, tiles:Array) ->PoolVector2Array:
	var cells = PoolVector2Array()
	for oct in FOVOctants.values():
		cells.append_array(_visible_cells_in_octant_from(origin, oct, radius, tiles))
	cells.append(origin)
	return cells

#Cast a shadow-cast friendly lerpline that should reach any visible cell
static func cast_lerp_line(origin:Vector2, target:Vector2, max_length:int, tiles:Array) -> PoolVector2Array:
	var oct = _get_octant(origin, target)
	return _lerp_line(origin, target, oct, max_length, tiles)

#Cast a circle segment from from aiming at to with width(ish) radians angle out
#to radius, shadowcasting against tiles.  Buggy, slow and has many possible
#input values that don't look right
static func cast_cone_at(from: Vector2, to: Vector2, width: float, radius: int, tiles: Array) -> PoolVector2Array:
	var angle_v := from.direction_to(to) * radius
	var angle := to.angle_to_point(from)
	var min_v := angle_v.rotated(-(width/2))
	var max_v := angle_v.rotated(width/2)
	var octs := _get_angle_range_octants(min_v, max_v)
	var cells := PoolVector2Array()
	for oct in octs:
		cells.append_array(_visible_cells_in_octant_from_in_range(from, oct, radius, tiles, min_v, max_v))
	return cells


#Cast a line to a point in oct maxing at radius, will prefer a lerp line but 
#can deflect a little to allow targeting any visible cell.  Lerp lines and
#bresenham look much better
static func _lerp_line(origin:Vector2, target:Vector2, oct:Dictionary, radius:int, tiles:Array) -> PoolVector2Array:
	var target_iteration := _iteration_at(origin, target, oct)
	var target_step := _step_at(origin, target, oct)
	var target_allocation := 1.0 / float(target_iteration + 1)
	var target_angles := CellAngles.new(float(target_step) * target_allocation, float(target_step+0.5) * target_allocation, float(target_step + 1) * target_allocation)
	var target_cells := PoolVector2Array()
	var prefer_x := false
	var last_cell = target
	if !tiles[target.x][target.y]:
		target_cells.append(last_cell)
	var max_x = tiles.size()
	var max_y = tiles[0].size()
	var delta = target - origin
	var N = max(abs(delta.x), abs(delta.y))
	for iteration in range(target_iteration, 0, -1):
		var num_cells_in_row = iteration + 1
		var angle_allocation = 1.0 / float(num_cells_in_row)
		var closest_dist = INF
		var best_cell = null
		var best_step = 0
		var t = float(iteration)/float(N)
		var lerp_target_cell = Vector2(round(lerp(target.x, origin.x, t)), round(lerp(target.y, origin.y, t)))
		# Start at the center (vertical or horizontal line) and step outwards
		target_step = _step_at(origin, lerp_target_cell, oct)
		for step in range(floor(target_angles.near * num_cells_in_row), ceil(target_angles.far * num_cells_in_row)):
			var cell = _cell_at(origin, oct, step, iteration)
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

static func  _visible_cells_in_octant_from_in_range(origin, oct, radius, tiles, min_v, max_v) -> PoolVector2Array:
	var iteration = 1
	var visible_cells = PoolVector2Array()
	var obstructions = []
	var max_x = tiles.size()
	var max_y = tiles[0].size()
	var radius_sq = radius * radius
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
			var cell = _cell_at(origin, oct, step, iteration)
			if _cell_in_radius(origin, cell, radius):
				var cell_angles = CellAngles.new((float(step) * angle_allocation),
											(float(step + .5) * angle_allocation),
											(float(step + 1) * angle_allocation))
				if _cell_is_visible(cell_angles, obstructions):
					if (!oct.shift and step == num_cells_in_row - 1) or (oct.shift and step == 0):
						pass
					elif _cell_in_segment(origin, cell, min_v, max_v):
						visible_cells.append(cell)
					if cell.x < 0 or cell.y < 0 or cell.x >= max_x or cell.y >= max_y or tiles[cell.x][cell.y]:
							obstructions = _add_obstruction(obstructions, cell_angles)
				elif NOT_VISIBLE_BLOCKS_VISION:
					obstructions = _add_obstruction(obstructions, cell_angles)

		iteration += 1

	return visible_cells

#Finds all cells from origin in oct out to radius shadowcasting against tiles
static func  _visible_cells_in_octant_from(origin:Vector2, oct:Dictionary, radius:int, tiles:Array) -> PoolVector2Array:
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
			var cell = _cell_at(origin, oct, step, iteration)
			if _cell_in_radius(origin, cell, radius):
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

#Find iteration in octant from origin for a cell
static func _iteration_at(origin:Vector2, cell:Vector2, oct:Dictionary) -> int:
	var iteration
	if oct.flip:
		iteration = (cell.y - origin.y)/oct.y
	else:
		iteration = (cell.x - origin.x)/oct.x
	return iteration
	
#Find the step in octant from origin for a cell
static func _step_at(origin:Vector2, cell:Vector2, oct:Dictionary) -> int:
	var step
	if oct.flip:
		step = (cell.x - origin.x)/oct.x
	else:
		step = (cell.y - origin.y)/oct.y
	return step

#Find the cell at step and iteration in octant from origin
static func _cell_at(origin:Vector2, oct:Dictionary, step:int, iteration:int) -> Vector2:
	var cell
	if oct.flip:
		cell = Vector2(origin.x + step * oct.x, origin.y + iteration * oct.y)
	else:
		cell = Vector2(origin.x + iteration * oct.x, origin.y + step * oct.y)
	return cell

#Find out if a cell is within radius of the origin.  Probably could be done
#inline
static func _cell_in_radius(origin:Vector2, cell:Vector2, radius:int) -> bool:
	var fudged_radius = (float(radius) + RADIUS_FUDGE)
	return origin.distance_squared_to(cell) <= radius * radius

#check if a cell is obstructed by any obstruction
static func _cell_is_visible(cell_angles:CellAngles, obstructions:Array) -> bool:
	var near_visible := true
	var center_visible := true
	var far_visible := true

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
static func _add_obstruction(obstructions:Array, new_obstruction:CellAngles) -> Array:
	var new_list = []#[o for o in obstructions if not self._combine_obstructions(o, new_object)]
	for o in obstructions:
		if not _combine_obstructions(o, new_obstruction):
			new_list.append(o)
	new_list.append(new_obstruction)
	return new_list
	
# Returns True if you combine, False otherwise
static func _combine_obstructions(old:CellAngles, new:CellAngles) -> bool:
	# Pseudo-sort; if their near values are equal, they overlap
	var low: CellAngles
	var high: CellAngles
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

#Find which oct from from to is in
static func _get_octant(from:Vector2, to:Vector2) -> Dictionary:
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
	return {}

#Find all octants that overlap a circle segment described by min_v and max_v.
static func _get_angle_range_octants(min_v:Vector2, max_v:Vector2) -> Array:
	var octs := []
	for oct in FOVOctants.values():
		if _angle_in_range(min_v, max_v, oct.min_) or _angle_in_range(min_v, max_v, oct.max_a):
			octs.append(oct)
	return octs

#Check if a cell is in the circle segment described by min_v and max_v from
#origin
static func _cell_in_segment(origin:Vector2, cell:Vector2, min_v:Vector2, max_v:Vector2) -> bool:
	return _vector_in_vector_angle_range(min_v, max_v, origin - cell)

#Check if vector is within the circle segment described by min_v and max_v by
#testing if it is clockwise of min_v and counterclockwise of max_v
static func _vector_in_vector_angle_range(min_v:Vector2, max_v:Vector2, test_v:Vector2) -> bool:
	return _is_clockwise(min_v, test_v) and _is_clockwise(test_v, max_v)

#Check if angle is within the circle segment described by ccw_v and cw_v by
#testing if it is clockwise of ccw_v and counterclockwise of cw_v
static func _angle_in_range(min_v:Vector2, max_v:Vector2, test_a:float) -> bool:
	var test_v = Vector2.RIGHT.rotated(test_a)
	return _is_clockwise(min_v, test_v) and _is_clockwise(test_v, max_v)

#Check if v2 is clockwise of v1... maybe, I'm bad at vector math but it seems
#to work \{**}/
static func _is_clockwise(v1: Vector2, v2: Vector2) -> bool:
	return v1.tangent().dot(v2) > 0
