/// start loading screen on local
HEX_LOC_FNC_LOAD = {
	call compile preprocessFile "HEX\Local\Loading.sqf";
};

/// update locally if player has been chosen as commander
HEX_LOC_FNC_COMMANDER = {
	if (name player == HEX_ADM_WEST_COMMANDER) then {
		HEX_LOC_COMMANDER = true;

		systemChat "You have been chosen as BLUFOR Commander!";
		systemChat "In strategic phase: Move units on hex board by clicking them.";
		systemChat "In tactical battle: Open High Command module with ctrl+space.";
		systemChat "Good luck commander!";
	};

	if (name player == HEX_ADM_EAST_COMMANDER) then {
		LOC_COMMANDER = true;

		systemChat "You have been chosen as OPFOR Commander!";
		systemChat "In strategic phase: Move units on hex board by clicking them.";
		systemChat "In tactical battle: Open High Command module with ctrl+space.";
		systemChat "Good luck commander!";
	};
};

/// start strategic on local
HEX_LOC_FNC_STRATEGIC = {
	call compile preprocessFile "HEX\Local\Strategic.sqf";
	call compile preprocessFile "HEX\Local\Ambient.sqf";
};

/// Updates counter markers on client
HEX_LOC_FNC_COTE = {
	{
		private _hex = _x;
		private _row = _x select 0;
		private _col = _x select 1;
		private _pos = _x select 2;
		private _cfg = _x select 3;
		private _sid = _x select 4;
		private _act = _x select 5;
		private _org = _x select 6;

		private _name = format ["HEX_LOC_%1_%2", _row, _col];
		deleteMarkerLocal _name;

		private _draw = false;
		if (_sid == side player) then {_draw = true};
	
		private _near = _hex call HEX_GLO_FNC_NEAR;
		{
			private _sid2 = _x select 4;
			if (_sid2 == resistance) then {
				_draw = true;
			};
		}forEach _near;	
	
		if (_draw == true && _cfg != "hd_dot") then {
			private _marker = createMarkerLocal [_name, _pos];
			_marker setMarkerTypeLocal _cfg;
			private _orgText = ".";
			if (_org >= 2) then {_orgtext = ".."};
			if (_org >= 3) then {_orgtext = "..."};
			if (_org >= 5) then {_orgtext = "I"};
			if (_org >= 7) then {_orgtext = "II"};
			if (_org >= 9) then {_orgtext = "III"};

			if (_act == 0) then {_marker setMarkerTextLocal (_orgtext)};
			if (_act == 1) then {_marker setMarkerTextLocal (_orgtext + " >")};
			if (_act == 2) then {_marker setMarkerTextLocal (_orgtext + " >>")};
			if (_act == 3) then {_marker setMarkerTextLocal (_orgtext + " >>>")};
			};
	}forEach HEX_GRID;
};

HEX_LOC_FNC_COTEDELETE = {
	{
		private _row = _x select 0;
		private _col = _x select 1;
		private _name = format ["HEX_LOC_%1_%2", _row, _col];
		deleteMarkerLocal _name;
	}forEach HEX_GRID;
};

/// Clears markers and orders locally
HEX_LOC_FNC_CLIC = {
	/// Remove order markers
	{
		private _hex = _x;
		private _row = _x select 0;
		private _col = _x select 1;
		private _pos = _x select 2;
		private _name = format ["ACT_%1_%2", _row, _col];		
		deleteMarkerLocal _name;
	}forEach HEX_LOC_ORDERS;
	
	deleteMarkerLocal "HEX_SELECT";
	
	/// Reset local variables
	if (isNil "HEX_LOC_ORDERS" == false) then {
		HEX_LOC_ORDERS = [];
	};
	
	if (isNil "HEX_LOC_SELECT" == false) then {
		HEX_LOC_SELECT = [];
	};
	
	if (isNil "HEX_LOC_MODE" == false) then {
		HEX_LOC_MODE = "SELECT";
	};	
	
	/// Stop radio noise;
	if (isNil "HEX_LOC_SOUND" == false) then {
		stopSound HEX_LOC_SOUND;
	};
};

HEX_LOC_FNC_SELECT = {
	private _selectable = [];
	private _posCLICK = _this;
	/// Find counters with moves
	{
		private _hex = _x;
		private _sid = _x select 4;
			private _act = _x select 5;
		if (_sid == side player && _act > 0) then {
			_selectable pushback _hex;
		};
	}forEach HEX_GRID;

	/// Select counter
	{
		private _hex = _x;
		private _pos = _x select 2;
		if (_pos distance _posCLICK < (HEX_SIZE/2)) then {
			HEX_LOC_SELECT = _x;
			HEX_LOC_MODE = "ORDER";
			
			private _marker = createMarkerLocal ["HEX_SELECT", _pos];
			_marker setMarkerTypeLocal "Select";
			_marker setMarkerSize [1.5, 1.5];
			
			/// Play sound 
			0 spawn HEX_LOC_FNC_EFFECT;
			
			/// Add all possible near moves
			private _near = _hex call HEX_GLO_FNC_NEAR;
			{
				private _nearHEX = _x;
				private _cfg = _x select 3;
				private _side = _x select 4;
				if (_side != resistance && _cfg == "hd_dot") then {
					HEX_LOC_ORDERS pushback _nearHEX;
				};
			}forEach _near;
			
			/// Add move markers
			{
				private _row = _x select 0;
				private _col = _x select 1;
				private _pos2 = _x select 2;
				private _name2 = format ["ACT_%1_%2", _row, _col];
				private _marker2 = createMarkerLocal [_name2, _pos2];
				_marker2 setMarkerTypeLocal "Select";
			}ForEach HEX_LOC_ORDERS;
		};
	}forEach _selectable;
};

