extends Node3D

func init(position:Vector3):
	global_position = position

# Called when the node enters the scene tree for the first time.
func _ready():	
	$AnimatedSprite3D.play("default")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_audio_stream_player_finished():
	queue_free()
	


func _on_animated_sprite_3d_animation_finished():
	$AnimatedSprite3D.visible = false
