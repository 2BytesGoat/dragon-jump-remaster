extends Panel


func show_stats(stats: Dictionary) -> void:
	%TimeLabel.text = Utils.format_time(stats.get("time", 0.0))
	%ResetsLabel.text = str(stats.get("restarts", 1) - 1)
	%CrownDroppedLabel.text = str(stats.get("crowns_dropped", 0))
	self.visible = true
