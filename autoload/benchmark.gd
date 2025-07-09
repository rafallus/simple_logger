@tool
extends Node
##
## Benchmark
##
## Can do benchmarks.
##
##

class BenchmarkData:
	var running := false
	var current_time: int = 0
	var last_tick: int = -1

	func reset() -> void:
		running = false
		current_time = 0
		last_tick = -1

var _benchmarks: Dictionary[StringName, BenchmarkData] = {}
var _def_benchmark: BenchmarkData = BenchmarkData.new()
var _cached_benchmark: BenchmarkData
var _cached: StringName


# =============================================================
# ========= Public Functions ==================================

func start(benchmark: StringName = &"") -> void:
	var b: BenchmarkData = _cached_benchmark if _cached == benchmark else __get_benchmark(benchmark)
	if b.running:
		pass # Error
		return
	b.running = true
	b.last_tick = Time.get_ticks_usec()


func stop(benchmark: StringName = &"") -> void:
	var b: BenchmarkData = _cached_benchmark if _cached == benchmark else __get_benchmark(benchmark)
	if not b.running:
		pass # Error
		return
	b.current_time += Time.get_ticks_usec() - b.last_tick
	print("%s %d" % [benchmark, b.current_time])
	b.reset()


func pause(benchmark: StringName = &"") -> void:
	var b: BenchmarkData = _cached_benchmark if _cached == benchmark else __get_benchmark(benchmark)
	if not b.running:
		pass # Error
		return
	b.running = false
	b.current_time += Time.get_ticks_usec() - b.last_tick
	b.last_tick = -1


# =============================================================
# ========= Callbacks =========================================


# =============================================================
# ========= Virtual Methods ===================================


# =============================================================
# ========= Private Functions =================================

func __get_benchmark(benchmark: StringName) -> BenchmarkData:
	var b: BenchmarkData
	if benchmark.is_empty():
		b = _def_benchmark
	else:
		b = _benchmarks.get(benchmark, null)
		if not b:
			b = BenchmarkData.new()
			_benchmarks[benchmark] = b
	_cached_benchmark = b
	return b

# =============================================================
# ========= Signal Callbacks ==================================
