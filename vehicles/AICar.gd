extends VehicleBody3D

const LOW_SPEED = 10

var horse_power = 200
var accel_speed = 100

var steer_angle = deg_to_rad(30)
var steer_speed = 2.5

var brake_power = 60
var brake_speed = 60

var current_speed_mps = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	current_speed_mps = linear_velocity.length()
	
	var throt_input = -1.0 #TDOD	
	if current_speed_mps > 0 and  current_speed_mps < LOW_SPEED:
		throt_input = throt_input * LOW_SPEED / current_speed_mps
	engine_force = lerp(engine_force, throt_input * horse_power, accel_speed * delta)	
	
	var steer_input = 0.0 #TODO
	steering = lerp(steering, steer_input * steer_angle, steer_speed * delta)
	
	var brake_input = 0.0 #TODO
	brake = lerp(brake, brake_power * brake_input, brake_speed * delta)
