set define off
create or replace package body ks_plugins
is

--------------------------------------------------------------------------------
-- TYPES
/**
 * @type
 */

-- CONSTANTS
/**
 * @constant gc_scope_prefix Standard logger package name
 */
gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';


gco_min_lov_cols constant number(1) := 2;
gco_max_lov_cols constant number(1) := 3;
gco_lov_display_col constant number(1) := 1;
gco_lov_return_col constant number(1) := 2;
gco_lov_group_col constant number(1) := 3;
gco_contains_ignore_case constant char(3) := 'CIC';
gco_contains_ignore_case_diac constant char(4) := 'CICD';
gco_contains_case_sensitive constant char(3) := 'CCS';
gco_exact_ignore_case constant char(3) := 'EIC';
gco_exact_case_sensitive constant char(3) := 'ECS';
gco_starts_with_ignore_case constant char(3) := 'SIC';
gco_starts_with_case_sensitive constant char(3) := 'SCS';
gco_multi_word constant char(2) := 'MW';


------------------------------------------------------------------------------

-- ========================================
-- Built with love
-- ========================================
FUNCTION built_with_love_render_region(p_region              IN apex_plugin.t_region,
                       p_plugin              IN apex_plugin.t_plugin,
                       p_is_printer_friendly IN BOOLEAN)
  RETURN apex_plugin.t_region_render_result
IS
  -- plugin attributes
  l_result apex_plugin.t_region_render_result;
  -- other vars
  l_region_id VARCHAR2(200);
  --
BEGIN
  -- Debug
  IF apex_application.g_debug THEN
    apex_plugin_util.debug_region(p_plugin => p_plugin,
                                  p_region => p_region);
  END IF;
  -- set vars
  l_region_id := apex_escape.html_attribute(p_region.static_id ||
                                            '_orclapex_builtwithlove');
  --
  -- write region html
  sys.htp.p('<div id="' || l_region_id || '">' ||
            '<span class="footer-apex">Built with <span class="fa fa-heart"><span class="u-VisuallyHidden">love</span></span> ' ||
            'using <a href="https://apex.oracle.com/" target="_blank" title="Oracle Application Express">Oracle APEX</a> ' ||
            'by <a href="https://insum.ca/" target="_blank" title="Insum Solutions">Insum Solutions</a>' ||
            '</span>' ||
            '</div>');
  --
  RETURN l_result;
  --
END built_with_love_render_region;


-- ========================================
-- Select2
-- ========================================




procedure print_lov_options(
            p_item in apex_plugin.t_page_item,
            p_plugin in apex_plugin.t_plugin,
            p_value in gt_string default null
          ) is
  l_null_optgroup_label_app gt_string := p_plugin.attribute_05;
  l_select_list_type gt_string := p_item.attribute_01;
  l_null_optgroup_label_cmp gt_string := p_item.attribute_09;
  l_drag_and_drop_sorting gt_string := p_item.attribute_11;
  l_lazy_loading gt_string := p_item.attribute_14;

  lco_null_optgroup_label constant gt_string := 'Ungrouped';

  l_lov apex_plugin_util.t_column_value_list;
  l_null_optgroup gt_string;
  l_tmp_optgroup gt_string;
  l_selected_values apex_application_global.vc_arr2;
  l_display_value gt_string;

  type gt_optgroups
    is table of gt_string
    index by pls_integer;
  laa_optgroups gt_optgroups;

  -- local subprograms
  function optgroup_exists(
             p_optgroups in gt_optgroups,
             p_optgroup in gt_string
           ) return boolean is
    l_index pls_integer := p_optgroups.first;
  begin
    while (l_index is not null) loop
      if p_optgroups(l_index) = p_optgroup then
        return true;
      end if;

      l_index := p_optgroups.next(l_index);
    end loop;

    return false;
  end optgroup_exists;


  function is_selected_value(
             p_value in gt_string,
             p_selected_values in gt_string
           ) return boolean is
    l_selected_values apex_application_global.vc_arr2;
  begin
    l_selected_values := apex_util.string_to_table(p_selected_values);

    for i in 1 .. l_selected_values.count loop
      if apex_plugin_util.is_equal(p_value, l_selected_values(i)) then
        return true;
      end if;
    end loop;

    return false;
  end is_selected_value;
