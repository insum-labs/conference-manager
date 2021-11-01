create or replace package ks_plugins
is


--------------------------------------------------------------------------------
--*
--* Save application plugins code
--*
--------------------------------------------------------------------------------

subtype gt_string is varchar2(32767);

--------------------------------------------------------------------------------
FUNCTION built_with_love_render_region(p_region              IN apex_plugin.t_region,
                       p_plugin              IN apex_plugin.t_plugin,
                       p_is_printer_friendly IN BOOLEAN)
  RETURN apex_plugin.t_region_render_result;

--------------------------------------------------------------------------------
function select2_render(
           p_item in apex_plugin.t_page_item,
           p_plugin in apex_plugin.t_plugin,
           p_value in gt_string,
           p_is_readonly in boolean,
           p_is_printer_friendly in boolean
         ) 
  return apex_plugin.t_page_item_render_result;

function select2_ajax(
           p_item in apex_plugin.t_page_item,
           p_plugin in apex_plugin.t_plugin
         ) 
  return apex_plugin.t_page_item_ajax_result;

--------------------------------------------------------------------------------
function render_simple_checkbox (
    p_item                in apex_plugin.t_page_item,
    p_plugin              in apex_plugin.t_plugin,
    p_value               in varchar2,
    p_is_readonly         in boolean,
    p_is_printer_friendly in boolean )
    return apex_plugin.t_page_item_render_result;

function validate_simple_checkbox (
    p_item   in apex_plugin.t_page_item,
    p_plugin in apex_plugin.t_plugin,
    p_value  in varchar2
)
return apex_plugin.t_page_item_validation_result;


--------------------------------------------------------------------------------
FUNCTION render_apexspotlight(p_dynamic_action IN apex_plugin.t_dynamic_action,
                              p_plugin         IN apex_plugin.t_plugin)
  RETURN apex_plugin.t_dynamic_action_render_result;

FUNCTION ajax_apexspotlight(p_dynamic_action IN apex_plugin.t_dynamic_action,
                            p_plugin         IN apex_plugin.t_plugin)
  RETURN apex_plugin.t_dynamic_action_ajax_result;


end ks_plugins;
/
