//====================================================================================
//
//	wh_ep_toggleKey.sqf - Sets up a key that can be used to toggle plugs with a press.
//							Behavior varies depending on presence of CBA.
//
//	@ /u/Whalen207 | Whale #5963
//
//====================================================================================

//------------------------------------------------------------------------------------
//	Parameters:
//	1. _cbaPresent (BOOL) - Presence of CBA addon in mission. Default: false
//------------------------------------------------------------------------------------

params [["_cbaPresent",false]];


//------------------------------------------------------------------------------------
//	If CBA is NOT present: Setup the Toggle Key, default '-'.
//------------------------------------------------------------------------------------

if !_cbaPresent then
{

//	Setup toggleKey names.
WH_EP_TOGGLE_ID = (actionKeys WH_EP_TOGGLE_KEY) select 0; // This key, a global variable.
WH_EP_TOGGLE_NAME = actionKeysNames WH_EP_TOGGLE_KEY; // Which is named this...

//	Stop here (do not setup key handlers) if the system is disabled.
if (!WH_EP_TOGGLE) exitWith {};

//	If the key is already established, exit.
if (uiNamespace getVariable ["WH_EP_EH_KEYDOWN",-1] > -1) exitWith {};

//	Function that will determine when the disableKey is depressed.
_keydownCode = 
{
	_key = _this select 1;
	_handled = false;
	if(_key == WH_EP_TOGGLE_ID) then
	{
		if (!(player getVariable 'WH_EP_EARPLUGS_IN'))
		then { WH_EP_MANUAL = true; call wh_ep_fnc_insert; }
		else { WH_EP_MANUAL = false; call wh_ep_fnc_remove; };
		
		_handled = true;
	};
	_handled;
};

//	Function that will determine when the disableKey is released.
_keyupCode = 
{
	_key = _this select 1;
	_handled = false;
	if(_key == WH_EP_TOGGLE_ID) then
	{ _handled = true; };
	_handled;
};

//	Add eventhandlers (functions above).
_eh_keydown = (findDisplay 46) displayAddEventHandler ["keydown", _keydownCode];
_eh_keyup = (findDisplay 46) displayAddEventHandler ["keyup", _keyupCode];

uiNamespace setVariable ["WH_EP_EH_KEYDOWN",_eh_keydown];
uiNamespace setVariable ["WH_EP_EH_KEYUP",_eh_keyup];

}


//------------------------------------------------------------------------------------
//	If CBA IS present: Setup the Toggle UserKey, default '-'.
//------------------------------------------------------------------------------------

else
{
	["WH Earplugs", // Mod name
	"WH_EP_TOGGLE_CBA", // Key name
	["Toggle Earplugs","Remove or insert WH earplugs with a keypress."], // Key display name
	{
		if (!(player getVariable 'WH_EP_EARPLUGS_IN'))
		then { WH_EP_MANUAL = true; call wh_ep_fnc_insert; }
		else { WH_EP_MANUAL = false; call wh_ep_fnc_remove; };
	}, // Code ran on keydown
	"", // Code ran on keyup
	[0x0C, [false, false, false]]] // Default keybind [KEY, [SHIFT,CTRL,ALT]]
	call CBA_fnc_addKeybind; // Function call
	
	["WH Earplugs", // Mod name
	"WH_EP_HOLDTODEAF_CBA", // Key name
	["Hold to Deafen","Sound will be reduced as long as this key is held."], // Key display name
	{ WH_EP_MANUAL = true; call wh_ep_fnc_insert; }, // Code ran on keydown
	{ WH_EP_MANUAL = false; call wh_ep_fnc_remove; }] // Code ran on keyup
	call CBA_fnc_addKeybind; // Function call
};