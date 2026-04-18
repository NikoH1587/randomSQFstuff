if (!isServer) exitWith {hint "not server"};

"VOX_AO" setMarkerPos ([] call BIS_fnc_randomPos); /// position can be changed in menu?
VOX_SCENARIO = ["WEST","NORTH","EAST","SOUTH"] select floor random 4;
VOX_PHASE = "NEWGAME"; /// "NEWGAME", "OLDGAME", "STRATEGIC", "TACTIACAL", "DEBRIEFING"
VOX_BLUFOR = ["NATO", "NATO"];
VOX_OPFOR = ["CSAT", "CSAT"];
VOX_SIZE = 250; /// cell size
/// alternatively load grid from missionProfileNamespace
VOX_GRID = [];
VOX_DEBUG = true;

[] spawn {
	if (VOX_PHASE == "NEWGAME") then {
		private _generate = execVM "vox_generate.sqf";
		waitUntil {scriptDone _generate};
		private _strategic = execVM "vox_strategic.sqf";
		waitUntil {scriptDone _strategic};		
		
	};
};



