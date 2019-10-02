var cm = cm || {};

(function(cm, $, undefined) {

  cm.theme = {

    // expand or collapse Nested Report plugin rows.
    // The "Expand/Collapse All" header needs
    // <a href="#0" class="expand-collapse-all" data-state="closed" title="Expand All"><span aria-hidden="true" class="fa fa-plus-square"></span></a>
    //
    expandCollapseAll: function(el) {
      // the context ensures we stay within the report (either IR or Classic)
      var $context = $(el).parents('.a-IRR-container'),
          $expandAll;
      if ($context.length === 0) {
        // we're not within an IR, so find the classic repor
        $context = $(el).parents('.t-Report');
      }
      $expandAll = $('.expand-collapse-all', $context);
      if($expandAll.data('state') == 'opened') {
        $('.pretius--expanded a', $context).click();
        $expandAll.data('state', 'closed');
        $expandAll.prop('title', 'Expand All');
        $expandAll.find('.fa').removeClass().addClass('fa fa-plus-square');    
      }
      else {
        //We are clicking rows that do NOT have a parent with class '.pretius--expanded'
        //Solution taken from: https://stackoverflow.com/questions/6784741/how-to-select-an-element-which-parent-is-not-specified-class  
        $('.showChildren', $context).not('.pretius--expanded .showChildren').click();
        $expandAll.data('state', 'opened');
        $expandAll.prop('title','Collapse All');  
        $expandAll.find('.fa').removeClass().addClass('fa fa-minus-square');
      }
    },

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
