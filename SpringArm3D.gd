extends SpringArm3D

@export_range(0.0, 1.0) var sensitivity: float = 0.25

# Mouse state
var _mouse_position = Vector2(0.0, 0.0)
var _total_pitch = 0.0

# Movement state
var _direction = Vector3(0.0, 0.0, 0.0)
var _velocity = Vector3(0.0, 0.0, 0.0)
var _acceleration = 30
var _deceleration = -10
var _vel_multiplier = 4

var constant_angle = false;
var pitch_override = 0


func _input(event):
	# Receives mouse motion
	if event is InputEventMouseMotion:
		_mouse_position = event.relative
	#if event is InputEventMouseButton:
	#	match event.button_index:
	#		MOUSE_BUTTON_RIGHT: # Only allows rotation if right click down
	#			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE)
	
	# Receives mouse button input
	
# Updates mouselook and movement every frame
func _process(delta):
	_update_mouselook(delta)
	_update_movement(delta)

# Updates camera movement
func _update_movement(delta):
	
	# Computes the change in velocity due to desired direction and "drag"
	# The "drag" is a constant acceleration on the camera to bring it's velocity to 0
	var offset = _direction.normalized() * _acceleration * _vel_multiplier * delta \
		+ _velocity.normalized() * _deceleration * _vel_multiplier * delta
	
	# Compute modifiers' speed multiplier
	var speed_multi = 1
		
	# Checks if we should bother translating the camera
	if _direction == Vector3.ZERO and offset.length_squared() > _velocity.length_squared():
		# Sets the velocity to 0 to prevent jittering due to imperfect deceleration
		_velocity = Vector3.ZERO
	else:
		# Clamps speed to stay within maximum value (_vel_multiplier)
		_velocity.x = clamp(_velocity.x + offset.x, -_vel_multiplier, _vel_multiplier)
		_velocity.y = clamp(_velocity.y + offset.y, -_vel_multiplier, _vel_multiplier)
		_velocity.z = clamp(_velocity.z + offset.z, -_vel_multiplier, _vel_multiplier)
	
		translate(_velocity * delta * speed_multi)

# Updates mouse look 
func _update_mouselook(delta):
	# Only rotates mouse if the mouse is captured
	if not constant_angle:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			_mouse_position *= sensitivity
			var yaw = _mouse_position.x
			var pitch = _mouse_position.y
			_mouse_position = Vector2(0, 0)
			
			# Prevents looking up/down too far
			pitch = clamp(pitch, -90 - _total_pitch, 90 - _total_pitch)
			_total_pitch += pitch
		
			rotate_y(deg_to_rad(-yaw))
			rotate_object_local(Vector3(1,0,0), deg_to_rad(-pitch))
	else: 
		var to_look = lerp(global_transform.basis.z, Vector3(global_position.x,0,global_position.z),delta * 100)		#TODO
		look_at(Vector3(global_position.x,0,global_position.z), Vector3.RIGHT)
		
func look_from_top():
	constant_angle = true
	pitch_override = 0
