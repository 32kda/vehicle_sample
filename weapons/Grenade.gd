extends RigidBody3D

@onready var collision = $CollisionShape3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _integrate_forces(state):	
	for i in state.get_contact_count():
		var cpos = state.get_contact_collider_position(i)
		var target = state.get_contact_collider_object(i)
		print("contact: " + str(target))
		destroy()
		Events.explosion.emit(cpos, target)

func _on_body_entered(body):
	print(body)
	pass
	#destroy()
	#Events.explosion.emit(cpos, target)	

func destroy():
	#var particles = $SmokeParticles
	#remove_child(particles)
	#get_parent().add_child(particles)
	#particles.emitting = false
	queue_free()
