extends Node

# AI Client Script - Handles communication with Hugging Face API
# This script manages HTTP requests to your FastAPI backend

signal response_received(text: String)
signal error_occurred(message: String)
signal loading_state_changed(is_loading: bool, message: String)

@onready var http_request: HTTPRequest = HTTPRequest.new()

# IMPORTANT: Replace this with your Hugging Face Space URL once deployed
# Docker Spaces MUST use .hf.space domain for direct API access
var api_url: String = "https://varreaux-godot-ai-game.hf.space/"

var is_first_request: bool = true

func _ready():
	# Add HTTPRequest node as child
	add_child(http_request)
	# Connect the signal that fires when request completes
	http_request.request_completed.connect(_on_request_completed)
	# Enable use_threads for better web compatibility
	http_request.use_threads = true

# Called when you want to send a message to the AI
func send_message(prompt: String) -> void:
	if prompt.is_empty():
		return
	
	# Emit loading state
	if is_first_request:
		loading_state_changed.emit(true, "AI is waking up... 😴 This may take 30-90 seconds (first time)")
		is_first_request = false
	else:
		loading_state_changed.emit(true, "AI is thinking... 🧠")
	
	# Create JSON payload
	var payload = {
		"prompt": prompt
	}
	
	var json_string = JSON.stringify(payload)
	
	# Debug: print what we're sending
	print("Sending request to: ", api_url)
	print("Payload: ", json_string)
	
	# Use GET with 'msg' parameter (Hugging Face Spaces POST limitation workaround)
	var url_with_param = api_url + "?msg=" + prompt.uri_encode()
	
	# Set up headers
	var headers = [
		"Content-Type: application/json"
	]
	
	# Make the GET request
	var error = http_request.request(url_with_param, headers, HTTPClient.METHOD_GET)
	
	if error != OK:
		loading_state_changed.emit(false, "")
		var error_msg = "Failed to send request. Error code: " + str(error)
		print("HTTPRequest error: ", error_msg)
		error_occurred.emit(error_msg)

# Called when HTTP request completes
func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	loading_state_changed.emit(false, "")
	
	# Debug: print response info
	print("Request completed. Result: ", result, " Response code: ", response_code)
	print("Response body: ", body.get_string_from_utf8())
	
	# Check for HTTP errors
	if response_code != 200:
		var error_msg = "Server error (Code: %d)" % response_code
		if response_code == 0:
			error_msg = "Connection failed. Check your API URL."
		print("Error response: ", error_msg)
		error_occurred.emit(error_msg)
		return
	
	# Parse JSON response
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	
	if parse_result != OK:
		error_occurred.emit("Failed to parse response")
		return
	
	var response = json.data
	
	# Extract the generated text
	# Adjust this key based on what your FastAPI endpoint returns
	if response.has("response") or response.has("text") or response.has("generated_text"):
		var generated_text = response.get("response", response.get("text", response.get("generated_text", "")))
		response_received.emit(generated_text)
	else:
		error_occurred.emit("Unexpected response format: " + str(response))
