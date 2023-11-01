@tool
extends MeshInstance3D

@export var update: bool :
	set(value):
		do_update(value)
	get:
		return scale == Vector3(1,1,1)

func do_update(value):
	if value:
		_update()

func _update():
	var mdt = MeshDataTool.new()
	#will only work with 1 surfcae by now
	mdt.create_from_surface(mesh, 0)

	#step through every vetex of the surface
	for i in range(mdt.get_vertex_count()):
		#multiply position and normal by scale to apply scaling
		var vertex = mdt.get_vertex(i) * scale
		var normal = mdt.get_vertex_normal(i) * scale
		#write it back to the surface
		mdt.set_vertex(i, vertex)
		mdt.set_vertex_normal(i, normal)

	#make a new mesh
	mesh = ArrayMesh.new()
	#commit changes to mesh
	mdt.commit_to_surface( mesh )

	#reset scale to 1
	scale = Vector3(1,1,1)
	#tell the inspector something has changed
	notify_property_list_changed()
