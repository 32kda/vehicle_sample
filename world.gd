extends Node3D

var explosion_proto = preload("res://effects/explosion.tscn")
var explosion_proto01 = preload("res://effects/explosion01.tscn")
var explosion_proto02 = preload("res://effects/explosion02.tscn")

var blast_proto = preload("res://effects/blast.tscn")
# Called when the node enters the scene tree for the first time.

@onready var main_curve = ($track/Path3D).curve

func _ready():
	Events.explosion.connect(_fire_explosion)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _fire_explosion(position:Vector3, target:Node3D):
	var explosion = explosion_proto02.instantiate()
	add_child(explosion)
	explosion.init(position)
	var blast = blast_proto.instantiate()
	target.add_child(blast)
	blast.init(position)
	
#TODO in future we need to support several target curves, maybe using some gates between them
func get_target_curve(vehicle:Node3D):
	return main_curve
