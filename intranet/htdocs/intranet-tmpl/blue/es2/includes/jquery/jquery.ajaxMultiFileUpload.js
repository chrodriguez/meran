/*
 *
 * @name		ajaxMultiFileUpload
 * @author		Kevin Crossman
 * @contact		kevincrossman@gmail.com
 * @version		2.1
 * @date			Oct 14 2008
 * @type    	 	jQuery
 *
*/
; (function($) {

    $.fn.extend({
        ajaxMultiFileUpload: function(options) { 
        	opt = $.extend({}, $.uploadSetUp.defaults, options);
            if (opt.file_types.match('jpg') && !opt.file_types.match('jpeg')) 
            	opt.file_types += ',jpeg';
            $this = $(this);
            new $.uploadSetUp();
        }
    });

    $.uploadSetUp = function() {
        $('body').append($('<div></div>').append($('<iframe src="about:blank" id="myFrame" name="myFrame"></iframe>')));
        $this.append($('<form target="myFrame" enctype="multipart/form-data" action="' + opt.ajaxFile + '" method="post" name="myUploadForm" id="myUploadForm"></form>')
            .append(
            $('<input type="hidden" name="thumb" value="' + opt.thumbFolder + '" />'),
	    $('<input type="hidden" name="bornum" value="' + opt.bornum + '" />'),	
            $('<input type="hidden" name="upload" value="' + opt.uploadFolder + '" />'),
            $('<input type="hidden" name="mode" value="' + opt.mode + '" />'),
            $('<div class="select" title="upload new picture"></div>').append($('<input id="myUploadFile" class="myUploadFile file" type="file" value="" name="picture" size="1"/>')), 
            $('<h2 class="numFiles"></h2>'), 
            $('<ul id="ul_files"></ul>')), 
            $('<div class="responseMsg">Response from ajax file: <br />(note: all images renamed to avoid server issues)</div><ul id="response"></ul>'));
        init();
    };

    $.uploadSetUp.defaults = {
        // image types allowed
        file_types: "jpg,gif,png",
        // php script
        ajaxFile: "upload.php",
        // maximum number of files allowed to upload
        maxNumFiles: 3,
        // if set to "demo", files are automatically deleted from server
        mode: "",
        // absolute path for upload pictures folder (don't forget to chmod)
        uploadFolder: "/ajaxMultiFileUpload/upload/",
        // absolute path for thumbnail folder (don't forget to chmod)
        thumbFolder: "/ajaxMultiFileUpload/thumb/"
    };

    function init() {

        // if file type is allowed, submit form
        $('#myUploadFile').livequery('change', function() { 
        	if (checkFileType(this.value)) 
        		$('#myUploadForm').submit(); 
        });
        // execute event.submit when form is submitted
        $('#myUploadForm').submit(function() { 
        	return event.submit(this); 
        });
        // delete uploaded file
        $(".delete").livequery('click', function() {
            // avoid duplicate function call
            $(this).unbind('click');
            // determine how to delete based on demo mode
            (opt.mode == "demo") ? _demoDelete($(this)) : _delete($(this));
        });

        // function to handle form submission using iframe
        var event = {
            // setup iframe
            frame: function(_form) {
                $("#myFrame")
                	.empty()
                	.one('load',  function() { event.loaded(this, _form) });
            },
            // call event.submit after submit
            submit: function(_form) {
                $('.select').addClass('waiting');
                event.frame(_form);
            },
            // display results from submit after loades into iframe
            loaded: function(id, _form) {
                var d = frametype(id),
                data = d.body.innerHTML.replace(/^\s+|\s+$/g, '');
                eval(data);
                $('.select.waiting').removeClass('waiting');
                
                // if no problem reported from submit
                if (typeof pst === 'undefined') {
                    
                    var problem = '<P>There was a problem during the upload</P>';
                    if (data.length) problem += '<LI><SPAN>The response from the server was</SPAN> ' + data + '</LI>';
                    else problem += '<LI>There was no response from the server .</LI>';
                    $('UL#response').append(problem);
                } 
                else if (!pst.problem) {
                    
                    var _img = new Image(),
                    
                    $delete = $('<div id="' + pst.img.rename + '" class="delete" title="delete file"></div>');
                    // add remove icon
                    $new = $('<div class="fileInfo"></div>').append($delete);
                    // add info wrapper	
                    $name = $('<div class="nameOfFile">' + pst.img.name + '</div>'); // add name of file							
                    // store names for ajax delete
                    $delete[0]._name = pst.img.name;
                    $delete[0]._rename = pst.img.rename;
                   
                   // setup image
                    $(_img)
                    	.attr({ src: pst.img.src, alt: pst.img.alt, width: pst.img.width, height: pst.img.height, title: pst.img.name })
                    	.addClass('uploaded');
                    
                    // display thumbname and info	
                    $("UL#ul_files").append($('<LI></LI>').append($new.prepend($(_img)), $name));
                    
                    // display file info in ajax response section
                    $('UL#response').append('<LI>File <SPAN>' + pst.img.name + '</SPAN> uploaded.</LI>');
                    //	automatically delete files from server when in demo mode
                    if (opt.mode == "demo") {
                    	var t = setTimeout(
                    		function() {
                        		$.post(opt.ajaxFile, { deleteFile: pst.img.rename, origName: pst.img.name, upload: opt.uploadFolder,  thumb: opt.thumbFolder, mode: opt.mode}) 
                        	}, 4000);
                    }
                    // update file counter
                    updateCount();
                } 
                else {
                
                    var problem = '<P>There was a problem uploading <SPAN>' + pst.problem.name + '</SPAN></P>';
					if (pst.problem.error) problem += '<LI>' +pst.problem.error + '</LI>';
                    if (pst.problem.ext) problem += '<LI class="ext">File extension <SPAN>' + pst.problem.ext_actual + '</SPAN> does not match actual file type <SPAN>' + pst.problem.ext + '</SPAN>.</LI>';
                    $('UL#response').append(problem);
                }
            }
        };
        // delete during demo mode
        function _demoDelete(toDelete) {
            toDelete
            	.parents('LI')
            	.fadeOut(1000, function() {
                	$(this).remove();
               		$('UL#response').append('<LI>File <SPAN>' + toDelete[0]._name + '</SPAN> deleted. </LI>');
                	updateCount();
            	});
        };
        // normal delete
        function _delete(toDelete) {
            $.post(opt.ajaxFile, { deleteFile: toDelete[0]._rename, origName: toDelete[0]._name, upload: opt.uploadFolder, thumb: opt.thumbFolder, mode: opt.mode },  
            	function(returned) {
            		$('UL#response').append('<li>' + returned.replace(/^\s+|\s+$/g, '') + '</li>');
               	 	toDelete
                		.parents('LI')
                		.fadeOut(1000, function(){ $(this).remove(); updateCount() });
            	});
        };
        // update the file counter
        function updateCount() {
            var numUploads = $("UL#ul_files").children('LI').size(),
            limit = (numUploads == opt.maxNumFiles) ? " reached.": " allowed.";
            $("H2.numFiles").text(numUploads + " File(s) Uploaded . . . Limit of " + opt.maxNumFiles + limit);
            $('.select').css({ opacity: (numUploads == opt.maxNumFiles) ? 0 : 1 });
        };
        // check if file extension is allowed
        function checkFileType(file_) {
            var ext_ = file_.toLowerCase().substr(file_.toLowerCase().lastIndexOf('.') + 1);
            if (!opt.file_types.match(ext_)) {
                alert('file type ' + ext_ + ' not allowed');
                return false;
            } 
            else return true;
        };
        // check type of iframe
        function frametype(fid) {
            return (fid.contentDocument) ? fid.contentDocument: (fid.contentWindow) ? fid.contentWindow.document: window.frames[fid].document;
        };

        updateCount();
    }

})(jQuery);
