/// set reference time
HEX_GAMETIME = time;
HEX_PHASE = "GAME";
publicVariable "HEX_PHASE";
/// respawn loop for tactical groups
/// strat assets don't respawn (simpler)
while {HEX_PHASE == "GAME"} do {
	{
		private _hex = _x;
		private _row = _x select 0;
		private _col = _x select 1;
		private _pos = _x select 2;
		private _type = _x select 3;
		private _side = _x select 4;
		private _count = _x select 6; /// how many groups are stored
	
		/// get hex group amount
		/// _ids = [[_row, _col], []];
		private _amount = [_row, _col, _side] call HEX_SRV_HEXIDS;
	
		/// check if group needs to be spawned
		private _spawn = false;
		private _maxcount = 3;
		if (_type in ["b_inf", "o_inf"]) then {_maxcount = 4};
		if (_amount < _maxcount && _count > 0 && _side != resistance) then {
			_spawn = true;
		};
		
		/// spawn groups
		if (_spawn == true) then {
			private _factions = [HEX_WEST];
			if (_side == east) then {_factions = [HEX_EAST]};
	
			private _armor = false;
			if (_type in ["b_armor", "o_armor"]) then {_armor = true};
			private _groupsAndWeights = [_factions, _type] call HEX_SRV_FNC_GROUPS;
			private _weights = [];
			private _groups = [];
	
			{
				_weights pushback (_x select 0);
				_groups pushback (_x select 1);
			}ForEach _groupsAndWeights;
	
			/// remove group from pool
			[_hex, _count, 1] call HEX_SRV_FNC_SUBTRACT;

			private _select = _groups selectRandomWeighted _weights;
			private _config = "true" configClasses _select;
			if (_armor) then {_config = [_config select 0]};
	
			private _group = [_pos, _side, _config, _type] call HEX_FNC_SRV_SPAWNGROUP;
			_group setVariable ["HEX_ICON", _type, true];
			_group setVariable ["HEX_ID", [_row, _col], true];
			///_group setVariable ["MARTA_customIcon", [_type], true];
			_group deleteGroupWhenEmpty true;

			/// synchronize to HQ
			if (_side == west) then {HEX_OFFICER_WEST hcSetGroup [_group]};
			if (_side == east) then {HEX_OFFICER_EAST hcSetGroup [_group]};
		};
		
		sleep 0.1;
		player sidechat str _hex;
	}forEach HEX_TACTICAL;
	
	sleep 1;
};