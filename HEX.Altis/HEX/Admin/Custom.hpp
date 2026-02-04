class HEX_CUSTOM
{
	idd = 1200;

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
		class WestText: RscText
		{
			text = "BLUFOR";
			idc = -1;
			colorBackground[] = {0, 0.3, 0.6, 0.5};
			x = GUI_GRID_CENTER_X + 10 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 0 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 2 * GUI_GRID_CENTER_H;
		};
		
		class FacWest: RscCombo
		{
			idc = 1201;
			x = GUI_GRID_CENTER_X + 0 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 0 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 2 * GUI_GRID_CENTER_H;
			onLBSelChanged = "(_this select 1) call HEX_ADM_FNC_FACWEST";
		};			
	
		class FacEast: RscCombo
		{
			idc = 1202;
			x = GUI_GRID_CENTER_X + 30 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 0 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 2 * GUI_GRID_CENTER_H;
			onLBSelChanged = "(_this select 1) call HEX_ADM_FNC_FACEAST";
		};
		
		class EastText: RscText
		{
			text = "OPFOR";
			idc = -1;
			colorBackground[] = {0.5, 0, 0, 0.5};
			x = GUI_GRID_CENTER_X + 20 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 0 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 2 * GUI_GRID_CENTER_H;
		};	
		
		class List_West : RscListbox
		{
			idc = 1203;
			x = GUI_GRID_CENTER_X + 0 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 2 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 18 * GUI_GRID_CENTER_H;
			onLBSelChanged = "(_this select 1) call HEX_ADM_FNC_ADDWEST";
			rowHeight = 1.5 * GUI_GRID_CENTER_H;
		};
		
		class Selected_West : RscListbox
		{
			idc = 1204;
			x = GUI_GRID_CENTER_X + 10 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 2 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 18 * GUI_GRID_CENTER_H;
			onLBSelChanged = "(_this select 1) call HEX_ADM_FNC_DELETEWEST";
			rowHeight = 1.5 * GUI_GRID_CENTER_H;
		};
		
		class Selected_East : RscListbox
		{
			idc = 1205;
			x = GUI_GRID_CENTER_X + 20 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 2 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 18 * GUI_GRID_CENTER_H;
			onLBSelChanged = "(_this select 1) call HEX_ADM_FNC_DELETEEAST";
			rowHeight = 1.5 * GUI_GRID_CENTER_H;
		};
		
		class List_East : RscListbox
		{
			idc = 1206;
			x = GUI_GRID_CENTER_X + 30 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 2 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 18 * GUI_GRID_CENTER_H;
			onLBSelChanged = "(_this select 1) call HEX_ADM_FNC_ADDEAST";
			rowHeight = 1.5 * GUI_GRID_CENTER_H;
		};
		
		class Scenario: RscCombo
		{
			idc = 1207;
			x = GUI_GRID_CENTER_X + 0 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 20 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 2 * GUI_GRID_CENTER_H;
			onLBSelChanged = "HEX_SCENARIO = ['W','N','E','S'] select (_this select 1);";
		};
		
		class Time: RscCombo
		{
			idc = 1208;
			x = GUI_GRID_CENTER_X + 10 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 20 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 2 * GUI_GRID_CENTER_H;
			onLBSelChanged = "HEX_TIME = ['NIGHT','DAWN','DAY1','DAY2', 'DUSK'] select (_this select 1);";
			tooltip = "Set initial time.";
		};

		class Turn: RscCombo
		{
			idc = 1209;
			x = GUI_GRID_CENTER_X + 20 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 20 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 2 * GUI_GRID_CENTER_H;
			onLBSelChanged = "HEX_TURN = [west, east] select (_this select 1);";
			tooltip = "Set starting turn.";
		};
		
		class SizeText: RscText
		{
			text = "WHOLE MAP";
			idc = -1;
			x = GUI_GRID_CENTER_X + 32 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 20 * GUI_GRID_CENTER_H;
			w = 8 * GUI_GRID_CENTER_W;
			h = 2 * GUI_GRID_CENTER_H;
		};
		
		class Size: RscCheckBox
		{
			checked = 0;
			idc = 1210;
			x = GUI_GRID_CENTER_X + 30 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 20 * GUI_GRID_CENTER_H;
			w = 2 * GUI_GRID_CENTER_W;
			h = 2 * GUI_GRID_CENTER_H;
			onCheckedChanged = "HEX_FULLMAP = [false, true] select (_this select 1);";
			tooltip = "Turn on experimental full map mode";
		};
		
		class Export: RscEdit
		{
			idc = 1211;
			x = GUI_GRID_CENTER_X + 0 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 22 * GUI_GRID_CENTER_H;
			w = 30 * GUI_GRID_CENTER_W;
			h = 2 * GUI_GRID_CENTER_H;
		};
		
		class Start: RscButton
		{
			idc = 1212;
			x = GUI_GRID_CENTER_X + 30 * GUI_GRID_CENTER_W;
			y = GUI_GRID_CENTER_Y + 22 * GUI_GRID_CENTER_H;
			w = 10 * GUI_GRID_CENTER_W;
			h = 2 * GUI_GRID_CENTER_H;
			onButtonClick = "[] call HEX_ADM_FNC_START;";
		};		
	};
};