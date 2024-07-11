extends CharacterBody3D

const barrels_angle = PI / 3 #Or 360 / 6 = 60 degrees

@onready var axis := $BarrelAxis
@onready var barrels = $barrels
@onready var hit_scan := $HitScan
@onready var muzzle_flash := $MuzzleFlash
@onready var sound := $AudioStreamPlayer3D

@export var rotation_speed = 7.0
@export var rotation_accel = 2.0

var current_rotation_speed = 0.0;

var firing := false
var prev_barrel_idx = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func fire():
	if not firing:
		firing = true
		axis.set_flag(HingeJoint3D.FLAG_ENABLE_MOTOR, true)
	
func stop_fire():
	if firing:
		firing = false
		axis.set_flag(HingeJoint3D.FLAG_ENABLE_MOTOR, false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_rotation_speed > 0:
		barrels.rotate_z(current_rotation_speed * delta)
	if firing:		
		current_rotation_speed = lerp(current_rotation_speed, rotation_speed, rotation_accel * delta)
		var angle = barrels.transform.basis.y.angle_to(transform.basis.y)
		var barrel_idx = round(angle / barrels_angle)
		if barrel_idx != prev_barrel_idx:
			fire_round()
			muzzle_flash.restart()
			muzzle_flash.emitting = true
			prev_barrel_idx = barrel_idx		
	else:
		current_rotation_speed = lerp(current_rotation_speed, 0.0, rotation_accel * delta)		

func fire_round():
	hit_scan.make_shot()
	sound.play()
	
func set_hit_groups(groups:Array):
	hit_scan.set_hit_groups(groups)
	
func angle_to(point: Vector3)	 -> float:
	return Vector3.FORWARD.angle_to(to_local(point))
