extends MeshInstance3D

var width = 10  # Width of the terrain
var length = 10  # Length of the terrain
var heightScale = 5  # Scale factor for terrain height

func _ready():
	pass
	#generateTerrain()
#
#func generateTerrain():
	#var noiseGenerator = preload("res://NoiseGenerator.gd").new()
	#var mesh = get_mesh()
	#var surfaceTool = SurfaceTool.new()
	#surfaceTool.begin(Mesh.PRIMITIVE_TRIANGLES)
	#
	#for x in range(width):
		#for z in range(length):
			#var height = noiseGenerator.noise(x * 0.1, z * 0.1) * heightScale  # Adjust parameters for desired terrain
			#surfaceTool.add_vertex(Vector3(x, height, z))
	#
	#for x in range(width - 1):
		#for z in range(length - 1):
			#var i = x * width + z
			#surfaceTool.add_index(i)
			#surfaceTool.add_index(i + width)
			#surfaceTool.add_index(i + 1)
			#
			#surfaceTool.add_index(i + 1)
			#surfaceTool.add_index(i + width)
			#surfaceTool.add_index(i + width + 1)
	#
	#surfaceTool.index()
	#mesh.create_from_surface_tool(surfaceTool)
