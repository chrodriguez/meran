function _Init(options){if(options.showStatusIn!=''){$('#'+options.showStatusIn).addClass('cargando');}else{_ShowState(options);}
}
function _AddDiv(){var contenedor=$('#state')[0];if(contenedor==null){$('body').append("<div id='state' class='loading' style='position:absolute'>&nbsp;</div>");$('#state').css('top','0px');$('#state').css('left','0px');}}
function _ShowState(options){_AddDiv();$('#state').centerObject(options);$('#state').show();};function _HiddeState(options){if(options.showStatusIn!=''){$('#'+options.showStatusIn).show();$('#'+options.showStatusIn).removeClass('cargando');}else{$('#state').hide();}};jQuery.fn.centerObject=function(options){var obj=this;var total=0;var dif=0;if($(window).scrollTop()==0){obj.css('top',$(window).height()/2-this.height()/2);}else{total=$(window).height()+$(window).scrollTop();dif=total-$(window).height();obj.css('top',dif+($(window).height())/2);}
obj.css('left',$(window).width()/2-this.width()/2);if(options){if((options.debug)&&(window.console)){window.console.log("centerObject => \n"+
"Total Vertical: "+total+"\n"+
"Dif: "+dif+"\n"+
"Medio: "+(dif+($(window).height())/2)+
"\n"+
"Total Horizontal: "+$(window).width()+"\n"+
"Medio: "+$(window).width()/2);}}}
function AjaxHelper(fncUpdateInfo,fncInit){this.ini='';this.funcion='';this.url='';this.orden='';this.debug=false;this.debugJSON=false;this.onComplete=fncUpdateInfo;this.onBeforeSend=fncInit;this.showState=true;this.cache=false;this.showStatusIn='';this.sendToServer=function(){this.ajaxCallback(this);}
this.sort=function(ord){this.log("AjaxHelper => sort: "+ord);this.orden=ord;this.sendToServer();}
this.changePage=function(ini){this.log("AjaxHelper => changePage: "+ini);this.ini=ini;this.sendToServer();}
this.log=function(str){if((this.debug)&&(window.console)){window.console.log(str);}}
this.ajaxCallback=function(helper){if(this.debugJSON){JSONstring.debug=true;}
helper.token=token;var params="obj="+JSONstring.make(helper);this.log("AjaxHelper => ajaxCallback \n"+params);this.log("AjaxHelper => token: "+helper.token);var _hash_key;if(this.cache){_hash_key=b64_md5(params);this.log("AjaxHelper => cache element");this.log("AjaxHelper => cache hash_key "+_hash_key);if($.jCache.hasItem(_hash_key)){return helper.onComplete($.jCache.getItem(_hash_key));}}
$.ajax({type:"POST",url:helper.url,data:params,beforeSend:function(){if(helper.showState){_Init({debug:helper.debug,showStatusIn:helper.showStatusIn});}
if(helper.onBeforeSend){helper.onBeforeSend();}},complete:function(ajax){_HiddeState({showStatusIn:helper.showStatusIn});if(helper.onComplete){if(ajax.responseText=='CLIENT_REDIRECT'){window.location="/cgi-bin/koha/redirectController.pl";}else{if(helper.cache){$.jCache.setItem(_hash_key,ajax.responseText);}
helper.onComplete(ajax.responseText);}}}});}}