extends RigidBody3D

const barrels_angle = PI / 3 #Or 360 / 6 = 60 degrees

@onready var axis := $BarrelAxis
@onready var barrels = $barrels
@onready var hit_scan := $HitScan
@onready var muzzle_flash := $MuzzleFlash

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
	if firing:
		var angle = barrels.transform.basis.y.angle_to(transform.basis.y)
		var barrel_idx = round(angle / barrels_angle)
		if barrel_idx != prev_barrel_idx:
			fire_round()
			muzzle_flash.restart()
			muzzle_flash.emitting = true
			prev_barrel_idx = barrel_idx		

func fire_round():
	hit_scan.make_shot()
	
func set_hit_groups(groups:Array):
	hit_scan.set_hit_groups(groups)