begin
  l_lov := apex_plugin_util.get_data(
             p_sql_statement  => p_item.lov_definition,
             p_min_columns => gco_min_lov_cols,
             p_max_columns => gco_max_lov_cols,
             p_component_name => p_item.name
           );

  -- print the selected LOV options in case of lazy loading or when drag and drop sorting is enabled
  if (l_lazy_loading is not null or l_drag_and_drop_sorting is not null) then
    if p_value is not null then
      l_selected_values := apex_util.string_to_table(p_value);

      for i in 1 .. l_selected_values.count loop
        begin
          l_display_value := apex_plugin_util.get_display_data(
                               p_sql_statement => p_item.lov_definition,
                               p_min_columns => gco_min_lov_cols,
                               p_max_columns => gco_max_lov_cols,
                               p_component_name => p_item.name,
                               p_display_column_no => gco_lov_display_col,
                               p_search_column_no => gco_lov_return_col,
                               p_search_string => l_selected_values(i),
                               p_display_extra => false
                             );
        exception
          when no_data_found then
            l_display_value := null;
        end;

        if not (l_display_value is null and not p_item.lov_display_extra) then
          -- print the display value, or return value if no display value was found
          apex_plugin_util.print_option(
            p_display_value => nvl(l_display_value, l_selected_values(i)),
            p_return_value => l_selected_values(i),
            p_is_selected => true,
            p_attributes => p_item.element_option_attributes,
            p_escape => p_item.escape_output
          );
        end if;
      end loop;
    end if;
  end if;

  if l_lazy_loading is null then
    if l_lov.exists(gco_lov_group_col) then
      if l_null_optgroup_label_cmp is not null then
        l_null_optgroup := l_null_optgroup_label_cmp;
      else
        l_null_optgroup := nvl(l_null_optgroup_label_app, lco_null_optgroup_label);
      end if;

      for i in 1 .. l_lov(gco_lov_display_col).count loop
        l_tmp_optgroup := nvl(l_lov(gco_lov_group_col)(i), l_null_optgroup);

        if not optgroup_exists(laa_optgroups, l_tmp_optgroup) then
          htp.p('<optgroup label="' || l_tmp_optgroup || '">');
          for j in 1 .. l_lov(gco_lov_display_col).count loop
            if nvl(l_lov(gco_lov_group_col)(j), l_null_optgroup) = l_tmp_optgroup then
              apex_plugin_util.print_option(
                p_display_value => l_lov(gco_lov_display_col)(j),
                p_return_value => l_lov(gco_lov_return_col)(j),
                p_is_selected => is_selected_value(l_lov(gco_lov_return_col)(j), p_value),
                p_attributes => p_item.element_option_attributes,
                p_escape => p_item.escape_output
              );
            end if;
          end loop;
          htp.p('</optgroup>');

          laa_optgroups(i) := l_tmp_optgroup;
        end if;
      end loop;
    else
      if (l_drag_and_drop_sorting is not null and p_value is not null) then
        for i in 1 .. l_lov(gco_lov_display_col).count loop
          if not is_selected_value(l_lov(gco_lov_return_col)(i), p_value) then
            apex_plugin_util.print_option(
              p_display_value => l_lov(gco_lov_display_col)(i),
              p_return_value => l_lov(gco_lov_return_col)(i),
              p_is_selected => false,
              p_attributes => p_item.element_option_attributes,
              p_escape => p_item.escape_output
            );
          end if;
        end loop;
      else
        for i in 1 .. l_lov(gco_lov_display_col).count loop
          apex_plugin_util.print_option(
            p_display_value => l_lov(gco_lov_display_col)(i),
            p_return_value => l_lov(gco_lov_return_col)(i),
            p_is_selected => is_selected_value(l_lov(gco_lov_return_col)(i), p_value),
            p_attributes => p_item.element_option_attributes,
            p_escape => p_item.escape_output
          );
        end loop;
      end if;
    end if;
  end if;

  if (p_value is not null and (l_select_list_type = 'TAG' or p_item.lov_display_extra)) then
    if not (l_lazy_loading is not null or l_drag_and_drop_sorting is not null) then
      l_selected_values := apex_util.string_to_table(p_value);

      for i in 1 .. l_selected_values.count loop
        begin
          l_display_value := apex_plugin_util.get_display_data(
                               p_sql_statement => p_item.lov_definition,
                               p_min_columns => gco_min_lov_cols,
                               p_max_columns => gco_max_lov_cols,
                               p_component_name => p_item.name,
                               p_display_column_no => gco_lov_display_col,
                               p_search_column_no => gco_lov_return_col,
                               p_search_string => l_selected_values(i),
                               p_display_extra => false
                             );
        exception
          when no_data_found then
            l_display_value := null;
        end;

        if l_display_value is null then
          apex_plugin_util.print_option(
            p_display_value => l_selected_values(i),
            p_return_value => l_selected_values(i),
            p_is_selected => true,
            p_attributes => p_item.element_option_attributes,
            p_escape => p_item.escape_output
          );
        end if;
      end loop;
    end if;
  end if;
end print_lov_options;


