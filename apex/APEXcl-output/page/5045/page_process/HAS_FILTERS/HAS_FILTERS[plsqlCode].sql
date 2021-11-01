declare
  l_report    apex_ir.t_report;
  l_page_id   apex_application_page_regions.page_id%type := v('APP_PAGE_ID');
  l_static_id apex_application_page_regions.static_id%type := 'loadMappingsID';
  l_has_filters boolean;
begin

  l_report := ks_util.get_ir_report (p_page_id   => l_page_id, p_static_id => l_static_id);
  l_has_filters := ks_util.ir_has_filters (p_ir_t => l_report);
  
  apex_json.open_object;
  apex_json.write(
      p_name => 'hasFilters'
    , p_value => l_has_filters
  );
  apex_json.close_object;
    
end;