extends Node3D

signal new_predator
signal new_prey
signal predator_has_died
signal prey_has_died


const SPEED := 400

@export var GrassScene: PackedScene
@export var PredatorScene: PackedScene
@export var PreyScene: PackedScene

var movement := Vector3.ZERO
var mouse := Vector2.ZERO
var preys_count := 0
var predators_count := 0


func can_create_more_preys() -> bool:
	return preys_count < 1000


func can_create_more_predators() -> bool:
	return predators_count < 1000


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	for _i in 200:
		var grass := GrassScene.instantiate()
		grass.rotate_y(randf() * TAU)
		grass.position = Globals.random_position(500.0)
		grass.scale = Vector3.ONE * (1.2 - randf() * 0.4)
		add_child(grass)

	for i in 500:
		var prey: Prey = PreyScene.instantiate()
		prey.position = Globals.random_position(480.0)
		add_child(prey)
		if i % 5 == 0:
			var pred: Predator = PredatorScene.instantiate()
			pred.position = Globals.random_position(480.0)
			add_child(pred)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse = event.relative

	if Input.is_action_pressed("ui_up"):
		movement += Vector3.FORWARD
	if Input.is_action_pressed("ui_down"):
		movement += Vector3.BACK
	if Input.is_action_pressed("ui_left"):
		movement += Vector3.LEFT
	if Input.is_action_pressed("ui_right"):
		movement += Vector3.RIGHT
	movement = movement.normalized()


func _unhandled_key_input(_event: InputEvent) -> void:
	if Input.is_action_just_released("ui_cancel"):
		get_tree().quit()


func _process(_delta: float) -> void:
	if predators_count == 0 and preys_count > 0:
		for _i in 100:
			var pred: Predator = PredatorScene.instantiate()
			pred.position = Globals.random_position(480.0)
			add_child(pred)

	%PreysCount.text = "%d" % preys_count
	%PredatorsCount.text = "%d" % predators_count


func _physics_process(delta: float) -> void:
	if mouse.x != 0:
		%Camera.rotate_y(-mouse.x/2.0 * delta)
	if mouse.y != 0:
		%Camera.rotate_object_local(Vector3.LEFT, mouse.y/2.0 * delta)
	mouse = Vector2.ZERO

	if movement.length_squared() > 0:
		%Camera.position += movement.rotated(Vector3.UP, %Camera.rotation.y) * SPEED * delta
	movement = Vector3.ZERO



func _on_prey_has_died():
	if preys_count > 0:
		preys_count -= 1


func _on_predator_has_died():
	if predators_count > 0:
		predators_count -= 1


func _on_new_prey():
	preys_count += 1

func _on_new_predator():
	predators_count += 1

