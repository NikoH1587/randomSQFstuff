/// start campaign on server
HEX_SRV_FNC_CAMPAIGN = {
	/// set new commander
	remoteExec ["HEX_LOC_FNC_COMMANDER", 0, false];
	
	/// Generate default/custom new campaign or load saved campaign
	if (_this == "DEFAULT") then {call compile preprocessFile "HEX\Server\DefaultCampaign.sqf"};
	if (_this == "CUSTOM") then {call compile preprocessFile "HEX\Server\CustomCampaign.sqf"};
	if (_this == "SAVED") then {call compile preprocessFile "HEX\Server\SavedCampaign.sqf"};
};

/// Create grid overlay on server
HEX_SRV_FNC_GRID = {
	{
		private _row = _x select 0;
		private _col = _x select 1;
		private _pos = _x select 2;
		private _name = format ["HEX_%1_%2", _row, _col];
		private _marker = createMarker [_name, _pos];
		_marker setMarkerShape "HEXAGON";
		_marker setMarkerBrush "SolidBorder";
		_marker setMarkerAlpha 0.5;
		_marker setMarkerDir 90;
		_marker setMarkerSize [HEX_SIZE, HEX_SIZE];
	}forEach HEX_GRID;
};

HEX_SRV_FNC_GRIDDELETE = {
	private _grid = HEX_GRID;
	
	private _grid = _grid;
	{
		private _row = _x select 0;
		private _col = _x select 1;
		private _name = format ["HEX_%1_%2", _row, _col];
		deleteMarker _name;
	}forEach _grid;
};

/// Moves one hex into another on server
HEX_SRV_FNC_MOVE = {
	private _org = _this select 0;
	private _end = _this select 1;
	
	/// Find origin index
	private _indexORG = HEX_GRID find _org;
	/// Find destination index
	private _indexEND = HEX_GRID find _end;	
	
	/// Replace origin with "hd_dot", civilian, 0
	private _newORG = [_org select 0, _org select 1, _org select 2, "hd_dot", civilian, 0, 0];
	HEX_GRID set [_indexORG, _newORG];
	
	/// Replace destination with origin
	private _newEND = [_end select 0, _end select 1, _end select 2, _org select 3, _org select 4, (_org select 5) - 1, _org select 6];
	HEX_GRID set [_indexEND, _newEND];
	
	/// Update grid information globally
	publicVariable "HEX_GRID";
	
	/// Update zone of control globally
	private _zoco = 0 spawn HEX_SRV_FNC_ZOCO; 
	waitUntil {scriptDone _zoco};

	/// Update counters globally
	remoteExec ["HEX_LOC_FNC_COTE", 0, false];
};

/// Updates grid zone of control of counters on server and intensity globally
HEX_SRV_FNC_ZOCO = {
	private _intensity = 0;
	
	{
		private _hex = _x;
		private _row = _x select 0;
		private _col = _x select 1;
		private _pos = _x select 2;
		private _cfg = _x select 3;
		private _sid = _x select 4;
		private _act = _x select 5;
		private _org = _x select 6;
	
		private _near = _hex call HEX_GLO_FNC_NEAR;
		private _sides = [_sid];
		{
			_sides pushback (_x select 4);
		}forEach _near;
	
		if (_sid == resistance) then {_sid = civilian};
	
		private _color = "colorBLACK";
		if (west in _sides) then {_color = "colorBLUFOR"};
		if (east in _sides) then {_color = "colorOPFOR"};
		if (west in _sides && east in _sides) then {
			_color = "ColorCIV"; 
			_Intensity = _Intensity + 1;
			_sid = resistance;
		};
	
		private _newHEX = [_row, _col, _pos, _cfg, _sid, _act, _org];
		HEX_GRID set [_forEachIndex, _newhex];
	
		private _marker = format ["HEX_%1_%2", _row, _col];
		_marker setMarkerColor _color;
	}forEach HEX_GRID;
	
	HEX_INTENSITY = _intensity;
	publicVariable "HEX_GRID";
	publicVariable "HEX_INTENSITY";
};

/// End turn on server
HEX_SRV_FNC_TURN = {
	call compile preprocessFile "HEX\Server\Turn.sqf";
};

/// Start tactical on server
HEX_SRV_FNC_TACTICAL = {
	call compile preprocessFile "HEX\Server\Tactical.sqf"
};

