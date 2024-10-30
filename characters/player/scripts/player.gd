extends "res://characters/characters.gd"

var look:String
var movement:String
var player_animation:String
var mouse_position: Vector2
var player_gaze: float
var recorded_distance: float
var reverse_move_animation: bool

func _ready() -> void:
	$player_animated_sprite.play("idle_top")

func _physics_process(_delta: float) -> void:
	move_and_slide()
	look = update_gaze()
	player_animation = update_animation()
	mouse_position = get_global_mouse_position()
	player_gaze = rad_to_deg(position.angle_to_point(mouse_position))
	animate_player()
	update_deplacement()

### ---------------- DEBUT POSITION DU REGARD ---------------- ###
func update_gaze() -> String:
	if abs(player_gaze) < 22.5 or abs(player_gaze) > 157.5 :
		return handle_horizontal_look()
	elif 67.5 < abs(player_gaze) and abs(player_gaze) < 112.5:
		return handle_vertical_look()
	else:
		return handle_corner_look()

func handle_horizontal_look() -> String:
	return "left" if mouse_position.x < position.x else "right"

func handle_vertical_look() -> String:
	return "top" if mouse_position.y < position.y else "bot"

func handle_corner_look() -> String:
	var is_looking_up:bool = mouse_position.y < position.y
	if 112.5 < abs(player_gaze) and abs(player_gaze) < 157.5:
		return "tl" if is_looking_up else "bl"
	else:
		return "tr" if is_looking_up else "br"
### ---------------- FIN POSITION DU REGARD ---------------- ###
#######################################################
### ---------------- DEBUT ANIMATION ---------------- ###
# --------- DEBUT DEPLACEMENT
func update_animation() -> String:
	var is_walking = Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_CTRL)
	
	if Input.is_action_pressed("player_deplacement_animation"):
		return walk_animation() if is_walking else run_animation()
	return idle_animation()

func run_animation() -> String:
	if Input.is_action_pressed("player_go_away"):
		return "run_backward"
	elif Input.is_action_pressed("player_strafe_left"):
		return "strafeL"
	elif Input.is_action_pressed("player_strafe_right"):
		return "strafeR"
	return "run"

func walk_animation() -> String:
	return "walk_crouch" if Input.is_key_pressed(KEY_CTRL) else "walk"

func idle_animation() -> String:
	return "crouch_idle" if Input.is_key_pressed(KEY_CTRL) else "idle"
# --------- FIN DEPLACEMENT
# --------- DEBUT ESQUIVE
# TODO - réduire la hitbox en cas de crouch
# TODO - roulade
# TODO - salto
# TODO - slide
# --------- FIN ESQUIVE

# --------- joue l'animation defini par le regard et les touches
func animate_player() -> void:
	if reverse_move_animation :
		$player_animated_sprite.play_backwards(player_animation+"_"+look)
	else:
		$player_animated_sprite.play(player_animation+"_"+look)
### ---------------- FIN ANIMATION ---------------- ###
#######################################################
### ---------------- DEBUT MOUVEMENT ---------------- ###
# --------- DEBUT DEPLACEMENT
func update_deplacement() -> void:
	var deplacement_speed:float
	var max_deplacement_speed:float
	reverse_move_animation = Input.is_action_pressed("player_go_away") and player_animation.contains("walk")
	
	# setup de la vitesse de déplacement
	match player_animation:
		"run", "run_backward", "strafeL", "strafeR" :
			deplacement_speed = RUN_SPEED
			max_deplacement_speed = RUN_MAX_SPEED
		"walk", "walk_crouch" :
			deplacement_speed = WALK_SPEED
			max_deplacement_speed = WALK_MAX_SPEED
	
	if Input.is_action_pressed("player_go_towards") or Input.is_action_pressed("player_go_away"):
		move_forward_or_backward(max_deplacement_speed)
	elif Input.is_action_pressed("player_strafe_right") or Input.is_action_pressed("player_strafe_left"):
		if global_position.distance_to(mouse_position) > recorded_distance:
			velocity = global_position.direction_to(mouse_position) * max_deplacement_speed
		move_strafe(deplacement_speed, max_deplacement_speed)
	else:
		velocity.y = lerp(velocity.y, 0.00, FRICTION)
		velocity.x = lerp(velocity.x, 0.00, FRICTION)

