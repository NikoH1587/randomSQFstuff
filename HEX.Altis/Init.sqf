/// Load local functions
call compile preprocessFile "HEX\Global\Functions.sqf";
call compile preprocessFile "HEX\Local\Functions.sqf";

HEX_LOC_ADMIN = false;
HEX_LOC_COMMANDER = false;
HEX_SINGLEPLAYER = false;
/// Load server functions
if (isServer) then {
	{removeSwitchableUnit _x}forEach allUnits;
	call compile preprocessFile "HEX\Server\Functions.sqf";
};

/// Load admin functions
if (player == HEX_ADMIN) then {
	call compile preprocessFile "HEX\Admin\Functions.sqf";
	HEX_LOC_ADMIN = true;
	HEX_PHASE = "LOADING";
	publicVariable "HEX_PHASE";
	remoteExec ["HEX_LOC_FNC_LOAD", 0, true];
	removeSwitchableUnit HEX_ADMIN; /// remove slotting to ghost unit
};

if ((call BIS_fnc_getNetMode) == "SinglePlayer") then {
	HEX_SINGLEPLAYER = true;
};

///[] call BIS_fnc_jukebox; /// maybe add this at start of tactical phase?

/// ToDo:
///
/// Make magic support vehicle
/// make do repair, rearm, refuel, medical and place infantry ammo in cargo
/// setFuelCargo 0, setAmmoCargo 0, setRepairCargo 0
///
/// Each counter represents a company
/// In-game actually spawns just a platoon
/// Company is simulated with platoon's reinforcements (also unit's hitpoints)
///
/// Make each "Company" (Platoon) counter customiable
///
/// Change strategic time steps to 1 hour
/// More "dynamic" weather
/// Value that goes up / down?
///
/// Move functions to functions library
/// https://community.bistudio.com/wiki/Arma_3:_Functions_Library
///
///
/// Fix stuff if game is loaded from save (This file mostly?)
///
/// "AI Commander" places markers on map of enemy units etc on side channel
/// alternatively: radio sidechat messages?


/// Experimental mode ??? TBD:
/// flee max for groups: https://community.bistudio.com/wiki/setSkill
/// skillName: String - available sub-skills are: "courage" 0
/// Bigger hexes (1000)
/// aircraft / helo on airbases
/// fullmap by Default


/// random reinforcements on every day (1x support, 2x inf, 2x rando

/// Description;
///
/// HEX is a persistent mission, where real-time battles are generated from hex&counter wargame system.
/// Playable in singleplayer or multiplayer up to 20 players.
/// Customizable factions (DLC or mod) with freedom of forces scale, ratio and composition.
///
/// Players can choose the role of Commander, Leaders or Soldiers.
/// Commander dictates strategic actions on hex board, and tactics with High Command interface.
/// Leaders put Commander's orders in action, with a squad of Soldiers in real-time combat.
///
/// Campaign is split in multiple two-part phases, with progressing time and weather:
/// Strategic phase: Turn-based manouvers of counters on strategic hex-board.
/// Tactical phase: Connected counters are played out in real-time battle.
///
/// Counters are divided in two types: Primary and Auxiliary.
/// Primary (Infantry, Motorized, Mechanized, Armored, Recon) spawn tactical groups.
/// Auxiliary (Artillery, Support, Aircraft, Helicopters, Anti-Air) spawn strategic units.
///
/// Victory over enemy counters is achieved by capture of area in tactical battle.
/// Counters captured will be initially disorginized, and ultimately destroyed.
/// Campaign victory is achieved by destroying enemy Headquarters counter.
///
/// Copyright: Arma Public Licence (APL)

/// TBD: End scenario with list of casualities

/// First Menu: /// "LOADING"
/// Title, Author, Version
/// Cool picture
/// Select West / East Commanders
/// Commander select 0 == AI commander
/// Continue Campaign / Default Campaign
/// New Campaign

/// Second Menu (new campaign): /// "NEWSAVE"
/// West / East faction
/// Current West / Selectable West
/// Current East / Selectable East
/// Scenario Direction
/// First Turn West/East
/// Experimental toggle
/// "START CAMPAIGN"

/// Third Menu: /// "STRATEGIC"
/// Turn info
/// End Turn

/// Fourth menu: /// "BRIEFING"
/// Tactical Briefing
/// "To battle!" button

/// Fifth Menu: /// "TACTICAL"
/// Respawn / Slotting screen


/// Sixth menu: /// "DEBRIEFING"
/// Tactical Debriefing
/// "Save & Continue" button
/// "Save & Exit" button

/// Sources used: 
/// https://www.youtube.com/watch?v=kDFAHoxdL4Y&list=PLrFF_4LjPgISFZ6TzRi82O153ZQp5H-TJ
/// https://fieldgradeleader.themilitaryleader.com/wp-content/uploads/2017/10/2017-07-The-Russian-Way-of-War-Grau-and-Bartles-The-Defense.pdf
/// https://en.wikipedia.org/wiki/Military_organization
/// picture of military map case:
/// https://commons.wikimedia.org/wiki/File:US_map_case_-_National_World_War_I_Museum_-_Kansas_City,_MO_-_DSC07730.JPG