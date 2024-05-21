class_name CarController
extends Node

@export var look_ahead = 30
@export var num_rays = 16
@export var low_speed_rays = 4
@export var low_speed_angle = 60
@export var controller_height = 0.5
@export var debug_draw:=true

# context array
var ray_directions = []
var full_speed_ray_directions = []
var low_speed_ray_directions = []
var interest = []
var danger = []

var chosen_dir = Vector3.FORWARD
var velocity = Vector3.FORWARD
var acceleration = Vector3.FORWARD
var car:VehicleBody3D



# Called when the node enters the scene tree for the first time.
func _ready():
	if car == null && get_parent() is VehicleBody3D:
		car = get_parent()
	interest.resize(num_rays)
	danger.resize(num_rays)
	full_speed_ray_directions.resize(num_rays)
	for i in num_rays:
		var angle = i * 2 * PI / num_rays	
		full_speed_ray_directions[i] = Vector3.RIGHT.rotated(Vector3.UP, angle)
	var start_angle_1 := Vector3.FORWARD.rotated(Vector3.UP,deg_to_rad(-(low_speed_angle / 2)))
	var start_angle_2 := Vector3.BACK.rotated(Vector3.UP,deg_to_rad(-(low_speed_angle / 2)))
	var delta = deg_to_rad(low_speed_angle / low_speed_rays)
	low_speed_ray_directions.resize(low_speed_rays * 2)
	for i in low_speed_rays:
		low_speed_ray_directions[i] = start_angle_1.rotated(Vector3.UP, delta * i)
	for i in low_speed_rays:
		low_speed_ray_directions[low_speed_rays + i] = start_angle_2.rotated(Vector3.UP, delta * i)
	pass # Replace with function body.

func set_interest():
	# Set interest in each slot based on world direction	
	if owner:
		var curve:Curve3D = owner.get_target_curve(self)
		var length = curve.get_baked_length()
		var offset =  curve.get_closest_offset(car.global_position)
		var target_point = curve.sample_baked(fmod((offset + look_ahead),length))
		if debug_draw:
			DebugDraw3D.draw_sphere(target_point, 0.5, Color.RED)
		var path_direction = car.to_local(target_point)		
		path_direction = path_direction.normalized()
		for i in num_rays:
			var d = ray_directions[i].dot(path_direction)
			interest[i] = max(0, d)
	# If no world path, use default interest
	else:
		set_default_interest()

func set_default_interest():
	var multiplier = 1.0 - HIGH_SPEED_FORWARD_DELTA
	var to_add = HIGH_SPEED_FORWARD_DELTA
	if low_speed_mode:
		multiplier = 1.0 - LOW_SPEED_FORWARD_DELTA
		to_add = LOW_SPEED_FORWARD_DELTA

	for i in num_rays:
		var d = ray_directions[i].dot(Vector3.FORWARD) * multiplier		
		interest[i] = clamp(d + to_add, 0, 1)

func set_danger():
	# Cast rays to find danger directions
	var space_state = get_world_3d().direct_space_state
	for i in num_rays:
		var from = Vector3(global_position.x, global_position.y + controller_height, global_position.z)		
		var direction = Vector3(ray_directions[i].x * look_ahead, ray_directions[i].y + controller_height, ray_directions[i].z * look_ahead)
		
		var global_target := to_global(direction)
		var params := PhysicsRayQueryParameters3D.create(from, global_target)
		var result = space_state.intersect_ray(params)
#			var result = space_state.intersect_ray(position,
#				position + ray_directions[i].rotated(Vector3.UP, rotation) * look_ahead,
#				[self])
		if result.has("collider"):
			var pos = result["position"]
			var dist = (pos - global_position).length() / look_ahead
			if debug_draw:
				DebugDraw3D.draw_line_hit(from,global_target,pos,true,0.5,Color.GREEN,Color.RED)
			danger[i] = 1 - dist
		else: 
			if debug_draw:
				DebugDraw3D.draw_line(from, global_target, Color.GREEN)
			danger[i] = 0.0	
			
func choose_direction():
	# Eliminate interest in slots with danger
	for i in num_rays:
		interest[i] *= (1.0 - danger[i])
	# Choose direction based on remaining interest
	chosen_dir = Vector3.ZERO
	for i in num_rays:
		chosen_dir += ray_directions[i] * interest[i]
	chosen_dir = chosen_dir.normalized()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
