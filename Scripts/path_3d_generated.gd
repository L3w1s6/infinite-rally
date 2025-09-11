@tool
extends Path3D

@export var dummy := true:
	get():
		return dummy
	set(value):
		dummy = value
		printerr("HELLO")

var path: Curve3D

# Called when the node enters the scene tree for the first time.
func _ready():
	path.add_point(Vector3(10, 0, 0), Vector3(-1, 0, 0), Vector3(1, 0, 0), 0)
	path.add_point(Vector3(20, 0, 0), Vector3(-1, 0, 0), Vector3(1, 0, 0), 0)
	path.add_point(Vector3(30, 0, 0), Vector3(-1, 0, 0), Vector3(1, 0, 0), 0)
	self.curve = path

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
