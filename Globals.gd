extends Node

const TH32 = 1. / 32.
const TH64 = 1. / 64.


func mutate_brain(brain: PackedFloat32Array) -> PackedFloat32Array:
	var child = PackedFloat32Array()
	for neuron in brain:
		child.append(mutate_neuron(neuron))
	return child


func mutate_neuron(neuron: float) -> float:
	if randf() < TH32:
		return neuron - randf() * TH64
	return neuron


func random_position(radius: float) -> Vector3:
	var res := Vector3.FORWARD * randf() * radius
	return res.rotated(Vector3.UP, randf() * TAU)
