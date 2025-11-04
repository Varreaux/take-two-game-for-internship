extends Control

# Main UI - Chat interface controller

@onready var chat_display: RichTextLabel = $VBoxContainer/ChatDisplay
@onready var input_field: LineEdit = $VBoxContainer/HBoxContainer/InputField
@onready var send_button: Button = $VBoxContainer/HBoxContainer/SendButton
@onready var loading_label: Label = $VBoxContainer/LoadingLabel
@onready var ai_client: Node = $AIClient

func _ready():
	ai_client.response_received.connect(_on_response_received)
	ai_client.error_occurred.connect(_on_error_occurred)
	ai_client.loading_state_changed.connect(_on_loading_state_changed)
	
	send_button.pressed.connect(send_message)
	input_field.text_submitted.connect(func(_text): send_message())
	
	loading_label.visible = false
	add_message_to_chat("System", "Welcome! Type a message and the AI will respond.", Color.GRAY)

func send_message() -> void:
	var message = input_field.text.strip_edges()
	if message.is_empty():
		return
	
	add_message_to_chat("You", message, Color.WHITE)
	input_field.text = ""
	input_field.editable = false
	send_button.disabled = true
	
	ai_client.send_message(message)

func _on_response_received(text: String) -> void:
	add_message_to_chat("AI", text, Color.CYAN)
	_enable_ui()

func _on_error_occurred(message: String) -> void:
	add_message_to_chat("Error", message, Color.RED)
	_enable_ui()

func _on_loading_state_changed(is_loading: bool, message: String) -> void:
	loading_label.visible = is_loading
	loading_label.text = message

func _enable_ui() -> void:
	input_field.editable = true
	send_button.disabled = false
	input_field.grab_focus()

func add_message_to_chat(sender: String, message: String, color: Color) -> void:
	var time = Time.get_datetime_dict_from_system()
	var time_str = "%02d:%02d:%02d" % [time.hour, time.minute, time.second]
	var color_hex = "#" + color.to_html(false)
	
	chat_display.text += "[color=%s][b]%s[/b] (%s):[/color] %s\n" % [color_hex, sender, time_str, message]
	
	await get_tree().process_frame
	var scrollbar = chat_display.get_v_scroll_bar()
	if scrollbar:
		scrollbar.value = scrollbar.max_value
