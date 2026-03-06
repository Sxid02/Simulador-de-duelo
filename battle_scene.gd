extends Node2D

enum BattleState {
	PLAYER_TURN,
	PLAYER_ACTION,
	ENEMY_TURN,
	BATTLE_END
}

var state = BattleState.PLAYER_TURN

# -----------------------------
# MODELOS POSIBLES DEL JUGADOR
# -----------------------------
var player_classes = [
	{
		"name": "Unidad",
		"class": "tanque",
		"sprite": "res://assets/players/tank_bot_back.png",
		"max_hp": 130,
		"hp": 130,
		"attacks": [
			{"name": "Cañón Pesado", "min": 10, "max": 16},
			{"name": "Impacto Hidráulico", "min": 14, "max": 20},
			{"name": "Golpe de Acero", "min": 12, "max": 18},
			{"name": "Carga Blindada", "min": 16, "max": 22}
		]
	},
	{
		"name": "Unidad",
		"class": "plasma",
		"sprite": "res://assets/players/plasma_bot_back.png",
		"max_hp": 95,
		"hp": 95,
		"attacks": [
			{"name": "Rayo Láser", "min": 14, "max": 20},
			{"name": "Pulso de Plasma", "min": 18, "max": 26},
			{"name": "Descarga Iónica", "min": 13, "max": 19},
			{"name": "Explosión Cuántica", "min": 20, "max": 28}
		]
	},
	{
		"name": "Unidad",
		"class": "asalto",
		"sprite": "res://assets/players/assault_bot_back.png",
		"max_hp": 105,
		"hp": 105,
		"attacks": [
			{"name": "Ráfaga Metálica", "min": 11, "max": 17},
			{"name": "Mordaza Mecánica", "min": 15, "max": 21},
			{"name": "Garra Rotatoria", "min": 13, "max": 19},
			{"name": "Embestida Turbo", "min": 17, "max": 24}
		]
	},
	{
		"name": "Unidad",
		"class": "sigilo",
		"sprite": "res://assets/players/stealth_bot_back.png",
		"max_hp": 85,
		"hp": 85,
		"attacks": [
			{"name": "Corte Láser", "min": 15, "max": 21},
			{"name": "Ataque Fantasma", "min": 17, "max": 24},
			{"name": "Impulso Rápido", "min": 12, "max": 18},
			{"name": "Golpe de Precisión", "min": 20, "max": 30}
		]
	},
	{
		"name": "Unidad",
		"class": "guardian",
		"sprite": "res://assets/players/guardian_bot_back.png",
		"max_hp": 140,
		"hp": 140,
		"attacks": [
			{"name": "Martillo Magnético", "min": 12, "max": 18},
			{"name": "Pulso Defensor", "min": 14, "max": 20},
			{"name": "Escudo de Choque", "min": 10, "max": 16},
			{"name": "Juicio Binario", "min": 18, "max": 26}
		]
	},
	{
		"name": "Unidad",
		"class": "virus",
		"sprite": "res://assets/players/virus_bot_back.png",
		"max_hp": 100,
		"hp": 100,
		"attacks": [
			{"name": "Hackeo Corrupto", "min": 13, "max": 19},
			{"name": "Pulso Malicioso", "min": 16, "max": 23},
			{"name": "Nube de Nanobots", "min": 15, "max": 22},
			{"name": "Invasión de Sistema", "min": 19, "max": 27}
		]
	}
]

var player = {}

# -----------------------------
# LISTA DE ENEMIGOS ROBÓTICOS
# -----------------------------
var enemies = [
	{
		"name": "Drone Chatarra",
		"class": "asalto",
		"sprite": "res://assets/enemies/scrap_drone_front.png",
		"max_hp": 75,
		"hp": 75,
		"attack_min": 8,
		"attack_max": 14
	},
	{
		"name": "Meca Dragón",
		"class": "tanque",
		"sprite": "res://assets/enemies/mecha_dragon_front.png",
		"max_hp": 125,
		"hp": 125,
		"attack_min": 14,
		"attack_max": 22
	},
	{
		"name": "Tecnomante Oscuro",
		"class": "plasma",
		"sprite": "res://assets/enemies/dark_technomancer_front.png",
		"max_hp": 90,
		"hp": 90,
		"attack_min": 12,
		"attack_max": 18
	},
	{
		"name": "Centinela Negro",
		"class": "guardian",
		"sprite": "res://assets/enemies/dark_sentinel_front.png",
		"max_hp": 115,
		"hp": 115,
		"attack_min": 10,
		"attack_max": 17
	},
	{
		"name": "Asesino Óptico",
		"class": "sigilo",
		"sprite": "res://assets/enemies/optic_assassin_front.png",
		"max_hp": 85,
		"hp": 85,
		"attack_min": 15,
		"attack_max": 24
	},
	{
		"name": "Defensor Caído",
		"class": "guardian",
		"sprite": "res://assets/enemies/fallen_guardian_front.png",
		"max_hp": 130,
		"hp": 130,
		"attack_min": 12,
		"attack_max": 21
	},
	{
		"name": "IA Corrupta",
		"class": "virus",
		"sprite": "res://assets/enemies/corrupt_ai_front.png",
		"max_hp": 95,
		"hp": 95,
		"attack_min": 14,
		"attack_max": 23
	}
]

