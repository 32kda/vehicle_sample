@tool
extends Sprite3D

@export var text:String = "Rock"
@export var color:Color = Color(1,1,1,1)

# Called when the node enters the scene tree for the first time.
func _ready():	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$SubViewport/Label.text = text
	$SubViewport/Label.label_settings.font_color = color
	pass
