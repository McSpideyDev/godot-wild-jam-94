extends Node2D

@export var turtle_scene: PackedScene

func _ready():
	GameEvents.request_mutation.connect(_on_mutation_requested)
	
func _on_mutation_requested(pos, data):
	var new_turtle = turtle_scene.instantiate()
	new_turtle.data = data
	new_turtle.global_position = pos
	$TurtleContainer.add_child(new_turtle)
