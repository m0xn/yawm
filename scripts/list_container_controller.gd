class_name ListContainer extends VBoxContainer

@export var item_res: PackedScene

var item_count := 0

func add_item(mod_fn: Callable) -> void:
	var item = item_res.instantiate()
	add_child(item)
	mod_fn.call(item)
	item_count += 1

func remove_item(item_ref: Node) -> void:
	remove_child(item_ref)
	item_count -= 1

func process_items(mod_fn: Callable) -> void:
	var processed_items = 0

	for instance in get_children():
		await mod_fn.call(instance, processed_items)
		processed_items += 1
