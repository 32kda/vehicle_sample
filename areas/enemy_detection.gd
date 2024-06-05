@tool
extends Area3D

@onready var detection = $DetectionShape
@export var radius = 30
@export var height = 10
@export var fov_angle = 180
var enemy_groups := []

var to_attack:RigidBody3D
var visible_units := []

func set_enemy_groups(enemy_groups:Array):
	self.enemy_groups = enemy_groups
	

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
	if enemy_groups.is_empty():
		push_warning("Enemy detection for " + get_parent().get_name() + " did nothing, since no enemy groups are set" )
	for grp in enemy_groups:
		if body.is_in_group(grp):
			visible_units.append(body)
			if to_attack == null:
				to_attack = body

func _on_body_exited(body):
	visible_units.erase(body)
	if to_attack == body:
		if visible_units.size() > 0:
			to_attack = visible_units[0]
		else :
			to_attack = null

