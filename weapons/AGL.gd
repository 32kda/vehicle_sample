extends Node3D

@export var gun_name:String = "HardRock"
@export var target_yaw_speed:int = 10
@export var target_pitch_speed:int = 10
@export var rate_of_fire:int = 300
@export var fire_range:int = 1000
@export var damage:int = 8
@export var hit_groups:=["Players", "Enemies", "Objects", "Breakable"]
@export var mag_capacity = 20
@export var max_up_angle = 80
@export var max_down_angle = 80

@onready var turret:Node3D = $turret_body
@onready var gun: Node3D = $turret_body/barrel_body
@onready var rof_timer:Timer = $ROF_Timer
@onready var reload_timer:Timer = $Reload_Timer
@onready var sound = $ShootSoundPlayer
@onready var reload_sound := $ReloadSoundPlayer
@onready var projectile_emitter := $turret_body/barrel_body/Projectile
@onready var mag := $turret_body/barrel_body/mag

var target: Vector3
var ammo = mag_capacity
var max_up_rad = deg_to_rad(max_up_angle)
var max_down_rad = deg_to_rad(max_down_angle)

var can_shoot:bool = true
#By default machinegun can hit players, enemies and some destroyable objects on map
#If using in your game - be sure to replace with your constants
#GDScript do not support interfaces (like Java) yet, so yu need to ensure your objects have necessary hit(damage) method

func _ready():
	assert(rate_of_fire > 0, "Rate of Fire should be positive number!")
	#projectile_emitter.set_hit_groups(hit_groups)
	#projectile_emitter.set_damage(damage)
	rof_timer.wait_time = 60.0 / rate_of_fire		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var local_target = turret.to_local(target)
	local_target.y = 0
	var angle = Vector3.FORWARD.signed_angle_to(local_target, Vector3.UP)
	turret.rotation.y += angle * clamp(delta * target_yaw_speed, 0, 1)
	var gun_local = gun.to_local(target)
	gun_local.x = 0
	var pitch_angle = Vector3.FORWARD.signed_angle_to(gun_local, Vector3.RIGHT)
	var foo = gun.rotation.x
	gun.rotation.x += pitch_angle * clamp(delta * target_pitch_speed, 0, 1)
	
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
	ammo -= 1
	projectile_emitter.make_shot()
	sound.play()
	if ammo == 0:
		reload()
		
func _on_timer_timeout():
	can_shoot = ammo > 0
	
func reload():
	ammo = 0 #TODO if ammo is not infinite, push this back to global ammo count of specific type
	mag.visible = false
	reload_sound.play()
	reload_timer.start()	
	
func do_projectile_emitter():
	projectile_emitter.make_shot()

func set_hit_groups(groups:Array):
	hit_groups = groups


func _on_reload_timer_timeout():
	ammo = mag_capacity #TODO take this from player's ammo amount in future
	mag.visible = true
	can_shoot = true	
