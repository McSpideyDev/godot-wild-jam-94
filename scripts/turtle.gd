class_name Turtle extends CharacterBody2D

@export var data: TurtleData

enum State { WANDERING, DRAGGED }
var current_state: State = State.WANDERING

var target_position: Vector2
var wander_bounds: Rect2
var is_mouse_over: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var wander_timer: Timer = $WanderTimer
@onready var merge_detector: Area2D = $MergeDetector

func _ready() -> void:
	if data:
		sprite.texture = data.texture
	
	var moveArea = get_tree().get_first_node_in_group("area")
	if moveArea:
		wander_bounds = moveArea.get_global_rect()
		
		wander_timer.timeout.connect(_pick_new_target)
		_pick_new_target()
	
func _physics_process(delta: float) -> void:
	match current_state:
		State.WANDERING:
			_handle_wandering(delta)
		State.DRAGGED:
			_handle_dragging()
	
func _handle_wandering(delta):
	if global_position.distance_to(target_position) < 10:
		_pick_new_target()
	
	velocity = global_position.direction_to(target_position) * data.move_speed
	move_and_slide()
	
	global_position.x = clamp(global_position.x, wander_bounds.position.x, wander_bounds.end.x)
	global_position.y = clamp(global_position.y, wander_bounds.position.y, wander_bounds.end.y)

func _handle_dragging():
	global_position = get_global_mouse_position()

func _pick_new_target():
	var rx = randf_range(wander_bounds.position.x, wander_bounds.end.x)
	var ry = randf_range(wander_bounds.position.y, wander_bounds.end.y)
	target_position = Vector2(rx, ry)
	
	wander_timer.wait_time = randf_range(1.0, 4.0) 
	wander_timer.start()


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		print("Mouse clicked on turtle!")
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			current_state = State.DRAGGED
			z_index = 10
			wander_timer.stop()

	
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and current_state == State.DRAGGED:
			current_state = State.WANDERING
			z_index = 0
			
			if not check_for_merge():
				_pick_new_target()

func check_for_merge() -> bool:
	var bodies = merge_detector.get_overlapping_bodies()
	for body in bodies:
		if body is Turtle and body != self:
			if body.data.tier == self.data.tier and self.data.next_tier != null:
				perform_merge(body)
				return true
	return false

func perform_merge(other_turtle: Turtle):
	var spawn_pos = other_turtle.global_position
	var next_data = self.data.next_tier
	
	other_turtle.queue_free()
	self.queue_free()
	
	GameEvents.emit_signal("request_mutation", spawn_pos, next_data)
	
	
	
	
	
