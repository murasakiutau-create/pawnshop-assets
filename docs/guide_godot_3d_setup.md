# Godot 4.x で3Dゲームを作る — セットアップガイド

このガイドでは、このリポジトリに含まれる3Dモデルを使って、
Godot 4.x で三人称視点（TPS）の3Dゲームを動かすまでの手順を解説します。

---

## 目次

1. [プロジェクトの概要](#1-プロジェクトの概要)
2. [Godot でプロジェクトを開く](#2-godot-でプロジェクトを開く)
3. [フォルダ構成](#3-フォルダ構成)
4. [ゲームを実行する](#4-ゲームを実行する)
5. [操作方法](#5-操作方法)
6. [シーンの仕組み](#6-シーンの仕組み)
7. [スクリプトの解説](#7-スクリプトの解説)
8. [3Dモデル（GLB）について](#8-3dモデルglbについて)
9. [カスタマイズしてみよう](#9-カスタマイズしてみよう)
10. [次のステップ](#10-次のステップ)
11. [GDScript チートシート](#11-gdscript-チートシート)

---

## 1. プロジェクトの概要

このプロジェクトには以下が含まれています：

| 種類 | ファイル | 説明 |
|------|---------|------|
| 3Dモデル | `Meshy_AI_Crescentbound_War_Axe_*.glb` | 三日月戦斧 |
| 3Dモデル | `Meshy_AI__0317020019_texture.glb` | 剣のモデル |
| メインシーン | `scenes/main.tscn` | 地面・空・照明・武器が配置された3D空間 |
| プレイヤー | `scenes/player.tscn` | キャラクター（カプセル型） |
| スクリプト | `scripts/player.gd` | 移動・カメラ・ジャンプ・インタラクション |
| スクリプト | `scripts/pickup_item.gd` | アイテムの回転・拾得 |

> **注意:** `sword_mithril_b.glb` はファイルが壊れています（2バイトしかない）。
> このファイルは使用していません。新しいモデルに差し替えるか、削除してください。

---

## 2. Godot でプロジェクトを開く

### 前提条件
- **Godot 4.3 以降** がインストール済みであること
- まだの場合は [godotengine.org](https://godotengine.org/download/) からダウンロード

### 手順

1. **Godot を起動** する
2. プロジェクトマネージャーが表示される
3. **「インポート」** ボタンをクリック
4. このリポジトリのフォルダ内にある **`project.godot`** を選択
5. **「インポート & 編集」** をクリック
6. エディターが開き、プロジェクトが読み込まれる

初回インポート時、Godot が GLB ファイルを自動的にインポートします。
`.godot/` フォルダにキャッシュが作成されますが、`.gitignore` で除外済みです。

---

## 3. フォルダ構成

```
pawnshop-assets/
├── project.godot          ← プロジェクト設定ファイル
├── .gitignore             ← Git除外設定
├── *.glb                  ← 3Dモデルファイル
├── scenes/
│   ├── main.tscn          ← メインシーン（ここからゲーム開始）
│   └── player.tscn        ← プレイヤーシーン
├── scripts/
│   ├── player.gd          ← プレイヤー制御スクリプト
│   └── pickup_item.gd     ← アイテムスクリプト
└── docs/
    └── guide_godot_3d_setup.md  ← このガイド
```

### Godot のルール
- Godot ではすべてのパスが `res://` から始まる（例: `res://scenes/main.tscn`）
- `res://` はプロジェクトのルートフォルダを指す

---

## 4. ゲームを実行する

1. エディター上部の **▶（再生ボタン）** をクリック、または **F5** キーを押す
2. 初回はメインシーンを聞かれるかもしれません → `scenes/main.tscn` を選択
3. ゲームウィンドウが開き、3D空間が表示される

---

## 5. 操作方法

| キー | 動作 |
|------|------|
| **W / ↑** | 前に歩く |
| **S / ↓** | 後ろに歩く |
| **A / ←** | 左に歩く |
| **D / →** | 右に歩く |
| **マウス移動** | カメラ（視点）を回す |
| **Space** | ジャンプ |
| **E** | 目の前のアイテムを拾う |
| **Esc** | マウスカーソルを解放 |
| **クリック** | マウスカーソルを再ロック |

---

## 6. シーンの仕組み

Godot では「シーン」と「ノード」がゲームの基本単位です。

### ノードとは？
ゲーム内のすべてのオブジェクト（カメラ、ライト、キャラクター等）は **ノード** です。
ノードはツリー状に親子関係を持ちます。

### main.tscn の構造

```
Main (Node3D)                    ← ルートノード
├── WorldEnvironment             ← 空と環境光
├── DirectionalLight3D           ← 太陽光（影あり）
├── Ground (StaticBody3D)        ← 地面
│   ├── GroundMesh               ← 地面の見た目（30m x 30m）
│   └── GroundCollision          ← 地面の当たり判定
├── Player (CharacterBody3D)     ← プレイヤー（別シーンから読み込み）
├── WarAxe (Node3D)              ← 戦斧アイテム
│   ├── Model                    ← GLBモデル
│   └── AxeCollision             ← 当たり判定
└── Sword (Node3D)               ← 剣アイテム
    ├── Model                    ← GLBモデル
    └── SwordCollision           ← 当たり判定
```

### player.tscn の構造

```
Player (CharacterBody3D)         ← 物理演算対応キャラクター
├── CollisionShape3D             ← プレイヤーの当たり判定（カプセル）
├── MeshInstance3D               ← プレイヤーの見た目（青いカプセル）
├── CameraPivot (Node3D)         ← カメラの回転軸
│   └── Camera3D                 ← 三人称カメラ（後方に配置）
└── InteractionRay (RayCast3D)   ← アイテム検出用レイ
```

### 重要な3Dノードの種類

| ノード | 役割 |
|--------|------|
| `Node3D` | 3D空間の基本ノード。位置・回転・スケールを持つ |
| `CharacterBody3D` | プレイヤーやNPC用。物理演算で動く |
| `StaticBody3D` | 地面や壁など動かないもの |
| `Camera3D` | カメラ（画面に映る視点） |
| `DirectionalLight3D` | 太陽のような平行光 |
| `MeshInstance3D` | 3Dモデルの表示 |
| `CollisionShape3D` | 当たり判定の形状 |
| `RayCast3D` | 直線状のレイで衝突を検出 |

---

## 7. スクリプトの解説

### player.gd — プレイヤー制御

```gdscript
extends CharacterBody3D
```
このスクリプトは `CharacterBody3D` ノードに付けるもの、という宣言。

#### 定数（変えない値）
```gdscript
const SPEED: float = 5.0           # 移動速度（m/秒）
const JUMP_VELOCITY: float = 4.5   # ジャンプの初速
const MOUSE_SENSITIVITY: float = 0.003  # マウス感度
```

#### _ready() — 初期化
```gdscript
func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
```
ゲーム開始時にマウスカーソルをロック。FPS/TPSゲームでよく使うパターン。

#### _unhandled_input() — 入力処理
マウス移動でカメラ回転、Escでマウス解放、Eキーでインタラクション。

```gdscript
# 左右 → プレイヤー全体を回す
rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
# 上下 → カメラピボットだけ回す（上下80度に制限）
camera_pivot.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
```

#### _physics_process() — 毎フレームの物理処理
1. **重力**: 空中にいるとき下向きの力を加える
2. **ジャンプ**: 地面にいてSpaceが押されたら上方向の速度を設定
3. **移動**: 入力方向をカメラの向きに合わせて変換し、`move_and_slide()` で移動

```gdscript
# カメラの向きを基準に移動方向を計算
var direction: Vector3 = Vector3.ZERO
direction += transform.basis.x * input_dir.x   # 左右
direction += -transform.basis.z * input_dir.y   # 前後
```
`transform.basis` はプレイヤーの向き。マウスで回した方向に合わせて移動します。

### pickup_item.gd — アイテム制御

```gdscript
@export var item_name: String = "アイテム"
```
`@export` を付けると、Godot エディターのインスペクタから値を変更できます。

```gdscript
func _process(delta: float) -> void:
    rotate_y(ROTATION_SPEED * delta)  # Y軸回転
    position.y = _base_y + sin(_time * FLOAT_SPEED) * FLOAT_AMPLITUDE  # 浮遊
```
毎フレーム回転し、sin関数で上下にふわふわ浮く演出。

```gdscript
func interact() -> void:
    print("「%s」を拾いました！" % item_name)
    queue_free()  # このノードをシーンから削除
```
プレイヤーがEキーを押すとこのメソッドが呼ばれ、アイテムが消えます。

---

## 8. 3Dモデル（GLB）について

### GLB形式とは？
**glTF Binary (.glb)** は3Dモデルの標準フォーマットです。
メッシュ（形状）、テクスチャ（模様）、マテリアル（材質）をひとつのファイルにまとめられます。

### Godot での使い方
1. GLBファイルをプロジェクトフォルダに置く
2. Godot が自動的にインポートする
3. シーンにドラッグ&ドロップで配置できる

### Meshy AI について
このリポジトリのモデルは **Meshy AI** で生成されています。
AIテキストから3Dモデルを生成するサービスで、プロトタイプ制作に便利です。

### 壊れたファイルについて
`sword_mithril_b.glb` は **ファイルサイズが2バイト** しかなく、正常なGLBファイルではありません。
Git履歴を見ると、リネーム操作時にデータが失われたようです。

**対処法:**
- 新しいGLBモデルをダウンロードして同じファイル名で置き換える
- または削除する（プロジェクトでは使用していません）

---

## 9. カスタマイズしてみよう

### 移動速度を変える
`scripts/player.gd` を開いて：
```gdscript
const SPEED: float = 5.0  # ← この数値を変える（大きい＝速い）
```

### 地面の大きさを変える
`scenes/main.tscn` をエディターで開き、`Ground` → `GroundMesh` を選択。
インスペクタで `Mesh` → `Size` を変更。

### 新しい3Dモデルを追加する
1. GLBファイルをプロジェクトフォルダに入れる
2. エディターのファイルシステムドックで表示される
3. シーンにドラッグ&ドロップ
4. `pickup_item.gd` をアタッチすれば拾えるようになる

### 空の色を変える
`WorldEnvironment` ノードを選択 → `Environment` → `Sky` の設定を変更。

---

## 10. 次のステップ

ここからゲームを発展させるアイデアです：

### 初級（まずはこれから）
- [ ] プレイヤーの見た目を3Dモデルに差し替える
- [ ] 地面にテクスチャ（模様）を貼る
- [ ] BGMや効果音を追加する
- [ ] UI（画面上のテキスト）を表示する

### 中級
- [ ] インベントリ（持ち物リスト）システムを作る
- [ ] NPC（会話できるキャラ）を追加する
- [ ] 質屋の店内を3Dで作る
- [ ] アイテムの売買システム

### 上級
- [ ] 敵AIを実装する
- [ ] アニメーション付きのキャラクターモデル
- [ ] セーブ/ロード機能
- [ ] ゲームをエクスポート（exe/apk に書き出し）

---

## 11. GDScript チートシート

### 変数
```gdscript
var hp: int = 100              # 整数
var speed: float = 5.0         # 小数
var name: String = "プレイヤー"  # 文字列
var alive: bool = true         # 真偽値
var pos: Vector3 = Vector3(0, 1, 0)  # 3D座標
```

### 定数
```gdscript
const MAX_HP: int = 100  # 変更不可の値
```

### 関数
```gdscript
func greet(name: String) -> void:
    print("こんにちは、" + name)
```

### 条件分岐
```gdscript
if hp <= 0:
    print("ゲームオーバー")
elif hp < 30:
    print("ピンチ！")
else:
    print("元気")
```

### ループ
```gdscript
for i in range(5):
    print(i)  # 0, 1, 2, 3, 4

for item in item_list:
    print(item.name)
```

### よく使う組み込み関数
```gdscript
print("デバッグ出力")           # コンソールに出力
deg_to_rad(90)                  # 度→ラジアン変換
clampf(value, 0.0, 1.0)        # 値を範囲内に制限
move_toward(current, target, delta)  # 値を少しずつ近づける
```

### シグナル（イベント）
```gdscript
# シグナルの定義
signal health_changed(new_hp: int)

# シグナルの発火
health_changed.emit(hp)

# シグナルの接続（他ノードから）
player.health_changed.connect(_on_health_changed)
```

### ノード操作
```gdscript
$ChildNode                    # 子ノードを取得
get_node("../Sibling")        # パスでノードを取得
queue_free()                  # ノードを安全に削除
get_tree().quit()             # ゲーム終了
```

---

## 参考リンク

- [Godot 公式ドキュメント（英語）](https://docs.godotengine.org/en/stable/)
- [Godot 公式チュートリアル: 3Dゲーム入門](https://docs.godotengine.org/en/stable/getting_started/first_3d_game/index.html)
- [GDScript リファレンス](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html)
