class_name Predator
extends CharacterBody3D


const SPEED = 20.0
const ANGLE = PI

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var brain := PackedFloat32Array()
var reaction := 0
var age := 0.0

@onready var Self: PackedScene = preload("res://predator.tscn")


func add_brain(parent: PackedFloat32Array) -> void:
	brain = Globals.mutate_brain(parent)


func procreate() -> Predator:
	var child: Predator = null
	if get_parent().can_create_more_predators():
		child = Self.instantiate()
		child.position.x = position.x
		child.position.z = position.z
		child.position.y = 2.0
		child.rotate_y(randf() * TAU)
		child.add_brain(brain)
	return child


func _ready() -> void:
	collision_layer = 5
	collision_mask = 1
	scale = Vector3.ONE * 0.8
	var parent := get_parent()
	parent.new_predator.emit()
	self.tree_exited.connect(func(): parent.predator_has_died.emit())
	%AnimationPlayer.speed_scale = 10
	if brain.is_empty():
		for _i in 58:
			brain.append(1.0 - randf()*2.0)


func _process(delta: float) -> void:
	if randf() < 0.8:
		age += delta

	if age >= 30 and randf() < 0.25:
		call_deferred("queue_free")
		return

	if global_position.y < -5 or global_position.y > 5:
		call_deferred("queue_free")

	if global_position.y > 0.5:
		reaction = 1
		return

	var i0 := 1.0 if %RayCast1.is_colliding() else 0.0
	var i1 := 1.0 if %RayCast2.is_colliding() else 0.0
	var i2 := 1.0 if %RayCast3.is_colliding() else 0.0
	var i3 := 1.0 if %RayCast4.is_colliding() else 0.0
	var i4 := 1.0 if %RayCast5.is_colliding() else 0.0
	var i5 := 1.0 if %RayCastFloor.is_colliding() else 0.0

	# Genes from 49 to 52 are initiative ones, they count as always-triggered inputs for the first neuron layer
	var a0 := 1.0 if 0.0 < i0 * brain[0] + i1 * brain[1] + i2 * brain[2] + i3 * brain[3] + i4 * brain[4] + i5 * brain[5] + brain[6]  else 0.0
	var a1 := 1.0 if 0.0 < i0 * brain[7] + i1 * brain[8] + i2 * brain[9] + i3 * brain[10] + i4 * brain[11] + i5 * brain[12] + brain[13] else 0.0
	var a2 := 1.0 if 0.0 < i0 * brain[14] + i1 * brain[15] + i2 * brain[16] + i3 * brain[17] + i4 * brain[18] + i5 * brain[19] + brain[20] else 0.0
	var a3 := 1.0 if 0.0 < i0 * brain[21] + i1 * brain[22] + i2 * brain[23] + i3 * brain[24] + i4 * brain[25] + i5 * brain[26] + brain[27] else 0.0

	var b0 := 1.0 if 0.0 < a0 * brain[28] + a1 * brain[29] + a2 * brain[30] + a3 * brain[31] else 0.0
	var b1 := 1.0 if 0.0 < a0 * brain[32] + a1 * brain[33] + a2 * brain[34] + a3 * brain[35] else 0.0
	var b2 := 1.0 if 0.0 < a0 * brain[36] + a1 * brain[37] + a2 * brain[38] + a3 * brain[39] else 0.0

	var c0 := 1.0 if 0.0 < b0 * brain[40] + b1 * brain[41] + b2 * brain[42] else 0.0
	var c1 := 1.0 if 0.0 < b0 * brain[43] + b1 * brain[44] + b2 * brain[45] else 0.0
	var c2 := 1.0 if 0.0 < b0 * brain[46] + b1 * brain[47] + b2 * brain[48] else 0.0

	var o0 := 1 if 0.0 < c0 * brain[49] + c1 * brain[50] + c2 * brain[51] else 0
	var o1 := 2 if 0.0 < c0 * brain[52] + c1 * brain[53] + c2 * brain[54] else 0
	var o2 := 4 if 0.0 < c0 * brain[55] + c1 * brain[56] + c2 * brain[57] else 0

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


func _on_claw_body_entered(body: Prey) -> void:
	if body:
		body.queue_free()
		age = 0.0
		if scale.x < 2.0:
			scale *= 1.0625

		if randf() < 0.5:
			var child := procreate()
			if child:
				get_parent().add_child(child)
