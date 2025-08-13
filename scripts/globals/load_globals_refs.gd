extends Control

@export var global_nodes: Dictionary[String, Node]
@export var global_res: Dictionary[String, PackedScene]

func _enter_tree() -> void:
	Global.nodes = global_nodes
	Global.res = global_res

	Utils.Debug.log_msg(Types.DT.INFO, "Succesfully loaded [b]%d static node[/b] references and [b]%d static resources[/b]" % [len(global_nodes), len(global_res)])
	# Utils.Debug.log_msg(Types.DT.ERROR, "There has been an error whilst loading the wallpapers", func (): get_window().queue_free())
