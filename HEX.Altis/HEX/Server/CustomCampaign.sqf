/// HEX_ variables from admin

/// generate grid, counters & weather
call compile preprocessFile "HEX\Server\Generation.sqf";

/// update zone of control
0 call HEX_SRV_FNC_ZOCO;

/// update time and weather
call compile preprocessFile "HEX\Server\Time.sqf";

/// begin strategic phase
remoteExec ["HEX_LOC_FNC_STRATEGIC", 0, false];	