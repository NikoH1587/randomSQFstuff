/// close loading menu
HEX_PHASE = "CUSTOM";
HEX_DAY = 0;
(findDisplay 1100) closedisplay 1;

HEX_FULLMAP = false;
HEX_SIZE = 750;
HEX_WEST = "BLU_F"; /// faction name for spawning
HEX_EAST = "OPF_F";

HEX_CFG_WEST = ["b_hq"];
HEX_CFG_EAST = ["o_hq"];

/// Open custom menu for admin
[] spawn {
	while {HEX_PHASE == "CUSTOM"} do {
		if (isNull findDisplay 1200) then {
			createDialog "HEX_CUSTOM";
			private _menu = findDisplay 1200;
			private _facWest = _menu displayCtrl 1201;
			private _facEast = _menu displayCtrl 1202;
			
			HEX_ADM_ALLWEST = [];
			private _allWest = 0 call HEX_ADM_FNC_FACTIONS;
			{
				HEX_ADM_ALLWEST pushBack (_x select 0);
				private _added = _facWest lbAdd (_x select 1);
				_facWest lbSetPicture [_added, _x select 2];
			}forEach _allWest;
			
			HEX_ADM_ALLEAST = [];			
			private _alleast = 0 call HEX_ADM_FNC_FACTIONS;
			{
				HEX_ADM_ALLEAST pushBack (_x select 0);
				private _added = _facEast lbAdd (_x select 1);
				_facEast lbSetPicture [_added, _x select 2];				
			}forEach _allEast;
			
			private _listWest = _menu displayCtrl 1203;
			private _selWest = _menu displayCtrl 1204;
			private _selEast = _menu displayCtrl 1205;
			private _listEast = _menu displayCtrl 1206;
			
			private _scenario = _menu displayCtrl 1207;
			_scenario lbAdd "WEST";
			_scenario lbAdd "NORT";
			_scenario lbAdd "EAST";
			_scenario lbAdd "SOUTH";
			_scenario lbSetCurSel 0;
			
			private _time = _menu displayCtrl 1208;
			_time lbAdd "NIGHT";
			_time lbAdd "DAWN";
			_time lbAdd "DAY";
			_time lbAdd "DAY";
			_time lbAdd "DAY";
			_time lbAdd "DUSK";
			_time lbSetCurSel 0;
			
			private _turn = _menu displayCtrl 1209;
			_turn lbAdd "BLUFOR";
			_turn lbAdd "OPFOR";
			_turn lbSetCurSel 0;
		};
		
		sleep 1;
	};
};