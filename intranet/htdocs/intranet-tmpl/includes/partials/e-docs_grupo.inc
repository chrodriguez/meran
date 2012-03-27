[% USE HTML %]

[% IF pref_e_documents %]
		<script type="text/javascript">
		
		function refreshPage(fileName, responseJSON){
		   
		    jAlert(responseJSON.error,fileName);
		    
		}
		function uploadFile(id2,id1,url) {
			previousBytesLoaded = 0;
			ID2_file = id2;
			document.getElementById('uploadResponse' + '_' + ID2_file).style.display = 'none';
			document.getElementById('progressNumber' + '_' + ID2_file).innerHTML = '';
			var progressBar = document.getElementById('progressBar' + '_' + ID2_file);
			progressBar.style.display = 'block';
			progressBar.style.width = '0px';

			/*
			 * If you want to upload only a file along with arbitary data that is not in
			 * the form, use this
			 */
			var fd = new FormData();
			fd.append("id1", id1);
			fd.append("id2", id2);
			fd.append("filename", document.getElementById('filename_'+id2).value);
			fd.append("fileToUpload", document.getElementById('fileToUpload' + '_'
					+ ID2_file).files[0]);

			/* If you want to simply post the entire form, use this */
			// var fd = document.getElementById('form1').getFormData();
			xhr = new XMLHttpRequest();
			xhr.upload.addEventListener("progress", uploadProgress, false);
			xhr.addEventListener("load", uploadComplete, false);
			xhr.addEventListener("error", uploadFailed, false);
			xhr.addEventListener("abort", uploadCanceled, false);
			xhr.open("POST", url);
			xhr.send(fd);

			intervalTimer = setInterval(updateTransferSpeed, 500);
		}
		</script>



	<div class="accordion" id="lista_docs_[% id2 %]">
            <div class="accordion-group">
              <div class="accordion-heading">
                <a class="accordion-toggle" data-toggle="collapse" data-parent="#lista_docs_[% id2 %]" href="#e_docs[% id2 %]">
                  [% "Documentos electr&oacute;nicos"| i18n %]
                </a>
              </div>
              <div id="e_docs[% id2 %]" class="accordion-body collapse">
                <div class="accordion-inner">
			        <dl>
			               [% FOREACH file IN lista_docs %] 
			                           <dt>
				                           [% PERL %]
				                               print C4::AR::Filtros::link_to( text =>     "[% HTML.escape(file.getTitle) %]",
				                                                               url =>      "getDocument.pl", 
				                                                               params =>   ["id=[% file.getId %]"],
				                                                               title =>    "[% HTML.escape(file.getTitle) %]",
				                                                               icon => "icon-file",
				                                                           ) ;
				                           [% END %]

				                           [% PERL %]
				                               print C4::AR::Filtros::action_link_button( 
				                               								   title =>     "",
				                                                               url =>      "deleteDocument.pl", 
				                                                               params =>   ["id=[% file.getId %]","id1=[% id1 %]"],
				                                                               button =>    "btn-small btn-danger click",
				                                                               icon	  =>  "icon-white icon-trash",
				                                                           ) ;
				                           [% END %]
		                           	  </dt>
			            [% END %]
			        </dl>
				    <div id="file-uploader_[% id2 %]" class="form-horizontal">
						<form id="form_file-uploader_[% id2 %]" enctype="multipart/form-data" method="post" 
								action="[% url_prefix %]/catalogacion/estructura/uploadDocument.pl">
				               <input type="hidden" name="id2" id="id2" value="[% id2 %]" /><br />
				               <input type="hidden" name="id1" id="id1" value="[% id1 %]" /><br />
							   <div class="control-group">
							    <label class="control-label" for="fileToUpload_[% id2 %]">[% "Seleccione un archivo" | i18n %]</label>
							    <div class="controls">
							    	<input type="file" name="fileToUpload" id="fileToUpload_[% id2 %]" onchange="fileSelected([% id2 %]);"/>
							    </div>  
							  </div>
							  <div class="control-group">
								  <label class="control-label" for="filename">[% "T&iacute;tulo del arhivo"| i18n %]: </label>
								  <div class="controls">
								  	<input type="text" name="filename" id="filename_[% id2 %]" required /><br />
							  	  </div>
							  </div>
							  
							  <div id="fileInfo_[% id2 %]" class="alert alert-info hide">
							    <div id="fileName_[% id2 %]" class="fileName"></div>
							    <div id="fileSize_[% id2 %]" class="fileSize"></div>
							    <div id="fileType_[% id2 %]" class="fileType"></div>
							  </div>
							  
		  
							  <div class="row"></div>
							  <div id="progressIndicator_[% id2 %]" clas="progressIndicator" > 

								<div  class="progress progress-success progress-striped active">
								  <div id="progressBar_[% id2 %]" class="bar"></div>
								</div>
							    <div id="progressNumber_[% id2 %]" class="floatRight">&nbsp;</div>
							    <div class="clear"></div>
							    <div>
							      <div id="transferSpeedInfo_[% id2 %]" class="floatLeft" style="width: 80px;">&nbsp;</div>
							      <div id="timeRemainingInfo_[% id2 %]" class="floatLeft" style="margin-left: 10px;">&nbsp;</div>
							      <div id="transferBytesInfo_[% id2 %]" class="floatRight" style="text-align: right;">&nbsp;</div>
							      <div class="clear"></div>
							    </div>    
							    <div id="uploadResponse_[% id2 %]" class="uploadResponse"></div>
							  </div>  
							  
							  
							  <div class="form-actions">
						  		<div class="controls">
	                                  [% PERL %]
	                                          print C4::AR::Filtros::action_button( 
	                                                                          button         => "btn btn-primary click",
	                                                                          action       => 'uploadFile("[% id2 %]","[% id1 %]","[% url_prefix %]/catalogacion/estructura/uploadDocument.pl")', 
	                                                                          icon         => "",
	                                                                          title        => "[% 'Subir archivo' | i18n %]",
	                                                                      ) ;
	
	                                  [% END %]
                                </div>
						  			
  				  			  </div>
						</form>
				    </div>
		    	</div>
			</div>			    
		 </div>
	 </div>       
[% END %]	
		
		
		