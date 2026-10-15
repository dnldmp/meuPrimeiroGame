extends CharacterBody2D

enum PlayerState {
	idle,
	walk,
	jump,
	fall,
	duck
}

@onready var animated: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

const SPEED = 60
const JUMP_VELOCITY = -300.0

var jump_count = 0
@export var max_jump_count = 2
var status: PlayerState
var direction = 0

func _ready() -> void:
	go_to_idle_state()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	match status:
		PlayerState.idle:
			idle_state()
		PlayerState.walk:
			walk_state()
		PlayerState.jump:
			jump_state()
		PlayerState.fall:
			fall_state()
		PlayerState.duck:
			duck_state()
		
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
	collision_shape.shape.size.y = 10
	collision_shape.position.y = 3

func exit_from_duck_state():
	collision_shape.shape.size.y = 14
	collision_shape.position.y = 1

func idle_state():
	if !is_on_floor():
		jump_count += 1
		return go_to_fall_state()
	
	move()
	if velocity.x != 0:
		return go_to_walk_state()
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		return go_to_jump_state()
	
	if Input.is_action_pressed("ui_down"):
		return go_to_duck_state()

func walk_state():
	if !is_on_floor():
		jump_count += 1
		return go_to_fall_state()
	
	move()
	if velocity.x == 0:
		return go_to_idle_state()
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		return go_to_jump_state()

func jump_state():
	move()
	
	if Input.is_action_just_pressed("jump") && can_jump():
		return go_to_jump_state()
		
	if velocity.y > 0:
		return go_to_fall_state()

func fall_state():
	move()
	
	if Input.is_action_just_pressed("jump") && can_jump():
		return go_to_jump_state()
	
	if is_on_floor():
		jump_count = 0
		if velocity.x != 0:
			return go_to_walk_state()
		return go_to_idle_state()

func duck_state():
	update_direction()
	if Input.is_action_just_released("ui_down"):
		exit_from_duck_state()
		return go_to_idle_state()

func move():
	update_direction()
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func update_direction():
	direction = Input.get_axis("ui_left", "ui_right")
	
	if direction < 0:
		animated.flip_h = true
	elif direction > 0:
		animated.flip_h = false

func can_jump() -> bool:
	return jump_count < max_jump_count
