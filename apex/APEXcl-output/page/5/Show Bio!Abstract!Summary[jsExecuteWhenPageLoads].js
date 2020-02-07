var show_type = $v('P5_SHOW_TYPE');
switch(show_type) {
    case "SESSION_SUMMARY": show_type = 'Summary';
    break;
    case "SESSION_ABSTRACT": show_type =  'Abstract/For Review Committee';
    break;
    case "PRESENTER_BIOGRAPHY": show_type =  $v('P5_PRESENTER');
    break;
}
apex.util.getTopApex().jQuery(".P5-Page .ui-dialog-content").dialog("option", "title", show_type);