var current_enemy = {}

# -----------------------------
# STATS DE COMBATE
# -----------------------------
var player_hp = 100
var player_max_hp = 100
var enemy_hp = 100
var enemy_max_hp = 100

# -----------------------------
# MÓDULOS Y EFECTOS
# -----------------------------
var shield_active = false
var fury_active = false
var item_used = false

var items = [
	{"name": "Kit de Reparación", "type": "heal", "value": 25},
	{"name": "Granada EMP", "type": "damage", "value": 20},
	{"name": "Campo de Fuerza", "type": "shield", "value": 0},
	{"name": "Overclock", "type": "buff", "value": 1.5}
]

# -----------------------------
# REFERENCIAS A NODOS
# -----------------------------
@onready var lbl_player_name = $CanvasLayer/PlayerName
@onready var lbl_enemy_name = $CanvasLayer/EnemyName
@onready var bar_player_hp = $CanvasLayer/PlayerHP
@onready var bar_enemy_hp = $CanvasLayer/EnemyHP

@onready var dialog_box = $CanvasLayer/DialogBox
@onready var lbl_dialog = $CanvasLayer/DialogBox/DialogLabel
@onready var next_arrow = $CanvasLayer/DialogBox/NextArrow

@onready var btn_attack1 = $CanvasLayer/Menu/BtnAttack1
@onready var btn_attack2 = $CanvasLayer/Menu/BtnAttack2
@onready var btn_attack3 = $CanvasLayer/Menu/BtnAttack3
@onready var btn_attack4 = $CanvasLayer/Menu/BtnAttack4
@onready var btn_item = $CanvasLayer/Menu/BtnItem
@onready var btn_run = $CanvasLayer/Menu/BtnRun

@onready var timer = $Timer
@onready var player_sprite = $PlayerSprite
@onready var enemy_sprite = $EnemySprite

# -----------------------------
# INICIO
# -----------------------------
func _ready():
	randomize()

	select_random_player()
	make_bar_styles_unique()
	select_random_enemy()
	setup_battle_ui()

	btn_attack1.pressed.connect(func(): use_player_attack(0))
	btn_attack2.pressed.connect(func(): use_player_attack(1))
	btn_attack3.pressed.connect(func(): use_player_attack(2))
	btn_attack4.pressed.connect(func(): use_player_attack(3))
	btn_item.pressed.connect(_on_item_pressed)
	btn_run.pressed.connect(_on_run_pressed)

	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)

	next_arrow.text = "▼"
	next_arrow.visible = true

# -----------------------------
# BARRAS INDEPENDIENTES
# -----------------------------
func make_bar_styles_unique():
	var player_fill = bar_player_hp.get_theme_stylebox("fill")
	if player_fill != null:
		bar_player_hp.add_theme_stylebox_override("fill", player_fill.duplicate())

	var enemy_fill = bar_enemy_hp.get_theme_stylebox("fill")
	if enemy_fill != null:
		bar_enemy_hp.add_theme_stylebox_override("fill", enemy_fill.duplicate())

	var player_bg = bar_player_hp.get_theme_stylebox("background")
	if player_bg != null:
		bar_player_hp.add_theme_stylebox_override("background", player_bg.duplicate())

	var enemy_bg = bar_enemy_hp.get_theme_stylebox("background")
	if enemy_bg != null:
		bar_enemy_hp.add_theme_stylebox_override("background", enemy_bg.duplicate())

# -----------------------------
# SELECCIÓN ALEATORIA
# -----------------------------
func select_random_player():
	var random_index = randi_range(0, player_classes.size() - 1)
	player = player_classes[random_index].duplicate(true)

