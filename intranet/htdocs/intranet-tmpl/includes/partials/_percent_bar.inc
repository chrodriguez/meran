<script>
var percent_progress_bar = 0;
var interval_ID = 0;
	function updateProgress(percentage){
		$('#progress_bar').show();
		$('#progress_bar_value').css('width',percent_progress_bar+'%');
		$('#progress_bar_value').html(percent_progress_bar+"%");
        percent_progress_bar = parseInt(percentage);
	}


    function pollTest(){
    	if ( (percent_progress_bar != null) && (percent_progress_bar < 100) ) {
	        objAH                   = new AjaxHelper(updatePollTest);
	        objAH.url               = URL_PREFIX+'/poll_job.pl';
	        objAH.debug             = true;
	        objAH.showOverlay       = false;
	        objAH.jobID             = jobID; 
	        objAH.sendToServer();
    	}else{
    		updatePollTest(percent_progress_bar);
			percent_progress_bar = null;
            clearInterval(interval_ID);
            jAlert("EHHHH LOCO, TERMINO!!!!!!!!!!!");

    	}

    }
	
    function updatePollTest(responseText){
	   if (parseInt(responseText) >= percent_progress_bar)
	    	updateProgress(responseText);
    }
	
    function checkProgress(){
 		interval_ID = window.setInterval('pollTest()', 300);
    }
	
</script>

<div id="progress_bar" class="progress progress-success progress-striped hide" style="margin-bottom: 9px;margin-top: 25px;">
        <div class="bar" id="progress_bar_value" style="width: 0%"></div>
</div>