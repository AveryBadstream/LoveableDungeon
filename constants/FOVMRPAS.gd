extends Node

const PERIOD_MASK = 0x0f
const ANGLE_RANGE = 65535

enum FOVAreaType {AreaSquare, AreaOctagon, AreaCircle, AreaStrict}
enum FOVOctantType {NNW=0, NWW, SWW, SSW, SSE, SEE, NEE, NNE}

const FOV_AREA = FOVAreaType.AreaCircle

const FOVOctants = {
	FOVOctantType.NNW: {x = -1, y = -1, flip = false },
	FOVOctantType.NWW: {x = -1, y = -1, flip = true },
	FOVOctantType.SWW: {x = -1, y = 1, flip = true },
	FOVOctantType.SSW: {x = -1, y = 1, flip = false },
	FOVOctantType.SSE: {x = 1, y = 1, flip = false },
	FOVOctantType.SEE: {x = 1, y = 1, flip = true },
	FOVOctantType.NEE: {x = 1, y = -1, flip = true },
	FOVOctantType.NNE: {x = 1, y = -1, flip = false },
}

class angle_set extends Reference:
	var near
	var center
	var far
	
	func _init(near_angle=0, center_angle=0, far_angle=0):
		near = near_angle
		center = center_angle
		far = far_angle

func offset_to_angle_set(row: int, cell:int) -> angle_set:
	var a_range = int(ANGLE_RANGE / (row+1))
	var a_set = angle_set.new()
	a_set.near = a_range * cell
	a_set.far = a_set.near + a_range
	a_set.center = a_set.near + (a_range / 2)
	
	return a_set

func angle_set_to_cell(a_set:angle_set, new_row: int):
	var new_range = ANGLE_RANGE / (new_row + 1)
	
	return a_set.center / new_range

func angle_is_blocked(test_set: angle_set, blocked_set: angle_set, transparent: bool) -> bool:
	if test_set.far < blocked_set.near or test_set.near > blocked_set.far:
		return false
	if (transparent and (test_set.center > blocked_set.near) and test_set.center < blocked_set.far) \
		or (test_set.near >= blocked_set.near and test_set.far <= blocked_set.far):
		return true
	return false

func in_radius(row: int, cell: int, radius: int) -> bool:
	match FOV_AREA:
		FOVAreaType.AreaOctagon:
			if row + (cell/2) <= radius:
				return true
		FOVAreaType.AreaCircle:
			if (row*row) + (cell*cell) <= (radius*radius) + radius:
				return true
		FOVAreaType.AreaStrict:
			if (row*row) + (cell*cell) <= (radius*radius):
				return true
		FOVAreaType.AreaSquare:
			if row <= radius:
				return true
	return false

func extend_block(blocked_set: angle_set, current_set: angle_set) -> void:
	if current_set.near < blocked_set.far:
		blocked_set.near = current_set.near
	if current_set.far > blocked_set.far:
		blocked_set.far = current_set.far
	
#func scrub_blocked_list(angle_list: Array, list_sz: int) -> int:
#	if list_sz <= 1:
#		return list_sz
#	var max_not_scrubbed:= -1
#	var removal_list = []
#	for a_set in angle_list:
#		for c_set in angle_list:
#			if a_set == c_set:
#				continue
#			if (a_set.near >= c_set.near and a_set.near <= c_set.far) or (a_set.far <= c_set.far and a_set.far >= c_set.near):
#				extend_block(c_set, a_set)
#				removal_list.append(a_set)

func visible_cells_in_octant_from(start_x: int, start_y: int, tiles: Array, radius: int, oct_i: int):
	var shift := oct_i % 2 == 0
	var obstacles_total := 0
	var obstacles_max := radius * ( (radius+1) / 2);
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
