#region jsDoc
/// @func    WWFolder()
/// @desc    Folder/tree node component built on WWButtonText.
///          The folder IS the header button, and it owns a child container (WWCore)
///          that holds folder items. Clicking the header toggles open/closed.
/// @returns {Struct.WWFolder}
#endregion
function WWFolder() : WWButtonText() constructor {
	debug_name = "WWFolder";

	#region Public

		#region Events

			events.opened = variable_get_hash("opened");
			events.closed = variable_get_hash("closed");
			
			add_event_listener(events.released, function(_data) {
				set_open(!is_open);

				if (is_open) {
					trigger_event(events.opened);
				} else {
					trigger_event(events.closed);
				}
			});
			
		#endregion

		#region Variables

			__is_ww_folder__ = true;

			is_open = true;

			// Header sizing rules:
			// - height is the header height
			// - if user sets height to 0, we use __header_height_default__
			__header_height_default__ = 26;

			// Child layout inside the container
			__children_x_offset__ = 0;
			__children_y_spacing__ = 0;

		#endregion

		#region Builder Functions

			#region jsDoc
			/// @func    set_size(_width, _height)
			/// @desc    Sets the header size. If _height <= 0, uses default header height.
			/// @param   {Real} _width
			/// @param   {Real} _height
			/// @returns {Struct.WWFolder} self
			#endregion
			static set_size = function(_width, _height) {
				static __base_set_size__ = WWCore.set_size;

				if (is_undefined(_width)) { _width = width; }
				if (is_undefined(_height)) { _height = height; }

				if (_height <= 0) {
					_height = __header_height_default__;
				}

				__base_set_size__(_width, _height);

				update_component_positions();
				__update_group_region__();

				return self;
			}

			#region jsDoc
			/// @func    set_header_height(_height)
			/// @desc    Sets the default header height used when set_size(_, 0) is called.
			/// @param   {Real} _height
			/// @returns {Struct.WWFolder} self
			#endregion
			static set_header_height = function(_height) {
				if (is_undefined(_height)) { _height = __header_height_default__; }
				if (_height <= 0) { _height = 1; }

				__header_height_default__ = _height;

				// Keep current header valid if it was 0 or negative.
				if (height <= 0) {
					set_size(width, _height);
				}

				return self;
			}

			#region jsDoc
			/// @func    set_children_offsets(_xoff, _yoff)
			/// @desc    Sets indenting and vertical spacing for sub components inside the folder container.
			/// @param   {Real} _xoff
			/// @param   {Real} _yoff
			/// @returns {Struct.WWFolder} self
			#endregion
			static set_children_offsets = function(_xoff, _yoff) {
				if (is_undefined(_xoff)) { _xoff = 0; }
				if (is_undefined(_yoff)) { _yoff = 0; }

				__children_x_offset__ = _xoff;
				__children_y_spacing__ = _yoff;

				if (is_open) {
					__layout_container_children__();
					update_component_positions();
					__update_group_region__();
					__notify_parent_folder_reflow__();
				}

				return self;
			}

			#region jsDoc
			/// @func    set_open(_is_open)
			/// @desc    Sets the folder open state. If the parent is a WWFolder, requests parent to reflow.
			/// @param   {Bool} _is_open
			/// @returns {Struct.WWFolder} self
			#endregion
			static set_open = function(_is_open) {
				if (is_undefined(_is_open)) { _is_open = true; }

				var _prev_open = is_open;
				is_open = _is_open;

				if (_prev_open != is_open) {
					__container__.set_active(is_open);

					if (is_open) {
						__layout_container_children__();
					}

					update_component_positions();
					__update_group_region__();

					// Critical: if we are inside another folder, ask it to reflow its children
					__notify_parent_folder_reflow__();
				}

				return self;
			}

		#endregion

		#region Functions

			#region jsDoc
			/// @func    add(_comp)
			/// @desc    Adds a component (or array) into the folder container.
			/// @param   {Struct.WWCore|Array} _comp
			/// @returns {Undefined}
			#endregion
			static add = function(_comp) {
				var _result = __container__.add(_comp);
				
				if (is_open) {
					__layout_container_children__();
					update_component_positions();
					__update_group_region__();
					__notify_parent_folder_reflow__();
				}

				return _result;
			}

			#region jsDoc
			/// @func    insert(_comp, _index)
			/// @desc    Inserts a component (or array) into the folder container children.
			/// @param   {Struct.WWCore|Array} _comp
			/// @param   {Real} _index
			/// @returns {Undefined}
			#endregion
			static insert = function(_comp, _index) {
				var _result = __container__.insert(_comp, _index);

				if (is_open) {
					__layout_container_children__();
					update_component_positions();
					__update_group_region__();
					__notify_parent_folder_reflow__();
				}

				return _result;
			}

			#region jsDoc
			/// @func    clear_children()
			/// @desc    Clears only folder items (does not remove the container itself).
			/// @returns {Struct.WWFolder} self
			#endregion
			static clear_children = function() {
				__container__.clear_children();

				if (is_open) {
					__layout_container_children__();
				}

				update_component_positions();
				__update_group_region__();
				__notify_parent_folder_reflow__();

				return self;
			}

			#region jsDoc
			/// @func    get_container()
			/// @desc    Returns the internal container (advanced usage).
			/// @returns {Struct.WWCore}
			#endregion
			static get_container = function() {
				return __container__;
			}

			#region jsDoc
			/// @func    relayout_children()
			/// @desc    Forces a reflow of this folder's container children and group size.
			///          Safe to call from a child folder when it opens/closes.
			/// @returns {Undefined}
			#endregion
			static relayout_children = function() {
				if (is_open) {
					__layout_container_children__();
				}

				update_component_positions();
				__update_group_region__();
			}

			#region jsDoc
			/// @func    update_component_positions()
			/// @desc    Updates the container position and lays out children when open.
			/// @returns {Undefined}
			#endregion
			static update_component_positions = function() {
				static __base_update__ = WWCore.update_component_positions;

				// Ensure header height is never 0, otherwise container will overlap header.
				if (height <= 0) {
					set_size(width, __header_height_default__);
				}

				__container__.set_active(is_open);

				// Container is below the header area.
				__container__.set_offset(0, height);

				if (is_open) {
					__layout_container_children__();
				}

				// Positions direct children (container).
				__base_update__();

				// Propagate into container after it has its world position.
				if (is_open) {
					__container__.update_component_positions();
				}

				__update_group_region__();
			}

		#endregion

	#endregion

	#region Private

		#region Variables

			__container__ = new WWCore();

			// Add container as a child of the header button (this object).
			// Must call the base add, not our overridden add that forwards into the container.
			static __base_add__ = WWCore.add;
			__base_add__([__container__]);

		#endregion

		#region Functions

			#region jsDoc
			/// @func    __layout_container_children__()
			/// @desc    Stacks the container children vertically using offsets.
			///          Ensures each child has up-to-date group sizing before stacking.
			/// @returns {Undefined}
			#endregion
			static __layout_container_children__ = function() {
				var _current_y = 0;
				var _child_index = 0;

				repeat(__container__.__children_count__) {
					var _child_comp = __container__.__children__[_child_index];

					// Ensure child layout and group is current before we use its group height.
					_child_comp.update_component_positions();
					_child_comp.__update_group_region__();

					_child_comp.set_offset(__children_x_offset__, _current_y);

					var _child_height = _child_comp.__group__.height;
					if (is_undefined(_child_height)) { _child_height = _child_comp.height; }
					if (is_undefined(_child_height)) { _child_height = 0; }

					_current_y += _child_height + __children_y_spacing__;

					_child_index += 1;
				}
			}

			#region jsDoc
			/// @func    __update_group_region__()
			/// @desc    Group sizing but ignores the container when closed.
			/// @returns {Undefined}
			#endregion
			static __update_group_region__ = function() {
				var _group_width = width;
				var _group_height = height;

				var _prev_width = __group__.width;
				var _prev_height = __group__.height;

				if (is_open) {
					var _xoff = __container__.x_offset;
					var _yoff = __container__.y_offset;

					_group_width = max(_group_width, _xoff + __container__.__group__.width);
					_group_height = max(_group_height, _yoff + __container__.__group__.height);
				}

				__group__.width = _group_width;
				__group__.height = _group_height;

				if (__is_child__) {
					if (_prev_width != _group_width)
					|| (_prev_height != _group_height) {
						__parent__.__update_group_region__();
					}
				}
			}

			#region jsDoc
			/// @func    __notify_parent_folder_reflow__()
			/// @desc    If our parent is a WWFolder, request it to relayout its children.
			/// @returns {Undefined}
			#endregion
			static __notify_parent_folder_reflow__ = function() {
				if (!__is_child__) { exit; }
				
				var _parent_comp = __parent__;
				if (is_instanceof(_parent_comp, WWCore)) {
					
					if (!_parent_comp.__is_child__) { exit; }
					
					var _parent_comp = _parent_comp.__parent__;
					if (is_instanceof(_parent_comp, WWFolder)) {
						_parent_comp.relayout_children();
					}
				}
			}
			
		#endregion

	#endregion

	// Post init
	if (height <= 0) {
		set_size(width, __header_height_default__);
	}

	__container__.set_active(is_open);
	update_component_positions();
	__update_group_region__();
}
