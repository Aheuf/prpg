extends "res://characters/characters.gd"

var look:String
var player_animation:String

func _ready() -> void:
	$player_animated_sprite.play("idle_top")

func _physics_process(delta: float) -> void:
	move_and_slide()
	look = update_gaze()
	player_animation = update_animation()
	animate_player()
	update_deplacement()

### ---------------- DEBUT ANIMATION ---------------- ###
## DEBUT fonctions pour mettre à jour la POSITION DU REGARD du joueur
func update_gaze() -> String:
	var mousePosition: Vector2 = get_global_mouse_position()
	var playerGaze = abs(rad_to_deg(position.angle_to_point(mousePosition)))
	
	if playerGaze < 22.5 or playerGaze > 157.5 :
		return handle_horizontal_look(mousePosition)
	elif 67.5 < playerGaze and playerGaze < 112.5:
		return handle_vertical_look(mousePosition)
	else:
		return handle_corner_look(playerGaze, mousePosition)

func handle_horizontal_look(mousePosition) -> String:
	if mousePosition.x < position.x :
		return "left"
	return "right"

func handle_vertical_look(mousePosition) -> String:
	if mousePosition.y < position.y :
		return "top"
	return "bot"

func handle_corner_look(playerGaze, mousePosition) -> String:
	var is_looking_up:bool = mousePosition.y < position.y
	if 112.5 < playerGaze and playerGaze < 157.5:
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
	if Input.is_action_pressed("player_run_animation"):
		return "run"
	elif Input.is_action_pressed("player_walk_animation"):
		return "walk"
	return "idle"
## FIN fonctions pour mettre à jour l'ANIMATION DU JOUEUR du joueur

# joue l'animation defini par le regard et les touches
func animate_player() -> void:
	$player_animated_sprite.play(player_animation+"_"+look)
### ---------------- FIN ANIMATION ---------------- ###

### ---------------- DEBUT MOVEMENT ---------------- ###
func update_deplacement() -> void:
	if player_animation == "run":
		run()
	elif player_animation == "walk":
		walk()


func run():
	## vertical run
	if Input.is_action_pressed("player_run_up") and not Input.is_action_pressed("player_run_down"):
		velocity.y = clamp(velocity.y - RUN_SPEED, - RUN_MAX_SPEED, 0)
	elif Input.is_action_pressed("player_run_down") and not Input.is_action_pressed("player_run_up"):
		velocity.y = clamp(velocity.y + RUN_SPEED, 0, RUN_MAX_SPEED)
	else:
		velocity.y = lerp(velocity.y, 0.00, FRICTION)
	
	## horizontal run
	if Input.is_action_pressed("player_run_right") and not Input.is_action_pressed("player_run_left"):
		velocity.x = clamp(velocity.x + RUN_SPEED, 0, RUN_MAX_SPEED)
	elif Input.is_action_pressed("player_run_left") and not Input.is_action_pressed("player_run_right"):
		velocity.x = clamp(velocity.x - RUN_SPEED, - RUN_MAX_SPEED, 0)
	else:
		velocity.x = lerp(velocity.x, 0.00, FRICTION)

func walk():
	## vertical walk
	if Input.is_action_pressed("player_walk_up") and not Input.is_action_pressed("player_walk_down"):
		velocity.y = clamp(velocity.y - WALK_SPEED, - WALK_MAX_SPEED, 0)
	elif Input.is_action_pressed("player_walk_down") and not Input.is_action_pressed("player_walk_up"):
		velocity.y = clamp(velocity.y + WALK_SPEED, 0, WALK_MAX_SPEED)
	else:
		velocity.y = lerp(velocity.y, 0.00, FRICTION)
	
	## horizontal walk
	if Input.is_action_pressed("player_walk_right") and not Input.is_action_pressed("player_walk_left"):
		velocity.x = clamp(velocity.x + WALK_SPEED, 0, WALK_MAX_SPEED)
	elif Input.is_action_pressed("player_walk_left") and not Input.is_action_pressed("player_walk_right"):
		velocity.x = clamp(velocity.x - WALK_SPEED, - WALK_MAX_SPEED, 0)
	else:
		velocity.x = lerp(velocity.x, 0.00, FRICTION)
### ---------------- FIN MOVEMENT ---------------- ###
