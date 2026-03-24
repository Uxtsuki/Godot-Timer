extends Node2D

var _t : Tempus = Tempus.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_t.on_timeout.connect(func(x): print(0))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_t._update(delta)
	print(_t._timer)
