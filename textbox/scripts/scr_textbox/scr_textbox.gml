// v2.3.0에 대한 스크립트 어셋 변경됨 자세한 정보는
// https://help.yoyogames.com/hc/en-us/articles/360005277377 참조
function textbox(){
	return __textbox_class_element__();
}

function __textbox_class_element__(struct) constructor{
	text = struct[$"text"] ?? "";
	x = struct[$"x"] ?? x;
	y = struct[$"y"] ?? y;
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

function __textbox_get_text_coord__(pos){
	var _ime_string = get_IME_string();
	
	var _text = string_insert(_ime_string,text,pos+1);
	pos += string_length(_ime_string);
	
	if(string_width(_text) == 0 || string_height(_text) == 0){
		_text = " ";
		pos = 1;
	}	
	
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
	
	var _x = x+_last_line_width+_last_full_line_width*_last_line_h_adjust;
	var _y = y+_height*_v_adjust;
	
	return [_x,_y];
}

function __textbox_get_text_pos__(coord){
	var _text = text;
	//y
	var _nearest_dis = 0;
	var _dis = 0;
	var _ln_pos = 0;

	while(_nearest_dis < _dis){
		_ln_pos = string_pos_ext("\n",_text,_ln_pos+1);
		if(_ln_pos > 0){
			_dis = abs(__textbox_get_text_coord__(_ln_pos)[1] - coord[1]);
			if(_nearest_dis >= _dis){
				_nearest_dis = _dis;
			}
		} else {
			_dis = abs(__textbox_get_text_coord__(string_length(_text))[1] - coord[1]);
			if(_nearest_dis >= _dis){
				_nearest_dis = _dis;
			}
			break;
		}
	}
	
	//x
	var _line = string_copy(_text, _ln_pos+1,string_length(_text));
	var _ln_pos_2 = string_pos_ext("\n",_text,_ln_pos+1);
	if(_ln_pos_2 > 0){
		_line = string_copy(_text,_ln_pos+1,_ln_pos_2-_ln_pos+1);
	}
	
	var _nearest_dis = 0;
	var _dis = 0;
	var _pos = 0;
	var _idx = _ln_pos;
	for(var i = 1; i < string_length(_line)+1; i++){
		_idx = _ln_pos+i;
		var _char_coord = __textbox_get_text_coord__(_idx);
		if(abs(_char_coord[0]-coord[0]) < _dis){
			_dis = _char_coord;
			_pos = _idx;
		} else {
			break;
		}
	}
	
	//result
	return _x_pos;
}

function get_IME_string(){
	var _window_handle = window_handle();
	return GetImeComposition(string(_window_handle));
}

function clear_IME_string(){
	var _window_handle = window_handle();
	return ClearImeString(string(_window_handle));
}