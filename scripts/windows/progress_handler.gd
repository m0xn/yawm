extends "base_window.gd"

var base_info: String

func init(progress_info: StringName) -> void:
	%ProgressInfoLB.text = tr(progress_info)
	base_info = progress_info

func update_progress(current: int, total: int, new_progress_info: String = "", element_being_processed: String = "") -> void:
	%ProgressInfoLB.text = "%s... (%d/%d)" % [base_info if new_progress_info == "" else tr(new_progress_info), current, total]

	if element_being_processed == "":
		%ElementBeingProcessedLB.hide()

	%ElementBeingProcessedLB.text = element_being_processed
	%ProgressBarPB.value = current / (total as float) * 100
