__build_ui__ = function() {

    var _root = new WWCore()
        .set_offset(0, 0)
        .set_size(1280, 720)
        .set_background_color(c_black)
        .set_enabled(true);

    // Theme
    var _page_bg = make_color_rgb(16, 16, 18);
    var _card_bg = make_color_rgb(46, 46, 52);
    var _card_hdr = make_color_rgb(34, 34, 38);
    var _textbox_bg = make_color_rgb(24, 24, 26);

    var _subtitle_color = make_color_rgb(180, 180, 190);
    var _footer_bg = make_color_rgb(34, 34, 38);
    var _footer_color = make_color_rgb(200, 200, 210);

    // Backdrop
    var _page_backdrop = new WWCore()
        .set_offset(12, 12)
        .set_size(1256, 696)
        .set_background_color(_page_bg);
    _root.add(_page_backdrop);

    // Header bar
    var _header_x = 24;
    var _header_y = 14;
    var _header_w = 1232;
    var _header_h = 58;

    var _header_back = new WWCore()
        .set_offset(_header_x, _header_y)
        .set_size(_header_w, _header_h)
        .set_background_color(_card_hdr);
    _root.add(_header_back);

    // Title and subtitle (slightly nicer spacing)
    var _title_text = title;
    if (is_undefined(_title_text)) _title_text = "Textbox Renderer Demo";

    var _title_label = new WWLabel()
        .set_offset(_header_x + 12, _header_y + 6)
        .set_size(_header_w - 340, 24)
        .set_text(_title_text)
        .set_text_color(c_white)
        .set_text_font(fnt_ww_default_big);
    _root.add(_title_label);

    if (!is_undefined(subtitle)) {
        var _subtitle_label = new WWLabel()
            .set_offset(_header_x + 12, _header_y + 30)
            .set_size(_header_w - 340, 18)
            .set_text(subtitle)
            .set_text_color(_subtitle_color);
        _root.add(_subtitle_label);
    }

    // Nav buttons (vertically centered inside header)
    __build_nav_buttons__(_root, _header_x, _header_y, _header_w, _header_h);

    // Content card
    var _card_x = 24;
    var _card_y = 86;
    var _card_w = 1232;
    var _card_h = 586;

    var _content_card = new WWCore()
        .set_offset(_card_x, _card_y)
        .set_size(_card_w, _card_h)
        .set_background_color(_card_bg);
    _root.add(_content_card);

    // Inner layout
    var _pad = 14;
    var _label_h = 18;
    var _label_gap = 8;
    var _gap_x = 14;

    var _inner_x = _card_x + _pad;
    var _inner_y = _card_y + _pad;
    var _inner_w = _card_w - (_pad * 2);
    var _inner_h = _card_h - (_pad * 2);

    var _half_w = floor((_inner_w - _gap_x) * 0.5);

    // Column labels (configurable)
    var _left_label_text = left_label;
    if (is_undefined(_left_label_text)) _left_label_text = "Input";

    var _right_label_text = right_label;
    if (is_undefined(_right_label_text)) _right_label_text = "Preview";

    var _label_left = new WWLabel()
        .set_offset(_inner_x, _inner_y)
        .set_size(_half_w, _label_h)
        .set_text(_left_label_text)
        .set_text_color(_subtitle_color);
    _root.add(_label_left);

    var _label_right = new WWLabel()
        .set_offset(_inner_x + _half_w + _gap_x, _inner_y)
        .set_size(_half_w, _label_h)
        .set_text(_right_label_text)
        .set_text_color(_subtitle_color);
    _root.add(_label_right);

    // Pair area (below labels)
    var _pair_x = _inner_x;
    var _pair_y = _inner_y + _label_h + _label_gap;
    var _pair_h = _inner_h - (_label_h + _label_gap);

    // Vertical divider (reads more intentional than empty gap)
    __build_vertical_divider__(
        _root,
        _pair_x + _half_w + floor(_gap_x * 0.5),
        _inner_y,
        _pair_h + (_label_h + _label_gap),
        make_color_rgb(60, 60, 68)
    );

    // Mirror pair with framed boxes
    __build_mirror_pair__(
        _root,
        _textbox_bg,
        _pair_x,
        _pair_y,
        _half_w,
        _pair_h,
        _gap_x,
        text,
        left_init,
        right_init
    );

    return _root;
};

