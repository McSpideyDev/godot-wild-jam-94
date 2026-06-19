extends Node

signal request_mutation(pos: Vector2, data: TurtleData)
signal spawn_loot_visual(pos: Vector2, loot: LootData)

var active_drag_target: Turtle = null
