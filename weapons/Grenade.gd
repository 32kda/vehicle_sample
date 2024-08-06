extends RigidBody3D

const MIN_RICOCHET_ANGLE = 8

@onready var collision = $CollisionShape3D
@onready var raycast = $RayCast3D
@onready var col_shape = $CollisionShape3D

var prev_vec: Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var vec := linear_velocity
	if prev_vec != null:
		var diff = rad_to_deg(prev_vec.angle_to(vec))
		if diff >= MIN_RICOCHET_ANGLE:
			print("from ricochet")
			Events.explosion.emit(global_position, null)
			destroy()			
	prev_vec = vec	
	
func _physics_process(delta):
	
	var query = PhysicsRayQueryParameters3D.create(position, to_global(Vector3.FORWARD))
	var from_ray = get_world_3d().direct_space_state.intersect_ray(query)
	if from_ray:
		print("from_ray " + str(from_ray["collider_id"]))
		Events.explosion.emit(global_position, from_ray["collider"])
		destroy()	
	elif raycast.is_colliding():
		print("from_ray " + str(from_ray["collider_id"]))
		Events.explosion.emit(raycast.get_collision_point(), raycast.get_collider())
		destroy()

#func _integrate_forces(state):	
#	for i in state.get_contact_count():
#		var cpos = state.get_contact_collider_position(i)
#		var target = state.get_contact_collider_object(i)
#		print("contact: " + str(target))
#		destroy()
#		Events.explosion.emit(cpos, target)

func _on_body_entered(body):
	Events.explosion.emit(global_position, body)
	destroy()
	pass
	#destroy()
	#Events.explosion.emit(cpos, target)	

func destroy():
	#var particles = $SmokeParticles
	#remove_child(particles)
	#get_parent().add_child(particles)
	#particles.emitting = false
	queue_free()


func _on_area_3d_body_entered(body):
	if body != self:
		print("body entered " + str(body))
	pass # Replace with function body.
