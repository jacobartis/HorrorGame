extends Spatial

export var lightStrength: float = 0.5
export var flickerInterval: float = 1

onready var light: Node = get_node("SpotLight")
onready var timeStamp: float = get_time()

var status = ON
var rand = RandomNumberGenerator.new()

enum {
	ON,
	OFF,
	FLICKERING
}

func _process(delta):
	checkStatus()

func checkStatus():
	match status:
		ON:
			light.light_energy = lightStrength
		OFF:
			light.light_energy = 0
		FLICKERING:
			flicker()

func flicker():
	
	rand.randomize()
	
	if get_time() - timeStamp < rand.randf_range(0,flickerInterval):
		return
	
	if light.light_energy == 0:
		light.light_energy = lightStrength
	else:
		light.light_energy = 0
	
	timeStamp = get_time()

func get_time():
	return OS.get_ticks_msec() / 1000.0
