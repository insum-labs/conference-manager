                   begin
                            for c1 in (select skip_validation
                                      from apex_appl_load_tables
                                      where name = 'Session Load' and application_id = apex_application.g_flow_id )
                            loop
                                if c1.skip_validation = 'Y' then return true;
                                else return false;
                                end if;
                            end loop;
                        end;