extends GameCar

const LOW_SPEED = 10
const HIGH_SPEED_FORWARD_DELTA = 0.7
const LOW_SPEED_FORWARD_DELTA = 0.9

var horse_power = 150
var accel_speed = 30

var steer_angle = deg_to_rad(30)
var steer_speed = 4

var brake_power = 60
var brake_speed = 60

var current_speed_mps = 0

var low_speed_mode := false
var car_controller:CarController

var health_controller:HealthController

# Called when the node enters the scene tree for the first time.
func _ready():
	car_controller = CarController.new(self, self.owner)
	health_controller = $HealthController

func _process(delta):
	if state == State.ALIVE and health_controller.is_destroyed():
		state = State.DESTROYED
		

func physics_process_alive(delta):
	super(delta)
	car_controller.set_speed(current_speed_mps)
	car_controller.calculate_direction()
		
	current_speed_mps = linear_velocity.length()
	var chosen_dir = car_controller.chosen_dir
	
	var to_look = to_global(chosen_dir * 5)
	#to_look.y = ARROW_HEIGHT
	#var from = Vector3(global_position.x, global_position.y + ARROW_HEIGHT, global_position.z)	
	#if debug_draw:
	#	DebugDraw3D.draw_arrow_line(from, to_look, Color.CRIMSON, 0.3)
	
	var throt_input = chosen_dir.z	
	if throt_input > 0:
		throt_input = 0.5
	if current_speed_mps > 0 and  current_speed_mps < LOW_SPEED:
		throt_input = throt_input * LOW_SPEED / current_speed_mps
	engine_force = lerp(engine_force, throt_input * horse_power, accel_speed * delta)	
	
	var steer_input = clamp(Vector3.FORWARD.signed_angle_to(chosen_dir, Vector3.UP), -steer_angle, steer_angle)
	
	if chosen_dir.z > 0:
		steer_input = clamp(-Vector3.BACK.signed_angle_to(chosen_dir, Vector3.UP), -steer_angle, steer_angle)
	steering = lerp(steering, steer_input, steer_speed * delta)

func physics_process_destroyed(delta):
	engine_force = lerp(engine_force,0.0,delta * accel_speed)

