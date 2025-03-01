function GUICompRegion() : GUICompController() constructor {
	debug_name = "GUICompRegion";
	
	#region Public
		
		#region Builder functions
			
			#region jsDoc
			/// @func    set_size()
			/// @desc    Set the reletive region for all click selections. Reletive to the x,y of the component.
			/// @self    GUICompCore
			/// @param   {real} left : The left side of the bounding box
			/// @param   {real} top : The top side of the bounding box
			/// @param   {real} right : The right side of the bounding box
			/// @param   {real} bottom : The bottom side of the bounding box
			/// @returns {Struct.GUICompCore}
			#endregion
			static set_size = function(_left, _top, _right, _bottom) {
				static __set_size = GUICompController.set_size;
				__set_size(_left, _top, _right, _bottom);
				
				__scroll_horz__.set_coverage_size(get_coverage_width());
				__scroll_vert__.set_coverage_size(get_coverage_height());
				
				update_component_positions();
				
				__update_scrollbar_thumbs__();
				__update_group_region__();
				
				set_scrollbar_sizes(__scroll_horz_size__, __scroll_vert_size__)
				
				//update click regions
				if (__is_controller__) {
					__update_group_region__();
				}
				else {
					if (__is_child__) {
						__parent__.__update_group_region__()
					}
				}
				
				return self;
			}
			#region jsDoc
			/// @func    set_smooth_scrolling()
			/// @desc    Sets the scrolling to be smooth
			/// @self    GUICompScrollRegion
			/// @param   {Bool} name : desc
			/// @returns {Struct.GUICompScrollRegion}
			#endregion
			static set_smooth_scrolling = function(_smooth=false) {
				scroll.smooth = _smooth;
				
				return self;
			}
			#region jsDoc
			/// @func    set_canvas_size()
			/// @desc    Sets the canvas size. This is used to help calculate the maximum possible scroll directions and the scroll bars height based off how much is viewed with in a region. If a value of -1 is used it will auto generate the width or height based on the children component's regions.
			///
			///          .
			///
			///          Example: 
			///
			///          if it's a scrolling text box which is 20 lines big and you only want to show 5 lines,
			///
			///          use `set_canvas_size(-1, string_height("M")*20)`
			///
			///          .
			///
			///          NOTE:
			///
			///          This should be called after the children have been added.
			/// @self    GUICompScrollRegion
			/// @param   {Real} width  : The width of the canvas, a value of -1 will adapt to the region's width.
			/// @param   {Real} height : The height of the canvas, a value of -1 will adapt to the region's height.
			/// @returns {Struct.GUICompScrollRegion}
			#endregion
			static set_canvas_size = function(_width=undefined, _height=undefined) {
				if (_width == -1)
				|| (_height == -1) {
					set_canvas_size_from_children();
				}
				
				//if a value was undefined let it use it's previous value
				//_width = (is_undefined(_width)) ? __canvas_region__.get_width() : _width;
				//_height = (is_undefined(_height)) ? __canvas_region__.get_height() : _height;
				
				if (!is_undefined(_width)){
					__canvas_region__.left   = (_width == -1)  ? __canvas_region__.left   : 0;
					__canvas_region__.right  = (_width == -1)  ? __canvas_region__.right  : _width;
					var _addapted_w = __canvas_region__.get_width()  - get_coverage_width();
					__scroll_horz__.set_canvas_size(__canvas_region__.get_width() );
					set_scrollbar_hidden(_addapted_w <= 0, undefined);
				}
				
				if (!is_undefined(_height)) {
					__canvas_region__.top    = (_height == -1) ? __canvas_region__.top    : 0;
					__canvas_region__.bottom = (_height == -1) ? __canvas_region__.bottom : _height;
					var _addapted_h = __canvas_region__.get_height() - get_coverage_height();
					__scroll_vert__.set_canvas_size(__canvas_region__.get_height());
					set_scrollbar_hidden(undefined, _addapted_h <= 0);
				}
				
				__update_scrollbar_thumbs__();
				
				return self;
			}
			#region jsDoc
			/// @func    set_canvas_size_from_children()
			/// @desc    Automatically sets the canvas size from the given children components' regions. This is used to help calculate the maximum possible scroll directions and the scroll bars height based off how much is viewed with in a region. If a value of -1 is used it will auto generate the width or height based on the children component's regions.
			///
			///          .
			///
			///          NOTE:
			///
			///          .
			///
			///          This should be called after the children have been added.
			/// @self    GUICompScrollRegion
			/// @param   {Real} width  : The width of the canvas, a value of -1 will adapt to the region's width.
			/// @param   {Real} height : The height of the canvas, a value of -1 will adapt to the region's height.
			/// @returns {Struct.GUICompScrollRegion}
			#endregion
			static set_canvas_size_from_children = function() {
				var _component, xoff, yoff;
				
				var _left   = 0;
				var _top    = 0;
				var _right  = 0;
				var _bottom = 0;
				
				var _i = 0; repeat(__children_count__) {
					
					_component = __children__[_i];
					xoff = _component.x-(self.x+scroll.x_off);
					yoff = _component.y-(self.y+scroll.y_off);
					
					if (_component.__is_controller__)
					&& (_component.is_open) {
						_left   = min(_left,   xoff+_component.__group_region__.left);
						_top    = min(_top,    yoff+_component.__group_region__.top);
						_right  = max(_right,  xoff+_component.__group_region__.right);
						_bottom = max(_bottom, yoff+_component.__group_region__.bottom);
					}
					else {
						_left   = min(_left,   xoff+_component.region.left);
						_top    = min(_top,    yoff+_component.region.top);
						_right  = max(_right,  xoff+_component.region.right);
						_bottom = max(_bottom, yoff+_component.region.bottom);
					}
					
					_i+=1
				}
				
				
				__update_scrollbar_thumbs__();
				
				__canvas_region__.left   = _left;
				__canvas_region__.top    = _top;
				__canvas_region__.right  = _right;
				__canvas_region__.bottom = _bottom;
				
				var _addapted_w = __canvas_region__.get_width()  - get_coverage_width();
				var _addapted_h = __canvas_region__.get_height() - get_coverage_height();
				
				__scroll_horz__.set_canvas_size(_addapted_w);
				
				__scroll_vert__.set_canvas_size(_addapted_h);
				
				set_scrollbar_hidden(_addapted_w < 0, _addapted_h < 0);
				
				return self;
			}
			#region jsDoc
			/// @func    set_scrollbar_horz_sprites()
			/// @desc    Sets the sprites for the horizontal scrollbar
			/// @self    GUICompScrollRegion
			/// @param   {Asset.GMSprite} spr_background : The scrollbar's background sprite
			/// @param   {Asset.GMSprite} spr_thumb : The scrollbar's thumb sprite
			/// @param   {Asset.GMSprite} spr_button_left : The scrollbar's left button sprite
			/// @param   {Asset.GMSprite} spr_button_right : The scrollbar's right button sprite
			/// @returns {Struct.GUICompScrollRegion}
			#endregion
			static set_scrollbar_horz_sprites = function(_bg, _thumb, _dec, _inc) {
				__scroll_horz__.set_button_sprites(_dec, _inc);
				__scroll_horz__.set_background_sprite(_bg);
				__scroll_horz__.set_thumb_sprite(_thumb);
				
				update_component_positions();
				
				__update_scrollbar_thumbs__();
				
				return self;
			}
			#region jsDoc
			/// @func    set_scrollbar_vert_sprites()
			/// @desc    Sets the sprites for the vertical scrollbar
			/// @self    GUICompScrollRegion
			/// @param   {Asset.GMSprite} spr_background : The scrollbar's background sprite
			/// @param   {Asset.GMSprite} spr_thumb : The scrollbar's thumb sprite
			/// @param   {Asset.GMSprite} spr_button_up : The scrollbar's up button sprite
			/// @param   {Asset.GMSprite} spr_button_down : The scrollbar's down button sprite
			/// @returns {Struct.GUICompScrollRegion}
			#endregion
			static set_scrollbar_vert_sprites = function(_bg, _thumb, _dec, _inc) {
				__scroll_vert__.set_button_sprites(_dec, _inc);
				__scroll_vert__.set_background_sprite(_bg);
				__scroll_vert__.set_thumb_sprite(_thumb);
				
				update_component_positions();
				
				__update_scrollbar_thumbs__();
				
				return self;
			}
			#region jsDoc
			/// @func    set_scrollbar_button_usage()
			/// @desc    Sets the scroll bars buttons to either be used or not. This will toggle if they are executed, and drawn depending of if they are active or not.
			/// @self    GUICompScrollRegion
			/// @param   {Bool} used : The scrollbars' buttons are used.
			/// @returns {Struct.GUICompScrollRegion}
			#endregion
			static set_scrollbar_button_usage = function(_used) {
				__scroll_horz__.set_button_usage(_used);
				__scroll_vert__.set_button_usage(_used);
				
				return self;
			}
			#region jsDoc
			/// @func    set_scrollbar_sizes()
			/// @desc    Sets the height of the horizontal scroll bar, and the width of the vertical scroll bar, these will help determin how much remaining room in the region we have to make use of for views.
			/// @self    GUICompScrollRegion
			/// @param   {Real} horz_height : The horizontal scrollbars' height.
			/// @param   {Real} vert_width  : The vertical scrollbars' width.
			/// @returns {Struct.GUICompScrollRegion}
			#endregion
			static set_scrollbar_sizes = function(_horz_height, _vert_width) {
				
				if (is_undefined(_horz_height) || is_undefined(_vert_width)) return;
				
				__scroll_horz_size__ = _horz_height;
				__scroll_vert_size__ = _vert_width;
				__scroll_horz__.set_size(0, 0, region.get_width() - _vert_width, _horz_height)
				__scroll_vert__.set_size(0, 0, _vert_width, region.get_height() - _horz_height)
				
				__scroll_horz__.set_coverage_size(get_coverage_width());
				__scroll_vert__.set_coverage_size(get_coverage_height());
				
				update_component_positions();
				
				__update_scrollbar_thumbs__();
				
				return self;
			}
			#region jsDoc
			/// @func    set_scrollbar_hidden()
			/// @desc    Sets the scrollbars to be hidden or not.
			/// @self    GUICompScrollRegion
			/// @param   {Bool} horz_hidden : If the horizontal scrollbar is hidden. If left undefined it will use the previous setting
			/// @param   {Bool} vert_hidden : If the vertical scrollbar is hidden. If left undefined it will use the previous setting
			/// @returns {Struct.GUICompScrollRegion}
			#endregion
			static set_scrollbar_hidden = function(_horz_hidden=undefined, _vert_hidden=undefined) {
				//make sure both values get updated at the same time
				_horz_hidden = (_horz_hidden == undefined) ? __scroll_horz_hidden__ : _horz_hidden;
				_vert_hidden = (_vert_hidden == undefined) ? __scroll_vert_hidden__ : _vert_hidden;
				
				//horz
				__scroll_horz_hidden__ = (is_undefined(_horz_hidden)) ? __scroll_horz_hidden__ : _horz_hidden
				var _view_width  = (__scroll_vert_hidden__) ? region.get_width()  : region.get_width()  - __scroll_vert_size__
				__scroll_horz__.set_size(0, 0, _view_width, __scroll_horz_size__)
				
				//vert
				__scroll_vert_hidden__ = (is_undefined(_vert_hidden)) ? __scroll_vert_hidden__ : _vert_hidden
				var _view_height = (__scroll_horz_hidden__) ? region.get_height() : region.get_height() - __scroll_horz_size__
				__scroll_vert__.set_size(0, 0, __scroll_vert_size__, _view_height)
				
				update_component_positions();
				
				return self;
			}
			#region jsDoc
			/// @func    set_vert_scroll()
			/// @desc    Sets the vertical scroll offset.
			/// @self    GUICompScrollRegion
			/// @param   {Real} scroll_off : The scrollbar's offset.
			/// @returns {Struct.GUICompScrollRegion}
			#endregion
			static set_vert_scroll = function(_y_off=0) {
				scroll.y_off = clamp(_y_off, min(0, -__canvas_region__.get_height()), 0);
				__scroll_vert__.set_value(-scroll.y_off);
				update_component_positions();
			}
			#region jsDoc
			/// @func    set_horz_scroll()
			/// @desc    Sets the horizontal scroll offset.
			/// @self    GUICompScrollRegion
			/// @param   {Real} scroll_off : The scrollbar's offset.
			/// @returns {Struct.GUICompScrollRegion}
			#endregion
			static set_horz_scroll = function(_x_off=0) {
				scroll.x_off = clamp(_x_off, min(0, -__canvas_region__.get_width()), 0);
				
				__scroll_horz__.set_value(-scroll.x_off);
				
				update_component_positions()
			}
			#region jsDoc
			/// @func    get_horz_scroll()
			/// @desc    Get scroll x offset.
			/// @self    GUICompTextbox
			/// @returns {Real}
			#endregion
			static get_horz_scroll = function() {
				return scroll.x_off;
			}
			#region jsDoc
			/// @func    get_vert_scroll()
			/// @desc    Get scroll y offset.
			/// @self    GUICompTextbox
			/// @returns {Real}
			#endregion
			static get_vert_scroll = function() {
				return scroll.y_off;
			}
			
		#endregion
		
		#region Events
			
			self.events.scrolled       = variable_get_hash("scrolled"); //if the scroll region has moved it's view in any way
			self.events.scrolled_up    = variable_get_hash("scrolled_up"); //if the scroll region has scrolled up
			self.events.scrolled_down  = variable_get_hash("scrolled_down"); //if the scroll region has scrolled down
			self.events.scrolled_left  = variable_get_hash("scrolled_left"); //if the scroll region has scrolled left
			self.events.scrolled_right = variable_get_hash("scrolled_right"); //if the scroll region has scrolled right
			
		#endregion
		
		#region Variables
			
			is_open = true; // unused, but left here so buttons can make use of callapsing this component in the future
			
			scroll = {};
			scroll.y_off = 0;
			scroll.x_off = 0;
			scroll.y_off_target = 0;
			scroll.x_off_target = 0;
			scroll.smooth = true;
			
		#endregion
		
		#region Functions
			
			static get_coverage_width = function() {
				if (__scroll_vert_hidden__) {
					return region.get_width()
				}
				else {
					return region.get_width() - __scroll_vert__.region.get_width()
				}
			}
			static get_coverage_height = function() {
				if (__scroll_horz_hidden__) {
					return region.get_height()
				}
				else {
					return region.get_height() - __scroll_horz__.region.get_height()
				}
			}
			
			static draw_gui = function(_input) {
				if (sprite_index != -1) {
					draw_sprite_stretched(
							sprite_index,
							image_index,
							x+region.left,
							y+region.top,
							region.get_width(),
							region.get_height()
					);
				}
			}
			
			static update_component_positions = function() {
				//move the scroll bars
				__update_scrollbar_positions__();
				
				if (!__is_empty__) {
					var _anchor_point, _comp, _xx, _yy;
					
					/// NOTE: //////////////////////////////////////////////////////////////////
					//
					// This is not the same thing as it's super as it adds in the scroll offsets
					// stop trying to remove this Red
					//                                     -Red 06/26/2023 (MM/DD/YYYY)
					//
					////////////////////////////////////////////////////////////////////////////
					
					
					//move the children
					var _i=0; repeat(__children_count__) {
						_comp = __children__[_i];
						
						_xx = __get_controller_archor_x__(_comp.halign);
						_yy = __get_controller_archor_y__(_comp.valign);
						
						_comp.x = self.x + _xx + _comp.x_offset + _comp.__internal_x__ + scroll.x_off;
						_comp.y = self.y + _yy + _comp.y_offset + _comp.__internal_y__ + scroll.y_off;
						
						//if the component is a controller it's self have it update it's children
						if (_comp.__is_controller__) {
							_comp.update_component_positions();
						}
					_i+=1;}//end repeat loop
					
				}
			}
			
		#endregion
		
	#endregion
	
	#region Private Library
		
		#region Variables
			
			__canvas_region__ = new __region__();
			
			__scroll_horz_size__ = 24;
			__scroll_vert_size__ = 24;
			
			__scroll_horz_hidden__ = false;
			__scroll_vert_hidden__ = false;
			
			#region sliders
				
				//create the children sliders
				
				//init both before we start building as they are codependant
				__scroll_vert__ = new GUICompScrollBar()
					.set_offset(0,0)
					.set_alignment(fa_right, fa_top)
					.set_vertical(true)
				__scroll_horz__ = new GUICompScrollBar()
					.set_offset(0,0)
					.set_alignment(fa_left, fa_bottom)
					.set_button_sprites(s9ScrollbarHorzButtonLeft, s9ScrollbarHorzButtonRight)
					.set_background_sprite(s9ScrollbarHorzBackground)
				
				//vertical
				__scroll_vert__.__is_child__ = true;
				__scroll_vert__.__parent__ = self;
				__scroll_vert__.set_offset(__scroll_vert__.region.get_width(), 0)
				__scroll_vert__.add_event_listener(__scroll_vert__.events.value_changed, function(_val) {
					scroll.y_off = -_val;
				});
				
				//horizontal
				__scroll_horz__.__is_child__ = true;
				__scroll_horz__.__parent__ = self;
				__scroll_horz__.set_offset(0, __scroll_horz__.region.get_height())
				__scroll_horz__.add_event_listener(__scroll_horz__.events.value_changed, function(_val) {
					scroll.x_off = -_val;
				});
				
				//set the regions
				//__scroll_vert__.old_set_size = __scroll_vert__.set_size
				//__scroll_vert__.set_size = method(self, function(_left, _top, _right, _bottom){
				//	__scroll_vert__.old_set_size(_left, _top, _right, _bottom)
				//});
				
				__scroll_vert__.set_size(0, region.top, 16, region.bottom);
				__scroll_horz__.set_size(region.left, 0, region.right, 16);
				
			#endregion
			
		#endregion
		
		#region Functions
			
			static __update_group_region__ = function() {
				__group_region__.left   = region.left;
				__group_region__.top    = region.top;
				__group_region__.right  = region.right;
				__group_region__.bottom = region.bottom;
				
				__update_scrollbar_thumbs__();
				
				//if this controller is a child of another controller, update the parent controller, this will loop all the way to the top most parent
				if (__is_child__) {
					__parent__.__update_group_region__();
				}
			}
			
			static __update_scrollbar_positions__ = function() {
				
				__scroll_vert__.x = x + region.right - (__scroll_vert__.region.get_width());
				__scroll_vert__.y = y + region.top;
				
				__scroll_horz__.x = x + region.left;
				__scroll_horz__.y = y + region.bottom - (__scroll_horz__.region.get_height())
				
				__scroll_vert__.update_component_positions();
				__scroll_horz__.update_component_positions();
				
			}
			
			static __update_scrollbar_thumbs__ = function() {
				
				__scroll_vert__.set_canvas_size(__canvas_region__.get_height());
				__scroll_vert__.set_coverage_size(get_coverage_height());
				
				__scroll_horz__.set_canvas_size(__canvas_region__.get_width());
				__scroll_horz__.set_coverage_size(get_coverage_width());
				
			}
			
		#endregion
		
	#endregion
	
	static draw_debug = function() {
		if (!should_draw_debug) return;
		
		draw_text(x,y,""
			+ "\n scroll.y_off = "+string(scroll.y_off)
			+ "\n scroll.x_off = "+string(scroll.x_off)
			+ "\n scrollbar.y_off = "+string(__scroll_vert__.get_value())
			+ "\n scrollbar.x_off = "+string(__scroll_horz__.get_value())
		)
		draw_set_color(c_blue)
		draw_rectangle(
				x+region.left,
				y+region.top,
				x+region.right,
				y+region.bottom,
				true
		);
	}
	
	//post init
	__update_group_region__();
}