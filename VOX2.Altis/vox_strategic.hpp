class VOX_STRATEGIC
{
	idd = 1100;

	class Controls
	{		
		
		class info: RscListbox
		{
			idc = 1401;
			x = GUI_GRID_CENTER_X + 0 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 20 * GUI_GRID_CENTER_H;
			w = 30 * GUI_GRID_CENTER_W;
			h = 5 * GUI_GRID_CENTER_H;
		};
		
		class start: RscButton
		{
			idc = 1402;
			x = GUI_GRID_CENTER_X + 30 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 20 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 5 * GUI_GRID_CENTER_H;
			onButtonClick = "[] call VOX_FNC_ENDBRIEFING;";
		};		
		

	};
};