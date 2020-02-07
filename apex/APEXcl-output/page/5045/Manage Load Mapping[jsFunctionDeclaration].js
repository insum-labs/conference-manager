var fixHelper = function(e, ui) {
            ui.children().each(function() {
            $(this).width($(this).width());
            });
      return ui;
}
function updateDisplaySeq(pRegionID) {
    var results = $(pRegionID).sortable('toArray', {attribute: 'data-id'});
    apex.server.process ( "UPDATE_DISPLAY_ORDER", 
   {f01:results},
   {
    success: function( pData ) 
    {
      if (pData.result === "OK") {
          apex.message.showPageSuccess("New order saved");
          apex.event.trigger(pRegionID, 'apexrefresh');
      } else {
          apex.message.showErrors({
                type:       "error",
                location:   "page",
                message:    pData.message,
                unsafe:     false
            });
      }
    }
   }
 );
}

function _makeSortable(pRegionID) {
    $r = $("#" + pRegionID).find('table');
    var r = $r[1];
    //Add ID element to TR
    $r.find("[headers='LINK'] a:not('.disabled')").each(function(){ 
        $(this).parent().parent().attr('data-id', $(this).data("id"));
    });
    //Make the region sortable
    $r.sortable({
          items: 'tr[data-id]'
        , containment : r
        , helper : fixHelper
        , update: function(event,ui) { updateDisplaySeq(r); }
    });
}


function makeSortable(pRegionID) {
  apex.server.process ( "HAS_FILTERS", 
    {},
    {
     success: function( pData ) 
     {
       if (pData.hasFilters) {
         // we do not want to allow sorting
         $(".drag-handle").addClass("disabled");
       }
       else {
          _makeSortable(pRegionID);
       }
     }
    }
  );
}
