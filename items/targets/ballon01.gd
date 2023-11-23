extends RigidBody3D

@export var hp = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func hit(damage:float):
	hp -= damage
	if hp <= 0:
		gravity_scale = 1
		$particles.emitting = true
