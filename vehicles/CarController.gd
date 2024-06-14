class_name CarController

enum State {
	FORWARD,
	BACK
}

const HIGH_SPEED_FORWARD_DELTA = 0.7

const prev_points := 4
const prev_points_dist = 3

const go_back_msecs := 2500
const go_forward_msecs := 2500

var look_ahead = 30
var num_rays = 16
var controller_height = 0.5
var debug_draw:=false

# context array
var ray_directions = []
var interest = []
var danger = []
var prev_points_buf = []
var prev_point_idx := 0

var chosen_dir = Vector3.FORWARD
var velocity = Vector3.FORWARD
var acceleration = Vector3.FORWARD
var car:VehicleBody3D

var owner:Node3D

var state := State.FORWARD
var speed_mps := 0
var back_direction:Vector3
var go_back_timestamp := 0
var go_forward_timestamp := 0

var colliders := []

func calculate_direction():
	store_prev_point()
	check_set_state()
	if state == State.BACK:
		chosen_dir = back_direction
		return	
	set_interest()
	set_danger()
	choose_direction()
	
func check_set_state():
	if state == State.FORWARD \
		and speed_mps < 3 \
		and not colliders.is_empty() \
		and Time.get_ticks_msec() - go_forward_timestamp > go_forward_msecs:
		state = State.BACK
		if chosen_dir.x < 0:
			back_direction = Vector3(1,0,1)
		else: 
			back_direction = Vector3(-1,0,1)
		go_back_timestamp = Time.get_ticks_msec()
		go_forward_timestamp = 0
	elif state == State.BACK and Time.get_ticks_msec() - go_back_timestamp > go_back_msecs:
		state = State.FORWARD
		go_forward_timestamp = Time.get_ticks_msec()		
		go_back_timestamp = 0	

func set_speed(speed_mps:int): 
	self.speed_mps = speed_mps

# car should be RigidBody3D (tested with VehicleBody3D, but should work with RigidBody based cars also)
# owner should be some node having get_target_curve(car) method responsible for providing a curve, currecntly car should follow
# E.g. this could be a curve defining a racing track
func _init(car:RigidBody3D, owner:Node3D):
	self.car = car
	self.owner = owner
	car.contact_monitor = true
	car.max_contacts_reported = 3
	car.body_entered.connect(_body_entered)
	car.body_exited.connect(_body_exited)
	interest.resize(num_rays)
	danger.resize(num_rays)
	prev_points_buf.resize(prev_points)
	ray_directions.resize(num_rays)
	for i in num_rays:
		var angle = i * 2 * PI / num_rays	
		ray_directions[i] = Vector3.RIGHT.rotated(Vector3.UP, angle)	

func store_prev_point():
	if not prev_points_buf[prev_point_idx]:
		prev_points_buf[prev_point_idx] = car.global_position
	else:
		var distance := car.global_position.distance_to(prev_points_buf[prev_point_idx])
		if distance >= prev_points_dist:
			prev_point_idx = (prev_point_idx + 1) % prev_points
			prev_points_buf[prev_point_idx] = car.global_position	
		if debug_draw:
			for my_point in prev_points_buf:
				if my_point != null:
					DebugDraw3D.draw_sphere(my_point,0.4,Color.DARK_GREEN)	

func set_interest():
	# Set interest in each slot based on world direction	
	if owner:
		var curve:Curve3D = owner.get_target_curve(car)
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

	for i in num_rays:
		var d = ray_directions[i].dot(Vector3.FORWARD) * multiplier		
		interest[i] = clamp(d + to_add, 0, 1)

func set_danger():
	# Cast rays to find danger directions
	var global_position = car.global_position;
	var space_state = car.get_world_3d().direct_space_state
	for i in num_rays:
		var from = Vector3(global_position.x, global_position.y + controller_height, global_position.z)		
		var direction = Vector3(ray_directions[i].x * look_ahead, ray_directions[i].y + controller_height, ray_directions[i].z * look_ahead)
		
		var global_target := car.to_global(direction)
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
	chosen_dir.z = min(-0.5,chosen_dir.z)
	chosen_dir = chosen_dir.normalized()	
	
func _body_entered(body:Node):
	if body is StaticBody3D or body is CSGPolygon3D:
		colliders.append(body)
		
func _body_exited(body:Node):
	if body is StaticBody3D or body is CSGPolygon3D:
		colliders.erase(body)
		
