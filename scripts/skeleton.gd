extends CharacterBody2D

enum SkeletonState {
	walk,
	attack,
	dead
}

const SPINNING_BONE = preload("res://entities/spinning_bone.tscn")

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var wall_detector: RayCast2D = $WallDetector
@onready var wall_detector_2: RayCast2D = $WallDetector2
@onready var ground_detector: RayCast2D = $GroundDetector
@onready var player_detector: RayCast2D = $PlayerDetector
@onready var bone_start_position: Node2D = $BoneStartPosition

const SPEED = 50
const JUMP_VELOCITY = -400.0

var status: SkeletonState

var direction = 1
var can_throw = true

func _ready() -> void:
	go_to_walk_state()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	match status:
		SkeletonState.walk:
			walk_state(delta)
		SkeletonState.attack:
			attack_state(delta)
		SkeletonState.dead:
			dead_state(delta)
	
	move_and_slide()

func go_to_walk_state():
	status = SkeletonState.walk
	animation.play("walk")

func go_to_attack_state():
	status = SkeletonState.attack
	animation.play("attack")
	velocity = Vector2.ZERO
	can_throw = true

func go_to_dead_state():
	status = SkeletonState.dead
	animation.play("dead")
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED
	velocity = Vector2.ZERO

func walk_state(_delta: float):
	if animation.frame == 3 or animation.frame == 4:	
		velocity.x = SPEED * direction
	else:
		velocity.x = 0

	if wall_detector.is_colliding() || wall_detector_2.is_colliding() || !ground_detector.is_colliding():
		scale.x *= -1
		direction *= -1
	
	if player_detector.is_colliding():
		return go_to_attack_state()

func attack_state(_delta: float):
	if animation.frame == 2 && can_throw:
		throw_bone()
		can_throw = false

func dead_state(_delta: float):
	pass

func take_damage():
	go_to_dead_state()

func throw_bone():
	var new_bone = SPINNING_BONE.instantiate()
	add_sibling(new_bone)
	new_bone.position = bone_start_position.global_position
	new_bone.set_direction(self.direction)

func _on_animated_sprite_2d_animation_finished():
	if animation.animation == "attack":
		return go_to_walk_state()
