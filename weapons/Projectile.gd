extends Node

@onready var bullet_ray: RayCast3D = $RayCast3D #A ray for initial project direction
@export var damage:int = 5 #Damage, which projectile will directly do when hit. For now does not depend on distance
@export var speed := 70
@export var deviation = 0.03
@export var hit_groups:=["Players", "Enemies", "Objects", "Breakable"]

var projectile_proto := preload("res://weapons/Grenade.tscn")
# Called when the node enters the scene tree for the first time.

func make_shot():
	var angle = randf_range(0, PI)
	var cur_deviation = randfn(0,deviation)
		
	var bullet_direction = -bullet_ray.global_transform.basis.z
	var to_add = Vector3(cur_deviation,0,0).rotated(bullet_direction,angle)
	var projectile := projectile_proto.instantiate()
	var projectile_transform = Transform3D(bullet_ray.global_transform.basis, bullet_ray.global_position)
	projectile.global_transform = projectile_transform
	var world = get_tree().current_scene.world
	world.add_child(projectile)
	projectile.linear_velocity = bullet_direction * speed

func set_hit_groups(groups:Array):
	hit_groups = groups
	
func set_deviation(deviation: float):
	self.deviation = deviation
	
func set_damage(damage: int):
	self.damage = damage
