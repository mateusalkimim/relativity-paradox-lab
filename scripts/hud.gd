extends CanvasLayer
class_name HUD

var _label_beta: Label
var _label_gamma: Label
var _label_frame: Label
var _bar: ProgressBar

func _ready() -> void:
	layer = 10
	var panel := _build_panel()
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	margin.add_child(vbox)

	_label_beta = _make_label("β  0.050 c")
	_bar = _make_bar()
	_label_gamma = _make_label("γ  1.001")
	_label_frame = _make_label("ALICE", Color(0.4, 0.9, 0.5))

	vbox.add_child(_label_beta)
	vbox.add_child(_bar)
	vbox.add_child(_label_gamma)
	vbox.add_child(_label_frame)
	add_child(panel)

	GameState.velocity_changed.connect(func(_v): _update())
	GameState.frame_changed.connect(func(_f): _update())
	_update()

func _update() -> void:
	var beta := GameState.get_beta()
	var gamma := GameState.get_gamma()
	_label_beta.text = "β  %.3f c" % beta
	_label_gamma.text = "γ  %.3f" % gamma
	_bar.value = beta
	var is_alice := GameState.current_frame == GameState.Frame.ALICE
	_label_frame.text = "ALICE" if is_alice else "BOB"
	var frame_color := Color(0.4, 0.9, 0.5) if is_alice else Color(0.9, 0.6, 0.2)
	_label_frame.add_theme_color_override("font_color", frame_color)

func _build_panel() -> Panel:
	var panel := Panel.new()
	panel.name = "HUDPanel"
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.position = Vector2(16.0, 16.0)
	panel.size = Vector2(200.0, 110.0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.07, 0.10, 0.88)
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.35, 0.35, 0.50, 0.70)
	panel.add_theme_stylebox_override("panel", style)
	return panel

func _make_label(text: String, color: Color = Color(0.92, 0.86, 0.62)) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_font_size_override("font_size", 15)
	return lbl

func _make_bar() -> ProgressBar:
	var bar := ProgressBar.new()
	bar.min_value = 0.0
	bar.max_value = 0.99
	bar.value = 0.05
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0.0, 10.0)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.90, 0.75, 0.20)
	fill.corner_radius_top_left = 2
	fill.corner_radius_top_right = 2
	fill.corner_radius_bottom_left = 2
	fill.corner_radius_bottom_right = 2
	bar.add_theme_stylebox_override("fill", fill)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.15, 0.15, 0.20)
	bg.corner_radius_top_left = 2
	bg.corner_radius_top_right = 2
	bg.corner_radius_bottom_left = 2
	bg.corner_radius_bottom_right = 2
	bar.add_theme_stylebox_override("background", bg)
	return bar
