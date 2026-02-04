waitUntil {!isNil "HEX_GRID" && !isNIl "HEX_PHASE"};

/// Update counters locally
0 spawn HEX_LOC_FNC_COTE;

/// close loading menu
(findDisplay 1100) closedisplay 1;
(findDisplay 1200) closedisplay 1;
openmap true;

HEX_LOC_MODE = "SELECT"; /// "SELECT", "ORDER", "NONE";
HEX_LOC_ORDERS = [];
HEX_LOC_SELECT = [];

HEX_LOC_SOUNDS = [
"a3\dubbing_radio_f\sfx\in2a.ogg",
"a3\dubbing_radio_f\sfx\in2b.ogg",
"a3\dubbing_radio_f\sfx\in2c.ogg",
"a3\dubbing_radio_f\sfx\out2a.ogg",
"a3\dubbing_radio_f\sfx\out2b.ogg",
"a3\dubbing_radio_f\sfx\out2c.ogg"
];

HEX_LOC_RADIO = [
"a3\dubbing_radio_f\sfx\radionoise1.ogg",
"a3\dubbing_radio_f\sfx\radionoise2.ogg",
"a3\dubbing_radio_f\sfx\radionoise3.ogg"
];

/// Open menu
[] spawn {
	private _open = false;
	while {HEX_PHASE == "STRATEGIC"} do {
		sleep 0.1;
		if (visibleMap && !_open) then {
			(findDisplay 46) createDisplay "HEX_STRATEGIC";
			private _menu = findDisplay 1300;
			_open = true;
			private _time = _menu displayCtrl 1302;
			private _weather = _menu displayCtrl 1303;
			private _turn = _menu displayCtrl 1303;

			private _color = [0, 0.3, 0.6, 0.5];
			
			if (playerSide == east) then {
				_color = [0.5, 0, 0, 0.5];
			};

			_time ctrlSetBackgroundColor _color;
			_turn ctrlSetBackgroundColor _color;
			
			/// Command
			onMapSingleClick {
				if (HEX_LOC_MODE == "SELECT" && HEX_LOC_COMMANDER && side player == HEX_TURN) then {
					_pos spawn HEX_LOC_FNC_SELECT;
				};
	
				if (HEX_LOC_MODE == "ORDER" && HEX_LOC_COMMANDER && side player == HEX_TURN) then {
					_pos spawn HEX_LOC_FNC_ORDER;
				};
				true;
			};
		};
		
		/// Update information
		if (visibleMap && _open) then {
			private _menu = findDisplay 1300;
			private _info = _menu displayCtrl 1301;
			private _time = _menu displayCtrl 1302;
			private _turn = _menu displayCtrl 1304;
			
			if (HEX_TURN == west) then {
				_info ctrlSetBackgroundColor [0, 0.3, 0.6, 0.5];
				_info ctrlSetText "BLUFOR COMMANDER TURN";
			} else {
				_info ctrlSetBackgroundColor [0.5, 0, 0, 0.5];
				_info ctrlSetText "OPFOR COMMANDER TURN";
			};
			
			private _timeTEXT = HEX_TIME;
			if (_timeTEXT in ["DAY1", "DAY2", "DAY3"]) then {_timeTEXT = "DAY"};
			_time ctrlSetText ("D+" + str HEX_DAY + " - " + _timeTEXT + " - " + HEX_WEATHER);
			
			if (side player == HEX_TURN && HEX_LOC_COMMANDER) then {
				_turn ctrlSetText "END TURN";
			} else {
				if (HEX_TURN == west) then {
				
				};
				_turn ctrlSetText "WAITING...";	
			};
		};
		
		if (!visiblemap && _open) then {
			(findDisplay 1300) closedisplay 1;
			_open = false;
			
		};
	};
};

/// TBD: Road +1 move skip:
/// Origin (1st hex) has to have road hex
/// Middle (2nd hex w/HEX_GLO_FNC_NEAR) is civilian & Road
/// destination (3rd) is civilian & Road

/// Could also be done like this (would use flood as origin point, with enemy ZoC + max radius limiting it):
/// road tile + logi(support) = move another unit into road hex
/// friendly helo + airport = move another unit into hex
/// ship + harbor = move another unit into shore hex
/// HQ = Teleport in reserve/imaginary units?
			
/// Aircraft carrier / etc ship = airport + harbor
/// this could make airdrops/shore landings possible