function select2_render(
           p_item in apex_plugin.t_page_item,
           p_plugin in apex_plugin.t_plugin,
           p_value in gt_string,
           p_is_readonly in boolean,
           p_is_printer_friendly in boolean
         ) return apex_plugin.t_page_item_render_result is
  l_no_matches_msg gt_string := p_plugin.attribute_01;
  l_input_too_short_msg gt_string := p_plugin.attribute_02;
  l_selection_too_big_msg gt_string := p_plugin.attribute_03;
  l_searching_msg gt_string := p_plugin.attribute_04;
  l_null_optgroup_label_app gt_string := p_plugin.attribute_05;
  l_loading_more_results_msg gt_string := p_plugin.attribute_06;
  l_look_and_feel gt_string := p_plugin.attribute_07;
  l_error_loading_msg gt_string := p_plugin.attribute_08;
  l_input_too_long_msg gt_string := p_plugin.attribute_09;
  l_custom_css_path gt_string := p_plugin.attribute_10;
  l_custom_css_filename gt_string := p_plugin.attribute_11;

  l_select_list_type gt_string := p_item.attribute_01;
  l_min_results_for_search gt_string := p_item.attribute_02;
  l_min_input_length gt_string := p_item.attribute_03;
  l_max_input_length gt_string := p_item.attribute_04;
  l_max_selection_size gt_string := p_item.attribute_05;
  l_rapid_selection gt_string := p_item.attribute_06;
  l_select_on_blur gt_string := p_item.attribute_07;
  l_search_logic gt_string := p_item.attribute_08;
  l_null_optgroup_label_cmp gt_string := p_item.attribute_09;
  l_width gt_string := p_item.attribute_10;
  l_drag_and_drop_sorting gt_string := p_item.attribute_11;
  l_token_separators gt_string := p_item.attribute_12;
  l_extra_options gt_string := p_item.attribute_13;
  l_lazy_loading gt_string := p_item.attribute_14;
  l_lazy_append_row_count gt_string := p_item.attribute_15;

  l_display_values apex_application_global.vc_arr2;
  l_multiselect gt_string;

  l_item_jq gt_string := apex_plugin_util.page_item_names_to_jquery(p_item.name);
  l_cascade_parent_items_jq gt_string := apex_plugin_util.page_item_names_to_jquery(p_item.lov_cascade_parent_items);
  l_cascade_items_to_submit_jq gt_string := apex_plugin_util.page_item_names_to_jquery(p_item.ajax_items_to_submit);
  l_items_for_session_state_jq gt_string;
  l_cascade_parent_items apex_application_global.vc_arr2;
  l_optimize_refresh_condition gt_string;

  l_apex_version gt_string;
  l_onload_code gt_string;
  l_render_result apex_plugin.t_page_item_render_result;

  -- local subprograms
  function get_select2_constructor
  return gt_string is
    l_selected_values apex_application_global.vc_arr2;
    l_display_values apex_application_global.vc_arr2;
    l_json gt_string;
    l_code gt_string;

    l_allow_clear_bool boolean;
    l_rapid_selection_bool boolean;
    l_select_on_blur_bool boolean;
  begin
    if p_item.lov_display_null then
      l_allow_clear_bool := true;
    else
      l_allow_clear_bool := false;
    end if;

    if l_rapid_selection is null then
      l_rapid_selection_bool := true;
    else
      l_rapid_selection_bool := false;
    end if;

    if l_select_on_blur is null then
      l_select_on_blur_bool := false;
    else
      l_select_on_blur_bool := true;
    end if;

    -- make sure the last character of l_extra_options is a comma
    if trim(l_extra_options) is not null then
      if substr(trim(l_extra_options), -1, 1) != ',' then
        l_extra_options := l_extra_options || ',';
      end if;
    end if;

    l_code := '
      $("' || l_item_jq || '").select2({' ||
        apex_javascript.add_attribute('placeholder', p_item.lov_null_text, false) ||
        apex_javascript.add_attribute('allowClear', l_allow_clear_bool) ||
        apex_javascript.add_attribute('minimumInputLength', to_number(l_min_input_length)) ||
        apex_javascript.add_attribute('maximumInputLength', to_number(l_max_input_length)) ||
        apex_javascript.add_attribute('minimumResultsForSearch', to_number(l_min_results_for_search)) ||
        apex_javascript.add_attribute('maximumSelectionLength', to_number(l_max_selection_size)) ||
        apex_javascript.add_attribute('closeOnSelect', l_rapid_selection_bool) ||
        apex_javascript.add_attribute('selectOnClose', l_select_on_blur_bool) ||
        apex_javascript.add_attribute('tokenSeparators', l_token_separators) ||
        l_extra_options;

    if l_look_and_feel = 'SELECT2_CLASSIC' then
      l_code := l_code || apex_javascript.add_attribute('theme', 'classic');
    end if;

    l_code := l_code || '"language": {';

    if l_error_loading_msg is not null then
      l_code := l_code || '
        "errorLoading": function() {
                          return "' || l_error_loading_msg || '";
                        },';
    end if;
    if l_input_too_long_msg is not null then
      l_code := l_code || '
        "inputTooLong": function(args) {
                          var msg = "' || l_input_too_long_msg || '";
                          msg = msg.replace("#TERM#", args.input);
                          msg = msg.replace("#MAXLENGTH#", args.maximum);
                          msg = msg.replace("#OVERCHARS#", args.input.length - args.maximum);
                          return msg;
                        },';
    end if;
    if l_input_too_short_msg is not null then
      l_code := l_code || '
        "inputTooShort": function(args) {
                           var msg = "' || l_input_too_short_msg || '";
                           msg = msg.replace("#TERM#", args.input);
                           msg = msg.replace("#MINLENGTH#", args.minimum);
                           msg = msg.replace("#REMAININGCHARS#", args.minimum - args.input.length);
                           return msg;
                         },';
    end if;
    if l_loading_more_results_msg is not null then
      l_code := l_code || '
        "loadingMore": function() {
                         return "' || l_loading_more_results_msg || '";
                       },';
    end if;
    if l_selection_too_big_msg is not null then
      l_code := l_code || '
        "maximumSelected": function(args) {
                             var msg = "' || l_selection_too_big_msg || '";
                             msg = msg.replace("#MAXSIZE#", args.maximum);
                             return msg;
                           },';
    end if;
    if l_no_matches_msg is not null then
      l_code := l_code || '
        "noResults": function() {
                       return "' || l_no_matches_msg || '";
                     },';
    end if;
    if l_searching_msg is not null then
      l_code := l_code || '
        "searching": function() {
                       return "' || l_searching_msg || '";
                     },';
    end if;

    l_code := rtrim(l_code, ',') || '},';

    if l_search_logic != gco_contains_ignore_case then
      case l_search_logic
        when gco_contains_ignore_case_diac then l_search_logic := 'return text.toUpperCase().indexOf(term.toUpperCase()) >= 0;';
        when gco_contains_case_sensitive then l_search_logic := 'return text.indexOf(term) >= 0;';
        when gco_exact_ignore_case then l_search_logic := 'return text.toUpperCase() === term.toUpperCase() || term.length === 0;';
        when gco_exact_case_sensitive then l_search_logic := 'return text === term || term.length === 0;';
        when gco_starts_with_ignore_case then l_search_logic := 'return text.toUpperCase().indexOf(term.toUpperCase()) === 0;';
        when gco_starts_with_case_sensitive then l_search_logic := 'return text.indexOf(term) === 0;';
        when gco_multi_word then l_search_logic := '
          var escpTerm = term.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");
          return new RegExp(escpTerm.replace(/ /g, ".*"), "i").test(text);';
        else l_search_logic := 'return text.toUpperCase().indexOf(term.toUpperCase()) >= 0;';
      end case;

      l_code := '$.fn.select2.amd.require([''select2/compat/matcher''], function(oldMatcher) {' ||
        l_code || '
        matcher: oldMatcher(
                   function(term, text) {
                     ' || l_search_logic || '
                   }
                 ),';
    end if;

    if l_lazy_loading is not null then
      l_code := l_code || '
        ajax: {
          url: "wwv_flow.show",
          type: "POST",
          dataType: "json",
          delay: 400,
          data: function(params) {
                  return {
                    p_flow_id: $("#pFlowId").val(),
                    p_flow_step_id: $("#pFlowStepId").val(),
                    p_instance: $("#pInstance").val(),
                    x01: params.term,
                    x02: params.page,
                    x03: "LAZY_LOAD",
                    p_request: "PLUGIN=' || apex_plugin.get_ajax_identifier || '"
                  };
                },
          processResults: function(data, params) {
                            var select2Data = $.map(data.row, function(obj) {
                              obj.id = obj.R;
                              obj.text = obj.D;
                              return obj;
                            });

                            return {
                              results: select2Data,
                              pagination: { more: data.more }
                            };
                          },
          cache: true
        },
        escapeMarkup: function(markup) { return markup; },';
    end if;

    if l_select_list_type = 'TAG' then
      l_code := l_code || apex_javascript.add_attribute('tags', true);
    end if;

    l_code := l_code || apex_javascript.add_attribute('width', nvl(l_width, 'element'), true, false);
    l_code := l_code || '})';

    if l_search_logic != gco_contains_ignore_case then
      l_code := l_code || '});';
    else
      l_code := l_code || ';';
    end if;

    -- issue #71: fix focus after selection for single-value items
    if l_select_list_type = 'SINGLE' then
      l_code := l_code || '
        $("' || l_item_jq || '").on(
          "select2:select",
          function(){ $(this).focus(); }
        );';
    end if;

    return l_code;
  end get_select2_constructor;


  function get_sortable_constructor
  return gt_string is
    l_code gt_string;
  begin
    l_code := '
      var s2item = $("' || l_item_jq || '");
      var s2ul = s2item.next(".select2-container").find("ul.select2-selection__rendered");
      s2ul.sortable({
        containment: "parent",
        items: "li:not(.select2-search)",
        tolerance: "pointer",
        stop: function() {
          $(s2ul.find(".select2-selection__choice").get().reverse()).each(function() {
            s2item.prepend(s2item.find(''option[value="'' + $(this).data("data").id + ''"]'')[0]);
          });
        }
      });';

      /* prevent automatic tags sorting
         http://stackoverflow.com/questions/31431197/select2-how-to-prevent-tags-sorting
      s2item.on("select2:select", function(e) {
        var $element = $(e.params.data.element);

        $element.detach();
        $(this).append($element);
        $(this).trigger("change");
      });';
      */

    return l_code;
  end get_sortable_constructor;
begin
  if apex_application.g_debug then
    apex_plugin_util.debug_page_item(p_plugin, p_item, p_value, p_is_readonly, p_is_printer_friendly);
  end if;

  if (p_is_readonly or p_is_printer_friendly) then
    apex_plugin_util.print_hidden_if_readonly(p_item.name, p_value, p_is_readonly, p_is_printer_friendly);

    begin
      l_display_values := apex_plugin_util.get_display_data(
                            p_sql_statement => p_item.lov_definition,
                            p_min_columns => gco_min_lov_cols,
                            p_max_columns => gco_max_lov_cols,
                            p_component_name => p_item.name,
                            p_search_value_list => apex_util.string_to_table(p_value),
                            p_display_extra => p_item.lov_display_extra
                          );
    exception
      when no_data_found then
        null; -- https://github.com/nbuytaert1/apex-select2/issues/51
    end;

    if l_display_values.count = 1 then
      apex_plugin_util.print_display_only(
        p_item_name => p_item.name,
        p_display_value => l_display_values(1),
        p_show_line_breaks => false,
        p_escape => p_item.escape_output,
        p_attributes => p_item.element_attributes
      );
    elsif l_display_values.count > 1 then
      htp.p('
        <ul id="' || p_item.name || '_DISPLAY"
          class="display_only ' || p_item.element_css_classes || '"' ||
          p_item.element_attributes || '>');

      for i in 1 .. l_display_values.count loop
        if p_item.escape_output then
          htp.p('<li>' || htf.escape_sc(l_display_values(i)) || '</li>');
        else
          htp.p('<li>' || l_display_values(i) || '</li>');
        end if;
      end loop;

      htp.p('</ul>');
    end if;

    return l_render_result;
  end if;

  apex_javascript.add_library(
    p_name => 'select2.full.min',
    p_directory => p_plugin.file_prefix,
    p_version => null
  );
  apex_javascript.add_library(
    p_name => 'select2-apex',
    p_directory => p_plugin.file_prefix,
    p_version => null
  );
  apex_css.add_file(
    p_name => 'select2.min',
    p_directory => p_plugin.file_prefix,
    p_version => null
  );
  if l_look_and_feel = 'SELECT2_CLASSIC' then
    apex_css.add_file(
      p_name => 'select2-classic',
      p_directory => p_plugin.file_prefix,
      p_version => null
    );
  elsif l_look_and_feel = 'CUSTOM' then
    apex_css.add_file(
      p_name => apex_plugin_util.replace_substitutions(l_custom_css_filename),
      p_directory => apex_plugin_util.replace_substitutions(l_custom_css_path),
      p_version => null
    );
  end if;

  if l_select_list_type in ('MULTI', 'TAG') then
    l_multiselect := 'multiple="multiple"';
  end if;

  htp.p('
    <select ' || l_multiselect || '
      id="' || p_item.name || '"
      name="' || apex_plugin.get_input_name_for_page_item(true) || '"
      class="selectlist ' || p_item.element_css_classes || '"' ||
      p_item.element_attributes || '>');

  if (l_select_list_type = 'SINGLE' and p_item.lov_display_null) then
    apex_plugin_util.print_option(
      p_display_value => p_item.lov_null_text,
      p_return_value => p_item.lov_null_value,
      p_is_selected => false,
      p_attributes => p_item.element_option_attributes,
      p_escape => p_item.escape_output
    );
  end if;

  print_lov_options(p_item, p_plugin, p_value);

  htp.p('</select>');

  l_onload_code := get_select2_constructor;

  if l_drag_and_drop_sorting is not null then
    select substr(version_no, 1, 3)
    into l_apex_version
    from apex_release;

    if l_apex_version = '4.2' then
      apex_javascript.add_library(
        p_name => 'jquery.ui.sortable.min',
        p_directory => '#JQUERYUI_DIRECTORY#ui/minified/',
        p_version => null
      );
    else
      apex_javascript.add_library(
        p_name => 'jquery.ui.sortable.min',
        p_directory => '#IMAGE_PREFIX#libraries/jquery-ui/1.10.4/ui/minified/',
        p_version => null
      );
    end if;

    l_onload_code := l_onload_code || get_sortable_constructor();
  end if;

  if p_item.lov_cascade_parent_items is not null then
    l_items_for_session_state_jq := l_cascade_parent_items_jq;

    if l_cascade_items_to_submit_jq is not null then
      l_items_for_session_state_jq := l_items_for_session_state_jq || ',' || l_cascade_items_to_submit_jq;
    end if;

    l_onload_code := l_onload_code || '
      $("' || l_cascade_parent_items_jq || '").on("change", function(e) {';

    if p_item.ajax_optimize_refresh then
      l_cascade_parent_items := apex_util.string_to_table(l_cascade_parent_items_jq, ',');

      l_optimize_refresh_condition := '$("' || l_cascade_parent_items(1) || '").val() === ""';

      for i in 2 .. l_cascade_parent_items.count loop
        l_optimize_refresh_condition := l_optimize_refresh_condition || ' || $("' || l_cascade_parent_items(i) || '").val() === ""';
      end loop;

      l_onload_code := l_onload_code || '
        var item = $("' || l_item_jq || '");
        if (' || l_optimize_refresh_condition || ') {
          item.val("").trigger("change");
        } else {';
    end if;

    l_onload_code := l_onload_code || '
          apex.server.plugin(
            "' || apex_plugin.get_ajax_identifier || '",
            { pageItems: "' || l_items_for_session_state_jq || '" },
            { refreshObject: "' || l_item_jq || '",
              loadingIndicator: "' || l_item_jq || '",
              loadingIndicatorPosition: "after",
              dataType: "text",
              success: function(pData) {
                         var item = $("' || l_item_jq || '");
                         item.html(pData);
                         item.val("").trigger("change");
                       }
            });';

    if p_item.ajax_optimize_refresh then
      l_onload_code := l_onload_code || '}';
    end if;

    l_onload_code := l_onload_code || '});';
  end if;

  l_onload_code := l_onload_code || '
      beCtbSelect2.events.bind("' || l_item_jq || '");';

  apex_javascript.add_onload_code(l_onload_code);
  l_render_result.is_navigable := true;
  return l_render_result;
end select2_render;


function select2_ajax(
           p_item in apex_plugin.t_page_item,
           p_plugin in apex_plugin.t_plugin
         ) return apex_plugin.t_page_item_ajax_result is
  l_select_list_type gt_string := p_item.attribute_01;
  l_search_logic gt_string := p_item.attribute_08;
  l_lazy_append_row_count gt_string := p_item.attribute_15;

  l_lov apex_plugin_util.t_column_value_list;
  l_json gt_string;
  l_apex_plugin_search_logic gt_string;
  l_search_string gt_string;
  l_search_page number;
  l_first_row number;
  l_loop_count number;
  l_more_rows_boolean boolean;

  l_result apex_plugin.t_page_item_ajax_result;
begin
  if apex_application.g_x03 = 'LAZY_LOAD' then
    l_search_string := nvl(apex_application.g_x01, '%');
    l_search_page := nvl(apex_application.g_x02, 1);
    l_first_row := ((l_search_page - 1) * nvl(l_lazy_append_row_count, 0)) + 1;

    -- translate Select2 search logic into APEX_PLUGIN_UTIL search logic
    -- the percentage wildcard returns all rows whenever the search string is null
    case l_search_logic
      when gco_contains_case_sensitive then
        l_apex_plugin_search_logic := apex_plugin_util.c_search_like_case; -- uses LIKE %value%
      when gco_exact_ignore_case then
        l_apex_plugin_search_logic := apex_plugin_util.c_search_exact_ignore; -- uses LIKE VALUE% with UPPER (not completely correct)
      when gco_exact_case_sensitive then
        l_apex_plugin_search_logic := apex_plugin_util.c_search_lookup; -- uses = value
      when gco_starts_with_ignore_case then
        l_apex_plugin_search_logic := apex_plugin_util.c_search_exact_ignore; -- uses LIKE VALUE% with UPPER
      when gco_starts_with_case_sensitive then
        l_apex_plugin_search_logic := apex_plugin_util.c_search_exact_case; -- uses LIKE value%
      else
        l_apex_plugin_search_logic := apex_plugin_util.c_search_like_ignore; -- uses LIKE %VALUE% with UPPER
    end case;

    if l_search_logic = gco_multi_word then
      l_search_string := replace(l_search_string, ' ', '%');
    end if;

    l_lov := apex_plugin_util.get_data(
               p_sql_statement => p_item.lov_definition,
               p_min_columns => gco_min_lov_cols,
               p_max_columns => gco_max_lov_cols,
               p_component_name => p_item.name,
               p_search_type => l_apex_plugin_search_logic,
               p_search_column_no => gco_lov_display_col,
               p_search_string => apex_plugin_util.get_search_string(
                                    p_search_type => l_apex_plugin_search_logic,
                                    p_search_string => l_search_string
                                  ),
               p_first_row => l_first_row,
               p_max_rows => l_lazy_append_row_count + 1
             );

    if l_lov(gco_lov_return_col).count = l_lazy_append_row_count + 1 then
      l_loop_count := l_lov(gco_lov_return_col).count - 1;
    else
      l_loop_count := l_lov(gco_lov_return_col).count;
    end if;

    l_json := '{"row":[';

    if p_item.escape_output then
      for i in 1 .. l_loop_count loop
        l_json := l_json || '{' ||
          apex_javascript.add_attribute('R', htf.escape_sc(l_lov(gco_lov_return_col)(i)), false, true) ||
          apex_javascript.add_attribute('D', htf.escape_sc(l_lov(gco_lov_display_col)(i)), false, false) ||
        '},';
      end loop;
    else
      for i in 1 .. l_loop_count loop
        l_json := l_json || '{' ||
          apex_javascript.add_attribute('R', l_lov(gco_lov_return_col)(i), false, true) ||
          apex_javascript.add_attribute('D', l_lov(gco_lov_display_col)(i), false, false) ||
        '},';
      end loop;
    end if;

    l_json := rtrim(l_json, ',');

    if l_lov(gco_lov_return_col).exists(l_lazy_append_row_count + 1) then
      l_more_rows_boolean := true;
    else
      l_more_rows_boolean := false;
    end if;

    l_json := l_json || '],' || apex_javascript.add_attribute('more', l_more_rows_boolean, true, false) || '}';

    htp.p(l_json);
  else
    print_lov_options(p_item, p_plugin);
  end if;

  return l_result;
end select2_ajax;




-- ========================================
--  Simple Checkbox
-- ========================================
/**
 *
 * Renders the Simple Checkbox item type based on the configuration of the page item.
 *
 * @param p_item
 * @param p_plugin
 * @param p_value
 * @param p_is_readonly
 * @param p_is_printer_friendly
 *
 */
function render_simple_checkbox (
    p_item                in apex_plugin.t_page_item,
    p_plugin              in apex_plugin.t_plugin,
    p_value               in varchar2,
    p_is_readonly         in boolean,
    p_is_printer_friendly in boolean )
    return apex_plugin.t_page_item_render_result
is
    -- Use named variables instead of the generic attribute variables
    l_checked_value    varchar2(255)  := nvl(p_item.attribute_01, 'Y');
    l_unchecked_value  varchar2(255)  := p_item.attribute_02;
    l_checked_label    varchar2(4000) := p_item.attribute_03;

    l_name             varchar2(30);
    l_value            varchar2(255);
    l_checkbox_postfix varchar2(8);
    l_result           apex_plugin.t_page_item_render_result;
begin
    -- if the current value doesn't match our checked and unchecked value
    -- we fallback to the unchecked value 
    if p_value in (l_checked_value, l_unchecked_value) then
        l_value := p_value;
    else
        l_value := l_unchecked_value;
    end if;

    if p_is_readonly or p_is_printer_friendly then
        -- if the checkbox is readonly we will still render a hidden field with
        -- the value so that it can be used when the page gets submitted
        wwv_flow_plugin_util.print_hidden_if_readonly (
            p_item_name           => p_item.name,
            p_value               => p_value,
            p_is_readonly         => p_is_readonly,
            p_is_printer_friendly => p_is_printer_friendly );
        l_checkbox_postfix := '_DISPLAY';

        -- Tell APEX that this field is NOT navigable
        l_result.is_navigable := false;
    else
        -- If a page item saves state, we have to call the get_input_name_for_page_item
        -- to render the internal hidden p_arg_names field. It will also return the
        -- HTML field name which we have to use when we render the HTML input field.
        l_name := wwv_flow_plugin.get_input_name_for_page_item(false);

        -- render the hidden field which actually stores the checkbox value
        sys.htp.prn (
            '<input type="hidden" id="'||p_item.name||'_HIDDEN" name="'||l_name||'" '||
            'value="'||l_value||'" />');

        -- Add the JavaScript library and the call to initialize the widget
        apex_javascript.add_library (
            p_name      => 'com_oracle_apex_simple_checkbox.min',
            p_directory => p_plugin.file_prefix,
            p_version   => null );

        apex_javascript.add_onload_code (
            p_code => 'com_oracle_apex_simple_checkbox('||
                      apex_javascript.add_value(p_item.name)||
                      '{'||
                      apex_javascript.add_attribute('unchecked', l_unchecked_value, false)||
                      apex_javascript.add_attribute('checked',   l_checked_value, false, false)||
                      '});' );

        -- Tell APEX that this field is navigable
        l_result.is_navigable := true;
    end if;


    -- render the checkbox widget
    -- fieldset added for UT look and feel
    -- Added apex-item-group--rc for 19.1
    sys.htp.prn('<fieldset tabindex="-1" id="'||p_item.name||'_FIELDSET" class="checkbox_group apex-item-checkbox apex-item-group--rc">');
    sys.htp.prn (
        '<input type="checkbox" id="'||p_item.name||l_checkbox_postfix||'" '||
        'value="'||l_value||'" '||
        case when l_value = l_checked_value then 'checked="checked" ' end||
        -- case when p_is_readonly or p_is_printer_friendly then 'disabled="disabled" ' end||
        -- readonly fixes APEX 5.1 issue, but we should really switch to "Switch" ;-)
        case when p_is_readonly or p_is_printer_friendly then 'readonly="readonly" ' end||
        coalesce(p_item.element_attributes, 'class="simple_checkbox"')||' />');

    -- print label after checkbox
    -- if l_checked_label is not null then
    --   sys.htp.prn('<label for="'||p_item.name||l_checkbox_postfix||'">'||l_checked_label||'</label>');
    -- end if;
    -- for UT, always print the label even when l_checked_label is empty
    sys.htp.prn('<label for="'||p_item.name||l_checkbox_postfix||'">'||l_checked_label||'</label>');
    sys.htp.prn('</fieldset>');

    return l_result;
end render_simple_checkbox;



/**
 *
 * Validates the submitted "Simple Checkbox" value against the configuration to
 * make sure that invalid values submitted by hackers are detected.
 *
 * @param p_item
 * @param p_plugin
 * @param p_value
 *
 */
function validate_simple_checkbox (
    p_item   in apex_plugin.t_page_item,
    p_plugin in apex_plugin.t_plugin,
    p_value  in varchar2
)
return apex_plugin.t_page_item_validation_result
is
    l_checked_value   varchar2(255) := nvl(p_item.attribute_01, 'Y');
    l_unchecked_value varchar2(255) := p_item.attribute_02;

    l_result          apex_plugin.t_page_item_validation_result;
begin
    if not (   p_value in (l_checked_value, l_unchecked_value)
            or (p_value is null and l_unchecked_value is null)
           )
    then
        l_result.message := 'Checkbox contains invalid value!';
    end if;
    return l_result;
end validate_simple_checkbox;



-- ========================================
--  Spotlight Search
-- ========================================
/*-------------------------------------
 * APEX Spotlight Search
 * Version: 1.6.1
 * Author:  Daniel Hochleitner
 *-------------------------------------
*/

--
-- Plug-in Render Function
-- #param p_dynamic_action
-- #param p_plugin
-- #return apex_plugin.t_dynamic_action_render_result
FUNCTION render_apexspotlight(p_dynamic_action IN apex_plugin.t_dynamic_action,
                              p_plugin         IN apex_plugin.t_plugin)
  RETURN apex_plugin.t_dynamic_action_render_result IS
  --
  l_result apex_plugin.t_dynamic_action_render_result;
  --
  -- plugin attributes
  l_placeholder_text           p_plugin.attribute_01%TYPE := nvl(p_dynamic_action.attribute_12,
                                                                 p_plugin.attribute_01);
  l_more_chars_text            p_plugin.attribute_02%TYPE := p_plugin.attribute_02;
  l_no_match_text              p_plugin.attribute_03%TYPE := p_plugin.attribute_03;
  l_one_match_text             p_plugin.attribute_04%TYPE := p_plugin.attribute_04;
  l_multiple_matches_text      p_plugin.attribute_05%TYPE := p_plugin.attribute_05;
  l_inpage_search_text         p_plugin.attribute_06%TYPE := p_plugin.attribute_06;
  l_search_history_delete_text p_plugin.attribute_07%TYPE := p_plugin.attribute_07;
  --
  l_enable_keyboard_shortcuts    VARCHAR2(5) := nvl(p_dynamic_action.attribute_01,
                                                    'N');
  l_keyboard_shortcuts           p_dynamic_action.attribute_02%TYPE := p_dynamic_action.attribute_02;
  l_submit_items                 p_dynamic_action.attribute_04%TYPE := p_dynamic_action.attribute_04;
  l_enable_inpage_search         VARCHAR2(5) := nvl(p_dynamic_action.attribute_05,
                                                    'Y');
  l_max_display_results          NUMBER := to_number(p_dynamic_action.attribute_06);
  l_width                        p_dynamic_action.attribute_07%TYPE := p_dynamic_action.attribute_07;
  l_enable_data_cache            VARCHAR2(5) := nvl(p_dynamic_action.attribute_08,
                                                    'N');
  l_theme                        p_dynamic_action.attribute_09%TYPE := nvl(p_dynamic_action.attribute_09,
                                                                           'STANDARD');
  l_enable_prefill_selected_text VARCHAR2(5) := nvl(p_dynamic_action.attribute_10,
                                                    'N');
  l_show_processing              VARCHAR2(5) := nvl(p_dynamic_action.attribute_11,
                                                    'N');
  l_placeholder_icon             p_dynamic_action.attribute_13%TYPE := nvl(p_dynamic_action.attribute_13,
                                                                           'DEFAULT');
  l_escape_special_chars         VARCHAR2(5) := nvl(p_dynamic_action.attribute_14,
                                                    'Y');
  l_enable_search_history        VARCHAR2(5) := nvl(p_dynamic_action.attribute_15,
                                                    'N');
  --
  l_component_config_json CLOB := empty_clob();
  --
  -- Get DA internal event name
  FUNCTION get_da_event_name(p_action_id IN NUMBER) RETURN VARCHAR2 IS
    --
    l_da_event_name apex_application_page_da.when_event_internal_name%TYPE;
    --
    CURSOR l_cur_da_event IS
      SELECT aapd.when_event_internal_name
        FROM apex_application_page_da      aapd,
             apex_application_page_da_acts aapda
       WHERE aapd.dynamic_action_id = aapda.dynamic_action_id
         AND aapd.application_id = (SELECT nv('APP_ID')
                                      FROM dual)
         AND aapda.action_id = p_action_id;
    --
  BEGIN
    --
    OPEN l_cur_da_event;
    FETCH l_cur_da_event
      INTO l_da_event_name;
    CLOSE l_cur_da_event;
    --
    RETURN nvl(l_da_event_name,
               'ready');
    --
  END get_da_event_name;
  --
  -- Get DA Fire on Initialization property
  FUNCTION get_da_fire_on_init(p_action_id IN NUMBER) RETURN VARCHAR2 IS
    --
    l_da_fire_on_init apex_application_page_da_acts.execute_on_page_init%TYPE;
    --
    CURSOR l_cur_da_fire_on_init IS
      SELECT decode(aapda.execute_on_page_init,
                    'Yes',
                    'Y',
                    'No',
                    'N') AS execute_on_page_init
        FROM apex_application_page_da_acts aapda
       WHERE aapda.application_id = (SELECT nv('APP_ID')
                                       FROM dual)
         AND aapda.action_id = p_action_id;
    --
  BEGIN
    --
    OPEN l_cur_da_fire_on_init;
    FETCH l_cur_da_fire_on_init
      INTO l_da_fire_on_init;
    CLOSE l_cur_da_fire_on_init;
    --
    RETURN nvl(l_da_fire_on_init,
               'N');
    --
  END get_da_fire_on_init;
  --
BEGIN
  -- Debug
  IF apex_application.g_debug THEN
    apex_plugin_util.debug_dynamic_action(p_plugin         => p_plugin,
                                          p_dynamic_action => p_dynamic_action);
  END IF;
  --
  -- add mousetrap.js & mark.js libs & tippy libs
  IF l_enable_keyboard_shortcuts = 'Y' THEN
    apex_javascript.add_library(p_name                  => 'mousetrap',
                                p_directory             => p_plugin.file_prefix || 'js/',
                                p_version               => NULL,
                                p_skip_extension        => FALSE,
                                p_check_to_add_minified => TRUE);
  END IF;
  --
  IF l_enable_inpage_search = 'Y' THEN
    apex_javascript.add_library(p_name                  => 'jquery.mark',
                                p_directory             => p_plugin.file_prefix || 'js/',
                                p_version               => NULL,
                                p_skip_extension        => FALSE,
                                p_check_to_add_minified => TRUE);
  END IF;
  --
  IF l_enable_search_history = 'Y' THEN
    apex_javascript.add_library(p_name                  => 'tippy.all',
                                p_directory             => p_plugin.file_prefix || 'js/',
                                p_version               => NULL,
                                p_skip_extension        => FALSE,
                                p_check_to_add_minified => TRUE);
  END IF;
  -- escape input
  IF l_escape_special_chars = 'Y' THEN
    l_placeholder_text           := apex_escape.html(l_placeholder_text);
    l_more_chars_text            := apex_escape.html(l_more_chars_text);
    l_no_match_text              := apex_escape.html(l_no_match_text);
    l_one_match_text             := apex_escape.html(l_one_match_text);
    l_multiple_matches_text      := apex_escape.html(l_multiple_matches_text);
    l_inpage_search_text         := apex_escape.html(l_inpage_search_text);
    l_search_history_delete_text := apex_escape.html(l_search_history_delete_text);
    l_placeholder_icon           := apex_escape.html(l_placeholder_icon);
  END IF;
  -- build component config json
  apex_json.initialize_clob_output;
  apex_json.open_object();
  -- general
  apex_json.write('dynamicActionId',
                  p_dynamic_action.id);
  apex_json.write('ajaxIdentifier',
                  apex_plugin.get_ajax_identifier);
  apex_json.write('eventName',
                  get_da_event_name(p_action_id => p_dynamic_action.id));
  apex_json.write('fireOnInit',
                  get_da_fire_on_init(p_action_id => p_dynamic_action.id));
  -- app wide attributes
  apex_json.write('placeholderText',
                  l_placeholder_text);
  apex_json.write('moreCharsText',
                  l_more_chars_text);
  apex_json.write('noMatchText',
                  l_no_match_text);
  apex_json.write('oneMatchText',
                  l_one_match_text);
  apex_json.write('multipleMatchesText',
                  l_multiple_matches_text);
  apex_json.write('inPageSearchText',
                  l_inpage_search_text);
  apex_json.write('searchHistoryDeleteText',
                  l_search_history_delete_text);
  -- component attributes
  apex_json.write('enableKeyboardShortcuts',
                  l_enable_keyboard_shortcuts);
  apex_json.write('keyboardShortcuts',
                  l_keyboard_shortcuts);
  apex_json.write('submitItems',
                  l_submit_items);
  apex_json.write('enableInPageSearch',
                  l_enable_inpage_search);
  apex_json.write('maxNavResult',
                  l_max_display_results);
  apex_json.write('width',
                  l_width);
  apex_json.write('enableDataCache',
                  l_enable_data_cache);
  apex_json.write('spotlightTheme',
                  l_theme);
  apex_json.write('enablePrefillSelectedText',
                  l_enable_prefill_selected_text);
  apex_json.write('showProcessing',
                  l_show_processing);
  apex_json.write('placeHolderIcon',
                  l_placeholder_icon);
  apex_json.write('enableSearchHistory',
                  l_enable_search_history);
  apex_json.close_object();
  --
  l_component_config_json := apex_json.get_clob_output;
  apex_json.free_output;
  -- init keyboard shortcut
  IF l_enable_keyboard_shortcuts = 'Y' THEN
    apex_javascript.add_inline_code(p_code => 'function apexSpotlightInitKeyboardShortcuts' || p_dynamic_action.id ||
                                              '() { apex.da.apexSpotlight.initKeyboardShortcuts(' ||
                                              l_component_config_json || '); }');
    apex_javascript.add_onload_code(p_code => 'apexSpotlightInitKeyboardShortcuts' || p_dynamic_action.id || '();');
  END IF;
  -- DA javascript function
  l_result.javascript_function := 'function() { apex.da.apexSpotlight.pluginHandler(' || l_component_config_json ||
                                  '); }';
  --
  RETURN l_result;
  --
END render_apexspotlight;
--
-- Plug-in AJAX Function
-- #param p_dynamic_action
-- #param p_plugin
-- #return apex_plugin.t_dynamic_action_ajax_result
FUNCTION ajax_apexspotlight(p_dynamic_action IN apex_plugin.t_dynamic_action,
                            p_plugin         IN apex_plugin.t_plugin) RETURN apex_plugin.t_dynamic_action_ajax_result IS
  --
  l_result apex_plugin.t_dynamic_action_ajax_result;
  --
  l_request_type VARCHAR2(50);
  --
  -- Execute Spotlight GET_DATA Request
  PROCEDURE exec_get_data_request(p_dynamic_action IN apex_plugin.t_dynamic_action,
                                  p_plugin         IN apex_plugin.t_plugin) IS
    l_data_source_sql_query p_dynamic_action.attribute_03%TYPE := p_dynamic_action.attribute_03;
    l_escape_special_chars  VARCHAR2(5) := nvl(p_dynamic_action.attribute_14,
                                               'Y');
    l_data_type_list        apex_application_global.vc_arr2;
    l_column_value_list     apex_plugin_util.t_column_value_list2;
    l_row_count             NUMBER;
    l_name                  VARCHAR2(4000);
    l_description           VARCHAR2(4000);
    l_link                  VARCHAR2(4000);
    l_icon                  VARCHAR2(4000);
    l_icon_color            VARCHAR2(4000);
  BEGIN
    -- Data Types of SQL Source Columns
    l_data_type_list(1) := apex_plugin_util.c_data_type_varchar2;
    l_data_type_list(2) := apex_plugin_util.c_data_type_varchar2;
    l_data_type_list(3) := apex_plugin_util.c_data_type_varchar2;
    l_data_type_list(4) := apex_plugin_util.c_data_type_varchar2;
    l_data_type_list(5) := apex_plugin_util.c_data_type_varchar2;
    -- Get Data from SQL Source
    l_column_value_list := apex_plugin_util.get_data2(p_sql_statement  => l_data_source_sql_query,
                                                      p_min_columns    => 4,
                                                      p_max_columns    => 5,
                                                      p_data_type_list => l_data_type_list,
                                                      p_component_name => p_dynamic_action.action);
    -- loop over SQL Source results and write json
    apex_json.open_array();
    --
    l_row_count := l_column_value_list(1).value_list.count;
    --
    FOR i IN 1 .. l_row_count LOOP
      -- escape input
      IF l_escape_special_chars = 'Y' THEN
        l_name        := apex_escape.html(l_column_value_list(1).value_list(i).varchar2_value);
        l_description := apex_escape.html(l_column_value_list(2).value_list(i).varchar2_value);
        l_link        := l_column_value_list(3).value_list(i).varchar2_value;
        l_icon        := apex_escape.html(l_column_value_list(4).value_list(i).varchar2_value);
        IF l_column_value_list.last = 5 THEN
          l_icon_color := apex_escape.html(l_column_value_list(5).value_list(i).varchar2_value);
        END IF;
      ELSE
        l_name        := l_column_value_list(1).value_list(i).varchar2_value;
        l_description := l_column_value_list(2).value_list(i).varchar2_value;
        l_link        := l_column_value_list(3).value_list(i).varchar2_value;
        l_icon        := l_column_value_list(4).value_list(i).varchar2_value;
        IF l_column_value_list.last = 5 THEN
          l_icon_color := l_column_value_list(5).value_list(i).varchar2_value;
        END IF;
      END IF;
      -- write json
      apex_json.open_object;
      -- name / title
      apex_json.write('n',
                      l_name);
      -- description
      apex_json.write('d',
                      l_description);
      -- link / URL
      apex_json.write('u',
                      l_link);
      -- icon
      apex_json.write('i',
                      l_icon);
      -- icon color (optional)
      IF l_column_value_list.last = 5 THEN
        apex_json.write('ic',
                        nvl(l_icon_color,
                            'DEFAULT'));
      END IF;
      -- if URL contains ~SEARCH_VALUE~, make list entry static
      IF instr(l_link,
               '~SEARCH_VALUE~') > 0 THEN
        apex_json.write('s',
                        TRUE);
      ELSE
        apex_json.write('s',
                        FALSE);
      END IF;
      -- type
      apex_json.write('t',
                      'redirect');
      apex_json.close_object;
    END LOOP;
    --
    apex_json.close_array;
  END exec_get_data_request;
  --
  -- Execute Spotlight GET_URL Request
  PROCEDURE exec_get_url_request(p_dynamic_action IN apex_plugin.t_dynamic_action,
                                 p_plugin         IN apex_plugin.t_plugin) IS
    l_search_value VARCHAR2(1000);
    l_url          VARCHAR2(4000);
    l_url_new      VARCHAR2(4000);
  BEGIN
    -- get values from AJAX call X02/X03
    l_search_value := apex_application.g_x02;
    l_url          := apex_application.g_x03;
    -- Check for f?p URL and if URL contains ~SEARCH_VALUE~ substitution string
    IF instr(l_url,
             'f?p=') > 0
       AND instr(l_url,
                 '~SEARCH_VALUE~') > 0 THEN
      -- replace substitution string with real search value
      l_url := REPLACE(l_url,
                       '~SEARCH_VALUE~',
                       l_search_value);
      -- if input URL already contains a checksum > remove checksum
      IF instr(l_url,
               '&cs=') > 0 THEN
        l_url := substr(l_url,
                        1,
                        instr(l_url,
                              '&cs=') - 1);
      END IF;
      -- get SSP URL
      l_url_new := apex_util.prepare_url(p_url => l_url);
      --
      apex_json.open_object;
      apex_json.write('url',
                      l_url_new);
      apex_json.close_object;
      -- if checks don't succeed return input URL back
    ELSE
      apex_json.open_object;
      apex_json.write('url',
                      l_url);
      apex_json.close_object;
    END IF;
  END exec_get_url_request;
  --
BEGIN
  -- Check request type in X01
  l_request_type := apex_application.g_x01;
  -- GET_DATA Request
  IF l_request_type = 'GET_DATA' THEN
    exec_get_data_request(p_dynamic_action => p_dynamic_action,
                          p_plugin         => p_plugin);
    -- GET_URL Request
  ELSIF l_request_type = 'GET_URL' THEN
    exec_get_url_request(p_dynamic_action => p_dynamic_action,
                         p_plugin         => p_plugin);
    --
  END IF;
  --
  RETURN l_result;
  --
END ajax_apexspotlight;


-- ========================================
-- ========================================




end ks_plugins;
/

