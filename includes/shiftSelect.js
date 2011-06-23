(function($) {
	$.fn.shiftClick = function() {
		var lastSelected;
		var checkBoxes = $(this);

		this.each(function() {
			$(this).click(function(ev) {
				if (ev.shiftKey) {
					var last    = checkBoxes.index(lastSelected);
					var first   = checkBoxes.index(this);

					var start   = Math.min(first, last);
					var end     = Math.max(first, last);

					var chk     = lastSelected.checked;
                    var clase;
                    var claseOriginal;
					for (var i = start; i < end; i++) {
						checkBoxes[i].checked = chk;
                        clase = checkBoxes[i].parentNode.parentNode.getAttribute('class');
                        claseOriginal = clase.split(' ');
                        if(chk == false){         
                            checkBoxes[i].parentNode.parentNode.setAttribute('class', claseOriginal[0]);
                        }else{
                            if(claseOriginal[1] != 'marked'){ 
                                checkBoxes[i].parentNode.parentNode.setAttribute('class', clase+' marked');
                            }
                        }
					}
				} else {
					lastSelected = this;
				}
			})
		});
	};
})(jQuery);
