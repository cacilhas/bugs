extends Node

const TH32 = 1. / 32.
const TH64 = 1. / 64.


func mutate_brain(brain: PackedFloat32Array) -> PackedFloat32Array:
	var child = PackedFloat32Array()
	for gene in brain:
		child.append(mutate_gene(gene))
	return child


func mutate_gene(gene: float) -> float:
	if randf() < TH32:
		return gene - randf() * TH64
	return gene


func random_position(radius: float) -> Vector3:
	var res := Vector3.FORWARD * randf() * radius
	return res.rotated(Vector3.UP, randf() * TAU)
