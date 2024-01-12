extends VehicleBody3D

@export var steer_force = 0.1
@export var look_ahead = 20
@export var num_rays = 8
@export var low_speed_rays = 4
@export var low_speed_angle = 60
@export var controller_height = 0.5

# context array
var ray_directions = []
var low_speed_ray_directions = []
var interest = []
var danger = []

var chosen_dir = Vector3.FORWARD
var velocity = Vector3.FORWARD
var acceleration = Vector3.FORWARD

const LOW_SPEED = 10

var horse_power = 250
var accel_speed = 100

var steer_angle = deg_to_rad(30)
var steer_speed = 40

var brake_power = 60
var brake_speed = 60

var current_speed_mps = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	interest.resize(num_rays)
	danger.resize(num_rays)
	ray_directions.resize(num_rays)
	for i in num_rays:
		var angle = i * 2 * PI / num_rays	
		ray_directions[i] = Vector3.RIGHT.rotated(Vector3.UP, angle)
	var start_angle_1 = Vector3.FORWARD.rotated(Vector3.UP,deg_to_rad(-(low_speed_angle / 2)))
	var start_angle_2 = Vector3.BACK.rotated(Vector3.UP,deg_to_rad(-(low_speed_angle / 2)))
	var delta = low_speed_angle / low_speed_rays
	low_speed_ray_directions.resize(low_speed_rays * 2)
	for i in low_speed_rays:
		low_speed_ray_directions[i] = start_angle_1.rotated(Vector3.UP, delta)
	for i in low_speed_rays:
		low_speed_ray_directions[low_speed_rays + i] = start_angle_2.rotated(Vector3.UP, delta)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	set_interest()
	set_danger()
	choose_direction()
	
	#var desired_velocity = chosen_dir 
	#velocity = velocity.lerp(desired_velocity, steer_force)
#	rotation = velocity.angle()
#	move_and_collide(velocity * delta)
	
	current_speed_mps = linear_velocity.length()
	
	var to_look = Vector3(chosen_dir)
	to_look.y = 0
	$MeshInstance3D.look_at(to_global(to_look))
	
	var throt_input = chosen_dir.z	
	if throt_input > 0:
		throt_input = 0.5
	if current_speed_mps > 0 and  current_speed_mps < LOW_SPEED:
		throt_input = throt_input * LOW_SPEED / current_speed_mps
	engine_force = lerp(engine_force, throt_input * horse_power, accel_speed * delta)	
	
	var steer_input = clamp(Vector3.FORWARD.signed_angle_to(chosen_dir, Vector3.UP), -steer_angle, steer_angle)
	
	if chosen_dir.z > 0:
		steer_input = -steer_input
	steering = lerp(steering, steer_input * steer_angle, steer_speed * delta)
	
	
	var brake_input = 0.0 #TODO
	brake = lerp(brake, brake_power * brake_input, brake_speed * delta)
	
func set_interest():
	# Set interest in each slot based on world direction
	if owner and owner.has_method("get_path_direction"):
		var path_direction = owner.get_path_direction(global_position)
		for i in num_rays:
			var d = ray_directions[i].rotated(rotation).dot(path_direction)
			interest[i] = max(0, d)
	# If no world path, use default interest
	else:
		set_default_interest()

func set_default_interest():
	# Default to moving forward
	for i in num_rays:
		var d = ray_directions[i].dot(Vector3.FORWARD) * 0.3		
		interest[i] = clamp(d + 0.7, 0, 1)

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
			DebugDraw3D.draw_line_hit(from,global_target,pos,true,0.5,Color.GREEN,Color.RED)
			danger[i] = 1 - dist
		else: 
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
	print(chosen_dir.z)