func select_random_enemy():
	var random_index = randi_range(0, enemies.size() - 1)
	current_enemy = enemies[random_index].duplicate(true)

# -----------------------------
# CONFIGURAR UI
# -----------------------------
func setup_battle_ui():
	player_hp = player["hp"]
	player_max_hp = player["max_hp"]

	enemy_hp = current_enemy["hp"]
	enemy_max_hp = current_enemy["max_hp"]

	shield_active = false
	fury_active = false
	item_used = false

	lbl_player_name.text = player["name"] + " (" + player["class"] + ")"
	lbl_enemy_name.text = current_enemy["name"] + " (" + current_enemy["class"] + ")"

	if player.has("sprite"):
		player_sprite.texture = load(player["sprite"])

	if current_enemy.has("sprite"):
		enemy_sprite.texture = load(current_enemy["sprite"])

	btn_attack1.text = player["attacks"][0]["name"]
	btn_attack2.text = player["attacks"][1]["name"]
	btn_attack3.text = player["attacks"][2]["name"]
	btn_attack4.text = player["attacks"][3]["name"]
	btn_item.text = "Módulo"
	btn_run.text = "Retirada"

	bar_player_hp.max_value = player_max_hp
	bar_enemy_hp.max_value = enemy_max_hp

	update_hp_bars()
	set_dialog("Tu modelo es " + player["class"] + ".\n¡" + current_enemy["name"] + " ha entrado en combate!")

	set_menu_enabled(true)
	state = BattleState.PLAYER_TURN

# -----------------------------
# UI
# -----------------------------
func set_dialog(texto: String):
	lbl_dialog.text = texto
	next_arrow.visible = true

func set_menu_enabled(enabled: bool):
	btn_attack1.disabled = not enabled
	btn_attack2.disabled = not enabled
	btn_attack3.disabled = not enabled
	btn_attack4.disabled = not enabled
	btn_item.disabled = (not enabled) or item_used
	btn_run.disabled = not enabled

func update_hp_bars():
	bar_player_hp.value = player_hp
	bar_enemy_hp.value = enemy_hp

	update_hp_color(bar_player_hp, player_hp, player_max_hp)
	update_hp_color(bar_enemy_hp, enemy_hp, enemy_max_hp)

func update_hp_color(bar: ProgressBar, hp: int, max_hp: int):
	var percent = float(hp) / float(max_hp)
	var fill = bar.get_theme_stylebox("fill")

	if fill == null:
		return

	if percent > 0.5:
		fill.bg_color = Color.GREEN
	elif percent > 0.25:
		fill.bg_color = Color.YELLOW
	else:
		fill.bg_color = Color.RED

# -----------------------------
# SISTEMA DE CLASES ROBOT
# -----------------------------
func get_class_multiplier(attacker_class: String, defender_class: String) -> float:
	if attacker_class == "tanque" and defender_class == "asalto":
		return 1.25
	elif attacker_class == "asalto" and defender_class == "plasma":
		return 1.25
	elif attacker_class == "plasma" and defender_class == "tanque":
		return 1.25
	elif attacker_class == "sigilo" and defender_class == "virus":
		return 1.25
	elif attacker_class == "virus" and defender_class == "guardian":
		return 1.25
	elif attacker_class == "guardian" and defender_class == "sigilo":
		return 1.25

	elif attacker_class == "asalto" and defender_class == "tanque":
		return 0.85
	elif attacker_class == "plasma" and defender_class == "asalto":
		return 0.85
	elif attacker_class == "tanque" and defender_class == "plasma":
		return 0.85
	elif attacker_class == "virus" and defender_class == "sigilo":
		return 0.85
	elif attacker_class == "guardian" and defender_class == "virus":
		return 0.85
	elif attacker_class == "sigilo" and defender_class == "guardian":
		return 0.85

	return 1.0