HEX_LOC_FNC_ORDER = {
	private _posCLICK = _this;

	/// Select move
	{
		private _hex = _x;
		private _pos = _x select 2;
		
		if (_pos distance _posCLICK < (HEX_SIZE/2)) then {
		
			private _hex2 = HEX_LOC_SELECT;
			private _row2 = _hex2 select 0;
			private _col2 = _hex2 select 1;
			
			private _name2 = format ["HEX_LOC_%1_%2", _row2, _col2];
			_name2 setMarkerPosLocal _pos;
			
			/// Send move to server
			[HEX_LOC_SELECT, _hex] remoteExec ["HEX_SRV_FNC_MOVE", 2, false];
			
			/// Play sound
			private _sound = HEX_LOC_SOUNDS select floor random count HEX_LOC_SOUNDS;
			playSoundUI [_sound, 1, random 1];
		};
	}forEach HEX_LOC_ORDERS;
	
	/// Clear local orders, markers and sound
	remoteExec ["HEX_LOC_FNC_CLIC", 0, false];
};

/// Sound effect
HEX_LOC_FNC_EFFECT = {
	
	private _sound = HEX_LOC_SOUNDS select floor random count HEX_LOC_SOUNDS;
	private _radio = HEX_LOC_RADIO select floor random count HEX_LOC_RADIO;
	private _pitch = random 1;
	playSoundUI [_sound, 1, random 1];
	HEX_LOC_SOUND = playSoundUI [_radio, 3 - _pitch, _pitch];
};

HEX_LOC_FNC_ENDTURN = {
	if (side player == HEX_TURN && HEX_LOC_COMMANDER) then {
		remoteExec ["HEX_SRV_FNC_TURN", 2, false];
	};
};

/// Open briefing menu
HEX_LOC_FNC_BRIEFING = {
	call compile preprocessFile "HEX\Local\Briefing.sqf";
};

/// Close tactical briefing for clients
HEX_LOC_FNC_CLOSEBRIEFING = {
	(findDisplay 1400) closedisplay 1;
};

/// Open slotting menu
HEX_LOC_FNC_SLOTTING = {
	call compile preprocessFile "HEX\Local\Slotting.sqf";
};

/// gets all HEX groups of specific side, locally
HEX_LOC_FNC_GROUPS = {
	private _side = _this;
	private _groups = allGroups select {
		side _x == _side && _x isNil "HEX_ICON" == false;
	};
	_groups
};

/// update units list
HEX_LOC_FNC_UNITS = {
	private _group = HEX_LOC_GROUPS select _this;
	private _menu = findDisplay 1500;
	private _unitsList = _menu displayCtrl 1503;
	
	private _color = [0, 0.3, 0.6, 0.5];
	if (HEX_LOC_SIDE == east) then {
		_color = [0.5, 0, 0, 0.5];
	};	
	
	_unitsList lbSetCurSel 0;
	lbClear _unitsList;
	
	HEX_LOC_UNITS = units _group;
	
	{
		private _unit = _x;
		private _cfg = configfile >> "CfgVehicles" >> typeOf _unit;
		private _name = getText (_cfg >> "displayName");
		private _veh = vehicle _unit;
		
		if (_unit != _veh) then {
			private _cfgVeh = configfile >> "CfgVehicles" >> typeOf _veh;
			private _nameVeh = getText (_cfgVeh >> "displayName");
			if (driver _veh == _unit) then {_name = _nameVeh + " Driver"};
			if (commander _veh == _unit) then {_name = _nameVeh + " Commander"};
			if (gunner _veh == _unit) then {_name = _nameVeh + " Gunner"};
		};
		
		if (isPlayer _x) then {_name = "(PLAYER) " + _name};
		if (leader _x == _x) then {_name = "(LEADER) " + _name};
		/// add check if unit is "autonomous"
		private _added = _unitsList lbAdd _name;		
	}forEach HEX_LOC_UNITS;
};

/// Select unit in list
HEX_LOC_FNC_UNIT = {
	HEX_LOC_UNIT = HEX_LOC_UNITS select _this;
	private _menu = findDisplay 1500;
	private _minimap = _menu displayCtrl 1505;	

	/// move map to unit's position	
	_minimap ctrlMapAnimAdd [0, 0.1, HEX_LOC_UNIT];
	ctrlMapAnimCommit _minimap;
};

/// Switch player unit
HEX_LOC_FNC_SWITCH = {
	private _newUnit = HEX_LOC_UNIT;
	private _possible = true;
	
	if (isPlayer _newUnit) then {_possible == false};
	if (alive _newUnit == false) then {_possible == false};
	
	if (_possible) then {
		selectPlayer HEX_LOC_UNIT;
		HEX_LOC_SLOTTING = false;
		(findDisplay 1500) closedisplay 1;
	};
	
	/// if check fails re-open the menu
	if (_possible == false) then {
		(findDisplay 1500) closedisplay 1;	
	};

};