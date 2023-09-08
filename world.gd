extends Node3D

var explosion_proto = preload("res://effects/missle_explosion.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	Events.explosion.connect(_fire_explosion)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _fire_explosion(position:Vector3):
	var explosion = explosion_proto.instantiate()
	add_child(explosion)
	explosion.init(position)
	
