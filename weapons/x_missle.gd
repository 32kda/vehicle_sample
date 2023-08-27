extends RigidBody3D


@export var speed = 350

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO

func start(_transform):
	global_transform = _transform
	velocity = transform.origin.x * speed

func _physics_process(delta):
	velocity += acceleration * delta
	velocity = velocity.clamped(speed)
	rotation = velocity.angle()
	position += velocity * delta

func _on_Missile_body_entered(body):
	queue_free()

func _on_Lifetime_timeout():
	queue_free()
