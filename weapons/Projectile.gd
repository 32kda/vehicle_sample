extends Node

@onready var bullet_ray: RayCast3D = $RayCast3D #A ray for initial project direction
@export var damage:int = 5 #Damage, which projectile will directly do when hit. For now does not depend on distance

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
