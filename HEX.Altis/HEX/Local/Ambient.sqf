waitUntil {!isNil "HEX_PHASE"};
waitUntil {!isNil "HEX_INTENSITY"};

/// Intensity:
/// 0: Occasional radio chatter
/// 1: Occasional radio & Combat
/// 2: Constant radio & Constant combat

AMB_RADIO = [
"a3\sounds_f\sfx\ui\uav\uav_01.wss",
"a3\sounds_f\sfx\ui\uav\uav_02.wss",
"a3\sounds_f\sfx\ui\uav\uav_03.wss",
"a3\sounds_f\sfx\ui\uav\uav_04.wss",
"a3\sounds_f\sfx\ui\uav\uav_05.wss",
"a3\sounds_f\sfx\ui\uav\uav_06.wss",
"a3\sounds_f\sfx\ui\uav\uav_07.wss",
"a3\sounds_f\sfx\ui\uav\uav_08.wss",
"a3\sounds_f\sfx\ui\uav\uav_09.wss"
];

AMB_COMBAT = [
"a3\sounds_f\environment\ambient\battlefield\battlefield_firefight1.wss",
"a3\sounds_f\environment\ambient\battlefield\battlefield_firefight2.wss",
"a3\sounds_f\environment\ambient\battlefield\battlefield_firefight3.wss",
"a3\sounds_f\environment\ambient\battlefield\battlefield_firefight4.wss",
"a3\sounds_f\environment\ambient\battlefield\battlefield_explosions1.wss",
"a3\sounds_f\environment\ambient\battlefield\battlefield_explosions2.wss",
"a3\sounds_f\environment\ambient\battlefield\battlefield_explosions3.wss",
"a3\sounds_f\environment\ambient\battlefield\battlefield_explosions4.wss",
"a3\sounds_f\environment\ambient\battlefield\battlefield_explosions5.wss"
];

/// play ambient radio sounds
0 spawn {
	while {HEX_PHASE == "STRATEGIC" or HEX_PHASE == "BRIEFING"} do {
		private _delay = 5;
		if (HEX_INTENSITY > 0) then {
			_delay = 10 + (random 5);
			private _radio = AMB_RADIO select floor random count AMB_RADIO;
			playSoundUI [_radio, 0.5];
		};
		sleep _delay;
	};
};

/// play ambient combat sounds
0 spawn {
	while {HEX_PHASE == "STRATEGIC" or HEX_PHASE == "BRIEFING"} do {
		private _delay = 5;
		if (HEX_INTENSITY > 2) then {
			_delay = 10 + (random 5);
			private _combat = AMB_COMBAT select floor random count AMB_COMBAT;
			playSoundUI [_combat, 0.5];
		};
		sleep _delay;
	};
};