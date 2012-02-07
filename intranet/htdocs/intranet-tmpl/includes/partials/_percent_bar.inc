<script>
var percent_progress_bar = 0;
var interval_ID = 0;
	function updateProgress(percentage){
		$('#progress_bar').show();
		$('#progress_bar').val(percentage);
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

<progress id="progress_bar" max="100" style="display:none;" ></progress>
