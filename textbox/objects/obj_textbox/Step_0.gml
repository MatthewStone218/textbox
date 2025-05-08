/// @description 여기에 설명 삽입
// 이 에디터에 코드를 작성할 수 있습니다

if(mouse_check_button_pressed(mb_left)){
	if(position_meeting(mouse_x,mouse_y,id)){
		tbox.gain_focus();
	} else {
		tbox.lose_focus();
	}
}

if(tbox.is_focused){
	tbox.handle_input(keyboard_string);
	keyboard_string = "";
}