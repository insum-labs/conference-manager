with region as (
    select  region_id
    from    apex_application_page_regions
    where   application_id = :APP_ID
    and     page_id = 2
    and     static_id = 'sessionsIR'
)
,report as (
    select apex_ir.get_last_viewed_report_id (
            p_page_id => 2
           ,p_region_id => r.region_id
        ) report_id
    from region r 
)
,report_alias as (
    select  rpt.report_alias
    from    apex_application_page_ir_rpt rpt
    join    report r
    on      r.report_id = rpt.report_id
)
select 'IR[sessionsIR]' || nvl2 (ra.report_alias, '_' || ra.report_alias, '')
into   :P10_IR_REQUEST
from   report_alias ra;