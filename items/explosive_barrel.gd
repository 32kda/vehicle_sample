extends RigidBody3D

@onready var controller = $HealthController

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func hit(damage:int):
	controller.hit(damage)
	if controller.is_destroyed():
		Events.explosion.emit(global_position, null)
		queue_free()