# -----------------------------
# ATAQUES DEL JUGADOR
# -----------------------------
func use_player_attack(index: int):
	if state != BattleState.PLAYER_TURN:
		return

	state = BattleState.PLAYER_ACTION
	set_menu_enabled(false)

	var attack = player["attacks"][index]
	var base_damage = randi_range(attack["min"], attack["max"])
	var multiplier = get_class_multiplier(player["class"], current_enemy["class"])
	var damage = int(round(base_damage * multiplier))

	var used_fury = fury_active
	if fury_active:
		damage = int(round(damage * 1.5))
		fury_active = false

	enemy_hp -= damage
	enemy_hp = max(enemy_hp, 0)

	update_hp_bars()
	shake_sprite(enemy_sprite)

	var text = player["name"] + " usó " + attack["name"] + " e hizo " + str(damage) + " de daño."

	if used_fury:
		text += "\n¡Overclock potenció el ataque!"

	if multiplier > 1.0:
		text += "\n¡Impacto optimizado!"
	elif multiplier < 1.0:
		text += "\nLa defensa rival resistió parte del daño..."

	set_dialog(text)
	timer.start(1.2)

# -----------------------------
# MÓDULO ALEATORIO
# -----------------------------
func _on_item_pressed():
	if state != BattleState.PLAYER_TURN:
		return

	if item_used:
		set_dialog("Ya usaste un módulo en esta batalla.")
		return

	state = BattleState.PLAYER_ACTION
	set_menu_enabled(false)
	item_used = true

	var random_index = randi_range(0, items.size() - 1)
	var item = items[random_index]

	var text = "Activaste " + item["name"] + ".\n"

	match item["type"]:
		"heal":
			player_hp += item["value"]
			player_hp = min(player_hp, player_max_hp)
			text += "Recuperaste " + str(item["value"]) + " de integridad."

		"damage":
			enemy_hp -= item["value"]
			enemy_hp = max(enemy_hp, 0)
			text += "El enemigo recibió " + str(item["value"]) + " de daño eléctrico."
			shake_sprite(enemy_sprite)

		"shield":
			shield_active = true
			text += "Reducirás el próximo daño recibido."

		"buff":
			fury_active = true
			text += "Tu próximo ataque tendrá potencia aumentada."

	update_hp_bars()
	set_dialog(text)
	timer.start(1.2)

# -----------------------------
# RETIRADA
# -----------------------------
func _on_run_pressed():
	if state != BattleState.PLAYER_TURN:
		return

	state = BattleState.BATTLE_END
	set_menu_enabled(false)
	set_dialog("¡La unidad se retiró del combate!")

# -----------------------------
# TIMER
# -----------------------------
func _on_timer_timeout():
	if state == BattleState.PLAYER_ACTION:
		check_enemy_defeat()
	elif state == BattleState.ENEMY_TURN:
		enemy_attack()

# -----------------------------
# REVISAR SI EL ENEMIGO CAYÓ
# -----------------------------
func check_enemy_defeat():
	if enemy_hp <= 0:
		state = BattleState.BATTLE_END
		set_dialog("¡Victoria! " + current_enemy["name"] + " fue destruido.")
		return

	state = BattleState.ENEMY_TURN
	set_dialog(current_enemy["name"] + " está cargando un ataque...")
	timer.start(1.0)

# -----------------------------
# ATAQUE ENEMIGO
# -----------------------------
func enemy_attack():
	var base_damage = randi_range(current_enemy["attack_min"], current_enemy["attack_max"])
	var multiplier = get_class_multiplier(current_enemy["class"], player["class"])
	var damage = int(round(base_damage * multiplier))

	var used_shield = shield_active
	if shield_active:
		damage = int(round(damage * 0.5))
		shield_active = false

	player_hp -= damage
	player_hp = max(player_hp, 0)

	update_hp_bars()
	shake_sprite(player_sprite)

	var text = current_enemy["name"] + " atacó e hizo " + str(damage) + " de daño."

	if used_shield:
		text += "\n¡El campo de fuerza redujo el impacto!"

	if multiplier > 1.0:
		text += "\n¡Ataque altamente efectivo!"
	elif multiplier < 1.0:
		text += "\nEl blindaje absorbió parte del golpe..."

	set_dialog(text)

	if player_hp <= 0:
		state = BattleState.BATTLE_END
		set_menu_enabled(false)
		set_dialog("Derrota. " + player["name"] + " fue destruido.")
		return

	state = BattleState.PLAYER_TURN
	set_menu_enabled(true)

# -----------------------------
# ANIMACIÓN SIMPLE
# -----------------------------
func shake_sprite(target: Node2D):
	var original_pos = target.position
	var tween = create_tween()
	tween.tween_property(target, "position", original_pos + Vector2(10, 0), 0.05)
	tween.tween_property(target, "position", original_pos + Vector2(-10, 0), 0.05)
	tween.tween_property(target, "position", original_pos, 0.05)
