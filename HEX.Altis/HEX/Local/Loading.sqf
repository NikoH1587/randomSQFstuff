/// TBD: make a save system
HEX_ADM_SAVE = false;

/// Open loading menu
[] spawn {
	while {HEX_PHASE == "LOADING"} do {
		
		if (isNull findDisplay 1100) then {
			createDialog "HEX_LOADING";
			private _menu = findDisplay 1100;
			private _continue = _menu displayCtrl 1101;
			private _newsave = _menu displayCtrl 1102;
			private _import = _menu displayCtrl 1103;
			private _westtext = _menu displayCtrl 1104;
			private _westCMD = _menu displayCtrl 1105;
			private _easttext = _menu displayCtrl 1106;
			private _eastCMD = _menu displayCtrl 1107;
			
			/// Show setting if player is admin
			if (HEX_LOC_ADMIN) then {
				if (HEX_ADM_SAVE) then {
					_continue ctrlSetText "CONTINUE CAMPAIGN";		
					_newsave ctrlSetText "NEW CAMPAIGN";						
				} else {
					_continue ctrlSetText "DEFAULT CAMPAIGN";		
					_newsave ctrlSetText "CUSTOM CAMPAIGN";
				};
				
				0 call HEX_ADM_FNC_GETPLAYERS;
				
				/// Selection of commanders
				{_westCMD lbAdd _x}forEach HEX_ADM_WEST_PLAYERS;
				{_eastCMD lbAdd _x}forEach HEX_ADM_EAST_PLAYERS;
				
				_westCMD lbsetCurSel 0;
				_eastCMD lbsetCurSel 0;
			} else {
			
				_continue ctrlSetText "WAIT FOR ADMIN...";
				_newsave ctrlShow false;
				_import ctrlShow false;
				_westtext ctrlShow false;
				_westCMD ctrlShow false;
				_easttext ctrlShow false;
				_eastCMD ctrlShow false;
			
			};
		};
		
		sleep 1;
	};
};