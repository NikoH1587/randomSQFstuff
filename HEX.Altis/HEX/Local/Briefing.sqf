waitUntil {!isNil "HEX_PHASE"};
waitUntil {!isNil "HEX_TACTICAL"};
waitUntil {!isNil "HEX_STRATEGIC"};

/// Close strategic map, reset onsingleclick
onMapSingleClick "";
(findDisplay 1300) closedisplay 1;
openmap false;

/// Todo:
/// Clear / Update map markers

/// Open briefing menu
[] spawn {
	while {HEX_PHASE == "BRIEFING"} do {
		if (isNull findDisplay 1400) then {
			createDialog "HEX_BRIEFING";
			private _menu = findDisplay 1400;
			private _text = _menu displayCtrl 1401;
			private _info = _menu displayCtrl 1402;
			private _west = _menu displayCtrl 1403;
			private _east = _menu displayCtrl 1404;
			private _start = _menu displayCtrl 1405;
			private _map = _menu displayCtrl 1406;
			private _color = [0, 0.3, 0.6, 0.5];
			if (playerSide == east) then {
				_color = [0.5, 0, 0, 0.5];
			};
			
			/// Title text
			_text ctrlSetBackgroundColor _color;
			
			/// Info text
			_info lbAdd ("D+" + str HEX_DAY + " " + ([dayTime, "HH:MM"] call BIS_fnc_timeToString));
			_info lbAdd HEX_WEATHER;
			_info lbAdd "";
			_info lbAdd "Description 2";
			_info lbAdd "Description 3";
			_info lbAdd "Description 4";
			
			/// Add active units to list with name + icon
			private _posX = 0;
			private _posY = 0;
			
			_west lbAdd "PRIMARY:";
			_east lbAdd "PRIMARY:";
			
			{
				private _pos = _x select 2;
				private _type = _x select 3;
				private _side = _x select 4;
				/// private _state = _x select 6;
				private _icon = "\A3\ui_f\data\map\markers\nato\" + _type + ".paa";
				private _text = "Infantry Coy";
				switch (_type select [2]) do {
					case "hq": {_text = "BDE Headquarters"};
					case "unknown": {_text = "Mixed Coy"};
					case "art": {_text = "Artillery Bty"};
					case "mortar": {_text = "Mortar Bty"};
					case "support": {_text = "Support Plt"};
					case "air": {_text = "Helicopter Flt"};
					case "plane": {_text = "Plane Flt"};
					case "uav": {_text = "Drone Flt"};
					case "antiair": {_text = "Anti-Air Bty"};
					case "recon": {_text = "Recon Coy"};
					case "motor_inf": {_text = "Motorized Coy"};
					case "mech_inf": {_text = "Mechanized Coy"};
					case "armor": {_text = "Armor Coy"};
				};
				
				private _alpha = 1;
				/// if (_state < 0.5) then {_text = _text + "(ROUT!)"; _alpha = 0.5};
				
				if (_side == west) then {
					private _added = _west lbAdd _text;
					_west lbSetPicture [_added, _icon];
					_west lbSetPictureColor [_added, [0, 0.3, 0.6, _alpha]];
				};
				if (_side == east) then {
					private _added = _east lbAdd _text;
					_east lbSetPicture [_added, _icon];
					_east lbSetPictureColor [_added, [0.5, 0, 0, _alpha]];				
				};
				
				_posX = _posX + (_pos select 0);
				_posY = _posY + (_pos select 1);
				
			}forEach HEX_TACTICAL;
			
			_west lbAdd "AUXILIARY:";
			_east lbAdd "AUXILIARY:";
			
			{
				private _type = _x select 3;
				private _side = _x select 4;
				/// private _state = _x select 6;
				private _icon = "\A3\ui_f\data\map\markers\nato\" + _type + ".paa";
				private _text = "Reserve";
				switch (_type select [2]) do {
					case "hq": {_text = "BDE Headquarters"};
					case "mortar": {_text = "Mortar Bty"};
					case "art": {_text = "Artillery Bty"};
					case "support": {_text = "Support Plt"};
					case "air": {_text = "Helicopter Flt"};
					case "plane": {_text = "Plane Flt"};
					case "uav": {_text = "Drone Flt"};
					case "antiair": {_text = "Anti-Air Bty"};
				};
				
				/// if (_state < 0.5) then {_text = _text + "(ERROR)"};
				
				if (_side == west) then {
					private _added = _west lbAdd _text;
					_west lbSetPicture [_added, _icon];
					_west lbSetPictureColor [_added, [0, 0.3, 0.6, 1]];
				};
				if (_side == east) then {
					private _added = _east lbAdd _text;
					_east lbSetPicture [_added, _icon];
					_east lbSetPictureColor [_added, [0.5, 0, 0, 1]];				
				};
				
				
			}forEach HEX_STRATEGIC;			
			
			/// Set map in center
			_posX = _posX / (count HEX_TACTICAL);
			_posY = _posY / (count HEX_TACTICAL);
			private _zoom = 1 / (count HEX_TACTICAL);
			_map ctrlMapAnimAdd [0, _zoom, [_posX, _posY]];
			ctrlMapAnimCommit _map;
			
			/// Start button text
			if (HEX_LOC_ADMIN) then {
				_start ctrlSetText "COMMENCE BATTLE";
			} else {
				_start ctrlSetText "WAITING FOR ADMIN...";
			};
		};
		sleep 1;
	};
};