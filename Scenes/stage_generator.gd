@tool
extends Node3D

@export_group("")
@export var dummyUpdate = true:
	get():
		return 0
	set(value):
		genCurve()
		print("curve generated ----")
		$Path3D.curve = curve

@export_group("Map Properties")
@export var noise: NoiseTexture2D
@export var coordScale := 1.
@export var heightScale := 10.
@export var randomiserSeed := 0

@export_group("Curve Properties")
@export var noPoints := 16
@export var minLength := 5.
@export var maxLength := 200.
@export var maxAngleRange := 160.

var curve: Curve3D

func genCurve():
	#init
	var curPos: Vector3
	var prevPos := Vector3()
	var noiseImage = noise.get_image()
	var randGen := SeededRandom.new()
	randGen.setSeed(randomiserSeed)
	
	curve = Curve3D.new() #create curve
	
	#create curve points (ADD HANDLE STUFF)
	for i in range(noPoints):
		#calc next point
		curPos = prevPos + Vector3(
			randGen.nextRandRange(-maxAngleRange, maxAngleRange) * coordScale,
			0,
			randGen.nextRandRange(-maxAngleRange, maxAngleRange) * coordScale
		).normalized() * randGen.nextRandRange(minLength, maxLength) * coordScale
		
		#sample noise at current pos (within valid range)
		var pixelColour = noiseImage.get_pixel(
			wrap(int(curPos.x), 0, noiseImage.get_width()),
			wrap(int(curPos.z), 0, noiseImage.get_height())
		)
		
		curPos.y = pixelColour.r * heightScale #noise value stored as rgb with a as 1
		
		curve.add_point(curPos)
		
		#update prev
		prevPos = curPos
		print("pos:", curPos, " | noise:", pixelColour.r, " | ", randGen.nextRandRange(-100,100)) #KINDA ADDED
