extends Control

signal retry

func _on_Retry_pressed():
	emit_signal("retry")

func _on_Menu_pressed():
	get_tree().change_scene("res://Menu.tscn")