/// get cfgVehicles
HEX_SRV_FNC_VEHICLES = {
	private _factions = _this select 0;
	private _type = _this select 1;
	private _men = [];
	private _configs = [];
	private _reammo = [];
	private _repair = [];
	private _refuel = [];
	
	private _typ = "hq";
	if (_type in ["b_support", "o_support"]) then {_typ = "support"};
	if (_type in ["b_mortar", "o_mortar"]) then {_typ = "mortar"};
	if (_type in ["b_art", "o_art"]) then {_typ = "art"};
	if (_type in ["b_antiair", "o_antiair"]) then {_typ = "antiair"};
	if (_type in ["b_air", "o_air"]) then {_typ = "air"};
	if (_type in ["b_plane", "o_plane"]) then {_typ = "plane"};
	if (_type in ["b_uav", "o_uav"]) then {_typ = "uav"};
	
	/// Scan throught cfgVehicles
	{
		private _veh = _x;
		private _fac = getText (_x >> "faction");
		private _sco = getNumber (_x >> "scope");
		private _cfg = configName _x;

		if (_sco == 2 && _fac in _factions) then {
			private _amo = getNumber (_veh >> "transportAmmo");
			private _plo = getNumber (_veh >> "transportFuel");
			private _rep = getNumber (_veh >> "transportRepair");
			private _art = getNumber (_veh >> "artilleryScanner");
			private _sup = _amo + _plo + _rep;
			private _med = getNumber (_veh >> "attendant");
			private _eng = getNumber (_veh >> "engineer");
			private _sup2 = _med + _eng;
			private _sim = toLower getText (_veh >> "simulation");
			private _cat = getText (_veh >> "editorSubcategory");
			private _dsp = getText (_veh >> "displayName");
			private _drv = getNumber (_veh >> "hasDriver");
			private _cls = getText (_veh >> "vehicleClass");
			private _wep = getArray (_veh >> "weapons");
			private _cas = false;
			if (count _wep > 0) then {_cas = true};

			if (_sim == "soldier") then {_men pushback _cfg};
			if (_typ == "hq" && _dsp == "Officer") then {_configs pushback _cfg};	
			if (_typ == "mortar" && _art > 0 && _drv == 0 && _cls != "Autonomous") then {_configs pushback _cfg};
			if (_typ == "art" && _art > 0 && _drv == 1) then {_configs pushback _cfg};
			if (_typ == "antiair" && _cat == "EdSubcat_AAs") then {_configs pushback _cfg};			
			if (_typ == "support" && _sup > 0) then {_configs pushback _cfg};
			if (_typ == "air" && _sup == 0 && _sup2 == 0 && (_sim == "helicopterrtd" or _sim == "helicopterx") && _cls != "Autonomous" && _cas) then {_configs pushback _cfg};
			if (_typ == "plane" && _sup == 0 && _sup2 == 0 && (_sim == "airplanex" or _sim == "airplane") && _cls != "Autonomous" && _cas) then {_configs pushback _cfg};
			if (_typ == "uav" && _sup == 0 && _sup2 == 0 && (_sim == "airplanex" or _sim == "airplane" or _sim == "helicopterrtd" or _sim == "helicopterx") && _cls == "Autonomous" && _cas) then {_configs pushback _cfg};
		};
	} forEach ("true" configClasses (configFile >> "CfgVehicles"));

	/// if no configs, pick random man
	if (count _configs == 0) then {_configs = [_men select floor random count _men]};

	/// return array
	_configs
};

HEX_FNC_SRV_SPAWNVEHICLE = {
	private _hexpos = _this select 0;
	private _side = _this select 1;
	private _config = _this select 2;

	private _pos = [_hexpos, 0, HEX_SIZE / 2, 5, 0, 0, 0, [], _hexpos] call BIS_fnc_findSafePos;
	private _spawned = [_pos, 0, _config, _side] call BIS_fnc_spawnVehicle;	
	private _crew = _spawned select 1;
	private _group = _spawned select 2;
	{_x setSkill 1}forEach _crew;
	(_crew select 0) setRank "CORPORAL";
	if (count _crew > 0) then {(_crew select 1) setRank "SERGEANT"};
	if (count _crew > 1) then {(_crew select 2) setRank "LIEUTENANT"};
	
	_group
};

/// Remove group from pool
HEX_SRV_FNC_SUBTRACT = {
	private _hex = _this select 0;
	private _org = _this select 1;
	private _sub = _this select 2;
	/// Find hex index
	private _index = HEX_TACTICAL find _hex;
	
	/// subtract
	private _count = _org - _sub;
	
	/// Replace hex in grid with subtracted amount
	private _newHEX = [_hex select 0, _hex select 1, _hex select 2, _hex select 3, _hex select 4, _hex select 5, _count];
	HEX_TACTICAL set [_index, _newHEX];
	
	/// Update grid information globally
	publicVariable "HEX_TACTICAL";
};

/// Count how many groups hex has present
HEX_SRV_HEXIDS = {
	private _row = _this select 0;
	private _col = _this select 1;
	private _side = _this select 2;
	private _groups = _side call HEX_LOC_FNC_GROUPS;
	private _amount = 0;
	
	{
		private _id = _x getVariable "HEX_ID";
		private _rowG = _id select 0;
		private _colG = _id select 1;
		if (_rowG == _row && _colG == _col) then {
			_amount = _amount + 1;
		};
	}forEach _groups;
	
	_amount
};

