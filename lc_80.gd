extends VehicleBody3D

var horse_power =700
var accel_speed = 100

var steer_angle = deg_to_rad(20)
var steer_speed = 3

var brake_power = 40
var brake_speed = 40


func _physics_process(delta):
	var throt_input = - Input.get_action_strength("W") + Input.get_action_strength("S")	
	engine_force = lerp(engine_force, throt_input * horse_power, accel_speed * delta)
	print(engine_force)
	
	var steer_input = Input.get_action_strength("A") - Input.get_action_strength("D")
	steering = lerp(steering, steer_input * steer_angle, steer_speed * delta)
	
	var brake_input = Input.get_action_strength("SPACE")
	brake = lerp(brake, brake_power * brake_input, brake_speed * delta)
	
	
