extends "res://scripts/duel_bot.gd"














signal dm_hit(attacker: Node3D, victim: Node3D, amount: float, zone: String, 
	lethal: bool, weapon: String)

var dm_targets: Array[Node3D] = []




var dm_name: = ""

var _dm_query: PhysicsRayQueryParameters3D


func set_dm_name(nick: String) -> void :
	dm_name = nick.strip_edges().to_upper()
	if _label != null and not dm_name.is_empty():
		_label.text = dm_name




func set_dm_targets(targets: Array) -> void :
	dm_targets.clear()
	for target in targets:
		if target == self or target == null:
			continue
		if target is Node3D and is_instance_valid(target):
			dm_targets.append(target as Node3D)
	if not _dm_alive(player):
		player = _dm_nearest_alive()


func _dm_alive(target: Variant) -> bool:
	if not (target is Node3D) or not is_instance_valid(target):
		return false
	if target == self:
		return false
	if target.has_method("is_alive"):
		return bool(target.call("is_alive"))
	return bool(target.get("alive"))




func _dm_guarded(target: Variant) -> bool:
	if not (target is Node3D) or not is_instance_valid(target):
		return false
	return bool((target as Node3D).get_meta("dm_guard", false))


func _dm_nearest_alive() -> Node3D:
	var best: Node3D = null
	var best_distance: = INF
	for target in dm_targets:
		if not _dm_alive(target) or _dm_guarded(target):
			continue
		var distance: = global_position.distance_squared_to(target.global_position)
		if distance < best_distance:
			best_distance = distance
			best = target
	return best




func _physics_process(delta: float) -> void :
	if alive and ( not _dm_alive(player) or _dm_guarded(player)):
		player = _dm_nearest_alive()
	super._physics_process(delta)





func _ray(from: Vector3, to: Vector3) -> Dictionary:
	if _dm_query == null:
		_dm_query = PhysicsRayQueryParameters3D.new()
		_dm_query.collision_mask = 1 | 8
		_dm_query.exclude = [get_rid()]
		_dm_query.collide_with_areas = false
		_dm_query.collide_with_bodies = true
	_dm_query.from = from
	_dm_query.to = to
	return get_world_3d().direct_space_state.intersect_ray(_dm_query)





func _update_perception(delta: float) -> void :
	if not _visible:
		_last_seen_time += delta
	_reaction_timer = maxf(_reaction_timer - delta, 0.0)
	_perception_timer -= delta
	if _perception_timer > 0.0:
		return
	_perception_timer = PERCEPTION_INTERVAL
	_was_visible = _visible
	var spot: = _dm_spot_target()
	_visible = bool(spot.get("visible", false))
	if _visible:
		_visible_height = float(spot.get("height", 1.22))
		if not _was_visible:
			_reaction_timer = _reaction_time * randf_range(0.88, 1.22)\
			+ randf_range(0.0, 0.05)
			_aim_visual = Vector3(
				randf_range(-0.1, 0.1), 
				randf_range(-0.035, 0.035), 
				randf_range(-0.1, 0.1))
		if player != null and is_instance_valid(player):
			_last_seen = player.global_position
			_last_seen_time = 0.0
	else:
		_aim_settle = 0.0


func _dm_spot_target() -> Dictionary:
	var from: = global_position + Vector3.UP * _eye_height
	var forward: = _forward_direction()
	var best: Node3D = null
	var best_distance: = INF
	var best_height: = 1.22
	for target in dm_targets:
		if not _dm_alive(target) or _dm_guarded(target):
			continue
		var base: = target.global_position
		var distance: = from.distance_to(base)
		if distance >= best_distance:
			continue
		for offset in BODY_SAMPLES:
			var point: = base + Vector3.UP * float(offset)
			var to_target: = point - from
			if to_target.length_squared() > 1.44:
				if rad_to_deg(forward.angle_to(to_target.normalized()))\
				> VIEW_HALF_ANGLE:
					continue
			var result: = _ray(from, point)
			if result.is_empty():
				continue
			if result.get("collider") == target:
				best = target
				best_distance = distance
				best_height = float(offset)
				break
	if best != null:
		player = best
		return {"visible": true, "height": best_height}
	if not _dm_alive(player) or _dm_guarded(player):
		player = _dm_nearest_alive()
	return {"visible": false, "height": 1.22}





func _shoot(aim: Vector3) -> void :
	_recoil = 1.0
	var spread: = _shot_spread
	var direction: = (aim + Vector3(
		randf_range( - spread, spread), 
		randf_range( - spread, spread), 
		randf_range( - spread, spread))).normalized()
	var from: = global_position + Vector3.UP * _eye_height
	var result: = _ray(from, from + direction * 90.0)
	var end: = from + direction * 90.0
	var victim: Node3D = null
	var hit_position: = end
	if not result.is_empty():
		end = result.get("position", end)
		hit_position = end
		victim = _dm_victim(result.get("collider"))
	_spawn_tracer(_muzzle.global_position if _muzzle != null else from, end)
	Sfx.play_bot_shot(_muzzle.global_position if _muzzle != null else from)

	if victim != null and victim.has_method("take_damage"):
		_miss_streak = 0
		var relative: = hit_position.y - victim.global_position.y
		var zone: = "body"
		if relative < 0.88:
			zone = "legs"
		elif relative > 1.46:
			zone = "head"
		var damage: = _damage_for_zone(zone)
		var lethal: bool = damage >= float(victim.get("health"))
		dm_hit.emit(self, victim, damage, zone, lethal, weapon_id)
		victim.call("take_damage", damage, global_position)
	else:
		_miss_streak += 1
		var retreat_chance: = clampf(
			0.28 + 0.12 * float(_miss_streak) + 0.25 * _skill_t, 0.0, 0.92)
		if randf() < retreat_chance:
			_retreat_timer = maxf(_retreat_timer, randf_range(0.18, 0.45))


func _dm_victim(collider: Variant) -> Node3D:
	if not (collider is Node3D):
		return null
	var node: = collider as Node3D
	if node == self:
		return null
	if node.has_method("is_alive") and not bool(node.call("is_alive")):
		return null

	if _dm_guarded(node):
		return null
	if node == player or dm_targets.has(node):
		return node
	return null




func reset_round(spawn: Vector3) -> void :
	super.reset_round(spawn)
	collision_mask = 1 | 8
