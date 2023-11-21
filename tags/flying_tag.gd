@tool
extends Sprite3D

@export var lines_up:int = 5;
@export var speed = 10
@export var text:String = "Rock"
@export var color:Color = Color(1,0,0,1)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
		$SubViewport/Label.text = text
		$SubViewport/Label.label_settings.font_color = color
		var size:Vector2 = $SubViewport/Label.get_rect().size
		var viewport_size = Vector2(size.x, lines_up * size.y)
		$SubViewport.size = viewport_size
	else: 
		var position:Vector2 = $SubViewport/Label.position
		position.y -= delta * speed
		if position.y < $SubViewport/Label.get_rect().size.y:
			queue_free()
		else:
			$SubViewport/Label.position = position
		
	pass
