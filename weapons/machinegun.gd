extends Node3D

@export var gun_name:String = "HardRock"
@export var target_yaw_speed:int = 10
@export var target_pitch_speed:int = 10
@export var rate_of_fire:int = 600

var turret:Node3D
var gun: Node3D
var rof_timer:Timer
var target: Vector3

var can_shoot:bool = true

func _ready():
	turret = $turret
	gun = $turret/gun
	rof_timer = $Timer
	rof_timer.wait_time = 60 / rate_of_fire


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var local_target = $turret.to_local(target)
	local_target.y = 0
	var angle = Vector3.FORWARD.signed_angle_to(local_target, Vector3.UP)
	$turret.rotation.y += angle * clamp(delta * target_yaw_speed, 0, 1)
	var gun_local = $turret/gun.to_local(target)
	gun_local.x = 0
	var pitch_angle = Vector3.FORWARD.signed_angle_to(gun_local, Vector3.RIGHT)
	$turret/gun.rotation.x += pitch_angle * clamp(delta * target_pitch_speed, 0, 1)
	pass
	
func set_target(target: Vector3):
	self.target = target
	
func hold_trigger():
	if can_shoot:
		shoot()
		can_shoot = false
		rof_timer.start()
		
func shoot():
	pass
		
		

