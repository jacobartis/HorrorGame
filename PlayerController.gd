extends KinematicBody

signal health_changed(new_health)
signal player_dead()

export var health: float = 100.0
export var move_speed: float = 3
export var jump_height: float = 8.0
export var acceleration: float = 50
export var gravity: float = .25
export var mouse_sensitivity: float = 0.08
export var sprint_multiplier: float = 2
export var stamina: float = 100

export var camera_path: NodePath
export var player_path: NodePath
export var raycast_path: NodePath

onready var camera: Node = get_node(camera_path)
onready var player: Node = get_node(player_path)
onready var raycast: Node = get_node(raycast_path)

var velocity: Vector3
var vertical_vector: Vector3

var player_in_control: bool = true

var mouse_status

enum mouse_lock{
	LOCKED = 0,
	UNLOCKED = 1
}

func _ready():
	mouse_status = mouse_lock.LOCKED

func _input(event):
	aim(event)

func _process(_delta):
	mouse_mode()
	interact()

func _physics_process(delta):
	movement(delta)

func movement(delta):
	var movement_direction: Vector3 = Vector3.ZERO
	var current_speed: float = move_speed
	
	if Input.is_action_pressed("move_forward"):
		movement_direction -= transform.basis.z
	elif Input.is_action_pressed("move_backward"):
		movement_direction += transform.basis.z
	
	if Input.is_action_pressed("move_left"):
		movement_direction -= transform.basis.x
	elif Input.is_action_pressed("move_right"):
		movement_direction += transform.basis.x
	
	#Checks if the player can jump (if they're on the floor)
	if is_on_floor() && Input.is_action_pressed("jump"):
		vertical_vector.y = jump_height
	elif not is_on_floor():
		vertical_vector.y -= gravity
	
	if stamina > 0 && Input.is_action_pressed("sprint"):
		current_speed = move_speed*sprint_multiplier
	
	if player_in_control:
		#Sets movement vector
		movement_direction = movement_direction.normalized()
		velocity = velocity.linear_interpolate(movement_direction*current_speed, acceleration * delta)
		velocity = move_and_slide(velocity, Vector3.UP)
		move_and_slide(vertical_vector, Vector3.UP)
		
		#changes camera position
		camera.translation = player.translation + Vector3.UP

#Handles moving the camera with the mouse
func aim(event):
	var mouse_motion = event as InputEventMouseMotion
	if player_in_control:
		if mouse_motion && mouse_status == mouse_lock.LOCKED:
			var current_tilt = camera.rotation_degrees.x
			camera.rotation_degrees.y -= mouse_motion.relative.x * mouse_sensitivity
			current_tilt -= mouse_motion.relative.y * mouse_sensitivity
			camera.rotation_degrees.x = clamp(current_tilt, -90, 90)
			player.rotation_degrees.y = camera.rotation_degrees.y

#Handles mouse mode operations
func mouse_mode():
	#Swaps the mouse mode if the toggle_mouse button is pressed
	if Input.is_action_just_pressed("toggle_mouse"):
		mouse_status = (mouse_status + 1)%2
	
	#Checks the current mouse status and sets the mode accordingly
	match mouse_status:
		mouse_lock.LOCKED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		mouse_lock.UNLOCKED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func interact():
	
	if Input.is_action_just_pressed("interact"):
		var target: Object = raycast.get_collider()
		if target != null && target.is_in_group("Note"):
			target.being_read = true
			print (1)
		print (target)

func take_damage(damage):
	health = clamp(health - damage, 0, 100)
	if health > 0:
		emit_signal("health_changed", health)
	else:
		emit_signal("player_dead")


func _on_Area_body_entered(body):
	if body.is_in_group("Player"):
		take_damage(5)


func _on_Player_player_dead():
	player_in_control = false
