class_name Machinegun
extends Node3D

const FLASH_TIME = 0.05
const IMPULSE_MULTIPLIER = 2

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
@onready var bullet_ray = $turret/gun/BulletRay
@onready var hole_decal = preload("res://weapons/effects/bullet_hole.tscn")

var target: Vector3

var can_shoot:bool = true
var parentBody;
#By default machinegun can hit players, enemies and some destroyable objects on map
#If using in your game - be sure to replace with your constants
#GDScript do not support interfaces (like Java) yet, so yu need to ensure your objects have necessary hit(damage) method
var hit_groups:=["Players", "Enemies", "Objects"]

func _ready():
	assert(rate_of_fire > 0, "Rate of Fire should be positive number!")
	
	rof_timer.wait_time = 60.0 / rate_of_fire	
	flash_timer.wait_time = FLASH_TIME
	parentBody = get_parent_node_3d()
	while (parentBody != null && !(parentBody is RigidBody3D)):
		parentBody = parentBody.get_parent_node_3d()

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
	hit_scan()
	sound.play()
		
func _on_timer_timeout():
	can_shoot = true
	
func hide_flash():
	flash.visible = false	
	
func hit_scan():
	var angle = randf_range(0, PI)
	var deviation = randfn(0,0.03)
	var to_add = Vector3(deviation,0,0).rotated(Vector3.FORWARD,angle)
		
	var bullet_direction = -bullet_ray.global_transform.basis.z.normalized()
	to_add = to_add * bullet_ray.global_transform.basis
	bullet_direction = bullet_direction + Vector3(deviation,0,0).rotated(Vector3.FORWARD,angle) #Todo adding this way does not seem correct	
	var origin = bullet_ray.global_transform.origin
	var intersection = PhysicsRayQueryParameters3D.create(origin, origin + bullet_direction * fire_range)
	var bullet_collision = get_world_3d().direct_space_state.intersect_ray(intersection)
	
	if bullet_collision:
		var collider:Node3D = bullet_collision["collider"]
		var collision_point:Vector3 = bullet_collision["position"]
		var collision_normal:Vector3 = bullet_collision["normal"]
		var hole:Node3D = hole_decal.instantiate()
		collider.add_child(hole)
		hole.global_transform.origin = collision_point
		if Vector3.DOWN.is_equal_approx(collision_normal):
			hole.rotation_degrees.x = 90
		elif !Vector3.UP.is_equal_approx(collision_normal):
			hole.look_at(collision_point - collision_normal, Vector3(0,1,0))			
		if (collider is RigidBody3D) and (collider != parentBody):			#avoid hitting self
			var body = collider as RigidBody3D
			body.apply_impulse(bullet_direction * IMPULSE_MULTIPLIER, collision_point)
		
		for grp in hit_groups:
			if collider.is_in_group(grp) and (collider != parentBody):
				collider.hit(damage)
				break

func set_hit_groups(groups:Array):
	hit_groups = groups
