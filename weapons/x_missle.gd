extends RigidBody3D


@export var speed = 350

#var velocity = Vector3.ZERO
var acceleration = Vector3.ZERO
var new_vec:Vector3 = Vector3.ZERO
const MANEURABILITY = 10;
const MANEUR_MIN_SPEED = 10;
var rays : Array[RayCast3D]

func start(_transform, _acceleration: Vector3, _linear_velocity: Vector3):
	global_transform = _transform
	linear_velocity = _linear_velocity
	acceleration = _acceleration.normalized();
	Events.missle_target.connect(self.retarget)	
	rays.append_array([$Ray1, $Ray2, $Ray3, $Ray4])
	#velocity = _acceleration * speed
	
func _integrate_forces(state):
	for i in state.get_contact_count():
		var cpos = state.get_contact_collider_position(i)
		var target = state.get_contact_collider_object(i)
		var normal = state.get_contact_local_normal(i)
		queue_free()
		Events.explosion.emit(cpos, target)

func retarget(target:Vector3)->void:
	new_vec = (target - global_position).normalized() 	

func _physics_process(delta):
	apply_central_force(acceleration * speed)
	linear_velocity.limit_length(speed)
	if linear_velocity.length() > MANEUR_MIN_SPEED:
		acceleration = lerp(acceleration, new_vec, MANEURABILITY * delta)	
		look_at(linear_velocity + global_position, Vector3.UP, true)
	
		
	#global_transform = global_transform.looking_at(acceleration)
	#velocity += (acceleration * delta) as Vector3
	#velocity = velocity.limit_length(speed)
	#rotation = velocity.angle_to()
	#position += velocity * delta


func _on_Lifetime_timeout():
	queue_free()


