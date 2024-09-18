extends RigidBody3D

@onready var controller = $HealthController
@onready var boom_timer = $BoomTimer
var initial_health:int
# Called when the node enters the scene tree for the first time.
func _ready():
	initial_health = controller.get_health()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func hit(damage:int):
	controller.hit(damage)
	if controller.is_destroyed():
		Events.explosion.emit(global_position, null)
		queue_free()
	elif controller.get_health() <= initial_health / 2 and boom_timer.is_stopped():
		$FireParticles.show()
		boom_timer.start()


func _on_boom_timer_timeout():
	Events.explosion.emit(global_position, null)
	queue_free()
