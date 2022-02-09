extends TextureProgress
signal death


func _on_character_took_damage(damage):
	value -= damage
	if value <= 0:
		emit_signal("death")
