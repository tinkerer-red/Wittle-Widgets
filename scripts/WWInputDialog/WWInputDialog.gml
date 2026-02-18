#region jsDoc
/// @func    WWInputDialog()
/// @desc    Confirm dialog variant with a single-line text input.
/// @returns {Struct.WWInputDialog}
#endregion
function WWInputDialog() : WWConfirmDialog() constructor {
	debug_name = "WWInputDialog";
	
	#region Public
		
		#region Events
		events.submitted = variable_get_hash("submitted");
		#endregion
		
		#region Components
		input = new WWInputString()
			.set_size(280, 22)
			.set_offset(0, 28);
		
		add(input);
		#endregion
		
		#region Variables
		prompt_text = "Enter value";
		placeholder_text = "";
		__submit_data__ = { dialog: self, value: "" };
		#endregion
		
		#region Builder Functions
		static set_size = function(_w, _h) {
			static __base_set_size__ = WWConfirmDialog.set_size;
			__base_set_size__(_w, _h);
			__apply_fixed_layout__();
			return self;
		};

		static set_prompt = function(_text) {
			prompt_text = string(_text);
			set_message(prompt_text);
			return self;
		};
		
		static set_value = function(_value) {
			input.set_value(string(_value));
			return self;
		};
		
		static set_placeholder = function(_text="") {
			placeholder_text = string(_text);
			var _field = input.get_field();
			if (is_struct(_field) && is_callable(_field.set_caption)) {
				_field.set_caption(placeholder_text);
			}
			return self;
		};
		#endregion
		
		#region Functions
		static on_submitted = function(_func) { add_event_listener(events.submitted, _func); return self; };
		static get_prompt = function() { return prompt_text; };
		static get_value = function() { return input.get_value(); };
		static get_placeholder = function() { return placeholder_text; };
		
		static submit = function() {
			var _v = input.get_value();
			__submit_data__.dialog = self;
			__submit_data__.value = _v;
			trigger_event(events.submitted, __submit_data__);
			trigger_event(events.confirmed, __event_payload__("confirmed"));
			set_open(false);
			return self;
		};
		#endregion
		
	#endregion
	
	#region Private
		#region Functions
		static __apply_fixed_layout__ = function() {
			var _pad = 10;
			input.set_offset(_pad, 24);
			input.set_size(max(32, width - _pad * 2), 22);
			confirm_button.set_offset(10, 78);
			cancel_button.set_offset(114, 78);
			content_region.set_canvas_size_from_children();
		};
		#endregion
	#endregion
	
	confirm_button.set_callback(function() {
		submit();
	});
	input.on_submit(function(_d) {
		submit();
	});
	
	set_title("Input");
	set_size(340, 170);
	set_prompt("Enter value");
	set_confirm_text("OK");
	set_cancel_text("Cancel");
	set_placeholder("");
	set_value("");
	__apply_fixed_layout__();
	set_open(false);
}
