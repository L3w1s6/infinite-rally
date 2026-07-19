@tool
extends MeshInstance3D

@export var xSize = 20: #resolution x
	set(value): xSize = max(value, 0)
@export var zSize = 20: #resolution z
	set(value): zSize = max(value, 0)

@export var drawPoints = true

@export var update = false: #recreate mesh
	get():
		return update
	set(value):
		if value:
			clearPoints()
			genTerrain()
@export var clearVerts = false: #clear all child vertices
	get():
		return clearVerts
	set(value):
		if value:
			clearPoints()
			clearMesh()

var pointsMesh: MultiMeshInstance3D

#create mesh using SurfaceTool
func genTerrain():
	var startTime = Time.get_ticks_usec()
	
	var arrayMesh: ArrayMesh
	var surfTool = SurfaceTool.new()
	var n = FastNoiseLite.new()
	n.noise_type = FastNoiseLite.TYPE_PERLIN
	n.frequency = 0.1
	
	pointsMesh = $MultiPoints
	pointsMesh.multimesh = MultiMesh.new()
	pointsMesh.multimesh.mesh = $Point.mesh
	pointsMesh.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	pointsMesh.multimesh.instance_count = (xSize + 1) * (zSize + 1)
	
	surfTool.begin(Mesh.PRIMITIVE_TRIANGLES)
	#create triangles
	var i: int = 0
	for z in range(zSize + 1):
		for x in range(xSize + 1):
			var y = n.get_noise_2d(x * 0.5, z * 0.5) * 5
			var v = Vector3(x, y, z)
			
			var uv = Vector2()
			uv.x = inverse_lerp(0, xSize, x)#percent value between 0 & xSize
			uv.y = inverse_lerp(0, zSize, z)
			surfTool.set_uv(uv)
			
			surfTool.add_vertex(v)
			if drawPoints: #debug to see all points
				#drawSphere(v)
				drawPointOptimised(pointsMesh.multimesh, x + (z * xSize), v)
				i += 1
	print("i: ", i, " | instance_count: ", pointsMesh.multimesh.instance_count)
	
	#create indexes for triangles
	var vert = 0
	for z in zSize:
		for x in xSize:
			surfTool.add_index(vert + 0)
			surfTool.add_index(vert + 1)
			surfTool.add_index(vert + xSize + 1)
			surfTool.add_index(vert + xSize + 1)
			surfTool.add_index(vert + 1)
			surfTool.add_index(vert + xSize + 2)
			vert += 1
		vert += 1
	surfTool.generate_normals()
	
	arrayMesh = surfTool.commit()
	
	mesh = arrayMesh
	
	var timeTaken = Time.get_ticks_usec() - startTime
	@warning_ignore("integer_division")
	print("mesh generated in {0}msec ({1}usec)".format([floor(timeTaken / 1000), timeTaken]))

#add new sphere mesh as child of this node
func drawSphere(pos: Vector3):
	var ins = MeshInstance3D.new()
	add_child(ins)
	ins.position = pos
	var sphere = SphereMesh.new()
	sphere.radius = .1
	sphere.height = .2
	
	#essentially reducing vertex count
	sphere.rings = 1
	sphere.radial_segments = 1
	
	ins.mesh = sphere

func drawPointOptimised(multiMesh: MultiMesh, index: int, pos: Vector3):
	multiMesh.set_instance_transform(index, Transform3D(Basis.IDENTITY, pos))

#clear all children of node
func clearPoints():
	pointsMesh.multimesh = null

func clearMesh():
	mesh = null

#called once initially
func _ready() -> void:
	genTerrain()
	print("ready")