__build_nav_buttons__ = function(_root, _header_x, _header_y, _header_w, _header_h) {

    var _button_width = 90;
    var _button_height = 22;
    var _button_gap = 8;

    var _nav_w = (_button_width * 2) + 110 + (_button_gap * 2);
    var _nav_x = _header_x + _header_w - _nav_w - 12;
    var _nav_y = _header_y + floor((_header_h - _button_height) * 0.5);

    // Prev
    var _button_prev = new WWButtonText()
        .set_offset(_nav_x, _nav_y)
        .set_size(_button_width, _button_height)
        .set_text("< Prev");

    if (is_undefined(prev_room)) {
        _button_prev.set_enabled(false);
    } else {
        _button_prev.set_callback(function() {
            room_goto(prev_room);
        });
    }
    _root.add(_button_prev);

    // Next
    var _button_next = new WWButtonText()
        .set_offset(_nav_x + _button_width + _button_gap, _nav_y)
        .set_size(_button_width, _button_height)
        .set_text("Next >");

    if (is_undefined(next_room)) {
        _button_next.set_enabled(false);
    } else {
        _button_next.set_callback(function() {
            room_goto(next_room);
        });
    }
    _root.add(_button_next);

    // Return
    var _button_return = new WWButtonText()
        .set_offset(_nav_x + (_button_width + _button_gap) * 2, _nav_y)
        .set_size(110, _button_height)
        .set_text("Return");

    if (is_undefined(root_room)) {
        _button_return.set_enabled(false);
    } else {
        _button_return.set_callback(function() {
            room_goto(root_room);
        });
    }
    _root.add(_button_return);
};

__build_vertical_divider__ = function(_root, _x, _y, _h, _color) {

    var _divider = new WWCore()
        .set_offset(_x, _y)
        .set_size(1, _h)
        .set_background_color(_color);

    _root.add(_divider);
};

__build_mirror_pair__ = function(
    _root,
    _textbox_bg,
    _base_x,
    _base_y,
    _box_w,
    _box_h,
    _gap_x,
    _text_value,
    _left_init_fn,
    _right_init_fn
) {

    // Frame colors
    var _frame_color = make_color_rgb(60, 60, 68);
    var _preview_cursor = _textbox_bg;
    var _preview_highlight = make_color_rgb(60, 66, 72);

    // Frame thickness
    var _frame = 1;

    // Left frame
    var _left_frame = new WWCore()
        .set_offset(_base_x, _base_y)
        .set_size(_box_w, _box_h)
        .set_background_color(_frame_color);
    _root.add(_left_frame);

    // Right frame
    var _right_frame = new WWCore()
        .set_offset(_base_x + _box_w + _gap_x, _base_y)
        .set_size(_box_w, _box_h)
        .set_background_color(_frame_color);
    _root.add(_right_frame);

    // Left textbox (inset inside frame)
    var _left_box = new WWTextBoxV3()
        .set_offset(_base_x + _frame, _base_y + _frame)
        .set_size(_box_w - (_frame * 2), _box_h - (_frame * 2))
        .set_background_color(_textbox_bg)
        .set_text(_text_value)
        .set_text_color(c_white)
        .set_highlight_color(#78848A)
        .set_cursor_color(c_white)
        .set_wrap_enabled(true);

    // Right textbox (inset inside frame)
    var _right_box = new WWTextBoxV3()
        .set_offset((_base_x + _box_w + _gap_x) + _frame, _base_y + _frame)
        .set_size(_box_w - (_frame * 2), _box_h - (_frame * 2))
        .set_background_color(_textbox_bg)
        .set_text(_text_value)
        .set_text_color(c_white)
        .set_highlight_color(_preview_highlight)
        .set_cursor_color(_preview_cursor)
        .set_wrap_enabled(true)
		.set_read_only(true);
    
    // Init hooks
    if (is_callable(_left_init_fn)) {
        _left_init_fn(_left_box);
    }
    if (is_callable(_right_init_fn)) {
        _right_init_fn(_right_box);
    }

    // Left drives right
    _left_box.on_change(method({ left_ref: _left_box, right_ref: _right_box }, function() {
        right_ref.set_text(left_ref.get_text());
    }));

    _root.add(_left_box);
    _root.add(_right_box);

    return {
        text_left: _left_box,
        text_right: _right_box
    };
};

