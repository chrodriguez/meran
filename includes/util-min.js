ancla="";function crearAncla(id,strAncla){if(!$("#"+strAncla)){new Insertion.Before(id,"<a id="+strAncla+" name="+strAncla+"></a>");}
ancla="#"+strAncla;}
function delay(funcion,segundos){setTimeout(funcion,segundos*1000);}
function fancybox(id){$('#'+id).fancybox();}
function crearForm(url,params){var arrayParam=params.split("&");var formu=$("#formulario");var inputs="";for(var i=0;i<arrayParam.length;i++){var nombre=arrayParam[i].split("=")[0];var valor=arrayParam[i].split("=")[1];inputs=inputs+"<input type='hidden' name="+nombre+" value="+valor+"><br>";}
inputs=inputs+"<input type='hidden' name='token' value="+token+"><br>";formu.html("<form id='miForm' action="+url+" method='post'>"+inputs+"</form>");$("#miForm")[0].submit();}
function zebra(classObj){$("."+classObj+" tr:gt(0):odd").addClass("impar");$("."+classObj+" tr:gt(0):even").addClass("par");}
function zebraList(classObj){$("."+classObj+" li:gt(0):odd").addClass("impar");$("."+classObj+" li:gt(0):even").addClass("par");}
function zebraId(idObj){$("#"+idObj+" tr:gt(0):odd").addClass("impar");$("#"+idObj+" tr:gt(0):even").addClass("par");}
function tomarTiempo(){var currentTime=new Date()
var hours=currentTime.getHours()
var minutes=currentTime.getMinutes()
var seconds=currentTime.getSeconds();if(minutes<10)
minutes="0"+minutes
if(seconds<10)
seconds="0"+seconds;return hours+":"+minutes+" "+" "+seconds;}
function checkedAll(id,nombreCheckbox){$("#"+id).toggle(function(){$("input[name="+nombreCheckbox+"]").each(function(){this.checked=true;$(this).parent().parent().addClass("marked");})},function(){$("input[name="+nombreCheckbox+"]").each(function(){this.checked=false;$(this).parent().parent().removeClass("marked");})});}
function recuperarSeleccionados(chckbox){var chck=$("input[name="+chckbox+"]:checked");var array=new Array;var long=chck.length;for(var i=0;i<long;i++){array[i]=chck[i].value;}
return array;}
function checkedAllById(id){$("#"+id+" input[type='checkbox']").each(function(){this.checked=!this.checked;});}
function onEnter(idInput,funcion,param){var result_array=$("#"+idInput);if(result_array.length==0)return;$("#"+idInput).keypress(function(e){if(e.which==13){if(this.value!=''){if(param)
funcion(param);else
funcion();}}});}
function registrarKeypress(typeObject){var componentes=["input","INPUT"];var bool1=componentes[0]==typeObject;var bool2=componentes[1]==typeObject;var result=bool1||bool2;if(result==-1)
return;$(typeObject).keypress(function(e){if(e.which==13){if(this.value!=''){buscar();}}});}
function scrollTo(idObj){var result_array=$("#"+idObj);if(result_array.length==0)return;var divOffset=$('#'+idObj).offset().top-40;$('html,body').animate({scrollTop:divOffset},200);}
function getRadioButtonSelectedValue(ctrl){for(i=0;i<ctrl.length;i++)
if(ctrl[i].checked)return ctrl[i].value;}
function highlight(classesArray,idKeywordsArray){for(x=0;x<idKeywordsArray.length;x++){stringArray=($('#'+idKeywordsArray[x]).val()).split(' ');for(y=0;y<stringArray.length;y++){if($.trim(stringArray[y]).length!=0){for(z=0;z<classesArray.length;z++){$('.'+classesArray[z]).highlight(stringArray[y]);}}}}}
function toggle_ayuda_in_line(){$("#ayuda").click(function(){$("#ayuda_in_line").toggle("slow");});}
function esBrowser(browser){browser=browser.toLowerCase();ok=false;jQuery.each(jQuery.browser,function(i,val){if((val)&&(i==browser))
ok=true;});return(ok);}
function makeToggle(container_class,trigger,afterToggleFunction,hide){if(hide)
$("."+container_class).hide();$("legend."+trigger).toggle(function(){if(afterToggleFunction!=null)
afterToggleFunction();$(this).addClass("active");},function(){$(this).removeClass("active");});$("legend."+trigger).click(function(){$(this).next("."+container_class).slideToggle("fast");});}
function makeDataTable(id){try{$(id).dataTable({"bFilter":true,"bPaginate":false,"oLanguage":{"sLengthMenu":S_LENGTH_MENU,"sZeroRecords":S_ZERO_RECORDS,"sInfo":S_INFO,"sInfoEmpty":S_INFO_EMPTY,"sInfoFiltered":S_INFO_FILTERED,"sSearch":S_SEARCH,}});}
catch(e){}}
function changePage(ini){objAH.changePage(ini);}
function registrarTooltips(){$('input[type=text]').tooltip({track:true,});$('a').tooltip({showURL:false,track:true,});$('li').tooltip({showURL:false,track:true,});$('tr td').tooltip({showURL:false,track:true,});$('select option').tooltip({track:true,delay:0,showURL:false,opacity:1,fixPNG:true,showBody:" - ",extraClass:"pretty fancy",top:-15,left:5});}
function print_objetc(o){for(property in o){alert(property);}}
function copy(o){var newO=new Object();for(property in o){newO[property]=o[property];}
return newO;}
function log(string){if(window.console){window.console.log(string);}}
function replaceAccents(s){var r=s.toLowerCase();r=r.replace(new RegExp(/\s/g),"");r=r.replace(new RegExp(/[àáâãäå]/g),"a");r=r.replace(new RegExp(/æ/g),"ae");r=r.replace(new RegExp(/ç/g),"c");r=r.replace(new RegExp(/[èéêë]/g),"e");r=r.replace(new RegExp(/[ìíîï]/g),"i");r=r.replace(new RegExp(/ñ/g),"n");r=r.replace(new RegExp(/[òóôõö]/g),"o");r=r.replace(new RegExp(/œ/g),"oe");r=r.replace(new RegExp(/[ùúûü]/g),"u");r=r.replace(new RegExp(/[ýÿ]/g),"y");r=r.replace(new RegExp(/\W/g),"");return r;}
function replaceNonAccents(s){var r=s.toLowerCase();r=r.replace(new RegExp(/\s/g),"");r=r.replace(new RegExp(/[àaâãäå]/g),"á");r=r.replace(new RegExp(/[èeêë]/g),"é");r=r.replace(new RegExp(/[ìiîï]/g),"í");r=r.replace(new RegExp(/n/g),"ñ");r=r.replace(new RegExp(/[òoôõö]/g),"ó");r=r.replace(new RegExp(/[ùuûü]/g),"ú");r=r.replace(new RegExp(/[y]/g),"ÿ");r=r.replace(new RegExp(/\W/g),"");return r;}
function disableComponent(id){$('#'+id).attr('disabled',true);}