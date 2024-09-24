extends Interactable

@export_category("Settings")
@export var rotation_on_carry: Vector3
@export var carry_position_offset: Vector3
@export var set_requirement: String
@export var follow_speed: float = 1000

@export_category("Carry audio")
@export var carry_audio_stream_player: AudioStreamPlayer3D
@export var pick_up_audio: AudioStream
@export var put_down_audio: AudioStream

var carrying: bool = false
var dropoff_area: Area3D


func _ready() -> void:
	if not verb:
		verb = "Carry"

	super._ready()


func _physics_process(delta: float) -> void:
	if carrying:
		self.linear_velocity = (player.inspect_position.global_position - global_position) * delta * follow_speed
		print(self.linear_velocity)


func interact(interacting_player: CharacterBody3D) -> Node:
	super.interact(interacting_player)

	carry()
	return self


func carry() -> void:
	self.collision_layer = 2

	get_parent().remove_child(self)
	player.inspect_position.add_child(self)
	position = carry_position_offset
	rotation = Vector3(deg_to_rad(rotation_on_carry.x),
					deg_to_rad(rotation_on_carry.y),
					deg_to_rad(rotation_on_carry.z))
	carrying = true

	if carry_audio_stream_player and pick_up_audio:
		carry_audio_stream_player.stream = pick_up_audio
		carry_audio_stream_player.play()


func release() -> bool:
	if not dropoff_area:
		print("Cannot release here")
		player.set_interact_response_message("Cannot release here")
		return false

	self.collision_layer = 1

	var new_parent = dropoff_area
	get_parent().remove_child(self)
	new_parent.add_child(self)
	position = Vector3.ZERO
	rotation = Vector3.ZERO
	carrying = false
	
	if carry_audio_stream_player and put_down_audio:
		carry_audio_stream_player.stream = put_down_audio
		carry_audio_stream_player.play()

	player.add_met_picture_requirement(set_requirement)

	return true


func set_dropoff(area: Area3D) -> void:
	dropoff_area = area
	player.set_interact_response_message("Release here")
