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


func _ready() -> void:
	collision_layer = 5
	collision_mask = 1
	scale = Vector3.ONE * 0.8
	var parent := get_parent()
	parent.new_predator.emit()
	self.tree_exited.connect(func(): parent.predator_has_died.emit())
	%AnimationPlayer.speed_scale = 10
	if brain.is_empty():
		for _i in 53:
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

	# Neurons from 49 to 52 are initiative neurons, they count as always-triggered inputs
	var a0: float = max(0, i0 * brain[0] + i1 * brain[1] + i2 * brain[2] + i3 * brain[3] + i4 * brain[4] + brain[49])
	var a1: float = max(0, i0 * brain[5] + i1 * brain[6] + i2 * brain[7] + i3 * brain[8] + i4 * brain[9] + brain[50])
	var a2: float = max(0, i0 * brain[10] + i1 * brain[11] + i2 * brain[12] + i3 * brain[13] + i4 * brain[14] + brain[51])
	var a3: float = max(0, i0 * brain[15] + i1 * brain[16] + i2 * brain[17] + i3 * brain[18] + i4 * brain[19] + brain[52])

	var b0: float = max(0, a0 * brain[20] + a1 * brain[21] + a2 * brain[22] + a3 * brain[23])
	var b1: float = max(0, a0 * brain[24] + a1 * brain[25] + a2 * brain[26] + a3 * brain[27])
	var b2: float = max(0, a0 * brain[28] + a1 * brain[29] + a2 * brain[30] + a3 * brain[31])

	var c0: float = max(0, b0 * brain[32] + b1 * brain[33] + b2 * brain[34])
	var c1: float = max(0, b0 * brain[35] + b1 * brain[36] + b2 * brain[37])
	var c2: float = max(0, b0 * brain[38] + b1 * brain[39] + b2 * brain[39])

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
		velocity = Vector3.FORWARD.rotated(Vector3.UP, rotation.y) * SPEED
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

		if randf() < 0.5 and get_parent().can_create_more_predators():
			var child: Predator = Self.instantiate()
			child.position.x = position.x
			child.position.z = position.z
			child.position.y = 2.0
			child.rotate_y(randf() * TAU)
			child.add_brain(brain)
			get_parent().add_child(child)
