/// Default variables
HEX_SIZE = 750;
HEX_PHASE = "STRATEGIC";
HEX_SCENARIO = ["W", "E", "N", "S"] select floor random 4;
HEX_TIME = ["NIGHT", "DAWN", "DAY1", "DAY2", "DAY3", "DUSK"] select floor random 6;
HEX_DAY = 0;
HEX_TURN = [west, east] select floor random 2;
HEX_WEST = "BLU_F";
HEX_EAST = "OPF_F";
HEX_FULLMAP = false;

/// Create random west counters
/// 3 battallion per side (3x + 3x + 3x inf) + 3 supports

/// BLUFOR
private _allAux = ["b_support", "b_mortar", "b_art", "b_antiair", "b_air", "b_plane", "b_uav"];
private _allPri = ["b_unknown", "b_inf", "b_recon", "b_motor_inf", "b_mech_inf", "b_armor"];

private _aux1 = _allAux select floor random count _allAux;
_allAux = _allAux - [_aux1];
private _aux2 = _allAux select floor random count _allAux;
_allAux = _allAux - [_aux2];
private _aux3 = _allAux select floor random count _allAux;

private _pri1 = _allPri select floor random count _allPri;
_allPri = _allPri - [_pri1];
private _pri2 = _allPri select floor random count _allPri;
_allPri = _allPri - [_pri2];
private _pri3 = _allPri select floor random count _allPri;

HEX_CFG_WEST = ["b_hq", _aux1, _aux2, _aux3, _pri1, _pri1, _pri1, _pri2, _pri3];

/// OPFOR
private _allAux = ["o_support", "o_mortar", "o_art", "o_antiair", "o_air", "o_plane", "o_uav"];
private _allPri = ["o_unknown", "o_inf", "o_recon", "o_motor_inf", "o_mech_inf", "o_armor"];

private _aux1 = _allAux select floor random count _allAux;
_allAux = _allAux - [_aux1];
private _aux2 = _allAux select floor random count _allAux;
_allAux = _allAux - [_aux2];
private _aux3 = _allAux select floor random count _allAux;

private _pri1 = _allPri select floor random count _allPri;
_allPri = _allPri - [_pri1];
private _pri2 = _allPri select floor random count _allPri;
_allPri = _allPri - [_pri2];
private _pri3 = _allPri select floor random count _allPri;

HEX_CFG_EAST = ["o_hq", _aux1, _aux2, _aux3, _pri1, _pri1, _pri1, _pri2, _pri3];

/// Globalize variables
publicVariable "HEX_SIZE";
publicVariable "HEX_TIME";
publicVariable "HEX_TURN";
publicVariable "HEX_PHASE";

/// generate grid, counters & weather
call compile preprocessFile "HEX\Server\Generation.sqf";

/// update zone of control
0 call HEX_SRV_FNC_ZOCO;

/// update time and weather
call compile preprocessFile "HEX\Server\Time.sqf";	

/// begin strategic phase
remoteExec ["HEX_LOC_FNC_STRATEGIC", 0, false];

