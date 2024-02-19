extends RigidBody3D

enum {	
	PATROLING,
	ATTACKING,
	SHOT_DOWN	
}

const FORWARD_ANGLE = deg_to_rad(30)
const MANEURABILITY = 30

@export var health = 100
@export var speed = 40

var state = PATROLING

var circle_radius:int = 100
var circle_center:Vector3
var ccw_direction := true

var acceleration = Vector3.ZERO
var new_vec:Vector3 = Vector3.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	if circle_center == Vector3.ZERO:
		circle_center = Vector3(global_position.x + circle_radius, global_position.y, global_position.z)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state:
		PATROLING:
			var to_center:Vector3 = global_position - circle_center
			var target = to_center.rotated(Vector3.UP, delta * (FORWARD_ANGLE if ccw_direction else -FORWARD_ANGLE))
			new_vec = target.normalized()
		ATTACKING:
			pass
		SHOT_DOWN:
			pass
	pass
	
func _physics_process(delta):
	apply_central_force(acceleration * speed)
	linear_velocity.limit_length(speed)
	acceleration = lerp(acceleration, new_vec, clamp(MANEURABILITY * delta, 0.0, 1.0))	
	look_at(linear_velocity + global_position, Vector3.UP, true)
