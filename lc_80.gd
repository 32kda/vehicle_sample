extends VehicleBody3D

const LOW_SPEED = 10

var horse_power = 200
var accel_speed = 100

var steer_angle = deg_to_rad(30)
var steer_speed = 2.5

var brake_power = 60
var brake_speed = 60

var current_speed_mps = 0

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

