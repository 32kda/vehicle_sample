extends RigidBody3D
class_name EnemyDrone01

enum {	
	TAKEOFF,
	PATROLING,
	ATTACKING,
	SHOT_DOWN	
}

const FORWARD_ANGLE = deg_to_rad(30)
const MANEURABILITY = 15

@export var health = 100
@export var speed = 20
@export var min_attack_angle = 45
@export var max_attack_angle = 30

@onready var min_dist_ratio = tan(deg_to_rad(min_attack_angle))
@onready var max_dist_ratio = tan(deg_to_rad(max_attack_angle))

var state = PATROLING

@export var circle_radius:int = 20
var circle_center:Vector3
var ccw_direction := true

var acceleration = Vector3.ZERO
var new_vec:Vector3 = Vector3.ZERO
var to_attack:RigidBody3D
var visible_units := []


# Called when the node enters the scene tree for the first time.
func _ready():
	if circle_center == Vector3.ZERO:
		circle_center = Vector3(global_position.x + circle_radius, global_position.y, global_position.z)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state:
		PATROLING:
			var to_center:Vector3 = global_position - circle_center
			#DebugDraw3D.draw_arrow_line(global_position, circle_center, Color.GREEN)
			var to_rotate = to_center.normalized() * circle_radius
			var target = to_rotate.rotated(Vector3.UP, delta * (-FORWARD_ANGLE if ccw_direction else FORWARD_ANGLE))
			new_vec = target + circle_center - global_position
			#DebugDraw3D.draw_arrow_line(global_position, global_position + new_vec * 5, Color.RED)
		ATTACKING:
			var to_target := Vector3(to_attack.global_position.x, global_position.y, to_attack.global_position.z)
			var dist = to_target.distance_to(global_position)
			var min_dist = global_position.y / min_dist_ratio
			var max_dist = global_position.y / max_dist_ratio
			if dist > ((max_dist - min_dist) / 2):
				new_vec = (to_target - global_position).normalized() * max_dist
			else:
				new_vec = Vector3.ZERO
			pass
		SHOT_DOWN:
			pass
	pass
	
func _physics_process(delta):
	apply_central_force(acceleration * speed)
	linear_velocity.limit_length(speed)
	acceleration = lerp(acceleration, new_vec, clamp(MANEURABILITY * delta, 0.0, 1.0))	
	print("State: " + str(state))
	match state:
		PATROLING:
			if linear_velocity.length() > 0.1:
				look_at(lerp(global_transform.basis.z, linear_velocity + global_position, delta), Vector3.UP)
				pass
		ATTACKING:
			var to_target := Vector3(to_attack.global_position.x, global_position.y, to_attack.global_position.z)
			if to_target.distance_to(global_position) >= 1:
				look_at(lerp(global_transform.basis.z, to_target, delta), Vector3.UP)
				pass
		SHOT_DOWN:
			pass
			

func set_state(state):	
	self.state = state
	$Label3D.text = str(state)

func _on_enemy_detection_body_entered(body):
	if body.is_in_group("Players"):
		visible_units.append(body)
		if state == PATROLING:
			to_attack = body
			set_state(ATTACKING)

func _on_enemy_detection_body_exited(body):	
	if body.is_in_group("Players"):
		visible_units.erase(body)
		if state == ATTACKING && to_attack == body:
			if visible_units.size() > 0:
				to_attack = visible_units[0]
			else:
				set_state(PATROLING)
				
func hit(damage: int):
	if state != SHOT_DOWN:
		health = max(0, health - damage)
		if health == 0:
			shot_down()
			
func shot_down():
	set_state(SHOT_DOWN)
	gravity_scale = 1.0 #Make it fall onto the ground
	#TODO emit some particles, show some fire or play sound
		
