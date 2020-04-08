var scrollsave = 0;

// Derived from @J_Snyders code
// Set title of the dialog Session Details
$("body").on("dialogcreate", ".ui-dialog--apex", function(e) {
    $(this).closest(".session-details-modal").children(".ui-dialog-content").dialog("option", "title", $v("P2_DIALOG_TITLE"));
});

// Trigger the toggle when the NavBar is changed
apex.jQuery("#t_TreeNav").on('theme42layoutchanged', function(event, obj) {
    toggleBodySide($v("P2_BODY_SIDE_STATE"));
});

function _syncSizes() {
  // fix special elements with the new dimensions
  setTimeout(function(){
    apex.event.trigger(window, 'resize');
    // in 19.1 the resize event doesn't seem to be enough to adjust
    // the sticky headers, so we issue a forceresize
    $(".js-stickyTableHeader").trigger('forceresize');
  }, 100);
}

function toggleBodySide(state) {
  var $side=$(".t-Body-side"),
      $body=$(".t-Body-content"),
      $expandBtn=$("#expandTags"),

      closedMargin=245,
      closeSide=0,
      openMargin=480,
      openSide=240;

  // this assignment will save the latest preference
  $s("P2_BODY_SIDE_STATE", state);

  if ($("body").hasClass("js-navCollapsed")) {
    openMargin=280;
    closedMargin=40;
  }

  if (state === "close"){
    $side.animate({width: closeSide}, 'fast');
    $body.animate({'margin-left': closedMargin}, 'fast', 
      function(){
        $expandBtn.show();
        _syncSizes();
      });
  }
  else {
    $side.animate({width: openSide}, 'fast');
    $body.animate({'margin-left': openMargin}, 'fast', 
      function(){
        $expandBtn.hide();
        _syncSizes();
      });
  }

}
