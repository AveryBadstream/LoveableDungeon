extends Node
#godot implementation of rpas from https://github.com/MoyTW/roguebasin_rpas/ including most comments because I never comment D:

# Changing the radius-fudge changes how smooth the edges of the vision bubble are.
#I might remove this and replace with r^2, but there are a lot of improvements
#before that
# RADIUS_FUDGE should always be a value between 0 and 1.
const RADIUS_FUDGE = 1.0 / 3.0

# If this is False, some cells will unexpectedly be visible.
#
# For example, let's say you you have obstructions blocking (0.0 - 0.25) and (.33 - 1.0).
# A far off cell with (near=0.25, center=0.3125, far=0.375) will have both its near and center unblocked.
#
# On certain restrictiveness settings this will mean that it will be visible, but the blocks in front of it will
# not, which is unexpected and probably not desired.
#
# Setting it to True, however, makes the algorithm more restrictive.
#const NOT_VISIBLE_BLOCKS_VISION = true
const NVBV = true
# Determines how restrictive the algorithm is.
#
# 0 - if you have a line to the near, center, or far, it will return as visible
# 1 - if you have a line to the center and at least one other corner it will return as visible
# 2 - if you have a line to all the near, center, and far, it will return as visible
#
# If any other value is given, it will treat it as a 2.
#const RESTRICTIVENESS = 0
const R = 0

# If VISIBLE_ON_EQUAL is False, an obstruction will obstruct its endpoints. If True, it will not.
#
# For example, if there is an obstruction (0.0 - 0.25) and a square at (0.25 - 0.5), the square's near angle will
# be unobstructed in True, and obstructed on False.
#
# Setting this to False will make the algorithm more restrictive.
#const VISIBLE_ON_EQUAL = false
const VOE = false

#Octant lookup, used for finding octants to test in templates, min_a and max_a 
#are totally wrong and only work by rotating Vector2.LEFT, but I can't be
#bothered
enum FOVOctantType {NNW=0, NWW, SWW, SSW, SSE, SEE, NEE, NNE, MAX}

