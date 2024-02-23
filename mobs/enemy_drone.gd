extends RigidBody3D
class_name Enemy

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

@export var circle_radius:int = 20
var circle_center:Vector3
var ccw_direction := true

var acceleration = Vector3.ZERO
var new_vec:Vector3 = Vector3.ZERO
var to_attack:RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready():
	if circle_center == Vector3.ZERO:
		circle_center = Vector3(global_position.x + circle_radius, global_position.y, global_position.z)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state:
		PATROLING:
			var to_center:Vector3 = global_position - circle_center
			#DebugDraw3D.draw_arrow_line(global_position, circle_center, Color.GREEN)
			var to_rotate = to_center.normalized() * circle_radius
			var target = to_rotate.rotated(Vector3.UP, delta * (-FORWARD_ANGLE if ccw_direction else FORWARD_ANGLE))
			new_vec = target + circle_center - global_position
			#DebugDraw3D.draw_arrow_line(global_position, global_position + new_vec * 5, Color.RED)
		ATTACKING:
			pass
		SHOT_DOWN:
			pass
	pass
	
func _physics_process(delta):
	match state:
		PATROLING:
			apply_central_force(acceleration * speed)
			linear_velocity.limit_length(speed)
			acceleration = lerp(acceleration, new_vec, clamp(MANEURABILITY * delta, 0.0, 1.0))	
			look_at(linear_velocity + global_position, Vector3.UP)
		ATTACKING:
			pass
			

func set_state(state):	
	self.state = state
	$Label3D.text = str(state)

func _on_enemy_detection_body_entered(body):
	if body.is_in_group("Players"):
		set_state(ATTACKING)
		to_attack = body
	pass # Replace with function body.