/// Get cfgGroups configs of groups
HEX_SRV_FNC_GROUPS = {
	private _factions = _this select 0;
	private _type = _this select 1;

	private _icons = ["\A3\ui_f\data\map\markers\nato\b_inf.paa", "\A3\ui_f\data\map\markers\nato\n_inf.paa", "\A3\ui_f\data\map\markers\nato\o_inf.paa"];	
	if (_type in ["b_recon", "o_recon"]) then {_icons = ["\A3\ui_f\data\map\markers\nato\b_recon.paa", "\A3\ui_f\data\map\markers\nato\n_recon.paa", "\A3\ui_f\data\map\markers\nato\o_recon.paa"]};	
	if (_type in ["b_motor_inf", "o_motor_inf"]) then {_icons = ["\A3\ui_f\data\map\markers\nato\b_motor_inf.paa", "\A3\ui_f\data\map\markers\nato\n_motor_inf.paa", "\A3\ui_f\data\map\markers\nato\o_motor_inf.paa"]};
	if (_type in ["b_mech_inf", "o_mech_inf"]) then {_icons = ["\A3\ui_f\data\map\markers\nato\b_mech_inf.paa", "\A3\ui_f\data\map\markers\nato\n_mech_inf.paa", "\A3\ui_f\data\map\markers\nato\o_mech_inf.paa"]};
	if (_type in ["b_armor", "o_armor"]) then {_icons = ["\A3\ui_f\data\map\markers\nato\b_armor.paa", "\A3\ui_f\data\map\markers\nato\n_armor.paa", "\A3\ui_f\data\map\markers\nato\o_armor.paa"]};
	if (_type in ["b_unknown", "o_unknown"]) then {_icons = ["\A3\ui_f\data\map\markers\nato\b_inf.paa", "\A3\ui_f\data\map\markers\nato\n_inf.paa", "\A3\ui_f\data\map\markers\nato\o_inf.paa", "\A3\ui_f\data\map\markers\nato\b_recon.paa", "\A3\ui_f\data\map\markers\nato\n_recon.paa", "\A3\ui_f\data\map\markers\nato\o_recon.paa", "\A3\ui_f\data\map\markers\nato\b_motor_inf.paa", "\A3\ui_f\data\map\markers\nato\n_motor_inf.paa", "\A3\ui_f\data\map\markers\nato\o_motor_inf.paa", "\A3\ui_f\data\map\markers\nato\b_mech_inf.paa", "\A3\ui_f\data\map\markers\nato\n_mech_inf.paa", "\A3\ui_f\data\map\markers\nato\o_mech_inf.paa"]};		
	
	/// blacklist diver etc squads
	private _blacklist = ["Recon UAV Team", "Attack UAV Team", "Diver Team", "Diver Team (Boat)", "Diver Team (SDV)", "Mechanized Air-defense Squad", "Mechanized Support Squad", "Motorized Air-defense Team", "Motorized GMG Team", "Motorized HMG Team", "Motorized Mortar Team", "AWC Air-Defense Platoon", "AWC Platoon (Combined)", "AWC Air-Defense Section", "AWC Recon Section"];
	
	/// Go throught entire cfgGroups and find groups matching icons and faction
	private _groups = [];
	{
		private _facs = "true" configClasses _x;
		{
			private _cats = "true" configClasses _x;
			{
				private _grps = "true" configClasses _x;
				
				/// move "Special Forces" to recon
				private _CATname = getText (_x >> "name");
				private _INFnoskip = true;
				private _RECnoskip = false;
				private _SUPnoskip = true;
				if (_CATname == "Special Forces" && (_icons select 0 == "\A3\ui_f\data\map\markers\nato\b_inf.paa")) then {_INFnoskip = false};	
				if (_CATname == "Special Forces" && (_icons select 0 == "\A3\ui_f\data\map\markers\nato\b_recon.paa")) then {_RECnoskip = true};
				if (_CATname == "Support Infantry") then {_SUPnoskip = false};
				if (_CATname == "Guard Infantry") then {_SUPnoskip = false};					
				{
					private _fac = getText (_x >> "faction");
					private _ico = getText (_x >> "icon");
					private _GRPname = getText (_x >> "name");
					
					private _ARMnoskip = false;
					if (_GRPname == "Tank Destroyer Section" && _icons select 0 == "\A3\ui_f\data\map\markers\nato\b_armor.paa") then {_ARMnoskip = true};
					if (_GRPname == "Tank Destroyer Section (UP)" && _icons select 0 == "\A3\ui_f\data\map\markers\nato\b_armor.paa") then {_ARMnoskip = true};
					
					if (_fac in _factions && (_ico in _icons or _RECnoskip or _ARMnoskip) && _INFnoskip && _SUPnoskip && (_GRPname in _blacklist == false)) then {
						private _group = _x;
						private _size = (count _x) min 12;
						_grpAndSize = [_size, _group];
						_groups append [_grpAndSize];
					};
				}forEach _grps;
			}forEach _cats;
		}forEach _facs;
	}forEach [(configFile >> "CfgGroups" >> "West"), (configFile >> "CfgGroups" >> "East"), (configFile >> "CfgGroups" >> "Indep")];
	
	_groups sort false;
	_groups
};

