class_name SeededRandom extends Object

var startSeed: int
var seedOffset: int

func setSeed(seed: int) -> void:
	startSeed = seed
	seedOffset = 0

func resetOffset() -> void:
	seedOffset = 0

func nextRand() -> int:
	var x = rand_from_seed(startSeed + seedOffset)[0]
	seedOffset = x
	return x

func nextRandRange(min:int, max:int) -> int:
	return wrap(nextRand(), min, max)
