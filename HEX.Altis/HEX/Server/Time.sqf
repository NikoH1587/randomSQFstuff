/// Set weather
private _overcast = 0;
private _fog = 0;
if (HEX_WEATHER == "CLOUDS") then {_overcast = 0.5};
if (HEX_WEATHER == "STORM") then {_overcast = 1};
if (HEX_WEATHER == "FOG") then {_fog = 0.2};
0 setOverCast _overcast;
0 setFog _fog;
forceWeatherChange;

/// Set date
private _now = date;
private _year = _now select 0;
private _month = _now select 1;

private _day = HEX_DAY;	

private _hour = 0;
if (HEX_TIME == "NIGHT") then {_hour = -3 + (floor (random 9))};
if (HEX_TIME == "DAWN") then {_hour = 6 + (floor (random 3))}; 
if (HEX_TIME == "DAY1") then {_hour = 9 + (floor (random 3))};
if (HEX_TIME == "DAY2") then {_hour = 12 + (floor (random 3))};
if (HEX_TIME == "DAY3") then {_hour = 15 + (floor (random 3))};
if (HEX_TIME == "DUSK") then {_hour = 18 + (floor (random 3))};

private _date = [_year, _month, _day, _hour, 0] call BIS_fnc_fixDate;
setDate _date;