HEX_FNC_SRV_SPAWNGROUP = {
	private _hexpos = _this select 0;
	private _side = _this select 1;
	private _config = _this select 2;

	private _group = createGroup _side;
	private _pos = [[[_hexpos, HEX_SIZE / 2]], ["water"]] call BIS_fnc_randomPos;
	
	private _infantry = [];
	private _vehicles = [];
		
	{
		private _veh = getText (_x >> "vehicle");
		private _rank = getText (_x >> "rank");
		private _cfg = (configFile >> "CfgVehicles" >> _veh);
		private _isMan = getNumber (_cfg >> "isMan");
			
		if (_isMan == 1) then {
			_infantry pushback [_rank, _veh];
		} else {
			_vehicles pushback [_rank, _veh];				
		};
	}forEach _config;
	
	/// Limit excessive groups
	_infantry deleteRange [12, 20];
	_vehicles deleteRange [2, 6];
	
	{
		(_x select 1) createUnit [_pos, _group, "", 1, (_x select 0)];	
	}forEach _infantry;
	
	{
		private _pos2 = [_pos, 0, 50, 5, 0, 0, 0, [], _pos] call BIS_fnc_findSafePos;
		private _spawned = [_pos2, 0, (_x select 1), _group] call BIS_fnc_spawnVehicle;
		private _crew = _spawned select 1;
		{_x setSkill 1}forEach _crew;
		(_crew select 0) setRank "PRIVATE";
		if (count _crew > 0) then {(_crew select 1) setRank "CORPORAL"};
		if (count _crew > 1) then {(_crew select 2) setRank "SERGEANT"};
	}forEach _vehicles;
	
	if (count _infantry > 0) then {
		/// set inf/mixed group leader as inf SL
		_group selectLeader ((units _group) select 0);
	} else {
		/// set veh group leader as gunner -> commander
		private _count = count units _group;
		_group selectLeader ((units _group) select (_count - 1));
	};	
	
	/// return group
	_group
};

/// TBD
HEX_FNC_SRV_SPAWNSTATIC = {
	private _hexpos = _this select 0;
	private _side = _this select 1;
	private _dir = _this select 2;
	private _factions = [HEX_WEST];
	private _icon = "b_installation";
	if (_side == east) then {_factions = [HEX_EAST]; _icon = "o_installation"};
	
	private _configs = [];
	
	
		/// Scan throught cfgVehicles
	{
		private _veh = _x;
		private _fac = getText (_x >> "faction");
		private _sco = getNumber (_x >> "scope");
		private _cfg = configName _x;

		if (_sco == 2 && _fac in _factions) then {
			private _amo = getNumber (_veh >> "transportAmmo");
			private _plo = getNumber (_veh >> "transportFuel");
			private _rep = getNumber (_veh >> "transportRepair");
			private _art = getNumber (_veh >> "artilleryScanner");
			private _sup = _amo + _plo + _rep;
			private _med = getNumber (_veh >> "attendant");
			private _eng = getNumber (_veh >> "engineer");
			private _sup2 = _med + _eng;
			private _sim = toLower getText (_veh >> "simulation");
			private _drv = getNumber (_veh >> "hasDriver");
			private _cls = getText (_veh >> "vehicleClass");

			if (_sim == "tankx" && _sup == 0 && _sup2 == 0 && _art == 0 && _drv == 0 && _cls != "Autonomous") then {_configs pushback _cfg};
		};
	} forEach ("true" configClasses (configFile >> "CfgVehicles"));
	
	if (count _configs > 0) then {
		private _config = _configs select floor random count _configs;
		private _pos = [_hexpos, 0, HEX_SIZE / 2, 5, 0, 0, 0, [], _hexpos] call BIS_fnc_findSafePos;
		private _spawned = [_pos, _dir, _config, _side] call BIS_fnc_spawnVehicle;	
		private _crew = _spawned select 1;
		private _group = _spawned select 2;
		{_x setSkill 1}forEach _crew;
		_group setVariable ["MARTA_customIcon", [_icon], true];
	}
};

/// TBD
HEX_FNC_SRV_SPAWNSITE= {
	/// site minefield module
	/// place trenches
	/// call statics/ garrison in trenches?
};