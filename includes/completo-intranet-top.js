(function(E,B){function ka(a,b,d){if(d===B&&a.nodeType===1){d=a.getAttribute("data-"+b);if(typeof d==="string"){try{d=d==="true"?true:d==="false"?false:d==="null"?null:!c.isNaN(d)?parseFloat(d):Ja.test(d)?c.parseJSON(d):d}catch(e){}c.data(a,b,d)}else d=B}return d}function U(){return false}function ca(){return true}function la(a,b,d){d[0].type=a;return c.event.handle.apply(b,d)}function Ka(a){var b,d,e,f,h,l,k,o,x,r,A,C=[];f=[];h=c.data(this,this.nodeType?"events":"__events__");if(typeof h==="function")h=h.events;if(!(a.liveFired===this||!h||!h.live||a.button&&a.type==="click")){if(a.namespace)A=RegExp("(^|\\.)"+a.namespace.split(".").join("\\.(?:.*\\.)?")+"(\\.|$)");a.liveFired=this;var J=h.live.slice(0);for(k=0;k<J.length;k++){h=J[k];h.origType.replace(X,"")===a.type?f.push(h.selector):J.splice(k--,1)}f=c(a.target).closest(f,a.currentTarget);o=0;for(x=f.length;o<x;o++){r=f[o];for(k=0;k<J.length;k++){h=J[k];if(r.selector===h.selector&&(!A||A.test(h.namespace))){l=r.elem;e=null;if(h.preType==="mouseenter"||h.preType==="mouseleave"){a.type=h.preType;e=c(a.relatedTarget).closest(h.selector)[0]}if(!e||e!==l)C.push({elem:l,handleObj:h,level:r.level})}}}o=0;for(x=C.length;o<x;o++){f=C[o];if(d&&f.level>d)break;a.currentTarget=f.elem;a.data=f.handleObj.data;a.handleObj=f.handleObj;A=f.handleObj.origHandler.apply(f.elem,arguments);if(A===false||a.isPropagationStopped()){d=f.level;if(A===false)b=false;if(a.isImmediatePropagationStopped())break}}return b}}function Y(a,b){return(a&&a!=="*"?a+".":"")+b.replace(La,"`").replace(Ma,"&")}function ma(a,b,d){if(c.isFunction(b))return c.grep(a,function(f,h){return!!b.call(f,h,f)===d});else if(b.nodeType)return c.grep(a,function(f){return f===b===d});else if(typeof b==="string"){var e=c.grep(a,function(f){return f.nodeType===1});if(Na.test(b))return c.filter(b,e,!d);else b=c.filter(b,e)}return c.grep(a,function(f){return c.inArray(f,b)>=0===d})}function na(a,b){var d=0;b.each(function(){if(this.nodeName===(a[d]&&a[d].nodeName)){var e=c.data(a[d++]),f=c.data(this,e);if(e=e&&e.events){delete f.handle;f.events={};for(var h in e)for(var l in e[h])c.event.add(this,h,e[h][l],e[h][l].data)}}})}function Oa(a,b){b.src?c.ajax({url:b.src,async:false,dataType:"script"}):c.globalEval(b.text||b.textContent||b.innerHTML||"");b.parentNode&&b.parentNode.removeChild(b)}function oa(a,b,d){var e=b==="width"?a.offsetWidth:a.offsetHeight;if(d==="border")return e;c.each(b==="width"?Pa:Qa,function(){d||(e-=parseFloat(c.css(a,"padding"+this))||0);if(d==="margin")e+=parseFloat(c.css(a,"margin"+this))||0;else e-=parseFloat(c.css(a,"border"+this+"Width"))||0});return e}function da(a,b,d,e){if(c.isArray(b)&&b.length)c.each(b,function(f,h){d||Ra.test(a)?e(a,h):da(a+"["+(typeof h==="object"||c.isArray(h)?f:"")+"]",h,d,e)});else if(!d&&b!=null&&typeof b==="object")c.isEmptyObject(b)?e(a,""):c.each(b,function(f,h){da(a+"["+f+"]",h,d,e)});else e(a,b)}function S(a,b){var d={};c.each(pa.concat.apply([],pa.slice(0,b)),function(){d[this]=a});return d}function qa(a){if(!ea[a]){var b=c("<"+
a+">").appendTo("body"),d=b.css("display");b.remove();if(d==="none"||d==="")d="block";ea[a]=d}return ea[a]}function fa(a){return c.isWindow(a)?a:a.nodeType===9?a.defaultView||a.parentWindow:false}var t=E.document,c=function(){function a(){if(!b.isReady){try{t.documentElement.doScroll("left")}catch(j){setTimeout(a,1);return}b.ready()}}var b=function(j,s){return new b.fn.init(j,s)},d=E.jQuery,e=E.$,f,h=/^(?:[^<]*(<[\w\W]+>)[^>]*$|#([\w\-]+)$)/,l=/\S/,k=/^\s+/,o=/\s+$/,x=/\W/,r=/\d/,A=/^<(\w+)\s*\/?>(?:<\/\1>)?$/,C=/^[\],:{}\s]*$/,J=/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g,w=/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g,I=/(?:^|:|,)(?:\s*\[)+/g,L=/(webkit)[ \/]([\w.]+)/,g=/(opera)(?:.*version)?[ \/]([\w.]+)/,i=/(msie) ([\w.]+)/,n=/(mozilla)(?:.*? rv:([\w.]+))?/,m=navigator.userAgent,p=false,q=[],u,y=Object.prototype.toString,F=Object.prototype.hasOwnProperty,M=Array.prototype.push,N=Array.prototype.slice,O=String.prototype.trim,D=Array.prototype.indexOf,R={};b.fn=b.prototype={init:function(j,s){var v,z,H;if(!j)return this;if(j.nodeType){this.context=this[0]=j;this.length=1;return this}if(j==="body"&&!s&&t.body){this.context=t;this[0]=t.body;this.selector="body";this.length=1;return this}if(typeof j==="string")if((v=h.exec(j))&&(v[1]||!s))if(v[1]){H=s?s.ownerDocument||s:t;if(z=A.exec(j))if(b.isPlainObject(s)){j=[t.createElement(z[1])];b.fn.attr.call(j,s,true)}else j=[H.createElement(z[1])];else{z=b.buildFragment([v[1]],[H]);j=(z.cacheable?z.fragment.cloneNode(true):z.fragment).childNodes}return b.merge(this,j)}else{if((z=t.getElementById(v[2]))&&z.parentNode){if(z.id!==v[2])return f.find(j);this.length=1;this[0]=z}this.context=t;this.selector=j;return this}else if(!s&&!x.test(j)){this.selector=j;this.context=t;j=t.getElementsByTagName(j);return b.merge(this,j)}else return!s||s.jquery?(s||f).find(j):b(s).find(j);else if(b.isFunction(j))return f.ready(j);if(j.selector!==B){this.selector=j.selector;this.context=j.context}return b.makeArray(j,this)},selector:"",jquery:"1.4.4",length:0,size:function(){return this.length},toArray:function(){return N.call(this,0)},get:function(j){return j==null?this.toArray():j<0?this.slice(j)[0]:this[j]},pushStack:function(j,s,v){var z=b();b.isArray(j)?M.apply(z,j):b.merge(z,j);z.prevObject=this;z.context=this.context;if(s==="find")z.selector=this.selector+(this.selector?" ":"")+v;else if(s)z.selector=this.selector+"."+s+"("+v+")";return z},each:function(j,s){return b.each(this,j,s)},ready:function(j){b.bindReady();if(b.isReady)j.call(t,b);else q&&q.push(j);return this},eq:function(j){return j===-1?this.slice(j):this.slice(j,+j+1)},first:function(){return this.eq(0)},last:function(){return this.eq(-1)},slice:function(){return this.pushStack(N.apply(this,arguments),"slice",N.call(arguments).join(","))},map:function(j){return this.pushStack(b.map(this,function(s,v){return j.call(s,v,s)}))},end:function(){return this.prevObject||b(null)},push:M,sort:[].sort,splice:[].splice};b.fn.init.prototype=b.fn;b.extend=b.fn.extend=function(){var j,s,v,z,H,G=arguments[0]||{},K=1,Q=arguments.length,ga=false;if(typeof G==="boolean"){ga=G;G=arguments[1]||{};K=2}if(typeof G!=="object"&&!b.isFunction(G))G={};if(Q===K){G=this;--K}for(;K<Q;K++)if((j=arguments[K])!=null)for(s in j){v=G[s];z=j[s];if(G!==z)if(ga&&z&&(b.isPlainObject(z)||(H=b.isArray(z)))){if(H){H=false;v=v&&b.isArray(v)?v:[]}else v=v&&b.isPlainObject(v)?v:{};G[s]=b.extend(ga,v,z)}else if(z!==B)G[s]=z}return G};b.extend({noConflict:function(j){E.$=e;if(j)E.jQuery=d;return b},isReady:false,readyWait:1,ready:function(j){j===true&&b.readyWait--;if(!b.readyWait||j!==true&&!b.isReady){if(!t.body)return setTimeout(b.ready,1);b.isReady=true;if(!(j!==true&&--b.readyWait>0))if(q){var s=0,v=q;for(q=null;j=v[s++];)j.call(t,b);b.fn.trigger&&b(t).trigger("ready").unbind("ready")}}},bindReady:function(){if(!p){p=true;if(t.readyState==="complete")return setTimeout(b.ready,1);if(t.addEventListener){t.addEventListener("DOMContentLoaded",u,false);E.addEventListener("load",b.ready,false)}else if(t.attachEvent){t.attachEvent("onreadystatechange",u);E.attachEvent("onload",b.ready);var j=false;try{j=E.frameElement==null}catch(s){}t.documentElement.doScroll&&j&&a()}}},isFunction:function(j){return b.type(j)==="function"},isArray:Array.isArray||function(j){return b.type(j)==="array"},isWindow:function(j){return j&&typeof j==="object"&&"setInterval"in j},isNaN:function(j){return j==null||!r.test(j)||isNaN(j)},type:function(j){return j==null?String(j):R[y.call(j)]||"object"},isPlainObject:function(j){if(!j||b.type(j)!=="object"||j.nodeType||b.isWindow(j))return false;if(j.constructor&&!F.call(j,"constructor")&&!F.call(j.constructor.prototype,"isPrototypeOf"))return false;for(var s in j);return s===B||F.call(j,s)},isEmptyObject:function(j){for(var s in j)return false;return true},error:function(j){throw j;},parseJSON:function(j){if(typeof j!=="string"||!j)return null;j=b.trim(j);if(C.test(j.replace(J,"@").replace(w,"]").replace(I,"")))return E.JSON&&E.JSON.parse?E.JSON.parse(j):(new Function("return "+j))();else b.error("Invalid JSON: "+j)},noop:function(){},globalEval:function(j){if(j&&l.test(j)){var s=t.getElementsByTagName("head")[0]||t.documentElement,v=t.createElement("script");v.type="text/javascript";if(b.support.scriptEval)v.appendChild(t.createTextNode(j));else v.text=j;s.insertBefore(v,s.firstChild);s.removeChild(v)}},nodeName:function(j,s){return j.nodeName&&j.nodeName.toUpperCase()===s.toUpperCase()},each:function(j,s,v){var z,H=0,G=j.length,K=G===B||b.isFunction(j);if(v)if(K)for(z in j){if(s.apply(j[z],v)===false)break}else for(;H<G;){if(s.apply(j[H++],v)===false)break}else if(K)for(z in j){if(s.call(j[z],z,j[z])===false)break}else for(v=j[0];H<G&&s.call(v,H,v)!==false;v=j[++H]);return j},trim:O?function(j){return j==null?"":O.call(j)}:function(j){return j==null?"":j.toString().replace(k,"").replace(o,"")},makeArray:function(j,s){var v=s||[];if(j!=null){var z=b.type(j);j.length==null||z==="string"||z==="function"||z==="regexp"||b.isWindow(j)?M.call(v,j):b.merge(v,j)}return v},inArray:function(j,s){if(s.indexOf)return s.indexOf(j);for(var v=0,z=s.length;v<z;v++)if(s[v]===j)return v;return-1},merge:function(j,s){var v=j.length,z=0;if(typeof s.length==="number")for(var H=s.length;z<H;z++)j[v++]=s[z];else for(;s[z]!==B;)j[v++]=s[z++];j.length=v;return j},grep:function(j,s,v){var z=[],H;v=!!v;for(var G=0,K=j.length;G<K;G++){H=!!s(j[G],G);v!==H&&z.push(j[G])}return z},map:function(j,s,v){for(var z=[],H,G=0,K=j.length;G<K;G++){H=s(j[G],G,v);if(H!=null)z[z.length]=H}return z.concat.apply([],z)},guid:1,proxy:function(j,s,v){if(arguments.length===2)if(typeof s==="string"){v=j;j=v[s];s=B}else if(s&&!b.isFunction(s)){v=s;s=B}if(!s&&j)s=function(){return j.apply(v||this,arguments)};if(j)s.guid=j.guid=j.guid||s.guid||b.guid++;return s},access:function(j,s,v,z,H,G){var K=j.length;if(typeof s==="object"){for(var Q in s)b.access(j,Q,s[Q],z,H,v);return j}if(v!==B){z=!G&&z&&b.isFunction(v);for(Q=0;Q<K;Q++)H(j[Q],s,z?v.call(j[Q],Q,H(j[Q],s)):v,G);return j}return K?H(j[0],s):B},now:function(){return(new Date).getTime()},uaMatch:function(j){j=j.toLowerCase();j=L.exec(j)||g.exec(j)||i.exec(j)||j.indexOf("compatible")<0&&n.exec(j)||[];return{browser:j[1]||"",version:j[2]||"0"}},browser:{}});b.each("Boolean Number String Function Array Date RegExp Object".split(" "),function(j,s){R["[object "+s+"]"]=s.toLowerCase()});m=b.uaMatch(m);if(m.browser){b.browser[m.browser]=true;b.browser.version=m.version}if(b.browser.webkit)b.browser.safari=true;if(D)b.inArray=function(j,s){return D.call(s,j)};if(!/\s/.test("\u00a0")){k=/^[\s\xA0]+/;o=/[\s\xA0]+$/}f=b(t);if(t.addEventListener)u=function(){t.removeEventListener("DOMContentLoaded",u,false);b.ready()};else if(t.attachEvent)u=function(){if(t.readyState==="complete"){t.detachEvent("onreadystatechange",u);b.ready()}};return E.jQuery=E.$=b}();(function(){c.support={};var a=t.documentElement,b=t.createElement("script"),d=t.createElement("div"),e="script"+c.now();d.style.display="none";d.innerHTML="   <link/><table></table><a href='/a' style='color:red;float:left;opacity:.55;'>a</a><input type='checkbox'/>";var f=d.getElementsByTagName("*"),h=d.getElementsByTagName("a")[0],l=t.createElement("select"),k=l.appendChild(t.createElement("option"));if(!(!f||!f.length||!h)){c.support={leadingWhitespace:d.firstChild.nodeType===3,tbody:!d.getElementsByTagName("tbody").length,htmlSerialize:!!d.getElementsByTagName("link").length,style:/red/.test(h.getAttribute("style")),hrefNormalized:h.getAttribute("href")==="/a",opacity:/^0.55$/.test(h.style.opacity),cssFloat:!!h.style.cssFloat,checkOn:d.getElementsByTagName("input")[0].value==="on",optSelected:k.selected,deleteExpando:true,optDisabled:false,checkClone:false,scriptEval:false,noCloneEvent:true,boxModel:null,inlineBlockNeedsLayout:false,shrinkWrapBlocks:false,reliableHiddenOffsets:true};l.disabled=true;c.support.optDisabled=!k.disabled;b.type="text/javascript";try{b.appendChild(t.createTextNode("window."+e+"=1;"))}catch(o){}a.insertBefore(b,a.firstChild);if(E[e]){c.support.scriptEval=true;delete E[e]}try{delete b.test}catch(x){c.support.deleteExpando=false}a.removeChild(b);if(d.attachEvent&&d.fireEvent){d.attachEvent("onclick",function r(){c.support.noCloneEvent=false;d.detachEvent("onclick",r)});d.cloneNode(true).fireEvent("onclick")}d=t.createElement("div");d.innerHTML="<input type='radio' name='radiotest' checked='checked'/>";a=t.createDocumentFragment();a.appendChild(d.firstChild);c.support.checkClone=a.cloneNode(true).cloneNode(true).lastChild.checked;c(function(){var r=t.createElement("div");r.style.width=r.style.paddingLeft="1px";t.body.appendChild(r);c.boxModel=c.support.boxModel=r.offsetWidth===2;if("zoom"in r.style){r.style.display="inline";r.style.zoom=1;c.support.inlineBlockNeedsLayout=r.offsetWidth===2;r.style.display="";r.innerHTML="<div style='width:4px;'></div>";c.support.shrinkWrapBlocks=r.offsetWidth!==2}r.innerHTML="<table><tr><td style='padding:0;display:none'></td><td>t</td></tr></table>";var A=r.getElementsByTagName("td");c.support.reliableHiddenOffsets=A[0].offsetHeight===0;A[0].style.display="";A[1].style.display="none";c.support.reliableHiddenOffsets=c.support.reliableHiddenOffsets&&A[0].offsetHeight===0;r.innerHTML="";t.body.removeChild(r).style.display="none"});a=function(r){var A=t.createElement("div");r="on"+r;var C=r in A;if(!C){A.setAttribute(r,"return;");C=typeof A[r]==="function"}return C};c.support.submitBubbles=a("submit");c.support.changeBubbles=a("change");a=b=d=f=h=null}})();var ra={},Ja=/^(?:\{.*\}|\[.*\])$/;c.extend({cache:{},uuid:0,expando:"jQuery"+c.now(),noData:{embed:true,object:"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000",applet:true},data:function(a,b,d){if(c.acceptData(a)){a=a==E?ra:a;var e=a.nodeType,f=e?a[c.expando]:null,h=c.cache;if(!(e&&!f&&typeof b==="string"&&d===B)){if(e)f||(a[c.expando]=f=++c.uuid);else h=a;if(typeof b==="object")if(e)h[f]=c.extend(h[f],b);else c.extend(h,b);else if(e&&!h[f])h[f]={};a=e?h[f]:h;if(d!==B)a[b]=d;return typeof b==="string"?a[b]:a}}},removeData:function(a,b){if(c.acceptData(a)){a=a==E?ra:a;var d=a.nodeType,e=d?a[c.expando]:a,f=c.cache,h=d?f[e]:e;if(b){if(h){delete h[b];d&&c.isEmptyObject(h)&&c.removeData(a)}}else if(d&&c.support.deleteExpando)delete a[c.expando];else if(a.removeAttribute)a.removeAttribute(c.expando);else if(d)delete f[e];else for(var l in a)delete a[l]}},acceptData:function(a){if(a.nodeName){var b=c.noData[a.nodeName.toLowerCase()];if(b)return!(b===true||a.getAttribute("classid")!==b)}return true}});c.fn.extend({data:function(a,b){var d=null;if(typeof a==="undefined"){if(this.length){var e=this[0].attributes,f;d=c.data(this[0]);for(var h=0,l=e.length;h<l;h++){f=e[h].name;if(f.indexOf("data-")===0){f=f.substr(5);ka(this[0],f,d[f])}}}return d}else if(typeof a==="object")return this.each(function(){c.data(this,a)});var k=a.split(".");k[1]=k[1]?"."+k[1]:"";if(b===B){d=this.triggerHandler("getData"+k[1]+"!",[k[0]]);if(d===B&&this.length){d=c.data(this[0],a);d=ka(this[0],a,d)}return d===B&&k[1]?this.data(k[0]):d}else return this.each(function(){var o=c(this),x=[k[0],b];o.triggerHandler("setData"+k[1]+"!",x);c.data(this,a,b);o.triggerHandler("changeData"+k[1]+"!",x)})},removeData:function(a){return this.each(function(){c.removeData(this,a)})}});c.extend({queue:function(a,b,d){if(a){b=(b||"fx")+"queue";var e=c.data(a,b);if(!d)return e||[];if(!e||c.isArray(d))e=c.data(a,b,c.makeArray(d));else e.push(d);return e}},dequeue:function(a,b){b=b||"fx";var d=c.queue(a,b),e=d.shift();if(e==="inprogress")e=d.shift();if(e){b==="fx"&&d.unshift("inprogress");e.call(a,function(){c.dequeue(a,b)})}}});c.fn.extend({queue:function(a,b){if(typeof a!=="string"){b=a;a="fx"}if(b===B)return c.queue(this[0],a);return this.each(function(){var d=c.queue(this,a,b);a==="fx"&&d[0]!=="inprogress"&&c.dequeue(this,a)})},dequeue:function(a){return this.each(function(){c.dequeue(this,a)})},delay:function(a,b){a=c.fx?c.fx.speeds[a]||a:a;b=b||"fx";return this.queue(b,function(){var d=this;setTimeout(function(){c.dequeue(d,b)},a)})},clearQueue:function(a){return this.queue(a||"fx",[])}});var sa=/[\n\t]/g,ha=/\s+/,Sa=/\r/g,Ta=/^(?:href|src|style)$/,Ua=/^(?:button|input)$/i,Va=/^(?:button|input|object|select|textarea)$/i,Wa=/^a(?:rea)?$/i,ta=/^(?:radio|checkbox)$/i;c.props={"for":"htmlFor","class":"className",readonly:"readOnly",maxlength:"maxLength",cellspacing:"cellSpacing",rowspan:"rowSpan",colspan:"colSpan",tabindex:"tabIndex",usemap:"useMap",frameborder:"frameBorder"};c.fn.extend({attr:function(a,b){return c.access(this,a,b,true,c.attr)},removeAttr:function(a){return this.each(function(){c.attr(this,a,"");this.nodeType===1&&this.removeAttribute(a)})},addClass:function(a){if(c.isFunction(a))return this.each(function(x){var r=c(this);r.addClass(a.call(this,x,r.attr("class")))});if(a&&typeof a==="string")for(var b=(a||"").split(ha),d=0,e=this.length;d<e;d++){var f=this[d];if(f.nodeType===1)if(f.className){for(var h=" "+f.className+" ",l=f.className,k=0,o=b.length;k<o;k++)if(h.indexOf(" "+b[k]+" ")<0)l+=" "+b[k];f.className=c.trim(l)}else f.className=a}return this},removeClass:function(a){if(c.isFunction(a))return this.each(function(o){var x=c(this);x.removeClass(a.call(this,o,x.attr("class")))});if(a&&typeof a==="string"||a===B)for(var b=(a||"").split(ha),d=0,e=this.length;d<e;d++){var f=this[d];if(f.nodeType===1&&f.className)if(a){for(var h=(" "+f.className+" ").replace(sa," "),l=0,k=b.length;l<k;l++)h=h.replace(" "+b[l]+" "," ");f.className=c.trim(h)}else f.className=""}return this},toggleClass:function(a,b){var d=typeof a,e=typeof b==="boolean";if(c.isFunction(a))return this.each(function(f){var h=c(this);h.toggleClass(a.call(this,f,h.attr("class"),b),b)});return this.each(function(){if(d==="string")for(var f,h=0,l=c(this),k=b,o=a.split(ha);f=o[h++];){k=e?k:!l.hasClass(f);l[k?"addClass":"removeClass"](f)}else if(d==="undefined"||d==="boolean"){this.className&&c.data(this,"__className__",this.className);this.className=this.className||a===false?"":c.data(this,"__className__")||""}})},hasClass:function(a){a=" "+a+" ";for(var b=0,d=this.length;b<d;b++)if((" "+this[b].className+" ").replace(sa," ").indexOf(a)>-1)return true;return false},val:function(a){if(!arguments.length){var b=this[0];if(b){if(c.nodeName(b,"option")){var d=b.attributes.value;return!d||d.specified?b.value:b.text}if(c.nodeName(b,"select")){var e=b.selectedIndex;d=[];var f=b.options;b=b.type==="select-one";if(e<0)return null;var h=b?e:0;for(e=b?e+1:f.length;h<e;h++){var l=f[h];if(l.selected&&(c.support.optDisabled?!l.disabled:l.getAttribute("disabled")===null)&&(!l.parentNode.disabled||!c.nodeName(l.parentNode,"optgroup"))){a=c(l).val();if(b)return a;d.push(a)}}return d}if(ta.test(b.type)&&!c.support.checkOn)return b.getAttribute("value")===null?"on":b.value;return(b.value||"").replace(Sa,"")}return B}var k=c.isFunction(a);return this.each(function(o){var x=c(this),r=a;if(this.nodeType===1){if(k)r=a.call(this,o,x.val());if(r==null)r="";else if(typeof r==="number")r+="";else if(c.isArray(r))r=c.map(r,function(C){return C==null?"":C+""});if(c.isArray(r)&&ta.test(this.type))this.checked=c.inArray(x.val(),r)>=0;else if(c.nodeName(this,"select")){var A=c.makeArray(r);c("option",this).each(function(){this.selected=c.inArray(c(this).val(),A)>=0});if(!A.length)this.selectedIndex=-1}else this.value=r}})}});c.extend({attrFn:{val:true,css:true,html:true,text:true,data:true,width:true,height:true,offset:true},attr:function(a,b,d,e){if(!a||a.nodeType===3||a.nodeType===8)return B;if(e&&b in c.attrFn)return c(a)[b](d);e=a.nodeType!==1||!c.isXMLDoc(a);var f=d!==B;b=e&&c.props[b]||b;var h=Ta.test(b);if((b in a||a[b]!==B)&&e&&!h){if(f){b==="type"&&Ua.test(a.nodeName)&&a.parentNode&&c.error("type property can't be changed");if(d===null)a.nodeType===1&&a.removeAttribute(b);else a[b]=d}if(c.nodeName(a,"form")&&a.getAttributeNode(b))return a.getAttributeNode(b).nodeValue;if(b==="tabIndex")return(b=a.getAttributeNode("tabIndex"))&&b.specified?b.value:Va.test(a.nodeName)||Wa.test(a.nodeName)&&a.href?0:B;return a[b]}if(!c.support.style&&e&&b==="style"){if(f)a.style.cssText=""+d;return a.style.cssText}f&&a.setAttribute(b,""+d);if(!a.attributes[b]&&a.hasAttribute&&!a.hasAttribute(b))return B;a=!c.support.hrefNormalized&&e&&h?a.getAttribute(b,2):a.getAttribute(b);return a===null?B:a}});var X=/\.(.*)$/,ia=/^(?:textarea|input|select)$/i,La=/\./g,Ma=/ /g,Xa=/[^\w\s.|`]/g,Ya=function(a){return a.replace(Xa,"\\$&")},ua={focusin:0,focusout:0};c.event={add:function(a,b,d,e){if(!(a.nodeType===3||a.nodeType===8)){if(c.isWindow(a)&&a!==E&&!a.frameElement)a=E;if(d===false)d=U;else if(!d)return;var f,h;if(d.handler){f=d;d=f.handler}if(!d.guid)d.guid=c.guid++;if(h=c.data(a)){var l=a.nodeType?"events":"__events__",k=h[l],o=h.handle;if(typeof k==="function"){o=k.handle;k=k.events}else if(!k){a.nodeType||(h[l]=h=function(){});h.events=k={}}if(!o)h.handle=o=function(){return typeof c!=="undefined"&&!c.event.triggered?c.event.handle.apply(o.elem,arguments):B};o.elem=a;b=b.split(" ");for(var x=0,r;l=b[x++];){h=f?c.extend({},f):{handler:d,data:e};if(l.indexOf(".")>-1){r=l.split(".");l=r.shift();h.namespace=r.slice(0).sort().join(".")}else{r=[];h.namespace=""}h.type=l;if(!h.guid)h.guid=d.guid;var A=k[l],C=c.event.special[l]||{};if(!A){A=k[l]=[];if(!C.setup||C.setup.call(a,e,r,o)===false)if(a.addEventListener)a.addEventListener(l,o,false);else a.attachEvent&&a.attachEvent("on"+l,o)}if(C.add){C.add.call(a,h);if(!h.handler.guid)h.handler.guid=d.guid}A.push(h);c.event.global[l]=true}a=null}}},global:{},remove:function(a,b,d,e){if(!(a.nodeType===3||a.nodeType===8)){if(d===false)d=U;var f,h,l=0,k,o,x,r,A,C,J=a.nodeType?"events":"__events__",w=c.data(a),I=w&&w[J];if(w&&I){if(typeof I==="function"){w=I;I=I.events}if(b&&b.type){d=b.handler;b=b.type}if(!b||typeof b==="string"&&b.charAt(0)==="."){b=b||"";for(f in I)c.event.remove(a,f+b)}else{for(b=b.split(" ");f=b[l++];){r=f;k=f.indexOf(".")<0;o=[];if(!k){o=f.split(".");f=o.shift();x=RegExp("(^|\\.)"+
c.map(o.slice(0).sort(),Ya).join("\\.(?:.*\\.)?")+"(\\.|$)")}if(A=I[f])if(d){r=c.event.special[f]||{};for(h=e||0;h<A.length;h++){C=A[h];if(d.guid===C.guid){if(k||x.test(C.namespace)){e==null&&A.splice(h--,1);r.remove&&r.remove.call(a,C)}if(e!=null)break}}if(A.length===0||e!=null&&A.length===1){if(!r.teardown||r.teardown.call(a,o)===false)c.removeEvent(a,f,w.handle);delete I[f]}}else for(h=0;h<A.length;h++){C=A[h];if(k||x.test(C.namespace)){c.event.remove(a,r,C.handler,h);A.splice(h--,1)}}}if(c.isEmptyObject(I)){if(b=w.handle)b.elem=null;delete w.events;delete w.handle;if(typeof w==="function")c.removeData(a,J);else c.isEmptyObject(w)&&c.removeData(a)}}}}},trigger:function(a,b,d,e){var f=a.type||a;if(!e){a=typeof a==="object"?a[c.expando]?a:c.extend(c.Event(f),a):c.Event(f);if(f.indexOf("!")>=0){a.type=f=f.slice(0,-1);a.exclusive=true}if(!d){a.stopPropagation();c.event.global[f]&&c.each(c.cache,function(){this.events&&this.events[f]&&c.event.trigger(a,b,this.handle.elem)})}if(!d||d.nodeType===3||d.nodeType===8)return B;a.result=B;a.target=d;b=c.makeArray(b);b.unshift(a)}a.currentTarget=d;(e=d.nodeType?c.data(d,"handle"):(c.data(d,"__events__")||{}).handle)&&e.apply(d,b);e=d.parentNode||d.ownerDocument;try{if(!(d&&d.nodeName&&c.noData[d.nodeName.toLowerCase()]))if(d["on"+f]&&d["on"+f].apply(d,b)===false){a.result=false;a.preventDefault()}}catch(h){}if(!a.isPropagationStopped()&&e)c.event.trigger(a,b,e,true);else if(!a.isDefaultPrevented()){var l;e=a.target;var k=f.replace(X,""),o=c.nodeName(e,"a")&&k==="click",x=c.event.special[k]||{};if((!x._default||x._default.call(d,a)===false)&&!o&&!(e&&e.nodeName&&c.noData[e.nodeName.toLowerCase()])){try{if(e[k]){if(l=e["on"+k])e["on"+k]=null;c.event.triggered=true;e[k]()}}catch(r){}if(l)e["on"+k]=l;c.event.triggered=false}}},handle:function(a){var b,d,e,f;d=[];var h=c.makeArray(arguments);a=h[0]=c.event.fix(a||E.event);a.currentTarget=this;b=a.type.indexOf(".")<0&&!a.exclusive;if(!b){e=a.type.split(".");a.type=e.shift();d=e.slice(0).sort();e=RegExp("(^|\\.)"+
d.join("\\.(?:.*\\.)?")+"(\\.|$)")}a.namespace=a.namespace||d.join(".");f=c.data(this,this.nodeType?"events":"__events__");if(typeof f==="function")f=f.events;d=(f||{})[a.type];if(f&&d){d=d.slice(0);f=0;for(var l=d.length;f<l;f++){var k=d[f];if(b||e.test(k.namespace)){a.handler=k.handler;a.data=k.data;a.handleObj=k;k=k.handler.apply(this,h);if(k!==B){a.result=k;if(k===false){a.preventDefault();a.stopPropagation()}}if(a.isImmediatePropagationStopped())break}}}return a.result},props:"altKey attrChange attrName bubbles button cancelable charCode clientX clientY ctrlKey currentTarget data detail eventPhase fromElement handler keyCode layerX layerY metaKey newValue offsetX offsetY pageX pageY prevValue relatedNode relatedTarget screenX screenY shiftKey srcElement target toElement view wheelDelta which".split(" "),fix:function(a){if(a[c.expando])return a;var b=a;a=c.Event(b);for(var d=this.props.length,e;d;){e=this.props[--d];a[e]=b[e]}if(!a.target)a.target=a.srcElement||t;if(a.target.nodeType===3)a.target=a.target.parentNode;if(!a.relatedTarget&&a.fromElement)a.relatedTarget=a.fromElement===a.target?a.toElement:a.fromElement;if(a.pageX==null&&a.clientX!=null){b=t.documentElement;d=t.body;a.pageX=a.clientX+(b&&b.scrollLeft||d&&d.scrollLeft||0)-(b&&b.clientLeft||d&&d.clientLeft||0);a.pageY=a.clientY+(b&&b.scrollTop||d&&d.scrollTop||0)-(b&&b.clientTop||d&&d.clientTop||0)}if(a.which==null&&(a.charCode!=null||a.keyCode!=null))a.which=a.charCode!=null?a.charCode:a.keyCode;if(!a.metaKey&&a.ctrlKey)a.metaKey=a.ctrlKey;if(!a.which&&a.button!==B)a.which=a.button&1?1:a.button&2?3:a.button&4?2:0;return a},guid:1E8,proxy:c.proxy,special:{ready:{setup:c.bindReady,teardown:c.noop},live:{add:function(a){c.event.add(this,Y(a.origType,a.selector),c.extend({},a,{handler:Ka,guid:a.handler.guid}))},remove:function(a){c.event.remove(this,Y(a.origType,a.selector),a)}},beforeunload:{setup:function(a,b,d){if(c.isWindow(this))this.onbeforeunload=d},teardown:function(a,b){if(this.onbeforeunload===b)this.onbeforeunload=null}}}};c.removeEvent=t.removeEventListener?function(a,b,d){a.removeEventListener&&a.removeEventListener(b,d,false)}:function(a,b,d){a.detachEvent&&a.detachEvent("on"+b,d)};c.Event=function(a){if(!this.preventDefault)return new c.Event(a);if(a&&a.type){this.originalEvent=a;this.type=a.type}else this.type=a;this.timeStamp=c.now();this[c.expando]=true};c.Event.prototype={preventDefault:function(){this.isDefaultPrevented=ca;var a=this.originalEvent;if(a)if(a.preventDefault)a.preventDefault();else a.returnValue=false},stopPropagation:function(){this.isPropagationStopped=ca;var a=this.originalEvent;if(a){a.stopPropagation&&a.stopPropagation();a.cancelBubble=true}},stopImmediatePropagation:function(){this.isImmediatePropagationStopped=ca;this.stopPropagation()},isDefaultPrevented:U,isPropagationStopped:U,isImmediatePropagationStopped:U};var va=function(a){var b=a.relatedTarget;try{for(;b&&b!==this;)b=b.parentNode;if(b!==this){a.type=a.data;c.event.handle.apply(this,arguments)}}catch(d){}},wa=function(a){a.type=a.data;c.event.handle.apply(this,arguments)};c.each({mouseenter:"mouseover",mouseleave:"mouseout"},function(a,b){c.event.special[a]={setup:function(d){c.event.add(this,b,d&&d.selector?wa:va,a)},teardown:function(d){c.event.remove(this,b,d&&d.selector?wa:va)}}});if(!c.support.submitBubbles)c.event.special.submit={setup:function(){if(this.nodeName.toLowerCase()!=="form"){c.event.add(this,"click.specialSubmit",function(a){var b=a.target,d=b.type;if((d==="submit"||d==="image")&&c(b).closest("form").length){a.liveFired=B;return la("submit",this,arguments)}});c.event.add(this,"keypress.specialSubmit",function(a){var b=a.target,d=b.type;if((d==="text"||d==="password")&&c(b).closest("form").length&&a.keyCode===13){a.liveFired=B;return la("submit",this,arguments)}})}else return false},teardown:function(){c.event.remove(this,".specialSubmit")}};if(!c.support.changeBubbles){var V,xa=function(a){var b=a.type,d=a.value;if(b==="radio"||b==="checkbox")d=a.checked;else if(b==="select-multiple")d=a.selectedIndex>-1?c.map(a.options,function(e){return e.selected}).join("-"):"";else if(a.nodeName.toLowerCase()==="select")d=a.selectedIndex;return d},Z=function(a,b){var d=a.target,e,f;if(!(!ia.test(d.nodeName)||d.readOnly)){e=c.data(d,"_change_data");f=xa(d);if(a.type!=="focusout"||d.type!=="radio")c.data(d,"_change_data",f);if(!(e===B||f===e))if(e!=null||f){a.type="change";a.liveFired=B;return c.event.trigger(a,b,d)}}};c.event.special.change={filters:{focusout:Z,beforedeactivate:Z,click:function(a){var b=a.target,d=b.type;if(d==="radio"||d==="checkbox"||b.nodeName.toLowerCase()==="select")return Z.call(this,a)},keydown:function(a){var b=a.target,d=b.type;if(a.keyCode===13&&b.nodeName.toLowerCase()!=="textarea"||a.keyCode===32&&(d==="checkbox"||d==="radio")||d==="select-multiple")return Z.call(this,a)},beforeactivate:function(a){a=a.target;c.data(a,"_change_data",xa(a))}},setup:function(){if(this.type==="file")return false;for(var a in V)c.event.add(this,a+".specialChange",V[a]);return ia.test(this.nodeName)},teardown:function(){c.event.remove(this,".specialChange");return ia.test(this.nodeName)}};V=c.event.special.change.filters;V.focus=V.beforeactivate}t.addEventListener&&c.each({focus:"focusin",blur:"focusout"},function(a,b){function d(e){e=c.event.fix(e);e.type=b;return c.event.trigger(e,null,e.target)}c.event.special[b]={setup:function(){ua[b]++===0&&t.addEventListener(a,d,true)},teardown:function(){--ua[b]===0&&t.removeEventListener(a,d,true)}}});c.each(["bind","one"],function(a,b){c.fn[b]=function(d,e,f){if(typeof d==="object"){for(var h in d)this[b](h,e,d[h],f);return this}if(c.isFunction(e)||e===false){f=e;e=B}var l=b==="one"?c.proxy(f,function(o){c(this).unbind(o,l);return f.apply(this,arguments)}):f;if(d==="unload"&&b!=="one")this.one(d,e,f);else{h=0;for(var k=this.length;h<k;h++)c.event.add(this[h],d,l,e)}return this}});c.fn.extend({unbind:function(a,b){if(typeof a==="object"&&!a.preventDefault)for(var d in a)this.unbind(d,a[d]);else{d=0;for(var e=this.length;d<e;d++)c.event.remove(this[d],a,b)}return this},delegate:function(a,b,d,e){return this.live(b,d,e,a)},undelegate:function(a,b,d){return arguments.length===0?this.unbind("live"):this.die(b,null,d,a)},trigger:function(a,b){return this.each(function(){c.event.trigger(a,b,this)})},triggerHandler:function(a,b){if(this[0]){var d=c.Event(a);d.preventDefault();d.stopPropagation();c.event.trigger(d,b,this[0]);return d.result}},toggle:function(a){for(var b=arguments,d=1;d<b.length;)c.proxy(a,b[d++]);return this.click(c.proxy(a,function(e){var f=(c.data(this,"lastToggle"+a.guid)||0)%d;c.data(this,"lastToggle"+a.guid,f+1);e.preventDefault();return b[f].apply(this,arguments)||false}))},hover:function(a,b){return this.mouseenter(a).mouseleave(b||a)}});var ya={focus:"focusin",blur:"focusout",mouseenter:"mouseover",mouseleave:"mouseout"};c.each(["live","die"],function(a,b){c.fn[b]=function(d,e,f,h){var l,k=0,o,x,r=h||this.selector;h=h?this:c(this.context);if(typeof d==="object"&&!d.preventDefault){for(l in d)h[b](l,e,d[l],r);return this}if(c.isFunction(e)){f=e;e=B}for(d=(d||"").split(" ");(l=d[k++])!=null;){o=X.exec(l);x="";if(o){x=o[0];l=l.replace(X,"")}if(l==="hover")d.push("mouseenter"+x,"mouseleave"+x);else{o=l;if(l==="focus"||l==="blur"){d.push(ya[l]+x);l+=x}else l=(ya[l]||l)+x;if(b==="live"){x=0;for(var A=h.length;x<A;x++)c.event.add(h[x],"live."+Y(l,r),{data:e,selector:r,handler:f,origType:l,origHandler:f,preType:o})}else h.unbind("live."+Y(l,r),f)}}return this}});c.each("blur focus focusin focusout load resize scroll unload click dblclick mousedown mouseup mousemove mouseover mouseout mouseenter mouseleave change select submit keydown keypress keyup error".split(" "),function(a,b){c.fn[b]=function(d,e){if(e==null){e=d;d=null}return arguments.length>0?this.bind(b,d,e):this.trigger(b)};if(c.attrFn)c.attrFn[b]=true});E.attachEvent&&!E.addEventListener&&c(E).bind("unload",function(){for(var a in c.cache)if(c.cache[a].handle)try{c.event.remove(c.cache[a].handle.elem)}catch(b){}});(function(){function a(g,i,n,m,p,q){p=0;for(var u=m.length;p<u;p++){var y=m[p];if(y){var F=false;for(y=y[g];y;){if(y.sizcache===n){F=m[y.sizset];break}if(y.nodeType===1&&!q){y.sizcache=n;y.sizset=p}if(y.nodeName.toLowerCase()===i){F=y;break}y=y[g]}m[p]=F}}}function b(g,i,n,m,p,q){p=0;for(var u=m.length;p<u;p++){var y=m[p];if(y){var F=false;for(y=y[g];y;){if(y.sizcache===n){F=m[y.sizset];break}if(y.nodeType===1){if(!q){y.sizcache=n;y.sizset=p}if(typeof i!=="string"){if(y===i){F=true;break}}else if(k.filter(i,[y]).length>0){F=y;break}}y=y[g]}m[p]=F}}}var d=/((?:\((?:\([^()]+\)|[^()]+)+\)|\[(?:\[[^\[\]]*\]|['"][^'"]*['"]|[^\[\]'"]+)+\]|\\.|[^ >+~,(\[\\]+)+|[>+~])(\s*,\s*)?((?:.|\r|\n)*)/g,e=0,f=Object.prototype.toString,h=false,l=true;[0,0].sort(function(){l=false;return 0});var k=function(g,i,n,m){n=n||[];var p=i=i||t;if(i.nodeType!==1&&i.nodeType!==9)return[];if(!g||typeof g!=="string")return n;var q,u,y,F,M,N=true,O=k.isXML(i),D=[],R=g;do{d.exec("");if(q=d.exec(R)){R=q[3];D.push(q[1]);if(q[2]){F=q[3];break}}}while(q);if(D.length>1&&x.exec(g))if(D.length===2&&o.relative[D[0]])u=L(D[0]+D[1],i);else for(u=o.relative[D[0]]?[i]:k(D.shift(),i);D.length;){g=D.shift();if(o.relative[g])g+=D.shift();u=L(g,u)}else{if(!m&&D.length>1&&i.nodeType===9&&!O&&o.match.ID.test(D[0])&&!o.match.ID.test(D[D.length-1])){q=k.find(D.shift(),i,O);i=q.expr?k.filter(q.expr,q.set)[0]:q.set[0]}if(i){q=m?{expr:D.pop(),set:C(m)}:k.find(D.pop(),D.length===1&&(D[0]==="~"||D[0]==="+")&&i.parentNode?i.parentNode:i,O);u=q.expr?k.filter(q.expr,q.set):q.set;if(D.length>0)y=C(u);else N=false;for(;D.length;){q=M=D.pop();if(o.relative[M])q=D.pop();else M="";if(q==null)q=i;o.relative[M](y,q,O)}}else y=[]}y||(y=u);y||k.error(M||g);if(f.call(y)==="[object Array]")if(N)if(i&&i.nodeType===1)for(g=0;y[g]!=null;g++){if(y[g]&&(y[g]===true||y[g].nodeType===1&&k.contains(i,y[g])))n.push(u[g])}else for(g=0;y[g]!=null;g++)y[g]&&y[g].nodeType===1&&n.push(u[g]);else n.push.apply(n,y);else C(y,n);if(F){k(F,p,n,m);k.uniqueSort(n)}return n};k.uniqueSort=function(g){if(w){h=l;g.sort(w);if(h)for(var i=1;i<g.length;i++)g[i]===g[i-1]&&g.splice(i--,1)}return g};k.matches=function(g,i){return k(g,null,null,i)};k.matchesSelector=function(g,i){return k(i,null,null,[g]).length>0};k.find=function(g,i,n){var m;if(!g)return[];for(var p=0,q=o.order.length;p<q;p++){var u,y=o.order[p];if(u=o.leftMatch[y].exec(g)){var F=u[1];u.splice(1,1);if(F.substr(F.length-1)!=="\\"){u[1]=(u[1]||"").replace(/\\/g,"");m=o.find[y](u,i,n);if(m!=null){g=g.replace(o.match[y],"");break}}}}m||(m=i.getElementsByTagName("*"));return{set:m,expr:g}};k.filter=function(g,i,n,m){for(var p,q,u=g,y=[],F=i,M=i&&i[0]&&k.isXML(i[0]);g&&i.length;){for(var N in o.filter)if((p=o.leftMatch[N].exec(g))!=null&&p[2]){var O,D,R=o.filter[N];D=p[1];q=false;p.splice(1,1);if(D.substr(D.length-1)!=="\\"){if(F===y)y=[];if(o.preFilter[N])if(p=o.preFilter[N](p,F,n,y,m,M)){if(p===true)continue}else q=O=true;if(p)for(var j=0;(D=F[j])!=null;j++)if(D){O=R(D,p,j,F);var s=m^!!O;if(n&&O!=null)if(s)q=true;else F[j]=false;else if(s){y.push(D);q=true}}if(O!==B){n||(F=y);g=g.replace(o.match[N],"");if(!q)return[];break}}}if(g===u)if(q==null)k.error(g);else break;u=g}return F};k.error=function(g){throw"Syntax error, unrecognized expression: "+g;};var o=k.selectors={order:["ID","NAME","TAG"],match:{ID:/#((?:[\w\u00c0-\uFFFF\-]|\\.)+)/,CLASS:/\.((?:[\w\u00c0-\uFFFF\-]|\\.)+)/,NAME:/\[name=['"]*((?:[\w\u00c0-\uFFFF\-]|\\.)+)['"]*\]/,ATTR:/\[\s*((?:[\w\u00c0-\uFFFF\-]|\\.)+)\s*(?:(\S?=)\s*(['"]*)(.*?)\3|)\s*\]/,TAG:/^((?:[\w\u00c0-\uFFFF\*\-]|\\.)+)/,CHILD:/:(only|nth|last|first)-child(?:\((even|odd|[\dn+\-]*)\))?/,POS:/:(nth|eq|gt|lt|first|last|even|odd)(?:\((\d*)\))?(?=[^\-]|$)/,PSEUDO:/:((?:[\w\u00c0-\uFFFF\-]|\\.)+)(?:\((['"]?)((?:\([^\)]+\)|[^\(\)]*)+)\2\))?/},leftMatch:{},attrMap:{"class":"className","for":"htmlFor"},attrHandle:{href:function(g){return g.getAttribute("href")}},relative:{"+":function(g,i){var n=typeof i==="string",m=n&&!/\W/.test(i);n=n&&!m;if(m)i=i.toLowerCase();m=0;for(var p=g.length,q;m<p;m++)if(q=g[m]){for(;(q=q.previousSibling)&&q.nodeType!==1;);g[m]=n||q&&q.nodeName.toLowerCase()===i?q||false:q===i}n&&k.filter(i,g,true)},">":function(g,i){var n,m=typeof i==="string",p=0,q=g.length;if(m&&!/\W/.test(i))for(i=i.toLowerCase();p<q;p++){if(n=g[p]){n=n.parentNode;g[p]=n.nodeName.toLowerCase()===i?n:false}}else{for(;p<q;p++)if(n=g[p])g[p]=m?n.parentNode:n.parentNode===i;m&&k.filter(i,g,true)}},"":function(g,i,n){var m,p=e++,q=b;if(typeof i==="string"&&!/\W/.test(i)){m=i=i.toLowerCase();q=a}q("parentNode",i,p,g,m,n)},"~":function(g,i,n){var m,p=e++,q=b;if(typeof i==="string"&&!/\W/.test(i)){m=i=i.toLowerCase();q=a}q("previousSibling",i,p,g,m,n)}},find:{ID:function(g,i,n){if(typeof i.getElementById!=="undefined"&&!n)return(g=i.getElementById(g[1]))&&g.parentNode?[g]:[]},NAME:function(g,i){if(typeof i.getElementsByName!=="undefined"){for(var n=[],m=i.getElementsByName(g[1]),p=0,q=m.length;p<q;p++)m[p].getAttribute("name")===g[1]&&n.push(m[p]);return n.length===0?null:n}},TAG:function(g,i){return i.getElementsByTagName(g[1])}},preFilter:{CLASS:function(g,i,n,m,p,q){g=" "+g[1].replace(/\\/g,"")+" ";if(q)return g;q=0;for(var u;(u=i[q])!=null;q++)if(u)if(p^(u.className&&(" "+u.className+" ").replace(/[\t\n]/g," ").indexOf(g)>=0))n||m.push(u);else if(n)i[q]=false;return false},ID:function(g){return g[1].replace(/\\/g,"")},TAG:function(g){return g[1].toLowerCase()},CHILD:function(g){if(g[1]==="nth"){var i=/(-?)(\d*)n((?:\+|-)?\d*)/.exec(g[2]==="even"&&"2n"||g[2]==="odd"&&"2n+1"||!/\D/.test(g[2])&&"0n+"+g[2]||g[2]);g[2]=i[1]+(i[2]||1)-0;g[3]=i[3]-0}g[0]=e++;return g},ATTR:function(g,i,n,m,p,q){i=g[1].replace(/\\/g,"");if(!q&&o.attrMap[i])g[1]=o.attrMap[i];if(g[2]==="~=")g[4]=" "+g[4]+" ";return g},PSEUDO:function(g,i,n,m,p){if(g[1]==="not")if((d.exec(g[3])||"").length>1||/^\w/.test(g[3]))g[3]=k(g[3],null,null,i);else{g=k.filter(g[3],i,n,true^p);n||m.push.apply(m,g);return false}else if(o.match.POS.test(g[0])||o.match.CHILD.test(g[0]))return true;return g},POS:function(g){g.unshift(true);return g}},filters:{enabled:function(g){return g.disabled===false&&g.type!=="hidden"},disabled:function(g){return g.disabled===true},checked:function(g){return g.checked===true},selected:function(g){return g.selected===true},parent:function(g){return!!g.firstChild},empty:function(g){return!g.firstChild},has:function(g,i,n){return!!k(n[3],g).length},header:function(g){return/h\d/i.test(g.nodeName)},text:function(g){return"text"===g.type},radio:function(g){return"radio"===g.type},checkbox:function(g){return"checkbox"===g.type},file:function(g){return"file"===g.type},password:function(g){return"password"===g.type},submit:function(g){return"submit"===g.type},image:function(g){return"image"===g.type},reset:function(g){return"reset"===g.type},button:function(g){return"button"===g.type||g.nodeName.toLowerCase()==="button"},input:function(g){return/input|select|textarea|button/i.test(g.nodeName)}},setFilters:{first:function(g,i){return i===0},last:function(g,i,n,m){return i===m.length-1},even:function(g,i){return i%2===0},odd:function(g,i){return i%2===1},lt:function(g,i,n){return i<n[3]-0},gt:function(g,i,n){return i>n[3]-0},nth:function(g,i,n){return n[3]-
0===i},eq:function(g,i,n){return n[3]-0===i}},filter:{PSEUDO:function(g,i,n,m){var p=i[1],q=o.filters[p];if(q)return q(g,n,i,m);else if(p==="contains")return(g.textContent||g.innerText||k.getText([g])||"").indexOf(i[3])>=0;else if(p==="not"){i=i[3];n=0;for(m=i.length;n<m;n++)if(i[n]===g)return false;return true}else k.error("Syntax error, unrecognized expression: "+p)},CHILD:function(g,i){var n=i[1],m=g;switch(n){case"only":case"first":for(;m=m.previousSibling;)if(m.nodeType===1)return false;if(n==="first")return true;m=g;case"last":for(;m=m.nextSibling;)if(m.nodeType===1)return false;return true;case"nth":n=i[2];var p=i[3];if(n===1&&p===0)return true;var q=i[0],u=g.parentNode;if(u&&(u.sizcache!==q||!g.nodeIndex)){var y=0;for(m=u.firstChild;m;m=m.nextSibling)if(m.nodeType===1)m.nodeIndex=++y;u.sizcache=q}m=g.nodeIndex-p;return n===0?m===0:m%n===0&&m/n>=0}},ID:function(g,i){return g.nodeType===1&&g.getAttribute("id")===i},TAG:function(g,i){return i==="*"&&g.nodeType===1||g.nodeName.toLowerCase()===i},CLASS:function(g,i){return(" "+(g.className||g.getAttribute("class"))+" ").indexOf(i)>-1},ATTR:function(g,i){var n=i[1];n=o.attrHandle[n]?o.attrHandle[n](g):g[n]!=null?g[n]:g.getAttribute(n);var m=n+"",p=i[2],q=i[4];return n==null?p==="!=":p==="="?m===q:p==="*="?m.indexOf(q)>=0:p==="~="?(" "+m+" ").indexOf(q)>=0:!q?m&&n!==false:p==="!="?m!==q:p==="^="?m.indexOf(q)===0:p==="$="?m.substr(m.length-q.length)===q:p==="|="?m===q||m.substr(0,q.length+1)===q+"-":false},POS:function(g,i,n,m){var p=o.setFilters[i[2]];if(p)return p(g,n,i,m)}}},x=o.match.POS,r=function(g,i){return"\\"+(i-0+1)},A;for(A in o.match){o.match[A]=RegExp(o.match[A].source+/(?![^\[]*\])(?![^\(]*\))/.source);o.leftMatch[A]=RegExp(/(^(?:.|\r|\n)*?)/.source+o.match[A].source.replace(/\\(\d+)/g,r))}var C=function(g,i){g=Array.prototype.slice.call(g,0);if(i){i.push.apply(i,g);return i}return g};try{Array.prototype.slice.call(t.documentElement.childNodes,0)}catch(J){C=function(g,i){var n=0,m=i||[];if(f.call(g)==="[object Array]")Array.prototype.push.apply(m,g);else if(typeof g.length==="number")for(var p=g.length;n<p;n++)m.push(g[n]);else for(;g[n];n++)m.push(g[n]);return m}}var w,I;if(t.documentElement.compareDocumentPosition)w=function(g,i){if(g===i){h=true;return 0}if(!g.compareDocumentPosition||!i.compareDocumentPosition)return g.compareDocumentPosition?-1:1;return g.compareDocumentPosition(i)&4?-1:1};else{w=function(g,i){var n,m,p=[],q=[];n=g.parentNode;m=i.parentNode;var u=n;if(g===i){h=true;return 0}else if(n===m)return I(g,i);else if(n){if(!m)return 1}else return-1;for(;u;){p.unshift(u);u=u.parentNode}for(u=m;u;){q.unshift(u);u=u.parentNode}n=p.length;m=q.length;for(u=0;u<n&&u<m;u++)if(p[u]!==q[u])return I(p[u],q[u]);return u===n?I(g,q[u],-1):I(p[u],i,1)};I=function(g,i,n){if(g===i)return n;for(g=g.nextSibling;g;){if(g===i)return-1;g=g.nextSibling}return 1}}k.getText=function(g){for(var i="",n,m=0;g[m];m++){n=g[m];if(n.nodeType===3||n.nodeType===4)i+=n.nodeValue;else if(n.nodeType!==8)i+=k.getText(n.childNodes)}return i};(function(){var g=t.createElement("div"),i="script"+(new Date).getTime(),n=t.documentElement;g.innerHTML="<a name='"+i+"'/>";n.insertBefore(g,n.firstChild);if(t.getElementById(i)){o.find.ID=function(m,p,q){if(typeof p.getElementById!=="undefined"&&!q)return(p=p.getElementById(m[1]))?p.id===m[1]||typeof p.getAttributeNode!=="undefined"&&p.getAttributeNode("id").nodeValue===m[1]?[p]:B:[]};o.filter.ID=function(m,p){var q=typeof m.getAttributeNode!=="undefined"&&m.getAttributeNode("id");return m.nodeType===1&&q&&q.nodeValue===p}}n.removeChild(g);n=g=null})();(function(){var g=t.createElement("div");g.appendChild(t.createComment(""));if(g.getElementsByTagName("*").length>0)o.find.TAG=function(i,n){var m=n.getElementsByTagName(i[1]);if(i[1]==="*"){for(var p=[],q=0;m[q];q++)m[q].nodeType===1&&p.push(m[q]);m=p}return m};g.innerHTML="<a href='#'></a>";if(g.firstChild&&typeof g.firstChild.getAttribute!=="undefined"&&g.firstChild.getAttribute("href")!=="#")o.attrHandle.href=function(i){return i.getAttribute("href",2)};g=null})();t.querySelectorAll&&function(){var g=k,i=t.createElement("div");i.innerHTML="<p class='TEST'></p>";if(!(i.querySelectorAll&&i.querySelectorAll(".TEST").length===0)){k=function(m,p,q,u){p=p||t;m=m.replace(/\=\s*([^'"\]]*)\s*\]/g,"='$1']");if(!u&&!k.isXML(p))if(p.nodeType===9)try{return C(p.querySelectorAll(m),q)}catch(y){}else if(p.nodeType===1&&p.nodeName.toLowerCase()!=="object"){var F=p.getAttribute("id"),M=F||"__sizzle__";F||p.setAttribute("id",M);try{return C(p.querySelectorAll("#"+M+" "+m),q)}catch(N){}finally{F||p.removeAttribute("id")}}return g(m,p,q,u)};for(var n in g)k[n]=g[n];i=null}}();(function(){var g=t.documentElement,i=g.matchesSelector||g.mozMatchesSelector||g.webkitMatchesSelector||g.msMatchesSelector,n=false;try{i.call(t.documentElement,"[test!='']:sizzle")}catch(m){n=true}if(i)k.matchesSelector=function(p,q){q=q.replace(/\=\s*([^'"\]]*)\s*\]/g,"='$1']");if(!k.isXML(p))try{if(n||!o.match.PSEUDO.test(q)&&!/!=/.test(q))return i.call(p,q)}catch(u){}return k(q,null,null,[p]).length>0}})();(function(){var g=t.createElement("div");g.innerHTML="<div class='test e'></div><div class='test'></div>";if(!(!g.getElementsByClassName||g.getElementsByClassName("e").length===0)){g.lastChild.className="e";if(g.getElementsByClassName("e").length!==1){o.order.splice(1,0,"CLASS");o.find.CLASS=function(i,n,m){if(typeof n.getElementsByClassName!=="undefined"&&!m)return n.getElementsByClassName(i[1])};g=null}}})();k.contains=t.documentElement.contains?function(g,i){return g!==i&&(g.contains?g.contains(i):true)}:t.documentElement.compareDocumentPosition?function(g,i){return!!(g.compareDocumentPosition(i)&16)}:function(){return false};k.isXML=function(g){return(g=(g?g.ownerDocument||g:0).documentElement)?g.nodeName!=="HTML":false};var L=function(g,i){for(var n,m=[],p="",q=i.nodeType?[i]:i;n=o.match.PSEUDO.exec(g);){p+=n[0];g=g.replace(o.match.PSEUDO,"")}g=o.relative[g]?g+"*":g;n=0;for(var u=q.length;n<u;n++)k(g,q[n],m);return k.filter(p,m)};c.find=k;c.expr=k.selectors;c.expr[":"]=c.expr.filters;c.unique=k.uniqueSort;c.text=k.getText;c.isXMLDoc=k.isXML;c.contains=k.contains})();var Za=/Until$/,$a=/^(?:parents|prevUntil|prevAll)/,ab=/,/,Na=/^.[^:#\[\.,]*$/,bb=Array.prototype.slice,cb=c.expr.match.POS;c.fn.extend({find:function(a){for(var b=this.pushStack("","find",a),d=0,e=0,f=this.length;e<f;e++){d=b.length;c.find(a,this[e],b);if(e>0)for(var h=d;h<b.length;h++)for(var l=0;l<d;l++)if(b[l]===b[h]){b.splice(h--,1);break}}return b},has:function(a){var b=c(a);return this.filter(function(){for(var d=0,e=b.length;d<e;d++)if(c.contains(this,b[d]))return true})},not:function(a){return this.pushStack(ma(this,a,false),"not",a)},filter:function(a){return this.pushStack(ma(this,a,true),"filter",a)},is:function(a){return!!a&&c.filter(a,this).length>0},closest:function(a,b){var d=[],e,f,h=this[0];if(c.isArray(a)){var l,k={},o=1;if(h&&a.length){e=0;for(f=a.length;e<f;e++){l=a[e];k[l]||(k[l]=c.expr.match.POS.test(l)?c(l,b||this.context):l)}for(;h&&h.ownerDocument&&h!==b;){for(l in k){e=k[l];if(e.jquery?e.index(h)>-1:c(h).is(e))d.push({selector:l,elem:h,level:o})}h=h.parentNode;o++}}return d}l=cb.test(a)?c(a,b||this.context):null;e=0;for(f=this.length;e<f;e++)for(h=this[e];h;)if(l?l.index(h)>-1:c.find.matchesSelector(h,a)){d.push(h);break}else{h=h.parentNode;if(!h||!h.ownerDocument||h===b)break}d=d.length>1?c.unique(d):d;return this.pushStack(d,"closest",a)},index:function(a){if(!a||typeof a==="string")return c.inArray(this[0],a?c(a):this.parent().children());return c.inArray(a.jquery?a[0]:a,this)},add:function(a,b){var d=typeof a==="string"?c(a,b||this.context):c.makeArray(a),e=c.merge(this.get(),d);return this.pushStack(!d[0]||!d[0].parentNode||d[0].parentNode.nodeType===11||!e[0]||!e[0].parentNode||e[0].parentNode.nodeType===11?e:c.unique(e))},andSelf:function(){return this.add(this.prevObject)}});c.each({parent:function(a){return(a=a.parentNode)&&a.nodeType!==11?a:null},parents:function(a){return c.dir(a,"parentNode")},parentsUntil:function(a,b,d){return c.dir(a,"parentNode",d)},next:function(a){return c.nth(a,2,"nextSibling")},prev:function(a){return c.nth(a,2,"previousSibling")},nextAll:function(a){return c.dir(a,"nextSibling")},prevAll:function(a){return c.dir(a,"previousSibling")},nextUntil:function(a,b,d){return c.dir(a,"nextSibling",d)},prevUntil:function(a,b,d){return c.dir(a,"previousSibling",d)},siblings:function(a){return c.sibling(a.parentNode.firstChild,a)},children:function(a){return c.sibling(a.firstChild)},contents:function(a){return c.nodeName(a,"iframe")?a.contentDocument||a.contentWindow.document:c.makeArray(a.childNodes)}},function(a,b){c.fn[a]=function(d,e){var f=c.map(this,b,d);Za.test(a)||(e=d);if(e&&typeof e==="string")f=c.filter(e,f);f=this.length>1?c.unique(f):f;if((this.length>1||ab.test(e))&&$a.test(a))f=f.reverse();return this.pushStack(f,a,bb.call(arguments).join(","))}});c.extend({filter:function(a,b,d){if(d)a=":not("+a+")";return b.length===1?c.find.matchesSelector(b[0],a)?[b[0]]:[]:c.find.matches(a,b)},dir:function(a,b,d){var e=[];for(a=a[b];a&&a.nodeType!==9&&(d===B||a.nodeType!==1||!c(a).is(d));){a.nodeType===1&&e.push(a);a=a[b]}return e},nth:function(a,b,d){b=b||1;for(var e=0;a;a=a[d])if(a.nodeType===1&&++e===b)break;return a},sibling:function(a,b){for(var d=[];a;a=a.nextSibling)a.nodeType===1&&a!==b&&d.push(a);return d}});var za=/ jQuery\d+="(?:\d+|null)"/g,$=/^\s+/,Aa=/<(?!area|br|col|embed|hr|img|input|link|meta|param)(([\w:]+)[^>]*)\/>/ig,Ba=/<([\w:]+)/,db=/<tbody/i,eb=/<|&#?\w+;/,Ca=/<(?:script|object|embed|option|style)/i,Da=/checked\s*(?:[^=]|=\s*.checked.)/i,fb=/\=([^="'>\s]+\/)>/g,P={option:[1,"<select multiple='multiple'>","</select>"],legend:[1,"<fieldset>","</fieldset>"],thead:[1,"<table>","</table>"],tr:[2,"<table><tbody>","</tbody></table>"],td:[3,"<table><tbody><tr>","</tr></tbody></table>"],col:[2,"<table><tbody></tbody><colgroup>","</colgroup></table>"],area:[1,"<map>","</map>"],_default:[0,"",""]};P.optgroup=P.option;P.tbody=P.tfoot=P.colgroup=P.caption=P.thead;P.th=P.td;if(!c.support.htmlSerialize)P._default=[1,"div<div>","</div>"];c.fn.extend({text:function(a){if(c.isFunction(a))return this.each(function(b){var d=c(this);d.text(a.call(this,b,d.text()))});if(typeof a!=="object"&&a!==B)return this.empty().append((this[0]&&this[0].ownerDocument||t).createTextNode(a));return c.text(this)},wrapAll:function(a){if(c.isFunction(a))return this.each(function(d){c(this).wrapAll(a.call(this,d))});if(this[0]){var b=c(a,this[0].ownerDocument).eq(0).clone(true);this[0].parentNode&&b.insertBefore(this[0]);b.map(function(){for(var d=this;d.firstChild&&d.firstChild.nodeType===1;)d=d.firstChild;return d}).append(this)}return this},wrapInner:function(a){if(c.isFunction(a))return this.each(function(b){c(this).wrapInner(a.call(this,b))});return this.each(function(){var b=c(this),d=b.contents();d.length?d.wrapAll(a):b.append(a)})},wrap:function(a){return this.each(function(){c(this).wrapAll(a)})},unwrap:function(){return this.parent().each(function(){c.nodeName(this,"body")||c(this).replaceWith(this.childNodes)}).end()},append:function(){return this.domManip(arguments,true,function(a){this.nodeType===1&&this.appendChild(a)})},prepend:function(){return this.domManip(arguments,true,function(a){this.nodeType===1&&this.insertBefore(a,this.firstChild)})},before:function(){if(this[0]&&this[0].parentNode)return this.domManip(arguments,false,function(b){this.parentNode.insertBefore(b,this)});else if(arguments.length){var a=c(arguments[0]);a.push.apply(a,this.toArray());return this.pushStack(a,"before",arguments)}},after:function(){if(this[0]&&this[0].parentNode)return this.domManip(arguments,false,function(b){this.parentNode.insertBefore(b,this.nextSibling)});else if(arguments.length){var a=this.pushStack(this,"after",arguments);a.push.apply(a,c(arguments[0]).toArray());return a}},remove:function(a,b){for(var d=0,e;(e=this[d])!=null;d++)if(!a||c.filter(a,[e]).length){if(!b&&e.nodeType===1){c.cleanData(e.getElementsByTagName("*"));c.cleanData([e])}e.parentNode&&e.parentNode.removeChild(e)}return this},empty:function(){for(var a=0,b;(b=this[a])!=null;a++)for(b.nodeType===1&&c.cleanData(b.getElementsByTagName("*"));b.firstChild;)b.removeChild(b.firstChild);return this},clone:function(a){var b=this.map(function(){if(!c.support.noCloneEvent&&!c.isXMLDoc(this)){var d=this.outerHTML,e=this.ownerDocument;if(!d){d=e.createElement("div");d.appendChild(this.cloneNode(true));d=d.innerHTML}return c.clean([d.replace(za,"").replace(fb,'="$1">').replace($,"")],e)[0]}else return this.cloneNode(true)});if(a===true){na(this,b);na(this.find("*"),b.find("*"))}return b},html:function(a){if(a===B)return this[0]&&this[0].nodeType===1?this[0].innerHTML.replace(za,""):null;else if(typeof a==="string"&&!Ca.test(a)&&(c.support.leadingWhitespace||!$.test(a))&&!P[(Ba.exec(a)||["",""])[1].toLowerCase()]){a=a.replace(Aa,"<$1></$2>");try{for(var b=0,d=this.length;b<d;b++)if(this[b].nodeType===1){c.cleanData(this[b].getElementsByTagName("*"));this[b].innerHTML=a}}catch(e){this.empty().append(a)}}else c.isFunction(a)?this.each(function(f){var h=c(this);h.html(a.call(this,f,h.html()))}):this.empty().append(a);return this},replaceWith:function(a){if(this[0]&&this[0].parentNode){if(c.isFunction(a))return this.each(function(b){var d=c(this),e=d.html();d.replaceWith(a.call(this,b,e))});if(typeof a!=="string")a=c(a).detach();return this.each(function(){var b=this.nextSibling,d=this.parentNode;c(this).remove();b?c(b).before(a):c(d).append(a)})}else return this.pushStack(c(c.isFunction(a)?a():a),"replaceWith",a)},detach:function(a){return this.remove(a,true)},domManip:function(a,b,d){var e,f,h,l=a[0],k=[];if(!c.support.checkClone&&arguments.length===3&&typeof l==="string"&&Da.test(l))return this.each(function(){c(this).domManip(a,b,d,true)});if(c.isFunction(l))return this.each(function(x){var r=c(this);a[0]=l.call(this,x,b?r.html():B);r.domManip(a,b,d)});if(this[0]){e=l&&l.parentNode;e=c.support.parentNode&&e&&e.nodeType===11&&e.childNodes.length===this.length?{fragment:e}:c.buildFragment(a,this,k);h=e.fragment;if(f=h.childNodes.length===1?h=h.firstChild:h.firstChild){b=b&&c.nodeName(f,"tr");f=0;for(var o=this.length;f<o;f++)d.call(b?c.nodeName(this[f],"table")?this[f].getElementsByTagName("tbody")[0]||this[f].appendChild(this[f].ownerDocument.createElement("tbody")):this[f]:this[f],f>0||e.cacheable||this.length>1?h.cloneNode(true):h)}k.length&&c.each(k,Oa)}return this}});c.buildFragment=function(a,b,d){var e,f,h;b=b&&b[0]?b[0].ownerDocument||b[0]:t;if(a.length===1&&typeof a[0]==="string"&&a[0].length<512&&b===t&&!Ca.test(a[0])&&(c.support.checkClone||!Da.test(a[0]))){f=true;if(h=c.fragments[a[0]])if(h!==1)e=h}if(!e){e=b.createDocumentFragment();c.clean(a,b,e,d)}if(f)c.fragments[a[0]]=h?e:1;return{fragment:e,cacheable:f}};c.fragments={};c.each({appendTo:"append",prependTo:"prepend",insertBefore:"before",insertAfter:"after",replaceAll:"replaceWith"},function(a,b){c.fn[a]=function(d){var e=[];d=c(d);var f=this.length===1&&this[0].parentNode;if(f&&f.nodeType===11&&f.childNodes.length===1&&d.length===1){d[b](this[0]);return this}else{f=0;for(var h=d.length;f<h;f++){var l=(f>0?this.clone(true):this).get();c(d[f])[b](l);e=e.concat(l)}return this.pushStack(e,a,d.selector)}}});c.extend({clean:function(a,b,d,e){b=b||t;if(typeof b.createElement==="undefined")b=b.ownerDocument||b[0]&&b[0].ownerDocument||t;for(var f=[],h=0,l;(l=a[h])!=null;h++){if(typeof l==="number")l+="";if(l){if(typeof l==="string"&&!eb.test(l))l=b.createTextNode(l);else if(typeof l==="string"){l=l.replace(Aa,"<$1></$2>");var k=(Ba.exec(l)||["",""])[1].toLowerCase(),o=P[k]||P._default,x=o[0],r=b.createElement("div");for(r.innerHTML=o[1]+l+o[2];x--;)r=r.lastChild;if(!c.support.tbody){x=db.test(l);k=k==="table"&&!x?r.firstChild&&r.firstChild.childNodes:o[1]==="<table>"&&!x?r.childNodes:[];for(o=k.length-
1;o>=0;--o)c.nodeName(k[o],"tbody")&&!k[o].childNodes.length&&k[o].parentNode.removeChild(k[o])}!c.support.leadingWhitespace&&$.test(l)&&r.insertBefore(b.createTextNode($.exec(l)[0]),r.firstChild);l=r.childNodes}if(l.nodeType)f.push(l);else f=c.merge(f,l)}}if(d)for(h=0;f[h];h++)if(e&&c.nodeName(f[h],"script")&&(!f[h].type||f[h].type.toLowerCase()==="text/javascript"))e.push(f[h].parentNode?f[h].parentNode.removeChild(f[h]):f[h]);else{f[h].nodeType===1&&f.splice.apply(f,[h+1,0].concat(c.makeArray(f[h].getElementsByTagName("script"))));d.appendChild(f[h])}return f},cleanData:function(a){for(var b,d,e=c.cache,f=c.event.special,h=c.support.deleteExpando,l=0,k;(k=a[l])!=null;l++)if(!(k.nodeName&&c.noData[k.nodeName.toLowerCase()]))if(d=k[c.expando]){if((b=e[d])&&b.events)for(var o in b.events)f[o]?c.event.remove(k,o):c.removeEvent(k,o,b.handle);if(h)delete k[c.expando];else k.removeAttribute&&k.removeAttribute(c.expando);delete e[d]}}});var Ea=/alpha\([^)]*\)/i,gb=/opacity=([^)]*)/,hb=/-([a-z])/ig,ib=/([A-Z])/g,Fa=/^-?\d+(?:px)?$/i,jb=/^-?\d/,kb={position:"absolute",visibility:"hidden",display:"block"},Pa=["Left","Right"],Qa=["Top","Bottom"],W,Ga,aa,lb=function(a,b){return b.toUpperCase()};c.fn.css=function(a,b){if(arguments.length===2&&b===B)return this;return c.access(this,a,b,true,function(d,e,f){return f!==B?c.style(d,e,f):c.css(d,e)})};c.extend({cssHooks:{opacity:{get:function(a,b){if(b){var d=W(a,"opacity","opacity");return d===""?"1":d}else return a.style.opacity}}},cssNumber:{zIndex:true,fontWeight:true,opacity:true,zoom:true,lineHeight:true},cssProps:{"float":c.support.cssFloat?"cssFloat":"styleFloat"},style:function(a,b,d,e){if(!(!a||a.nodeType===3||a.nodeType===8||!a.style)){var f,h=c.camelCase(b),l=a.style,k=c.cssHooks[h];b=c.cssProps[h]||h;if(d!==B){if(!(typeof d==="number"&&isNaN(d)||d==null)){if(typeof d==="number"&&!c.cssNumber[h])d+="px";if(!k||!("set"in k)||(d=k.set(a,d))!==B)try{l[b]=d}catch(o){}}}else{if(k&&"get"in k&&(f=k.get(a,false,e))!==B)return f;return l[b]}}},css:function(a,b,d){var e,f=c.camelCase(b),h=c.cssHooks[f];b=c.cssProps[f]||f;if(h&&"get"in h&&(e=h.get(a,true,d))!==B)return e;else if(W)return W(a,b,f)},swap:function(a,b,d){var e={},f;for(f in b){e[f]=a.style[f];a.style[f]=b[f]}d.call(a);for(f in b)a.style[f]=e[f]},camelCase:function(a){return a.replace(hb,lb)}});c.curCSS=c.css;c.each(["height","width"],function(a,b){c.cssHooks[b]={get:function(d,e,f){var h;if(e){if(d.offsetWidth!==0)h=oa(d,b,f);else c.swap(d,kb,function(){h=oa(d,b,f)});if(h<=0){h=W(d,b,b);if(h==="0px"&&aa)h=aa(d,b,b);if(h!=null)return h===""||h==="auto"?"0px":h}if(h<0||h==null){h=d.style[b];return h===""||h==="auto"?"0px":h}return typeof h==="string"?h:h+"px"}},set:function(d,e){if(Fa.test(e)){e=parseFloat(e);if(e>=0)return e+"px"}else return e}}});if(!c.support.opacity)c.cssHooks.opacity={get:function(a,b){return gb.test((b&&a.currentStyle?a.currentStyle.filter:a.style.filter)||"")?parseFloat(RegExp.$1)/100+"":b?"1":""},set:function(a,b){var d=a.style;d.zoom=1;var e=c.isNaN(b)?"":"alpha(opacity="+b*100+")",f=d.filter||"";d.filter=Ea.test(f)?f.replace(Ea,e):d.filter+" "+e}};if(t.defaultView&&t.defaultView.getComputedStyle)Ga=function(a,b,d){var e;d=d.replace(ib,"-$1").toLowerCase();if(!(b=a.ownerDocument.defaultView))return B;if(b=b.getComputedStyle(a,null)){e=b.getPropertyValue(d);if(e===""&&!c.contains(a.ownerDocument.documentElement,a))e=c.style(a,d)}return e};if(t.documentElement.currentStyle)aa=function(a,b){var d,e,f=a.currentStyle&&a.currentStyle[b],h=a.style;if(!Fa.test(f)&&jb.test(f)){d=h.left;e=a.runtimeStyle.left;a.runtimeStyle.left=a.currentStyle.left;h.left=b==="fontSize"?"1em":f||0;f=h.pixelLeft+"px";h.left=d;a.runtimeStyle.left=e}return f===""?"auto":f};W=Ga||aa;if(c.expr&&c.expr.filters){c.expr.filters.hidden=function(a){var b=a.offsetHeight;return a.offsetWidth===0&&b===0||!c.support.reliableHiddenOffsets&&(a.style.display||c.css(a,"display"))==="none"};c.expr.filters.visible=function(a){return!c.expr.filters.hidden(a)}}var mb=c.now(),nb=/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi,ob=/^(?:select|textarea)/i,pb=/^(?:color|date|datetime|email|hidden|month|number|password|range|search|tel|text|time|url|week)$/i,qb=/^(?:GET|HEAD)$/,Ra=/\[\]$/,T=/\=\?(&|$)/,ja=/\?/,rb=/([?&])_=[^&]*/,sb=/^(\w+:)?\/\/([^\/?#]+)/,tb=/%20/g,ub=/#.*$/,Ha=c.fn.load;c.fn.extend({load:function(a,b,d){if(typeof a!=="string"&&Ha)return Ha.apply(this,arguments);else if(!this.length)return this;var e=a.indexOf(" ");if(e>=0){var f=a.slice(e,a.length);a=a.slice(0,e)}e="GET";if(b)if(c.isFunction(b)){d=b;b=null}else if(typeof b==="object"){b=c.param(b,c.ajaxSettings.traditional);e="POST"}var h=this;c.ajax({url:a,type:e,dataType:"html",data:b,complete:function(l,k){if(k==="success"||k==="notmodified")h.html(f?c("<div>").append(l.responseText.replace(nb,"")).find(f):l.responseText);d&&h.each(d,[l.responseText,k,l])}});return this},serialize:function(){return c.param(this.serializeArray())},serializeArray:function(){return this.map(function(){return this.elements?c.makeArray(this.elements):this}).filter(function(){return this.name&&!this.disabled&&(this.checked||ob.test(this.nodeName)||pb.test(this.type))}).map(function(a,b){var d=c(this).val();return d==null?null:c.isArray(d)?c.map(d,function(e){return{name:b.name,value:e}}):{name:b.name,value:d}}).get()}});c.each("ajaxStart ajaxStop ajaxComplete ajaxError ajaxSuccess ajaxSend".split(" "),function(a,b){c.fn[b]=function(d){return this.bind(b,d)}});c.extend({get:function(a,b,d,e){if(c.isFunction(b)){e=e||d;d=b;b=null}return c.ajax({type:"GET",url:a,data:b,success:d,dataType:e})},getScript:function(a,b){return c.get(a,null,b,"script")},getJSON:function(a,b,d){return c.get(a,b,d,"json")},post:function(a,b,d,e){if(c.isFunction(b)){e=e||d;d=b;b={}}return c.ajax({type:"POST",url:a,data:b,success:d,dataType:e})},ajaxSetup:function(a){c.extend(c.ajaxSettings,a)},ajaxSettings:{url:location.href,global:true,type:"GET",contentType:"application/x-www-form-urlencoded",processData:true,async:true,xhr:function(){return new E.XMLHttpRequest},accepts:{xml:"application/xml, text/xml",html:"text/html",script:"text/javascript, application/javascript",json:"application/json, text/javascript",text:"text/plain",_default:"*/*"}},ajax:function(a){var b=c.extend(true,{},c.ajaxSettings,a),d,e,f,h=b.type.toUpperCase(),l=qb.test(h);b.url=b.url.replace(ub,"");b.context=a&&a.context!=null?a.context:b;if(b.data&&b.processData&&typeof b.data!=="string")b.data=c.param(b.data,b.traditional);if(b.dataType==="jsonp"){if(h==="GET")T.test(b.url)||(b.url+=(ja.test(b.url)?"&":"?")+(b.jsonp||"callback")+"=?");else if(!b.data||!T.test(b.data))b.data=(b.data?b.data+"&":"")+(b.jsonp||"callback")+"=?";b.dataType="json"}if(b.dataType==="json"&&(b.data&&T.test(b.data)||T.test(b.url))){d=b.jsonpCallback||"jsonp"+mb++;if(b.data)b.data=(b.data+"").replace(T,"="+d+"$1");b.url=b.url.replace(T,"="+d+"$1");b.dataType="script";var k=E[d];E[d]=function(m){if(c.isFunction(k))k(m);else{E[d]=B;try{delete E[d]}catch(p){}}f=m;c.handleSuccess(b,w,e,f);c.handleComplete(b,w,e,f);r&&r.removeChild(A)}}if(b.dataType==="script"&&b.cache===null)b.cache=false;if(b.cache===false&&l){var o=c.now(),x=b.url.replace(rb,"$1_="+o);b.url=x+(x===b.url?(ja.test(b.url)?"&":"?")+"_="+o:"")}if(b.data&&l)b.url+=(ja.test(b.url)?"&":"?")+b.data;b.global&&c.active++===0&&c.event.trigger("ajaxStart");o=(o=sb.exec(b.url))&&(o[1]&&o[1].toLowerCase()!==location.protocol||o[2].toLowerCase()!==location.host);if(b.dataType==="script"&&h==="GET"&&o){var r=t.getElementsByTagName("head")[0]||t.documentElement,A=t.createElement("script");if(b.scriptCharset)A.charset=b.scriptCharset;A.src=b.url;if(!d){var C=false;A.onload=A.onreadystatechange=function(){if(!C&&(!this.readyState||this.readyState==="loaded"||this.readyState==="complete")){C=true;c.handleSuccess(b,w,e,f);c.handleComplete(b,w,e,f);A.onload=A.onreadystatechange=null;r&&A.parentNode&&r.removeChild(A)}}}r.insertBefore(A,r.firstChild);return B}var J=false,w=b.xhr();if(w){b.username?w.open(h,b.url,b.async,b.username,b.password):w.open(h,b.url,b.async);try{if(b.data!=null&&!l||a&&a.contentType)w.setRequestHeader("Content-Type",b.contentType);if(b.ifModified){c.lastModified[b.url]&&w.setRequestHeader("If-Modified-Since",c.lastModified[b.url]);c.etag[b.url]&&w.setRequestHeader("If-None-Match",c.etag[b.url])}o||w.setRequestHeader("X-Requested-With","XMLHttpRequest");w.setRequestHeader("Accept",b.dataType&&b.accepts[b.dataType]?b.accepts[b.dataType]+", */*; q=0.01":b.accepts._default)}catch(I){}if(b.beforeSend&&b.beforeSend.call(b.context,w,b)===false){b.global&&c.active--===1&&c.event.trigger("ajaxStop");w.abort();return false}b.global&&c.triggerGlobal(b,"ajaxSend",[w,b]);var L=w.onreadystatechange=function(m){if(!w||w.readyState===0||m==="abort"){J||c.handleComplete(b,w,e,f);J=true;if(w)w.onreadystatechange=c.noop}else if(!J&&w&&(w.readyState===4||m==="timeout")){J=true;w.onreadystatechange=c.noop;e=m==="timeout"?"timeout":!c.httpSuccess(w)?"error":b.ifModified&&c.httpNotModified(w,b.url)?"notmodified":"success";var p;if(e==="success")try{f=c.httpData(w,b.dataType,b)}catch(q){e="parsererror";p=q}if(e==="success"||e==="notmodified")d||c.handleSuccess(b,w,e,f);else c.handleError(b,w,e,p);d||c.handleComplete(b,w,e,f);m==="timeout"&&w.abort();if(b.async)w=null}};try{var g=w.abort;w.abort=function(){w&&Function.prototype.call.call(g,w);L("abort")}}catch(i){}b.async&&b.timeout>0&&setTimeout(function(){w&&!J&&L("timeout")},b.timeout);try{w.send(l||b.data==null?null:b.data)}catch(n){c.handleError(b,w,null,n);c.handleComplete(b,w,e,f)}b.async||L();return w}},param:function(a,b){var d=[],e=function(h,l){l=c.isFunction(l)?l():l;d[d.length]=encodeURIComponent(h)+"="+encodeURIComponent(l)};if(b===B)b=c.ajaxSettings.traditional;if(c.isArray(a)||a.jquery)c.each(a,function(){e(this.name,this.value)});else for(var f in a)da(f,a[f],b,e);return d.join("&").replace(tb,"+")}});c.extend({active:0,lastModified:{},etag:{},handleError:function(a,b,d,e){a.error&&a.error.call(a.context,b,d,e);a.global&&c.triggerGlobal(a,"ajaxError",[b,a,e])},handleSuccess:function(a,b,d,e){a.success&&a.success.call(a.context,e,d,b);a.global&&c.triggerGlobal(a,"ajaxSuccess",[b,a])},handleComplete:function(a,b,d){a.complete&&a.complete.call(a.context,b,d);a.global&&c.triggerGlobal(a,"ajaxComplete",[b,a]);a.global&&c.active--===1&&c.event.trigger("ajaxStop")},triggerGlobal:function(a,b,d){(a.context&&a.context.url==null?c(a.context):c.event).trigger(b,d)},httpSuccess:function(a){try{return!a.status&&location.protocol==="file:"||a.status>=200&&a.status<300||a.status===304||a.status===1223}catch(b){}return false},httpNotModified:function(a,b){var d=a.getResponseHeader("Last-Modified"),e=a.getResponseHeader("Etag");if(d)c.lastModified[b]=d;if(e)c.etag[b]=e;return a.status===304},httpData:function(a,b,d){var e=a.getResponseHeader("content-type")||"",f=b==="xml"||!b&&e.indexOf("xml")>=0;a=f?a.responseXML:a.responseText;f&&a.documentElement.nodeName==="parsererror"&&c.error("parsererror");if(d&&d.dataFilter)a=d.dataFilter(a,b);if(typeof a==="string")if(b==="json"||!b&&e.indexOf("json")>=0)a=c.parseJSON(a);else if(b==="script"||!b&&e.indexOf("javascript")>=0)c.globalEval(a);return a}});if(E.ActiveXObject)c.ajaxSettings.xhr=function(){if(E.location.protocol!=="file:")try{return new E.XMLHttpRequest}catch(a){}try{return new E.ActiveXObject("Microsoft.XMLHTTP")}catch(b){}};c.support.ajax=!!c.ajaxSettings.xhr();var ea={},vb=/^(?:toggle|show|hide)$/,wb=/^([+\-]=)?([\d+.\-]+)(.*)$/,ba,pa=[["height","marginTop","marginBottom","paddingTop","paddingBottom"],["width","marginLeft","marginRight","paddingLeft","paddingRight"],["opacity"]];c.fn.extend({show:function(a,b,d){if(a||a===0)return this.animate(S("show",3),a,b,d);else{d=0;for(var e=this.length;d<e;d++){a=this[d];b=a.style.display;if(!c.data(a,"olddisplay")&&b==="none")b=a.style.display="";b===""&&c.css(a,"display")==="none"&&c.data(a,"olddisplay",qa(a.nodeName))}for(d=0;d<e;d++){a=this[d];b=a.style.display;if(b===""||b==="none")a.style.display=c.data(a,"olddisplay")||""}return this}},hide:function(a,b,d){if(a||a===0)return this.animate(S("hide",3),a,b,d);else{a=0;for(b=this.length;a<b;a++){d=c.css(this[a],"display");d!=="none"&&c.data(this[a],"olddisplay",d)}for(a=0;a<b;a++)this[a].style.display="none";return this}},_toggle:c.fn.toggle,toggle:function(a,b,d){var e=typeof a==="boolean";if(c.isFunction(a)&&c.isFunction(b))this._toggle.apply(this,arguments);else a==null||e?this.each(function(){var f=e?a:c(this).is(":hidden");c(this)[f?"show":"hide"]()}):this.animate(S("toggle",3),a,b,d);return this},fadeTo:function(a,b,d,e){return this.filter(":hidden").css("opacity",0).show().end().animate({opacity:b},a,d,e)},animate:function(a,b,d,e){var f=c.speed(b,d,e);if(c.isEmptyObject(a))return this.each(f.complete);return this[f.queue===false?"each":"queue"](function(){var h=c.extend({},f),l,k=this.nodeType===1,o=k&&c(this).is(":hidden"),x=this;for(l in a){var r=c.camelCase(l);if(l!==r){a[r]=a[l];delete a[l];l=r}if(a[l]==="hide"&&o||a[l]==="show"&&!o)return h.complete.call(this);if(k&&(l==="height"||l==="width")){h.overflow=[this.style.overflow,this.style.overflowX,this.style.overflowY];if(c.css(this,"display")==="inline"&&c.css(this,"float")==="none")if(c.support.inlineBlockNeedsLayout)if(qa(this.nodeName)==="inline")this.style.display="inline-block";else{this.style.display="inline";this.style.zoom=1}else this.style.display="inline-block"}if(c.isArray(a[l])){(h.specialEasing=h.specialEasing||{})[l]=a[l][1];a[l]=a[l][0]}}if(h.overflow!=null)this.style.overflow="hidden";h.curAnim=c.extend({},a);c.each(a,function(A,C){var J=new c.fx(x,h,A);if(vb.test(C))J[C==="toggle"?o?"show":"hide":C](a);else{var w=wb.exec(C),I=J.cur()||0;if(w){var L=parseFloat(w[2]),g=w[3]||"px";if(g!=="px"){c.style(x,A,(L||1)+g);I=(L||1)/J.cur()*I;c.style(x,A,I+g)}if(w[1])L=(w[1]==="-="?-1:1)*L+I;J.custom(I,L,g)}else J.custom(I,C,"")}});return true})},stop:function(a,b){var d=c.timers;a&&this.queue([]);this.each(function(){for(var e=d.length-1;e>=0;e--)if(d[e].elem===this){b&&d[e](true);d.splice(e,1)}});b||this.dequeue();return this}});c.each({slideDown:S("show",1),slideUp:S("hide",1),slideToggle:S("toggle",1),fadeIn:{opacity:"show"},fadeOut:{opacity:"hide"},fadeToggle:{opacity:"toggle"}},function(a,b){c.fn[a]=function(d,e,f){return this.animate(b,d,e,f)}});c.extend({speed:function(a,b,d){var e=a&&typeof a==="object"?c.extend({},a):{complete:d||!d&&b||c.isFunction(a)&&a,duration:a,easing:d&&b||b&&!c.isFunction(b)&&b};e.duration=c.fx.off?0:typeof e.duration==="number"?e.duration:e.duration in c.fx.speeds?c.fx.speeds[e.duration]:c.fx.speeds._default;e.old=e.complete;e.complete=function(){e.queue!==false&&c(this).dequeue();c.isFunction(e.old)&&e.old.call(this)};return e},easing:{linear:function(a,b,d,e){return d+e*a},swing:function(a,b,d,e){return(-Math.cos(a*Math.PI)/2+0.5)*e+d}},timers:[],fx:function(a,b,d){this.options=b;this.elem=a;this.prop=d;if(!b.orig)b.orig={}}});c.fx.prototype={update:function(){this.options.step&&this.options.step.call(this.elem,this.now,this);(c.fx.step[this.prop]||c.fx.step._default)(this)},cur:function(){if(this.elem[this.prop]!=null&&(!this.elem.style||this.elem.style[this.prop]==null))return this.elem[this.prop];var a=parseFloat(c.css(this.elem,this.prop));return a&&a>-1E4?a:0},custom:function(a,b,d){function e(l){return f.step(l)}
var f=this,h=c.fx;this.startTime=c.now();this.start=a;this.end=b;this.unit=d||this.unit||"px";this.now=this.start;this.pos=this.state=0;e.elem=this.elem;if(e()&&c.timers.push(e)&&!ba)ba=setInterval(h.tick,h.interval)},show:function(){this.options.orig[this.prop]=c.style(this.elem,this.prop);this.options.show=true;this.custom(this.prop==="width"||this.prop==="height"?1:0,this.cur());c(this.elem).show()},hide:function(){this.options.orig[this.prop]=c.style(this.elem,this.prop);this.options.hide=true;this.custom(this.cur(),0)},step:function(a){var b=c.now(),d=true;if(a||b>=this.options.duration+this.startTime){this.now=this.end;this.pos=this.state=1;this.update();this.options.curAnim[this.prop]=true;for(var e in this.options.curAnim)if(this.options.curAnim[e]!==true)d=false;if(d){if(this.options.overflow!=null&&!c.support.shrinkWrapBlocks){var f=this.elem,h=this.options;c.each(["","X","Y"],function(k,o){f.style["overflow"+o]=h.overflow[k]})}this.options.hide&&c(this.elem).hide();if(this.options.hide||this.options.show)for(var l in this.options.curAnim)c.style(this.elem,l,this.options.orig[l]);this.options.complete.call(this.elem)}return false}else{a=b-this.startTime;this.state=a/this.options.duration;b=this.options.easing||(c.easing.swing?"swing":"linear");this.pos=c.easing[this.options.specialEasing&&this.options.specialEasing[this.prop]||b](this.state,a,0,1,this.options.duration);this.now=this.start+(this.end-this.start)*this.pos;this.update()}return true}};c.extend(c.fx,{tick:function(){for(var a=c.timers,b=0;b<a.length;b++)a[b]()||a.splice(b--,1);a.length||c.fx.stop()},interval:13,stop:function(){clearInterval(ba);ba=null},speeds:{slow:600,fast:200,_default:400},step:{opacity:function(a){c.style(a.elem,"opacity",a.now)},_default:function(a){if(a.elem.style&&a.elem.style[a.prop]!=null)a.elem.style[a.prop]=(a.prop==="width"||a.prop==="height"?Math.max(0,a.now):a.now)+a.unit;else a.elem[a.prop]=a.now}}});if(c.expr&&c.expr.filters)c.expr.filters.animated=function(a){return c.grep(c.timers,function(b){return a===b.elem}).length};var xb=/^t(?:able|d|h)$/i,Ia=/^(?:body|html)$/i;c.fn.offset="getBoundingClientRect"in t.documentElement?function(a){var b=this[0],d;if(a)return this.each(function(l){c.offset.setOffset(this,a,l)});if(!b||!b.ownerDocument)return null;if(b===b.ownerDocument.body)return c.offset.bodyOffset(b);try{d=b.getBoundingClientRect()}catch(e){}var f=b.ownerDocument,h=f.documentElement;if(!d||!c.contains(h,b))return d||{top:0,left:0};b=f.body;f=fa(f);return{top:d.top+(f.pageYOffset||c.support.boxModel&&h.scrollTop||b.scrollTop)-(h.clientTop||b.clientTop||0),left:d.left+(f.pageXOffset||c.support.boxModel&&h.scrollLeft||b.scrollLeft)-(h.clientLeft||b.clientLeft||0)}}:function(a){var b=this[0];if(a)return this.each(function(x){c.offset.setOffset(this,a,x)});if(!b||!b.ownerDocument)return null;if(b===b.ownerDocument.body)return c.offset.bodyOffset(b);c.offset.initialize();var d,e=b.offsetParent,f=b.ownerDocument,h=f.documentElement,l=f.body;d=(f=f.defaultView)?f.getComputedStyle(b,null):b.currentStyle;for(var k=b.offsetTop,o=b.offsetLeft;(b=b.parentNode)&&b!==l&&b!==h;){if(c.offset.supportsFixedPosition&&d.position==="fixed")break;d=f?f.getComputedStyle(b,null):b.currentStyle;k-=b.scrollTop;o-=b.scrollLeft;if(b===e){k+=b.offsetTop;o+=b.offsetLeft;if(c.offset.doesNotAddBorder&&!(c.offset.doesAddBorderForTableAndCells&&xb.test(b.nodeName))){k+=parseFloat(d.borderTopWidth)||0;o+=parseFloat(d.borderLeftWidth)||0}e=b.offsetParent}if(c.offset.subtractsBorderForOverflowNotVisible&&d.overflow!=="visible"){k+=parseFloat(d.borderTopWidth)||0;o+=parseFloat(d.borderLeftWidth)||0}d=d}if(d.position==="relative"||d.position==="static"){k+=l.offsetTop;o+=l.offsetLeft}if(c.offset.supportsFixedPosition&&d.position==="fixed"){k+=Math.max(h.scrollTop,l.scrollTop);o+=Math.max(h.scrollLeft,l.scrollLeft)}return{top:k,left:o}};c.offset={initialize:function(){var a=t.body,b=t.createElement("div"),d,e,f,h=parseFloat(c.css(a,"marginTop"))||0;c.extend(b.style,{position:"absolute",top:0,left:0,margin:0,border:0,width:"1px",height:"1px",visibility:"hidden"});b.innerHTML="<div style='position:absolute;top:0;left:0;margin:0;border:5px solid #000;padding:0;width:1px;height:1px;'><div></div></div><table style='position:absolute;top:0;left:0;margin:0;border:5px solid #000;padding:0;width:1px;height:1px;' cellpadding='0' cellspacing='0'><tr><td></td></tr></table>";a.insertBefore(b,a.firstChild);d=b.firstChild;e=d.firstChild;f=d.nextSibling.firstChild.firstChild;this.doesNotAddBorder=e.offsetTop!==5;this.doesAddBorderForTableAndCells=f.offsetTop===5;e.style.position="fixed";e.style.top="20px";this.supportsFixedPosition=e.offsetTop===20||e.offsetTop===15;e.style.position=e.style.top="";d.style.overflow="hidden";d.style.position="relative";this.subtractsBorderForOverflowNotVisible=e.offsetTop===-5;this.doesNotIncludeMarginInBodyOffset=a.offsetTop!==h;a.removeChild(b);c.offset.initialize=c.noop},bodyOffset:function(a){var b=a.offsetTop,d=a.offsetLeft;c.offset.initialize();if(c.offset.doesNotIncludeMarginInBodyOffset){b+=parseFloat(c.css(a,"marginTop"))||0;d+=parseFloat(c.css(a,"marginLeft"))||0}return{top:b,left:d}},setOffset:function(a,b,d){var e=c.css(a,"position");if(e==="static")a.style.position="relative";var f=c(a),h=f.offset(),l=c.css(a,"top"),k=c.css(a,"left"),o=e==="absolute"&&c.inArray("auto",[l,k])>-1;e={};var x={};if(o)x=f.position();l=o?x.top:parseInt(l,10)||0;k=o?x.left:parseInt(k,10)||0;if(c.isFunction(b))b=b.call(a,d,h);if(b.top!=null)e.top=b.top-h.top+l;if(b.left!=null)e.left=b.left-h.left+k;"using"in b?b.using.call(a,e):f.css(e)}};c.fn.extend({position:function(){if(!this[0])return null;var a=this[0],b=this.offsetParent(),d=this.offset(),e=Ia.test(b[0].nodeName)?{top:0,left:0}:b.offset();d.top-=parseFloat(c.css(a,"marginTop"))||0;d.left-=parseFloat(c.css(a,"marginLeft"))||0;e.top+=parseFloat(c.css(b[0],"borderTopWidth"))||0;e.left+=parseFloat(c.css(b[0],"borderLeftWidth"))||0;return{top:d.top-e.top,left:d.left-e.left}},offsetParent:function(){return this.map(function(){for(var a=this.offsetParent||t.body;a&&!Ia.test(a.nodeName)&&c.css(a,"position")==="static";)a=a.offsetParent;return a})}});c.each(["Left","Top"],function(a,b){var d="scroll"+b;c.fn[d]=function(e){var f=this[0],h;if(!f)return null;if(e!==B)return this.each(function(){if(h=fa(this))h.scrollTo(!a?e:c(h).scrollLeft(),a?e:c(h).scrollTop());else this[d]=e});else return(h=fa(f))?"pageXOffset"in h?h[a?"pageYOffset":"pageXOffset"]:c.support.boxModel&&h.document.documentElement[d]||h.document.body[d]:f[d]}});c.each(["Height","Width"],function(a,b){var d=b.toLowerCase();c.fn["inner"+b]=function(){return this[0]?parseFloat(c.css(this[0],d,"padding")):null};c.fn["outer"+b]=function(e){return this[0]?parseFloat(c.css(this[0],d,e?"margin":"border")):null};c.fn[d]=function(e){var f=this[0];if(!f)return e==null?null:this;if(c.isFunction(e))return this.each(function(l){var k=c(this);k[d](e.call(this,l,k[d]()))});if(c.isWindow(f))return f.document.compatMode==="CSS1Compat"&&f.document.documentElement["client"+b]||f.document.body["client"+b];else if(f.nodeType===9)return Math.max(f.documentElement["client"+
b],f.body["scroll"+b],f.documentElement["scroll"+b],f.body["offset"+b],f.documentElement["offset"+b]);else if(e===B){f=c.css(f,d);var h=parseFloat(f);return c.isNaN(h)?f:h}else return this.css(d,typeof e==="string"?e:e+"px")}})})(window);;(function(d){var k=d.scrollTo=function(a,i,e){d(window).scrollTo(a,i,e)};k.defaults={axis:'xy',duration:parseFloat(d.fn.jquery)>=1.3?0:1};k.window=function(a){return d(window)._scrollable()};d.fn._scrollable=function(){return this.map(function(){var a=this,i=!a.nodeName||d.inArray(a.nodeName.toLowerCase(),['iframe','#document','html','body'])!=-1;if(!i)return a;var e=(a.contentWindow||a).document||a.ownerDocument||a;return d.browser.safari||e.compatMode=='BackCompat'?e.body:e.documentElement})};d.fn.scrollTo=function(n,j,b){if(typeof j=='object'){b=j;j=0}if(typeof b=='function')b={onAfter:b};if(n=='max')n=9e9;b=d.extend({},k.defaults,b);j=j||b.speed||b.duration;b.queue=b.queue&&b.axis.length>1;if(b.queue)j/=2;b.offset=p(b.offset);b.over=p(b.over);return this._scrollable().each(function(){var q=this,r=d(q),f=n,s,g={},u=r.is('html,body');switch(typeof f){case'number':case'string':if(/^([+-]=)?\d+(\.\d+)?(px|%)?$/.test(f)){f=p(f);break}f=d(f,this);case'object':if(f.is||f.style)s=(f=d(f)).offset()}d.each(b.axis.split(''),function(a,i){var e=i=='x'?'Left':'Top',h=e.toLowerCase(),c='scroll'+e,l=q[c],m=k.max(q,i);if(s){g[c]=s[h]+(u?0:l-r.offset()[h]);if(b.margin){g[c]-=parseInt(f.css('margin'+e))||0;g[c]-=parseInt(f.css('border'+e+'Width'))||0}g[c]+=b.offset[h]||0;if(b.over[h])g[c]+=f[i=='x'?'width':'height']()*b.over[h]}else{var o=f[h];g[c]=o.slice&&o.slice(-1)=='%'?parseFloat(o)/100*m:o}if(/^\d+$/.test(g[c]))g[c]=g[c]<=0?0:Math.min(g[c],m);if(!a&&b.queue){if(l!=g[c])t(b.onAfterFirst);delete g[c]}});t(b.onAfter);function t(a){r.animate(g,j,b.easing,a&&function(){a.call(this,n,b)})}}).end()};k.max=function(a,i){var e=i=='x'?'Width':'Height',h='scroll'+e;if(!d(a).is('html,body'))return a[h]-d(a)[e.toLowerCase()]();var c='client'+e,l=a.ownerDocument.documentElement,m=a.ownerDocument.body;return Math.max(l[h],m[h])-Math.min(l[c],m[c])};function p(a){return typeof a=='object'?a:{top:a,left:a}}})(jQuery);(function($){var g=[],visibleMenus=[],activeMenu=activeItem=null,menuDIVElement=$('<div class="menu-div outerbox" style="position:absolute;top:0;left:0;display:none;"><div class="shadowbox1"></div><div class="shadowbox2"></div><div class="shadowbox3"></div></div>')[0],menuULElement=$('<ul class="menu-ul innerbox"></ul>')[0],menuItemElement=$('<li style="position:relative;"><div class="menu-item"></div></li>')[0],arrowElement=$('<img class="menu-item-arrow" />')[0],$rootDiv=$('<div id="root-menu-div" style="position:absolute;top:0;left:0;"></div>'),defaults={showDelay:200,hideDelay:200,hoverOpenDelay:0,offsetTop:0,offsetLeft:0,minWidth:0,onOpen:null,onClose:null,onClick:null,arrowSrc:null,addExpando:false,copyClassAttr:false};$(function(){$rootDiv.appendTo('body')});$.extend({MenuCollection:function(a){this.menus=[];this.init(a)}});$.extend($.MenuCollection,{prototype:{init:function(a){if(a&&a.length){for(var i=0;i<a.length;i++){this.addMenu(a[i]);a[i].menuCollection=this}}},addMenu:function(a){if(a instanceof $.Menu)this.menus.push(a);a.menuCollection=this;var b=this;$(a.target).hover(function(){if(a.visible)return;for(var i=0;i<b.menus.length;i++){if(b.menus[i].visible){b.menus[i].hide();a.show();return}}},function(){})}}});$.extend({Menu:function(a,b,c){this.menuItems=[];this.subMenus=[];this.visible=false;this.active=false;this.parentMenuItem=null;this.settings=$.extend({},defaults,c);this.target=a;this.$eDIV=null;this.$eUL=null;this.timer=null;this.menuCollection=null;this.openTimer=null;this.init();if(b&&b.constructor==Array)this.addItems(b)}});$.extend($.Menu,{checkMouse:function(e){var t=e.target;if(visibleMenus.length&&t==visibleMenus[0].target)return;while(t.parentNode&&t.parentNode!=$rootDiv[0])t=t.parentNode;if(!$(visibleMenus).filter(function(){return this.$eDIV[0]==t}).length){$.Menu.closeAll()}},checkKey:function(e){switch(e.keyCode){case 13:if(activeItem)activeItem.click(e,activeItem.$eLI[0]);break;case 27:$.Menu.closeAll();break;case 37:if(!activeMenu)activeMenu=visibleMenus[0];var a=activeMenu;if(a&&a.parentMenuItem){var b=a.parentMenuItem;b.$eLI.unbind('mouseout').unbind('mouseover');a.hide();b.hoverIn(true);setTimeout(function(){b.bindHover()})}else if(a&&a.menuCollection){var c,mcm=a.menuCollection.menus;if((c=$.inArray(a,mcm))>-1){if(--c<0)c=mcm.length-1;$.Menu.closeAll();mcm[c].show();mcm[c].setActive();if(mcm[c].menuItems.length)mcm[c].menuItems[0].hoverIn(true)}}break;case 38:if(activeMenu)activeMenu.selectNextItem(-1);break;case 39:if(!activeMenu)activeMenu=visibleMenus[0];var m,a=activeMenu,asm=activeItem?activeItem.subMenu:null;if(a){if(asm&&asm.menuItems.length){asm.show();asm.menuItems[0].hoverIn()}else if((a=a.inMenuCollection())){var c,mcm=a.menuCollection.menus;if((c=$.inArray(a,mcm))>-1){if(++c>=mcm.length)c=0;$.Menu.closeAll();mcm[c].show();mcm[c].setActive();if(mcm[c].menuItems.length)mcm[c].menuItems[0].hoverIn(true)}}}break;case 40:if(!activeMenu){if(visibleMenus.length&&visibleMenus[0].menuItems.length)visibleMenus[0].menuItems[0].hoverIn()}else activeMenu.selectNextItem();break}if(e.keyCode>36&&e.keyCode<41)return false},closeAll:function(){while(visibleMenus.length)visibleMenus[0].hide()},setDefaults:function(d){$.extend(defaults,d)},prototype:{init:function(){var a=this;if(!this.target)return;else if(this.target instanceof $.MenuItem){this.parentMenuItem=this.target;this.target.addSubMenu(this);this.target=this.target.$eLI}g.push(this);this.$eDIV=$(menuDIVElement.cloneNode(1));this.$eUL=$(menuULElement.cloneNode(1));this.$eDIV[0].appendChild(this.$eUL[0]);$rootDiv[0].appendChild(this.$eDIV[0]);if(!this.parentMenuItem){$(this.target).click(function(e){a.onClick(e)}).hover(function(e){a.setActive();if(a.settings.hoverOpenDelay){a.openTimer=setTimeout(function(){if(!a.visible)a.onClick(e)},a.settings.hoverOpenDelay)}},function(){if(!a.visible)$(this).removeClass('activetarget');if(a.openTimer)clearTimeout(a.openTimer)})}else{this.$eDIV.hover(function(){a.setActive()},function(){})}},setActive:function(){if(!this.parentMenuItem)$(this.target).addClass('activetarget');else this.active=true},addItem:function(a){if(a instanceof $.MenuItem){if($.inArray(a,this.menuItems)==-1){this.$eUL.append(a.$eLI);this.menuItems.push(a);a.parentMenu=this;if(a.subMenu)this.subMenus.push(a.subMenu)}}else{this.addItem(new $.MenuItem(a,this.settings))}},addItems:function(a){for(var i=0;i<a.length;i++){this.addItem(a[i])}},removeItem:function(a){var b=$.inArray(a,this.menuItems);if(b>-1)this.menuItems.splice(b,1);a.parentMenu=null},hide:function(){if(!this.visible)return;var i,pos=$.inArray(this,visibleMenus);this.$eDIV.hide();if(pos>=0)visibleMenus.splice(pos,1);this.visible=this.active=false;$(this.target).removeClass('activetarget');for(i=0;i<this.subMenus.length;i++){this.subMenus[i].hide()}for(i=0;i<this.menuItems.length;i++){if(this.menuItems[i].active)this.menuItems[i].setInactive()}if(!visibleMenus.length)$(document).unbind('mousedown',$.Menu.checkMouse).unbind('keydown',$.Menu.checkKey);if(activeMenu==this)activeMenu=null;if(this.settings.onClose)this.settings.onClose.call(this)},show:function(e){if(this.visible)return;var a,pmi=this.parentMenuItem;if(this.menuItems.length){if(pmi){a=parseInt(pmi.parentMenu.$eDIV.css('z-index'));this.$eDIV.css('z-index',(isNaN(a)?1:a+1))}this.$eDIV.css({visibility:'hidden',display:'block'});if(this.settings.minWidth){if(this.$eDIV.width()<this.settings.minWidth)this.$eDIV.css('width',this.settings.minWidth)}this.setPosition();this.$eDIV.css({display:'none',visibility:''}).show();if($.browser.msie)this.$eUL.css('width',parseInt($.browser.version)==6?this.$eDIV.width()-7:this.$eUL.width());if(this.settings.onOpen)this.settings.onOpen.call(this)}if(visibleMenus.length==0)$(document).bind('mousedown',$.Menu.checkMouse).bind('keydown',$.Menu.checkKey);this.visible=true;visibleMenus.push(this)},setPosition:function(){var a,o,posX,posY,pmo,wst,wsl,ww=$(window).width(),wh=$(window).height(),pmi=this.parentMenuItem,height=this.$eDIV[0].clientHeight,width=this.$eDIV[0].clientWidth,pheight;if(pmi){o=pmi.$eLI.offset();posX=o.left+pmi.$eLI.width();posY=o.top}else{a=$(this.target);o=a.offset();posX=o.left+this.settings.offsetLeft;posY=o.top+a.height()+this.settings.offsetTop}if($.fn.scrollTop){wst=$(window).scrollTop();if(wh<height){posY=wst}else if(wh+wst<posY+height){if(pmi){pmo=pmi.parentMenu.$eDIV.offset();pheight=pmi.parentMenu.$eDIV[0].clientHeight;if(height<=pheight){posY=pmo.top+pheight-height}else{posY=pmo.top}if(wh+wst<posY+height){posY-=posY+height-(wh+wst)}}else{posY-=posY+height-(wh+wst)}}}if($.fn.scrollLeft){wsl=$(window).scrollLeft();if(ww+wsl<posX+width){if(pmi){posX-=pmi.$eLI.width()+width;if(posX<wsl)posX=wsl}else{posX-=posX+width-(ww+wsl)}}}this.$eDIV.css({left:posX,top:posY})},onClick:function(e){if(this.visible){this.hide();this.setActive()}else{$.Menu.closeAll();this.show(e)}},addTimer:function(a,b){var c=this;this.timer=setTimeout(function(){a.call(c);c.timer=null},b)},removeTimer:function(){if(this.timer){clearTimeout(this.timer);this.timer=null}},selectNextItem:function(a){var i,pos=0,mil=this.menuItems.length,o=a||1;for(i=0;i<mil;i++){if(this.menuItems[i].active){pos=i;break}}this.menuItems[pos].hoverOut();do{pos+=o;if(pos>=mil)pos=0;else if(pos<0)pos=mil-1}while(this.menuItems[pos].separator);this.menuItems[pos].hoverIn(true)},inMenuCollection:function(){var m=this;while(m.parentMenuItem)m=m.parentMenuItem.parentMenu;return m.menuCollection?m:null},destroy:function(){var a,item;this.hide();if(!this.parentMenuItem)$(this.target).unbind('click').unbind('mouseover').unbind('mouseout');else this.$eDIV.unbind('mouseover').unbind('mouseout');while(this.menuItems.length){item=this.menuItems[0];item.destroy();delete item}if((a=$.inArray(this,g))>-1)g.splice(a,1);if(this.menuCollection){if((a=$.inArray(this,this.menuCollection.menus))>-1)this.menuCollection.menus.splice(a,1)}this.$eDIV.remove()}}});$.extend({MenuItem:function(a,b){if(typeof a=='string')a={src:a};this.src=a.src||'';this.url=a.url||null;this.urlTarget=a.target||null;this.addClass=a.addClass||null;this.data=a.data||null;this.$eLI=null;this.parentMenu=null;this.subMenu=null;this.settings=$.extend({},defaults,b);this.active=false;this.enabled=true;this.separator=false;this.init();if(a.subMenu)new $.Menu(this,a.subMenu,b)}});$.extend($.MenuItem,{prototype:{init:function(){var i,isStr,src=this.src,self=this;this.$eLI=$(menuItemElement.cloneNode(1));if(this.addClass)this.$eLI[0].setAttribute('class',this.addClass);if(this.settings.addExpando&&this.data)this.$eLI[0].menuData=this.data;if(src==''){this.$eLI.addClass('menu-separator');this.separator=true}else{isStr=typeof src=='string';if(isStr&&this.url)src=$('<a href="'+this.url+'"'+(this.urlTarget?'target="'+this.urlTarget+'"':'')+'>'+src+'</a>');else if(isStr||!src.length)src=[src];for(i=0;i<src.length;i++){if(typeof src[i]=='string'){elem=document.createElement('span');elem.innerHTML=src[i];this.$eLI[0].firstChild.appendChild(elem)}else this.$eLI[0].firstChild.appendChild(src[i].cloneNode(1))}}this.$eLI.click(function(e){self.click(e,this)});this.bindHover()},click:function(e,a){if(this.enabled&&this.settings.onClick)this.settings.onClick.call(a,e,this)},bindHover:function(){var a=this;this.$eLI.hover(function(){a.hoverIn()},function(){a.hoverOut()})},hoverIn:function(a){this.removeTimer();var i,pms=this.parentMenu.subMenus,pmi=this.parentMenu.menuItems,self=this;if(this.parentMenu.timer)this.parentMenu.removeTimer();if(!this.enabled)return;for(i=0;i<pmi.length;i++){if(pmi[i].active)pmi[i].setInactive()}this.setActive();activeMenu=this.parentMenu;for(i=0;i<pms.length;i++){if(pms[i].visible&&pms[i]!=this.subMenu&&!pms[i].timer)pms[i].addTimer(function(){this.hide()},pms[i].settings.hideDelay)}if(this.subMenu&&!a){this.subMenu.addTimer(function(){this.show()},this.subMenu.settings.showDelay)}},hoverOut:function(){this.removeTimer();if(!this.enabled)return;if(!this.subMenu||!this.subMenu.visible)this.setInactive()},removeTimer:function(){if(this.subMenu){this.subMenu.removeTimer()}},setActive:function(){this.active=true;this.$eLI.addClass('active');var a=this.parentMenu.parentMenuItem;if(a&&!a.active)a.setActive();activeItem=this},setInactive:function(){this.active=false;this.$eLI.removeClass('active');if(this==activeItem)activeItem=null},enable:function(){this.$eLI.removeClass('disabled');this.enabled=true},disable:function(){this.$eLI.addClass('disabled');this.enabled=false},destroy:function(){this.removeTimer();this.$eLI.remove();this.$eLI.unbind('mouseover').unbind('mouseout').unbind('click');if(this.subMenu){this.subMenu.destroy();delete this.subMenu}this.parentMenu.removeItem(this)},addSubMenu:function(b){if(this.subMenu)return;this.subMenu=b;if(this.parentMenu&&$.inArray(b,this.parentMenu.subMenus)==-1)this.parentMenu.subMenus.push(b);if(this.settings.arrowSrc){var a=arrowElement.cloneNode(0);a.setAttribute('src',this.settings.arrowSrc);this.$eLI[0].firstChild.appendChild(a)}}}});$.extend($.fn,{menuFromElement:function(c,d,e){var f=function(a){var b=[],subItems,menuItem,lis,$li,i,subUL,submenu,target,classNames=null;lis=j(a,'LI');for(i=0;i<lis.length;i++){subItems=[];if(!lis[i].childNodes.length){b.push(new $.MenuItem('',c));continue}if((subUL=h(lis[i],'UL'))){subItems=f(subUL);$(subUL).remove()}$li=$(lis[i]);if($li[0].childNodes.length==1&&$li[0].childNodes[0].nodeType==3)target=$li[0].childNodes[0].nodeValue;else target=$li[0].childNodes;if(c&&c.copyClassAttr)classNames=$li.attr('class');menuItem=new $.MenuItem({src:target,addClass:classNames},c);b.push(menuItem);if(subItems.length)new $.Menu(menuItem,subItems,c)}return b};return this.each(function(){var a,m;if(d||(a=h(this,'UL'))){a=d?$(d).clone(true)[0]:a;menuItems=f(a);if(menuItems.length){m=new $.Menu(this,menuItems,c);if(e)e.addMenu(m)}$(a).hide()}})},menuBarFromUL:function(a){return this.each(function(){var i,lis=j(this,'LI');if(lis.length){bar=new $.MenuCollection();for(i=0;i<lis.length;i++)$(lis[i]).menuFromElement(a,null,bar)}})},menu:function(a,b){return this.each(function(){if(b&&b.constructor==Array)new $.Menu(this,b,a);else{if(this.nodeName.toUpperCase()=='UL')$(this).menuBarFromUL(a);else $(this).menuFromElement(a,b)}})}});var h=function(a,b){if(!a)return null;var n=a.firstChild;for(;n;n=n.nextSibling){if(n.nodeType==1&&n.nodeName.toUpperCase()==b)return n}return null};var j=function(a,b){if(!a)return[];var r=[],n=a.firstChild;for(;n;n=n.nextSibling){if(n.nodeType==1&&n.nodeName.toUpperCase()==b)r[r.length]=n}return r}})(jQuery);(function(jQuery){this.version='(beta)(0.0.1)';this.maxSize=10;this.keys=new Array();this.cache_length=0;this.items=new Array();this.setItem=function(pKey,pValue)
{if(typeof(pValue)!='undefined')
{if(typeof(this.items[pKey])=='undefined')
{this.cache_length++;}
this.keys.push(pKey);this.items[pKey]=pValue;if(this.cache_length>this.maxSize)
{this.removeOldestItem();}}
return pValue;}
this.removeItem=function(pKey)
{var tmp;if(typeof(this.items[pKey])!='undefined')
{this.cache_length--;var tmp=this.items[pKey];delete this.items[pKey];}
return tmp;}
this.getItem=function(pKey)
{return this.items[pKey];}
this.hasItem=function(pKey)
{return typeof(this.items[pKey])!='undefined';}
this.removeOldestItem=function()
{this.removeItem(this.keys.shift());}
this.clear=function()
{var tmp=this.cache_length;this.keys=new Array();this.cache_length=0;this.items=new Array();return tmp;}
jQuery.jCache=this;return jQuery;})(jQuery);(function($){$.alerts={verticalOffset:-75,horizontalOffset:0,repositionOnResize:true,overlayOpacity:.01,overlayColor:'#FFF',draggable:true,okButton:'&nbsp;OK&nbsp;',cancelButton:'&nbsp;Cancel&nbsp;',dialogClass:null,alert:function(message,title,callback){if(title==null)title='Alert';$.alerts._show(title,message,null,'alert',function(result){if(callback)callback(result);});},confirm:function(message,title,callback){if(title==null)title='Confirm';$.alerts._show(title,message,null,'confirm',function(result){if(callback)callback(result);});},prompt:function(message,value,title,callback){if(title==null)title='Prompt';$.alerts._show(title,message,value,'prompt',function(result){if(callback)callback(result);});},_show:function(title,msg,value,type,callback){$.alerts._hide();$.alerts._overlay('show');$("BODY").append('<div id="popup_container">'+
'<h1 id="popup_title"></h1>'+
'<div id="popup_content">'+
'<div id="popup_message"></div>'+
'</div>'+
'</div>');if($.alerts.dialogClass)$("#popup_container").addClass($.alerts.dialogClass);var pos=($.browser.msie&&parseInt($.browser.version)<=6)?'absolute':'fixed';$("#popup_container").css({position:pos,zIndex:99999,padding:0,margin:0});$("#popup_title").text(title);$("#popup_content").addClass(type);$("#popup_message").text(msg);$("#popup_message").html($("#popup_message").text().replace(/\n/g,'<br />'));$("#popup_container").css({minWidth:$("#popup_container").outerWidth(),maxWidth:$("#popup_container").outerWidth()});$.alerts._reposition();$.alerts._maintainPosition(true);switch(type){case'alert':$("#popup_message").after('<div id="popup_panel"><input type="button" value="'+$.alerts.okButton+'" id="popup_ok" /></div>');$("#popup_ok").click(function(){$.alerts._hide();callback(true);});$("#popup_ok").focus().keypress(function(e){if(e.keyCode==13||e.keyCode==27)$("#popup_ok").trigger('click');});break;case'confirm':$("#popup_message").after('<div id="popup_panel"><input type="button" value="'+$.alerts.okButton+'" id="popup_ok" /> <input type="button" value="'+$.alerts.cancelButton+'" id="popup_cancel" /></div>');$("#popup_ok").click(function(){$.alerts._hide();if(callback)callback(true);});$("#popup_cancel").click(function(){$.alerts._hide();if(callback)callback(false);});$("#popup_ok").focus();$("#popup_ok, #popup_cancel").keypress(function(e){if(e.keyCode==13)$("#popup_ok").trigger('click');if(e.keyCode==27)$("#popup_cancel").trigger('click');});break;case'prompt':$("#popup_message").append('<br /><input type="text" size="30" id="popup_prompt" />').after('<div id="popup_panel"><input type="button" value="'+$.alerts.okButton+'" id="popup_ok" /> <input type="button" value="'+$.alerts.cancelButton+'" id="popup_cancel" /></div>');$("#popup_prompt").width($("#popup_message").width());$("#popup_ok").click(function(){var val=$("#popup_prompt").val();$.alerts._hide();if(callback)callback(val);});$("#popup_cancel").click(function(){$.alerts._hide();if(callback)callback(null);});$("#popup_prompt, #popup_ok, #popup_cancel").keypress(function(e){if(e.keyCode==13)$("#popup_ok").trigger('click');if(e.keyCode==27)$("#popup_cancel").trigger('click');});if(value)$("#popup_prompt").val(value);$("#popup_prompt").focus().select();break;}
if($.alerts.draggable){try{$("#popup_container").draggable({handle:$("#popup_title")});$("#popup_title").css({cursor:'move'});}catch(e){}}},_hide:function(){$("#popup_container").remove();$.alerts._overlay('hide');$.alerts._maintainPosition(false);},_overlay:function(status){switch(status){case'show':$.alerts._overlay('hide');$("BODY").append('<div id="popup_overlay"></div>');$("#popup_overlay").css({position:'absolute',zIndex:99998,top:'0px',left:'0px',width:'100%',height:$(document).height(),background:$.alerts.overlayColor,opacity:$.alerts.overlayOpacity});break;case'hide':$("#popup_overlay").remove();break;}},_reposition:function(){var top=(($(window).height()/2)-($("#popup_container").outerHeight()/2))+$.alerts.verticalOffset;var left=(($(window).width()/2)-($("#popup_container").outerWidth()/2))+$.alerts.horizontalOffset;if(top<0)top=0;if(left<0)left=0;if($.browser.msie&&parseInt($.browser.version)<=6)top=top+$(window).scrollTop();$("#popup_container").css({top:top+'px',left:left+'px'});$("#popup_overlay").height($(document).height());},_maintainPosition:function(status){if($.alerts.repositionOnResize){switch(status){case true:$(window).bind('resize',$.alerts._reposition);break;case false:$(window).unbind('resize',$.alerts._reposition);break;}}}}
jAlert=function(message,title,callback){$.alerts.alert(message,title,callback);}
jConfirm=function(message,title,callback){$.alerts.confirm(message,title,callback);};jPrompt=function(message,value,title,callback){$.alerts.prompt(message,value,title,callback);};})(jQuery);(function($,window,document){$.fn.dataTableSettings=[];var _aoSettings=$.fn.dataTableSettings;$.fn.dataTableExt={};var _oExt=$.fn.dataTableExt;_oExt.sVersion="1.7.6";_oExt.sErrMode="alert";_oExt.iApiIndex=0;_oExt.oApi={};_oExt.afnFiltering=[];_oExt.aoFeatures=[];_oExt.ofnSearch={};_oExt.afnSortData=[];_oExt.oStdClasses={"sPagePrevEnabled":"paginate_enabled_previous","sPagePrevDisabled":"paginate_disabled_previous","sPageNextEnabled":"paginate_enabled_next","sPageNextDisabled":"paginate_disabled_next","sPageJUINext":"","sPageJUIPrev":"","sPageButton":"paginate_button","sPageButtonActive":"paginate_active","sPageButtonStaticDisabled":"paginate_button","sPageFirst":"first","sPagePrevious":"previous","sPageNext":"next","sPageLast":"last","sStripOdd":"odd","sStripEven":"even","sRowEmpty":"dataTables_empty","sWrapper":"dataTables_wrapper","sFilter":"dataTables_filter","sInfo":"dataTables_info","sPaging":"dataTables_paginate paging_","sLength":"dataTables_length","sProcessing":"dataTables_processing","sSortAsc":"sorting_asc","sSortDesc":"sorting_desc","sSortable":"sorting","sSortableAsc":"sorting_asc_disabled","sSortableDesc":"sorting_desc_disabled","sSortableNone":"sorting_disabled","sSortColumn":"sorting_","sSortJUIAsc":"","sSortJUIDesc":"","sSortJUI":"","sSortJUIAscAllowed":"","sSortJUIDescAllowed":"","sSortJUIWrapper":"","sScrollWrapper":"dataTables_scroll","sScrollHead":"dataTables_scrollHead","sScrollHeadInner":"dataTables_scrollHeadInner","sScrollBody":"dataTables_scrollBody","sScrollFoot":"dataTables_scrollFoot","sScrollFootInner":"dataTables_scrollFootInner","sFooterTH":""};_oExt.oJUIClasses={"sPagePrevEnabled":"fg-button ui-button ui-state-default ui-corner-left","sPagePrevDisabled":"fg-button ui-button ui-state-default ui-corner-left ui-state-disabled","sPageNextEnabled":"fg-button ui-button ui-state-default ui-corner-right","sPageNextDisabled":"fg-button ui-button ui-state-default ui-corner-right ui-state-disabled","sPageJUINext":"ui-icon ui-icon-circle-arrow-e","sPageJUIPrev":"ui-icon ui-icon-circle-arrow-w","sPageButton":"fg-button ui-button ui-state-default","sPageButtonActive":"fg-button ui-button ui-state-default ui-state-disabled","sPageButtonStaticDisabled":"fg-button ui-button ui-state-default ui-state-disabled","sPageFirst":"first ui-corner-tl ui-corner-bl","sPagePrevious":"previous","sPageNext":"next","sPageLast":"last ui-corner-tr ui-corner-br","sStripOdd":"odd","sStripEven":"even","sRowEmpty":"dataTables_empty","sWrapper":"dataTables_wrapper","sFilter":"dataTables_filter","sInfo":"dataTables_info","sPaging":"dataTables_paginate fg-buttonset ui-buttonset fg-buttonset-multi "+
"ui-buttonset-multi paging_","sLength":"dataTables_length","sProcessing":"dataTables_processing","sSortAsc":"ui-state-default","sSortDesc":"ui-state-default","sSortable":"ui-state-default","sSortableAsc":"ui-state-default","sSortableDesc":"ui-state-default","sSortableNone":"ui-state-default","sSortColumn":"sorting_","sSortJUIAsc":"css_right ui-icon ui-icon-triangle-1-n","sSortJUIDesc":"css_right ui-icon ui-icon-triangle-1-s","sSortJUI":"css_right ui-icon ui-icon-carat-2-n-s","sSortJUIAscAllowed":"css_right ui-icon ui-icon-carat-1-n","sSortJUIDescAllowed":"css_right ui-icon ui-icon-carat-1-s","sSortJUIWrapper":"DataTables_sort_wrapper","sScrollWrapper":"dataTables_scroll","sScrollHead":"dataTables_scrollHead ui-state-default","sScrollHeadInner":"dataTables_scrollHeadInner","sScrollBody":"dataTables_scrollBody","sScrollFoot":"dataTables_scrollFoot ui-state-default","sScrollFootInner":"dataTables_scrollFootInner","sFooterTH":"ui-state-default"};_oExt.oPagination={"two_button":{"fnInit":function(oSettings,nPaging,fnCallbackDraw)
{var nPrevious,nNext,nPreviousInner,nNextInner;if(!oSettings.bJUI)
{nPrevious=document.createElement('div');nNext=document.createElement('div');}
else
{nPrevious=document.createElement('a');nNext=document.createElement('a');nNextInner=document.createElement('span');nNextInner.className=oSettings.oClasses.sPageJUINext;nNext.appendChild(nNextInner);nPreviousInner=document.createElement('span');nPreviousInner.className=oSettings.oClasses.sPageJUIPrev;nPrevious.appendChild(nPreviousInner);}
nPrevious.className=oSettings.oClasses.sPagePrevDisabled;nNext.className=oSettings.oClasses.sPageNextDisabled;nPrevious.title=oSettings.oLanguage.oPaginate.sPrevious;nNext.title=oSettings.oLanguage.oPaginate.sNext;nPaging.appendChild(nPrevious);nPaging.appendChild(nNext);$(nPrevious).bind('click.DT',function(){if(oSettings.oApi._fnPageChange(oSettings,"previous"))
{fnCallbackDraw(oSettings);}});$(nNext).bind('click.DT',function(){if(oSettings.oApi._fnPageChange(oSettings,"next"))
{fnCallbackDraw(oSettings);}});$(nPrevious).bind('selectstart.DT',function(){return false;});$(nNext).bind('selectstart.DT',function(){return false;});if(oSettings.sTableId!==''&&typeof oSettings.aanFeatures.p=="undefined")
{nPaging.setAttribute('id',oSettings.sTableId+'_paginate');nPrevious.setAttribute('id',oSettings.sTableId+'_previous');nNext.setAttribute('id',oSettings.sTableId+'_next');}},"fnUpdate":function(oSettings,fnCallbackDraw)
{if(!oSettings.aanFeatures.p)
{return;}
var an=oSettings.aanFeatures.p;for(var i=0,iLen=an.length;i<iLen;i++)
{if(an[i].childNodes.length!==0)
{an[i].childNodes[0].className=(oSettings._iDisplayStart===0)?oSettings.oClasses.sPagePrevDisabled:oSettings.oClasses.sPagePrevEnabled;an[i].childNodes[1].className=(oSettings.fnDisplayEnd()==oSettings.fnRecordsDisplay())?oSettings.oClasses.sPageNextDisabled:oSettings.oClasses.sPageNextEnabled;}}}},"iFullNumbersShowPages":5,"full_numbers":{"fnInit":function(oSettings,nPaging,fnCallbackDraw)
{var nFirst=document.createElement('span');var nPrevious=document.createElement('span');var nList=document.createElement('span');var nNext=document.createElement('span');var nLast=document.createElement('span');nFirst.innerHTML=oSettings.oLanguage.oPaginate.sFirst;nPrevious.innerHTML=oSettings.oLanguage.oPaginate.sPrevious;nNext.innerHTML=oSettings.oLanguage.oPaginate.sNext;nLast.innerHTML=oSettings.oLanguage.oPaginate.sLast;var oClasses=oSettings.oClasses;nFirst.className=oClasses.sPageButton+" "+oClasses.sPageFirst;nPrevious.className=oClasses.sPageButton+" "+oClasses.sPagePrevious;nNext.className=oClasses.sPageButton+" "+oClasses.sPageNext;nLast.className=oClasses.sPageButton+" "+oClasses.sPageLast;nPaging.appendChild(nFirst);nPaging.appendChild(nPrevious);nPaging.appendChild(nList);nPaging.appendChild(nNext);nPaging.appendChild(nLast);$(nFirst).bind('click.DT',function(){if(oSettings.oApi._fnPageChange(oSettings,"first"))
{fnCallbackDraw(oSettings);}});$(nPrevious).bind('click.DT',function(){if(oSettings.oApi._fnPageChange(oSettings,"previous"))
{fnCallbackDraw(oSettings);}});$(nNext).bind('click.DT',function(){if(oSettings.oApi._fnPageChange(oSettings,"next"))
{fnCallbackDraw(oSettings);}});$(nLast).bind('click.DT',function(){if(oSettings.oApi._fnPageChange(oSettings,"last"))
{fnCallbackDraw(oSettings);}});$('span',nPaging)
.bind('mousedown.DT',function(){return false;})
.bind('selectstart.DT',function(){return false;});if(oSettings.sTableId!==''&&typeof oSettings.aanFeatures.p=="undefined")
{nPaging.setAttribute('id',oSettings.sTableId+'_paginate');nFirst.setAttribute('id',oSettings.sTableId+'_first');nPrevious.setAttribute('id',oSettings.sTableId+'_previous');nNext.setAttribute('id',oSettings.sTableId+'_next');nLast.setAttribute('id',oSettings.sTableId+'_last');}},"fnUpdate":function(oSettings,fnCallbackDraw)
{if(!oSettings.aanFeatures.p)
{return;}
var iPageCount=_oExt.oPagination.iFullNumbersShowPages;var iPageCountHalf=Math.floor(iPageCount/2);var iPages=Math.ceil((oSettings.fnRecordsDisplay())/oSettings._iDisplayLength);var iCurrentPage=Math.ceil(oSettings._iDisplayStart/oSettings._iDisplayLength)+1;var sList="";var iStartButton,iEndButton,i,iLen;var oClasses=oSettings.oClasses;if(iPages<iPageCount)
{iStartButton=1;iEndButton=iPages;}
else
{if(iCurrentPage<=iPageCountHalf)
{iStartButton=1;iEndButton=iPageCount;}
else
{if(iCurrentPage>=(iPages-iPageCountHalf))
{iStartButton=iPages-iPageCount+1;iEndButton=iPages;}
else
{iStartButton=iCurrentPage-Math.ceil(iPageCount/2)+1;iEndButton=iStartButton+iPageCount-1;}}}
for(i=iStartButton;i<=iEndButton;i++)
{if(iCurrentPage!=i)
{sList+='<span class="'+oClasses.sPageButton+'">'+i+'</span>';}
else
{sList+='<span class="'+oClasses.sPageButtonActive+'">'+i+'</span>';}}
var an=oSettings.aanFeatures.p;var anButtons,anStatic,nPaginateList;var fnClick=function(){var iTarget=(this.innerHTML*1)-1;oSettings._iDisplayStart=iTarget*oSettings._iDisplayLength;fnCallbackDraw(oSettings);return false;};var fnFalse=function(){return false;};for(i=0,iLen=an.length;i<iLen;i++)
{if(an[i].childNodes.length===0)
{continue;}
var qjPaginateList=$('span:eq(2)',an[i]);qjPaginateList.html(sList);$('span',qjPaginateList).bind('click.DT',fnClick).bind('mousedown.DT',fnFalse)
.bind('selectstart.DT',fnFalse);anButtons=an[i].getElementsByTagName('span');anStatic=[anButtons[0],anButtons[1],anButtons[anButtons.length-2],anButtons[anButtons.length-1]];$(anStatic).removeClass(oClasses.sPageButton+" "+oClasses.sPageButtonActive+" "+oClasses.sPageButtonStaticDisabled);if(iCurrentPage==1)
{anStatic[0].className+=" "+oClasses.sPageButtonStaticDisabled;anStatic[1].className+=" "+oClasses.sPageButtonStaticDisabled;}
else
{anStatic[0].className+=" "+oClasses.sPageButton;anStatic[1].className+=" "+oClasses.sPageButton;}
if(iPages===0||iCurrentPage==iPages||oSettings._iDisplayLength==-1)
{anStatic[2].className+=" "+oClasses.sPageButtonStaticDisabled;anStatic[3].className+=" "+oClasses.sPageButtonStaticDisabled;}
else
{anStatic[2].className+=" "+oClasses.sPageButton;anStatic[3].className+=" "+oClasses.sPageButton;}}}}};_oExt.oSort={"string-asc":function(a,b)
{var x=a.toLowerCase();var y=b.toLowerCase();return((x<y)?-1:((x>y)?1:0));},"string-desc":function(a,b)
{var x=a.toLowerCase();var y=b.toLowerCase();return((x<y)?1:((x>y)?-1:0));},"html-asc":function(a,b)
{var x=a.replace(/<.*?>/g,"").toLowerCase();var y=b.replace(/<.*?>/g,"").toLowerCase();return((x<y)?-1:((x>y)?1:0));},"html-desc":function(a,b)
{var x=a.replace(/<.*?>/g,"").toLowerCase();var y=b.replace(/<.*?>/g,"").toLowerCase();return((x<y)?1:((x>y)?-1:0));},"date-asc":function(a,b)
{var x=Date.parse(a);var y=Date.parse(b);if(isNaN(x)||x==="")
{x=Date.parse("01/01/1970 00:00:00");}
if(isNaN(y)||y==="")
{y=Date.parse("01/01/1970 00:00:00");}
return x-y;},"date-desc":function(a,b)
{var x=Date.parse(a);var y=Date.parse(b);if(isNaN(x)||x==="")
{x=Date.parse("01/01/1970 00:00:00");}
if(isNaN(y)||y==="")
{y=Date.parse("01/01/1970 00:00:00");}
return y-x;},"numeric-asc":function(a,b)
{var x=(a=="-"||a==="")?0:a*1;var y=(b=="-"||b==="")?0:b*1;return x-y;},"numeric-desc":function(a,b)
{var x=(a=="-"||a==="")?0:a*1;var y=(b=="-"||b==="")?0:b*1;return y-x;}};_oExt.aTypes=[function(sData)
{if(sData.length===0)
{return'numeric';}
var sValidFirstChars="0123456789-";var sValidChars="0123456789.";var Char;var bDecimal=false;Char=sData.charAt(0);if(sValidFirstChars.indexOf(Char)==-1)
{return null;}
for(var i=1;i<sData.length;i++)
{Char=sData.charAt(i);if(sValidChars.indexOf(Char)==-1)
{return null;}
if(Char==".")
{if(bDecimal)
{return null;}
bDecimal=true;}}
return'numeric';},function(sData)
{var iParse=Date.parse(sData);if((iParse!==null&&!isNaN(iParse))||sData.length===0)
{return'date';}
return null;},function(sData)
{if(sData.indexOf('<')!=-1&&sData.indexOf('>')!=-1)
{return'html';}
return null;}];_oExt.fnVersionCheck=function(sVersion)
{var fnZPad=function(Zpad,count)
{while(Zpad.length<count){Zpad+='0';}
return Zpad;};var aThis=_oExt.sVersion.split('.');var aThat=sVersion.split('.');var sThis='',sThat='';for(var i=0,iLen=aThat.length;i<iLen;i++)
{sThis+=fnZPad(aThis[i],3);sThat+=fnZPad(aThat[i],3);}
return parseInt(sThis,10)>=parseInt(sThat,10);};_oExt._oExternConfig={"iNextUnique":0};$.fn.dataTable=function(oInit)
{function classSettings()
{this.fnRecordsTotal=function()
{if(this.oFeatures.bServerSide){return parseInt(this._iRecordsTotal,10);}else{return this.aiDisplayMaster.length;}};this.fnRecordsDisplay=function()
{if(this.oFeatures.bServerSide){return parseInt(this._iRecordsDisplay,10);}else{return this.aiDisplay.length;}};this.fnDisplayEnd=function()
{if(this.oFeatures.bServerSide){if(this.oFeatures.bPaginate===false||this._iDisplayLength==-1){return this._iDisplayStart+this.aiDisplay.length;}else{return Math.min(this._iDisplayStart+this._iDisplayLength,this._iRecordsDisplay);}}else{return this._iDisplayEnd;}};this.oInstance=null;this.sInstance=null;this.oFeatures={"bPaginate":true,"bLengthChange":true,"bFilter":true,"bSort":true,"bInfo":true,"bAutoWidth":true,"bProcessing":false,"bSortClasses":true,"bStateSave":false,"bServerSide":false};this.oScroll={"sX":"","sXInner":"","sY":"","bCollapse":false,"bInfinite":false,"iLoadGap":100,"iBarWidth":0,"bAutoCss":true};this.aanFeatures=[];this.oLanguage={"sProcessing":"Processing...","sLengthMenu":"Show _MENU_ entries","sZeroRecords":"No matching records found","sEmptyTable":"No data available in table","sInfo":"Showing _START_ to _END_ of _TOTAL_ entries","sInfoEmpty":"Showing 0 to 0 of 0 entries","sInfoFiltered":"(filtered from _MAX_ total entries)","sInfoPostFix":"","sSearch":"Search:","sUrl":"","oPaginate":{"sFirst":"First","sPrevious":"Previous","sNext":"Next","sLast":"Last"},"fnInfoCallback":null};this.aoData=[];this.aiDisplay=[];this.aiDisplayMaster=[];this.aoColumns=[];this.iNextId=0;this.asDataSearch=[];this.oPreviousSearch={"sSearch":"","bRegex":false,"bSmart":true};this.aoPreSearchCols=[];this.aaSorting=[[0,'asc',0]];this.aaSortingFixed=null;this.asStripClasses=[];this.asDestoryStrips=[];this.sDestroyWidth=0;this.fnRowCallback=null;this.fnHeaderCallback=null;this.fnFooterCallback=null;this.aoDrawCallback=[];this.fnInitComplete=null;this.sTableId="";this.nTable=null;this.nTHead=null;this.nTFoot=null;this.nTBody=null;this.nTableWrapper=null;this.bInitialised=false;this.aoOpenRows=[];this.sDom='lfrtip';this.sPaginationType="two_button";this.iCookieDuration=60*60*2;this.sCookiePrefix="SpryMedia_DataTables_";this.fnCookieCallback=null;this.aoStateSave=[];this.aoStateLoad=[];this.oLoadedState=null;this.sAjaxSource=null;this.bAjaxDataGet=true;this.fnServerData=function(url,data,callback){$.ajax({"url":url,"data":data,"success":callback,"dataType":"json","cache":false,"error":function(xhr,error,thrown){if(error=="parsererror"){alert("DataTables warning: JSON data from server could not be parsed. "+
"This is caused by a JSON formatting error.");}}});};this.fnFormatNumber=function(iIn)
{if(iIn<1000)
{return iIn;}
else
{var s=(iIn+""),a=s.split(""),out="",iLen=s.length;for(var i=0;i<iLen;i++)
{if(i%3===0&&i!==0)
{out=','+out;}
out=a[iLen-i-1]+out;}}
return out;};this.aLengthMenu=[10,25,50,100];this.iDraw=0;this.bDrawing=0;this.iDrawError=-1;this._iDisplayLength=10;this._iDisplayStart=0;this._iDisplayEnd=10;this._iRecordsTotal=0;this._iRecordsDisplay=0;this.bJUI=false;this.oClasses=_oExt.oStdClasses;this.bFiltered=false;this.bSorted=false;this.oInit=null;}
this.oApi={};this.fnDraw=function(bComplete)
{var oSettings=_fnSettingsFromNode(this[_oExt.iApiIndex]);if(typeof bComplete!='undefined'&&bComplete===false)
{_fnCalculateEnd(oSettings);_fnDraw(oSettings);}
else
{_fnReDraw(oSettings);}};this.fnFilter=function(sInput,iColumn,bRegex,bSmart,bShowGlobal)
{var oSettings=_fnSettingsFromNode(this[_oExt.iApiIndex]);if(!oSettings.oFeatures.bFilter)
{return;}
if(typeof bRegex=='undefined')
{bRegex=false;}
if(typeof bSmart=='undefined')
{bSmart=true;}
if(typeof bShowGlobal=='undefined')
{bShowGlobal=true;}
if(typeof iColumn=="undefined"||iColumn===null)
{_fnFilterComplete(oSettings,{"sSearch":sInput,"bRegex":bRegex,"bSmart":bSmart},1);if(bShowGlobal&&typeof oSettings.aanFeatures.f!='undefined')
{var n=oSettings.aanFeatures.f;for(var i=0,iLen=n.length;i<iLen;i++)
{$('input',n[i]).val(sInput);}}}
else
{oSettings.aoPreSearchCols[iColumn].sSearch=sInput;oSettings.aoPreSearchCols[iColumn].bRegex=bRegex;oSettings.aoPreSearchCols[iColumn].bSmart=bSmart;_fnFilterComplete(oSettings,oSettings.oPreviousSearch,1);}};this.fnSettings=function(nNode)
{return _fnSettingsFromNode(this[_oExt.iApiIndex]);};this.fnVersionCheck=_oExt.fnVersionCheck;this.fnSort=function(aaSort)
{var oSettings=_fnSettingsFromNode(this[_oExt.iApiIndex]);oSettings.aaSorting=aaSort;_fnSort(oSettings);};this.fnSortListener=function(nNode,iColumn,fnCallback)
{_fnSortAttachListener(_fnSettingsFromNode(this[_oExt.iApiIndex]),nNode,iColumn,fnCallback);};this.fnAddData=function(mData,bRedraw)
{if(mData.length===0)
{return[];}
var aiReturn=[];var iTest;var oSettings=_fnSettingsFromNode(this[_oExt.iApiIndex]);if(typeof mData[0]=="object")
{for(var i=0;i<mData.length;i++)
{iTest=_fnAddData(oSettings,mData[i]);if(iTest==-1)
{return aiReturn;}
aiReturn.push(iTest);}}
else
{iTest=_fnAddData(oSettings,mData);if(iTest==-1)
{return aiReturn;}
aiReturn.push(iTest);}
oSettings.aiDisplay=oSettings.aiDisplayMaster.slice();if(typeof bRedraw=='undefined'||bRedraw)
{_fnReDraw(oSettings);}
return aiReturn;};this.fnDeleteRow=function(mTarget,fnCallBack,bRedraw)
{var oSettings=_fnSettingsFromNode(this[_oExt.iApiIndex]);var i,iAODataIndex;iAODataIndex=(typeof mTarget=='object')?_fnNodeToDataIndex(oSettings,mTarget):mTarget;var oData=oSettings.aoData.splice(iAODataIndex,1);var iDisplayIndex=$.inArray(iAODataIndex,oSettings.aiDisplay);oSettings.asDataSearch.splice(iDisplayIndex,1);_fnDeleteIndex(oSettings.aiDisplayMaster,iAODataIndex);_fnDeleteIndex(oSettings.aiDisplay,iAODataIndex);if(typeof fnCallBack=="function")
{fnCallBack.call(this,oSettings,oData);}
if(oSettings._iDisplayStart>=oSettings.aiDisplay.length)
{oSettings._iDisplayStart-=oSettings._iDisplayLength;if(oSettings._iDisplayStart<0)
{oSettings._iDisplayStart=0;}}
if(typeof bRedraw=='undefined'||bRedraw)
{_fnCalculateEnd(oSettings);_fnDraw(oSettings);}
return oData;};this.fnClearTable=function(bRedraw)
{var oSettings=_fnSettingsFromNode(this[_oExt.iApiIndex]);_fnClearTable(oSettings);if(typeof bRedraw=='undefined'||bRedraw)
{_fnDraw(oSettings);}};this.fnOpen=function(nTr,sHtml,sClass)
{var oSettings=_fnSettingsFromNode(this[_oExt.iApiIndex]);this.fnClose(nTr);var nNewRow=document.createElement("tr");var nNewCell=document.createElement("td");nNewRow.appendChild(nNewCell);nNewCell.className=sClass;nNewCell.colSpan=_fnVisbleColumns(oSettings);nNewCell.innerHTML=sHtml;var nTrs=$('tr',oSettings.nTBody);if($.inArray(nTr,nTrs)!=-1)
{$(nNewRow).insertAfter(nTr);}
oSettings.aoOpenRows.push({"nTr":nNewRow,"nParent":nTr});return nNewRow;};this.fnClose=function(nTr)
{var oSettings=_fnSettingsFromNode(this[_oExt.iApiIndex]);for(var i=0;i<oSettings.aoOpenRows.length;i++)
{if(oSettings.aoOpenRows[i].nParent==nTr)
{var nTrParent=oSettings.aoOpenRows[i].nTr.parentNode;if(nTrParent)
{nTrParent.removeChild(oSettings.aoOpenRows[i].nTr);}
oSettings.aoOpenRows.splice(i,1);return 0;}}
return 1;};this.fnGetData=function(mRow)
{var oSettings=_fnSettingsFromNode(this[_oExt.iApiIndex]);if(typeof mRow!='undefined')
{var iRow=(typeof mRow=='object')?_fnNodeToDataIndex(oSettings,mRow):mRow;return((aRowData=oSettings.aoData[iRow])?aRowData._aData:null);}
return _fnGetDataMaster(oSettings);};this.fnGetNodes=function(iRow)
{var oSettings=_fnSettingsFromNode(this[_oExt.iApiIndex]);if(typeof iRow!='undefined')
{return((aRowData=oSettings.aoData[iRow])?aRowData.nTr:null);}
return _fnGetTrNodes(oSettings);};this.fnGetPosition=function(nNode)
{var oSettings=_fnSettingsFromNode(this[_oExt.iApiIndex]);var i;if(nNode.nodeName.toUpperCase()=="TR")
{return _fnNodeToDataIndex(oSettings,nNode);}
else if(nNode.nodeName.toUpperCase()=="TD")
{var iDataIndex=_fnNodeToDataIndex(oSettings,nNode.parentNode);var iCorrector=0;for(var j=0;j<oSettings.aoColumns.length;j++)
{if(oSettings.aoColumns[j].bVisible)
{if(oSettings.aoData[iDataIndex].nTr.getElementsByTagName('td')[j-iCorrector]==nNode)
{return[iDataIndex,j-iCorrector,j];}}
else
{iCorrector++;}}}
return null;};this.fnUpdate=function(mData,mRow,iColumn,bRedraw,bAction)
{var oSettings=_fnSettingsFromNode(this[_oExt.iApiIndex]);var iVisibleColumn;var sDisplay;var iRow=(typeof mRow=='object')?_fnNodeToDataIndex(oSettings,mRow):mRow;if(typeof mData!='object')
{sDisplay=mData;oSettings.aoData[iRow]._aData[iColumn]=sDisplay;if(oSettings.aoColumns[iColumn].fnRender!==null)
{sDisplay=oSettings.aoColumns[iColumn].fnRender({"iDataRow":iRow,"iDataColumn":iColumn,"aData":oSettings.aoData[iRow]._aData,"oSettings":oSettings});if(oSettings.aoColumns[iColumn].bUseRendered)
{oSettings.aoData[iRow]._aData[iColumn]=sDisplay;}}
iVisibleColumn=_fnColumnIndexToVisible(oSettings,iColumn);if(iVisibleColumn!==null)
{oSettings.aoData[iRow].nTr.getElementsByTagName('td')[iVisibleColumn].innerHTML=sDisplay;}
else
{oSettings.aoData[iRow]._anHidden[iColumn].innerHTML=sDisplay;}}
else
{if(mData.length!=oSettings.aoColumns.length)
{_fnLog(oSettings,0,'An array passed to fnUpdate must have the same number of '+
'columns as the table in question - in this case '+oSettings.aoColumns.length);return 1;}
for(var i=0;i<mData.length;i++)
{sDisplay=mData[i];oSettings.aoData[iRow]._aData[i]=sDisplay;if(oSettings.aoColumns[i].fnRender!==null)
{sDisplay=oSettings.aoColumns[i].fnRender({"iDataRow":iRow,"iDataColumn":i,"aData":oSettings.aoData[iRow]._aData,"oSettings":oSettings});if(oSettings.aoColumns[i].bUseRendered)
{oSettings.aoData[iRow]._aData[i]=sDisplay;}}
iVisibleColumn=_fnColumnIndexToVisible(oSettings,i);if(iVisibleColumn!==null)
{oSettings.aoData[iRow].nTr.getElementsByTagName('td')[iVisibleColumn].innerHTML=sDisplay;}
else
{oSettings.aoData[iRow]._anHidden[i].innerHTML=sDisplay;}}}
var iDisplayIndex=$.inArray(iRow,oSettings.aiDisplay);oSettings.asDataSearch[iDisplayIndex]=_fnBuildSearchRow(oSettings,oSettings.aoData[iRow]._aData);if(typeof bAction=='undefined'||bAction)
{_fnAjustColumnSizing(oSettings);}
if(typeof bRedraw=='undefined'||bRedraw)
{_fnReDraw(oSettings);}
return 0;};this.fnSetColumnVis=function(iCol,bShow,bRedraw)
{var oSettings=_fnSettingsFromNode(this[_oExt.iApiIndex]);var i,iLen;var iColumns=oSettings.aoColumns.length;var nTd,anTds,nCell,anTrs,jqChildren;if(oSettings.aoColumns[iCol].bVisible==bShow)
{return;}
var nTrHead=$('>tr',oSettings.nTHead)[0];var nTrFoot=$('>tr',oSettings.nTFoot)[0];var anTheadTh=[];var anTfootTh=[];for(i=0;i<iColumns;i++)
{anTheadTh.push(oSettings.aoColumns[i].nTh);anTfootTh.push(oSettings.aoColumns[i].nTf);}
if(bShow)
{var iInsert=0;for(i=0;i<iCol;i++)
{if(oSettings.aoColumns[i].bVisible)
{iInsert++;}}
if(iInsert>=_fnVisbleColumns(oSettings))
{nTrHead.appendChild(anTheadTh[iCol]);anTrs=$('>tr',oSettings.nTHead);for(i=1,iLen=anTrs.length;i<iLen;i++)
{anTrs[i].appendChild(oSettings.aoColumns[iCol].anThExtra[i-1]);}
if(nTrFoot)
{nTrFoot.appendChild(anTfootTh[iCol]);anTrs=$('>tr',oSettings.nTFoot);for(i=1,iLen=anTrs.length;i<iLen;i++)
{anTrs[i].appendChild(oSettings.aoColumns[iCol].anTfExtra[i-1]);}}
for(i=0,iLen=oSettings.aoData.length;i<iLen;i++)
{nTd=oSettings.aoData[i]._anHidden[iCol];oSettings.aoData[i].nTr.appendChild(nTd);}}
else
{var iBefore;for(i=iCol;i<iColumns;i++)
{iBefore=_fnColumnIndexToVisible(oSettings,i);if(iBefore!==null)
{break;}}
nTrHead.insertBefore(anTheadTh[iCol],nTrHead.getElementsByTagName('th')[iBefore]);anTrs=$('>tr',oSettings.nTHead);for(i=1,iLen=anTrs.length;i<iLen;i++)
{jqChildren=$(anTrs[i]).children();anTrs[i].insertBefore(oSettings.aoColumns[iCol].anThExtra[i-1],jqChildren[iBefore]);}
if(nTrFoot)
{nTrFoot.insertBefore(anTfootTh[iCol],nTrFoot.getElementsByTagName('th')[iBefore]);anTrs=$('>tr',oSettings.nTFoot);for(i=1,iLen=anTrs.length;i<iLen;i++)
{jqChildren=$(anTrs[i]).children();anTrs[i].insertBefore(oSettings.aoColumns[iCol].anTfExtra[i-1],jqChildren[iBefore]);}}
anTds=_fnGetTdNodes(oSettings);for(i=0,iLen=oSettings.aoData.length;i<iLen;i++)
{nTd=oSettings.aoData[i]._anHidden[iCol];oSettings.aoData[i].nTr.insertBefore(nTd,$('>td:eq('+iBefore+')',oSettings.aoData[i].nTr)[0]);}}
oSettings.aoColumns[iCol].bVisible=true;}
else
{nTrHead.removeChild(anTheadTh[iCol]);for(i=0,iLen=oSettings.aoColumns[iCol].anThExtra.length;i<iLen;i++)
{nCell=oSettings.aoColumns[iCol].anThExtra[i];nCell.parentNode.removeChild(nCell);}
if(nTrFoot)
{nTrFoot.removeChild(anTfootTh[iCol]);for(i=0,iLen=oSettings.aoColumns[iCol].anTfExtra.length;i<iLen;i++)
{nCell=oSettings.aoColumns[iCol].anTfExtra[i];nCell.parentNode.removeChild(nCell);}}
anTds=_fnGetTdNodes(oSettings);for(i=0,iLen=oSettings.aoData.length;i<iLen;i++)
{nTd=anTds[(i*oSettings.aoColumns.length)+(iCol*1)];oSettings.aoData[i]._anHidden[iCol]=nTd;nTd.parentNode.removeChild(nTd);}
oSettings.aoColumns[iCol].bVisible=false;}
for(i=0,iLen=oSettings.aoOpenRows.length;i<iLen;i++)
{oSettings.aoOpenRows[i].nTr.colSpan=_fnVisbleColumns(oSettings);}
if(typeof bRedraw=='undefined'||bRedraw)
{_fnAjustColumnSizing(oSettings);_fnDraw(oSettings);}
_fnSaveState(oSettings);};this.fnPageChange=function(sAction,bRedraw)
{var oSettings=_fnSettingsFromNode(this[_oExt.iApiIndex]);_fnPageChange(oSettings,sAction);_fnCalculateEnd(oSettings);if(typeof bRedraw=='undefined'||bRedraw)
{_fnDraw(oSettings);}};this.fnDestroy=function()
{var oSettings=_fnSettingsFromNode(this[_oExt.iApiIndex]);var nOrig=oSettings.nTableWrapper.parentNode;var nBody=oSettings.nTBody;var i,iLen;oSettings.bDestroying=true;$(oSettings.nTableWrapper).find('*').andSelf().unbind('.DT');for(i=0,iLen=oSettings.aoColumns.length;i<iLen;i++)
{if(oSettings.aoColumns[i].bVisible===false)
{this.fnSetColumnVis(i,true);}}
$('tbody>tr>td.'+oSettings.oClasses.sRowEmpty,oSettings.nTable).parent().remove();if(oSettings.nTable!=oSettings.nTHead.parentNode)
{$('>thead',oSettings.nTable).remove();oSettings.nTable.appendChild(oSettings.nTHead);}
if(oSettings.nTFoot&&oSettings.nTable!=oSettings.nTFoot.parentNode)
{$('>tfoot',oSettings.nTable).remove();oSettings.nTable.appendChild(oSettings.nTFoot);}
oSettings.nTable.parentNode.removeChild(oSettings.nTable);$(oSettings.nTableWrapper).remove();oSettings.aaSorting=[];oSettings.aaSortingFixed=[];_fnSortingClasses(oSettings);$(_fnGetTrNodes(oSettings)).removeClass(oSettings.asStripClasses.join(' '));if(!oSettings.bJUI)
{$('th',oSettings.nTHead).removeClass([_oExt.oStdClasses.sSortable,_oExt.oStdClasses.sSortableAsc,_oExt.oStdClasses.sSortableDesc,_oExt.oStdClasses.sSortableNone].join(' '));}
else
{$('th',oSettings.nTHead).removeClass([_oExt.oStdClasses.sSortable,_oExt.oJUIClasses.sSortableAsc,_oExt.oJUIClasses.sSortableDesc,_oExt.oJUIClasses.sSortableNone].join(' '));$('th span',oSettings.nTHead).remove();}
nOrig.appendChild(oSettings.nTable);for(i=0,iLen=oSettings.aoData.length;i<iLen;i++)
{nBody.appendChild(oSettings.aoData[i].nTr);}
oSettings.nTable.style.width=_fnStringToCss(oSettings.sDestroyWidth);$('>tr:even',nBody).addClass(oSettings.asDestoryStrips[0]);$('>tr:odd',nBody).addClass(oSettings.asDestoryStrips[1]);for(i=0,iLen=_aoSettings.length;i<iLen;i++)
{if(_aoSettings[i]==oSettings)
{_aoSettings.splice(i,1);}}
oSettings=null;};this.fnAdjustColumnSizing=function(bRedraw)
{var oSettings=_fnSettingsFromNode(this[_oExt.iApiIndex]);_fnAjustColumnSizing(oSettings);if(typeof bRedraw=='undefined'||bRedraw)
{this.fnDraw(false);}
else if(oSettings.oScroll.sX!==""||oSettings.oScroll.sY!=="")
{this.oApi._fnScrollDraw(oSettings);}};function _fnExternApiFunc(sFunc)
{return function(){var aArgs=[_fnSettingsFromNode(this[_oExt.iApiIndex])].concat(Array.prototype.slice.call(arguments));return _oExt.oApi[sFunc].apply(this,aArgs);};}
for(var sFunc in _oExt.oApi)
{if(sFunc)
{this[sFunc]=_fnExternApiFunc(sFunc);}}
function _fnInitalise(oSettings)
{var i,iLen;if(oSettings.bInitialised===false)
{setTimeout(function(){_fnInitalise(oSettings);},200);return;}
_fnAddOptionsHtml(oSettings);_fnDrawHead(oSettings);_fnProcessingDisplay(oSettings,true);if(oSettings.oFeatures.bAutoWidth)
{_fnCalculateColumnWidths(oSettings);}
for(i=0,iLen=oSettings.aoColumns.length;i<iLen;i++)
{if(oSettings.aoColumns[i].sWidth!==null)
{oSettings.aoColumns[i].nTh.style.width=_fnStringToCss(oSettings.aoColumns[i].sWidth);}}
if(oSettings.oFeatures.bSort)
{_fnSort(oSettings);}
else
{oSettings.aiDisplay=oSettings.aiDisplayMaster.slice();_fnCalculateEnd(oSettings);_fnDraw(oSettings);}
if(oSettings.sAjaxSource!==null&&!oSettings.oFeatures.bServerSide)
{oSettings.fnServerData.call(oSettings.oInstance,oSettings.sAjaxSource,[],function(json){for(i=0;i<json.aaData.length;i++)
{_fnAddData(oSettings,json.aaData[i]);}
oSettings.iInitDisplayStart=oSettings._iDisplayStart;if(oSettings.oFeatures.bSort)
{_fnSort(oSettings);}
else
{oSettings.aiDisplay=oSettings.aiDisplayMaster.slice();_fnCalculateEnd(oSettings);_fnDraw(oSettings);}
_fnProcessingDisplay(oSettings,false);_fnInitComplete(oSettings,json);});return;}
if(!oSettings.oFeatures.bServerSide)
{_fnProcessingDisplay(oSettings,false);_fnInitComplete(oSettings);}}
function _fnInitComplete(oSettings,json)
{oSettings._bInitComplete=true;if(typeof oSettings.fnInitComplete=='function')
{if(typeof json!='undefined')
{oSettings.fnInitComplete.call(oSettings.oInstance,oSettings,json);}
else
{oSettings.fnInitComplete.call(oSettings.oInstance,oSettings);}}}
function _fnLanguageProcess(oSettings,oLanguage,bInit)
{_fnMap(oSettings.oLanguage,oLanguage,'sProcessing');_fnMap(oSettings.oLanguage,oLanguage,'sLengthMenu');_fnMap(oSettings.oLanguage,oLanguage,'sEmptyTable');_fnMap(oSettings.oLanguage,oLanguage,'sZeroRecords');_fnMap(oSettings.oLanguage,oLanguage,'sInfo');_fnMap(oSettings.oLanguage,oLanguage,'sInfoEmpty');_fnMap(oSettings.oLanguage,oLanguage,'sInfoFiltered');_fnMap(oSettings.oLanguage,oLanguage,'sInfoPostFix');_fnMap(oSettings.oLanguage,oLanguage,'sSearch');if(typeof oLanguage.oPaginate!='undefined')
{_fnMap(oSettings.oLanguage.oPaginate,oLanguage.oPaginate,'sFirst');_fnMap(oSettings.oLanguage.oPaginate,oLanguage.oPaginate,'sPrevious');_fnMap(oSettings.oLanguage.oPaginate,oLanguage.oPaginate,'sNext');_fnMap(oSettings.oLanguage.oPaginate,oLanguage.oPaginate,'sLast');}
if(typeof oLanguage.sEmptyTable=='undefined'&&typeof oLanguage.sZeroRecords!='undefined')
{_fnMap(oSettings.oLanguage,oLanguage,'sZeroRecords','sEmptyTable');}
if(bInit)
{_fnInitalise(oSettings);}}
function _fnAddColumn(oSettings,nTh)
{oSettings.aoColumns[oSettings.aoColumns.length++]={"sType":null,"_bAutoType":true,"bVisible":true,"bSearchable":true,"bSortable":true,"asSorting":['asc','desc'],"sSortingClass":oSettings.oClasses.sSortable,"sSortingClassJUI":oSettings.oClasses.sSortJUI,"sTitle":nTh?nTh.innerHTML:'',"sName":'',"sWidth":null,"sWidthOrig":null,"sClass":null,"fnRender":null,"bUseRendered":true,"iDataSort":oSettings.aoColumns.length-1,"sSortDataType":'std',"nTh":nTh?nTh:document.createElement('th'),"nTf":null,"anThExtra":[],"anTfExtra":[]};var iCol=oSettings.aoColumns.length-1;var oCol=oSettings.aoColumns[iCol];if(typeof oSettings.aoPreSearchCols[iCol]=='undefined'||oSettings.aoPreSearchCols[iCol]===null)
{oSettings.aoPreSearchCols[iCol]={"sSearch":"","bRegex":false,"bSmart":true};}
else
{if(typeof oSettings.aoPreSearchCols[iCol].bRegex=='undefined')
{oSettings.aoPreSearchCols[iCol].bRegex=true;}
if(typeof oSettings.aoPreSearchCols[iCol].bSmart=='undefined')
{oSettings.aoPreSearchCols[iCol].bSmart=true;}}
_fnColumnOptions(oSettings,iCol,null);}
function _fnColumnOptions(oSettings,iCol,oOptions)
{var oCol=oSettings.aoColumns[iCol];if(typeof oOptions!='undefined'&&oOptions!==null)
{if(typeof oOptions.sType!='undefined')
{oCol.sType=oOptions.sType;oCol._bAutoType=false;}
_fnMap(oCol,oOptions,"bVisible");_fnMap(oCol,oOptions,"bSearchable");_fnMap(oCol,oOptions,"bSortable");_fnMap(oCol,oOptions,"sTitle");_fnMap(oCol,oOptions,"sName");_fnMap(oCol,oOptions,"sWidth");_fnMap(oCol,oOptions,"sWidth","sWidthOrig");_fnMap(oCol,oOptions,"sClass");_fnMap(oCol,oOptions,"fnRender");_fnMap(oCol,oOptions,"bUseRendered");_fnMap(oCol,oOptions,"iDataSort");_fnMap(oCol,oOptions,"asSorting");_fnMap(oCol,oOptions,"sSortDataType");}
if(!oSettings.oFeatures.bSort)
{oCol.bSortable=false;}
if(!oCol.bSortable||($.inArray('asc',oCol.asSorting)==-1&&$.inArray('desc',oCol.asSorting)==-1))
{oCol.sSortingClass=oSettings.oClasses.sSortableNone;oCol.sSortingClassJUI="";}
else if($.inArray('asc',oCol.asSorting)!=-1&&$.inArray('desc',oCol.asSorting)==-1)
{oCol.sSortingClass=oSettings.oClasses.sSortableAsc;oCol.sSortingClassJUI=oSettings.oClasses.sSortJUIAscAllowed;}
else if($.inArray('asc',oCol.asSorting)==-1&&$.inArray('desc',oCol.asSorting)!=-1)
{oCol.sSortingClass=oSettings.oClasses.sSortableDesc;oCol.sSortingClassJUI=oSettings.oClasses.sSortJUIDescAllowed;}}
function _fnAddData(oSettings,aDataSupplied)
{if(aDataSupplied.length!=oSettings.aoColumns.length&&oSettings.iDrawError!=oSettings.iDraw)
{_fnLog(oSettings,0,"Added data (size "+aDataSupplied.length+") does not match known "+
"number of columns ("+oSettings.aoColumns.length+")");oSettings.iDrawError=oSettings.iDraw;return-1;}
var aData=aDataSupplied.slice();var iThisIndex=oSettings.aoData.length;oSettings.aoData.push({"nTr":document.createElement('tr'),"_iId":oSettings.iNextId++,"_aData":aData,"_anHidden":[],"_sRowStripe":''});var nTd,sThisType;for(var i=0;i<aData.length;i++)
{nTd=document.createElement('td');if(aData[i]===null)
{aData[i]='';}
if(typeof oSettings.aoColumns[i].fnRender=='function')
{var sRendered=oSettings.aoColumns[i].fnRender({"iDataRow":iThisIndex,"iDataColumn":i,"aData":aData,"oSettings":oSettings});nTd.innerHTML=sRendered;if(oSettings.aoColumns[i].bUseRendered)
{oSettings.aoData[iThisIndex]._aData[i]=sRendered;}}
else
{nTd.innerHTML=aData[i];}
if(typeof aData[i]!='string')
{aData[i]+="";}
aData[i]=$.trim(aData[i]);if(oSettings.aoColumns[i].sClass!==null)
{nTd.className=oSettings.aoColumns[i].sClass;}
if(oSettings.aoColumns[i]._bAutoType&&oSettings.aoColumns[i].sType!='string')
{sThisType=_fnDetectType(oSettings.aoData[iThisIndex]._aData[i]);if(oSettings.aoColumns[i].sType===null)
{oSettings.aoColumns[i].sType=sThisType;}
else if(oSettings.aoColumns[i].sType!=sThisType)
{oSettings.aoColumns[i].sType='string';}}
if(oSettings.aoColumns[i].bVisible)
{oSettings.aoData[iThisIndex].nTr.appendChild(nTd);oSettings.aoData[iThisIndex]._anHidden[i]=null;}
else
{oSettings.aoData[iThisIndex]._anHidden[i]=nTd;}}
oSettings.aiDisplayMaster.push(iThisIndex);return iThisIndex;}
function _fnGatherData(oSettings)
{var iLoop,i,iLen,j,jLen,jInner,nTds,nTrs,nTd,aLocalData,iThisIndex,iRow,iRows,iColumn,iColumns;if(oSettings.sAjaxSource===null)
{nTrs=oSettings.nTBody.childNodes;for(i=0,iLen=nTrs.length;i<iLen;i++)
{if(nTrs[i].nodeName.toUpperCase()=="TR")
{iThisIndex=oSettings.aoData.length;oSettings.aoData.push({"nTr":nTrs[i],"_iId":oSettings.iNextId++,"_aData":[],"_anHidden":[],"_sRowStripe":''});oSettings.aiDisplayMaster.push(iThisIndex);aLocalData=oSettings.aoData[iThisIndex]._aData;nTds=nTrs[i].childNodes;jInner=0;for(j=0,jLen=nTds.length;j<jLen;j++)
{if(nTds[j].nodeName.toUpperCase()=="TD")
{aLocalData[jInner]=$.trim(nTds[j].innerHTML);jInner++;}}}}}
nTrs=_fnGetTrNodes(oSettings);nTds=[];for(i=0,iLen=nTrs.length;i<iLen;i++)
{for(j=0,jLen=nTrs[i].childNodes.length;j<jLen;j++)
{nTd=nTrs[i].childNodes[j];if(nTd.nodeName.toUpperCase()=="TD")
{nTds.push(nTd);}}}
if(nTds.length!=nTrs.length*oSettings.aoColumns.length)
{_fnLog(oSettings,1,"Unexpected number of TD elements. Expected "+
(nTrs.length*oSettings.aoColumns.length)+" and got "+nTds.length+". DataTables does "+
"not support rowspan / colspan in the table body, and there must be one cell for each "+
"row/column combination.");}
for(iColumn=0,iColumns=oSettings.aoColumns.length;iColumn<iColumns;iColumn++)
{if(oSettings.aoColumns[iColumn].sTitle===null)
{oSettings.aoColumns[iColumn].sTitle=oSettings.aoColumns[iColumn].nTh.innerHTML;}
var
bAutoType=oSettings.aoColumns[iColumn]._bAutoType,bRender=typeof oSettings.aoColumns[iColumn].fnRender=='function',bClass=oSettings.aoColumns[iColumn].sClass!==null,bVisible=oSettings.aoColumns[iColumn].bVisible,nCell,sThisType,sRendered;if(bAutoType||bRender||bClass||!bVisible)
{for(iRow=0,iRows=oSettings.aoData.length;iRow<iRows;iRow++)
{nCell=nTds[(iRow*iColumns)+iColumn];if(bAutoType)
{if(oSettings.aoColumns[iColumn].sType!='string')
{sThisType=_fnDetectType(oSettings.aoData[iRow]._aData[iColumn]);if(oSettings.aoColumns[iColumn].sType===null)
{oSettings.aoColumns[iColumn].sType=sThisType;}
else if(oSettings.aoColumns[iColumn].sType!=sThisType)
{oSettings.aoColumns[iColumn].sType='string';}}}
if(bRender)
{sRendered=oSettings.aoColumns[iColumn].fnRender({"iDataRow":iRow,"iDataColumn":iColumn,"aData":oSettings.aoData[iRow]._aData,"oSettings":oSettings});nCell.innerHTML=sRendered;if(oSettings.aoColumns[iColumn].bUseRendered)
{oSettings.aoData[iRow]._aData[iColumn]=sRendered;}}
if(bClass)
{nCell.className+=' '+oSettings.aoColumns[iColumn].sClass;}
if(!bVisible)
{oSettings.aoData[iRow]._anHidden[iColumn]=nCell;nCell.parentNode.removeChild(nCell);}
else
{oSettings.aoData[iRow]._anHidden[iColumn]=null;}}}}}
function _fnDrawHead(oSettings)
{var i,nTh,iLen,j,jLen;var anTr=oSettings.nTHead.getElementsByTagName('tr');var iThs=oSettings.nTHead.getElementsByTagName('th').length;var iCorrector=0;var jqChildren;if(iThs!==0)
{for(i=0,iLen=oSettings.aoColumns.length;i<iLen;i++)
{nTh=oSettings.aoColumns[i].nTh;if(oSettings.aoColumns[i].sClass!==null)
{$(nTh).addClass(oSettings.aoColumns[i].sClass);}
for(j=1,jLen=anTr.length;j<jLen;j++)
{jqChildren=$(anTr[j]).children();oSettings.aoColumns[i].anThExtra.push(jqChildren[i-iCorrector]);if(!oSettings.aoColumns[i].bVisible)
{anTr[j].removeChild(jqChildren[i-iCorrector]);}}
if(oSettings.aoColumns[i].bVisible)
{if(oSettings.aoColumns[i].sTitle!=nTh.innerHTML)
{nTh.innerHTML=oSettings.aoColumns[i].sTitle;}}
else
{nTh.parentNode.removeChild(nTh);iCorrector++;}}}
else
{var nTr=document.createElement("tr");for(i=0,iLen=oSettings.aoColumns.length;i<iLen;i++)
{nTh=oSettings.aoColumns[i].nTh;nTh.innerHTML=oSettings.aoColumns[i].sTitle;if(oSettings.aoColumns[i].sClass!==null)
{$(nTh).addClass(oSettings.aoColumns[i].sClass);}
if(oSettings.aoColumns[i].bVisible)
{nTr.appendChild(nTh);}}
$(oSettings.nTHead).html('')[0].appendChild(nTr);}
if(oSettings.bJUI)
{for(i=0,iLen=oSettings.aoColumns.length;i<iLen;i++)
{nTh=oSettings.aoColumns[i].nTh;var nDiv=document.createElement('div');nDiv.className=oSettings.oClasses.sSortJUIWrapper;$(nTh).contents().appendTo(nDiv);nDiv.appendChild(document.createElement('span'));nTh.appendChild(nDiv);}}
var fnNoSelect=function(e){this.onselectstart=function(){return false;};return false;};if(oSettings.oFeatures.bSort)
{for(i=0;i<oSettings.aoColumns.length;i++)
{if(oSettings.aoColumns[i].bSortable!==false)
{_fnSortAttachListener(oSettings,oSettings.aoColumns[i].nTh,i);$(oSettings.aoColumns[i].nTh).bind('mousedown.DT',fnNoSelect);}
else
{$(oSettings.aoColumns[i].nTh).addClass(oSettings.oClasses.sSortableNone);}}}
if(oSettings.nTFoot!==null)
{iCorrector=0;anTr=oSettings.nTFoot.getElementsByTagName('tr');var nTfs=anTr[0].getElementsByTagName('th');for(i=0,iLen=nTfs.length;i<iLen;i++)
{if(typeof oSettings.aoColumns[i]!='undefined')
{oSettings.aoColumns[i].nTf=nTfs[i-iCorrector];if(oSettings.oClasses.sFooterTH!=="")
{oSettings.aoColumns[i].nTf.className+=" "+oSettings.oClasses.sFooterTH;}
for(j=1,jLen=anTr.length;j<jLen;j++)
{jqChildren=$(anTr[j]).children();oSettings.aoColumns[i].anTfExtra.push(jqChildren[i-iCorrector]);if(!oSettings.aoColumns[i].bVisible)
{anTr[j].removeChild(jqChildren[i-iCorrector]);}}
if(!oSettings.aoColumns[i].bVisible)
{nTfs[i-iCorrector].parentNode.removeChild(nTfs[i-iCorrector]);iCorrector++;}}}}}
function _fnDraw(oSettings)
{var i,iLen;var anRows=[];var iRowCount=0;var bRowError=false;var iStrips=oSettings.asStripClasses.length;var iOpenRows=oSettings.aoOpenRows.length;oSettings.bDrawing=true;if(typeof oSettings.iInitDisplayStart!='undefined'&&oSettings.iInitDisplayStart!=-1)
{if(oSettings.oFeatures.bServerSide)
{oSettings._iDisplayStart=oSettings.iInitDisplayStart;}
else
{oSettings._iDisplayStart=(oSettings.iInitDisplayStart>=oSettings.fnRecordsDisplay())?0:oSettings.iInitDisplayStart;}
oSettings.iInitDisplayStart=-1;_fnCalculateEnd(oSettings);}
if(!oSettings.bDestroying&&oSettings.oFeatures.bServerSide&&!_fnAjaxUpdate(oSettings))
{return;}
else if(!oSettings.oFeatures.bServerSide)
{oSettings.iDraw++;}
if(oSettings.aiDisplay.length!==0)
{var iStart=oSettings._iDisplayStart;var iEnd=oSettings._iDisplayEnd;if(oSettings.oFeatures.bServerSide)
{iStart=0;iEnd=oSettings.aoData.length;}
for(var j=iStart;j<iEnd;j++)
{var aoData=oSettings.aoData[oSettings.aiDisplay[j]];var nRow=aoData.nTr;if(iStrips!==0)
{var sStrip=oSettings.asStripClasses[iRowCount%iStrips];if(aoData._sRowStripe!=sStrip)
{$(nRow).removeClass(aoData._sRowStripe).addClass(sStrip);aoData._sRowStripe=sStrip;}}
if(typeof oSettings.fnRowCallback=="function")
{nRow=oSettings.fnRowCallback.call(oSettings.oInstance,nRow,oSettings.aoData[oSettings.aiDisplay[j]]._aData,iRowCount,j);if(!nRow&&!bRowError)
{_fnLog(oSettings,0,"A node was not returned by fnRowCallback");bRowError=true;}}
anRows.push(nRow);iRowCount++;if(iOpenRows!==0)
{for(var k=0;k<iOpenRows;k++)
{if(nRow==oSettings.aoOpenRows[k].nParent)
{anRows.push(oSettings.aoOpenRows[k].nTr);}}}}}
else
{anRows[0]=document.createElement('tr');if(typeof oSettings.asStripClasses[0]!='undefined')
{anRows[0].className=oSettings.asStripClasses[0];}
var nTd=document.createElement('td');nTd.setAttribute('valign',"top");nTd.colSpan=_fnVisbleColumns(oSettings);nTd.className=oSettings.oClasses.sRowEmpty;if(typeof oSettings.oLanguage.sEmptyTable!='undefined'&&oSettings.fnRecordsTotal()===0)
{nTd.innerHTML=oSettings.oLanguage.sEmptyTable;}
else
{nTd.innerHTML=oSettings.oLanguage.sZeroRecords.replace('_MAX_',oSettings.fnFormatNumber(oSettings.fnRecordsTotal()));}
anRows[iRowCount].appendChild(nTd);}
if(typeof oSettings.fnHeaderCallback=='function')
{oSettings.fnHeaderCallback.call(oSettings.oInstance,$('>tr',oSettings.nTHead)[0],_fnGetDataMaster(oSettings),oSettings._iDisplayStart,oSettings.fnDisplayEnd(),oSettings.aiDisplay);}
if(typeof oSettings.fnFooterCallback=='function')
{oSettings.fnFooterCallback.call(oSettings.oInstance,$('>tr',oSettings.nTFoot)[0],_fnGetDataMaster(oSettings),oSettings._iDisplayStart,oSettings.fnDisplayEnd(),oSettings.aiDisplay);}
var
nAddFrag=document.createDocumentFragment(),nRemoveFrag=document.createDocumentFragment(),nBodyPar,nTrs;if(oSettings.nTBody)
{nBodyPar=oSettings.nTBody.parentNode;nRemoveFrag.appendChild(oSettings.nTBody);if(!oSettings.oScroll.bInfinite||!oSettings._bInitComplete||oSettings.bSorted||oSettings.bFiltered)
{nTrs=oSettings.nTBody.childNodes;for(i=nTrs.length-1;i>=0;i--)
{nTrs[i].parentNode.removeChild(nTrs[i]);}}
for(i=0,iLen=anRows.length;i<iLen;i++)
{nAddFrag.appendChild(anRows[i]);}
oSettings.nTBody.appendChild(nAddFrag);if(nBodyPar!==null)
{nBodyPar.appendChild(oSettings.nTBody);}}
for(i=oSettings.aoDrawCallback.length-1;i>=0;i--)
{oSettings.aoDrawCallback[i].fn.call(oSettings.oInstance,oSettings);}
oSettings.bSorted=false;oSettings.bFiltered=false;oSettings.bDrawing=false;if(oSettings.oFeatures.bServerSide)
{_fnProcessingDisplay(oSettings,false);if(typeof oSettings._bInitComplete=='undefined')
{_fnInitComplete(oSettings);}}}
function _fnReDraw(oSettings)
{if(oSettings.oFeatures.bSort)
{_fnSort(oSettings,oSettings.oPreviousSearch);}
else if(oSettings.oFeatures.bFilter)
{_fnFilterComplete(oSettings,oSettings.oPreviousSearch);}
else
{_fnCalculateEnd(oSettings);_fnDraw(oSettings);}}
function _fnAjaxUpdate(oSettings)
{if(oSettings.bAjaxDataGet)
{_fnProcessingDisplay(oSettings,true);var iColumns=oSettings.aoColumns.length;var aoData=[];var i;oSettings.iDraw++;aoData.push({"name":"sEcho","value":oSettings.iDraw});aoData.push({"name":"iColumns","value":iColumns});aoData.push({"name":"sColumns","value":_fnColumnOrdering(oSettings)});aoData.push({"name":"iDisplayStart","value":oSettings._iDisplayStart});aoData.push({"name":"iDisplayLength","value":oSettings.oFeatures.bPaginate!==false?oSettings._iDisplayLength:-1});if(oSettings.oFeatures.bFilter!==false)
{aoData.push({"name":"sSearch","value":oSettings.oPreviousSearch.sSearch});aoData.push({"name":"bRegex","value":oSettings.oPreviousSearch.bRegex});for(i=0;i<iColumns;i++)
{aoData.push({"name":"sSearch_"+i,"value":oSettings.aoPreSearchCols[i].sSearch});aoData.push({"name":"bRegex_"+i,"value":oSettings.aoPreSearchCols[i].bRegex});aoData.push({"name":"bSearchable_"+i,"value":oSettings.aoColumns[i].bSearchable});}}
if(oSettings.oFeatures.bSort!==false)
{var iFixed=oSettings.aaSortingFixed!==null?oSettings.aaSortingFixed.length:0;var iUser=oSettings.aaSorting.length;aoData.push({"name":"iSortingCols","value":iFixed+iUser});for(i=0;i<iFixed;i++)
{aoData.push({"name":"iSortCol_"+i,"value":oSettings.aaSortingFixed[i][0]});aoData.push({"name":"sSortDir_"+i,"value":oSettings.aaSortingFixed[i][1]});}
for(i=0;i<iUser;i++)
{aoData.push({"name":"iSortCol_"+(i+iFixed),"value":oSettings.aaSorting[i][0]});aoData.push({"name":"sSortDir_"+(i+iFixed),"value":oSettings.aaSorting[i][1]});}
for(i=0;i<iColumns;i++)
{aoData.push({"name":"bSortable_"+i,"value":oSettings.aoColumns[i].bSortable});}}
oSettings.fnServerData.call(oSettings.oInstance,oSettings.sAjaxSource,aoData,function(json){_fnAjaxUpdateDraw(oSettings,json);});return false;}
else
{return true;}}
function _fnAjaxUpdateDraw(oSettings,json)
{if(typeof json.sEcho!='undefined')
{if(json.sEcho*1<oSettings.iDraw)
{return;}
else
{oSettings.iDraw=json.sEcho*1;}}
if(!oSettings.oScroll.bInfinite||(oSettings.oScroll.bInfinite&&(oSettings.bSorted||oSettings.bFiltered)))
{_fnClearTable(oSettings);}
oSettings._iRecordsTotal=json.iTotalRecords;oSettings._iRecordsDisplay=json.iTotalDisplayRecords;var sOrdering=_fnColumnOrdering(oSettings);var bReOrder=(typeof json.sColumns!='undefined'&&sOrdering!==""&&json.sColumns!=sOrdering);if(bReOrder)
{var aiIndex=_fnReOrderIndex(oSettings,json.sColumns);}
for(var i=0,iLen=json.aaData.length;i<iLen;i++)
{if(bReOrder)
{var aData=[];for(var j=0,jLen=oSettings.aoColumns.length;j<jLen;j++)
{aData.push(json.aaData[i][aiIndex[j]]);}
_fnAddData(oSettings,aData);}
else
{_fnAddData(oSettings,json.aaData[i]);}}
oSettings.aiDisplay=oSettings.aiDisplayMaster.slice();oSettings.bAjaxDataGet=false;_fnDraw(oSettings);oSettings.bAjaxDataGet=true;_fnProcessingDisplay(oSettings,false);}
function _fnAddOptionsHtml(oSettings)
{var nHolding=document.createElement('div');oSettings.nTable.parentNode.insertBefore(nHolding,oSettings.nTable);oSettings.nTableWrapper=document.createElement('div');oSettings.nTableWrapper.className=oSettings.oClasses.sWrapper;if(oSettings.sTableId!=='')
{oSettings.nTableWrapper.setAttribute('id',oSettings.sTableId+'_wrapper');}
var nInsertNode=oSettings.nTableWrapper;var aDom=oSettings.sDom.split('');var nTmp,iPushFeature,cOption,nNewNode,cNext,sAttr,j;for(var i=0;i<aDom.length;i++)
{iPushFeature=0;cOption=aDom[i];if(cOption=='<')
{nNewNode=document.createElement('div');cNext=aDom[i+1];if(cNext=="'"||cNext=='"')
{sAttr="";j=2;while(aDom[i+j]!=cNext)
{sAttr+=aDom[i+j];j++;}
if(sAttr=="H")
{sAttr="fg-toolbar ui-toolbar ui-widget-header ui-corner-tl ui-corner-tr ui-helper-clearfix";}
else if(sAttr=="F")
{sAttr="fg-toolbar ui-toolbar ui-widget-header ui-corner-bl ui-corner-br ui-helper-clearfix";}
if(sAttr.indexOf('.')!=-1)
{var aSplit=sAttr.split('.');nNewNode.setAttribute('id',aSplit[0].substr(1,aSplit[0].length-1));nNewNode.className=aSplit[1];}
else if(sAttr.charAt(0)=="#")
{nNewNode.setAttribute('id',sAttr.substr(1,sAttr.length-1));}
else
{nNewNode.className=sAttr;}
i+=j;}
nInsertNode.appendChild(nNewNode);nInsertNode=nNewNode;}
else if(cOption=='>')
{nInsertNode=nInsertNode.parentNode;}
else if(cOption=='l'&&oSettings.oFeatures.bPaginate&&oSettings.oFeatures.bLengthChange)
{nTmp=_fnFeatureHtmlLength(oSettings);iPushFeature=1;}
else if(cOption=='f'&&oSettings.oFeatures.bFilter)
{nTmp=_fnFeatureHtmlFilter(oSettings);iPushFeature=1;}
else if(cOption=='r'&&oSettings.oFeatures.bProcessing)
{nTmp=_fnFeatureHtmlProcessing(oSettings);iPushFeature=1;}
else if(cOption=='t')
{nTmp=_fnFeatureHtmlTable(oSettings);iPushFeature=1;}
else if(cOption=='i'&&oSettings.oFeatures.bInfo)
{nTmp=_fnFeatureHtmlInfo(oSettings);iPushFeature=1;}
else if(cOption=='p'&&oSettings.oFeatures.bPaginate)
{nTmp=_fnFeatureHtmlPaginate(oSettings);iPushFeature=1;}
else if(_oExt.aoFeatures.length!==0)
{var aoFeatures=_oExt.aoFeatures;for(var k=0,kLen=aoFeatures.length;k<kLen;k++)
{if(cOption==aoFeatures[k].cFeature)
{nTmp=aoFeatures[k].fnInit(oSettings);if(nTmp)
{iPushFeature=1;}
break;}}}
if(iPushFeature==1&&nTmp!==null)
{if(typeof oSettings.aanFeatures[cOption]!='object')
{oSettings.aanFeatures[cOption]=[];}
oSettings.aanFeatures[cOption].push(nTmp);nInsertNode.appendChild(nTmp);}}
nHolding.parentNode.replaceChild(oSettings.nTableWrapper,nHolding);}
function _fnFeatureHtmlTable(oSettings)
{if(oSettings.oScroll.sX===""&&oSettings.oScroll.sY==="")
{return oSettings.nTable;}
var
nScroller=document.createElement('div'),nScrollHead=document.createElement('div'),nScrollHeadInner=document.createElement('div'),nScrollBody=document.createElement('div'),nScrollFoot=document.createElement('div'),nScrollFootInner=document.createElement('div'),nScrollHeadTable=oSettings.nTable.cloneNode(false),nScrollFootTable=oSettings.nTable.cloneNode(false),nThead=oSettings.nTable.getElementsByTagName('thead')[0],nTfoot=oSettings.nTable.getElementsByTagName('tfoot').length===0?null:oSettings.nTable.getElementsByTagName('tfoot')[0],oClasses=(typeof oInit.bJQueryUI!='undefined'&&oInit.bJQueryUI)?_oExt.oJUIClasses:_oExt.oStdClasses;nScrollHead.appendChild(nScrollHeadInner);nScrollFoot.appendChild(nScrollFootInner);nScrollBody.appendChild(oSettings.nTable);nScroller.appendChild(nScrollHead);nScroller.appendChild(nScrollBody);nScrollHeadInner.appendChild(nScrollHeadTable);nScrollHeadTable.appendChild(nThead);if(nTfoot!==null)
{nScroller.appendChild(nScrollFoot);nScrollFootInner.appendChild(nScrollFootTable);nScrollFootTable.appendChild(nTfoot);}
nScroller.className=oClasses.sScrollWrapper;nScrollHead.className=oClasses.sScrollHead;nScrollHeadInner.className=oClasses.sScrollHeadInner;nScrollBody.className=oClasses.sScrollBody;nScrollFoot.className=oClasses.sScrollFoot;nScrollFootInner.className=oClasses.sScrollFootInner;if(oSettings.oScroll.bAutoCss)
{nScrollHead.style.overflow="hidden";nScrollHead.style.position="relative";nScrollFoot.style.overflow="hidden";nScrollBody.style.overflow="auto";}
nScrollHead.style.border="0";nScrollHead.style.width="100%";nScrollFoot.style.border="0";nScrollHeadInner.style.width="150%";nScrollHeadTable.removeAttribute('id');nScrollHeadTable.style.marginLeft="0";oSettings.nTable.style.marginLeft="0";if(nTfoot!==null)
{nScrollFootTable.removeAttribute('id');nScrollFootTable.style.marginLeft="0";}
var nCaptions=$('>caption',oSettings.nTable);for(var i=0,iLen=nCaptions.length;i<iLen;i++)
{nScrollHeadTable.appendChild(nCaptions[i]);}
if(oSettings.oScroll.sX!=="")
{nScrollHead.style.width=_fnStringToCss(oSettings.oScroll.sX);nScrollBody.style.width=_fnStringToCss(oSettings.oScroll.sX);if(nTfoot!==null)
{nScrollFoot.style.width=_fnStringToCss(oSettings.oScroll.sX);}
$(nScrollBody).scroll(function(e){nScrollHead.scrollLeft=this.scrollLeft;if(nTfoot!==null)
{nScrollFoot.scrollLeft=this.scrollLeft;}});}
if(oSettings.oScroll.sY!=="")
{nScrollBody.style.height=_fnStringToCss(oSettings.oScroll.sY);}
oSettings.aoDrawCallback.push({"fn":_fnScrollDraw,"sName":"scrolling"});if(oSettings.oScroll.bInfinite)
{$(nScrollBody).scroll(function(){if(!oSettings.bDrawing)
{if($(this).scrollTop()+$(this).height()>$(oSettings.nTable).height()-oSettings.oScroll.iLoadGap)
{if(oSettings.fnDisplayEnd()<oSettings.fnRecordsDisplay())
{_fnPageChange(oSettings,'next');_fnCalculateEnd(oSettings);_fnDraw(oSettings);}}}});}
oSettings.nScrollHead=nScrollHead;oSettings.nScrollFoot=nScrollFoot;return nScroller;}
function _fnScrollDraw(o)
{var
nScrollHeadInner=o.nScrollHead.getElementsByTagName('div')[0],nScrollHeadTable=nScrollHeadInner.getElementsByTagName('table')[0],nScrollBody=o.nTable.parentNode,i,iLen,j,jLen,anHeadToSize,anHeadSizers,anFootSizers,anFootToSize,oStyle,iVis,iWidth,aApplied=[],iSanityWidth;var nTheadSize=o.nTable.getElementsByTagName('thead');if(nTheadSize.length>0)
{o.nTable.removeChild(nTheadSize[0]);}
if(o.nTFoot!==null)
{var nTfootSize=o.nTable.getElementsByTagName('tfoot');if(nTfootSize.length>0)
{o.nTable.removeChild(nTfootSize[0]);}}
nTheadSize=o.nTHead.cloneNode(true);o.nTable.insertBefore(nTheadSize,o.nTable.childNodes[0]);if(o.nTFoot!==null)
{nTfootSize=o.nTFoot.cloneNode(true);o.nTable.insertBefore(nTfootSize,o.nTable.childNodes[1]);}
var nThs=_fnGetUniqueThs(nTheadSize);for(i=0,iLen=nThs.length;i<iLen;i++)
{iVis=_fnVisibleToColumnIndex(o,i);nThs[i].style.width=o.aoColumns[iVis].sWidth;}
if(o.nTFoot!==null)
{_fnApplyToChildren(function(n){n.style.width="";},nTfootSize.getElementsByTagName('tr'));}
iSanityWidth=$(o.nTable).outerWidth();if(o.oScroll.sX==="")
{o.nTable.style.width="100%";if($.browser.msie&&$.browser.version<=7)
{o.nTable.style.width=_fnStringToCss($(o.nTable).outerWidth()-o.oScroll.iBarWidth);}}
else
{if(o.oScroll.sXInner!=="")
{o.nTable.style.width=_fnStringToCss(o.oScroll.sXInner);}
else if(iSanityWidth==$(nScrollBody).width()&&$(nScrollBody).height()<$(o.nTable).height())
{o.nTable.style.width=_fnStringToCss(iSanityWidth-o.oScroll.iBarWidth);if($(o.nTable).outerWidth()>iSanityWidth-o.oScroll.iBarWidth)
{o.nTable.style.width=_fnStringToCss(iSanityWidth);}}
else
{o.nTable.style.width=_fnStringToCss(iSanityWidth);}}
iSanityWidth=$(o.nTable).outerWidth();anHeadToSize=o.nTHead.getElementsByTagName('tr');anHeadSizers=nTheadSize.getElementsByTagName('tr');_fnApplyToChildren(function(nSizer,nToSize){oStyle=nSizer.style;oStyle.paddingTop="0";oStyle.paddingBottom="0";oStyle.borderTopWidth="0";oStyle.borderBottomWidth="0";oStyle.height=0;iWidth=$(nSizer).width();nToSize.style.width=_fnStringToCss(iWidth);aApplied.push(iWidth);},anHeadSizers,anHeadToSize);$(anHeadSizers).height(0);if(o.nTFoot!==null)
{anFootSizers=nTfootSize.getElementsByTagName('tr');anFootToSize=o.nTFoot.getElementsByTagName('tr');_fnApplyToChildren(function(nSizer,nToSize){oStyle=nSizer.style;oStyle.paddingTop="0";oStyle.paddingBottom="0";oStyle.borderTopWidth="0";oStyle.borderBottomWidth="0";oStyle.height=0;iWidth=$(nSizer).width();nToSize.style.width=_fnStringToCss(iWidth);aApplied.push(iWidth);},anFootSizers,anFootToSize);$(anFootSizers).height(0);}
_fnApplyToChildren(function(nSizer){nSizer.innerHTML="";nSizer.style.width=_fnStringToCss(aApplied.shift());},anHeadSizers);if(o.nTFoot!==null)
{_fnApplyToChildren(function(nSizer){nSizer.innerHTML="";nSizer.style.width=_fnStringToCss(aApplied.shift());},anFootSizers);}
if($(o.nTable).outerWidth()<iSanityWidth)
{if(o.oScroll.sX==="")
{_fnLog(o,1,"The table cannot fit into the current element which will cause column"+
" misalignment. It is suggested that you enable x-scrolling or increase the width"+
" the table has in which to be drawn");}
else if(o.oScroll.sXInner!=="")
{_fnLog(o,1,"The table cannot fit into the current element which will cause column"+
" misalignment. It is suggested that you increase the sScrollXInner property to"+
" allow it to draw in a larger area, or simply remove that parameter to allow"+
" automatic calculation");}}
if(o.oScroll.sY==="")
{if($.browser.msie&&$.browser.version<=7)
{nScrollBody.style.height=_fnStringToCss(o.nTable.offsetHeight+o.oScroll.iBarWidth);}}
if(o.oScroll.sY!==""&&o.oScroll.bCollapse)
{nScrollBody.style.height=_fnStringToCss(o.oScroll.sY);var iExtra=(o.oScroll.sX!==""&&o.nTable.offsetWidth>nScrollBody.offsetWidth)?o.oScroll.iBarWidth:0;if(o.nTable.offsetHeight<nScrollBody.offsetHeight)
{nScrollBody.style.height=_fnStringToCss($(o.nTable).height()+iExtra);}}
var iOuterWidth=$(o.nTable).outerWidth();nScrollHeadTable.style.width=_fnStringToCss(iOuterWidth);nScrollHeadInner.style.width=_fnStringToCss(iOuterWidth+o.oScroll.iBarWidth);if(o.nTFoot!==null)
{var
nScrollFootInner=o.nScrollFoot.getElementsByTagName('div')[0],nScrollFootTable=nScrollFootInner.getElementsByTagName('table')[0];nScrollFootInner.style.width=_fnStringToCss(o.nTable.offsetWidth+o.oScroll.iBarWidth);nScrollFootTable.style.width=_fnStringToCss(o.nTable.offsetWidth);}
if(o.bSorted||o.bFiltered)
{nScrollBody.scrollTop=0;}}
function _fnAjustColumnSizing(oSettings)
{if(oSettings.oFeatures.bAutoWidth===false)
{return false;}
_fnCalculateColumnWidths(oSettings);for(var i=0,iLen=oSettings.aoColumns.length;i<iLen;i++)
{oSettings.aoColumns[i].nTh.style.width=oSettings.aoColumns[i].sWidth;}}
function _fnFeatureHtmlFilter(oSettings)
{var nFilter=document.createElement('div');if(oSettings.sTableId!==''&&typeof oSettings.aanFeatures.f=="undefined")
{nFilter.setAttribute('id',oSettings.sTableId+'_filter');}
nFilter.className=oSettings.oClasses.sFilter;var sSpace=oSettings.oLanguage.sSearch===""?"":" ";nFilter.innerHTML=oSettings.oLanguage.sSearch+sSpace+'<input type="text" />';var jqFilter=$("input",nFilter);jqFilter.val(oSettings.oPreviousSearch.sSearch.replace('"','&quot;'));jqFilter.bind('keyup.DT',function(e){var n=oSettings.aanFeatures.f;for(var i=0,iLen=n.length;i<iLen;i++)
{if(n[i]!=this.parentNode)
{$('input',n[i]).val(this.value);}}
if(this.value!=oSettings.oPreviousSearch.sSearch)
{_fnFilterComplete(oSettings,{"sSearch":this.value,"bRegex":oSettings.oPreviousSearch.bRegex,"bSmart":oSettings.oPreviousSearch.bSmart});}});jqFilter.bind('keypress.DT',function(e){if(e.keyCode==13)
{return false;}});return nFilter;}
function _fnFilterComplete(oSettings,oInput,iForce)
{_fnFilter(oSettings,oInput.sSearch,iForce,oInput.bRegex,oInput.bSmart);for(var i=0;i<oSettings.aoPreSearchCols.length;i++)
{_fnFilterColumn(oSettings,oSettings.aoPreSearchCols[i].sSearch,i,oSettings.aoPreSearchCols[i].bRegex,oSettings.aoPreSearchCols[i].bSmart);}
if(_oExt.afnFiltering.length!==0)
{_fnFilterCustom(oSettings);}
oSettings.bFiltered=true;oSettings._iDisplayStart=0;_fnCalculateEnd(oSettings);_fnDraw(oSettings);_fnBuildSearchArray(oSettings,0);}
function _fnFilterCustom(oSettings)
{var afnFilters=_oExt.afnFiltering;for(var i=0,iLen=afnFilters.length;i<iLen;i++)
{var iCorrector=0;for(var j=0,jLen=oSettings.aiDisplay.length;j<jLen;j++)
{var iDisIndex=oSettings.aiDisplay[j-iCorrector];if(!afnFilters[i](oSettings,oSettings.aoData[iDisIndex]._aData,iDisIndex))
{oSettings.aiDisplay.splice(j-iCorrector,1);iCorrector++;}}}}
function _fnFilterColumn(oSettings,sInput,iColumn,bRegex,bSmart)
{if(sInput==="")
{return;}
var iIndexCorrector=0;var rpSearch=_fnFilterCreateSearch(sInput,bRegex,bSmart);for(var i=oSettings.aiDisplay.length-1;i>=0;i--)
{var sData=_fnDataToSearch(oSettings.aoData[oSettings.aiDisplay[i]]._aData[iColumn],oSettings.aoColumns[iColumn].sType);if(!rpSearch.test(sData))
{oSettings.aiDisplay.splice(i,1);iIndexCorrector++;}}}
function _fnFilter(oSettings,sInput,iForce,bRegex,bSmart)
{var i;var rpSearch=_fnFilterCreateSearch(sInput,bRegex,bSmart);if(typeof iForce=='undefined'||iForce===null)
{iForce=0;}
if(_oExt.afnFiltering.length!==0)
{iForce=1;}
if(sInput.length<=0)
{oSettings.aiDisplay.splice(0,oSettings.aiDisplay.length);oSettings.aiDisplay=oSettings.aiDisplayMaster.slice();}
else
{if(oSettings.aiDisplay.length==oSettings.aiDisplayMaster.length||oSettings.oPreviousSearch.sSearch.length>sInput.length||iForce==1||sInput.indexOf(oSettings.oPreviousSearch.sSearch)!==0)
{oSettings.aiDisplay.splice(0,oSettings.aiDisplay.length);_fnBuildSearchArray(oSettings,1);for(i=0;i<oSettings.aiDisplayMaster.length;i++)
{if(rpSearch.test(oSettings.asDataSearch[i]))
{oSettings.aiDisplay.push(oSettings.aiDisplayMaster[i]);}}}
else
{var iIndexCorrector=0;for(i=0;i<oSettings.asDataSearch.length;i++)
{if(!rpSearch.test(oSettings.asDataSearch[i]))
{oSettings.aiDisplay.splice(i-iIndexCorrector,1);iIndexCorrector++;}}}}
oSettings.oPreviousSearch.sSearch=sInput;oSettings.oPreviousSearch.bRegex=bRegex;oSettings.oPreviousSearch.bSmart=bSmart;}
function _fnBuildSearchArray(oSettings,iMaster)
{oSettings.asDataSearch.splice(0,oSettings.asDataSearch.length);var aArray=(typeof iMaster!='undefined'&&iMaster==1)?oSettings.aiDisplayMaster:oSettings.aiDisplay;for(var i=0,iLen=aArray.length;i<iLen;i++)
{oSettings.asDataSearch[i]=_fnBuildSearchRow(oSettings,oSettings.aoData[aArray[i]]._aData);}}
function _fnBuildSearchRow(oSettings,aData)
{var sSearch='';var nTmp=document.createElement('div');for(var j=0,jLen=oSettings.aoColumns.length;j<jLen;j++)
{if(oSettings.aoColumns[j].bSearchable)
{var sData=aData[j];sSearch+=_fnDataToSearch(sData,oSettings.aoColumns[j].sType)+'  ';}}
if(sSearch.indexOf('&')!==-1)
{nTmp.innerHTML=sSearch;sSearch=nTmp.textContent?nTmp.textContent:nTmp.innerText;sSearch=sSearch.replace(/\n/g," ").replace(/\r/g,"");}
return sSearch;}
function _fnFilterCreateSearch(sSearch,bRegex,bSmart)
{var asSearch,sRegExpString;if(bSmart)
{asSearch=bRegex?sSearch.split(' '):_fnEscapeRegex(sSearch).split(' ');sRegExpString='^(?=.*?'+asSearch.join(')(?=.*?')+').*$';return new RegExp(sRegExpString,"i");}
else
{sSearch=bRegex?sSearch:_fnEscapeRegex(sSearch);return new RegExp(sSearch,"i");}}
function _fnDataToSearch(sData,sType)
{if(typeof _oExt.ofnSearch[sType]=="function")
{return _oExt.ofnSearch[sType](sData);}
else if(sType=="html")
{return sData.replace(/\n/g," ").replace(/<.*?>/g,"");}
else if(typeof sData=="string")
{return sData.replace(/\n/g," ");}
return sData;}
function _fnSort(oSettings,bApplyClasses)
{var
iDataSort,iDataType,i,iLen,j,jLen,aaSort=[],aiOrig=[],oSort=_oExt.oSort,aoData=oSettings.aoData,aoColumns=oSettings.aoColumns;if(!oSettings.oFeatures.bServerSide&&(oSettings.aaSorting.length!==0||oSettings.aaSortingFixed!==null))
{if(oSettings.aaSortingFixed!==null)
{aaSort=oSettings.aaSortingFixed.concat(oSettings.aaSorting);}
else
{aaSort=oSettings.aaSorting.slice();}
for(i=0;i<aaSort.length;i++)
{var iColumn=aaSort[i][0];var iVisColumn=_fnColumnIndexToVisible(oSettings,iColumn);var sDataType=oSettings.aoColumns[iColumn].sSortDataType;if(typeof _oExt.afnSortData[sDataType]!='undefined')
{var aData=_oExt.afnSortData[sDataType](oSettings,iColumn,iVisColumn);for(j=0,jLen=aoData.length;j<jLen;j++)
{aoData[j]._aData[iColumn]=aData[j];}}}
for(i=0,iLen=oSettings.aiDisplayMaster.length;i<iLen;i++)
{aiOrig[oSettings.aiDisplayMaster[i]]=i;}
var iSortLen=aaSort.length;oSettings.aiDisplayMaster.sort(function(a,b){var iTest;for(i=0;i<iSortLen;i++)
{iDataSort=aoColumns[aaSort[i][0]].iDataSort;iDataType=aoColumns[iDataSort].sType;iTest=oSort[iDataType+"-"+aaSort[i][1]](aoData[a]._aData[iDataSort],aoData[b]._aData[iDataSort]);if(iTest!==0)
{return iTest;}}
return oSort['numeric-asc'](aiOrig[a],aiOrig[b]);});}
if(typeof bApplyClasses=='undefined'||bApplyClasses)
{_fnSortingClasses(oSettings);}
oSettings.bSorted=true;if(oSettings.oFeatures.bFilter)
{_fnFilterComplete(oSettings,oSettings.oPreviousSearch,1);}
else
{oSettings.aiDisplay=oSettings.aiDisplayMaster.slice();oSettings._iDisplayStart=0;_fnCalculateEnd(oSettings);_fnDraw(oSettings);}}
function _fnSortAttachListener(oSettings,nNode,iDataIndex,fnCallback)
{$(nNode).bind('click.DT',function(e){if(oSettings.aoColumns[iDataIndex].bSortable===false)
{return;}
var fnInnerSorting=function(){var iColumn,iNextSort;if(e.shiftKey)
{var bFound=false;for(var i=0;i<oSettings.aaSorting.length;i++)
{if(oSettings.aaSorting[i][0]==iDataIndex)
{bFound=true;iColumn=oSettings.aaSorting[i][0];iNextSort=oSettings.aaSorting[i][2]+1;if(typeof oSettings.aoColumns[iColumn].asSorting[iNextSort]=='undefined')
{oSettings.aaSorting.splice(i,1);}
else
{oSettings.aaSorting[i][1]=oSettings.aoColumns[iColumn].asSorting[iNextSort];oSettings.aaSorting[i][2]=iNextSort;}
break;}}
if(bFound===false)
{oSettings.aaSorting.push([iDataIndex,oSettings.aoColumns[iDataIndex].asSorting[0],0]);}}
else
{if(oSettings.aaSorting.length==1&&oSettings.aaSorting[0][0]==iDataIndex)
{iColumn=oSettings.aaSorting[0][0];iNextSort=oSettings.aaSorting[0][2]+1;if(typeof oSettings.aoColumns[iColumn].asSorting[iNextSort]=='undefined')
{iNextSort=0;}
oSettings.aaSorting[0][1]=oSettings.aoColumns[iColumn].asSorting[iNextSort];oSettings.aaSorting[0][2]=iNextSort;}
else
{oSettings.aaSorting.splice(0,oSettings.aaSorting.length);oSettings.aaSorting.push([iDataIndex,oSettings.aoColumns[iDataIndex].asSorting[0],0]);}}
_fnSort(oSettings);};if(!oSettings.oFeatures.bProcessing)
{fnInnerSorting();}
else
{_fnProcessingDisplay(oSettings,true);setTimeout(function(){fnInnerSorting();if(!oSettings.oFeatures.bServerSide)
{_fnProcessingDisplay(oSettings,false);}},0);}
if(typeof fnCallback=='function')
{fnCallback(oSettings);}});}
function _fnSortingClasses(oSettings)
{var i,iLen,j,jLen,iFound;var aaSort,sClass;var iColumns=oSettings.aoColumns.length;var oClasses=oSettings.oClasses;for(i=0;i<iColumns;i++)
{if(oSettings.aoColumns[i].bSortable)
{$(oSettings.aoColumns[i].nTh).removeClass(oClasses.sSortAsc+" "+oClasses.sSortDesc+
" "+oSettings.aoColumns[i].sSortingClass);}}
if(oSettings.aaSortingFixed!==null)
{aaSort=oSettings.aaSortingFixed.concat(oSettings.aaSorting);}
else
{aaSort=oSettings.aaSorting.slice();}
for(i=0;i<oSettings.aoColumns.length;i++)
{if(oSettings.aoColumns[i].bSortable)
{sClass=oSettings.aoColumns[i].sSortingClass;iFound=-1;for(j=0;j<aaSort.length;j++)
{if(aaSort[j][0]==i)
{sClass=(aaSort[j][1]=="asc")?oClasses.sSortAsc:oClasses.sSortDesc;iFound=j;break;}}
$(oSettings.aoColumns[i].nTh).addClass(sClass);if(oSettings.bJUI)
{var jqSpan=$("span",oSettings.aoColumns[i].nTh);jqSpan.removeClass(oClasses.sSortJUIAsc+" "+oClasses.sSortJUIDesc+" "+
oClasses.sSortJUI+" "+oClasses.sSortJUIAscAllowed+" "+oClasses.sSortJUIDescAllowed);var sSpanClass;if(iFound==-1)
{sSpanClass=oSettings.aoColumns[i].sSortingClassJUI;}
else if(aaSort[iFound][1]=="asc")
{sSpanClass=oClasses.sSortJUIAsc;}
else
{sSpanClass=oClasses.sSortJUIDesc;}
jqSpan.addClass(sSpanClass);}}
else
{$(oSettings.aoColumns[i].nTh).addClass(oSettings.aoColumns[i].sSortingClass);}}
sClass=oClasses.sSortColumn;if(oSettings.oFeatures.bSort&&oSettings.oFeatures.bSortClasses)
{var nTds=_fnGetTdNodes(oSettings);if(nTds.length>=iColumns)
{for(i=0;i<iColumns;i++)
{if(nTds[i].className.indexOf(sClass+"1")!=-1)
{for(j=0,jLen=(nTds.length/iColumns);j<jLen;j++)
{nTds[(iColumns*j)+i].className=$.trim(nTds[(iColumns*j)+i].className.replace(sClass+"1",""));}}
else if(nTds[i].className.indexOf(sClass+"2")!=-1)
{for(j=0,jLen=(nTds.length/iColumns);j<jLen;j++)
{nTds[(iColumns*j)+i].className=$.trim(nTds[(iColumns*j)+i].className.replace(sClass+"2",""));}}
else if(nTds[i].className.indexOf(sClass+"3")!=-1)
{for(j=0,jLen=(nTds.length/iColumns);j<jLen;j++)
{nTds[(iColumns*j)+i].className=$.trim(nTds[(iColumns*j)+i].className.replace(" "+sClass+"3",""));}}}}
var iClass=1,iTargetCol;for(i=0;i<aaSort.length;i++)
{iTargetCol=parseInt(aaSort[i][0],10);for(j=0,jLen=(nTds.length/iColumns);j<jLen;j++)
{nTds[(iColumns*j)+iTargetCol].className+=" "+sClass+iClass;}
if(iClass<3)
{iClass++;}}}}
function _fnFeatureHtmlPaginate(oSettings)
{if(oSettings.oScroll.bInfinite)
{return null;}
var nPaginate=document.createElement('div');nPaginate.className=oSettings.oClasses.sPaging+oSettings.sPaginationType;_oExt.oPagination[oSettings.sPaginationType].fnInit(oSettings,nPaginate,function(oSettings){_fnCalculateEnd(oSettings);_fnDraw(oSettings);});if(typeof oSettings.aanFeatures.p=="undefined")
{oSettings.aoDrawCallback.push({"fn":function(oSettings){_oExt.oPagination[oSettings.sPaginationType].fnUpdate(oSettings,function(oSettings){_fnCalculateEnd(oSettings);_fnDraw(oSettings);});},"sName":"pagination"});}
return nPaginate;}
function _fnPageChange(oSettings,sAction)
{var iOldStart=oSettings._iDisplayStart;if(sAction=="first")
{oSettings._iDisplayStart=0;}
else if(sAction=="previous")
{oSettings._iDisplayStart=oSettings._iDisplayLength>=0?oSettings._iDisplayStart-oSettings._iDisplayLength:0;if(oSettings._iDisplayStart<0)
{oSettings._iDisplayStart=0;}}
else if(sAction=="next")
{if(oSettings._iDisplayLength>=0)
{if(oSettings._iDisplayStart+oSettings._iDisplayLength<oSettings.fnRecordsDisplay())
{oSettings._iDisplayStart+=oSettings._iDisplayLength;}}
else
{oSettings._iDisplayStart=0;}}
else if(sAction=="last")
{if(oSettings._iDisplayLength>=0)
{var iPages=parseInt((oSettings.fnRecordsDisplay()-1)/oSettings._iDisplayLength,10)+1;oSettings._iDisplayStart=(iPages-1)*oSettings._iDisplayLength;}
else
{oSettings._iDisplayStart=0;}}
else
{_fnLog(oSettings,0,"Unknown paging action: "+sAction);}
return iOldStart!=oSettings._iDisplayStart;}
function _fnFeatureHtmlInfo(oSettings)
{var nInfo=document.createElement('div');nInfo.className=oSettings.oClasses.sInfo;if(typeof oSettings.aanFeatures.i=="undefined")
{oSettings.aoDrawCallback.push({"fn":_fnUpdateInfo,"sName":"information"});if(oSettings.sTableId!=='')
{nInfo.setAttribute('id',oSettings.sTableId+'_info');}}
return nInfo;}
function _fnUpdateInfo(oSettings)
{if(!oSettings.oFeatures.bInfo||oSettings.aanFeatures.i.length===0)
{return;}
var
iStart=oSettings._iDisplayStart+1,iEnd=oSettings.fnDisplayEnd(),iMax=oSettings.fnRecordsTotal(),iTotal=oSettings.fnRecordsDisplay(),sStart=oSettings.fnFormatNumber(iStart),sEnd=oSettings.fnFormatNumber(iEnd),sMax=oSettings.fnFormatNumber(iMax),sTotal=oSettings.fnFormatNumber(iTotal),sOut;if(oSettings.oScroll.bInfinite)
{sStart=oSettings.fnFormatNumber(1);}
if(oSettings.fnRecordsDisplay()===0&&oSettings.fnRecordsDisplay()==oSettings.fnRecordsTotal())
{sOut=oSettings.oLanguage.sInfoEmpty+oSettings.oLanguage.sInfoPostFix;}
else if(oSettings.fnRecordsDisplay()===0)
{sOut=oSettings.oLanguage.sInfoEmpty+' '+
oSettings.oLanguage.sInfoFiltered.replace('_MAX_',sMax)+
oSettings.oLanguage.sInfoPostFix;}
else if(oSettings.fnRecordsDisplay()==oSettings.fnRecordsTotal())
{sOut=oSettings.oLanguage.sInfo.replace('_START_',sStart).replace('_END_',sEnd).replace('_TOTAL_',sTotal)+
oSettings.oLanguage.sInfoPostFix;}
else
{sOut=oSettings.oLanguage.sInfo.replace('_START_',sStart).replace('_END_',sEnd).replace('_TOTAL_',sTotal)+' '+
oSettings.oLanguage.sInfoFiltered.replace('_MAX_',oSettings.fnFormatNumber(oSettings.fnRecordsTotal()))+
oSettings.oLanguage.sInfoPostFix;}
if(oSettings.oLanguage.fnInfoCallback!==null)
{sOut=oSettings.oLanguage.fnInfoCallback(oSettings,iStart,iEnd,iMax,iTotal,sOut);}
var n=oSettings.aanFeatures.i;for(var i=0,iLen=n.length;i<iLen;i++)
{$(n[i]).html(sOut);}}
function _fnFeatureHtmlLength(oSettings)
{if(oSettings.oScroll.bInfinite)
{return null;}
var sName=(oSettings.sTableId==="")?"":'name="'+oSettings.sTableId+'_length"';var sStdMenu='<select size="1" '+sName+'>';var i,iLen;if(oSettings.aLengthMenu.length==2&&typeof oSettings.aLengthMenu[0]=='object'&&typeof oSettings.aLengthMenu[1]=='object')
{for(i=0,iLen=oSettings.aLengthMenu[0].length;i<iLen;i++)
{sStdMenu+='<option value="'+oSettings.aLengthMenu[0][i]+'">'+
oSettings.aLengthMenu[1][i]+'</option>';}}
else
{for(i=0,iLen=oSettings.aLengthMenu.length;i<iLen;i++)
{sStdMenu+='<option value="'+oSettings.aLengthMenu[i]+'">'+
oSettings.aLengthMenu[i]+'</option>';}}
sStdMenu+='</select>';var nLength=document.createElement('div');if(oSettings.sTableId!==''&&typeof oSettings.aanFeatures.l=="undefined")
{nLength.setAttribute('id',oSettings.sTableId+'_length');}
nLength.className=oSettings.oClasses.sLength;nLength.innerHTML=oSettings.oLanguage.sLengthMenu.replace('_MENU_',sStdMenu);$('select option[value="'+oSettings._iDisplayLength+'"]',nLength).attr("selected",true);$('select',nLength).bind('change.DT',function(e){var iVal=$(this).val();var n=oSettings.aanFeatures.l;for(i=0,iLen=n.length;i<iLen;i++)
{if(n[i]!=this.parentNode)
{$('select',n[i]).val(iVal);}}
oSettings._iDisplayLength=parseInt(iVal,10);_fnCalculateEnd(oSettings);if(oSettings.fnDisplayEnd()==oSettings.fnRecordsDisplay())
{oSettings._iDisplayStart=oSettings.fnDisplayEnd()-oSettings._iDisplayLength;if(oSettings._iDisplayStart<0)
{oSettings._iDisplayStart=0;}}
if(oSettings._iDisplayLength==-1)
{oSettings._iDisplayStart=0;}
_fnDraw(oSettings);});return nLength;}
function _fnFeatureHtmlProcessing(oSettings)
{var nProcessing=document.createElement('div');if(oSettings.sTableId!==''&&typeof oSettings.aanFeatures.r=="undefined")
{nProcessing.setAttribute('id',oSettings.sTableId+'_processing');}
nProcessing.innerHTML=oSettings.oLanguage.sProcessing;nProcessing.className=oSettings.oClasses.sProcessing;oSettings.nTable.parentNode.insertBefore(nProcessing,oSettings.nTable);return nProcessing;}
function _fnProcessingDisplay(oSettings,bShow)
{if(oSettings.oFeatures.bProcessing)
{var an=oSettings.aanFeatures.r;for(var i=0,iLen=an.length;i<iLen;i++)
{an[i].style.visibility=bShow?"visible":"hidden";}}}
function _fnVisibleToColumnIndex(oSettings,iMatch)
{var iColumn=-1;for(var i=0;i<oSettings.aoColumns.length;i++)
{if(oSettings.aoColumns[i].bVisible===true)
{iColumn++;}
if(iColumn==iMatch)
{return i;}}
return null;}
function _fnColumnIndexToVisible(oSettings,iMatch)
{var iVisible=-1;for(var i=0;i<oSettings.aoColumns.length;i++)
{if(oSettings.aoColumns[i].bVisible===true)
{iVisible++;}
if(i==iMatch)
{return oSettings.aoColumns[i].bVisible===true?iVisible:null;}}
return null;}
function _fnNodeToDataIndex(s,n)
{var i,iLen;for(i=s._iDisplayStart,iLen=s._iDisplayEnd;i<iLen;i++)
{if(s.aoData[s.aiDisplay[i]].nTr==n)
{return s.aiDisplay[i];}}
for(i=0,iLen=s.aoData.length;i<iLen;i++)
{if(s.aoData[i].nTr==n)
{return i;}}
return null;}
function _fnVisbleColumns(oS)
{var iVis=0;for(var i=0;i<oS.aoColumns.length;i++)
{if(oS.aoColumns[i].bVisible===true)
{iVis++;}}
return iVis;}
function _fnCalculateEnd(oSettings)
{if(oSettings.oFeatures.bPaginate===false)
{oSettings._iDisplayEnd=oSettings.aiDisplay.length;}
else
{if(oSettings._iDisplayStart+oSettings._iDisplayLength>oSettings.aiDisplay.length||oSettings._iDisplayLength==-1)
{oSettings._iDisplayEnd=oSettings.aiDisplay.length;}
else
{oSettings._iDisplayEnd=oSettings._iDisplayStart+oSettings._iDisplayLength;}}}
function _fnConvertToWidth(sWidth,nParent)
{if(!sWidth||sWidth===null||sWidth==='')
{return 0;}
if(typeof nParent=="undefined")
{nParent=document.getElementsByTagName('body')[0];}
var iWidth;var nTmp=document.createElement("div");nTmp.style.width=sWidth;nParent.appendChild(nTmp);iWidth=nTmp.offsetWidth;nParent.removeChild(nTmp);return(iWidth);}
function _fnCalculateColumnWidths(oSettings)
{var iTableWidth=oSettings.nTable.offsetWidth;var iUserInputs=0;var iTmpWidth;var iVisibleColumns=0;var iColums=oSettings.aoColumns.length;var i;var oHeaders=$('th',oSettings.nTHead);for(i=0;i<iColums;i++)
{if(oSettings.aoColumns[i].bVisible)
{iVisibleColumns++;if(oSettings.aoColumns[i].sWidth!==null)
{iTmpWidth=_fnConvertToWidth(oSettings.aoColumns[i].sWidthOrig,oSettings.nTable.parentNode);if(iTmpWidth!==null)
{oSettings.aoColumns[i].sWidth=_fnStringToCss(iTmpWidth);}
iUserInputs++;}}}
if(iColums==oHeaders.length&&iUserInputs===0&&iVisibleColumns==iColums&&oSettings.oScroll.sX===""&&oSettings.oScroll.sY==="")
{for(i=0;i<oSettings.aoColumns.length;i++)
{iTmpWidth=$(oHeaders[i]).width();if(iTmpWidth!==null)
{oSettings.aoColumns[i].sWidth=_fnStringToCss(iTmpWidth);}}}
else
{var
nCalcTmp=oSettings.nTable.cloneNode(false),nBody=document.createElement('tbody'),nTr=document.createElement('tr'),nDivSizing;nCalcTmp.removeAttribute("id");nCalcTmp.appendChild(oSettings.nTHead.cloneNode(true));if(oSettings.nTFoot!==null)
{nCalcTmp.appendChild(oSettings.nTFoot.cloneNode(true));_fnApplyToChildren(function(n){n.style.width="";},nCalcTmp.getElementsByTagName('tr'));}
nCalcTmp.appendChild(nBody);nBody.appendChild(nTr);var jqColSizing=$('thead th',nCalcTmp);if(jqColSizing.length===0)
{jqColSizing=$('tbody tr:eq(0)>td',nCalcTmp);}
jqColSizing.each(function(i){this.style.width="";var iIndex=_fnVisibleToColumnIndex(oSettings,i);if(iIndex!==null&&oSettings.aoColumns[iIndex].sWidthOrig!=="")
{this.style.width=oSettings.aoColumns[iIndex].sWidthOrig;}});for(i=0;i<iColums;i++)
{if(oSettings.aoColumns[i].bVisible)
{var nTd=_fnGetWidestNode(oSettings,i);if(nTd!==null)
{nTd=nTd.cloneNode(true);nTr.appendChild(nTd);}}}
var nWrapper=oSettings.nTable.parentNode;nWrapper.appendChild(nCalcTmp);if(oSettings.oScroll.sX!==""&&oSettings.oScroll.sXInner!=="")
{nCalcTmp.style.width=_fnStringToCss(oSettings.oScroll.sXInner);}
else if(oSettings.oScroll.sX!=="")
{nCalcTmp.style.width="";if($(nCalcTmp).width()<nWrapper.offsetWidth)
{nCalcTmp.style.width=_fnStringToCss(nWrapper.offsetWidth);}}
else if(oSettings.oScroll.sY!=="")
{nCalcTmp.style.width=_fnStringToCss(nWrapper.offsetWidth);}
nCalcTmp.style.visibility="hidden";_fnScrollingWidthAdjust(oSettings,nCalcTmp);var oNodes=$("tbody tr:eq(0)>td",nCalcTmp);if(oNodes.length===0)
{oNodes=$("thead tr:eq(0)>th",nCalcTmp);}
var iIndex,iCorrector=0,iWidth;for(i=0;i<oSettings.aoColumns.length;i++)
{if(oSettings.aoColumns[i].bVisible)
{iWidth=$(oNodes[iCorrector]).outerWidth();if(iWidth!==null&&iWidth>0)
{oSettings.aoColumns[i].sWidth=_fnStringToCss(iWidth);}
iCorrector++;}}
oSettings.nTable.style.width=_fnStringToCss($(nCalcTmp).outerWidth());nCalcTmp.parentNode.removeChild(nCalcTmp);}}
function _fnScrollingWidthAdjust(oSettings,n)
{if(oSettings.oScroll.sX===""&&oSettings.oScroll.sY!=="")
{var iOrigWidth=$(n).width();n.style.width=_fnStringToCss($(n).outerWidth()-oSettings.oScroll.iBarWidth);}
else if(oSettings.oScroll.sX!=="")
{n.style.width=_fnStringToCss($(n).outerWidth());}}
function _fnGetWidestNode(oSettings,iCol,bFast)
{if(typeof bFast=='undefined'||bFast)
{var iMaxLen=_fnGetMaxLenString(oSettings,iCol);var iFastVis=_fnColumnIndexToVisible(oSettings,iCol);if(iMaxLen<0)
{return null;}
return oSettings.aoData[iMaxLen].nTr.getElementsByTagName('td')[iFastVis];}
var
iMax=-1,i,iLen,iMaxIndex=-1,n=document.createElement('div');n.style.visibility="hidden";n.style.position="absolute";document.body.appendChild(n);for(i=0,iLen=oSettings.aoData.length;i<iLen;i++)
{n.innerHTML=oSettings.aoData[i]._aData[iCol];if(n.offsetWidth>iMax)
{iMax=n.offsetWidth;iMaxIndex=i;}}
document.body.removeChild(n);if(iMaxIndex>=0)
{var iVis=_fnColumnIndexToVisible(oSettings,iCol);var nRet=oSettings.aoData[iMaxIndex].nTr.getElementsByTagName('td')[iVis];if(nRet)
{return nRet;}}
return null;}
function _fnGetMaxLenString(oSettings,iCol)
{var iMax=-1;var iMaxIndex=-1;for(var i=0;i<oSettings.aoData.length;i++)
{var s=oSettings.aoData[i]._aData[iCol];if(s.length>iMax)
{iMax=s.length;iMaxIndex=i;}}
return iMaxIndex;}
function _fnStringToCss(s)
{if(s===null)
{return"0px";}
if(typeof s=='number')
{if(s<0)
{return"0px";}
return s+"px";}
var c=s.charCodeAt(s.length-1);if(c<0x30||c>0x39)
{return s;}
return s+"px";}
function _fnArrayCmp(aArray1,aArray2)
{if(aArray1.length!=aArray2.length)
{return 1;}
for(var i=0;i<aArray1.length;i++)
{if(aArray1[i]!=aArray2[i])
{return 2;}}
return 0;}
function _fnDetectType(sData)
{var aTypes=_oExt.aTypes;var iLen=aTypes.length;for(var i=0;i<iLen;i++)
{var sType=aTypes[i](sData);if(sType!==null)
{return sType;}}
return'string';}
function _fnSettingsFromNode(nTable)
{for(var i=0;i<_aoSettings.length;i++)
{if(_aoSettings[i].nTable==nTable)
{return _aoSettings[i];}}
return null;}
function _fnGetDataMaster(oSettings)
{var aData=[];var iLen=oSettings.aoData.length;for(var i=0;i<iLen;i++)
{aData.push(oSettings.aoData[i]._aData);}
return aData;}
function _fnGetTrNodes(oSettings)
{var aNodes=[];var iLen=oSettings.aoData.length;for(var i=0;i<iLen;i++)
{aNodes.push(oSettings.aoData[i].nTr);}
return aNodes;}
function _fnGetTdNodes(oSettings)
{var nTrs=_fnGetTrNodes(oSettings);var nTds=[],nTd;var anReturn=[];var iCorrector;var iRow,iRows,iColumn,iColumns;for(iRow=0,iRows=nTrs.length;iRow<iRows;iRow++)
{nTds=[];for(iColumn=0,iColumns=nTrs[iRow].childNodes.length;iColumn<iColumns;iColumn++)
{nTd=nTrs[iRow].childNodes[iColumn];if(nTd.nodeName.toUpperCase()=="TD")
{nTds.push(nTd);}}
iCorrector=0;for(iColumn=0,iColumns=oSettings.aoColumns.length;iColumn<iColumns;iColumn++)
{if(oSettings.aoColumns[iColumn].bVisible)
{anReturn.push(nTds[iColumn-iCorrector]);}
else
{anReturn.push(oSettings.aoData[iRow]._anHidden[iColumn]);iCorrector++;}}}
return anReturn;}
function _fnEscapeRegex(sVal)
{var acEscape=['/','.','*','+','?','|','(',')','[',']','{','}','\\','$','^'];var reReplace=new RegExp('(\\'+acEscape.join('|\\')+')','g');return sVal.replace(reReplace,'\\$1');}
function _fnDeleteIndex(a,iTarget)
{var iTargetIndex=-1;for(var i=0,iLen=a.length;i<iLen;i++)
{if(a[i]==iTarget)
{iTargetIndex=i;}
else if(a[i]>iTarget)
{a[i]--;}}
if(iTargetIndex!=-1)
{a.splice(iTargetIndex,1);}}
function _fnReOrderIndex(oSettings,sColumns)
{var aColumns=sColumns.split(',');var aiReturn=[];for(var i=0,iLen=oSettings.aoColumns.length;i<iLen;i++)
{for(var j=0;j<iLen;j++)
{if(oSettings.aoColumns[i].sName==aColumns[j])
{aiReturn.push(j);break;}}}
return aiReturn;}
function _fnColumnOrdering(oSettings)
{var sNames='';for(var i=0,iLen=oSettings.aoColumns.length;i<iLen;i++)
{sNames+=oSettings.aoColumns[i].sName+',';}
if(sNames.length==iLen)
{return"";}
return sNames.slice(0,-1);}
function _fnLog(oSettings,iLevel,sMesg)
{var sAlert=oSettings.sTableId===""?"DataTables warning: "+sMesg:"DataTables warning (table id = '"+oSettings.sTableId+"'): "+sMesg;if(iLevel===0)
{if(_oExt.sErrMode=='alert')
{alert(sAlert);}
else
{throw sAlert;}
return;}
else if(typeof console!='undefined'&&typeof console.log!='undefined')
{console.log(sAlert);}}
function _fnClearTable(oSettings)
{oSettings.aoData.splice(0,oSettings.aoData.length);oSettings.aiDisplayMaster.splice(0,oSettings.aiDisplayMaster.length);oSettings.aiDisplay.splice(0,oSettings.aiDisplay.length);_fnCalculateEnd(oSettings);}
function _fnSaveState(oSettings)
{if(!oSettings.oFeatures.bStateSave||typeof oSettings.bDestroying!='undefined')
{return;}
var i,iLen,sTmp;var sValue="{";sValue+='"iCreate":'+new Date().getTime()+',';sValue+='"iStart":'+oSettings._iDisplayStart+',';sValue+='"iEnd":'+oSettings._iDisplayEnd+',';sValue+='"iLength":'+oSettings._iDisplayLength+',';sValue+='"sFilter":"'+encodeURIComponent(oSettings.oPreviousSearch.sSearch)+'",';sValue+='"sFilterEsc":'+!oSettings.oPreviousSearch.bRegex+',';sValue+='"aaSorting":[ ';for(i=0;i<oSettings.aaSorting.length;i++)
{sValue+='['+oSettings.aaSorting[i][0]+',"'+oSettings.aaSorting[i][1]+'"],';}
sValue=sValue.substring(0,sValue.length-1);sValue+="],";sValue+='"aaSearchCols":[ ';for(i=0;i<oSettings.aoPreSearchCols.length;i++)
{sValue+='["'+encodeURIComponent(oSettings.aoPreSearchCols[i].sSearch)+
'",'+!oSettings.aoPreSearchCols[i].bRegex+'],';}
sValue=sValue.substring(0,sValue.length-1);sValue+="],";sValue+='"abVisCols":[ ';for(i=0;i<oSettings.aoColumns.length;i++)
{sValue+=oSettings.aoColumns[i].bVisible+",";}
sValue=sValue.substring(0,sValue.length-1);sValue+="]";for(i=0,iLen=oSettings.aoStateSave.length;i<iLen;i++)
{sTmp=oSettings.aoStateSave[i].fn(oSettings,sValue);if(sTmp!=="")
{sValue=sTmp;}}
sValue+="}";_fnCreateCookie(oSettings.sCookiePrefix+oSettings.sInstance,sValue,oSettings.iCookieDuration,oSettings.sCookiePrefix,oSettings.fnCookieCallback);}
function _fnLoadState(oSettings,oInit)
{if(!oSettings.oFeatures.bStateSave)
{return;}
var oData,i,iLen;var sData=_fnReadCookie(oSettings.sCookiePrefix+oSettings.sInstance);if(sData!==null&&sData!=='')
{try
{oData=(typeof $.parseJSON=='function')?$.parseJSON(sData.replace(/'/g,'"')):eval('('+sData+')');}
catch(e)
{return;}
for(i=0,iLen=oSettings.aoStateLoad.length;i<iLen;i++)
{if(!oSettings.aoStateLoad[i].fn(oSettings,oData))
{return;}}
oSettings.oLoadedState=$.extend(true,{},oData);oSettings._iDisplayStart=oData.iStart;oSettings.iInitDisplayStart=oData.iStart;oSettings._iDisplayEnd=oData.iEnd;oSettings._iDisplayLength=oData.iLength;oSettings.oPreviousSearch.sSearch=decodeURIComponent(oData.sFilter);oSettings.aaSorting=oData.aaSorting.slice();oSettings.saved_aaSorting=oData.aaSorting.slice();if(typeof oData.sFilterEsc!='undefined')
{oSettings.oPreviousSearch.bRegex=!oData.sFilterEsc;}
if(typeof oData.aaSearchCols!='undefined')
{for(i=0;i<oData.aaSearchCols.length;i++)
{oSettings.aoPreSearchCols[i]={"sSearch":decodeURIComponent(oData.aaSearchCols[i][0]),"bRegex":!oData.aaSearchCols[i][1]};}}
if(typeof oData.abVisCols!='undefined')
{oInit.saved_aoColumns=[];for(i=0;i<oData.abVisCols.length;i++)
{oInit.saved_aoColumns[i]={};oInit.saved_aoColumns[i].bVisible=oData.abVisCols[i];}}}}
function _fnCreateCookie(sName,sValue,iSecs,sBaseName,fnCallback)
{var date=new Date();date.setTime(date.getTime()+(iSecs*1000));var aParts=window.location.pathname.split('/');var sNameFile=sName+'_'+aParts.pop().replace(/[\/:]/g,"").toLowerCase();var sFullCookie,oData;if(fnCallback!==null)
{oData=(typeof $.parseJSON=='function')?$.parseJSON(sValue):eval('('+sValue+')');sFullCookie=fnCallback(sNameFile,oData,date.toGMTString(),aParts.join('/')+"/");}
else
{sFullCookie=sNameFile+"="+encodeURIComponent(sValue)+
"; expires="+date.toGMTString()+"; path="+aParts.join('/')+"/";}
var sOldName="",iOldTime=9999999999999;var iLength=_fnReadCookie(sNameFile)!==null?document.cookie.length:sFullCookie.length+document.cookie.length;if(iLength+10>4096)
{var aCookies=document.cookie.split(';');for(var i=0,iLen=aCookies.length;i<iLen;i++)
{if(aCookies[i].indexOf(sBaseName)!=-1)
{var aSplitCookie=aCookies[i].split('=');try{oData=eval('('+decodeURIComponent(aSplitCookie[1])+')');}
catch(e){continue;}
if(typeof oData.iCreate!='undefined'&&oData.iCreate<iOldTime)
{sOldName=aSplitCookie[0];iOldTime=oData.iCreate;}}}
if(sOldName!=="")
{document.cookie=sOldName+"=; expires=Thu, 01-Jan-1970 00:00:01 GMT; path="+
aParts.join('/')+"/";}}
document.cookie=sFullCookie;}
function _fnReadCookie(sName)
{var
aParts=window.location.pathname.split('/'),sNameEQ=sName+'_'+aParts[aParts.length-1].replace(/[\/:]/g,"").toLowerCase()+'=',sCookieContents=document.cookie.split(';');for(var i=0;i<sCookieContents.length;i++)
{var c=sCookieContents[i];while(c.charAt(0)==' ')
{c=c.substring(1,c.length);}
if(c.indexOf(sNameEQ)===0)
{return decodeURIComponent(c.substring(sNameEQ.length,c.length));}}
return null;}
function _fnGetUniqueThs(nThead)
{var nTrs=nThead.getElementsByTagName('tr');if(nTrs.length==1)
{return nTrs[0].getElementsByTagName('th');}
var aLayout=[],aReturn=[];var ROWSPAN=2,COLSPAN=3,TDELEM=4;var i,j,k,iLen,jLen,iColumnShifted;var fnShiftCol=function(a,i,j){while(typeof a[i][j]!='undefined'){j++;}
return j;};var fnAddRow=function(i){if(typeof aLayout[i]=='undefined'){aLayout[i]=[];}};for(i=0,iLen=nTrs.length;i<iLen;i++)
{fnAddRow(i);var iColumn=0;var nTds=[];for(j=0,jLen=nTrs[i].childNodes.length;j<jLen;j++)
{if(nTrs[i].childNodes[j].nodeName.toUpperCase()=="TD"||nTrs[i].childNodes[j].nodeName.toUpperCase()=="TH")
{nTds.push(nTrs[i].childNodes[j]);}}
for(j=0,jLen=nTds.length;j<jLen;j++)
{var iColspan=nTds[j].getAttribute('colspan')*1;var iRowspan=nTds[j].getAttribute('rowspan')*1;if(!iColspan||iColspan===0||iColspan===1)
{iColumnShifted=fnShiftCol(aLayout,i,iColumn);aLayout[i][iColumnShifted]=(nTds[j].nodeName.toUpperCase()=="TD")?TDELEM:nTds[j];if(iRowspan||iRowspan===0||iRowspan===1)
{for(k=1;k<iRowspan;k++)
{fnAddRow(i+k);aLayout[i+k][iColumnShifted]=ROWSPAN;}}
iColumn++;}
else
{iColumnShifted=fnShiftCol(aLayout,i,iColumn);for(k=0;k<iColspan;k++)
{aLayout[i][iColumnShifted+k]=COLSPAN;}
iColumn+=iColspan;}}}
for(i=0,iLen=aLayout.length;i<iLen;i++)
{for(j=0,jLen=aLayout[i].length;j<jLen;j++)
{if(typeof aLayout[i][j]=='object'&&typeof aReturn[j]=='undefined')
{aReturn[j]=aLayout[i][j];}}}
return aReturn;}
function _fnScrollBarWidth()
{var inner=document.createElement('p');var style=inner.style;style.width="100%";style.height="200px";var outer=document.createElement('div');style=outer.style;style.position="absolute";style.top="0px";style.left="0px";style.visibility="hidden";style.width="200px";style.height="150px";style.overflow="hidden";outer.appendChild(inner);document.body.appendChild(outer);var w1=inner.offsetWidth;outer.style.overflow='scroll';var w2=inner.offsetWidth;if(w1==w2)
{w2=outer.clientWidth;}
document.body.removeChild(outer);return(w1-w2);}
function _fnApplyToChildren(fn,an1,an2)
{for(var i=0,iLen=an1.length;i<iLen;i++)
{for(var j=0,jLen=an1[i].childNodes.length;j<jLen;j++)
{if(an1[i].childNodes[j].nodeType==1)
{if(typeof an2!='undefined')
{fn(an1[i].childNodes[j],an2[i].childNodes[j]);}
else
{fn(an1[i].childNodes[j]);}}}}}
function _fnMap(oRet,oSrc,sName,sMappedName)
{if(typeof sMappedName=='undefined')
{sMappedName=sName;}
if(typeof oSrc[sName]!='undefined')
{oRet[sMappedName]=oSrc[sName];}}
this.oApi._fnExternApiFunc=_fnExternApiFunc;this.oApi._fnInitalise=_fnInitalise;this.oApi._fnLanguageProcess=_fnLanguageProcess;this.oApi._fnAddColumn=_fnAddColumn;this.oApi._fnColumnOptions=_fnColumnOptions;this.oApi._fnAddData=_fnAddData;this.oApi._fnGatherData=_fnGatherData;this.oApi._fnDrawHead=_fnDrawHead;this.oApi._fnDraw=_fnDraw;this.oApi._fnReDraw=_fnReDraw;this.oApi._fnAjaxUpdate=_fnAjaxUpdate;this.oApi._fnAjaxUpdateDraw=_fnAjaxUpdateDraw;this.oApi._fnAddOptionsHtml=_fnAddOptionsHtml;this.oApi._fnFeatureHtmlTable=_fnFeatureHtmlTable;this.oApi._fnScrollDraw=_fnScrollDraw;this.oApi._fnAjustColumnSizing=_fnAjustColumnSizing;this.oApi._fnFeatureHtmlFilter=_fnFeatureHtmlFilter;this.oApi._fnFilterComplete=_fnFilterComplete;this.oApi._fnFilterCustom=_fnFilterCustom;this.oApi._fnFilterColumn=_fnFilterColumn;this.oApi._fnFilter=_fnFilter;this.oApi._fnBuildSearchArray=_fnBuildSearchArray;this.oApi._fnBuildSearchRow=_fnBuildSearchRow;this.oApi._fnFilterCreateSearch=_fnFilterCreateSearch;this.oApi._fnDataToSearch=_fnDataToSearch;this.oApi._fnSort=_fnSort;this.oApi._fnSortAttachListener=_fnSortAttachListener;this.oApi._fnSortingClasses=_fnSortingClasses;this.oApi._fnFeatureHtmlPaginate=_fnFeatureHtmlPaginate;this.oApi._fnPageChange=_fnPageChange;this.oApi._fnFeatureHtmlInfo=_fnFeatureHtmlInfo;this.oApi._fnUpdateInfo=_fnUpdateInfo;this.oApi._fnFeatureHtmlLength=_fnFeatureHtmlLength;this.oApi._fnFeatureHtmlProcessing=_fnFeatureHtmlProcessing;this.oApi._fnProcessingDisplay=_fnProcessingDisplay;this.oApi._fnVisibleToColumnIndex=_fnVisibleToColumnIndex;this.oApi._fnColumnIndexToVisible=_fnColumnIndexToVisible;this.oApi._fnNodeToDataIndex=_fnNodeToDataIndex;this.oApi._fnVisbleColumns=_fnVisbleColumns;this.oApi._fnCalculateEnd=_fnCalculateEnd;this.oApi._fnConvertToWidth=_fnConvertToWidth;this.oApi._fnCalculateColumnWidths=_fnCalculateColumnWidths;this.oApi._fnScrollingWidthAdjust=_fnScrollingWidthAdjust;this.oApi._fnGetWidestNode=_fnGetWidestNode;this.oApi._fnGetMaxLenString=_fnGetMaxLenString;this.oApi._fnStringToCss=_fnStringToCss;this.oApi._fnArrayCmp=_fnArrayCmp;this.oApi._fnDetectType=_fnDetectType;this.oApi._fnSettingsFromNode=_fnSettingsFromNode;this.oApi._fnGetDataMaster=_fnGetDataMaster;this.oApi._fnGetTrNodes=_fnGetTrNodes;this.oApi._fnGetTdNodes=_fnGetTdNodes;this.oApi._fnEscapeRegex=_fnEscapeRegex;this.oApi._fnDeleteIndex=_fnDeleteIndex;this.oApi._fnReOrderIndex=_fnReOrderIndex;this.oApi._fnColumnOrdering=_fnColumnOrdering;this.oApi._fnLog=_fnLog;this.oApi._fnClearTable=_fnClearTable;this.oApi._fnSaveState=_fnSaveState;this.oApi._fnLoadState=_fnLoadState;this.oApi._fnCreateCookie=_fnCreateCookie;this.oApi._fnReadCookie=_fnReadCookie;this.oApi._fnGetUniqueThs=_fnGetUniqueThs;this.oApi._fnScrollBarWidth=_fnScrollBarWidth;this.oApi._fnApplyToChildren=_fnApplyToChildren;this.oApi._fnMap=_fnMap;var _that=this;return this.each(function()
{var i=0,iLen,j,jLen,k,kLen;for(i=0,iLen=_aoSettings.length;i<iLen;i++)
{if(_aoSettings[i].nTable==this)
{if(typeof oInit=='undefined'||(typeof oInit.bRetrieve!='undefined'&&oInit.bRetrieve===true))
{return _aoSettings[i].oInstance;}
else if(typeof oInit.bDestroy!='undefined'&&oInit.bDestroy===true)
{_aoSettings[i].oInstance.fnDestroy();break;}
else
{_fnLog(_aoSettings[i],0,"Cannot reinitialise DataTable.\n\n"+
"To retrieve the DataTables object for this table, please pass either no arguments "+
"to the dataTable() function, or set bRetrieve to true. Alternatively, to destory "+
"the old table and create a new one, set bDestroy to true (note that a lot of "+
"changes to the configuration can be made through the API which is usually much "+
"faster).");return;}}
if(_aoSettings[i].sTableId!==""&&_aoSettings[i].sTableId==this.getAttribute('id'))
{_aoSettings.splice(i,1);break;}}
var oSettings=new classSettings();_aoSettings.push(oSettings);var bInitHandedOff=false;var bUsePassedData=false;var sId=this.getAttribute('id');if(sId!==null)
{oSettings.sTableId=sId;oSettings.sInstance=sId;}
else
{oSettings.sInstance=_oExt._oExternConfig.iNextUnique++;}
if(this.nodeName.toLowerCase()!='table')
{_fnLog(oSettings,0,"Attempted to initialise DataTables on a node which is not a "+
"table: "+this.nodeName);return;}
oSettings.nTable=this;oSettings.oInstance=_that.length==1?_that:$(this).dataTable();oSettings.oApi=_that.oApi;oSettings.sDestroyWidth=$(this).width();if(typeof oInit!='undefined'&&oInit!==null)
{oSettings.oInit=oInit;_fnMap(oSettings.oFeatures,oInit,"bPaginate");_fnMap(oSettings.oFeatures,oInit,"bLengthChange");_fnMap(oSettings.oFeatures,oInit,"bFilter");_fnMap(oSettings.oFeatures,oInit,"bSort");_fnMap(oSettings.oFeatures,oInit,"bInfo");_fnMap(oSettings.oFeatures,oInit,"bProcessing");_fnMap(oSettings.oFeatures,oInit,"bAutoWidth");_fnMap(oSettings.oFeatures,oInit,"bSortClasses");_fnMap(oSettings.oFeatures,oInit,"bServerSide");_fnMap(oSettings.oScroll,oInit,"sScrollX","sX");_fnMap(oSettings.oScroll,oInit,"sScrollXInner","sXInner");_fnMap(oSettings.oScroll,oInit,"sScrollY","sY");_fnMap(oSettings.oScroll,oInit,"bScrollCollapse","bCollapse");_fnMap(oSettings.oScroll,oInit,"bScrollInfinite","bInfinite");_fnMap(oSettings.oScroll,oInit,"iScrollLoadGap","iLoadGap");_fnMap(oSettings.oScroll,oInit,"bScrollAutoCss","bAutoCss");_fnMap(oSettings,oInit,"asStripClasses");_fnMap(oSettings,oInit,"fnRowCallback");_fnMap(oSettings,oInit,"fnHeaderCallback");_fnMap(oSettings,oInit,"fnFooterCallback");_fnMap(oSettings,oInit,"fnCookieCallback");_fnMap(oSettings,oInit,"fnInitComplete");_fnMap(oSettings,oInit,"fnServerData");_fnMap(oSettings,oInit,"fnFormatNumber");_fnMap(oSettings,oInit,"aaSorting");_fnMap(oSettings,oInit,"aaSortingFixed");_fnMap(oSettings,oInit,"aLengthMenu");_fnMap(oSettings,oInit,"sPaginationType");_fnMap(oSettings,oInit,"sAjaxSource");_fnMap(oSettings,oInit,"iCookieDuration");_fnMap(oSettings,oInit,"sCookiePrefix");_fnMap(oSettings,oInit,"sDom");_fnMap(oSettings,oInit,"oSearch","oPreviousSearch");_fnMap(oSettings,oInit,"aoSearchCols","aoPreSearchCols");_fnMap(oSettings,oInit,"iDisplayLength","_iDisplayLength");_fnMap(oSettings,oInit,"bJQueryUI","bJUI");_fnMap(oSettings.oLanguage,oInit,"fnInfoCallback");if(typeof oInit.fnDrawCallback=='function')
{oSettings.aoDrawCallback.push({"fn":oInit.fnDrawCallback,"sName":"user"});}
if(typeof oInit.fnStateSaveCallback=='function')
{oSettings.aoStateSave.push({"fn":oInit.fnStateSaveCallback,"sName":"user"});}
if(typeof oInit.fnStateLoadCallback=='function')
{oSettings.aoStateLoad.push({"fn":oInit.fnStateLoadCallback,"sName":"user"});}
if(oSettings.oFeatures.bServerSide&&oSettings.oFeatures.bSort&&oSettings.oFeatures.bSortClasses)
{oSettings.aoDrawCallback.push({"fn":_fnSortingClasses,"sName":"server_side_sort_classes"});}
if(typeof oInit.bJQueryUI!='undefined'&&oInit.bJQueryUI)
{oSettings.oClasses=_oExt.oJUIClasses;if(typeof oInit.sDom=='undefined')
{oSettings.sDom='<"H"lfr>t<"F"ip>';}}
if(oSettings.oScroll.sX!==""||oSettings.oScroll.sY!=="")
{oSettings.oScroll.iBarWidth=_fnScrollBarWidth();}
if(typeof oInit.iDisplayStart!='undefined'&&typeof oSettings.iInitDisplayStart=='undefined')
{oSettings.iInitDisplayStart=oInit.iDisplayStart;oSettings._iDisplayStart=oInit.iDisplayStart;}
if(typeof oInit.bStateSave!='undefined')
{oSettings.oFeatures.bStateSave=oInit.bStateSave;_fnLoadState(oSettings,oInit);oSettings.aoDrawCallback.push({"fn":_fnSaveState,"sName":"state_save"});}
if(typeof oInit.aaData!='undefined')
{bUsePassedData=true;}
if(typeof oInit!='undefined'&&typeof oInit.aoData!='undefined')
{oInit.aoColumns=oInit.aoData;}
if(typeof oInit.oLanguage!='undefined')
{if(typeof oInit.oLanguage.sUrl!='undefined'&&oInit.oLanguage.sUrl!=="")
{oSettings.oLanguage.sUrl=oInit.oLanguage.sUrl;$.getJSON(oSettings.oLanguage.sUrl,null,function(json){_fnLanguageProcess(oSettings,json,true);});bInitHandedOff=true;}
else
{_fnLanguageProcess(oSettings,oInit.oLanguage,false);}}
}
else
{oInit={};}
if(typeof oInit.asStripClasses=='undefined')
{oSettings.asStripClasses.push(oSettings.oClasses.sStripOdd);oSettings.asStripClasses.push(oSettings.oClasses.sStripEven);}
var bStripeRemove=false;var anRows=$('>tbody>tr',this);for(i=0,iLen=oSettings.asStripClasses.length;i<iLen;i++)
{if(anRows.filter(":lt(2)").hasClass(oSettings.asStripClasses[i]))
{bStripeRemove=true;break;}}
if(bStripeRemove)
{oSettings.asDestoryStrips=['',''];if($(anRows[0]).hasClass(oSettings.oClasses.sStripOdd))
{oSettings.asDestoryStrips[0]+=oSettings.oClasses.sStripOdd+" ";}
if($(anRows[0]).hasClass(oSettings.oClasses.sStripEven))
{oSettings.asDestoryStrips[0]+=oSettings.oClasses.sStripEven;}
if($(anRows[1]).hasClass(oSettings.oClasses.sStripOdd))
{oSettings.asDestoryStrips[1]+=oSettings.oClasses.sStripOdd+" ";}
if($(anRows[1]).hasClass(oSettings.oClasses.sStripEven))
{oSettings.asDestoryStrips[1]+=oSettings.oClasses.sStripEven;}
anRows.removeClass(oSettings.asStripClasses.join(' '));}
var nThead=this.getElementsByTagName('thead');var anThs=nThead.length===0?[]:_fnGetUniqueThs(nThead[0]);var aoColumnsInit;if(typeof oInit.aoColumns=='undefined')
{aoColumnsInit=[];for(i=0,iLen=anThs.length;i<iLen;i++)
{aoColumnsInit.push(null);}}
else
{aoColumnsInit=oInit.aoColumns;}
for(i=0,iLen=aoColumnsInit.length;i<iLen;i++)
{if(typeof oInit.saved_aoColumns!='undefined'&&oInit.saved_aoColumns.length==iLen)
{if(aoColumnsInit[i]===null)
{aoColumnsInit[i]={};}
aoColumnsInit[i].bVisible=oInit.saved_aoColumns[i].bVisible;}
_fnAddColumn(oSettings,anThs?anThs[i]:null);}
if(typeof oInit.aoColumnDefs!='undefined')
{for(i=oInit.aoColumnDefs.length-1;i>=0;i--)
{var aTargets=oInit.aoColumnDefs[i].aTargets;if(!$.isArray(aTargets))
{_fnLog(oSettings,1,'aTargets must be an array of targets, not a '+(typeof aTargets));}
for(j=0,jLen=aTargets.length;j<jLen;j++)
{if(typeof aTargets[j]=='number'&&aTargets[j]>=0)
{while(oSettings.aoColumns.length<=aTargets[j])
{_fnAddColumn(oSettings);}
_fnColumnOptions(oSettings,aTargets[j],oInit.aoColumnDefs[i]);}
else if(typeof aTargets[j]=='number'&&aTargets[j]<0)
{_fnColumnOptions(oSettings,oSettings.aoColumns.length+aTargets[j],oInit.aoColumnDefs[i]);}
else if(typeof aTargets[j]=='string')
{for(k=0,kLen=oSettings.aoColumns.length;k<kLen;k++)
{if(aTargets[j]=="_all"||oSettings.aoColumns[k].nTh.className.indexOf(aTargets[j])!=-1)
{_fnColumnOptions(oSettings,k,oInit.aoColumnDefs[i]);}}}}}}
if(typeof aoColumnsInit!='undefined')
{for(i=0,iLen=aoColumnsInit.length;i<iLen;i++)
{_fnColumnOptions(oSettings,i,aoColumnsInit[i]);}}
for(i=0,iLen=oSettings.aaSorting.length;i<iLen;i++)
{if(oSettings.aaSorting[i][0]>=oSettings.aoColumns.length)
{oSettings.aaSorting[i][0]=0;}
var oColumn=oSettings.aoColumns[oSettings.aaSorting[i][0]];if(typeof oSettings.aaSorting[i][2]=='undefined')
{oSettings.aaSorting[i][2]=0;}
if(typeof oInit.aaSorting=="undefined"&&typeof oSettings.saved_aaSorting=="undefined")
{oSettings.aaSorting[i][1]=oColumn.asSorting[0];}
for(j=0,jLen=oColumn.asSorting.length;j<jLen;j++)
{if(oSettings.aaSorting[i][1]==oColumn.asSorting[j])
{oSettings.aaSorting[i][2]=j;break;}}}
_fnSortingClasses(oSettings);if(this.getElementsByTagName('thead').length===0)
{this.appendChild(document.createElement('thead'));}
if(this.getElementsByTagName('tbody').length===0)
{this.appendChild(document.createElement('tbody'));}
oSettings.nTHead=this.getElementsByTagName('thead')[0];oSettings.nTBody=this.getElementsByTagName('tbody')[0];if(this.getElementsByTagName('tfoot').length>0)
{oSettings.nTFoot=this.getElementsByTagName('tfoot')[0];}
if(bUsePassedData)
{for(i=0;i<oInit.aaData.length;i++)
{_fnAddData(oSettings,oInit.aaData[i]);}}
else
{_fnGatherData(oSettings);}
oSettings.aiDisplay=oSettings.aiDisplayMaster.slice();oSettings.bInitialised=true;if(bInitHandedOff===false)
{_fnInitalise(oSettings);}});};})(jQuery,window,document);;(function($){var helper={},current,title,tID,IE=$.browser.msie&&/MSIE\s(5\.5|6\.)/.test(navigator.userAgent),track=false;$.tooltip={blocked:false,defaults:{delay:200,fade:false,showURL:true,extraClass:"",top:15,left:15,id:"tooltip"},block:function(){$.tooltip.blocked=!$.tooltip.blocked;}};$.fn.extend({tooltip:function(settings){settings=$.extend({},$.tooltip.defaults,settings);createHelper(settings);return this.each(function(){$.data(this,"tooltip",settings);this.tOpacity=helper.parent.css("opacity");this.tooltipText=this.title;$(this).removeAttr("title");this.alt="";}).mouseover(save).mouseout(hide).click(hide);},fixPNG:IE?function(){return this.each(function(){var image=$(this).css('backgroundImage');if(image.match(/^url\(["']?(.*\.png)["']?\)$/i)){image=RegExp.$1;$(this).css({'backgroundImage':'none','filter':"progid:DXImageTransform.Microsoft.AlphaImageLoader(enabled=true, sizingMethod=crop, src='"+image+"')"}).each(function(){var position=$(this).css('position');if(position!='absolute'&&position!='relative')$(this).css('position','relative');});}});}:function(){return this;},unfixPNG:IE?function(){return this.each(function(){$(this).css({'filter':'',backgroundImage:''});});}:function(){return this;},hideWhenEmpty:function(){return this.each(function(){$(this)[$(this).html()?"show":"hide"]();});},url:function(){return this.attr('href')||this.attr('src');}});function createHelper(settings){if(helper.parent)return;helper.parent=$('<div id="'+settings.id+'"><h3></h3><div class="body"></div><div class="url"></div></div>').appendTo(document.body).hide();if($.fn.bgiframe)helper.parent.bgiframe();helper.title=$('h3',helper.parent);helper.body=$('div.body',helper.parent);helper.url=$('div.url',helper.parent);}function settings(element){return $.data(element,"tooltip");}function handle(event){if(settings(this).delay)tID=setTimeout(show,settings(this).delay);else
show();track=!!settings(this).track;$(document.body).bind('mousemove',update);update(event);}function save(){if($.tooltip.blocked||this==current||(!this.tooltipText&&!settings(this).bodyHandler))return;current=this;title=this.tooltipText;if(settings(this).bodyHandler){helper.title.hide();var bodyContent=settings(this).bodyHandler.call(this);if(bodyContent.nodeType||bodyContent.jquery){helper.body.empty().append(bodyContent)}else{helper.body.html(bodyContent);}helper.body.show();}else if(settings(this).showBody){var parts=title.split(settings(this).showBody);helper.title.html(parts.shift()).show();helper.body.empty();for(var i=0,part;(part=parts[i]);i++){if(i>0)helper.body.append("<br/>");helper.body.append(part);}helper.body.hideWhenEmpty();}else{helper.title.html(title).show();helper.body.hide();}if(settings(this).showURL&&$(this).url())helper.url.html($(this).url().replace('http://','')).show();else
helper.url.hide();helper.parent.addClass(settings(this).extraClass);if(settings(this).fixPNG)helper.parent.fixPNG();handle.apply(this,arguments);}function show(){tID=null;if((!IE||!$.fn.bgiframe)&&settings(current).fade){if(helper.parent.is(":animated"))helper.parent.stop().show().fadeTo(settings(current).fade,current.tOpacity);else
helper.parent.is(':visible')?helper.parent.fadeTo(settings(current).fade,current.tOpacity):helper.parent.fadeIn(settings(current).fade);}else{helper.parent.show();}update();}function update(event){if($.tooltip.blocked)return;if(event&&event.target.tagName=="OPTION"){return;}if(!track&&helper.parent.is(":visible")){$(document.body).unbind('mousemove',update)}if(current==null){$(document.body).unbind('mousemove',update);return;}helper.parent.removeClass("viewport-right").removeClass("viewport-bottom");var left=helper.parent[0].offsetLeft;var top=helper.parent[0].offsetTop;if(event){left=event.pageX+settings(current).left;top=event.pageY+settings(current).top;var right='auto';if(settings(current).positionLeft){right=$(window).width()-left;left='auto';}helper.parent.css({left:left,right:right,top:top});}var v=viewport(),h=helper.parent[0];if(v.x+v.cx<h.offsetLeft+h.offsetWidth){left-=h.offsetWidth+20+settings(current).left;helper.parent.css({left:left+'px'}).addClass("viewport-right");}if(v.y+v.cy<h.offsetTop+h.offsetHeight){top-=h.offsetHeight+20+settings(current).top;helper.parent.css({top:top+'px'}).addClass("viewport-bottom");}}function viewport(){return{x:$(window).scrollLeft(),y:$(window).scrollTop(),cx:$(window).width(),cy:$(window).height()};}function hide(event){if($.tooltip.blocked)return;if(tID)clearTimeout(tID);current=null;var tsettings=settings(this);function complete(){helper.parent.removeClass(tsettings.extraClass).hide().css("opacity","");}if((!IE||!$.fn.bgiframe)&&tsettings.fade){if(helper.parent.is(':animated'))helper.parent.stop().fadeTo(tsettings.fade,0,complete);else
helper.parent.stop().fadeOut(tsettings.fade,complete);}else
complete();if(settings(this).fixPNG)helper.parent.unfixPNG();}})(jQuery);ancla="";function crearAncla(id,strAncla){if(!$("#"+strAncla)){new Insertion.Before(id,"<a id="+strAncla+" name="+strAncla+"></a>");}
ancla="#"+strAncla;}
function delay(funcion,segundos){setTimeout(funcion,segundos*1000);}
function fancybox(id){$('#'+id).fancybox();}
function crearForm(url,params){var arrayParam=params.split("&");var formu=$("#formulario");var inputs="";for(var i=0;i<arrayParam.length;i++){var nombre=arrayParam[i].split("=")[0];var valor=arrayParam[i].split("=")[1];inputs=inputs+"<input type='hidden' name="+nombre+" value="+valor+"><br>";}
inputs=inputs+"<input type='hidden' name='token' value="+token+"><br>";formu.html("<form id='miForm' action="+url+" method='post'>"+inputs+"</form>");$("#miForm")[0].submit();}
function zebra(classObj){$("."+classObj+" tr:gt(0):odd").addClass("impar");$("."+classObj+" tr:gt(0):even").addClass("par");}
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
function disableComponent(id){$('#'+id).attr('disabled',true);}function startOverlay(){$('#ajax-indicator').modal({close:false,containerCss:{backgroundColor:"#fff",height:50,padding:0,width:190,opacity:50,},});return(true);}
function closeModal(){$.modal.close();}
function _Init(options){if(options.showStatusIn!=''){$('#'+options.showStatusIn).addClass('cargando');}else{if(options.showOverlay){startOverlay();}else{_ShowState(options);}}}
function _AddDiv(){var contenedor=$('#state')[0];if(contenedor==null){$('body').append("<div id='state' class='loading' style='position:absolute'>&nbsp;</div>");$('#state').css('top','0px');$('#state').css('left','0px');}}
function _ShowState(options){_AddDiv();$('#state').centerObject(options);$('#state').show();};function _HiddeState(options){if(options.showStatusIn!=''){$('#'+options.showStatusIn).show();$('#'+options.showStatusIn).removeClass('cargando');}else{$('#state').ajaxStop($('#state').hide());}
if(options.showOverlay){$(document).ajaxStop(closeModal());}};jQuery.fn.centerObject=function(options){var obj=this;var total=0;var dif=0;if($(window).scrollTop()==0){obj.css('top',$(window).height()/2-this.height()/2);}else{total=$(window).height()+$(window).scrollTop();dif=total-$(window).height();obj.css('top',dif+($(window).height())/2);}
obj.css('left',$(window).width()/2-this.width()/2);if(options){if((options.debug)&&(window.console)){window.console.log("centerObject => \n"+
"Total Vertical: "+total+"\n"+
"Dif: "+dif+"\n"+
"Medio: "+(dif+($(window).height())/2)+
"\n"+
"Total Horizontal: "+$(window).width()+"\n"+
"Medio: "+$(window).width()/2);}}}
function AjaxHelper(fncUpdateInfo,fncInit){this.ini='';this.funcion='';this.url='';this.orden='';this.debug=false;this.debugJSON=false;this.onComplete=fncUpdateInfo;this.onBeforeSend=fncInit;this.showState=true;this.cache=false;this.showStatusIn='';this.showOverlay=false;this.autoClose=true;this.sendToServer=function(){this.ajaxCallback(this);}
this.sort=function(ord){this.log("AjaxHelper => sort: "+ord);this.orden=ord;this.sendToServer();}
this.changePage=function(ini){this.log("AjaxHelper => changePage: "+ini);this.ini=ini;this.sendToServer();}
this.log=function(str){if((this.debug)&&(window.console)){window.console.log(str);}}
this.ajaxCallback=function(helper){if(this.debugJSON){JSONstring.debug=true;}
helper.token=token;var params="obj="+JSONstring.make(helper);this.log("AjaxHelper => ajaxCallback \n"+params);this.log("AjaxHelper => token: "+helper.token);var _hash_key;if(this.cache){_hash_key=b64_md5(params);this.log("AjaxHelper => cache element");this.log("AjaxHelper => cache hash_key "+_hash_key);if($.jCache.hasItem(_hash_key)){return helper.onComplete($.jCache.getItem(_hash_key));}}
$.ajax({type:"POST",url:helper.url,data:params,beforeSend:function(){if(helper.showState){_Init({debug:helper.debug,showStatusIn:helper.showStatusIn,showOverlay:helper.showOverlay});}
if(helper.onBeforeSend){helper.onBeforeSend();}},complete:function(ajax){_HiddeState({showStatusIn:helper.showStatusIn,showOverlay:helper.showOverlay});if(helper.onComplete){if(ajax.responseText=='CLIENT_REDIRECT'){window.location=URL_PREFIX+"/redirectController.pl";}else{if(helper.cache){$.jCache.setItem(_hash_key,ajax.responseText);}
helper.onComplete(ajax.responseText);}}}});}}function clearMessages(){$('#mensajes').css({opacity:0,"filter":"alpha(opacity=0)"});$('#mensajes').hide();$('#mensajes').html('');}
function verificarRespuesta(responseText){if(responseText==0){jAlert(DATOS_ENVIADOS_INCORRECTOS,'Info','errboxid');return(0);}else{return(1);}}
function setMessages(Messages_hashref){//@params
try{_createContentMessages();var i;for(i=0;i<Messages_hashref.messages.length;i++){$('#mensajes').append('<div class="message_text" >'+Messages_hashref.messages[i].message+'</div>');}
$('#mensajes').css("display","block");_show();scrollTo('mensajes');_delay(clearMessages,180);}
catch(e){}}
function assignCloseButton(){$('#close_message').click(function()
{$('#mensajes').animate({opacity:0},"slow");clearMessages();});}
function _createContentMessages(){var contenedor=$('#mensajes')[0];if(contenedor==null){$('#end_top').append("<div class='mensajes_informacion'><div id='mensajes'><img id='close_message' style='float:right;cursor:pointer' src="+imagesForJS+'/iconos/12-em-cross.png'+" /></div></div>");}
else{clearMessages();$('#mensajes').append("<img id='close_message' style='float:right;cursor:pointer' src='"+imagesForJS+'/iconos/12-em-cross.png'+" />");}
_show();assignCloseButton();}
function _show(){$('#mensajes').animate({opacity:90,"filter":"alpha(opacity=90)"},"fast");}
function _delay(funcion,segundos){setTimeout(funcion,segundos*1000);}
function hayError(msg){if(msg.error==1)
return(true);return(false);}function _WinInit(objWin){_WinAddDiv(objWin);}
function _WinAddDiv(objWin){var contenedor=$('#ventana')[0];var opciones={};var d_height=document.height;var d_width=document.width;var dimmer={height:d_height,width:d_width};if((contenedor==null)&&(objWin.dimmer_On==true)){$('body').append("<div id='dimmer' class='dimmer' style='height:"+dimmer.height+"px; width: "+dimmer.width+"px;top: 0px; visibility: visible; position:absolute'></div>");}
$('body').append("<div id='ventana' class='dimming' style='display:none; height:85%; width:85%; top:10px;'><div class='winHeader'><img align='right' id='cerrar' src='"+imagesForJS+'/cerrar.png'+"'/><span width=100px>"+objWin.titulo+"</span></div><div id='ventanaContenido' class='ventanaContenido' style='height:90%; width:100%; top:10px;'></div></div>");$('#ventanaContenido').html(objWin.html);if(objWin.opacity==true){opciones.opacity='0.7777';}
if(objWin.draggable==true){$('#ventana').draggable(opciones);}else{$('#ventana').draggable('disable');}
$('#cerrar').click(function(){objWin.close()});objWin.log();}
jQuery.fn.centerObject=function(options){var obj=this;var total=0;var dif=0;if($(window).scrollTop()==0){obj.css('top',$(window).height()/2-this.height()/2);}else{total=$(window).height()+$(window).scrollTop();dif=total-$(window).height();obj.css('top',dif+($(window).height())/2);}
obj.css('left',$(window).width()/2-this.width()/2);if(options){if((options.debug)&&(window.console)){console.log("centerObject => \n"+
"Total Vertical: "+total+"\n"+
"Dif: "+dif+"\n"+
"Medio: "+(dif+($(window).height())/2)+
"\n"+
"Total Horizontal: "+$(window).width()+"\n"+
"Medio: "+$(window).width()/2);}}}
function WindowHelper(options){this.debug=false;this.titulo='';this.html='';this.dimmer='';this.dimmer_On=true;this.showState=true;this.draggable=true;this.focus='';if(options.draggable==false){this.draggable=options.draggable;}
this.opacity=true;if(options.opacity==false){this.opacity=options.opacity;}
this.auto_focus=function(){if(this.focus!=''){$('#'+this.focus).focus();}}
this.close=function(){$('#ventana').hide();$('#dimmer').hide();}
this.height=function(height){$('#ventana').height(height);}
this.width=function(width){$('#ventana').width(width);}
this.create=function(){_WinInit(this);}
this.open=function(){$('#ventana').centerObject();$('#ventana').show();this.auto_focus();if(this.dimmer_On==true){$('#dimmer').show();}}
this.log=function(){if((this.debug)&&(window.console)){console.log(" 	WindowHelper => create() "+"\n"+
"opacity: "+this.opacity+"\n"+
"draggable: "+this.draggable+"\n"+
"width: "+$(window).width()+"\n"+
"height: "+$(window).height()+"\n");}}}function _getId(IdObj,id){$('#'+IdObj).val(id);}
function _CrearAutocomplete(options){if(!(options.IdInput)||!(options.IdInputHidden)){alert("AutocompleteHelper=> _CrearAutocomplete=> Error en parametros");return 0;}
url=URL_PREFIX+"/autocompletablesDB.pl?accion="+options.accion+"&token="+token;$("#"+options.IdInput).search();$("#"+options.IdInput).autocomplete(url,{formatItem:function(row){return row[1];},minChars:3,matchSubset:1,matchContains:1,maxItemsToShow:M_LIMITE_RESULTADOS,cacheLength:M_LIMITE_RESULTADOS,selectOnly:1,});$("#"+options.IdInput).result(function(event,data,formatted){$("#"+options.IdInput).val(data[1]);_getId(options.IdInputHidden,data[0]);if(options.callBackFunction){options.callBackFunction();}});}
function _CrearAutocompleteTextArea(options){if(!(options.IdInput)){alert("AutocompleteHelper=> _CrearAutocomplete=> Error en parametros");return 0;}
url=URL_PREFIX+"/autocompletablesDB.pl?accion="+options.accion+"&token="+token;$("#"+options.IdInput).search();$("#"+options.IdInput).autocomplete(url,{formatItem:function(row){return row[1];},minChars:3,matchSubset:1,matchContains:1,maxItemsToShow:10,cacheLength:50,selectOnly:1,multiple:true,matchContains:true,formatItem:formatItem,formatResult:formatResult,multipleSeparator:"\n",});$("#"+options.IdInput).result(function(event,data,formatted){if(options.IdInputHidden){_getId(options.IdInputHidden,data[0]);}
if(options.callBackFunction){options.callBackFunction();}});}
function CrearAutocompleteMonedas(options){_CrearAutocomplete({IdInput:options.IdInput,IdInputHidden:options.IdInputHidden,accion:'autocomplete_monedas',callBackFunction:options.callBackFunction,});}
function CrearAutocompleteCiudades(options){_CrearAutocomplete({IdInput:options.IdInput,IdInputHidden:options.IdInputHidden,accion:'autocomplete_ciudades',callBackFunction:options.callBackFunction,});}
function CrearAutocompletePaises(options){_CrearAutocomplete({IdInput:options.IdInput,IdInputHidden:options.IdInputHidden,accion:'autocomplete_paises',callBackFunction:options.callBackFunction,});}
function CrearAutocompleteLenguajes(options){_CrearAutocomplete({IdInput:options.IdInput,IdInputHidden:options.IdInputHidden,accion:'autocomplete_lenguajes',callBackFunction:options.callBackFunction,});}
function CrearAutocompleteAutores(options){_CrearAutocomplete({IdInput:options.IdInput,IdInputHidden:options.IdInputHidden,accion:'autocomplete_autores',callBackFunction:options.callBackFunction,});}
function CrearAutocompleteSoportes(options){_CrearAutocomplete({IdInput:options.IdInput,IdInputHidden:options.IdInputHidden,accion:'autocomplete_soportes',callBackFunction:options.callBackFunction,});}
function CrearAutocompleteUsuarios(options){_CrearAutocomplete({IdInput:options.IdInput,IdInputHidden:options.IdInputHidden,accion:'autocomplete_usuarios',callBackFunction:options.callBackFunction,});}
function CrearAutocompleteUsuariosConRegularidad(options){_CrearAutocomplete({IdInput:options.IdInput,IdInputHidden:options.IdInputHidden,accion:'autocomplete_usuarios_con_regularidad',callBackFunction:options.callBackFunction,});}
function CrearAutocompleteBarcodes(options){_CrearAutocomplete({IdInput:options.IdInput,IdInputHidden:options.IdInputHidden,accion:'autocomplete_barcodes',callBackFunction:options.callBackFunction,});}
function CrearAutocompleteBarcodesPrestados(options){_CrearAutocomplete({IdInput:options.IdInput,IdInputHidden:options.IdInputHidden,accion:'autocomplete_barcodes_prestados',callBackFunction:options.callBackFunction,});}
function CrearAutocompleteTemas(options){_CrearAutocomplete({IdInput:options.IdInput,IdInputHidden:options.IdInputHidden,accion:'autocomplete_temas',callBackFunction:options.callBackFunction,});}
function CrearAutocompleteEditoriales(options){_CrearAutocomplete({IdInput:options.IdInput,IdInputHidden:options.IdInputHidden,accion:'autocomplete_editoriales',callBackFunction:options.callBackFunction,});}
function CrearAutocompleteAyudaMARC(options){_CrearAutocomplete({IdInput:options.IdInput,IdInputHidden:options.IdInputHidden,accion:'autocomplete_ayuda_marc',callBackFunction:options.callBackFunction,});}
function CrearAutocompleteUI(options){_CrearAutocomplete({IdInput:options.IdInput,IdInputHidden:options.IdInputHidden,accion:'autocomplete_UI',callBackFunction:options.callBackFunction,});}
function CrearAutocompleteCatalogo(options){_CrearAutocomplete({IdInput:options.IdInput,IdInputHidden:options.IdInputHidden,IdInputAutor:options.IdInputAutor,accion:'autocomplete_catalogo',callBackFunction:options.callBackFunction,});}
function CrearAutocompleteNivel2(options){_CrearAutocomplete({IdInput:options.IdInput,IdInputHidden:options.IdInputHidden,IdInputAutor:options.IdInputAutor,accion:'autocomplete_nivel2',callBackFunction:options.callBackFunction,});}var hexcase=0;var b64pad="";var chrsz=8;function hex_md5(s){return binl2hex(core_md5(str2binl(s),s.length*chrsz));}
function b64_md5(s){return binl2b64(core_md5(str2binl(s),s.length*chrsz));}
function str_md5(s){return binl2str(core_md5(str2binl(s),s.length*chrsz));}
function hex_hmac_md5(key,data){return binl2hex(core_hmac_md5(key,data));}
function b64_hmac_md5(key,data){return binl2b64(core_hmac_md5(key,data));}
function str_hmac_md5(key,data){return binl2str(core_hmac_md5(key,data));}
function md5_vm_test()
{return hex_md5("abc")=="900150983cd24fb0d6963f7d28e17f72";}
function core_md5(x,len)
{x[len>>5]|=0x80<<((len)%32);x[(((len+64)>>>9)<<4)+14]=len;var a=1732584193;var b=-271733879;var c=-1732584194;var d=271733878;for(var i=0;i<x.length;i+=16)
{var olda=a;var oldb=b;var oldc=c;var oldd=d;a=md5_ff(a,b,c,d,x[i+0],7,-680876936);d=md5_ff(d,a,b,c,x[i+1],12,-389564586);c=md5_ff(c,d,a,b,x[i+2],17,606105819);b=md5_ff(b,c,d,a,x[i+3],22,-1044525330);a=md5_ff(a,b,c,d,x[i+4],7,-176418897);d=md5_ff(d,a,b,c,x[i+5],12,1200080426);c=md5_ff(c,d,a,b,x[i+6],17,-1473231341);b=md5_ff(b,c,d,a,x[i+7],22,-45705983);a=md5_ff(a,b,c,d,x[i+8],7,1770035416);d=md5_ff(d,a,b,c,x[i+9],12,-1958414417);c=md5_ff(c,d,a,b,x[i+10],17,-42063);b=md5_ff(b,c,d,a,x[i+11],22,-1990404162);a=md5_ff(a,b,c,d,x[i+12],7,1804603682);d=md5_ff(d,a,b,c,x[i+13],12,-40341101);c=md5_ff(c,d,a,b,x[i+14],17,-1502002290);b=md5_ff(b,c,d,a,x[i+15],22,1236535329);a=md5_gg(a,b,c,d,x[i+1],5,-165796510);d=md5_gg(d,a,b,c,x[i+6],9,-1069501632);c=md5_gg(c,d,a,b,x[i+11],14,643717713);b=md5_gg(b,c,d,a,x[i+0],20,-373897302);a=md5_gg(a,b,c,d,x[i+5],5,-701558691);d=md5_gg(d,a,b,c,x[i+10],9,38016083);c=md5_gg(c,d,a,b,x[i+15],14,-660478335);b=md5_gg(b,c,d,a,x[i+4],20,-405537848);a=md5_gg(a,b,c,d,x[i+9],5,568446438);d=md5_gg(d,a,b,c,x[i+14],9,-1019803690);c=md5_gg(c,d,a,b,x[i+3],14,-187363961);b=md5_gg(b,c,d,a,x[i+8],20,1163531501);a=md5_gg(a,b,c,d,x[i+13],5,-1444681467);d=md5_gg(d,a,b,c,x[i+2],9,-51403784);c=md5_gg(c,d,a,b,x[i+7],14,1735328473);b=md5_gg(b,c,d,a,x[i+12],20,-1926607734);a=md5_hh(a,b,c,d,x[i+5],4,-378558);d=md5_hh(d,a,b,c,x[i+8],11,-2022574463);c=md5_hh(c,d,a,b,x[i+11],16,1839030562);b=md5_hh(b,c,d,a,x[i+14],23,-35309556);a=md5_hh(a,b,c,d,x[i+1],4,-1530992060);d=md5_hh(d,a,b,c,x[i+4],11,1272893353);c=md5_hh(c,d,a,b,x[i+7],16,-155497632);b=md5_hh(b,c,d,a,x[i+10],23,-1094730640);a=md5_hh(a,b,c,d,x[i+13],4,681279174);d=md5_hh(d,a,b,c,x[i+0],11,-358537222);c=md5_hh(c,d,a,b,x[i+3],16,-722521979);b=md5_hh(b,c,d,a,x[i+6],23,76029189);a=md5_hh(a,b,c,d,x[i+9],4,-640364487);d=md5_hh(d,a,b,c,x[i+12],11,-421815835);c=md5_hh(c,d,a,b,x[i+15],16,530742520);b=md5_hh(b,c,d,a,x[i+2],23,-995338651);a=md5_ii(a,b,c,d,x[i+0],6,-198630844);d=md5_ii(d,a,b,c,x[i+7],10,1126891415);c=md5_ii(c,d,a,b,x[i+14],15,-1416354905);b=md5_ii(b,c,d,a,x[i+5],21,-57434055);a=md5_ii(a,b,c,d,x[i+12],6,1700485571);d=md5_ii(d,a,b,c,x[i+3],10,-1894986606);c=md5_ii(c,d,a,b,x[i+10],15,-1051523);b=md5_ii(b,c,d,a,x[i+1],21,-2054922799);a=md5_ii(a,b,c,d,x[i+8],6,1873313359);d=md5_ii(d,a,b,c,x[i+15],10,-30611744);c=md5_ii(c,d,a,b,x[i+6],15,-1560198380);b=md5_ii(b,c,d,a,x[i+13],21,1309151649);a=md5_ii(a,b,c,d,x[i+4],6,-145523070);d=md5_ii(d,a,b,c,x[i+11],10,-1120210379);c=md5_ii(c,d,a,b,x[i+2],15,718787259);b=md5_ii(b,c,d,a,x[i+9],21,-343485551);a=safe_add(a,olda);b=safe_add(b,oldb);c=safe_add(c,oldc);d=safe_add(d,oldd);}
return Array(a,b,c,d);}
function md5_cmn(q,a,b,x,s,t)
{return safe_add(bit_rol(safe_add(safe_add(a,q),safe_add(x,t)),s),b);}
function md5_ff(a,b,c,d,x,s,t)
{return md5_cmn((b&c)|((~b)&d),a,b,x,s,t);}
function md5_gg(a,b,c,d,x,s,t)
{return md5_cmn((b&d)|(c&(~d)),a,b,x,s,t);}
function md5_hh(a,b,c,d,x,s,t)
{return md5_cmn(b^c^d,a,b,x,s,t);}
function md5_ii(a,b,c,d,x,s,t)
{return md5_cmn(c^(b|(~d)),a,b,x,s,t);}
function core_hmac_md5(key,data)
{var bkey=str2binl(key);if(bkey.length>16)bkey=core_md5(bkey,key.length*chrsz);var ipad=Array(16),opad=Array(16);for(var i=0;i<16;i++)
{ipad[i]=bkey[i]^0x36363636;opad[i]=bkey[i]^0x5C5C5C5C;}
var hash=core_md5(ipad.concat(str2binl(data)),512+data.length*chrsz);return core_md5(opad.concat(hash),512+128);}
function safe_add(x,y)
{var lsw=(x&0xFFFF)+(y&0xFFFF);var msw=(x>>16)+(y>>16)+(lsw>>16);return(msw<<16)|(lsw&0xFFFF);}
function bit_rol(num,cnt)
{return(num<<cnt)|(num>>>(32-cnt));}
function str2binl(str)
{var bin=Array();var mask=(1<<chrsz)-1;for(var i=0;i<str.length*chrsz;i+=chrsz)
bin[i>>5]|=(str.charCodeAt(i/chrsz)&mask)<<(i%32);return bin;}
function binl2str(bin)
{var str="";var mask=(1<<chrsz)-1;for(var i=0;i<bin.length*32;i+=chrsz)
str+=String.fromCharCode((bin[i>>5]>>>(i%32))&mask);return str;}
function binl2hex(binarray)
{var hex_tab=hexcase?"0123456789ABCDEF":"0123456789abcdef";var str="";for(var i=0;i<binarray.length*4;i++)
{str+=hex_tab.charAt((binarray[i>>2]>>((i%4)*8+4))&0xF)+
hex_tab.charAt((binarray[i>>2]>>((i%4)*8))&0xF);}
return str;}
function binl2b64(binarray)
{var tab="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";var str="";for(var i=0;i<binarray.length*4;i+=3)
{var triplet=(((binarray[i>>2]>>8*(i%4))&0xFF)<<16)|(((binarray[i+1>>2]>>8*((i+1)%4))&0xFF)<<8)|((binarray[i+2>>2]>>8*((i+2)%4))&0xFF);for(var j=0;j<4;j++)
{if(i*8+j*6>binarray.length*32)str+=b64pad;else str+=tab.charAt((triplet>>6*(3-j))&0x3F);}}
return str;}