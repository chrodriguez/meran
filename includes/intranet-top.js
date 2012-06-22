var percent_progress_bar = 0;
var interval_ID = 0;
	function updateProgress(percentage){
        percent_progress_bar = parseInt(percentage);
		$('#progress_bar').show();
		$('#progress_bar_value').css('width',percent_progress_bar+'%');
		$('#progress_bar_value').html(percent_progress_bar+"%");
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
    	}

    }
	
    function updatePollTest(responseText){
	   if (parseInt(responseText) >= percent_progress_bar)
	    	updateProgress(responseText);
    }
	
    function checkProgress(){
 		interval_ID = window.setInterval('pollTest()', 1000);
    }
