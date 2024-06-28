class_name Prey
extends CharacterBody3D


const SPEED = 15.0
const ANGLE = PI

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var brain := PackedFloat32Array()
var reaction := 0
var age := 0.0

@onready var Self: PackedScene = preload("res://prey.tscn")


func add_brain(parent: PackedFloat32Array) -> void:
	brain = Globals.mutate_brain(parent)


func procreate() -> Prey:
	var child: Prey = null
	if get_parent().can_create_more_preys():
		scale = Vector3.ONE * 0.8
		child = Self.instantiate()
		child.position.x = position.x
		child.position.z = position.z
		child.position.y = 2.0
		child.rotate_y(randf() * TAU)
		child.add_brain(brain)
	return child


func to_dict() -> Dictionary:
	return {
		"brain": brain,
		"reaction": reaction,
		"age": age,
		"position": position,
		"rotation_y": rotation.y,
	}


func load_dict(info: Dictionary) -> void:
	brain = info.brain
	reaction = info.reaction
	age = info.age
	position = info.position
	rotation.y = 0
	rotate_y(info.rotation_y)


func _ready() -> void:
	collision_layer = 3
	collision_mask = 1
	scale = Vector3.ONE * 0.6
	var parent := get_parent()
	parent.new_prey.emit()
	self.tree_exited.connect(func(): parent.prey_has_died.emit())
	%AnimationPlayer.speed_scale = 10
	if brain.is_empty():
		for _i in 54:
			brain.append(1.0 - randf()*2.0)


func _process(delta: float) -> void:
	if randf() < 0.8:
		age += delta
		if scale.x < 1.2:
			scale *= 1.0 + (0.03125 * delta)

	if global_position.y < -5 or global_position.y > 5:
		call_deferred("queue_free")

	if global_position.y > 0.5:
		reaction = 1
		return

	if age >= 30:
		age /= 2.0
		var child := procreate()
		if child:
			get_parent().add_child(child)

	var i0 := 1.0 if %RayCast1.is_colliding() else 0.0
	var i1 := 1.0 if %RayCast2.is_colliding() else 0.0
	var i2 := 1.0 if %RayCast3.is_colliding() else 0.0
	var i3 := 1.0 if %RayCast4.is_colliding() else 0.0
	var i4 := 1.0 if %RayCast5.is_colliding() else 0.0
	var i5 := 1.0 if %RayCastFloor.is_colliding() else 0.0

	var a0 := 1.0 if 0.0 < i0 * brain[0] + i1 * brain[1] + i2 * brain[2] + i3 * brain[3] + i4 * brain[4] + i5 * brain[5] else 0.0
	var a1 := 1.0 if 0.0 < i0 * brain[6] + i1 * brain[7] + i2 * brain[8] + i3 * brain[9] + i4 * brain[10] + i5 * brain[11] else 0.0
	var a2 := 1.0 if 0.0 < i0 * brain[12] + i1 * brain[13] + i2 * brain[14] + i3 * brain[15] + i4 * brain[16] + i5 * brain[17] else 0.0
	var a3 := 1.0 if 0.0 < i0 * brain[18] + i1 * brain[19] + i2 * brain[20] + i3 * brain[21] + i4 * brain[22] + i5 * brain[23] else 0.0

	var b0:= 1.0 if 0.0 < a0 * brain[24] + a1 * brain[25] + a2 * brain[26] + a3 * brain[27] else 0.0
	var b1:= 1.0 if 0.0 < a0 * brain[28] + a1 * brain[29] + a2 * brain[30] + a3 * brain[31] else 0.0
	var b2:= 1.0 if 0.0 < a0 * brain[32] + a1 * brain[33] + a2 * brain[34] + a3 * brain[35] else 0.0

	var c0:= 1.0 if 0.0 < b0 * brain[36] + b1 * brain[37] + b2 * brain[38] else 0.0
	var c1:= 1.0 if 0.0 < b0 * brain[39] + b1 * brain[40] + b2 * brain[41] else 0.0
	var c2:= 1.0 if 0.0 < b0 * brain[42] + b1 * brain[43] + b2 * brain[44] else 0.0

	var o0 := 1 if 0.0 < c0 * brain[45] + c1 * brain[46] + c2 * brain[47] else 0
	var o1 := 2 if 0.0 < c0 * brain[48] + c1 * brain[49] + c2 * brain[50] else 0
	var o2 := 4 if 0.0 < c0 * brain[51] + c1 * brain[52] + c2 * brain[53] else 0

	reaction = o0 | o1 | o2


func _physics_process(delta: float) -> void:
	if reaction & 2 > 0:
		rotate_y(-ANGLE * delta)

	if reaction & 4 > 0:
		rotate_y(ANGLE * delta)

	if reaction & 1 > 0:
		%AnimationPlayer.play("Walk")
		var aux = Vector3.FORWARD.rotated(Vector3.UP, rotation.y) * SPEED
		velocity.x = aux.x
		velocity.z = aux.z
	else:
		%AnimationPlayer.pause()
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()
