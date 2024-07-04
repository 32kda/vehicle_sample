@tool
extends Area3D

@onready var detection = $DetectionShape
@export var radius = 30
@export var height = 10
@export var fov_angle = 180
var enemy_groups := []

var to_attack:RigidBody3D
var visible_units := []
var parent_unit

func set_enemy_groups(enemy_groups:Array):
	self.enemy_groups = enemy_groups
	var cur_parent = get_parent_node_3d()
	while parent_unit == null and cur_parent != null:
		for grp in enemy_groups:
			if cur_parent.is_in_group(grp):
				parent_unit = cur_parent
		cur_parent = cur_parent.get_parent_node_3d()
	if parent_unit == null:
		parent_unit = get_parent_node_3d()
	

func _ready():
	if Engine.is_editor_hint():
		return
	detection.shape.radius = radius
	detection.shape.height = height
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
		detection.shape.radius = radius
		detection.shape.height = height
	else: #TODO 
		pass

func _on_body_entered(body:Node3D):
	if body == parent_unit:
		return	
	if enemy_groups.is_empty():
		push_warning("Enemy detection for " + get_parent().get_name() + " did nothing, since no enemy groups are set" )
	for grp in enemy_groups:
		if body.is_in_group(grp):
			visible_units.append(body)
			if to_attack == null:
				to_attack = body

func is_in_fov(body:Node3D) -> bool:
	if body == null:
		return false
	var max = deg_to_rad(fov_angle / 2)
	var local = to_local(body.global_position)
	local.y = 0
	return local.angle_to(Vector3.FORWARD) <= max

func _on_body_exited(body):
	if body == parent_unit:
		return
	visible_units.erase(body)
	if to_attack == body:
		if visible_units.size() > 0:
			to_attack = visible_units[0]
		else:
			to_attack = null
			
func get_target():
	if not is_in_fov(to_attack):
		var new_target = null
		for body in visible_units:
			if body != to_attack and is_in_fov(body):
				to_attack = body
				break		
	return to_attack
