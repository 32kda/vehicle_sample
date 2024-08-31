extends CanvasLayer

@onready var crosshair = $Crosshair
@onready var game_over = $GameOver

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("player_speed", set_speed)
	Events.connect("player_health", set_health)
	
	crosshair.visible = true
	game_over.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_speed(kmh):
	$Info.text=str(round(kmh)).pad_zeros(3) + "km/h"
	$FPS.set_text("FPS %d" % Engine.get_frames_per_second())
	
func set_health(health):
	$Health.set_text("HP: " + str(health).pad_zeros(3))
	
	if health <= 0:
		crosshair.visible = false
		game_over.visible = true
