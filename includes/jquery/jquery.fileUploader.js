/*
 *
 *
*/
; (function($) {

    $.fn.extend({
        fileUploader: function(options) { 
        	opt = $.extend({}, $.uploadSetUp.defaults, options);
            if (opt.file_types.match('jpg') && !opt.file_types.match('jpeg')) 
            	opt.file_types += ',jpeg';
            $this = $(this);
            new $.uploadSetUp();
        }
    });

    $.uploadSetUp = function() {
        $('body').append($('<div></div>').append($('<iframe src="about:blank" id="myFrame" name="myFrame" style="display: none;"></iframe>')));
        $this.append($('<form target="myFrame" enctype="multipart/form-data" action="' + opt.ajaxFile + '" method="post" name="myUploadForm" id="myUploadForm"></form>')
            .append(
	    $('<input type="hidden" name="nro_socio" value="' + opt.nro_socio + '" />'),	
            $('<input type="hidden" name="upload" value="' + opt.uploadFolder + '" />'),
            $('<div class="select" title="upload new picture"></div>').append($('<input id="myUploadFile" class="myUploadFile file" type="file" value="" name="picture"/>')), 
            $('<ul id="ul_files"></ul>'))
	);
        init();
    };

    $.uploadSetUp.defaults = {
        // image types allowed
        file_types: "jpg,gif,png",
        // perl script
        ajaxFile: "upload.pl",
        // absolute path for upload pictures folder (don't forget to chmod)
        uploadFolder: "/ajaxMultiFileUpload/upload/",
        // callback function
	funcionOnComplete: '',
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
//         // delete uploaded file
//         $(".delete").livequery('click', function() {
//             // avoid duplicate function call
//             $(this).unbind('click');
//         });

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
            // llama a la funcion, luego de subir el archivo
	    loaded: function() {
			if(opt.funcionOnComplete){
				opt.funcionOnComplete();
			}
	    }
        };
        // check if file extension is allowed
        function checkFileType(file_) {
            var ext_ = file_.toLowerCase().substr(file_.toLowerCase().lastIndexOf('.') + 1);
            if (!opt.file_types.match(ext_)) {
                alert('tipo de archivo ' + ext_ + ' no permitido');
                return false;
            } 
            else return true;
        };
        // check type of iframe
        function frametype(fid) {
            return (fid.contentDocument) ? fid.contentDocument: (fid.contentWindow) ? fid.contentWindow.document: window.frames[fid].document;
        };

    }

})(jQuery);
