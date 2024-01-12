extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func celebrate():
	animation_player.play("Celebrate")

func _on_Celebration_ended():
	queue_free()
