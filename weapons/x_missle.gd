extends RigidBody3D


@export var speed = 350

#var velocity = Vector3.ZERO
var acceleration = Vector3.ZERO
var new_vec:Vector3 = Vector3.ZERO
const MANEURABILITY = 10;
const MANEUR_MIN_SPEED = 10;

func start(_transform, _acceleration: Vector3, _linear_velocity: Vector3):
	global_transform = _transform
	linear_velocity = _linear_velocity
	acceleration = _acceleration.normalized();
	Events.missle_target.connect(self.retarget)	
	#velocity = _acceleration * speed

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

func _on_Missle_body_entered(body):	
	if ($Ray.is_colliding()):
		var collision_point = $Ray.get_collision_point();
		var collider = $Ray.get_collider()
		var normal = $Ray.get_collision_normal()
		queue_free()
		Events.explosion.emit(collision_point)
	
	
	
