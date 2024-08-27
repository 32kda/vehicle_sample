extends Node3D

@onready var bullet_pos: Marker3D = $Marker3D #A ray for initial project direction
@export var damage:int = 5 #Damage, which projectile will directly do when hit. For now does not depend on distance
@export var speed := 70
@export var deviation = 0.03
@export var projectile_velocity: int = 40
@export var hit_groups:=["Players", "Enemies", "Objects", "Breakable"]

var count = 0;
var projectile_proto := preload("res://weapons/bullet.tscn")
var projectiles_spawned = []
# Called when the node enters the scene tree for the first time.

func make_shot():
	print("Shot: " + str(count))
	count += 1
	var angle = randf_range(0, PI)
	var cur_deviation = randfn(0,deviation)
		
	var bullet_direction = -bullet_pos.global_transform.basis.z
	#var bullet_direction = bullet_ray.to_global(Vector3.FORWARD)
	#var to_add = Vector3(cur_deviation,0,0).rotated(bullet_direction,angle)
	var projectile := projectile_proto.instantiate()
	launch_rigid_body_projectile(to_global(Vector3.FORWARD), projectile)
#	var projectile_transform = Transform3D(bullet_pos.global_transform.basis, bullet_pos.global_position)
#	projectile.global_transform = projectile_transform
#	var world = get_tree().current_scene.world	
#	projectile.set_as_top_level(true)
#	projectile.set_linear_velocity(bullet_direction * speed)
#	print("Velocity: " + str(projectile.linear_velocity) + " length: " + str(projectile.linear_velocity.length()))
#	world.add_child(projectile)

func set_hit_groups(groups:Array):
	hit_groups = groups
	
func set_deviation(deviation: float):
	self.deviation = deviation
	
func set_damage(damage: int):
	self.damage = damage
	
func launch_rigid_body_projectile(point, proj):		
	add_child(proj)
	
	projectiles_spawned.push_back(proj)

	proj.body_entered.connect(_on_body_entered.bind(proj))
	
	var direction = (point - global_transform.origin).normalized()
	proj.set_as_top_level(true)
	proj.set_linear_velocity(direction * projectile_velocity)    

func _on_body_entered(body, proj):
	proj.queue_free()
	Events.explosion.emit(proj.global_position, null)	
	projectiles_spawned.erase(proj)
	
#	if Projectiles_Spawned.is_empty():
#		queue_free()   