func move_forward_or_backward(max_deplacement_speed) -> void:
	if Input.is_action_pressed("player_go_towards") and not Input.is_action_pressed("player_go_away"):
		velocity = global_position.direction_to(mouse_position) * max_deplacement_speed
	elif Input.is_action_pressed("player_go_away") and not Input.is_action_pressed("player_go_towards"):
		velocity = - global_position.direction_to(mouse_position) * max_deplacement_speed
	recorded_distance = global_position.distance_to(mouse_position)

func move_strafe(deplacement_speed, max_deplacement_speed) -> void:
	if Input.is_action_pressed("player_strafe_right") and not Input.is_action_pressed("player_strafe_left"):
		if player_gaze > -22.5 and player_gaze < 22.5 :
			velocity.y = clamp(velocity.y + deplacement_speed, 0, max_deplacement_speed)
		elif player_gaze > -67.5 and player_gaze < -22.5 :
			velocity.x = clamp(velocity.x + deplacement_speed, 0, max_deplacement_speed)
			velocity.y = clamp(velocity.y + deplacement_speed, 0, max_deplacement_speed)
		elif player_gaze > -112.5 and player_gaze < -67.5 :
			velocity.x = clamp(velocity.x + deplacement_speed, 0, max_deplacement_speed)
		elif player_gaze > -157.5 and player_gaze < -112.5 :
			velocity.x = clamp(velocity.x + deplacement_speed, 0, max_deplacement_speed)
			velocity.y = clamp(velocity.y - deplacement_speed, - max_deplacement_speed, 0)
		elif player_gaze < 67.5 and player_gaze > 22.5 :
			velocity.x = clamp(velocity.x - deplacement_speed, - max_deplacement_speed, 0)
			velocity.y = clamp(velocity.y + deplacement_speed, 0, max_deplacement_speed)
		elif player_gaze < 112.5 and player_gaze > 67.5 :
			velocity.x = clamp(velocity.x - deplacement_speed, - max_deplacement_speed, 0)
		elif player_gaze < 157.5 and player_gaze > 112.5 :
			velocity.x = clamp(velocity.x - deplacement_speed, - max_deplacement_speed, 0)
			velocity.y = clamp(velocity.y - deplacement_speed, - max_deplacement_speed, 0)
		elif player_gaze < -157.5 or player_gaze > 157.5 :
			velocity.y = clamp(velocity.y - deplacement_speed, - max_deplacement_speed, 0)
	elif Input.is_action_pressed("player_strafe_left") and not Input.is_action_pressed("player_strafe_right"):
		if player_gaze > -22.5 and player_gaze < 22.5 :
			velocity.y = clamp(velocity.y - deplacement_speed, - max_deplacement_speed, 0)
		elif player_gaze > -67.5 and player_gaze < -22.5 :
			velocity.x = clamp(velocity.x - deplacement_speed, - max_deplacement_speed, 0)
			velocity.y = clamp(velocity.y - deplacement_speed, - max_deplacement_speed, 0)
		elif player_gaze > -112.5 and player_gaze < -67.5 :
			velocity.x = clamp(velocity.x - deplacement_speed, - max_deplacement_speed, 0)
		elif player_gaze > -157.5 and player_gaze < -112.5 :
			velocity.x = clamp(velocity.x - deplacement_speed, - max_deplacement_speed, 0)
			velocity.y = clamp(velocity.y + deplacement_speed, 0, max_deplacement_speed)
		elif player_gaze < 67.5 and player_gaze > 22.5 :
			velocity.x = clamp(velocity.x + deplacement_speed, 0, max_deplacement_speed)
			velocity.y = clamp(velocity.y - deplacement_speed, - max_deplacement_speed, 0)
		elif player_gaze < 112.5 and player_gaze > 67.5 :
			velocity.x = clamp(velocity.x + deplacement_speed, 0, max_deplacement_speed)
		elif player_gaze < 157.5 and player_gaze > 112.5 :
			velocity.x = clamp(velocity.x + deplacement_speed, 0, max_deplacement_speed)
			velocity.y = clamp(velocity.y + deplacement_speed, 0, max_deplacement_speed)
		elif player_gaze < -157.5 or player_gaze > 157.5 :
			velocity.y = clamp(velocity.y + deplacement_speed, 0, max_deplacement_speed)
# --------- FIN DEPLACEMENT
# --------- DEBUT ESQUIVE
# TODO - réduire la hitbox en cas de crouch
# TODO - roulade
# TODO - salto
# TODO - slide
# --------- FIN ESQUIVE
### ---------------- FIN MOUVEMENT ---------------- ###
