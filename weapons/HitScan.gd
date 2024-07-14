extends Node3D

@export var hole_decal = preload("res://weapons/effects/bullet_hole.tscn")

@onready var bullet_ray: RayCast3D = $RayCast3D
@export var fire_range: int = 300
@export var impulse_multiplier: float = 5
@export var deviation:float = 0.03
@export var damage:int = 5
var hit_groups := []
var parents := []

func _on_ready():
	var current = get_parent_node_3d()
	while not (current is RigidBody3D or current is CharacterBody3D):
		current = current.get_parent()
	while current is RigidBody3D or current is CharacterBody3D:
		parents.append(current)
		current = current.get_parent_node_3d()
	
func make_shot():
	var angle = randf_range(0, PI)
	var deviation = randfn(0,0.03)
		
	var bullet_direction = -bullet_ray.global_transform.basis.z
	var to_add = Vector3(deviation,0,0).rotated(bullet_direction,angle)
	
	bullet_direction = (bullet_direction + to_add).normalized() #Todo adding this way does not seem correct	
	var origin = bullet_ray.global_transform.origin
	var intersection = PhysicsRayQueryParameters3D.create(origin, origin + bullet_direction * fire_range)
	var bullet_collision = bullet_ray.get_world_3d().direct_space_state.intersect_ray(intersection)
	
	if bullet_collision:
		var collider:Node3D = bullet_collision["collider"]
		var collision_point:Vector3 = bullet_collision["position"]
		var collision_normal:Vector3 = bullet_collision["normal"]
		var hole:Node3D = hole_decal.instantiate()
		collider.add_child(hole)
		hole.global_transform.origin = collision_point
		var parent_body = get_parent()
		if Vector3.DOWN.is_equal_approx(collision_normal):
			hole.rotation_degrees.x = 90
		elif !Vector3.UP.is_equal_approx(collision_normal):
			hole.look_at(collision_point - collision_normal, Vector3(0,1,0))	
		if not collider in parents:		
			var found = false
			var initial_collider = collider
			while not found and ((collider is RigidBody3D) or (collider is CharacterBody3D)):
				for grp in hit_groups:
					if collider.is_in_group(grp) and (collider != parent_body):
						collider.hit(damage)
						found = true
						break
				collider = collider.get_parent_node_3d()
			#not found since we don't want to kick players and mobs with it
			if not found and impulse_multiplier > 0 and (initial_collider is RigidBody3D) and (initial_collider != parent_body):			#avoid hitting self
				var body = initial_collider as RigidBody3D
				body.apply_impulse(bullet_direction * impulse_multiplier, collision_point)
			

func set_hit_groups(groups:Array):
	hit_groups = groups
	
func set_deviation(deviation: float):
	self.deviation = deviation
	
func set_damage(damage: int):
	self.damage = damage
	
func set_impulse_multiplier(impulse_multiplier: float):
	self.impulse_multiplier = impulse_multiplier



