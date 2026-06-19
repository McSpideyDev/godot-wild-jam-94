extends Node2D

var value: float = 0.0

func _ready():
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 40, 1.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 1.5)
	
	tween.set_parallel(false)
	tween.tween_callback(_on_fade_finished)
	
func _on_fade_finished():
	GameStats.current_money += value * GameStats.income_multiplier
	#TODO: UI visualization
	queue_free()
