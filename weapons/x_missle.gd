extends RigidBody3D

@export var speed = 350
@export var debug_draw := true

#var velocity = Vector3.ZERO
var acceleration = Vector3.ZERO
var new_vec:Vector3 = Vector3.ZERO
var dist_from_launcher := 0

const MANEURABILITY = 300
const MANEUR_MIN_SPEED = 10
const MANEUR_MIN_DIST = 3;
const TARGET_POINT_COEF = 1.1

func start(_transform, _acceleration: Vector3, _linear_velocity: Vector3):
	global_transform = _transform
	linear_velocity = _linear_velocity
	acceleration = _acceleration.normalized();
	Events.missle_target.connect(self.retarget)	
	
func _integrate_forces(state):
	if dist_from_launcher > MANEUR_MIN_DIST:
		for i in state.get_contact_count():
			var cpos = state.get_contact_collider_position(i)
			var target = state.get_contact_collider_object(i)
			destroy()
			Events.explosion.emit(cpos, target)

#Missle tries to stay in the beam between player and currect target spotted with crosshair
func retarget(target:Vector3, from: Vector3)->void:
	var to_target:Vector3 = target - from
	var to_self:Vector3 = global_position - from
	dist_from_launcher = to_self.length()
	var ray:Vector3
	var arrow_color = Color.RED
	if dist_from_launcher > MANEUR_MIN_DIST and to_self.length() * TARGET_POINT_COEF < to_target.length():		
		ray = from + (to_target.normalized() * dist_from_launcher * TARGET_POINT_COEF) - global_position	
		arrow_color = Color.ORANGE
		if ray.length() < 1: #if we are too close to beam - just move towards the target to avoid trying to foolow too short vector
			ray = target - global_position			
			arrow_color = Color.GREEN
	else: 
		ray = target - global_position
		arrow_color = Color.PURPLE	
	if debug_draw:
		DebugDraw3D.draw_sphere(from, 0.3, Color.GREEN)
#		DebugDraw3D.draw_arrow_line(from, ray + global_position, Color.RED)
		#DebugDraw3D.draw_sphere(ray + global_position, 0.5, Color.RED)
	#var angle = to_target.signed_angle_to(to_self, normal)
	#print("Angle: " + str(rad_to_deg(angle)))
	
	new_vec = ray.normalized() 	
	if debug_draw:
		DebugDraw3D.draw_arrow_line(from, from + (to_target.normalized() * dist_from_launcher * TARGET_POINT_COEF), arrow_color, 0.4, true)

func _physics_process(delta):
	apply_central_force(acceleration * speed)
	linear_velocity = linear_velocity.limit_length(speed)
	if dist_from_launcher > MANEUR_MIN_DIST:
		acceleration = lerp(acceleration, new_vec, clamp(MANEURABILITY * delta, 0.0, 1.0))	
		look_at(linear_velocity + global_position, Vector3.UP, true)

func _on_Lifetime_timeout():
	destroy()

func destroy():
	var particles = $SmokeParticles
	particles.set_as_top_level(true)
	remove_child(particles)
	get_parent().add_child(particles)
	particles.emitting = false
	queue_free()
	



func _on_smoke_particles_finished():
	$SmokeParticles.queue_free()
