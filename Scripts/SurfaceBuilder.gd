class_name SurfaceBuilder
extends SurfaceTool
## Extends [SurfaceTool] with additional helper functions.

## Adds an array of triangles data to currently being constructed surface.
func add_triangles(positions: Array[Vector3], normals: Array[Vector3], uvs: Array[Vector2], colours: Array[Color]):
	var posSize = positions.size()
	var norSize = normals.size()
	var uvsSize = uvs.size()
	var colSize = colours.size()
	
	# add all triangles to surface
	for i in range(posSize):
		# somewhat optional
		if i < norSize: self.set_normal(normals[i])
		if i < uvsSize: self.set_uv(uvs[i])
		if i < colSize: self.set_color(colours[i])
		# always needed to properly create mesh
		self.add_vertex(positions[i])
