extends RigidBody3D

@export var speed = 350

#var velocity = Vector3.ZERO
var acceleration = Vector3.ZERO
var new_vec:Vector3 = Vector3.ZERO
const MANEURABILITY = 160;
const MANEUR_MIN_SPEED = 10;

func start(_transform, _acceleration: Vector3, _linear_velocity: Vector3):
	global_transform = _transform
	linear_velocity = _linear_velocity
	acceleration = _acceleration.normalized();
	Events.missle_target.connect(self.retarget)	
	
func _integrate_forces(state):
	for i in state.get_contact_count():
		var cpos = state.get_contact_collider_position(i)
		var target = state.get_contact_collider_object(i)
		var normal = state.get_contact_local_normal(i)
		destroy()
		Events.explosion.emit(cpos, target)

func retarget(target:Vector3)->void:
	new_vec = (target - global_position).normalized() 	

func _physics_process(delta):
	apply_central_force(acceleration * speed)
	linear_velocity.limit_length(speed)
	if linear_velocity.length() > MANEUR_MIN_SPEED:
		acceleration = lerp(acceleration, new_vec, clamp(MANEURABILITY * delta, 0.0, 1.0))	
		look_at(linear_velocity + global_position, Vector3.UP, true)

func _on_Lifetime_timeout():
	destroy()

func destroy():
	var particles = $SmokeParticles
	remove_child(particles)
	get_parent().add_child(particles)
	particles.stop_emitting()
	queue_free()
	

