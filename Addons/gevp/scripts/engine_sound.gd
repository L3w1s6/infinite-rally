extends AudioStreamPlayer3D

@export var vehicle : Vehicle
@export var sample_rpm := 4000.0

var vol: float = .01 #temp reducing volume so my ears don't explode
func _physics_process(_delta):
	pitch_scale = vehicle.motor_rpm / sample_rpm
	volume_db = linear_to_db((vehicle.throttle_amount * vol) + vol)
