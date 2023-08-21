extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():	
	Events.set_game_state.connect(self.set_state)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_btn_pressed():	
	Events.set_game_state.emit(GameState.STARTED)	
	

func set_state(state):
	if state == GameState.PAUSED:
		$Menu.visible = true
		$Menu/ControlContainer/RestartBtn.visible = true
		$Menu/ControlContainer/ResumeBtn.visible = true
		$Menu/ControlContainer/StartBtn.visible = false
	elif state == GameState.STARTED:
		$Menu.visible = false
	elif state == GameState.READY:
		$Menu.visible = true
		$Menu/ControlContainer/RestartBtn.visible = false
		$Menu/ControlContainer/ResumeBtn.visible = false
		$Menu/ControlContainer/StartBtn.visible = true
					
		

func _on_resume_btn_pressed():
	Events.set_game_state.emit(GameState.STARTED)


func _on_restart_btn_pressed():
	Events.set_game_state.emit(GameState.READY)


func _on_quit_btn_pressed():
	get_tree().quit()
