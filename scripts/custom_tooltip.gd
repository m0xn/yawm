extends Node

func _make_custom_tooltip(for_text: String) -> Object:
	var label = load("res://scenes/custom_components/TooltipLabel.tscn").instantiate()
	label.text = for_text
	return label
