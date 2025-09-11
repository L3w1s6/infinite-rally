@tool
extends Node3D

@export var noise: NoiseTexture3D:
	get():
		return noise
	set(value):
		noise = value
		print("Noise set")

var curve: Curve3D

func genCurve(seed:int, noise:NoiseTexture3D):
	pass
