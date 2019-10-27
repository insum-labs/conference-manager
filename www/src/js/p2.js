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
    $side.animate({width: closeSide}, 'fast', function(){$expandBtn.show(); });
    $body.animate({'margin-left': closedMargin}, 'fast', function(){$expandBtn.show(); });
  }
  else {
    $side.animate({width: openSide}, 'fast');
    $body.animate({'margin-left': openMargin}, 'fast');
    $expandBtn.hide();   
  }
  apex.event.trigger(window, 'resize');

}
