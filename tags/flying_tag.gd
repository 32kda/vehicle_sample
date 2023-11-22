extends Label3D

@export var lifetime:float = 1;

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.wait_time = lifetime	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_translate(Vector3.UP * delta)	


func _on_timer_timeout():
	queue_free()
