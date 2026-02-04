waitUntil {!isNil "HEX_PHASE"};
HEX_LOC_SIDE = side player;
HEX_LOC_SLOTTING = true;
HEX_LOC_GROUP = group player;
HEX_LOC_UNITS = units player;
HEX_LOC_GROUPS = [];
HEX_LOC_UNIT = player;

/// Close briefing map
(findDisplay 1400) closedisplay 1;

//// Minimap? - selecting from list moves map to the units position
/// Confirm if unit can actually be selected!
/// confirm button changes color when can be switched to?


/// Open slotting menu if player is ghost unit
[] spawn {
	while {HEX_PHASE == "GAME"} do {
		
		if (isNull findDisplay 1500 && HEX_LOC_SLOTTING) then {
			createDialog "HEX_SLOTTING";
			private _menu = findDisplay 1500;
			private _text = _menu displayCtrl 1501;
			private _groupsList = _menu displayCtrl 1502;
			private _unitsList = _menu displayCtrl 1503;
			private _button = _menu displayCtrl 1504;
			private _minimap = _menu displayCtrl 1505;
			private _color = [0, 0.3, 0.6, 0.5];
			if (HEX_LOC_SIDE == east) then {
				_color = [0.5, 0, 0, 0.5];
			};
			
			_text ctrlSetBackgroundColor _color;
			HEX_LOC_GROUPS = HEX_LOC_SIDE call HEX_LOC_FNC_GROUPS;
			
			{
				private _type = _x getVariable "HEX_ICON";
				private _icon = "\A3\ui_f\data\map\markers\nato\" + _type + ".paa";
				private _name = groupId _x;
				private _added = _groupsList lbAdd _name;
				_groupsList lbSetPicture [_added, _icon];
				_groupsList lbSetPictureColor [_added, _color];
			}ForEach HEX_LOC_GROUPS;
		};
		
		sleep 1;
	};
};