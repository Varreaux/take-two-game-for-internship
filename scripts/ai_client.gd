extends Node

# AI Client - Handles API communication with the backend

signal response_received(text: String)
signal error_occurred(message: String)
signal loading_state_changed(is_loading: bool, message: String)

@onready var http_request: HTTPRequest = HTTPRequest.new()

var api_url: String = "https://varreaux-godot-ai-game.hf.space/"
var is_first_request: bool = true

func _ready():
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	http_request.use_threads = true

func send_message(prompt: String) -> void:
	if prompt.is_empty():
		return
	
	if is_first_request:
		loading_state_changed.emit(true, "AI is waking up... 😴 This may take 30-90 seconds")
		is_first_request = false
	else:
		loading_state_changed.emit(true, "AI is thinking... 🧠")
	
	var url = api_url + "?msg=" + prompt.uri_encode()
	var headers = ["Content-Type: application/json"]
	var error = http_request.request(url, headers, HTTPClient.METHOD_GET)
	
	if error != OK:
		loading_state_changed.emit(false, "")
		error_occurred.emit("Failed to send request")

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	loading_state_changed.emit(false, "")
	
	if response_code != 200:
		var error_msg = "Server error (Code: %d)" % response_code
		if response_code == 0:
			error_msg = "Connection failed"
		error_occurred.emit(error_msg)
		return
	
	var json = JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK:
		error_occurred.emit("Failed to parse response")
		return
	
	var response = json.data
	if response.has("response"):
		response_received.emit(response["response"])
	else:
		error_occurred.emit("Unexpected response format")
