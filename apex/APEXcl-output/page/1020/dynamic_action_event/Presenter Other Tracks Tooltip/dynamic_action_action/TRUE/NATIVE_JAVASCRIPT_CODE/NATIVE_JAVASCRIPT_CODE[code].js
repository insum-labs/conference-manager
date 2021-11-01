var el=this.triggeringElement,
    legend="<spand class=\"legend\">Hit ESC to close</span>",
    eventID = &P1020_EVENT_ID.,
    presenter=this.triggeringElement.dataset.presenter,
    presenterUserId=this.triggeringElement.dataset.presenteruserid;


apex.server.process ( "PRESENTER_TRACKS_JSON", 
  {x01:eventID, x02:presenterUserId},
  {
   success: function( pData ) 
   {
    var lDialog$ = apex.jQuery( "#ksTracks" );
    if ( lDialog$.length === 0 ) {

        // add a new div to the page
        apex.jQuery( "#wwvFlowForm" ).after( '<div id="ksTracks" tabindex="0">' + pData[0].trackList + legend + '</div>' );
        lDialog$ = apex.jQuery("#ksTracks");

        // open created div as a dialog
        lDialog$
            .dialog({
            dialogClass: "ksjqTooltip",
            title:         presenter,
            autoResize:    true,
            maxWidth:      500,
            maxHeight:     350,
            position: { my: "left", at: "right center", of: el } }
            )
            .on('keydown', function(evt) {
                if (evt.keyCode === $.ui.keyCode.ESCAPE) {
                    lDialog$.dialog('close');
                }                
                evt.stopPropagation();
            });
    } else {
        // replace the existing dialog and open it again
        lDialog$
            .html( pData[0].trackList + legend )
            .dialog( "option", "title", presenter)
            .dialog({position: { my: "left", at: "right center", of: el } })
            .dialog( "open" );
    }
    lDialog$.focus();
   }
  }
);

this.browserEvent.preventDefault ? this.browserEvent.preventDefault() : (this.browserEvent.returnValue = false);
