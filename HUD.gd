extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("player_speed", set_speed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_speed(kmh):
	$Info.text=str(round(kmh)).pad_zeros(3) + "km/h"
