extends RigidBody3D


@export var speed = 350

#var velocity = Vector3.ZERO
var acceleration = Vector3.ZERO
var new_vec:Vector3 = Vector3.ZERO

func start(_transform, _acceleration):
	global_transform = _transform
	acceleration = _acceleration
	Events.missle_target.connect(self.retarget)
	#velocity = _acceleration * speed

func retarget(target:Vector3)->void:
	new_vec = (target - global_position).normalized() 	

func _physics_process(delta):
	apply_central_force(acceleration * speed)
	linear_velocity.limit_length(speed)
	acceleration = lerp(acceleration, new_vec, 10 * delta)
	#global_transform = global_transform.looking_at(acceleration)
	#velocity += (acceleration * delta) as Vector3
	#velocity = velocity.limit_length(speed)
	#rotation = velocity.angle_to()
	#position += velocity * delta

func _on_Lifetime_timeout():
	queue_free()

func _on_Missle_body_entered(body):
	queue_free()
	
