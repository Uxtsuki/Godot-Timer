extends Resource
class_name Tempus

signal on_reset(Tempus)
signal on_timeout(Tempus)

@export var _active : bool = true
@export var _one_shot : bool = false
@export var _timer : float = 0
@export var _reset : float = 1
@export var _increment : float = 0
@export var _multiplier : float = 1

@export var _count_only : bool = false
@export var _upper_limit : float = -1
@export var _is_addition : bool = false
@export var _delta_modifiers : Dictionary[String, Dictionary] = {}
@export var _reset_modifiers : Dictionary[String, Dictionary] = {}

func _init(one_shot : bool = false, timer : float = 0, reset : float = 1, increment : float = 0, multiplier : float = 1, active : bool = true) -> void:
	resource_local_to_scene = true
	_one_shot = one_shot
	_active = active
	_timer = timer
	_reset = reset
	_increment = increment
	_multiplier = multiplier

func _update(delta : float) -> void:
	if !_active:
		return
	for key in _reset_modifiers:
		if !_reset_modifiers[key].has("timer"):
			continue
		_reset_modifiers[key]["timer"] -= delta if _reset_modifiers["ignore_delta_modifier"] else get_final_delta(delta)
		if _reset_modifiers[key]["timer"] <= 0:
			_reset_modifiers.erase(key)
	for key in _delta_modifiers:
		if !_delta_modifiers[key].has("timer"):
			continue
		_delta_modifiers[key]["timer"] -= delta if _delta_modifiers["ignore_delta_modifier"] else get_final_delta(delta)
		if _delta_modifiers[key]["timer"] <= 0:
			_delta_modifiers.erase(key)
	if _timer > 0 && !_is_addition:
		_timer -= get_final_delta(delta)
	elif _is_addition:
		_timer += get_final_delta(delta)
	if _count_only:
		return
	
	if _upper_limit == -1 && _timer <= 0:
		on_timeout.emit(self)
		if _reset != 0:
			_reset += _increment
			_reset *= _multiplier
			_timer = get_final_reset()
			on_reset.emit(self)
		if _one_shot:
			_active = false
	if _upper_limit != -1 && _timer >= _upper_limit:
		on_timeout.emit(self)
		if _reset != 0:
			_reset += _increment
			_reset *= _multiplier
			_upper_limit = get_final_reset()
			_timer = 0
			on_reset.emit(self)
		if _one_shot:
			_active = false

func add_reset_modifier(key : String, origin : Variant, formula : String, positive : bool = true, description: String = "", timer : float = -1, condition : Variant = null, ignore_delta_modifier : bool = false) -> void:
		var _modifier : Dictionary = {
		"origin": origin,
		"formula": formula,
		"description": description,
		"positive": positive,
		"ignore_delta_modifier": ignore_delta_modifier
		}
		if timer != -1:
			_modifier["timer"] = timer
		if condition is Callable:
			_modifier["condition"] = condition
		_reset_modifiers[key] = _modifier
	
func remove_value_modifier(key : String) -> void:
	if key:
		_reset_modifiers.erase(key)
	
func add_delta_modifier(key : String, origin : Variant, formula : String, positive : bool = true, description: String = "", timer : float = -1, condition : Variant = null) -> void:
		var _modifier : Dictionary = {
		"origin": origin,
		"formula": formula,
		"description": description,
		"positive": positive,
		}
		if _timer != -1:
			_modifier["timer"] = timer
		if condition is Callable:
			_modifier["condition"] = condition
		_delta_modifiers[key] = _modifier
	
func remove_delta_modifier(key : String) -> void:
	if key:
		_delta_modifiers.erase(key)

func get_final_reset() -> float:
	var initial = _reset
	for key in _reset_modifiers:
		if _reset_modifiers[key].has("condition") && _reset_modifiers[key]["condition"].call() != true:
			_reset_modifiers.erase(key)
			continue
		var formula : Expression = Expression.new()
		var origin = _reset_modifiers[key]["origin"]
		if origin is Callable:
			origin = origin.call()
		formula.parse(_reset_modifiers[key]["formula"], ["initial", key])
		var value = formula.execute([initial, origin])
		if !formula.has_execute_failed():
			initial = value
	return initial

func get_final_delta(delta : float) -> float:
	var initial = delta
	for key in _delta_modifiers:
		if _delta_modifiers[key].has("condition") && _delta_modifiers[key]["condition"].call() != true:
			_delta_modifiers.erase(key)
			continue
		var formula : Expression = Expression.new()
		var origin = _delta_modifiers[key]["origin"]
		if origin is Callable:
			origin = origin.call()
		formula.parse(_delta_modifiers[key]["formula"], ["initial", key])
		var value = formula.execute([initial, origin])
		if !formula.has_execute_failed():
			initial = value
	return initial
		"positive": positive,
		"ignore_delta_modifier": ignore_delta_modifier
		}
		if timer != -1:
			_modifier["timer"] = timer
		if condition is Callable:
			_modifier["condition"] = condition
		_reset_modifiers[key] = _modifier
	
func remove_value_modifier(key : String) -> void:
	if key:
		_reset_modifiers.erase(key)
	
func add_delta_modifier(key : String, origin : Variant, formula : String, positive : bool = true, description: String = "", timer : float = -1, condition : Variant = null) -> void:
		var _modifier : Dictionary = {
		"origin": origin,
		"formula": formula,
		"description": description,
		"positive": positive,
		}
		if _timer != -1:
			_modifier["timer"] = timer
		if condition is Callable:
			_modifier["condition"] = condition
		_delta_modifiers[key] = _modifier
	
func remove_delta_modifier(key : String) -> void:
	if key:
		_delta_modifiers.erase(key)

func get_final_reset() -> float:
	var initial = _reset
	for key in _reset_modifiers:
		if _reset_modifiers[key].has("condition") && _reset_modifiers[key]["condition"].call() != true:
			_reset_modifiers.erase(key)
			continue
		var formula : Expression = Expression.new()
		var origin = _reset_modifiers[key]["origin"]
		if origin is Callable:
			origin = origin.call()
		formula.parse(_reset_modifiers[key]["formula"], ["initial", key])
		var value = formula.execute([initial, origin])
		if !formula.has_execute_failed():
			initial = value
	return initial

func get_final_delta(delta : float) -> float:
	var initial = delta
	for key in _delta_modifiers:
		if _delta_modifiers[key].has("condition") && _delta_modifiers[key]["condition"].call() != true:
			_delta_modifiers.erase(key)
			continue
		var formula : Expression = Expression.new()
		var origin = _delta_modifiers[key]["origin"]
		if origin is Callable:
			origin = origin.call()
		formula.parse(_delta_modifiers[key]["formula"], ["initial", key])
		var value = formula.execute([initial, origin])
		if !formula.has_execute_failed():
			initial = value
	return initial
