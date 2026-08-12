@tool
extends Node3D

@export_tool_button("test") var test_action = run
@export_tool_button("cleanup") var cleanup_action = cleanup
@export var enable_forest: bool = true

@export_category("Terrain Settings")
@export var height_noise: Noise
@export var terrain_size: Vector2 = Vector2(200, 200)
@export var subdivisions: int = 150
@export var height_scale: float = 25.0

@export_category("Forest Settings")
@export var forest_noise: Noise
@export var tree_mesh: Mesh
@export var tree_count: int = 3000

#var height_noise: FastNoiseLite
#var forest_noise: FastNoiseLite

func run() -> void:
	print("run")
	removeAll()
	#_setup_noise()
	_generate_terrain()
	
	if tree_mesh and enable_forest:
		_generate_forest()
	else:
		push_warning("No Tree Mesh assigned! Skipping forest generation.")

func cleanup() -> void:
	print("cleanup")
	removeAll()

#removes all children nodes
func removeAll():
	var children = get_children(true)
	for node in children:
		remove_child(node)
		node.queue_free()
	#print("removed children: ", children if children.size() < 10 else children.size())

func _ready() -> void:
	_setup_noise()
	run()

#hacky skip mesh during save to avoid saving to tscn file
func _notification(what:int) -> void:
	match what:
		NOTIFICATION_EDITOR_PRE_SAVE:
			if terrain_instance: terrain_instance.mesh = null
			if forest_instance: forest_instance.multimesh = null
		NOTIFICATION_EDITOR_POST_SAVE:
			if terrain_instance: terrain_instance.mesh = terrain_mesh
			if forest_instance: forest_instance.multimesh = forest_multimesh

func _setup_noise() -> void:
	# Noise for the terrain heightmap
	height_noise = FastNoiseLite.new()
	height_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	height_noise.seed = randi()
	height_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	height_noise.frequency = 0.005
	height_noise.fractal_octaves = 5

	# Noise for tree distribution (creates natural clusters/groves)
	forest_noise = FastNoiseLite.new()
	forest_noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	forest_noise.seed = randi() + 1
	forest_noise.frequency = 0.02

var terrain_instance: MeshInstance3D
var terrain_mesh: Mesh
func _generate_terrain() -> void:
	# 1. Create a flat base plane
	var plane := PlaneMesh.new()
	plane.size = terrain_size
	plane.subdivide_width = subdivisions
	plane.subdivide_depth = subdivisions

	# 2. Extract surface data to modify vertices
	var st := SurfaceTool.new()
	st.create_from(plane, 0)
	var array_mesh := st.commit()
	
	var mdt := MeshDataTool.new()
	mdt.create_from_surface(array_mesh, 0)

	# 3. Apply noise to vertex Y positions
	for i in range(mdt.get_vertex_count()):
		var vertex := mdt.get_vertex(i)
		var noise_val := height_noise.get_noise_2d(vertex.x, vertex.z)
		# Smooth out the valleys, elevate the hills
		#vertex.y = maxf(0.0, noise_val) * height_scale
		vertex.y = noise_val * height_scale
		mdt.set_vertex(i, vertex)

	# 4. Rebuild the mesh and calculate accurate normals for lighting
	array_mesh.clear_surfaces()
	mdt.commit_to_surface(array_mesh)
	
	st.clear()
	st.create_from(array_mesh, 0)
	st.generate_normals()
	array_mesh = st.commit()

	# 5. Add terrain to the scene
	terrain_instance = MeshInstance3D.new()
	terrain_mesh = array_mesh
	
	terrain_instance.mesh = terrain_mesh
	add_child(terrain_instance)
	terrain_instance.owner = get_tree().edited_scene_root #makes visible in scene dock

var forest_instance: MultiMeshInstance3D
var forest_multimesh: MultiMesh
func _generate_forest() -> void:
	# MultiMesh is crucial for rendering thousands of trees performantly
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.instance_count = tree_count
	multimesh.mesh = tree_mesh

	var valid_trees := 0

	for i in range(tree_count):
		# Pick a random spot within the terrain boundaries
		var x := randf_range(-terrain_size.x / 2, terrain_size.x / 2)
		var z := randf_range(-terrain_size.y / 2, terrain_size.y / 2)

		# Use the cellular noise map to determine if a tree should grow here (clustering)
		var density := forest_noise.get_noise_2d(x, z)
		#if density < 0.15:
			#continue # Skip this tree to create clearings/paths

		# Get the terrain height at this specific (X, Z) coordinate
		var noise_val := height_noise.get_noise_2d(x, z)
		#var y := maxf(0.0, noise_val) * height_scale
		var y = noise_val * height_scale

		# Prevent trees from spawning underwater or on perfectly flat lowlands
		#if y < 1.5:
			#continue

		var transform2 = Transform3D().translated(Vector3(x, y, z))

		# Add realistic variation to scale and rotation
		var random_scale := randf_range(0.8, 1.6)
		transform2 = transform2.scaled_local(Vector3(random_scale, random_scale, random_scale))
		transform2 = transform2.rotated_local(Vector3.UP, randf_range(0, TAU))

		multimesh.set_instance_transform(valid_trees, transform2)
		valid_trees += 1

	# Optimize memory by shrinking the visible count to only the successfully placed trees
	multimesh.visible_instance_count = valid_trees

	forest_instance = MultiMeshInstance3D.new()
	forest_multimesh = multimesh
	
	forest_instance.multimesh = forest_multimesh
	add_child(forest_instance)
	forest_instance.owner = get_tree().edited_scene_root #makes visible in scene dock
