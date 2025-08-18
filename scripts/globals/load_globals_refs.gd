extends Control

@export var global_nodes: Dictionary[String, Node]
@export var global_res: Dictionary[String, PackedScene]

func _enter_tree() -> void:
	Global.nodes = global_nodes
	Global.res = global_res
