extends SpringArm3D

@export_range (1,10,0.1) var smooth_speed: float = 2.5

var diretion = Vector3.FORWARD
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	var current_velocity = get_parent().get_linear_velocity()
	current_velocity.y = 0
	if current_velocity.length_squared() > 1:
		diretion = lerp(diretion,-current_velocity.normalized(), smooth_speed*delta)
	global_transform.basis = get_rotation_from_direction(diretion)
	
func get_rotation_from_direction(look_direction:Vector3) -> Basis:
	look_direction = look_direction.normalized()
	var x_axis = look_direction.cross(Vector3.UP)
	return Basis(look_direction, Vector3.UP, -look_direction)
	
