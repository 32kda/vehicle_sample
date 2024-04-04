extends Node3D

enum Mode {SPHERE, RAYS}

const GOLDEN_ANGLE = PI * (3 - sqrt(5))
const EXPLOSION_MODE := Mode.SPHERE

@export var physical_strength = 1500
@export var damage = 150
@export var base_damage_per_ray = 5
@export var radius := 5.0
@export var num_points := 250
@export var custom_sprite:SpriteFrames

@onready var sprite = $AnimatedSprite3D
@onready var smoke = $Smoke

var rays := []

var processed := Dictionary()

var first_run := true

var damage_distance := 3.5

var exploded = false

func init(position:Vector3):
	global_position = position

# Called when the node enters the scene tree for the first time.
func _ready():	
	if EXPLOSION_MODE == Mode.SPHERE:
		_create_rays()
	else:
		damage_distance = ($Area3D/CollisionShape3D.shape as SphereShape3D).radius 
	if custom_sprite != null:
		sprite.sprite_frames = custom_sprite
	sprite.play("default")
	smoke.emitting = true

func _process(delta):
	pass
				
func _physics_process(_delta):
	if EXPLOSION_MODE == Mode.RAYS:
		if not exploded:
			_explode()
			exploded = true
			#todo damage calc
	else: 
		for body in $Area3D.get_overlapping_bodies():
			if body is RigidBody3D:
				var id = body.get_instance_id();
				if not processed.has(id):
					processed[id] = true
					var distance:Vector3 = body.global_transform.origin - global_transform.origin
					var impact = 1.0 * physical_strength / (distance.length() + 0.1) #Closer the explosion are - bigger the imapct. 0.1 added to avoid zero division problems
					body.apply_central_impulse(distance.normalized() * impact)				
			if body.has_method("hit"):
				body.hit(damage)					

func _on_audio_stream_player_3d_finished():			
	pass

func _on_animated_sprite_3d_animation_finished():
	sprite.visible = false
	
func _create_rays() -> void:
	var points = _get_points()
	for point in points:
		var ray := RayCast3D.new()
		add_child(ray)
		ray.target_position = point
		ray.enabled = false
		ray.exclude_parent = true
		rays.append(ray)


func _get_points() -> Array:
	var points = []
	
	for point in num_points:
		var y: float = 1.0 - (point / (num_points - 1.0)) * 2.0
		var r: float = sqrt(1 - y*y)
		
		var angle_increment: float = GOLDEN_ANGLE * point
		
		var x: float = cos(angle_increment) * r
		var z: float = sin(angle_increment) * r
		
		points.append(Vector3(x, y, z) * radius)
	
	return points


func _get_explosion_ray_data() -> Array:
	var colliding_rays = []
	for ray in rays:
		ray.enabled = true
		ray.force_raycast_update()
		
		if ray.is_colliding():
			colliding_rays.append(ray)
	
	return colliding_rays


func _explode():
	var explosion_rays = _get_explosion_ray_data()
	var count = 0
	for ray in explosion_rays:
		var collider = ray.get_collider()
		
		if collider.has_method("take_damage"):
			var damage = _calculate_damage(ray.get_collision_point())
			collider.take_damage(damage)
	
		if collider is RigidBody3D:
			count += 1
			var body := collider as RigidBody3D
			var collision_point = ray.get_collision_point()
			var distance:Vector3 = collision_point - global_transform.origin
			var impact = 1.0 * physical_strength / (num_points * (distance.length() + 0.1)) #Closer the explosion are - bigger the imapct. 0.1 added to avoid zero division problems
			collider.apply_impulse(distance.normalized() * impact, collision_point)

func _calculate_damage(collision_point: Vector3) -> float:
	var distance = global_transform.origin.distance_to(collision_point)
	var damage = base_damage_per_ray * (radius - distance)
	
	return damage if damage > 0 else 0


func _on_smoke_finished():
	queue_free()
