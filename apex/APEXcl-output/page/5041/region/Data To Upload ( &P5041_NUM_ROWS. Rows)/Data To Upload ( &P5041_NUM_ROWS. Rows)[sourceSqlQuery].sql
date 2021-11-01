select 
      external_sys_ref
    , session_num
    , sub_category
    , session_type
    , title
    , presenter
    , company
    , co_presenter
    , co_presenter_company
    , tags
    , event_track_id
    , presenter_email               
    , session_abstract
    , session_summary
    , target_audience               
    , presented_before_ind
    , presented_before_where
    , technology_product        
    , ace_level
    , video_link        
    , contains_demo_ind
    , webinar_willing_ind        
    , presenter_biography
    , co_presenter_user_id
    , presenter_user_id
    , presented_anything_ind
    , presented_anything_where
from ks_full_session_load
   where app_user = :APP_USER
order by external_sys_ref