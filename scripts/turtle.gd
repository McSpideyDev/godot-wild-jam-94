class_name Turtle extends CharacterBody2D

@export var data: TurtleData

enum State { WANDERING, DRAGGED }
var current_state: State = State.WANDERING

var target_position: Vector2
var wander_bounds: Rect2
var is_mouse_over: bool = false

var is_stepping: bool = false
@export var hop_time: float = 0.5
@export var time_between_steps: float = 0.8

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
	
	if is_stepping:
		velocity = global_position.direction_to(target_position) * data.move_speed
	else:
		velocity = Vector2.ZERO	
	
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
	
	_animate_hop()
	

func _animate_hop():
	if current_state == State.DRAGGED: return
	
	if global_position.distance_to(target_position) < 20: 
		is_stepping = false
		return 
	
	sprite.flip_h = target_position.x < global_position.x
	is_stepping = true
	
	var tween = create_tween().set_parallel(true)
	
	tween.tween_property(sprite, "scale", Vector2(0.9, 1.1), hop_time * 0.5)
	tween.tween_property(sprite, "position:y", -8, hop_time * 0.5)
	
	await tween.finished
	
	var tween_land = create_tween().set_parallel(true)
	tween_land.tween_property(sprite, "scale", Vector2(1.1, 0.9), hop_time * 0.5)
	tween_land.tween_property(sprite, "position:y", 0, hop_time * 0.5)
	
	is_stepping = false
	
	await tween_land.finished
	
	var tween_reset = create_tween()
	tween_reset.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)
	await tween_reset.finished
	


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if GameEvents.active_drag_target == null:
				GameEvents.active_drag_target = self
				
				current_state = State.DRAGGED
				sprite.texture = data.texture_picked
				z_index = 10
				wander_timer.stop()

	
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and current_state == State.DRAGGED:
			GameEvents.active_drag_target = null
			
			current_state = State.WANDERING
			sprite.texture = data.texture
			z_index = 0
			
			if not check_for_merge():
				_pick_new_target()
				
func _exit_tree():
	if GameEvents.active_drag_target == self:
		GameEvents.active_drag_target = null

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
	
	
	
	
	
