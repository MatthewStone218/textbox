// v2.3.0에 대한 스크립트 어셋 변경됨 자세한 정보는
// https://help.yoyogames.com/hc/en-us/articles/360005277377 참조
function textbox(struct = {}){
	struct[$"x"] ??= x;
	struct[$"y"] ??= y;
	return new __textbox_class_element__(struct);
}

//빈 문자나 탭 문자는 모두 text에 당초 포함되는 게 전재. tab, ime만 계산시 직전 적용

function __textbox_class_element__(struct) constructor{
	text = struct[$"text"] ?? "";
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
	cursor_pos = struct[$"cursor_pos"] ?? 0;
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
		
		draw_text_transformed(x,y,string_insert(get_IME_string(),text,cursor_pos+1),xscale,yscale,0);
		
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
	var _text = text;
	
	var _font_prev = draw_get_font();
	draw_set_font(font);
	var _last_char = string_char_at(_text,string_length(_text));
	var _last_char_half_width = string_width(_last_char)*xscale/2;
	var _last_char_half_height = string_height(_last_char)*yscale/2;
	draw_set_font(_font_prev);
	
	coord[0] += _last_char_half_width;
	coord[1] += _last_char_half_height;
	
	//y
	var _nearest_dis = 10000000000;
	var _dis = 10000000000;
	var _ln_pos = 1;
	var _pos = 1;

	while(_ln_pos >= _pos){
		_pos = _ln_pos;
		_ln_pos = string_pos_ext("\n",_text,_ln_pos+1);
		if(_ln_pos > 0){
			if(_nearest_dis >= _dis){
				_dis = abs(__textbox_get_text_coord__(_ln_pos)[1] - coord[1]);
				_nearest_dis = _dis;
			}
		} else {
			break;
		}
	}
	//x
	var _line = string_copy(_text, _ln_pos+1,string_length(_text));
	var _ln_pos_2 = string_pos_ext("\n",_text,_ln_pos+1);
	if(_ln_pos_2 > 0){
		_line = string_copy(_text,_ln_pos+1,_ln_pos_2-_ln_pos+1);
	}
	
	var _nearest_dis = 10000000000;
	var _dis = 10000000000;
	for(var i = 1; i < string_length(_line)+1; i++){
		if(_nearest_dis >= _dis){
			_nearest_dis = _dis;
			_pos++;
		}
		
		var _char_coord = __textbox_get_text_coord__(_pos+i);
		var _dis = abs(_char_coord[0]-coord[0]);
	}
	if(_nearest_dis >= _dis){
		_nearest_dis = _dis;
		_pos++;
	}
	
	//result
	return _pos;
}

function get_IME_string(){
	var _window_handle = window_handle();
	return GetImeComposition(string(_window_handle));
}

function clear_IME_string(){
	var _window_handle = window_handle();
	return ClearImeString(string(_window_handle));
}