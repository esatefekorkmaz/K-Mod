#pragma reqlib "ibm say"
#if !defined AMXMODX_NOAUTOLOAD
  #pragma loadlib "ibm say"
#endif
#include <amxmodx>
#include <fakemeta>
/**************************
 *        FORWARDS        *
 **************************/
forward ibm_say_main();


/**************************
 *        NATIVES         *
 **************************/
 /**
 * @param cmdname			Say commands name(for multi commands seperate with '|')
 * @param function 			Target functions
 * @param accessflag		Admin access
 * @param len				Minimum Commands parameters 
 * @param context			Commands context
 * @param CmdInfo			Commands info
 * @param PluginPrefix 		Will be displaying message prefix(eg [TEST])
 * @param ShowAll			Show received message to all player.
 * @param NoHandleOnError	If there are errors when typing commands. PLUGIN_HANDLED is not used.
 * @param ShowSuccessMsg	If the message is applied, show success mesage.
 */
native register_saycmd(cmdname[], function[], accessflag = -1, len = 0, context[] = "", CmdInfo[] = "", PluginPrefix[] = "", bool:ShowAll=false, bool:NoHandleOnError=false, bool:ShowSuccessMsg=true);

 /**
 * @param index				Which param
 * @OutPut					OutPut
 * len						OutPut lenght.
 */
native get_say_argv(index, OutPut[], len);
native get_say_argc();