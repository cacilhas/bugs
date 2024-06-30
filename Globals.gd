extends Node

const TH32 = 1. / 32.
const TH64 = 1. / 64.
const STORE := "user://data.save"

@onready var PredatorScene: PackedScene = preload("res://predator.tscn")
@onready var PreyScene: PackedScene = preload("res://prey.tscn")


func save_creatures(creatures_: Array, azimuth: float) -> void:
	var creatures := []
	for creature in creatures_:
		creatures.append(creature.to_dict())


	var file := FileAccess.open(STORE, FileAccess.WRITE)
	var info := {"creatures": creatures, "azimuth": azimuth}
	file.store_var(info, false)
	file.close()


func load_creatures() -> Dictionary:
	if not FileAccess.file_exists(STORE):
		return {"creatures": [], "azimuth": 0.0}
	var file := FileAccess.open(STORE, FileAccess.READ)
	var info: Dictionary = file.get_var(false)
	file.close()
	var res := []
	var azimuth = 0.0
	if info.has("azimuth"):
		azimuth = info.azimuth

	for asset in info.creatures:
		if asset.brain.size() == 54:
			var prey: Prey = PreyScene.instantiate()
			prey.load_dict(asset)
			res.append(prey)
		elif asset.brain.size() == 58:
			var predator: Predator = PredatorScene.instantiate()
			predator.load_dict(asset)
			res.append(predator)

	return {
		"creatures": res,
		"azimuth": azimuth,
	}


func create_prey() -> Prey:
	var prey: Prey = PreyScene.instantiate()
	prey.position = random_position(480.0)
	prey.rotate_y(randf() * TAU)
	return prey


func create_predator() -> Predator:
	var pred: Predator = PredatorScene.instantiate()
	pred.position = random_position(480.0)
	pred.rotate_y(randf() * TAU)
	return pred


func mutate_brain(brain: PackedFloat32Array) -> PackedFloat32Array:
	var child = PackedFloat32Array()
	for gene in brain:
		child.append(mutate_gene(gene))
	return child


func mutate_gene(gene: float) -> float:
	if randf() < TH32:
		return gene + TH32 - randf() * TH64
	return gene


func random_position(radius: float) -> Vector3:
	var res := Vector3.FORWARD * randf() * radius
	return res.rotated(Vector3.UP, randf() * TAU)
