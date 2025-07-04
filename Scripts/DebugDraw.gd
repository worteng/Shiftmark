extends Control

var text_lines: Array = []
@export var font: FontFile
@export var font_size: int = 14

func _ready():
	set_process(true)

func _process(_delta):
	queue_redraw()

func _draw():
	var pos = Vector2(10, 20)
	for line in text_lines:
		if font:
			draw_string(
				font,                  # FontFile
				pos,                   # Vector2
				line,                  # String
				HORIZONTAL_ALIGNMENT_LEFT,  # int
				-1,                    # width: float
				font_size,             # font_size: int
				Color.WHITE,           # modulate: Color
				3,                     # justification_flags: int
				0,                     # direction: TextServer.Direction (0 = auto)
				TextServer.ORIENTATION_HORIZONTAL  # orientation
			)
		pos.y += font_size + 4
	text_lines.clear()

func draw_text(text: String):
	text_lines.append(text)
