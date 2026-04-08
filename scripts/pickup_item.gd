extends Node3D
## 拾えるアイテム（武器など）のスクリプト
## ゆっくり回転して目立たせる。Eキーで拾える。

# アイテム名（エディタのインスペクタから設定可能）
@export var item_name: String = "アイテム"

# 回転速度（ラジアン/秒）
const ROTATION_SPEED: float = 1.5

# 上下に浮遊する動き
var _base_y: float = 0.0
var _time: float = 0.0
const FLOAT_AMPLITUDE: float = 0.15
const FLOAT_SPEED: float = 2.0


func _ready() -> void:
	_base_y = position.y


func _process(delta: float) -> void:
	# Y軸で回転
	rotate_y(ROTATION_SPEED * delta)

	# 上下にふわふわ浮く
	_time += delta
	position.y = _base_y + sin(_time * FLOAT_SPEED) * FLOAT_AMPLITUDE


func interact() -> void:
	## プレイヤーがEキーで呼び出すメソッド
	print("「%s」を拾いました！" % item_name)
	queue_free()
