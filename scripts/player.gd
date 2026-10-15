extends CharacterBody2D

enum PlayerState {
	idle,
	walk,
	jump,
	fall,
	duck,
	slide
}

@onready var animated: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

@export var max_jump_count = 2
@export var acceleration = 500
@export var decceleration = 500
@export var max_speed = 100
@export var slide_decceleration = 60

const JUMP_VELOCITY = -300.0

var jump_count = 0
var status: PlayerState
var direction = 0

func _ready() -> void:
	go_to_idle_state()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	match status:
		PlayerState.idle:
			idle_state(delta)
		PlayerState.walk:
			walk_state(delta)
		PlayerState.jump:
			jump_state(delta)
		PlayerState.fall:
			fall_state(delta)
		PlayerState.duck:
			duck_state(delta)
		PlayerState.slide:
			slide_state(delta)
		
	move_and_slide()

func go_to_idle_state():
	status = PlayerState.idle
	animated.play("idle")
	
func go_to_walk_state():
	status = PlayerState.walk
	animated.play("walk")

func go_to_jump_state():
	status = PlayerState.jump
	animated.play("jump")
	velocity.y = JUMP_VELOCITY
	jump_count += 1

func go_to_fall_state():
	status = PlayerState.fall
	animated.play("fall")

func go_to_duck_state():
	status = PlayerState.duck
	animated.play("duck")
	set_small_collider()
	

func exit_from_duck_state():
	set_large_collider()

func go_to_slide_state():
	status = PlayerState.slide
	animated.play("slide")
	set_small_collider()

func exit_from_slide_state():
	set_large_collider()

func idle_state(delta: float):
	move(delta)
	
	check_and_go_to_fall_state()
	
	if velocity.x != 0:
		return go_to_walk_state()
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		return go_to_jump_state()
	
	if Input.is_action_pressed("ui_down"):
		return go_to_duck_state()

func walk_state(delta: float):
	move(delta)
	
	check_and_go_to_fall_state()
	
	if Input.is_action_just_pressed("ui_down"):
		return go_to_slide_state()
	
	if velocity.x == 0:
		return go_to_idle_state()
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		return go_to_jump_state()

func jump_state(delta: float):
	move(delta)
	
	if Input.is_action_just_pressed("jump") && can_jump():
		return go_to_jump_state()
		
	if velocity.y > 0:
		return go_to_fall_state()

func fall_state(delta: float):
	move(delta)
	
	if Input.is_action_just_pressed("jump") && can_jump():
		return go_to_jump_state()
	
	if is_on_floor():
		jump_count = 0
		if velocity.x != 0:
			return go_to_walk_state()
		return go_to_idle_state()

func duck_state(_delta: float):
	update_direction()
	if Input.is_action_just_released("ui_down"):
		exit_from_duck_state()
		return go_to_idle_state()

func slide_state(delta: float):
	velocity.x = move_toward(velocity.x, 0, slide_decceleration * delta)
	
	check_and_go_to_fall_state()
	
	if Input.is_action_just_released("ui_down"):
		exit_from_slide_state()
		return go_to_walk_state()
		
	if velocity.x == 0:
		exit_from_slide_state()
		return go_to_duck_state()

func move(delta: float):
	update_direction()
	
	if direction:
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, decceleration * delta)

func update_direction():
	direction = Input.get_axis("ui_left", "ui_right")
	
	if direction < 0:
		animated.flip_h = true
	elif direction > 0:
		animated.flip_h = false

func can_jump() -> bool:
	return jump_count < max_jump_count

func set_small_collider():
	collision_shape.shape.size.y = 10
	collision_shape.position.y = 3

func set_large_collider():
	collision_shape.shape.size.y = 14
	collision_shape.position.y = 1

func check_and_go_to_fall_state():
	if !is_on_floor():
		jump_count += 1
		return go_to_fall_state()
