extends "res://characters/characters.gd"

var look:String
var movement:String
var player_animation:String

func _ready() -> void:
	$player_animated_sprite.play("idle_top")

func _physics_process(delta: float) -> void:
	move_and_slide()
	look = update_gaze()
	player_animation = update_animation()
	animate_player()
	update_deplacement()

func is_getting_closer() -> bool:
	# TODO - ne fonctione pas de bottom left à top left (tout le côté gauche quoi)
	if look.contains("r") and movement.contains("l"):
		return false
	elif look.contains("top") and movement.contains("bot"):
		return false
	elif look.contains("bot") and movement.contains("top"):
		return false
	return true

### ---------------- DEBUT ANIMATION ---------------- ###
## DEBUT fonctions pour mettre à jour la POSITION DU REGARD du joueur
func update_gaze() -> String:
	var mouse_position: Vector2 = get_global_mouse_position()
	var player_gaze = abs(rad_to_deg(position.angle_to_point(mouse_position)))
	
	if player_gaze < 22.5 or player_gaze > 157.5 :
		return handle_horizontal_look(mouse_position)
	elif 67.5 < player_gaze and player_gaze < 112.5:
		return handle_vertical_look(mouse_position)
	else:
		return handle_corner_look(player_gaze, mouse_position)

func handle_horizontal_look(mouse_position) -> String:
	if mouse_position.x < position.x :
		return "left"
	return "right"

func handle_vertical_look(mouse_position) -> String:
	if mouse_position.y < position.y :
		return "top"
	return "bot"

func handle_corner_look(player_gaze, mouse_position) -> String:
	var is_looking_up:bool = mouse_position.y < position.y
	if 112.5 < player_gaze and player_gaze < 157.5:
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

## DEBUT fonctions pour mettre à jour l'ANIMATION DU JOUEUR du joueur
func update_animation() -> String:
	var movement_type:String = "idle"
	var is_getting_closer = is_getting_closer()
	if Input.is_action_pressed("player_run_animation") and not Input.is_key_pressed(KEY_SHIFT):
		if is_getting_closer:
			movement_type = "run"
		else:
			movement_type = "run_backward"
	elif Input.is_action_pressed("player_run_animation") and Input.is_key_pressed(KEY_SHIFT):
		movement_type = "walk"
	return movement_type
## FIN fonctions pour mettre à jour l'ANIMATION DU JOUEUR du joueur

# joue l'animation defini par le regard et les touches
func animate_player() -> void:
	$player_animated_sprite.play(player_animation+"_"+look)
### ---------------- FIN ANIMATION ---------------- ###
#######################################################
### ---------------- DEBUT MOVEMENT ---------------- ###
func update_deplacement() -> void:
	if player_animation == "run":
		run()
	elif player_animation == "walk":
		walk()
	else:
		velocity.y = lerp(velocity.y, 0.00, FRICTION)
		velocity.x = lerp(velocity.x, 0.00, FRICTION)

func run():
	## vertical run
	if Input.is_action_pressed("player_run_up") and not Input.is_action_pressed("player_run_down"):
		movement = "top"
		velocity.y = clamp(velocity.y - RUN_SPEED, - RUN_MAX_SPEED, 0)
	elif Input.is_action_pressed("player_run_down") and not Input.is_action_pressed("player_run_up"):
		movement = "bot"
		velocity.y = clamp(velocity.y + RUN_SPEED, 0, RUN_MAX_SPEED)
	
	## horizontal run
	if Input.is_action_pressed("player_run_right") and not Input.is_action_pressed("player_run_left"):
		movement = "right"
		velocity.x = clamp(velocity.x + RUN_SPEED, 0, RUN_MAX_SPEED)
	elif Input.is_action_pressed("player_run_left") and not Input.is_action_pressed("player_run_right"):
		movement = "left"
		velocity.x = clamp(velocity.x - RUN_SPEED, - RUN_MAX_SPEED, 0)
	
	## update corner movement information
	if velocity.y > 0 and velocity.x > 0 :
		movement = "br" #bottom right
	elif velocity.y < 0 and velocity.x < 0 :
		movement = "tl" #top left
	elif velocity.y > 0 and velocity.x < 0 :
		movement = "bl" #bottom right
	elif velocity.y < 0 and velocity.x > 0:
		movement = "tr" #top right

func walk():
	## vertical walk
	if Input.is_action_pressed("player_walk_up") and not Input.is_action_pressed("player_walk_down"):
		velocity.y = clamp(velocity.y - WALK_SPEED, - WALK_MAX_SPEED, 0)
	elif Input.is_action_pressed("player_walk_down") and not Input.is_action_pressed("player_walk_up"):
		velocity.y = clamp(velocity.y + WALK_SPEED, 0, WALK_MAX_SPEED)
	
	## horizontal walk
	if Input.is_action_pressed("player_walk_right") and not Input.is_action_pressed("player_walk_left"):
		velocity.x = clamp(velocity.x + WALK_SPEED, 0, WALK_MAX_SPEED)
	elif Input.is_action_pressed("player_walk_left") and not Input.is_action_pressed("player_walk_right"):
		velocity.x = clamp(velocity.x - WALK_SPEED, - WALK_MAX_SPEED, 0)
### ---------------- FIN MOVEMENT ---------------- ###
