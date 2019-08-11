extends Node2D

var SIZE = 8
var WIDTH = 20
var HEIGHT = 11
var D = 150
onready var last_time = OS.get_ticks_msec()

var snake = []
var food = null
var pressing = {}
var input_queue = []

var new_bodies = []

var is_die

var pos_scene = preload("res://Pos.tscn")

var g = preload("res://Global.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
  start()

func start():
  $Die.visible = false
  food = add_pos_scene(g.Type.FOOD, 8, 7, g.Dir.UP)

  var new_head = add_pos_scene(g.Type.SNAKE, 8, 0, g.Dir.RIGHT)
  var new_body = add_pos_scene(g.Type.SNAKE, 7, 0, g.Dir.RIGHT)
  snake.push_back(new_head)
  snake.push_back(new_body)
  is_die = false

func clear():
  for b in snake:
    b.queue_free()
  if food:
    food.queue_free()
  snake = []

func retry():
  start()

func add_pos_scene(_type, _x, _y, _dir):
  var s = pos_scene.instance()
  add_child(s)
  s.init(_type, _x, _y, _dir)
  return s

func _draw():
  pass

func move():
  move_snake()
  pass

func move_snake():
  maybe_eat()
  if maybe_hit():
    return
  var is_grow = is_can_grow()
  for i in range(snake.size(), 1, -1):
    snake[i-1].copy_from(snake[i-2])
  var head = snake[0]
  if input_queue.size() > 0:
    var dir = input_queue.pop_front()
    head.dir = dir
  head.move(HEIGHT, WIDTH)

  if is_grow:
    grow()

func maybe_eat():
  var head = snake[0]
  if head.x == food.x && head.y == food.y:
    # print(head.x, head.y, " | ", food.x, food.y)
    food.toggle_show(false)
    new_bodies.push_back(food)
    new_food(food.x, food.y)

func is_can_grow():
  if new_bodies.size() > 0:
    var tail = snake[snake.size() - 1]
    var nb = new_bodies[0]
    if tail.x == nb.x && tail.y == nb.y:
      return true
  return false

func grow():
  var tail = snake[snake.size() - 1]
  var nb = new_bodies.pop_front()
  nb.type = g.Type.SNAKE
  nb.dir = tail.dir
  nb.toggle_show(true)
  snake.push_back(nb)


func maybe_hit():
  var head = snake[0]
  for i in range(1, snake.size()):
    var body = snake[i]
    if body.x == head.x && body.y == head.y:
      hit()
      return true
  return false

func hit():
  is_die = true
  print("die")
  $Die.visible = true
  clear()

func new_food(_x, _y):
  var idx = _y * WIDTH + _x
  var r = randi() % (WIDTH * HEIGHT)
  var fx = r % WIDTH
  var fy = r / WIDTH
  while (r == idx || is_in_snake(fx, fy)):
    r = randi() % (WIDTH * HEIGHT)
    fx = r % WIDTH
    fy = r / WIDTH
  print(r, " ", fx, " ", fy)
  food = add_pos_scene(g.Type.FOOD, fx, fy, g.Dir.UP)

func is_in_snake(fx, fy):
  for b in snake:
    if b.x == fx && b.y == fy:
      return true
  return false

func _process(delta):
  var now = OS.get_ticks_msec()
  if now - last_time >= D:
    if !is_die:
      move()
    last_time += D

func input(dir):
  var last
  if input_queue.size() == 0:
    last = snake[0].dir
  else:
    last = input_queue[input_queue.size() - 1]
  if is_input_ok(dir, last):
      input_queue.push_back(dir)

func is_input_ok(dir1, dir2):
  if dir1 == g.Dir.UP || dir1 == g.Dir.DOWN:
    return dir2 == g.Dir.LEFT || dir2 == g.Dir.RIGHT
  if dir1 == g.Dir.LEFT || dir1 == g.Dir.RIGHT:
    return dir2 == g.Dir.UP || dir2 == g.Dir.DOWN
  print("err")
  return false

func _input(ev):
  if Input.is_key_pressed(KEY_W):
    if !pressing["w"]:
      input(g.Dir.UP)
    pressing["w"] = true
  else:
    pressing["w"] = false
  if Input.is_key_pressed(KEY_S):
    if !pressing["s"]:
      input(g.Dir.DOWN)
    pressing["s"] = true
  else:
    pressing["s"] = false
  if Input.is_key_pressed(KEY_A):
    if !pressing["a"]:
      input(g.Dir.LEFT)
    pressing["a"] = true
  else:
    pressing["a"] = false
  if Input.is_key_pressed(KEY_D):
    if !pressing["d"]:
      input(g.Dir.RIGHT)
    pressing["d"] = true
  else:
    pressing["d"] = false

func _on_Die_retry():
  retry()
