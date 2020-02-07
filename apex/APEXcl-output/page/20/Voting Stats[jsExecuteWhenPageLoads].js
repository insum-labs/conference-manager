//Relocate committee voter pie
var item=$("#P20_COMMITTEE_COUNT_OF_TOTAL_CONTAINER");
$("#voteStatsRegion .t-Region-title").append(item);

//Relocate blind voter pie
var item=$("#P20_BLIND_COUNT_OF_TOTAL_CONTAINER");
$("#blindVoteStatsRegion .t-Region-title").append(item);

$("#blindVoteStatsRegion .pie").attr("title", $v("P20_COMMITTEE_PERCENT_VOTED") + " % completed" )
.css("animation-delay", "-" + $v("P20_COMMITTEE_PERCENT_VOTED") + "s")
.text($v("P20_COMMITTEE_PERCENT_VOTED"));


$("#voteStatsRegion .pie").attr("title", $v("P20_COMMITTEE_PERCENT_VOTED") + " % completed" )
.css("animation-delay", "-" + $v("P20_COMMITTEE_PERCENT_VOTED") + "s")
.text($v("P20_COMMITTEE_PERCENT_VOTED"));

$("blindVoteStatsRegion .pie").attr("title", $v("P20_BLIND_PERCENT_VOTED") + " % completed" )
.css("animation-delay", "-" + $v("P20_BLIND_PERCENT_VOTED") + "s")
.text($v("P20_BLIND_PERCENT_VOTED"));