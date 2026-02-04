params ["_oldUnit", "_killer", "_respawn", "_respawnDelay"];

/// see Slotting.sqf
if (HEX_SINGLEPLAYER == false) then {
	LOC_SLOTTING = true;
};
/// display countdown?
/// display killer?
/// switch player to ghost unit ?