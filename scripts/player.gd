extends CharacterBody3D
## 三人称視点（TPS）プレイヤーコントローラー
## WASD移動、マウスカメラ操作、ジャンプ、アイテムインタラクション

# 移動パラメータ
const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5
const MOUSE_SENSITIVITY: float = 0.003

# 重力（プロジェクト設定から取得）
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# ノード参照（_readyで取得）
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var ray_cast: RayCast3D = $InteractionRay


func _ready() -> void:
	# マウスカーソルを画面中央にロック
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	# マウス移動 → カメラ回転
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# 左右回転（プレイヤー全体を回す）
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		# 上下回転（カメラピボットだけ回す、上下80度に制限）
		camera_pivot.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera_pivot.rotation.x = clampf(camera_pivot.rotation.x, deg_to_rad(-80), deg_to_rad(80))

	# Escキーでマウスカーソル解放 / クリックで再ロック
	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Eキーでインタラクション
	if event.is_action_pressed("interact"):
		_try_interact()


func _physics_process(delta: float) -> void:
	# 重力を適用
	if not is_on_floor():
		velocity.y -= gravity * delta

	# ジャンプ
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 入力方向を取得（WASD / 矢印キー）
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	# カメラの向きを基準に移動方向を計算
	var direction: Vector3 = Vector3.ZERO
	direction += transform.basis.x * input_dir.x
	direction += -transform.basis.z * input_dir.y
	direction.y = 0
	direction = direction.normalized()

	# 移動を適用
	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		# 入力がないときは減速して停止
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _try_interact() -> void:
	## レイキャストで前方のオブジェクトを検出し、interact()を呼ぶ
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		# 親ノードにpickup_item.gdがアタッチされているか確認
		var target = collider.get_parent()
		if target.has_method("interact"):
			target.interact()
