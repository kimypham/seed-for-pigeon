extends RigidBody2D

signal landed(seed)

var shadow: Node2D
var land_time = 1.2  # seconds to land
var elapsed = 0.0
var start_pos: Vector2
var target_pos: Vector2
var landing = true
var shadow_offset = Vector2(40, 40)
var control_point: Vector2

var spin_speed = 0.0
var final_rotation = 0.0

func _ready():
	scale = Vector2(0.2, 0.2)
	freeze = true
	
	shadow = Sprite2D.new()
	shadow.texture = $Sprite2D.texture
	shadow.modulate = Color(0, 0, 0, 0.4)
	shadow.scale = Vector2(1, 0.5)
	add_child(shadow)
	shadow.z_index = 1

func setup(from: Vector2, to: Vector2):
	start_pos = from
	target_pos = to
	position = from
	
	var mid = start_pos.lerp(target_pos, 0.5)
	# Always push control point upward (negative y = up in Godot)
	control_point = mid + Vector2(0, -randf_range(200, 400))
	
	## Random spin while flying
	spin_speed = randf_range(-1, 1)

	## Random final rotation when landed
	final_rotation = randf_range(0.0, TAU)

func quadratic_bezier(a: Vector2, b: Vector2, c: Vector2, t: float) -> Vector2:
	return a.lerp(b, t).lerp(b.lerp(c, t), t)

func _process(delta):
	if not landing:
		return
	
	elapsed += delta
	var t = clamp(elapsed / land_time, 0.0, 1.0)
	
	position = quadratic_bezier(start_pos, control_point, target_pos, t)
	rotation += spin_speed * delta
	#shadow.rotation -rotation
	
	var s = lerp(1.2, 1.0, t)
	scale = Vector2(s, s)
	
	shadow.position = shadow_offset.lerp(Vector2.ZERO, t)
	shadow.modulate.a = lerp(0.4, 0.15, t)
	
	if t >= 1.0:
		landing = false
		freeze = false
		shadow.hide()
		landed.emit(self)
		await get_tree().create_timer(5.0).timeout
		if is_instance_valid(self):  # make sure it wasn't already eaten
			var fade_time = 0.5
			var fade_elapsed = 0.0
			while fade_elapsed < fade_time:
				fade_elapsed += get_process_delta_time()
				modulate.a = lerp(1.0, 0.0, fade_elapsed / fade_time)
				await get_tree().process_frame
			queue_free()

func eaten():
	queue_free()
