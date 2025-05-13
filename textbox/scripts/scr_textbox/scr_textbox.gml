// v2.3.0에 대한 스크립트 어셋 변경됨 자세한 정보는
// https://help.yoyogames.com/hc/en-us/articles/360005277377 참조
function textbox(struct = {}){
	struct[$"x"] ??= x;
	struct[$"y"] ??= y;
	return new __textbox_class_element__(struct);
}

//빈 문자나 탭 문자는 모두 text에 당초 포함되는 게 전재. tab, ime만 계산시 직전 적용

function __textbox_class_element__(struct) constructor{
	text = "\u200B" + (struct[$"text"] ?? "") + "\u200B";
	x = struct[$"x"] ?? x;
	y = struct[$"y"] ?? y;
	halign = struct[$"halign"] ?? fa_left;
	valign = struct[$"valign"] ?? fa_top;
	font = struct[$"font"] ?? draw_get_font();
	color = struct[$"color"] ?? c_black;
	alpha = struct[$"alpha"] ?? 1;
	xscale = struct[$"xscale"] ?? 1;
	yscale = struct[$"yscale"] ?? 1;
	oneline = struct[$"oneline"] ?? false;
	cursor_pos = struct[$"cursor_pos"] ?? 2;
	cursor_drag_start_pos = struct[$"cursor_drag_start_pos"] ?? 0;
	tab_space_count = struct[$"tab_space_count"] ?? 6;
	is_focused = struct[$"is_focused"] ?? false;
	tab_space_string = "";
	for(var i = 0; i < tab_space_count; i++){
		tab_space_string += " ";
	}
	
	function handle_input(str){
		if(is_focused){
			if(keyboard_check_pressed(vk_backspace)){
				__textbox_push_input__(str);
				text = string_delete(text,cursor_pos,1);
				cursor_pos -= 1;
			} else if(keyboard_check_pressed(vk_enter) && !oneline){
				__textbox_push_input__(str);
				text = string_insert("\n\u200B",text,cursor_pos+1);
				cursor_pos += 2;
			} else if(keyboard_check_pressed(vk_right)){
				__textbox_push_input__(str);
				cursor_pos += 1;
			} else {
				__textbox_push_input__(str);
			}
			
			cursor_pos = median(1,cursor_pos,string_length(text));
		}
	}
	
	function draw(){
		var _halign_prev = draw_get_halign();
		var _valign_prev = draw_get_valign();
		var _font_prev = draw_get_font();
		var _alpha_prev = draw_get_alpha();
		var _color_prev = draw_get_color();
	
		draw_set_halign(fa_left);//intended
		draw_set_valign(fa_top);
		draw_set_font(font);
		draw_set_alpha(alpha);
		draw_set_color(color);
		
		var _text = get_converted_text();
		draw_text_transformed(x,y,_text,xscale,yscale,0);
		
		draw_set_halign(_halign_prev);
		draw_set_valign(_valign_prev);
		draw_set_font(_font_prev);
		draw_set_alpha(_alpha_prev);
		draw_set_color(_color_prev);
	}
	
	function draw_cursor(){
		var _halign_prev = draw_get_halign();
		var _valign_prev = draw_get_valign();
		var _font_prev = draw_get_font();
		var _alpha_prev = draw_get_alpha();
		var _color_prev = draw_get_color();
	
		draw_set_halign(fa_left);//intended
		draw_set_valign(fa_top);
		draw_set_font(font);
		draw_set_alpha(alpha);
		draw_set_color(color);
		
		var _coord = __textbox_get_text_coord__(cursor_pos);
		draw_text_transformed(_coord[0],_coord[1],"|",xscale,yscale,0);
		
		draw_set_halign(_halign_prev);
		draw_set_valign(_valign_prev);
		draw_set_font(_font_prev);
		draw_set_alpha(_alpha_prev);
		draw_set_color(_color_prev);
	}
	
	function gain_focus(xx = mouse_x, yy = mouse_y){
		cursor_pos = __textbox_get_text_pos__([xx,yy]);
		cursor_drag_start_pos = cursor_pos;
		is_focused = true;
	}
	
	function lose_focus(str = keyboard_string){
		__textbox_push_input__(str);
		cursor_drag_start_pos = cursor_pos;
		is_focused = false;
	}
}

function __textbox_push_input__(str){
	text = string_insert(str,text,cursor_pos+1);
	cursor_pos += string_length(str);
}

function __textbox_get_text_coord__(pos){
	var _text = get_converted_text(text);
	pos = get_converted_cursor_pos(text,pos);
	
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
	
	var _height = (string_height(_text)-string_height(_text_last_full_line))*yscale;
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
	var _y = y+_height*(1-_v_adjust);
	
	return [_x,_y];
}

function __textbox_get_text_pos__(coord){
	coord = variable_clone(coord);
	var _text = get_converted_text();
	
	var _font_prev = draw_get_font();
	draw_set_font(font);
	var _last_char = string_char_at(_text,string_length(_text));
	var _last_char_half_width = string_width(_last_char)*xscale/2;
	var _last_char_half_height = string_height(_last_char)*yscale/2;
	draw_set_font(_font_prev);
	
	coord[0] -= _last_char_half_width;
	coord[1] -= _last_char_half_height;
	
	//y
	var	_dis,_next_dis,_pos,_pos_2;
	_pos = 0;
	
	do{
		_pos = string_pos_ext("\n\u200B",_text,_pos+1);
		if(_pos != 0){
			_pos++;
		}
		_dis = abs(__textbox_get_text_coord__(_pos)[1] - coord[1]);
		_pos_2 = string_pos_ext("\n\u200B",_text,_pos+1);
		if(_pos_2 == 0){
				_pos_2 = string_length(_text);
		}
		_next_dis = abs(__textbox_get_text_coord__(_pos_2+1)[1] - coord[1]);
	}until(_pos_2 >= string_length(_text) || _next_dis > _dis)
	//show_message($"{_pos} {_pos}")
	//x
	for(_pos = _pos; _pos < _pos_2+1; _pos++){
		_dis = abs(__textbox_get_text_coord__(_pos)[0] - coord[0]);
		_next_dis = abs(__textbox_get_text_coord__(_pos+1)[0] - coord[0]);
		if(_next_dis > _dis){
			break;
		}
	}
	
	//result
	return _pos;
}

function get_converted_text(text = self.text){
	text = string_replace(text,"\t",tab_space_string);
	text = string_insert(get_IME_string(),text,cursor_pos+1);
	return text;
}

function get_converted_cursor_pos(text = self.text, cursor_pos = self.cursor_pos){
	text = string_copy(text,1,cursor_pos);
	return cursor_pos + string_count("\t",text)*tab_space_count + string_length(get_IME_string());
}

function get_IME_string(){
	var _window_handle = window_handle();
	return GetImeComposition(string(_window_handle));
}

function clear_IME_string(){
	var _window_handle = window_handle();
	return ClearImeString(string(_window_handle));
}