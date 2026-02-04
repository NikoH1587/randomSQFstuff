class HEX_STRATEGIC {
	idd = 1300;
		
	class controls
	{		
		class Info: RscText
		{
			idc = 1301;
			x = GUI_GRID_TOPCENTER_X + 15 * GUI_GRID_CENTER_W;
			y = GUI_GRID_TOPCENTER_Y + 0 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 1.5 * GUI_GRID_CENTER_H;
		};
		
		class Time: RscText
		{
			idc = 1302;
			x = GUI_GRID_TOPCENTER_X + 15 * GUI_GRID_CENTER_W;
			y = GUI_GRID_TOPCENTER_Y + 1.5 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 1.5 * GUI_GRID_CENTER_H;
		};
		
		class Turn: RscButton
		{
			idc = 1304;
			x = GUI_GRID_TOPCENTER_X + 15 * GUI_GRID_CENTER_W;
			y = GUI_GRID_TOPCENTER_Y + 3 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 1.5 * GUI_GRID_CENTER_H;
			onButtonClick = "[] call HEX_LOC_FNC_ENDTURN;";
		};
	};
};
