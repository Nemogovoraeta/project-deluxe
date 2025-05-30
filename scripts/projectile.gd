class_name Projectile extends CharacterBody3D

@export var explosion_scene: PackedScene

var time: float = 0.0

# To be set by the item
var stats: ProjectileStats

var current_height: float = 0.0

@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var mesh: Node3D = $Mesh

func _enter_tree() -> void:
	global_position = stats.position
	global_rotation = stats.rotation

func _on_collision():
	call_deferred("set_process_mode", ProcessMode.PROCESS_MODE_DISABLED)
	mesh.hide()
	explosion_particles.emitting = true
	if explosion_scene:
		var explosion_node = explosion_scene.instantiate()
		explosion_node.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(explosion_node)

func _physics_process(delta: float) -> void:
	var prev_height = current_height
	time += delta * stats.speed
	var displacement = time * stats.distance
	var next_height = Globals.projectile_arc(displacement, stats.distance, stats.height, stats.offset)
	var height_offset = next_height - prev_height
	current_height = next_height
	var collision = move_and_collide(Vector3(0.0, 0.0, delta * stats.distance * stats.speed) * global_basis.inverse() + Vector3(0.0, height_offset, 0.0))
	var is_underwater = global_position.y < BuoyancySolver.height(global_position)
	if collision or is_underwater:
		_on_collision()
