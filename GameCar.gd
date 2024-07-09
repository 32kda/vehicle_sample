#A car having health/hit points and alive/destroyed statew
class_name GameCar
extends VehicleBody3D

enum State {
	ALIVE,
	DESTROYED
}

@export var health = 100

var state:=State.ALIVE
var current_speed_mps := 0

func hit(damage:int):
	var prev_health = health
	health = max(0, health - damage)
	if prev_health > 0 and is_destroyed():
		state = State.DESTROYED
		on_destroyed()

func is_destroyed():
	return health == 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):	
	current_speed_mps = linear_velocity.length()
	if state == State.ALIVE:
		physics_process_alive(delta)
	elif state == State.DESTROYED:
		physics_process_destroyed(delta)

func on_destroyed():
	pass
	
func physics_process_alive(delta):
	pass
	
func physics_process_destroyed(delta):
	pass
	
