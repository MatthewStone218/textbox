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
	tab_space_count = struct[$"tab_space_count"] ?? 6;
	tab_space_string = "";
	for(var i = 0; i < tab_space_count; i++){
		tab_space_string += " ";
	}
}

function __textbox_get_text_coord__(pos,coord){
	var _ime_string = get_IME_string();
	
	var _text = string_insert(_ime_string,text,pos+1);
	pos += string_length(_ime_string);
	
	var _text_full_line = string_copy(_text,1,string_pos_ext("\n",_text,pos));
	if(string_pos_ext("\n",_text,pos) == 0){
		_text_full_line = _text;
	}
	
	_text = string_copy(_text,1,pos);
	
	_text = string_replace_all(_text,"\t",tab_space_string);
	_text_full_line = string_replace_all(_text_full_line,"\t",tab_space_string);
	
	var _text_last_line = _text;
	while(string_pos("\n",_text_last_line) > 0){
		_text_last_line = string_delete(_text_last_line,1,string_pos("\n",_text_last_line));
	}
	
	var _text_last_full_line = _text_full_line;
	while(string_pos("\n",_text_last_full_line) > 0){
		_text_last_full_line = string_delete(_text_last_full_line,1,string_pos("\n",_text_last_full_line));
	}
	
	var _halign_prev = draw_get_halign();
	var _valign_prev = draw_get_valign();
	var _font_prev = draw_get_font();
	
	draw_set_halign(halign);
	draw_set_valign(valign);
	draw_set_font(font);
	
	var _height = string_height(_text)*yscale;
	var _last_line_width = string_width(_text_last_line)*xscale;
	var _last_full_line_width = string_width(_text_last_full_line)*xscale;
	var _height = string_height(_text)*yscale;
	
	draw_set_halign(_halign_prev);
	draw_set_valign(_valign_prev);
	draw_set_font(_font_prev);
	
	var _last_line_h_adjust = 0;
	var _v_adjust = 0;
	
	if(halign == fa_center){
		_last_line_h_adjust = -0.5;
	} else if(halign == fa_right){
		_last_line_h_adjust = -1;
	}
	
	if(valign == fa_middle){
		_v_adjust = -0.5;
	} else if(valign == fa_bottom){
		_v_adjust = -1;
	}
	
	var _x = coord[0]+_last_line_width+_last_full_line_width*_last_line_h_adjust;
	var _y = coord[1]+_height*_v_adjust;
	
	return [_x,_y];
}

function get_IME_string(){
	var _window_handle = window_handle();
	return GetImeComposition(string(_window_handle));
}

function clear_IME_string(){
	var _window_handle = window_handle();
	return ClearImeString(string(_window_handle));
}