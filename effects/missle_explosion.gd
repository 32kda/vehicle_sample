extends Node3D

@export var physical_strength = 3000
@export var damage = 150

var processed := Dictionary()

var first_run := true

var damage_distance := 3.5

func init(position:Vector3):
	global_position = position

# Called when the node enters the scene tree for the first time.
func _ready():	
	$AnimatedSprite3D.play("default")
	if $Area3D/CollisionShape3D.shape is SphereShape3D:
		damage_distance = ($Area3D/CollisionShape3D.shape as SphereShape3D).radius
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
				
func _physics_process(_delta):
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

func _on_audio_stream_player_finished():
	queue_free()
	


func _on_animated_sprite_3d_animation_finished():
	$AnimatedSprite3D.visible = false
