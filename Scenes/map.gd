@tool
extends Node3D

@export_group("Terrain")
@export var terrainNoise: NoiseTexture2D
@export var xLength := 1000.
@export var yLength := 1000.
@export var xPoints := 1000
@export var yPoints := 1000
@export var height := 250.
@export_tool_button("Terrain Gen", "PrismMesh") var terrainGenExport = genTerrain

@export_group("Clutter")
@export_subgroup("Static")
@export var staticMeshes: Array[PackedScene]
@export_subgroup("Dynamic")
@export var dynamicMeshes: Array[PackedScene]
@export_subgroup("")
@export_tool_button("Clutter Gen", "CylinderMesh") var clutterGenExport = genClutter

@export_group("General")
@export_tool_button("Full Gen", "MultiMeshInstance3D") var genAllExport = genAll #reload project if adding a tool button (its a bug)
@export_tool_button("Cleanup Children", "Remove") var removeAllExport = removeAll

var terrainNode: MeshInstance3D
const terrainNodeName = "Terrain Mesh"
var terrainMat = StandardMaterial3D.new()

#safely set terrain mesh ensuring it exists in scene
func setTerrainMesh(mesh: Mesh):
	if terrainNode == null:
		terrainNode = MeshInstance3D.new()
		terrainNode.name = terrainNodeName
		get_children(true).all(func(node): print("removed ", node); node.queue_free())
		add_child(terrainNode)
		print("terrain node init")
	terrainNode.mesh = mesh
	print("set terrain mesh")

func genTerrain():
	var startTime = Time.get_ticks_usec()
	
	if terrainNoise == null:
		print("terrain noise null")
		return
	
	var img = terrainNoise.get_image() #gets copy of data (from texture on gpu)
	var imgW = img.get_width()
	var imgH = img.get_height()
	
	var st = SurfaceBuilder.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(terrainMat)
	
	## Prepare attributes for add_vertex.
	#st.set_normal(Vector3(0, 0, 1))
	#st.set_uv(Vector2(0, 0))
	#st.set_color(Color(1, 0, 0))
	## Call last for each vertex, adds the above attributes.
	#st.add_vertex(Vector3(-1, -1, 0))
#
	#st.set_normal(Vector3(0, 0, 1))
	#st.set_uv(Vector2(0, 1))
	#st.set_color(Color(1, 0, 0))
	#st.add_vertex(Vector3(-1, 1, 0))
#
	#st.set_normal(Vector3(0, 0, 1))
	#st.set_uv(Vector2(1, 1))
	#st.set_color(Color(1, 0, 0))
	#st.add_vertex(Vector3(1, 1, 0))
	
	st.add_triangles([Vector3(-1, -1, 0), Vector3(-1, 1, 0), Vector3(1, 1, 0)],
					[Vector3(0, 0, 1), Vector3(0, 0, 1), Vector3(0, 0, 1)],
					[Vector2(0, 0), Vector2(0, 1), Vector2(1, 1)],
					[Color(1, 0, 0), Color(0, 1, 0), Color(0, 0, 1)])
	
	st.generate_normals()
	st.index()
	# TESTING BY CREATING SINGLE TRIANGLE
	
	#for x in range(0, imgW + 1):
		#for z in range(0, imgH + 1):
			#var v = Vector3(x, img.get_pixel(clamp(x, 0, imgW - 1), clamp(z, 0, imgH - 1)).r * height, z)
			#
			#var uv = Vector2()
			#uv.x = inverse_lerp(0, imgW, x) #percent value between 0 & xSize
			#uv.y = inverse_lerp(0, imgH, z)
			#st.set_uv(uv)
			#
			#st.add_vertex(v)
	
	#create indexes for triangles
	#var vert = 0
	#for x in range(0, imgW):
		#for z in range(0, imgH):
			#st.add_index(vert + 0)
			#st.add_index(vert + 1)
			#st.add_index(vert + imgW + 1)
			#st.add_index(vert + imgW + 1)
			#st.add_index(vert + 1)
			#st.add_index(vert + imgW + 2)
			#vert += 1
		#vert += 1
	#st.generate_normals()
	
	var arrMesh: ArrayMesh = st.commit()
	setTerrainMesh(arrMesh)
	
	var timeTaken = Time.get_ticks_usec() - startTime
	@warning_ignore("integer_division")
	print("terrain generated in {0}msec ({1}usec)".format([floor(timeTaken / 1000), timeTaken]))

func genClutter():
	print("clutter")

func genAll():
	genTerrain()
	genClutter()
	print("all")

#removes all children nodes
func removeAll():
	var children = get_children(true)
	for node in children:
		remove_child(node)
		node.queue_free()
	print("removed children: ", children if children.size() < 10 else children.size())

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	terrainMat.vertex_color_use_as_albedo = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
