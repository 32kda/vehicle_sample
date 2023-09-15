extends Node3D

var explosion_proto = preload("res://effects/missle_explosion.tscn")
var blast_proto = preload("res://effects/blast.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	Events.explosion.connect(_fire_explosion)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _fire_explosion(position:Vector3, target:Node3D):
	var explosion = explosion_proto.instantiate()
	add_child(explosion)
	explosion.init(position)
	var blast = blast_proto.instantiate()
	target.add_child(blast)
	blast.init(position)
	
