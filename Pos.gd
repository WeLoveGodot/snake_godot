extends Node2D


var type
var x
var y
var dir

var g = preload("res://Global.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
  type = g.Type.SNAKE
  dir = g.Dir.RIGHT
  x = 0
  y = 0

func init(_type, _x, _y, _dir):
  type = _type
  dir = _dir
  x = _x
  y = _y
  update()

func set_pos(_x, _y):
  x = _x
  y = _y
  update_pos()

func set_direction(_dir):
  dir = _dir

func copy_from(another):
  set_pos(another.x, another.y)
  set_direction(another.dir)
  update_pos()

func update_pos():
  var size = $Sprite.get_texture().get_width()
  position = Vector2((x + 0.5) * size, (y + 0.5) * size)

func update_type():
  if type == g.Type.FOOD:
    $Sprite.modulate = Color(0, 1, 1)
  else:
    $Sprite.modulate = Color(1, 1, 1)

func update():
  update_type()
  update_pos()

func move(height, width):
  if dir == g.Dir.DOWN:
    y = (y + 1) % height
  elif dir == g.Dir.UP:
    y = (y + height - 1) % height
  elif dir == g.Dir.RIGHT:
    x = (x + 1) % width
  elif dir == g.Dir.LEFT:
    x = (x + width - 1) % width
  update_pos()

func toggle_show(is_show):
  $Sprite.visible = is_show

func _process(delta):
  update()
  pass
