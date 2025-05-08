// v2.3.0에 대한 스크립트 어셋 변경됨 자세한 정보는
// https://help.yoyogames.com/hc/en-us/articles/360005277377 참조
function textbox(){
	return __textbox_class_element__();
}

function __textbox_class_element__(struct) constructor{
	text = struct[$"text"] ?? "";
	halign = struct[$"halign"] ?? draw_get_halign();
	valign = struct[$"valign"] ?? draw_get_valign();
	font = struct[$"font"] ?? draw_get_font();
	color = struct[$"color"] ?? draw_get_color();
	alpha = struct[$"alpha"] ?? draw_get_alpha();
	xscale = struct[$"xscale"] ?? 1;
	yscale = struct[$"yscale"] ?? 1;
	oneline = struct[$"oneline"] ?? false;
	cursor_pos = struct[$"cursor_pos"] ?? 0;
	cursor_drag_start_pos = struct[$"cursor_drag_start_pos"] ?? 0;
}

function get_IME_string(){
	var _window_handle = window_handle();
	return GetImeComposition(string(_window_handle));
}

function clear_IME_string(){
	var _window_handle = window_handle();
	return ClearImeString(string(_window_handle));
}