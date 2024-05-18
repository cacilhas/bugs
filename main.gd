extends Node3D

signal new_predator
signal new_prey
signal predator_has_died
signal prey_has_died


const SPEED := 400

@export var GrassScene: PackedScene

var movement := Vector3.ZERO
var mouse := Vector2.ZERO
var preys_count := 0
var predators_count := 0


func can_create_more_preys() -> bool:
	return preys_count < 1000


func can_create_more_predators() -> bool:
	return predators_count < 1000


func get_matrix() -> Predator:
	for child in get_children():
		if child is Predator:
			return child
	return null


func recreate_creatures() -> void:
	if preys_count == 0:
		for _i in 500:
			add_child(Globals.create_prey())

	var new_predators_count := 100
	if predators_count > 0:
		var matrix := get_matrix()
		if matrix:
			matrix.age = 0.0
			for _i in 49:
				var pred := matrix.procreate()
				pred.position = Globals.random_position(480.0)
				add_child(pred)
			new_predators_count = 50
	for _i in new_predators_count:
		add_child(Globals.create_predator())



func _ready() -> void:
	randomize()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	for _i in 200:
		var grass := GrassScene.instantiate()
		grass.rotate_y(randf() * TAU)
		grass.position = Globals.random_position(500.0)
		grass.scale = Vector3.ONE * (1.2 - randf() * 0.4)
		add_child(grass)

	for i in 500:
		add_child(Globals.create_prey())
		if i % 5 == 0:
			add_child(Globals.create_predator())


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
	if predators_count <= 1:
		recreate_creatures()
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

