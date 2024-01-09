extends Node2D

@onready var sprite = $AnimatedSprite2D
var is_enemy = false : set = _set_is_enemy, get = _get_is_enemy

func _set_is_enemy(value):
	is_enemy = value
	
	if value == true:
		remove_from_group("Unit")
		add_to_group("Enemy")
		sprite.self_modulate = Color.CRIMSON

func _get_is_enemy():
	return is_enemy
