class_name TurtleData extends Resource

@export var tier: int = 1
@export var species_name: String = "Scrap Turtle"
@export var texture: Texture2D
@export var texture_picked: Texture2D
@export var move_speed: float = 20.0
@export var base_value: float = 10.0
@export var explosion_time: float = 10.0
@export var materials_yield: Dictionary = {"Scrap": 5}
@export var next_tier: TurtleData
@export var loot_pool: Array[LootData] = []
@export var drop_interval_min: float = 5.0
@export var drop_interval_max: float = 10.0
