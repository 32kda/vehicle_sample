extends VehicleBody3D

const LOW_SPEED = 10

var horse_power = 200
var accel_speed = 100

var steer_angle = deg_to_rad(30)
var steer_speed = 2.5

var brake_power = 60
var brake_speed = 60

var current_speed_mps = 0

var secondary_weapon = preload("res://weapons/x_missle.tscn")

const TARGET_YAW_SPEED = 10;
const TARGET_PITCH_SPEED = 200;

@onready var last_pos = position


func _physics_process(delta):
	current_speed_mps = linear_velocity.length()
	
	var throt_input = - Input.get_action_strength("W") + Input.get_action_strength("S")	
	if current_speed_mps > 0 and  current_speed_mps < LOW_SPEED:
		throt_input = throt_input * LOW_SPEED / current_speed_mps
	engine_force = lerp(engine_force, throt_input * horse_power, accel_speed * delta)	
	
	var steer_input = Input.get_action_strength("A") - Input.get_action_strength("D")
	steering = lerp(steering, steer_input * steer_angle, steer_speed * delta)
	
	var brake_input = Input.get_action_strength("SPACE")
	brake = lerp(brake, brake_power * brake_input, brake_speed * delta)
	
	last_pos = position
			
	
	
	
func _process(delta):	
	var kmh = current_speed_mps * 3.6
	$SpringArm3D/EngineSound.pitch_scale = 1 + kmh / 20
	Events.emit_signal("player_speed", kmh)
	var target
	if $SpringArm3D/RayCast3D.is_colliding():
		target = $SpringArm3D/RayCast3D.get_collision_point()	
	else: 
		target = -$SpringArm3D/RayCast3D.global_transform.basis.z * 3000
	$machinegun.set_target(target)
	Events.emit_signal("missle_target", target)
	var local_target = $turret.to_local(target)
	local_target.y = 0
	var angle = Vector3.FORWARD.signed_angle_to(local_target, Vector3.UP)
	$turret.rotation.y += angle * clamp(delta * TARGET_YAW_SPEED, 0, 1)
	var gun_local = $turret/gun.to_local(target)
	gun_local.x = 0
	var pitch_angle = Vector3.FORWARD.signed_angle_to(gun_local, Vector3.RIGHT)
	$turret/gun.rotation.x += pitch_angle * clamp(delta * TARGET_PITCH_SPEED, 0, 1)

func _input(event):
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_RIGHT and event.is_released():
		var missle = secondary_weapon.instantiate() as RigidBody3D
		var missle_transform = Transform3D(global_transform.basis, $WeaponOrigin.global_position)
		get_tree().get_root().get_node("/root/game/world").add_child(missle)
		var forward_vector = -global_transform.basis.z		
		missle.start(missle_transform, forward_vector, linear_velocity)
		
		
		
