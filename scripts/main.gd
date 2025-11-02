extends Control

# Main UI Controller
# This script handles the UI and connects to the AI client

@onready var chat_display: RichTextLabel = $VBoxContainer/ChatDisplay
@onready var input_field: LineEdit = $VBoxContainer/HBoxContainer/InputField
@onready var send_button: Button = $VBoxContainer/HBoxContainer/SendButton
@onready var loading_label: Label = $VBoxContainer/LoadingLabel
@onready var ai_client: Node = $AIClient

func _ready():
	# Connect AI client signals
	ai_client.response_received.connect(_on_response_received)
	ai_client.error_occurred.connect(_on_error_occurred)
	ai_client.loading_state_changed.connect(_on_loading_state_changed)
	
	# Connect send button
	send_button.pressed.connect(_on_send_button_pressed)
	
	# Allow Enter key to send
	input_field.text_submitted.connect(_on_input_submitted)
	
	# Initialize UI
	loading_label.visible = false
	loading_label.text = ""
	
	# Add welcome message
	add_message_to_chat("System", "Welcome! Type a message and the AI will respond.", Color.GRAY)

func _on_send_button_pressed() -> void:
	send_message()

func _on_input_submitted(_text: String) -> void:
	send_message()

func send_message() -> void:
	var message = input_field.text.strip_edges()
	if message.is_empty():
		return
	
	# Add player message to chat
	add_message_to_chat("You", message, Color.WHITE)
	
	# Clear input
	input_field.text = ""
	
	# Disable UI while waiting
	input_field.editable = false
	send_button.disabled = true
	
	# Send to AI
	ai_client.send_message(message)

func _on_response_received(text: String) -> void:
	# Add AI response to chat
	add_message_to_chat("AI", text, Color.CYAN)
	
	# Re-enable UI
	input_field.editable = true
	send_button.disabled = false
	input_field.grab_focus()

func _on_error_occurred(message: String) -> void:
	# Show error
	add_message_to_chat("Error", message, Color.RED)
	
	# Re-enable UI
	input_field.editable = true
	send_button.disabled = false
	input_field.grab_focus()

func _on_loading_state_changed(is_loading: bool, message: String) -> void:
	loading_label.visible = is_loading
	loading_label.text = message

func add_message_to_chat(sender: String, message: String, color: Color) -> void:
	var timestamp = Time.get_datetime_dict_from_system()
	var time_str = "%02d:%02d:%02d" % [timestamp.hour, timestamp.minute, timestamp.second]
	
	var color_hex = "#" + color.to_html(false)
	var formatted_message = "[color=%s][b]%s[/b] (%s):[/color] %s\n" % [color_hex, sender, time_str, message]
	
	chat_display.text += formatted_message
	
	# Auto-scroll to bottom
	await get_tree().process_frame
	var scrollbar = chat_display.get_v_scroll_bar()
	if scrollbar:
		scrollbar.value = scrollbar.max_value
