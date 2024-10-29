extends "res://characters/characters.gd"

var look:String
var movement:String
var player_animation:String
var mouse_position: Vector2
var player_gaze: float
var recorded_distance: float

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

## DEBUT fonctions pour mettre à jour la POSITION DU REGARD du joueur
func update_gaze() -> String:
	if abs(player_gaze) < 22.5 or abs(player_gaze) > 157.5 :
		return handle_horizontal_look()
	elif 67.5 < abs(player_gaze) and abs(player_gaze) < 112.5:
		return handle_vertical_look()
	else:
		return handle_corner_look()

func handle_horizontal_look() -> String:
	if mouse_position.x < position.x :
		return "left"
	return "right"

func handle_vertical_look() -> String:
	if mouse_position.y < position.y :
		return "top"
	return "bot"

func handle_corner_look() -> String:
	var is_looking_up:bool = mouse_position.y < position.y
	if 112.5 < abs(player_gaze) and abs(player_gaze) < 157.5:
		if is_looking_up:
			return "tl"
		else:
			return "bl"
	else:
		if is_looking_up:
			return "tr"
		else:
			return "br"
## FIN fonctions pour mettre à jour la POSITION DU REGARD du joueur

### ---------------- DEBUT ANIMATION ---------------- ###
## DEBUT fonctions pour mettre à jour l'ANIMATION DU JOUEUR du joueur
func update_animation() -> String:
	if Input.is_action_pressed("player_deplacement_animation") and not Input.is_key_pressed(KEY_SHIFT):
		return run_animation()
	elif Input.is_action_pressed("player_deplacement_animation") and Input.is_key_pressed(KEY_SHIFT):
		return "walk"
	return "idle"

func run_animation() -> String:
	if Input.is_action_pressed("player_go_towards"):
		return "run"
	elif Input.is_action_pressed("player_go_away"):
		return "run_backward"
	return "run"
## FIN fonctions pour mettre à jour l'ANIMATION DU JOUEUR du joueur

# joue l'animation defini par le regard et les touches
func animate_player() -> void:
	$player_animated_sprite.play(player_animation+"_"+look)
### ---------------- FIN ANIMATION ---------------- ###
#######################################################
### ---------------- DEBUT MOVEMENT ---------------- ###
func update_deplacement() -> void:
	var deplacement_speed:float
	var max_deplacement_speed:float
	
	# setup de la vitesse de déplacement
	match player_animation:
		"run", "run_backward" :
			deplacement_speed = RUN_SPEED
			max_deplacement_speed = RUN_MAX_SPEED
		"walk" :
			deplacement_speed = WALK_SPEED
			max_deplacement_speed = WALK_MAX_SPEED
	print(player_animation)
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
### ---------------- FIN MOVEMENT ---------------- ###
