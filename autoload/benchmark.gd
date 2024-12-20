@tool
extends Node
##
## Benchmark
##
## Can do benchmarks.
##
##

var _benchmarks := {}
var _def_benchmark := BenchmarkData.new()


# =============================================================
# ========= Public Functions ==================================

func start(benchmark: StringName = &"") -> void:
	var b := __get_benchmark(benchmark)
	if b.running:
		pass # Error
		return
	b.running = true
	b.last_tick = Time.get_ticks_usec()


func stop(benchmark: StringName = &"") -> void:
	var b := __get_benchmark(benchmark)
	if not b.running:
		pass # Error
		return
	b.current_time += Time.get_ticks_usec() - b.last_tick
	print("%s %d" % [benchmark, b.current_time])
	b.reset()


func pause(benchmark: StringName = &"") -> void:
	var b := __get_benchmark(benchmark)
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
		b = _benchmarks.get(benchmark)
		if not b:
			b = BenchmarkData.new()
	return b

# =============================================================
# ========= Signal Callbacks ==================================


# =============================================================
# ========= Internal Classes ==================================

class BenchmarkData:
	var running := false
	var current_time := 0
	var last_tick := -1

	func reset() -> void:
		running = false
		current_time = 0
		last_tick = -1
