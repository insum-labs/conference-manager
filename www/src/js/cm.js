var cm = cm || {};

(function(cm, $, undefined) {

  cm.theme = {

    _irButtons: function() {
      // extend the IR to support a direct RESET
      if (typeof $.apex.interactiveReport === "function") {
          // only extend when the IR code is present
          $.apex.interactiveReport.prototype.reset = function() {this._reset();};

          $(".a-IRR .a-IRR-toolbar:not(:has(.a-IRR-buttons))").append("<div class='a-IRR-buttons'></div>");
          $(".a-IRR .a-IRR-toolbar .a-IRR-buttons:not(:has(.mm-reset-ir))").append("<button class='t-Button t-Button--noLabel t-Button--icon mm-reset-ir  t-Button--noUI' type='button' title='Reset IR' aria-label='Reset IR'><span class='t-Icon fa fa-refresh' aria-hidden='true'></span></button>");

          $(document).on("click", ".mm-reset-ir", function(){
              $(this).closest('.a-IRR-container').interactiveReport("reset");
          });
      }

    },

    init: function() {
        // init all the IR stuff
        cm.theme._irButtons();
    }

  };

})(cm, apex.jQuery);
