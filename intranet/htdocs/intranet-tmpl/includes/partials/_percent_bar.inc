<script>
	function updateProgress(percentage){
		$('#progress_bar').show();
		$('#progress_bar').val(percentage);
	}

	function parseJsonMessages(Messages_hashref){
        var i;
        //se agregan todos los mensajes
        for(i=0;i<Messages_hashref.messages.length;i++){
            if (Messages_hashref.messages[i].codMsg == "PERCENTAGE_VALUE"){
            	updateProgress(Messages_hashref.messages[i].message);
            	break;
            }
        }
	}
	
</script>
