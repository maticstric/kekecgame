extends Node

var DEBUG = false

var cur_time

func _process(_delta):
	cur_time = Time.get_ticks_msec()
