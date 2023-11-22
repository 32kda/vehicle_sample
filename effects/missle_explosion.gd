extends Node3D

@export var physical_strength = 500

var first_run := true

func init(position:Vector3):
	global_position = position

# Called when the node enters the scene tree for the first time.
func _ready():	
	$AnimatedSprite3D.play("default")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
				
func _physics_process(_delta):
	call_deferred("process_explosion")	

func process_explosion():
	if first_run:		
		for body in $Area3D.get_overlapping_bodies():
			first_run = false
			if body is RigidBody3D:
				var distance:Vector3 = body.global_transform.origin - global_transform.origin
				var impact = 1.0 * physical_strength / (distance.length() + 0.1) #Closer the explosion are - bigger the imapct. 0.1 added to avoid zero division problems
				body.apply_central_impulse(distance.normalized() * impact)
			if body.has_method("hurt"):
				pass

func _on_audio_stream_player_finished():
	queue_free()
	


func _on_animated_sprite_3d_animation_finished():
	$AnimatedSprite3D.visible = false
