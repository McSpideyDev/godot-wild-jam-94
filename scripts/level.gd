extends Node2D

var wander_bounds: Rect2

@export var turtle_scene: PackedScene
@export var income_item_scene: PackedScene
@export var spawn_table: Dictionary # Key: TurtleData, Value: float (Weight)

@onready var spawn_timer: Timer = $SpawnTimer

func _ready():
	var move_area = $MoveArea 
	if move_area:
		wander_bounds = move_area.get_global_rect()
		
	GameEvents.request_mutation.connect(_on_mutation_requested)
	GameEvents.spawn_loot_visual.connect(_on_loot_requested)
	spawn_timer.timeout.connect(_attempt_spawn)
	spawn_timer.start()
	
func _on_mutation_requested(pos, data):
	var new_turtle = turtle_scene.instantiate()
	new_turtle.data = data
	new_turtle.global_position = pos
	$TurtleContainer.add_child(new_turtle)
	
func _attempt_spawn():
	var current_count = $TurtleContainer.get_child_count()
	
	if current_count < GameStats.max_turtles:
		_spawn_random_turtle()
	
	# Adjust spawn timer based on multiplier for shop upgrades
	spawn_timer.wait_time = 5.0 / GameStats.spawn_speed_multiplier
	
func _spawn_random_turtle():
	var chosen_data = _get_weighted_random_turtle()
	# Reuse your existing mutation logic to spawn a new turtle at a random pen position
	var rx = randf_range(wander_bounds.position.x, wander_bounds.end.x)
	var ry = randf_range(wander_bounds.position.y, wander_bounds.end.y)
	_on_mutation_requested(Vector2(rx, ry), chosen_data)
	
func _get_weighted_random_turtle() -> TurtleData:
	var total_weight = 0.0
	for weight in spawn_table.values():
		total_weight += weight
	
	var roll = randf() * total_weight
	var current_weight = 0.0
	
	for turtle_data in spawn_table.keys():
		current_weight += spawn_table[turtle_data]
		if roll <= current_weight:
			return turtle_data
	return spawn_table.keys()[0] # Fallback

func _on_loot_requested(pos, loot):
	var item = income_item_scene.instantiate()
	item.global_position = pos
	item.value = loot.value
	item.get_node("Sprite2D").texture = loot.texture
	add_child(item)
