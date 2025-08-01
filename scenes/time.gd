extends Label

func _process(delta: float) -> void:
	text = get_time()


func get_time() -> String:
	var minute = int(Time.get_datetime_dict_from_system()["minute"])
	var hour = int(Time.get_datetime_dict_from_system()["hour"])
	var minute_text = "0" if minute < 10 else ""
	minute_text += str(minute)
	var am_pm = "AM" if hour < 12 else "PM"
	var hour_text = str(hour) if hour <= 12 else str(hour - 12)
	return hour_text + ":" + minute_text + "  " + am_pm
