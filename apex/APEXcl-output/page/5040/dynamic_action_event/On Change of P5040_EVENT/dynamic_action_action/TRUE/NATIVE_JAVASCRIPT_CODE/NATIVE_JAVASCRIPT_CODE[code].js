var warnPrePopulated = apex.item('P5040_POPULATED_WARNING').getValue();
console.log('warnPrePopulated: ' + warnPrePopulated)
if(warnPrePopulated && parseInt(warnPrePopulated) == 1 ) {
   $('#warn_pre_populated').show();
} else {
   $('#warn_pre_populated').hide();
}