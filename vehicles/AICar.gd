extends VehicleBody3D
class_name RedCar


@export var steer_force = 0.1
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

const ARROW_HEIGHT = 2
const LOW_SPEED = 10
const HIGH_SPEED_FORWARD_DELTA = 0.7
const LOW_SPEED_FORWARD_DELTA = 0.9

var horse_power = 250
var accel_speed = 100


var steer_angle = deg_to_rad(30)
var steer_speed = 4

var brake_power = 60
var brake_speed = 60

var current_speed_mps = 0

var low_speed_mode := false
var car_controller:CarController

# Called when the node enters the scene tree for the first time.
func _ready():
	car_controller = CarController.new(self, self.owner)
	car_controller.look_ahead = look_ahead
	car_controller.num_rays = num_rays
	car_controller.low_speed_rays = low_speed_rays
	car_controller.low_speed_angle = low_speed_angle
	car_controller.controller_height = 0.5
	car_controller.debug_draw = debug_draw

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	car_controller.set_mode_by_speed(current_speed_mps)
	car_controller.calculate_direction()
		
	current_speed_mps = linear_velocity.length()
	chosen_dir = car_controller.chosen_dir
	
	var to_look = to_global(chosen_dir * 5)
	to_look.y = ARROW_HEIGHT
	var from = Vector3(global_position.x, global_position.y + ARROW_HEIGHT, global_position.z)	
	if debug_draw:
		DebugDraw3D.draw_arrow_line(from, to_look, Color.CRIMSON, 0.3)
	
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
	
	
	var brake_input = 0.0 #TODO
	brake = lerp(brake, brake_power * brake_input, brake_speed * delta)
	

