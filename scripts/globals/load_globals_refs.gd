extends Control

@export var global_nodes: Dictionary[String, Node]

func _enter_tree() -> void:
	Global.nodes = global_nodes
