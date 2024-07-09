extends GameCar

const LOW_SPEED = 10
const HIGH_SPEED_FORWARD_DELTA = 0.7
const LOW_SPEED_FORWARD_DELTA = 0.9

@export var horse_power = 150
@export var accel_speed = 30
@export var target_yaw_speed:int = 1
@export var target_pitch_speed:int = 5

@export var steer_angle = deg_to_rad(30)
@export var steer_speed = 4

@export var brake_power = 60
@export var brake_speed = 60
@export var max_fire_angle = 5

var low_speed_mode := false
var car_controller:CarController

var health_controller:HealthController

@onready var turret = $turret_body
@onready var l_minigun = $turret_body/LMinigun
@onready var r_minigun = $turret_body/RMinigun
@onready var pipe1 = $turret_body/turret/PipeParticles01
@onready var pipe2 = $turret_body/turret/PipeParticles02
@onready var fire_particles = $turret_body/turret/FireParticles
#@onready var joint = $joint
@onready var detection_area := $turret_body/turret/EnemyDetection
@onready var engine_sound = $turret_body/EngineSound

# Called when the node enters the scene tree for the first time.
func _ready():
	car_controller = CarController.new(self, self.owner)
	health_controller = $HealthController
	detection_area.set_enemy_groups(["Players", "Enemies"])
	#$turret_body.lock_rotation = true

func _process(delta):
	var firing = false
	if state == State.ALIVE:
		if health_controller.is_destroyed():
			state = State.DESTROYED
		else:			
			var target = detection_area.get_target()
			if target != null:
				var local_target = turret.to_local(target.global_position)
				local_target.y = 0
				var angle = Vector3.FORWARD.signed_angle_to(local_target, Vector3.UP)
				turret.rotation.y = lerp(turret.rotation.y, turret.rotation.y + angle, delta * target_yaw_speed)
				var gun_local = l_minigun.to_local(target.global_position)
				gun_local.x = 0				
				var pitch_angle = Vector3.FORWARD.signed_angle_to(gun_local, Vector3.RIGHT)
				l_minigun.rotation.x = lerp(l_minigun.rotation.x, l_minigun.rotation.x + pitch_angle, delta * target_pitch_speed)  
				r_minigun.rotation.x = l_minigun.rotation.x
				#machinegun.set_target(target.global_position, 10 * delta)
				var full_angle = l_minigun.angle_to(target.global_position)
				if full_angle <= max_fire_angle:
					firing = true
					l_minigun.fire()
					r_minigun.fire()
				#var distance = global_position.distance_to(target.global_position)
				#var max_angle = atan(MAX_SHOOT_DIST * 1.0 / distance)
				#if full_angle < max_angle:
				#	machinegun.hold_trigger() 
			else:
				turret.rotation.y = lerp(turret.rotation.y, 0.0, delta * target_yaw_speed)
	if not firing:
		l_minigun.stop_fire()
		r_minigun.stop_fire()	
		

func physics_process_alive(delta):
	super(delta)
	car_controller.set_speed(current_speed_mps)
	car_controller.calculate_direction()
		
	current_speed_mps = linear_velocity.length()
	var kmh = current_speed_mps * 3.6
	engine_sound.pitch_scale = 1 + kmh / 20
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

func on_destroyed():
	pipe1.emitting = false
	pipe2.emitting = false
	fire_particles.emitting = true
	#joint.queue_free()
	#$turret_body.mass = 100
	#$turret_body.lock_rotation = false
	
