var l_clear = $(this.triggeringElement).hasClass("clearopt");
var l_node = $x_UpTill(this.triggeringElement,'LI');
var $section = $(l_node);
// check all the inputs
$section.find('ul').find('input').prop('checked', l_clear?false:true);

// open if we're closed
if (! $section.hasClass('open')) {
	$section.addClass('open').find('.expand').slideDown();
}
