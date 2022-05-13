extends Spatial

export var closeWaitTime: float = 2.0
export var openWaitTime: float = 5.0

onready var anim: AnimationPlayer = get_node("AnimationPlayer")
onready var timeMarker: float = get_time()
onready var status: = WAITING

enum {
	WAITING,
	CLOSED,
	OPENED
}

func _process(delta):
	closingAnim()
	openingAnim()

func closingAnim():
	
	if status != WAITING:
		return
	
	if get_time()-timeMarker < closeWaitTime:
		return
	
	status = CLOSED
	timeMarker = get_time()
	anim.play("Close")

func openingAnim():
	
	if status != CLOSED:
		return
	
	if get_time()-timeMarker < openWaitTime:
		return
	
	status = OPENED
	anim.play("Open")

func get_time():
	return OS.get_ticks_msec() / 1000.0
