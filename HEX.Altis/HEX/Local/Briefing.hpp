class HEX_BRIEFING
{
	idd = 1400;

	class ControlsBackground
	{
		class Background : RscText
		{
			idc = -1;
			x = GUI_GRID_CENTER_X + 0 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 0 * GUI_GRID_CENTER_H;
			w = 40 * GUI_GRID_CENTER_W;
			h = 24 * GUI_GRID_CENTER_H;
			colorBackground[] = {0.1,0.1,0.1,1};
		};
	};

	class Controls
	{
		class Text : RscText
		{
			text = "TACTICAL BRIEFING";
			idc = 1401;
			x = GUI_GRID_CENTER_X + 0 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 0 * GUI_GRID_CENTER_H;
			w = 20 * GUI_GRID_CENTER_W;
			h = 2 * GUI_GRID_CENTER_H;
		};
		
		class Info : RscListbox
		{
			idc = 1402;
			x = GUI_GRID_CENTER_X + 0 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 2 * GUI_GRID_CENTER_H;
			w = 20 * GUI_GRID_CENTER_W;
			h = 6 * GUI_GRID_CENTER_H;
			rowHeight = 1 * GUI_GRID_CENTER_H;
		};		
		
		class List_West : RscListbox
		{
			idc = 1403;
			x = GUI_GRID_CENTER_X + 0 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 8 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 14 * GUI_GRID_CENTER_H;
			colorBackground[] = {0, 0.3, 0.6, 0.5};
			onLBSelChanged = "hint 'change minimap position to show unit'";
			rowHeight = 1.5 * GUI_GRID_CENTER_H;
		};
		
		class List_East : RscListbox
		{
			idc = 1404;
			x = GUI_GRID_CENTER_X + 10 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 8 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 14 * GUI_GRID_CENTER_H;
			colorBackground[] = {0.5, 0, 0, 0.5};
			onLBSelChanged = "hint 'change minimap position to show unit'";
			rowHeight = 1.5 * GUI_GRID_CENTER_H;
		};
		
		class Start: RscButton
		{
			idc = 1405;
			x = GUI_GRID_CENTER_X + 5 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 22 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 2 * GUI_GRID_CENTER_H;
			onButtonClick = "[] call HEX_ADM_FNC_TACTICAL;";
		};
		
		class Minimap : RscMapControl
		{
			idc = 1406;
			x = GUI_GRID_CENTER_X + 20 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 0 * GUI_GRID_CENTER_H;
			w = 20 * GUI_GRID_CENTER_W;
			h = 24 * GUI_GRID_CENTER_H;
		};
	};
};