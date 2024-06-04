extends Node3D

var gameState = GameState.READY
var started = false

@onready var world = $world
var drone00_proto := preload("res://mobs/enemy_drone.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$HUD.visible = false
	$MainMenu.visible = true
	world.get_tree().paused = true
	Events.set_game_state.connect(self.set_state)
	Events.drone_destroyed.connect(self.drone_destroyed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ESC"):
		if gameState == GameState.STARTED:
			Events.set_game_state.emit(GameState.PAUSED)
		elif gameState == GameState.PAUSED:
			Events.set_game_state.emit(GameState.STARTED)
	
func set_state(state):
	gameState = state
	if state == GameState.READY:		
		get_tree().reload_current_scene()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif state == GameState.PAUSED:
		$HUD.visible = false
		get_tree().paused = true;
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif state == GameState.STARTED:		
		$HUD.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().paused = false;

func get_target_curve(vehicle:Node3D):
	return world.get_target_curve(vehicle)
	
func drone_destroyed():
	var drone = drone00_proto.instantiate()
	drone.global_position = Vector3(0,10,0)
	drone.look_at(drone.global_position + Vector3(0,0,-1), Vector3.UP, true)
	world.add_child(drone)	
