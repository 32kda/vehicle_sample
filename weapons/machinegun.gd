class_name Machinegun
extends Node3D

const FLASH_TIME = 0.05

@export var gun_name:String = "HardRock"
@export var target_yaw_speed:int = 10
@export var target_pitch_speed:int = 10
@export var rate_of_fire:int = 600
@export var fire_range:int = 1000
@export var damage:int = 25

@onready var turret:Node3D = $turret
@onready var gun: Node3D = $turret/gun
@onready var rof_timer:Timer = $ROF_Timer
@onready var flash_timer: Timer = $Flash_Timer
@onready var flash: Node3D = $turret/gun/flash
@onready var sound = $ShootSoundPlayer
@onready var hit_scan = $turret/gun/HitScan

var target: Vector3

var can_shoot:bool = true
#By default machinegun can hit players, enemies and some destroyable objects on map
#If using in your game - be sure to replace with your constants
#GDScript do not support interfaces (like Java) yet, so yu need to ensure your objects have necessary hit(damage) method
var hit_groups:=["Players", "Enemies", "Objects"]

func _ready():
	assert(rate_of_fire > 0, "Rate of Fire should be positive number!")
	hit_scan.set_hit_groups(hit_groups)
	hit_scan.set_damage(damage)
	rof_timer.wait_time = 60.0 / rate_of_fire	
	flash_timer.wait_time = FLASH_TIME

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
	
func set_target(target: Vector3, weight: float = 1.0):	
	self.target = lerp(self.target, target, weight)
	
func angle_to(point: Vector3) -> float:
	return target.angle_to(point)
	
func hold_trigger():
	if can_shoot:
		shoot()
		can_shoot = false
		rof_timer.start()
		
func shoot():
	$turret/gun/flash.visible = true
	flash_timer.start()
	do_hit_scan()
	sound.play()
		
func _on_timer_timeout():
	can_shoot = true
	
func hide_flash():
	flash.visible = false	
	
func do_hit_scan():
	hit_scan.make_shot()
	$turret/gun/Projectile.make_shot() #TODO debug

func set_hit_groups(groups:Array):
	hit_groups = groups
