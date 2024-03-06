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


func procreate() -> void:
	var parent := get_parent()
	if parent.can_create_more_preys():
		scale = Vector3.ONE * 0.8
		var child: Prey = Self.instantiate()
		child.position.x = position.x
		child.position.z = position.z
		child.position.y = 2.0
		child.rotate_y(randf() * TAU)
		child.add_brain(brain)
		parent.add_child(child)


func _ready() -> void:
	collision_layer = 3
	collision_mask = 1
	scale = Vector3.ONE * 0.6
	var parent := get_parent()
	parent.new_prey.emit()
	self.tree_exited.connect(func(): parent.prey_has_died.emit())
	%AnimationPlayer.speed_scale = 10
	if brain.is_empty():
		for _i in 57:
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
		procreate()

	var i0 := 1.0 if %RayCast1.is_colliding() else 0.0
	var i1 := 1.0 if %RayCast2.is_colliding() else 0.0
	var i2 := 1.0 if %RayCast3.is_colliding() else 0.0
	var i3 := 1.0 if %RayCast4.is_colliding() else 0.0
	var i4 := 1.0 if %RayCast5.is_colliding() else 0.0
	var i5 := 1.0 if %RayCast6.is_colliding() else 0.0
	var i6 := 1.0 if %RayCast7.is_colliding() else 0.0

	var a0 := 1.0 if 0.0 < i0 * brain[0] + i1 * brain[1] + i2 * brain[2] + i3 * brain[3] + i4 * brain[4] + i5 * brain[49] + i6 * brain[53] else 0.0
	var a1 := 1.0 if 0.0 < i0 * brain[5] + i1 * brain[6] + i2 * brain[7] + i3 * brain[8] + i4 * brain[9] + i5 * brain[50] + i6 * brain[54] else 0.0
	var a2 := 1.0 if 0.0 < i0 * brain[10] + i1 * brain[11] + i2 * brain[12] + i3 * brain[13] + i4 * brain[14] + i5 * brain[51] + i6 * brain[55] else 0.0
	var a3 := 1.0 if 0.0 < i0 * brain[15] + i1 * brain[16] + i2 * brain[17] + i3 * brain[18] + i4 * brain[19] + i5 * brain[52] + i6 * brain[56] else 0.0

	var b0:= 1.0 if 0.0 < a0 * brain[20] + a1 * brain[21] + a2 * brain[22] + a3 * brain[23] else 0.0
	var b1:= 1.0 if 0.0 < a0 * brain[24] + a1 * brain[25] + a2 * brain[26] + a3 * brain[27] else 0.0
	var b2:= 1.0 if 0.0 < a0 * brain[28] + a1 * brain[29] + a2 * brain[30] + a3 * brain[31] else 0.0

	var c0:= 1.0 if 0.0 < b0 * brain[32] + b1 * brain[33] + b2 * brain[34] else 0.0
	var c1:= 1.0 if 0.0 < b0 * brain[35] + b1 * brain[36] + b2 * brain[37] else 0.0
	var c2:= 1.0 if 0.0 < b0 * brain[38] + b1 * brain[39] + b2 * brain[39] else 0.0

	var o0 := 1 if 0.0 < c0 * brain[40] + c1 * brain[41] + c2 * brain[42] else 0
	var o1 := 2 if 0.0 < c0 * brain[43] + c1 * brain[44] + c2 * brain[45] else 0
	var o2 := 4 if 0.0 < c0 * brain[46] + c1 * brain[47] + c2 * brain[48] else 0

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