const FOVOctants = {
	FOVOctantType.NWW: {x = -1, y = -1, flip = false, shift=true, min_a = deg2rad(180), max_a = deg2rad(225), name="NorthWestWest" },
	FOVOctantType.NNW: {x = -1, y = -1, flip = true, shift=false, min_a = deg2rad(225), max_a = deg2rad(270), name="NorthNorthWest" },
	FOVOctantType.SSW: {x = -1, y = 1, flip = true, shift=true, min_a = deg2rad(90), max_a = deg2rad(135), name="SouthSouthWest" },
	FOVOctantType.SWW: {x = -1, y = 1, flip = false, shift=false, min_a = deg2rad(135), max_a = deg2rad(180), name="SouthWestWest" },
	FOVOctantType.SEE: {x = 1, y = 1, flip = false, shift=true, min_a = deg2rad(0), max_a = deg2rad(45), name="SouthEastEast" },
	FOVOctantType.SSE: {x = 1, y = 1, flip = true, shift=false, min_a = deg2rad(45), max_a = deg2rad(90), name="SouthSouthEast" },
	FOVOctantType.NNE: {x = 1, y = -1, flip = true, shift=true, min_a = deg2rad(270), max_a = deg2rad(315), name="NorthNorthEast" },
	FOVOctantType.NEE: {x = 1, y = -1, flip = false, shift=false, min_a = deg2rad(315), max_a = deg2rad(360), name="NorthEastEast" },
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
static func cast_area(origin:Vector2, radius:int, \
					cell_mask: int = TIL.CellInteractions.BlocksFOV,
					xmask := TIL.CellInteractions.None, 
					VISIBLE_ON_EQUAL := VOE, \
					NOT_VISIBLE_BLOCKS_VISION := NVBV, \
					RESTRICTIVENESS := R, \
					tiles:Array = WRLD.cell_interaction_mask_map) ->Array:
	var cells = []
	for oct in FOVOctants.values():
		_visible_cells_in_octant_from(origin, oct, radius, tiles, cells, \
									cell_mask, xmask, \
									NOT_VISIBLE_BLOCKS_VISION, \
									RESTRICTIVENESS, VISIBLE_ON_EQUAL )
	cells.append(origin)
	return cells

static func cast_oct(origin:Vector2, target:Vector2, radius:int, \
							cell_mask: int = TIL.CellInteractions.BlocksFOV,
							xmask := TIL.CellInteractions.None, \
							NOT_VISIBLE_BLOCKS_VISION := NVBV, \
							RESTRICTIVENESS := R, \
							tiles:Array = WRLD.cell_interaction_mask_map) -> Array:
	var oct = _get_octant(origin, target)
	return _visible_cells_in_octant_from(origin, oct, radius, tiles, [], cell_mask,
					 xmask, NOT_VISIBLE_BLOCKS_VISION, RESTRICTIVENESS)

#Cast a shadow-cast friendly lerpline that should reach any visible cell
static func cast_lerpish_line(origin:Vector2, target:Vector2, max_length:int, \
							cell_mask: int = TIL.CellInteractions.BlocksFOV,
							xmask := TIL.CellInteractions.None, \
							NOT_VISIBLE_BLOCKS_VISION := NVBV, \
							RESTRICTIVENESS := R, \
							tiles:Array = WRLD.cell_interaction_mask_map) -> Array:
	var oct = _get_octant(origin, target)
	return _lerpish_line(origin, target, oct, max_length, tiles, [], cell_mask,
					 xmask, NOT_VISIBLE_BLOCKS_VISION, RESTRICTIVENESS)

static func cast_psuedo_cone(from:Vector2, towards:Vector2, width: float, \
							radius: int, \
							cell_mask: int = TIL.CellInteractions.BlocksFOV,
							xmask := TIL.CellInteractions.None, \
							VISIBLE_ON_EQUAL := VOE, \
							NOT_VISIBLE_BLOCKS_VISION := NVBV, \
							RESTRICTIVENESS := R, \
							tiles:Array = WRLD.cell_interaction_mask_map) -> Array:
	var look_xform = Transform2D(towards.angle_to_point(from), from)
	var lines = [
		[look_xform.xform(Vector2(1.5, -1)),look_xform.xform(Vector2(radius, -(width/2)-1))],
		[look_xform.xform(Vector2(radius, (width/2)+1)), look_xform.xform(Vector2(1.5, 1))]
	]
	var cells = []
	for oct in FOVOctants.values():
		_cast_convex_polygon(from, lines, oct, radius, tiles, cells, \
							cell_mask, xmask, \
							VISIBLE_ON_EQUAL, \
							NOT_VISIBLE_BLOCKS_VISION, RESTRICTIVENESS)
	return cells
#casts a cone more reliably than cast cone, doesn't work for values under 35. 
#actual width is quite a bit more than advertised
static func cast_psuedo_cone_radius(from:Vector2, towards:Vector2, width: float, \
							radius: int, \
							cell_mask: int = TIL.CellInteractions.BlocksFOV,
							xmask := TIL.CellInteractions.None, \
							VISIBLE_ON_EQUAL := VOE, \
							NOT_VISIBLE_BLOCKS_VISION := NVBV, \
							RESTRICTIVENESS := R, \
							tiles:Array = WRLD.cell_interaction_mask_map) -> Array:
	var side_length = radius / cos(width/2)
	var look_xform = Transform2D(towards.angle_to_point(from), from)
	var x_pushback = 0
	var y_pushout = 1
	if width <= deg2rad(35):
		x_pushback = -5
		y_pushout = 3
	elif width <= deg2rad(45):
		x_pushback = -3
	elif width <= deg2rad(50):
		x_pushback = -3
	elif width <= deg2rad(75):
		x_pushback = -2
	elif width <= deg2rad(95):
		x_pushback = -1
	var start_offset = Vector2(x_pushback, y_pushout)
	var end_offset = Vector2(x_pushback, -y_pushout)
	var lines = [
		[look_xform.xform(start_offset),look_xform.xform(Vector2(side_length, 0).rotated(-(width/2)))],
		[look_xform.xform(Vector2(side_length, 0).rotated(width/2)), look_xform.xform(end_offset)]
	]
	var cells = []
	for oct in FOVOctants.values():
		_cast_convex_polygon(from, lines, oct, radius, tiles, cells, \
							cell_mask, xmask, \
							VISIBLE_ON_EQUAL, \
							NOT_VISIBLE_BLOCKS_VISION, RESTRICTIVENESS)
	return cells

static func cast_wide_beam(from:Vector2, towards:Vector2, width: float, \
						radius: int, \
						cell_mask: int = TIL.CellInteractions.BlocksFOV,
						xmask := TIL.CellInteractions.None, 
						VISIBLE_ON_EQUAL := VOE, \
						NOT_VISIBLE_BLOCKS_VISION := NVBV, \
						RESTRICTIVENESS := R, \
						tiles:Array = WRLD.cell_interaction_mask_map) -> Array:
#	var look_xform = Transform2D(towards.angle_to_point(from), from)
	var cells = []
#	var lines = [
#		[look_xform.xform(Vector2(0.5, width)), look_xform.xform(Vector2(0.5, -width))],
#		[look_xform.xform(Vector2(0.5, -width)), look_xform.xform(Vector2(radius, -width))],
#		[look_xform.xform(Vector2(radius, -width)), look_xform.xform(Vector2(radius, width))],
#		[look_xform.xform(Vector2(radius, width)), look_xform.xform(Vector2(0.5,width))],
#	]
#	for oct in FOVOctants.values():
#		_cast_convex_polygon(from, lines, oct, radius+1, tiles, cells, \
#							cell_mask, xmask, VISIBLE_ON_EQUAL, \
#							NOT_VISIBLE_BLOCKS_VISION, RESTRICTIVENESS)
	if (from - towards).length() < 1:
		return []
	var origin_cells = cast_wall(from, towards, width, 1, cell_mask, xmask,
							VISIBLE_ON_EQUAL, NOT_VISIBLE_BLOCKS_VISION,
							RESTRICTIVENESS, tiles)
	var first_origin = origin_cells[0]
	var dvec = (first_origin - from).normalized()
	var x_target = ((dvec * (radius + 20))+ first_origin).snapped(Vector2.ONE)
	for origin_cell in origin_cells:
		var oct = _get_octant(from, x_target)
		_forward_lerpish_line(from, towards, oct, radius, tiles, \
							cells, cell_mask, xmask, NOT_VISIBLE_BLOCKS_VISION, \
							RESTRICTIVENESS, VISIBLE_ON_EQUAL)
	origin_cells.append_array(cells)
	return origin_cells

static func cast_wall(from:Vector2, towards:Vector2, width:int, max_distance:int, \
						cell_mask: int = TIL.CellInteractions.BlocksFOV,
						xmask := TIL.CellInteractions.None, \
						VISIBLE_ON_EQUAL := VOE, \
						NOT_VISIBLE_BLOCKS_VISION := NVBV, \
						RESTRICTIVENESS := R, \
						tiles:Array = WRLD.cell_interaction_mask_map) -> Array:
	var dvec := (towards - from).normalized()
	var oct = _get_octant(from, towards)
	var max_point = _forward_lerpish_line(from, towards, oct, max_distance, tiles, \
										[], cell_mask, xmask, \
										NOT_VISIBLE_BLOCKS_VISION, \
										RESTRICTIVENESS, 
										VISIBLE_ON_EQUAL)[-1]
	var cells = [max_point]
	if width == 0:
		return cells
	var normal = Vector2(dvec.y, -dvec.x)
	var tangent = Vector2(-dvec.y, dvec.x)
	cells.append_array(lerp_line_toward(max_point, (normal*width)+max_point, \
					width, cell_mask, xmask, \
					NOT_VISIBLE_BLOCKS_VISION, RESTRICTIVENESS, tiles))
	cells.append_array(lerp_line_toward(max_point, (tangent*width)+max_point, \
					width, cell_mask, xmask, \
					NOT_VISIBLE_BLOCKS_VISION, RESTRICTIVENESS, tiles))
	return cells

static func cast_nearest_point(from:Vector2, towards:Vector2, max_distance:int, \
						cell_mask: int = TIL.CellInteractions.BlocksFOV,
						xmask := TIL.CellInteractions.None, \
						VISIBLE_ON_EQUAL := VOE, \
						NOT_VISIBLE_BLOCKS_VISION := NVBV, \
						RESTRICTIVENESS := R, \
						tiles:Array = WRLD.cell_interaction_mask_map) -> Vector2:
	var oct = _get_octant(from, towards)
	return _forward_lerpish_line(from, towards, oct, max_distance, tiles, \
										[], cell_mask, xmask, \
										NOT_VISIBLE_BLOCKS_VISION, \
										RESTRICTIVENESS, 
										VISIBLE_ON_EQUAL)[-1]

#tests if point to seen from from within site_range using tiles as a block map
static func can_see_point(from:Vector2, to:Vector2, radius: int, \
						cell_mask: int = TIL.CellInteractions.BlocksFOV,
						xmask := TIL.CellInteractions.None, \
						VISIBLE_ON_EQUAL := VOE, \
						NOT_VISIBLE_BLOCKS_VISION := NVBV, \
						RESTRICTIVENESS := R, \
						tiles:Array = WRLD.cell_interaction_mask_map) -> bool:
	var oct = _get_octant(from, to)
	for tile in _visible_cells_in_octant_from(from, oct, radius, tiles, [], \
									cell_mask, xmask, VISIBLE_ON_EQUAL, \
									NOT_VISIBLE_BLOCKS_VISION, RESTRICTIVENESS):
		if tile == to:
			return true
	return false

#cast a lerp line up to a certain distance
static func lerp_line_toward(origin:Vector2, toward:Vector2, length:int, \
							cell_mask: int = TIL.CellInteractions.BlocksFOV, \
							xmask := TIL.CellInteractions.None, \
							NOT_VISIBLE_BLOCKS_VISION := NVBV, \
							RESTRICTIVENESS := R, \
							tiles:Array = WRLD.cell_interaction_mask_map) -> Array:
	var target = (((toward - origin).normalized() * length) + origin).snapped(Vector2(1,1))
	return lerp_line(origin, target, cell_mask, xmask, 
						NOT_VISIBLE_BLOCKS_VISION, RESTRICTIVENESS, tiles)

static func lerp_line(origin:Vector2, target:Vector2, \
							cell_mask: int = TIL.CellInteractions.BlocksFOV,
							xmask := TIL.CellInteractions.None, \
							NOT_VISIBLE_BLOCKS_VISION := NVBV, \
							RESTRICTIVENESS := R, \
							tiles:Array = WRLD.cell_interaction_mask_map) -> Array:
	var cells = []
	var delta = origin - target
	var N = max(abs(delta.x), abs(delta.y))
	#var N = target.distance_to(origin)
	for i in range(N+1):
		if i == 0:
			continue
		var t = i/N
		var new_cell = Vector2( round(lerp(origin.x, target.x, t)), round(lerp(origin.y, target.y, t)))
		if !cells.has(new_cell):
			cells.append(new_cell)
	return cells

static func _cast_convex_polygon(origin:Vector2, area: Array, oct:Dictionary, \
								radius:int, tiles:Array, cell_list:Array, \
								cell_mask: int = TIL.CellInteractions.BlocksFOV,
								xmask := TIL.CellInteractions.None, \
								NOT_VISIBLE_BLOCKS_VISION := NVBV, \
								RESTRICTIVENESS := R, VISIBLE_ON_EQUAL := VOE) -> Array:
	var planes = []
	for line in area:
		var dvec = (line[1] - line[0]).normalized()
		var normal = Vector2(dvec.y, -dvec.x)
		planes.append([normal, normal.dot(line[1])])
	var iteration = 1
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
		var bad_cell_count = 0
		# Start at the center (vertical or horizontal line) and step outwards
		for step in range(num_cells_in_row):
			var cell = _cell_at(origin, oct, step, iteration)
			if cell.x < 0 or cell.y < 0 or cell.x >= max_x or cell.y >= max_y:
				bad_cell_count += 1
				continue
			if _cell_in_radius(origin, cell, radius):
				var cell_angles = CellAngles.new((float(step) * angle_allocation),
											(float(step + .5) * angle_allocation),
											(float(step + 1) * angle_allocation))
				if _cell_is_visible(cell_angles, obstructions, RESTRICTIVENESS, VISIBLE_ON_EQUAL):
					var in_polygon = true
					for plane in planes:
						if plane[0].dot(cell) - plane[1] > 0:
							in_polygon = false
							break
					if in_polygon and  ~(tiles[cell.x][cell.y] & xmask) and !cell_list.has(cell):
						cell_list.append(cell)
					if tiles[cell.x][cell.y] & cell_mask:
						obstructions = _add_obstruction(obstructions, cell_angles)
					elif in_polygon and !cell_list.has(cell):
						cell_list.append(cell)
				elif NOT_VISIBLE_BLOCKS_VISION:
					obstructions = _add_obstruction(obstructions, cell_angles)
		if bad_cell_count == num_cells_in_row:
			break
		iteration += 1

	return cell_list

#Cast a line to a point in oct maxing at radius, will prefer a lerp line but 
#can deflect a little to allow targeting any visible cell.  Lerp lines and
#bresenham look much better
static func _lerpish_line(origin:Vector2, target:Vector2, oct:Dictionary, radius:int, \
						tiles:Array, cell_list:Array, \
						cell_mask = TIL.CellInteractions.BlocksFOV, \
						xmask := TIL.CellInteractions.None, 
						NOT_VISIBLE_BLOCKS_VISION := NVBV, RESTRICTIVENESS := R) -> Array:
	var target_iteration := _iteration_at(origin, target, oct)
	var target_step := _step_at(origin, target, oct)
	var target_allocation := 1.0 / float(target_iteration + 1)
	var target_angles := CellAngles.new(float(target_step) * target_allocation, float(target_step+0.5) * target_allocation, float(target_step + 1) * target_allocation)
	var target_cells := []
	var prefer_x := false
	var last_cell = target
	var max_x = tiles.size()
	var max_y = tiles[0].size()
	target.x = clamp(target.x, 0, max_x - 1)
	target.y = clamp(target.y, 0, max_y)
	var delta = target - origin
	var N = max(abs(delta.x), abs(delta.y))
	for iteration in range(target_iteration, 0, -1):
		var num_cells_in_row = iteration + 1
		var angle_allocation = 1.0 / float(num_cells_in_row)
		var closest_dist = INF
		var best_cell = null
		var best_step = 0
		var t = float(iteration-1)/float(N)
		var lerp_target_cell = Vector2(round(lerp(target.x, origin.x, t)), round(lerp(target.y, origin.y, t)))
		# Start at the center (vertical or horizontal line) and step outwards
		target_step = _step_at(origin, lerp_target_cell, oct)
		for step in range(floor(target_angles.near * num_cells_in_row), ceil(target_angles.far * num_cells_in_row)):
			var cell = _cell_at(origin, oct, step, iteration)
			if cell.x >= max_x or cell.x < 0 or cell.y >= max_y or cell.y < 0:
				continue
			if !(tiles[cell.x][cell.y] & cell_mask):
				if cell == lerp_target_cell:
					best_cell = cell
					best_step = step
					break
				var cell_dist = abs(target_angles.center - (float(step) * angle_allocation))
				if cell_dist < closest_dist and not best_cell and not best_step:
					closest_dist = cell_dist
					best_cell = cell
					best_step = step
		if best_cell:
			target_cells.append(best_cell)
			last_cell = best_cell
		else:
			target_cells = []
			
	return target_cells

#Cast a line to a point in oct maxing at radius, will prefer a lerp line but 
#can deflect a little to allow targeting any visible cell.  Lerp lines and
#bresenham look much better.  This one runs forward, instead of working backward
static func  _forward_lerpish_line(origin:Vector2, target:Vector2, oct:Dictionary, \
										radius:int, tiles:Array, cell_list:Array, \
										cell_mask = TIL.CellInteractions.BlocksFOV, \
										xmask := TIL.CellInteractions.None, \
										NOT_VISIBLE_BLOCKS_VISION := NVBV, \
										RESTRICTIVENESS := R, 
										VISIBLE_ON_EQUAL := VOE) -> Array:
	var iteration = 1
	var visible_cells = []
	var obstructions = []
	var max_x = tiles.size()
	var max_y = tiles[0].size()
	var delta = target - origin
	var N = max(abs(delta.x), abs(delta.y))
	while iteration <= radius and not (obstructions.size() == 1 and
										obstructions[0].near == 0.0 and obstructions[0].far == 1.0):
		var num_cells_in_row = iteration + 1
		var angle_allocation = 1.0 / float(num_cells_in_row)
		var bad_cell_count = 0
		var best_cell = null
		var t = float(iteration)/float(N)
		var lerp_target_cell = origin.linear_interpolate(target, t).snapped(Vector2.ONE)
		# Start at the center (vertical or horizontal line) and step outwards
		for step in range(num_cells_in_row):
			var cell = _cell_at(origin, oct, step, iteration)
			if cell.x < 0 or cell.y < 0 or cell.x >= max_x or cell.y >= max_y:
				bad_cell_count += 1
				continue
			if _cell_in_radius(origin, cell, radius):
				var cell_angles = CellAngles.new((float(step) * angle_allocation),
											(float(step + .5) * angle_allocation),
											(float(step + 1) * angle_allocation))
				if _cell_is_visible(cell_angles, obstructions, RESTRICTIVENESS, VISIBLE_ON_EQUAL):
					if cell_list.has(cell):
						pass
					else:
						if cell == lerp_target_cell and ~(tiles[cell.x][cell.y] & xmask):
							best_cell = cell
					if tiles[cell.x][cell.y] & cell_mask:
						obstructions = _add_obstruction(obstructions, cell_angles)
				elif NOT_VISIBLE_BLOCKS_VISION:
					obstructions = _add_obstruction(obstructions, cell_angles)
		if bad_cell_count == num_cells_in_row:
			break
		if best_cell:
			cell_list.append(best_cell)
		else:
			break
		iteration += 1

	return cell_list
	
#Finds all cells from origin in oct out to radius shadowcasting against tiles
static func  _visible_cells_in_octant_from(origin:Vector2, oct:Dictionary, \
										radius:int, tiles:Array, cell_list:Array, \
										cell_mask = TIL.CellInteractions.BlocksFOV, \
										xmask := TIL.CellInteractions.None, \
										NOT_VISIBLE_BLOCKS_VISION := NVBV, \
										RESTRICTIVENESS := R, 
										VISIBLE_ON_EQUAL := VOE) -> Array:
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
		var bad_cell_count = 0
		# Start at the center (vertical or horizontal line) and step outwards
		for step in range(num_cells_in_row):
			var cell = _cell_at(origin, oct, step, iteration)
			if cell.x < 0 or cell.y < 0 or cell.x >= max_x or cell.y >= max_y:
				bad_cell_count += 1
				continue
			if _cell_in_radius(origin, cell, radius):
				var cell_angles = CellAngles.new((float(step) * angle_allocation),
											(float(step + .5) * angle_allocation),
											(float(step + 1) * angle_allocation))
				if _cell_is_visible(cell_angles, obstructions, RESTRICTIVENESS, VISIBLE_ON_EQUAL):
					if cell_list.has(cell) or tiles[cell.x][cell.y] & xmask:
						pass
					else:
						cell_list.append(cell)
					if tiles[cell.x][cell.y] & cell_mask:
						obstructions = _add_obstruction(obstructions, cell_angles)
				elif NOT_VISIBLE_BLOCKS_VISION:
					obstructions = _add_obstruction(obstructions, cell_angles)
		if bad_cell_count == num_cells_in_row:
			break
		iteration += 1

	return cell_list

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
	if origin.distance_to(cell) > radius:
		return cell == (((cell - origin).normalized()*radius) + origin).snapped(Vector2.ONE)
	return true
	var fudged_radius = (float(radius) + RADIUS_FUDGE)
	return origin.distance_squared_to(cell) <= fudged_radius * fudged_radius

#check if a cell is obstructed by any obstruction
static func _cell_is_visible(cell_angles:CellAngles, obstructions:Array, \
							RESTRICTIVENESS := R, VISIBLE_ON_EQUAL := VOE) -> bool:
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

#Find which oct from from to is in.  I used to use shift logic from 
#https://github.com/luctius/heresyrl/blob/master/src/fov/rpsc_fov.c because
#we don't have sets, and I hate iterating a list over and over again to 
#remove elements already found.  Because of this we have a bunch of weird
#checks to find the right octant.  Shift logic has been replaced with array.has
#with no noticeable impact in FOV calculations.  This needs refactor
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
	var last_candidate_oct = {}
	var best_oct
	var flip = delta_abs.x <= delta_abs.y
	if delta_v.y == 0 and delta_v.x > 0:
		return FOVOctants[FOVOctantType.NEE]
	elif delta_v.x == 0 and delta_v.y < 0:
		return FOVOctants[FOVOctantType.NNW]
	elif delta_v.x == delta_v.y:
		if delta_v.x > 0:
			return FOVOctants[FOVOctantType.SEE]
		else:
			return FOVOctants[FOVOctantType.NWW]
	#Probably could have handled this differently
	for oct in FOVOctants.values():
		if oct.x == mod_x and oct.y == mod_y and oct.flip == flip:
			var step = _step_at(from, to, oct)
			if !oct.shift and step != 0:
					last_candidate_oct = oct
			elif oct.shift and step != _iteration_at(from, to, oct):
				last_candidate_oct = oct
			else:
				best_oct = oct
	if best_oct:
		return best_oct
	else:
		return last_candidate_oct

