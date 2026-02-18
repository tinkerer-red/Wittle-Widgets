#region jsDoc
/// @func    WWConfirmDialog()
/// @desc    Modal-like confirm dialog window with message, confirm, and optional cancel button.
/// @returns {Struct.WWConfirmDialog}
#endregion
function WWConfirmDialog() : WWWindow() constructor {
	debug_name = "WWConfirmDialog";
	
	#region Public
		
		#region Events
		events.confirmed = variable_get_hash("confirmed");
		events.cancelled = variable_get_hash("cancelled");
		#endregion
		
		#region Components
		message_label = new WWLabel()
			.set_text("Are you sure?")
			.set_offset(0, 0);
		
		confirm_button = new WWButtonText()
			.set_text("OK")
			.set_size(96, 24)
			.set_callback(function() {
				trigger_event(events.confirmed, __event_payload__("confirmed"));
				set_open(false);
			});
		
		cancel_button = new WWButtonText()
			.set_text("Cancel")
			.set_size(96, 24)
			.set_callback(function() {
				trigger_event(events.cancelled, __event_payload__("cancelled"));
				set_open(false);
			});
		
		add([message_label, confirm_button, cancel_button]);
		#endregion
		
		#region Variables
		message_text = "Are you sure?";
		confirm_text = "OK";
		cancel_text = "Cancel";
		show_cancel = true;
		__event_data__ = { dialog: self, message: "", choice: "" };
		#endregion
		
		#region Builder Functions
		static set_size = function(_w, _h) {
			static __base_set_size__ = WWWindow.set_size;
			__base_set_size__(_w, _h);
			__apply_fixed_layout__();
			return self;
		};

		static set_message = function(_text) {
			message_text = string(_text);
			message_label.set_text(message_text);
			return self;
		};
		
		static set_confirm_text = function(_text) {
			confirm_text = string(_text);
			confirm_button.set_text(confirm_text);
			return self;
		};
		
		static set_cancel_text = function(_text) {
			cancel_text = string(_text);
			cancel_button.set_text(cancel_text);
			return self;
		};
		
		static set_show_cancel = function(_enabled=true) {
			show_cancel = _enabled;
			cancel_button.set_active(show_cancel);
			return self;
		};
		#endregion
		
		#region Functions
		static on_confirmed = function(_func) { add_event_listener(events.confirmed, _func); return self; };
		static on_cancelled = function(_func) { add_event_listener(events.cancelled, _func); return self; };
		
		static confirm = function() {
			trigger_event(events.confirmed, __event_payload__("confirmed"));
			set_open(false);
			return self;
		};
		
		static cancel = function() {
			trigger_event(events.cancelled, __event_payload__("cancelled"));
			set_open(false);
			return self;
		};
		
		static open_dialog = function() {
			set_open(true);
			bring_to_front();
			return self;
		};
		
		static get_message = function() { return message_text; };
		static get_confirm_text = function() { return confirm_text; };
		static get_cancel_text = function() { return cancel_text; };
		static get_show_cancel = function() { return show_cancel; };
		#endregion
		
	#endregion
	
	#region Private
		#region Functions
		static __event_payload__ = function(_choice="") {
			__event_data__.dialog = self;
			__event_data__.message = message_text;
			__event_data__.choice = _choice;
			return __event_data__;
		};
		
		static __apply_fixed_layout__ = function() {
			message_label.set_offset(10, 0);
			confirm_button.set_offset(10, 78);
			cancel_button.set_offset(114, 78);
			content_region.set_canvas_size_from_children();
		};
		#endregion
	#endregion
	
	set_title("Confirm");
	set_size(320, 140);
	set_scrollbars_enabled(false, false);
	set_smooth_scrolling(false);
	set_message("Are you sure?");
	set_confirm_text("OK");
	set_cancel_text("Cancel");
	set_show_cancel(true);
	__apply_fixed_layout__();
	set_open(false);
}
