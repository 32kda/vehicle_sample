extends Node3D

var gameState = GameState.READY

# Called when the node enters the scene tree for the first time.
func _ready():
	$HUD.visible = false
	$MainMenu.visible = true
	get_tree().paused = true
	Events.set_game_state.connect(self.set_state)

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
