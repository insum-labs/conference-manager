var d = $v(this.triggeringElement);
$(this.affectedElements).datepicker("option","minDate", d )
.next('button').addClass('a-Button a-Button--calendar');