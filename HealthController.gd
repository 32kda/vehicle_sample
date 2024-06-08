extends Node
class_name HealthController

@export var health = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func hit(damage:int):
	health = max(0, health - damage)

func is_destroyed():
	return health == 0

func _process(delta):
	pass
