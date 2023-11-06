extends Node3D

const TARGET_YAW_SPEED = 10;
const TARGET_PITCH_SPEED = 200;

var target: Vector3
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var local_target = $turrent.to_local(target)
	local_target.y = 0
	var angle = Vector3.FORWARD.signed_angle_to(local_target, Vector3.UP)
	$turrent.rotation.y += angle * clamp(delta * TARGET_YAW_SPEED, 0, 1)
	var gun_local = $turrent/gun.to_local(target)
	gun_local.x = 0
	var pitch_angle = Vector3.FORWARD.signed_angle_to(gun_local, Vector3.RIGHT)
	$turrent/gun.rotation.x += pitch_angle * clamp(delta * TARGET_PITCH_SPEED, 0, 1)
	pass
	
func set_target(target: Vector3):
	self.target = target
