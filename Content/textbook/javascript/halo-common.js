/*!
 * jQuery JavaScript Library v1.4.2
 * http://jquery.com/
 *
 * Copyright 2010, John Resig
 * Dual licensed under the MIT or GPL Version 2 licenses.
 * http://jquery.org/license
 *
 * Includes Sizzle.js
 * http://sizzlejs.com/
 * Copyright 2010, The Dojo Foundation
 * Released under the MIT, BSD, and GPL Licenses.
 *
 * Date: Sat Feb 13 22:33:48 2010 -0500
 */
(function(A,w){function ma(){if(!c.isReady){try{s.documentElement.doScroll("left")}catch(a){setTimeout(ma,1);return}c.ready()}}function Qa(a,b){b.src?c.ajax({url:b.src,async:false,dataType:"script"}):c.globalEval(b.text||b.textContent||b.innerHTML||"");b.parentNode&&b.parentNode.removeChild(b)}function X(a,b,d,f,e,j){var i=a.length;if(typeof b==="object"){for(var o in b)X(a,o,b[o],f,e,d);return a}if(d!==w){f=!j&&f&&c.isFunction(d);for(o=0;o<i;o++)e(a[o],b,f?d.call(a[o],o,e(a[o],b)):d,j);return a}return i?
e(a[0],b):w}function J(){return(new Date).getTime()}function Y(){return false}function Z(){return true}function na(a,b,d){d[0].type=a;return c.event.handle.apply(b,d)}function oa(a){var b,d=[],f=[],e=arguments,j,i,o,k,n,r;i=c.data(this,"events");if(!(a.liveFired===this||!i||!i.live||a.button&&a.type==="click")){a.liveFired=this;var u=i.live.slice(0);for(k=0;k<u.length;k++){i=u[k];i.origType.replace(O,"")===a.type?f.push(i.selector):u.splice(k--,1)}j=c(a.target).closest(f,a.currentTarget);n=0;for(r=
j.length;n<r;n++)for(k=0;k<u.length;k++){i=u[k];if(j[n].selector===i.selector){o=j[n].elem;f=null;if(i.preType==="mouseenter"||i.preType==="mouseleave")f=c(a.relatedTarget).closest(i.selector)[0];if(!f||f!==o)d.push({elem:o,handleObj:i})}}n=0;for(r=d.length;n<r;n++){j=d[n];a.currentTarget=j.elem;a.data=j.handleObj.data;a.handleObj=j.handleObj;if(j.handleObj.origHandler.apply(j.elem,e)===false){b=false;break}}return b}}function pa(a,b){return"live."+(a&&a!=="*"?a+".":"")+b.replace(/\./g,"`").replace(/ /g,
"&")}function qa(a){return!a||!a.parentNode||a.parentNode.nodeType===11}function ra(a,b){var d=0;b.each(function(){if(this.nodeName===(a[d]&&a[d].nodeName)){var f=c.data(a[d++]),e=c.data(this,f);if(f=f&&f.events){delete e.handle;e.events={};for(var j in f)for(var i in f[j])c.event.add(this,j,f[j][i],f[j][i].data)}}})}function sa(a,b,d){var f,e,j;b=b&&b[0]?b[0].ownerDocument||b[0]:s;if(a.length===1&&typeof a[0]==="string"&&a[0].length<512&&b===s&&!ta.test(a[0])&&(c.support.checkClone||!ua.test(a[0]))){e=
true;if(j=c.fragments[a[0]])if(j!==1)f=j}if(!f){f=b.createDocumentFragment();c.clean(a,b,f,d)}if(e)c.fragments[a[0]]=j?f:1;return{fragment:f,cacheable:e}}function K(a,b){var d={};c.each(va.concat.apply([],va.slice(0,b)),function(){d[this]=a});return d}function wa(a){return"scrollTo"in a&&a.document?a:a.nodeType===9?a.defaultView||a.parentWindow:false}var c=function(a,b){return new c.fn.init(a,b)},Ra=A.jQuery,Sa=A.$,s=A.document,T,Ta=/^[^<]*(<[\w\W]+>)[^>]*$|^#([\w-]+)$/,Ua=/^.[^:#\[\.,]*$/,Va=/\S/,
Wa=/^(\s|\u00A0)+|(\s|\u00A0)+$/g,Xa=/^<(\w+)\s*\/?>(?:<\/\1>)?$/,P=navigator.userAgent,xa=false,Q=[],L,$=Object.prototype.toString,aa=Object.prototype.hasOwnProperty,ba=Array.prototype.push,R=Array.prototype.slice,ya=Array.prototype.indexOf;c.fn=c.prototype={init:function(a,b){var d,f;if(!a)return this;if(a.nodeType){this.context=this[0]=a;this.length=1;return this}if(a==="body"&&!b){this.context=s;this[0]=s.body;this.selector="body";this.length=1;return this}if(typeof a==="string")if((d=Ta.exec(a))&&
(d[1]||!b))if(d[1]){f=b?b.ownerDocument||b:s;if(a=Xa.exec(a))if(c.isPlainObject(b)){a=[s.createElement(a[1])];c.fn.attr.call(a,b,true)}else a=[f.createElement(a[1])];else{a=sa([d[1]],[f]);a=(a.cacheable?a.fragment.cloneNode(true):a.fragment).childNodes}return c.merge(this,a)}else{if(b=s.getElementById(d[2])){if(b.id!==d[2])return T.find(a);this.length=1;this[0]=b}this.context=s;this.selector=a;return this}else if(!b&&/^\w+$/.test(a)){this.selector=a;this.context=s;a=s.getElementsByTagName(a);return c.merge(this,
a)}else return!b||b.jquery?(b||T).find(a):c(b).find(a);else if(c.isFunction(a))return T.ready(a);if(a.selector!==w){this.selector=a.selector;this.context=a.context}return c.makeArray(a,this)},selector:"",jquery:"1.4.2",length:0,size:function(){return this.length},toArray:function(){return R.call(this,0)},get:function(a){return a==null?this.toArray():a<0?this.slice(a)[0]:this[a]},pushStack:function(a,b,d){var f=c();c.isArray(a)?ba.apply(f,a):c.merge(f,a);f.prevObject=this;f.context=this.context;if(b===
"find")f.selector=this.selector+(this.selector?" ":"")+d;else if(b)f.selector=this.selector+"."+b+"("+d+")";return f},each:function(a,b){return c.each(this,a,b)},ready:function(a){c.bindReady();if(c.isReady)a.call(s,c);else Q&&Q.push(a);return this},eq:function(a){return a===-1?this.slice(a):this.slice(a,+a+1)},first:function(){return this.eq(0)},last:function(){return this.eq(-1)},slice:function(){return this.pushStack(R.apply(this,arguments),"slice",R.call(arguments).join(","))},map:function(a){return this.pushStack(c.map(this,
function(b,d){return a.call(b,d,b)}))},end:function(){return this.prevObject||c(null)},push:ba,sort:[].sort,splice:[].splice};c.fn.init.prototype=c.fn;c.extend=c.fn.extend=function(){var a=arguments[0]||{},b=1,d=arguments.length,f=false,e,j,i,o;if(typeof a==="boolean"){f=a;a=arguments[1]||{};b=2}if(typeof a!=="object"&&!c.isFunction(a))a={};if(d===b){a=this;--b}for(;b<d;b++)if((e=arguments[b])!=null)for(j in e){i=a[j];o=e[j];if(a!==o)if(f&&o&&(c.isPlainObject(o)||c.isArray(o))){i=i&&(c.isPlainObject(i)||
c.isArray(i))?i:c.isArray(o)?[]:{};a[j]=c.extend(f,i,o)}else if(o!==w)a[j]=o}return a};c.extend({noConflict:function(a){A.$=Sa;if(a)A.jQuery=Ra;return c},isReady:false,ready:function(){if(!c.isReady){if(!s.body)return setTimeout(c.ready,13);c.isReady=true;if(Q){for(var a,b=0;a=Q[b++];)a.call(s,c);Q=null}c.fn.triggerHandler&&c(s).triggerHandler("ready")}},bindReady:function(){if(!xa){xa=true;if(s.readyState==="complete")return c.ready();if(s.addEventListener){s.addEventListener("DOMContentLoaded",
L,false);A.addEventListener("load",c.ready,false)}else if(s.attachEvent){s.attachEvent("onreadystatechange",L);A.attachEvent("onload",c.ready);var a=false;try{a=A.frameElement==null}catch(b){}s.documentElement.doScroll&&a&&ma()}}},isFunction:function(a){return $.call(a)==="[object Function]"},isArray:function(a){return $.call(a)==="[object Array]"},isPlainObject:function(a){if(!a||$.call(a)!=="[object Object]"||a.nodeType||a.setInterval)return false;if(a.constructor&&!aa.call(a,"constructor")&&!aa.call(a.constructor.prototype,
"isPrototypeOf"))return false;var b;for(b in a);return b===w||aa.call(a,b)},isEmptyObject:function(a){for(var b in a)return false;return true},error:function(a){throw a;},parseJSON:function(a){if(typeof a!=="string"||!a)return null;a=c.trim(a);if(/^[\],:{}\s]*$/.test(a.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g,"@").replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g,"]").replace(/(?:^|:|,)(?:\s*\[)+/g,"")))return A.JSON&&A.JSON.parse?A.JSON.parse(a):(new Function("return "+
a))();else c.error("Invalid JSON: "+a)},noop:function(){},globalEval:function(a){if(a&&Va.test(a)){var b=s.getElementsByTagName("head")[0]||s.documentElement,d=s.createElement("script");d.type="text/javascript";if(c.support.scriptEval)d.appendChild(s.createTextNode(a));else d.text=a;b.insertBefore(d,b.firstChild);b.removeChild(d)}},nodeName:function(a,b){return a.nodeName&&a.nodeName.toUpperCase()===b.toUpperCase()},each:function(a,b,d){var f,e=0,j=a.length,i=j===w||c.isFunction(a);if(d)if(i)for(f in a){if(b.apply(a[f],
d)===false)break}else for(;e<j;){if(b.apply(a[e++],d)===false)break}else if(i)for(f in a){if(b.call(a[f],f,a[f])===false)break}else for(d=a[0];e<j&&b.call(d,e,d)!==false;d=a[++e]);return a},trim:function(a){return(a||"").replace(Wa,"")},makeArray:function(a,b){b=b||[];if(a!=null)a.length==null||typeof a==="string"||c.isFunction(a)||typeof a!=="function"&&a.setInterval?ba.call(b,a):c.merge(b,a);return b},inArray:function(a,b){if(b.indexOf)return b.indexOf(a);for(var d=0,f=b.length;d<f;d++)if(b[d]===
a)return d;return-1},merge:function(a,b){var d=a.length,f=0;if(typeof b.length==="number")for(var e=b.length;f<e;f++)a[d++]=b[f];else for(;b[f]!==w;)a[d++]=b[f++];a.length=d;return a},grep:function(a,b,d){for(var f=[],e=0,j=a.length;e<j;e++)!d!==!b(a[e],e)&&f.push(a[e]);return f},map:function(a,b,d){for(var f=[],e,j=0,i=a.length;j<i;j++){e=b(a[j],j,d);if(e!=null)f[f.length]=e}return f.concat.apply([],f)},guid:1,proxy:function(a,b,d){if(arguments.length===2)if(typeof b==="string"){d=a;a=d[b];b=w}else if(b&&
!c.isFunction(b)){d=b;b=w}if(!b&&a)b=function(){return a.apply(d||this,arguments)};if(a)b.guid=a.guid=a.guid||b.guid||c.guid++;return b},uaMatch:function(a){a=a.toLowerCase();a=/(webkit)[ \/]([\w.]+)/.exec(a)||/(opera)(?:.*version)?[ \/]([\w.]+)/.exec(a)||/(msie) ([\w.]+)/.exec(a)||!/compatible/.test(a)&&/(mozilla)(?:.*? rv:([\w.]+))?/.exec(a)||[];return{browser:a[1]||"",version:a[2]||"0"}},browser:{}});P=c.uaMatch(P);if(P.browser){c.browser[P.browser]=true;c.browser.version=P.version}if(c.browser.webkit)c.browser.safari=
true;if(ya)c.inArray=function(a,b){return ya.call(b,a)};T=c(s);if(s.addEventListener)L=function(){s.removeEventListener("DOMContentLoaded",L,false);c.ready()};else if(s.attachEvent)L=function(){if(s.readyState==="complete"){s.detachEvent("onreadystatechange",L);c.ready()}};(function(){c.support={};var a=s.documentElement,b=s.createElement("script"),d=s.createElement("div"),f="script"+J();d.style.display="none";d.innerHTML="   <link/><table></table><a href='/a' style='color:red;float:left;opacity:.55;'>a</a><input type='checkbox'/>";
var e=d.getElementsByTagName("*"),j=d.getElementsByTagName("a")[0];if(!(!e||!e.length||!j)){c.support={leadingWhitespace:d.firstChild.nodeType===3,tbody:!d.getElementsByTagName("tbody").length,htmlSerialize:!!d.getElementsByTagName("link").length,style:/red/.test(j.getAttribute("style")),hrefNormalized:j.getAttribute("href")==="/a",opacity:/^0.55$/.test(j.style.opacity),cssFloat:!!j.style.cssFloat,checkOn:d.getElementsByTagName("input")[0].value==="on",optSelected:s.createElement("select").appendChild(s.createElement("option")).selected,
parentNode:d.removeChild(d.appendChild(s.createElement("div"))).parentNode===null,deleteExpando:true,checkClone:false,scriptEval:false,noCloneEvent:true,boxModel:null};b.type="text/javascript";try{b.appendChild(s.createTextNode("window."+f+"=1;"))}catch(i){}a.insertBefore(b,a.firstChild);if(A[f]){c.support.scriptEval=true;delete A[f]}try{delete b.test}catch(o){c.support.deleteExpando=false}a.removeChild(b);if(d.attachEvent&&d.fireEvent){d.attachEvent("onclick",function k(){c.support.noCloneEvent=
false;d.detachEvent("onclick",k)});d.cloneNode(true).fireEvent("onclick")}d=s.createElement("div");d.innerHTML="<input type='radio' name='radiotest' checked='checked'/>";a=s.createDocumentFragment();a.appendChild(d.firstChild);c.support.checkClone=a.cloneNode(true).cloneNode(true).lastChild.checked;c(function(){var k=s.createElement("div");k.style.width=k.style.paddingLeft="1px";s.body.appendChild(k);c.boxModel=c.support.boxModel=k.offsetWidth===2;s.body.removeChild(k).style.display="none"});a=function(k){var n=
s.createElement("div");k="on"+k;var r=k in n;if(!r){n.setAttribute(k,"return;");r=typeof n[k]==="function"}return r};c.support.submitBubbles=a("submit");c.support.changeBubbles=a("change");a=b=d=e=j=null}})();c.props={"for":"htmlFor","class":"className",readonly:"readOnly",maxlength:"maxLength",cellspacing:"cellSpacing",rowspan:"rowSpan",colspan:"colSpan",tabindex:"tabIndex",usemap:"useMap",frameborder:"frameBorder"};var G="jQuery"+J(),Ya=0,za={};c.extend({cache:{},expando:G,noData:{embed:true,object:true,
applet:true},data:function(a,b,d){if(!(a.nodeName&&c.noData[a.nodeName.toLowerCase()])){a=a==A?za:a;var f=a[G],e=c.cache;if(!f&&typeof b==="string"&&d===w)return null;f||(f=++Ya);if(typeof b==="object"){a[G]=f;e[f]=c.extend(true,{},b)}else if(!e[f]){a[G]=f;e[f]={}}a=e[f];if(d!==w)a[b]=d;return typeof b==="string"?a[b]:a}},removeData:function(a,b){if(!(a.nodeName&&c.noData[a.nodeName.toLowerCase()])){a=a==A?za:a;var d=a[G],f=c.cache,e=f[d];if(b){if(e){delete e[b];c.isEmptyObject(e)&&c.removeData(a)}}else{if(c.support.deleteExpando)delete a[c.expando];
else a.removeAttribute&&a.removeAttribute(c.expando);delete f[d]}}}});c.fn.extend({data:function(a,b){if(typeof a==="undefined"&&this.length)return c.data(this[0]);else if(typeof a==="object")return this.each(function(){c.data(this,a)});var d=a.split(".");d[1]=d[1]?"."+d[1]:"";if(b===w){var f=this.triggerHandler("getData"+d[1]+"!",[d[0]]);if(f===w&&this.length)f=c.data(this[0],a);return f===w&&d[1]?this.data(d[0]):f}else return this.trigger("setData"+d[1]+"!",[d[0],b]).each(function(){c.data(this,
a,b)})},removeData:function(a){return this.each(function(){c.removeData(this,a)})}});c.extend({queue:function(a,b,d){if(a){b=(b||"fx")+"queue";var f=c.data(a,b);if(!d)return f||[];if(!f||c.isArray(d))f=c.data(a,b,c.makeArray(d));else f.push(d);return f}},dequeue:function(a,b){b=b||"fx";var d=c.queue(a,b),f=d.shift();if(f==="inprogress")f=d.shift();if(f){b==="fx"&&d.unshift("inprogress");f.call(a,function(){c.dequeue(a,b)})}}});c.fn.extend({queue:function(a,b){if(typeof a!=="string"){b=a;a="fx"}if(b===
w)return c.queue(this[0],a);return this.each(function(){var d=c.queue(this,a,b);a==="fx"&&d[0]!=="inprogress"&&c.dequeue(this,a)})},dequeue:function(a){return this.each(function(){c.dequeue(this,a)})},delay:function(a,b){a=c.fx?c.fx.speeds[a]||a:a;b=b||"fx";return this.queue(b,function(){var d=this;setTimeout(function(){c.dequeue(d,b)},a)})},clearQueue:function(a){return this.queue(a||"fx",[])}});var Aa=/[\n\t]/g,ca=/\s+/,Za=/\r/g,$a=/href|src|style/,ab=/(button|input)/i,bb=/(button|input|object|select|textarea)/i,
cb=/^(a|area)$/i,Ba=/radio|checkbox/;c.fn.extend({attr:function(a,b){return X(this,a,b,true,c.attr)},removeAttr:function(a){return this.each(function(){c.attr(this,a,"");this.nodeType===1&&this.removeAttribute(a)})},addClass:function(a){if(c.isFunction(a))return this.each(function(n){var r=c(this);r.addClass(a.call(this,n,r.attr("class")))});if(a&&typeof a==="string")for(var b=(a||"").split(ca),d=0,f=this.length;d<f;d++){var e=this[d];if(e.nodeType===1)if(e.className){for(var j=" "+e.className+" ",
i=e.className,o=0,k=b.length;o<k;o++)if(j.indexOf(" "+b[o]+" ")<0)i+=" "+b[o];e.className=c.trim(i)}else e.className=a}return this},removeClass:function(a){if(c.isFunction(a))return this.each(function(k){var n=c(this);n.removeClass(a.call(this,k,n.attr("class")))});if(a&&typeof a==="string"||a===w)for(var b=(a||"").split(ca),d=0,f=this.length;d<f;d++){var e=this[d];if(e.nodeType===1&&e.className)if(a){for(var j=(" "+e.className+" ").replace(Aa," "),i=0,o=b.length;i<o;i++)j=j.replace(" "+b[i]+" ",
" ");e.className=c.trim(j)}else e.className=""}return this},toggleClass:function(a,b){var d=typeof a,f=typeof b==="boolean";if(c.isFunction(a))return this.each(function(e){var j=c(this);j.toggleClass(a.call(this,e,j.attr("class"),b),b)});return this.each(function(){if(d==="string")for(var e,j=0,i=c(this),o=b,k=a.split(ca);e=k[j++];){o=f?o:!i.hasClass(e);i[o?"addClass":"removeClass"](e)}else if(d==="undefined"||d==="boolean"){this.className&&c.data(this,"__className__",this.className);this.className=
this.className||a===false?"":c.data(this,"__className__")||""}})},hasClass:function(a){a=" "+a+" ";for(var b=0,d=this.length;b<d;b++)if((" "+this[b].className+" ").replace(Aa," ").indexOf(a)>-1)return true;return false},val:function(a){if(a===w){var b=this[0];if(b){if(c.nodeName(b,"option"))return(b.attributes.value||{}).specified?b.value:b.text;if(c.nodeName(b,"select")){var d=b.selectedIndex,f=[],e=b.options;b=b.type==="select-one";if(d<0)return null;var j=b?d:0;for(d=b?d+1:e.length;j<d;j++){var i=
e[j];if(i.selected){a=c(i).val();if(b)return a;f.push(a)}}return f}if(Ba.test(b.type)&&!c.support.checkOn)return b.getAttribute("value")===null?"on":b.value;return(b.value||"").replace(Za,"")}return w}var o=c.isFunction(a);return this.each(function(k){var n=c(this),r=a;if(this.nodeType===1){if(o)r=a.call(this,k,n.val());if(typeof r==="number")r+="";if(c.isArray(r)&&Ba.test(this.type))this.checked=c.inArray(n.val(),r)>=0;else if(c.nodeName(this,"select")){var u=c.makeArray(r);c("option",this).each(function(){this.selected=
c.inArray(c(this).val(),u)>=0});if(!u.length)this.selectedIndex=-1}else this.value=r}})}});c.extend({attrFn:{val:true,css:true,html:true,text:true,data:true,width:true,height:true,offset:true},attr:function(a,b,d,f){if(!a||a.nodeType===3||a.nodeType===8)return w;if(f&&b in c.attrFn)return c(a)[b](d);f=a.nodeType!==1||!c.isXMLDoc(a);var e=d!==w;b=f&&c.props[b]||b;if(a.nodeType===1){var j=$a.test(b);if(b in a&&f&&!j){if(e){b==="type"&&ab.test(a.nodeName)&&a.parentNode&&c.error("type property can't be changed");
a[b]=d}if(c.nodeName(a,"form")&&a.getAttributeNode(b))return a.getAttributeNode(b).nodeValue;if(b==="tabIndex")return(b=a.getAttributeNode("tabIndex"))&&b.specified?b.value:bb.test(a.nodeName)||cb.test(a.nodeName)&&a.href?0:w;return a[b]}if(!c.support.style&&f&&b==="style"){if(e)a.style.cssText=""+d;return a.style.cssText}e&&a.setAttribute(b,""+d);a=!c.support.hrefNormalized&&f&&j?a.getAttribute(b,2):a.getAttribute(b);return a===null?w:a}return c.style(a,b,d)}});var O=/\.(.*)$/,db=function(a){return a.replace(/[^\w\s\.\|`]/g,
function(b){return"\\"+b})};c.event={add:function(a,b,d,f){if(!(a.nodeType===3||a.nodeType===8)){if(a.setInterval&&a!==A&&!a.frameElement)a=A;var e,j;if(d.handler){e=d;d=e.handler}if(!d.guid)d.guid=c.guid++;if(j=c.data(a)){var i=j.events=j.events||{},o=j.handle;if(!o)j.handle=o=function(){return typeof c!=="undefined"&&!c.event.triggered?c.event.handle.apply(o.elem,arguments):w};o.elem=a;b=b.split(" ");for(var k,n=0,r;k=b[n++];){j=e?c.extend({},e):{handler:d,data:f};if(k.indexOf(".")>-1){r=k.split(".");
k=r.shift();j.namespace=r.slice(0).sort().join(".")}else{r=[];j.namespace=""}j.type=k;j.guid=d.guid;var u=i[k],z=c.event.special[k]||{};if(!u){u=i[k]=[];if(!z.setup||z.setup.call(a,f,r,o)===false)if(a.addEventListener)a.addEventListener(k,o,false);else a.attachEvent&&a.attachEvent("on"+k,o)}if(z.add){z.add.call(a,j);if(!j.handler.guid)j.handler.guid=d.guid}u.push(j);c.event.global[k]=true}a=null}}},global:{},remove:function(a,b,d,f){if(!(a.nodeType===3||a.nodeType===8)){var e,j=0,i,o,k,n,r,u,z=c.data(a),
C=z&&z.events;if(z&&C){if(b&&b.type){d=b.handler;b=b.type}if(!b||typeof b==="string"&&b.charAt(0)==="."){b=b||"";for(e in C)c.event.remove(a,e+b)}else{for(b=b.split(" ");e=b[j++];){n=e;i=e.indexOf(".")<0;o=[];if(!i){o=e.split(".");e=o.shift();k=new RegExp("(^|\\.)"+c.map(o.slice(0).sort(),db).join("\\.(?:.*\\.)?")+"(\\.|$)")}if(r=C[e])if(d){n=c.event.special[e]||{};for(B=f||0;B<r.length;B++){u=r[B];if(d.guid===u.guid){if(i||k.test(u.namespace)){f==null&&r.splice(B--,1);n.remove&&n.remove.call(a,u)}if(f!=
null)break}}if(r.length===0||f!=null&&r.length===1){if(!n.teardown||n.teardown.call(a,o)===false)Ca(a,e,z.handle);delete C[e]}}else for(var B=0;B<r.length;B++){u=r[B];if(i||k.test(u.namespace)){c.event.remove(a,n,u.handler,B);r.splice(B--,1)}}}if(c.isEmptyObject(C)){if(b=z.handle)b.elem=null;delete z.events;delete z.handle;c.isEmptyObject(z)&&c.removeData(a)}}}}},trigger:function(a,b,d,f){var e=a.type||a;if(!f){a=typeof a==="object"?a[G]?a:c.extend(c.Event(e),a):c.Event(e);if(e.indexOf("!")>=0){a.type=
e=e.slice(0,-1);a.exclusive=true}if(!d){a.stopPropagation();c.event.global[e]&&c.each(c.cache,function(){this.events&&this.events[e]&&c.event.trigger(a,b,this.handle.elem)})}if(!d||d.nodeType===3||d.nodeType===8)return w;a.result=w;a.target=d;b=c.makeArray(b);b.unshift(a)}a.currentTarget=d;(f=c.data(d,"handle"))&&f.apply(d,b);f=d.parentNode||d.ownerDocument;try{if(!(d&&d.nodeName&&c.noData[d.nodeName.toLowerCase()]))if(d["on"+e]&&d["on"+e].apply(d,b)===false)a.result=false}catch(j){}if(!a.isPropagationStopped()&&
f)c.event.trigger(a,b,f,true);else if(!a.isDefaultPrevented()){f=a.target;var i,o=c.nodeName(f,"a")&&e==="click",k=c.event.special[e]||{};if((!k._default||k._default.call(d,a)===false)&&!o&&!(f&&f.nodeName&&c.noData[f.nodeName.toLowerCase()])){try{if(f[e]){if(i=f["on"+e])f["on"+e]=null;c.event.triggered=true;f[e]()}}catch(n){}if(i)f["on"+e]=i;c.event.triggered=false}}},handle:function(a){var b,d,f,e;a=arguments[0]=c.event.fix(a||A.event);a.currentTarget=this;b=a.type.indexOf(".")<0&&!a.exclusive;
if(!b){d=a.type.split(".");a.type=d.shift();f=new RegExp("(^|\\.)"+d.slice(0).sort().join("\\.(?:.*\\.)?")+"(\\.|$)")}e=c.data(this,"events");d=e[a.type];if(e&&d){d=d.slice(0);e=0;for(var j=d.length;e<j;e++){var i=d[e];if(b||f.test(i.namespace)){a.handler=i.handler;a.data=i.data;a.handleObj=i;i=i.handler.apply(this,arguments);if(i!==w){a.result=i;if(i===false){a.preventDefault();a.stopPropagation()}}if(a.isImmediatePropagationStopped())break}}}return a.result},props:"altKey attrChange attrName bubbles button cancelable charCode clientX clientY ctrlKey currentTarget data detail eventPhase fromElement handler keyCode layerX layerY metaKey newValue offsetX offsetY originalTarget pageX pageY prevValue relatedNode relatedTarget screenX screenY shiftKey srcElement target toElement view wheelDelta which".split(" "),
fix:function(a){if(a[G])return a;var b=a;a=c.Event(b);for(var d=this.props.length,f;d;){f=this.props[--d];a[f]=b[f]}if(!a.target)a.target=a.srcElement||s;if(a.target.nodeType===3)a.target=a.target.parentNode;if(!a.relatedTarget&&a.fromElement)a.relatedTarget=a.fromElement===a.target?a.toElement:a.fromElement;if(a.pageX==null&&a.clientX!=null){b=s.documentElement;d=s.body;a.pageX=a.clientX+(b&&b.scrollLeft||d&&d.scrollLeft||0)-(b&&b.clientLeft||d&&d.clientLeft||0);a.pageY=a.clientY+(b&&b.scrollTop||
d&&d.scrollTop||0)-(b&&b.clientTop||d&&d.clientTop||0)}if(!a.which&&(a.charCode||a.charCode===0?a.charCode:a.keyCode))a.which=a.charCode||a.keyCode;if(!a.metaKey&&a.ctrlKey)a.metaKey=a.ctrlKey;if(!a.which&&a.button!==w)a.which=a.button&1?1:a.button&2?3:a.button&4?2:0;return a},guid:1E8,proxy:c.proxy,special:{ready:{setup:c.bindReady,teardown:c.noop},live:{add:function(a){c.event.add(this,a.origType,c.extend({},a,{handler:oa}))},remove:function(a){var b=true,d=a.origType.replace(O,"");c.each(c.data(this,
"events").live||[],function(){if(d===this.origType.replace(O,""))return b=false});b&&c.event.remove(this,a.origType,oa)}},beforeunload:{setup:function(a,b,d){if(this.setInterval)this.onbeforeunload=d;return false},teardown:function(a,b){if(this.onbeforeunload===b)this.onbeforeunload=null}}}};var Ca=s.removeEventListener?function(a,b,d){a.removeEventListener(b,d,false)}:function(a,b,d){a.detachEvent("on"+b,d)};c.Event=function(a){if(!this.preventDefault)return new c.Event(a);if(a&&a.type){this.originalEvent=
a;this.type=a.type}else this.type=a;this.timeStamp=J();this[G]=true};c.Event.prototype={preventDefault:function(){this.isDefaultPrevented=Z;var a=this.originalEvent;if(a){a.preventDefault&&a.preventDefault();a.returnValue=false}},stopPropagation:function(){this.isPropagationStopped=Z;var a=this.originalEvent;if(a){a.stopPropagation&&a.stopPropagation();a.cancelBubble=true}},stopImmediatePropagation:function(){this.isImmediatePropagationStopped=Z;this.stopPropagation()},isDefaultPrevented:Y,isPropagationStopped:Y,
isImmediatePropagationStopped:Y};var Da=function(a){var b=a.relatedTarget;try{for(;b&&b!==this;)b=b.parentNode;if(b!==this){a.type=a.data;c.event.handle.apply(this,arguments)}}catch(d){}},Ea=function(a){a.type=a.data;c.event.handle.apply(this,arguments)};c.each({mouseenter:"mouseover",mouseleave:"mouseout"},function(a,b){c.event.special[a]={setup:function(d){c.event.add(this,b,d&&d.selector?Ea:Da,a)},teardown:function(d){c.event.remove(this,b,d&&d.selector?Ea:Da)}}});if(!c.support.submitBubbles)c.event.special.submit=
{setup:function(){if(this.nodeName.toLowerCase()!=="form"){c.event.add(this,"click.specialSubmit",function(a){var b=a.target,d=b.type;if((d==="submit"||d==="image")&&c(b).closest("form").length)return na("submit",this,arguments)});c.event.add(this,"keypress.specialSubmit",function(a){var b=a.target,d=b.type;if((d==="text"||d==="password")&&c(b).closest("form").length&&a.keyCode===13)return na("submit",this,arguments)})}else return false},teardown:function(){c.event.remove(this,".specialSubmit")}};
if(!c.support.changeBubbles){var da=/textarea|input|select/i,ea,Fa=function(a){var b=a.type,d=a.value;if(b==="radio"||b==="checkbox")d=a.checked;else if(b==="select-multiple")d=a.selectedIndex>-1?c.map(a.options,function(f){return f.selected}).join("-"):"";else if(a.nodeName.toLowerCase()==="select")d=a.selectedIndex;return d},fa=function(a,b){var d=a.target,f,e;if(!(!da.test(d.nodeName)||d.readOnly)){f=c.data(d,"_change_data");e=Fa(d);if(a.type!=="focusout"||d.type!=="radio")c.data(d,"_change_data",
e);if(!(f===w||e===f))if(f!=null||e){a.type="change";return c.event.trigger(a,b,d)}}};c.event.special.change={filters:{focusout:fa,click:function(a){var b=a.target,d=b.type;if(d==="radio"||d==="checkbox"||b.nodeName.toLowerCase()==="select")return fa.call(this,a)},keydown:function(a){var b=a.target,d=b.type;if(a.keyCode===13&&b.nodeName.toLowerCase()!=="textarea"||a.keyCode===32&&(d==="checkbox"||d==="radio")||d==="select-multiple")return fa.call(this,a)},beforeactivate:function(a){a=a.target;c.data(a,
"_change_data",Fa(a))}},setup:function(){if(this.type==="file")return false;for(var a in ea)c.event.add(this,a+".specialChange",ea[a]);return da.test(this.nodeName)},teardown:function(){c.event.remove(this,".specialChange");return da.test(this.nodeName)}};ea=c.event.special.change.filters}s.addEventListener&&c.each({focus:"focusin",blur:"focusout"},function(a,b){function d(f){f=c.event.fix(f);f.type=b;return c.event.handle.call(this,f)}c.event.special[b]={setup:function(){this.addEventListener(a,
d,true)},teardown:function(){this.removeEventListener(a,d,true)}}});c.each(["bind","one"],function(a,b){c.fn[b]=function(d,f,e){if(typeof d==="object"){for(var j in d)this[b](j,f,d[j],e);return this}if(c.isFunction(f)){e=f;f=w}var i=b==="one"?c.proxy(e,function(k){c(this).unbind(k,i);return e.apply(this,arguments)}):e;if(d==="unload"&&b!=="one")this.one(d,f,e);else{j=0;for(var o=this.length;j<o;j++)c.event.add(this[j],d,i,f)}return this}});c.fn.extend({unbind:function(a,b){if(typeof a==="object"&&
!a.preventDefault)for(var d in a)this.unbind(d,a[d]);else{d=0;for(var f=this.length;d<f;d++)c.event.remove(this[d],a,b)}return this},delegate:function(a,b,d,f){return this.live(b,d,f,a)},undelegate:function(a,b,d){return arguments.length===0?this.unbind("live"):this.die(b,null,d,a)},trigger:function(a,b){return this.each(function(){c.event.trigger(a,b,this)})},triggerHandler:function(a,b){if(this[0]){a=c.Event(a);a.preventDefault();a.stopPropagation();c.event.trigger(a,b,this[0]);return a.result}},
toggle:function(a){for(var b=arguments,d=1;d<b.length;)c.proxy(a,b[d++]);return this.click(c.proxy(a,function(f){var e=(c.data(this,"lastToggle"+a.guid)||0)%d;c.data(this,"lastToggle"+a.guid,e+1);f.preventDefault();return b[e].apply(this,arguments)||false}))},hover:function(a,b){return this.mouseenter(a).mouseleave(b||a)}});var Ga={focus:"focusin",blur:"focusout",mouseenter:"mouseover",mouseleave:"mouseout"};c.each(["live","die"],function(a,b){c.fn[b]=function(d,f,e,j){var i,o=0,k,n,r=j||this.selector,
u=j?this:c(this.context);if(c.isFunction(f)){e=f;f=w}for(d=(d||"").split(" ");(i=d[o++])!=null;){j=O.exec(i);k="";if(j){k=j[0];i=i.replace(O,"")}if(i==="hover")d.push("mouseenter"+k,"mouseleave"+k);else{n=i;if(i==="focus"||i==="blur"){d.push(Ga[i]+k);i+=k}else i=(Ga[i]||i)+k;b==="live"?u.each(function(){c.event.add(this,pa(i,r),{data:f,selector:r,handler:e,origType:i,origHandler:e,preType:n})}):u.unbind(pa(i,r),e)}}return this}});c.each("blur focus focusin focusout load resize scroll unload click dblclick mousedown mouseup mousemove mouseover mouseout mouseenter mouseleave change select submit keydown keypress keyup error".split(" "),
function(a,b){c.fn[b]=function(d){return d?this.bind(b,d):this.trigger(b)};if(c.attrFn)c.attrFn[b]=true});A.attachEvent&&!A.addEventListener&&A.attachEvent("onunload",function(){for(var a in c.cache)if(c.cache[a].handle)try{c.event.remove(c.cache[a].handle.elem)}catch(b){}});(function(){function a(g){for(var h="",l,m=0;g[m];m++){l=g[m];if(l.nodeType===3||l.nodeType===4)h+=l.nodeValue;else if(l.nodeType!==8)h+=a(l.childNodes)}return h}function b(g,h,l,m,q,p){q=0;for(var v=m.length;q<v;q++){var t=m[q];
if(t){t=t[g];for(var y=false;t;){if(t.sizcache===l){y=m[t.sizset];break}if(t.nodeType===1&&!p){t.sizcache=l;t.sizset=q}if(t.nodeName.toLowerCase()===h){y=t;break}t=t[g]}m[q]=y}}}function d(g,h,l,m,q,p){q=0;for(var v=m.length;q<v;q++){var t=m[q];if(t){t=t[g];for(var y=false;t;){if(t.sizcache===l){y=m[t.sizset];break}if(t.nodeType===1){if(!p){t.sizcache=l;t.sizset=q}if(typeof h!=="string"){if(t===h){y=true;break}}else if(k.filter(h,[t]).length>0){y=t;break}}t=t[g]}m[q]=y}}}var f=/((?:\((?:\([^()]+\)|[^()]+)+\)|\[(?:\[[^[\]]*\]|['"][^'"]*['"]|[^[\]'"]+)+\]|\\.|[^ >+~,(\[\\]+)+|[>+~])(\s*,\s*)?((?:.|\r|\n)*)/g,
e=0,j=Object.prototype.toString,i=false,o=true;[0,0].sort(function(){o=false;return 0});var k=function(g,h,l,m){l=l||[];var q=h=h||s;if(h.nodeType!==1&&h.nodeType!==9)return[];if(!g||typeof g!=="string")return l;for(var p=[],v,t,y,S,H=true,M=x(h),I=g;(f.exec(""),v=f.exec(I))!==null;){I=v[3];p.push(v[1]);if(v[2]){S=v[3];break}}if(p.length>1&&r.exec(g))if(p.length===2&&n.relative[p[0]])t=ga(p[0]+p[1],h);else for(t=n.relative[p[0]]?[h]:k(p.shift(),h);p.length;){g=p.shift();if(n.relative[g])g+=p.shift();
t=ga(g,t)}else{if(!m&&p.length>1&&h.nodeType===9&&!M&&n.match.ID.test(p[0])&&!n.match.ID.test(p[p.length-1])){v=k.find(p.shift(),h,M);h=v.expr?k.filter(v.expr,v.set)[0]:v.set[0]}if(h){v=m?{expr:p.pop(),set:z(m)}:k.find(p.pop(),p.length===1&&(p[0]==="~"||p[0]==="+")&&h.parentNode?h.parentNode:h,M);t=v.expr?k.filter(v.expr,v.set):v.set;if(p.length>0)y=z(t);else H=false;for(;p.length;){var D=p.pop();v=D;if(n.relative[D])v=p.pop();else D="";if(v==null)v=h;n.relative[D](y,v,M)}}else y=[]}y||(y=t);y||k.error(D||
g);if(j.call(y)==="[object Array]")if(H)if(h&&h.nodeType===1)for(g=0;y[g]!=null;g++){if(y[g]&&(y[g]===true||y[g].nodeType===1&&E(h,y[g])))l.push(t[g])}else for(g=0;y[g]!=null;g++)y[g]&&y[g].nodeType===1&&l.push(t[g]);else l.push.apply(l,y);else z(y,l);if(S){k(S,q,l,m);k.uniqueSort(l)}return l};k.uniqueSort=function(g){if(B){i=o;g.sort(B);if(i)for(var h=1;h<g.length;h++)g[h]===g[h-1]&&g.splice(h--,1)}return g};k.matches=function(g,h){return k(g,null,null,h)};k.find=function(g,h,l){var m,q;if(!g)return[];
for(var p=0,v=n.order.length;p<v;p++){var t=n.order[p];if(q=n.leftMatch[t].exec(g)){var y=q[1];q.splice(1,1);if(y.substr(y.length-1)!=="\\"){q[1]=(q[1]||"").replace(/\\/g,"");m=n.find[t](q,h,l);if(m!=null){g=g.replace(n.match[t],"");break}}}}m||(m=h.getElementsByTagName("*"));return{set:m,expr:g}};k.filter=function(g,h,l,m){for(var q=g,p=[],v=h,t,y,S=h&&h[0]&&x(h[0]);g&&h.length;){for(var H in n.filter)if((t=n.leftMatch[H].exec(g))!=null&&t[2]){var M=n.filter[H],I,D;D=t[1];y=false;t.splice(1,1);if(D.substr(D.length-
1)!=="\\"){if(v===p)p=[];if(n.preFilter[H])if(t=n.preFilter[H](t,v,l,p,m,S)){if(t===true)continue}else y=I=true;if(t)for(var U=0;(D=v[U])!=null;U++)if(D){I=M(D,t,U,v);var Ha=m^!!I;if(l&&I!=null)if(Ha)y=true;else v[U]=false;else if(Ha){p.push(D);y=true}}if(I!==w){l||(v=p);g=g.replace(n.match[H],"");if(!y)return[];break}}}if(g===q)if(y==null)k.error(g);else break;q=g}return v};k.error=function(g){throw"Syntax error, unrecognized expression: "+g;};var n=k.selectors={order:["ID","NAME","TAG"],match:{ID:/#((?:[\w\u00c0-\uFFFF-]|\\.)+)/,
CLASS:/\.((?:[\w\u00c0-\uFFFF-]|\\.)+)/,NAME:/\[name=['"]*((?:[\w\u00c0-\uFFFF-]|\\.)+)['"]*\]/,ATTR:/\[\s*((?:[\w\u00c0-\uFFFF-]|\\.)+)\s*(?:(\S?=)\s*(['"]*)(.*?)\3|)\s*\]/,TAG:/^((?:[\w\u00c0-\uFFFF\*-]|\\.)+)/,CHILD:/:(only|nth|last|first)-child(?:\((even|odd|[\dn+-]*)\))?/,POS:/:(nth|eq|gt|lt|first|last|even|odd)(?:\((\d*)\))?(?=[^-]|$)/,PSEUDO:/:((?:[\w\u00c0-\uFFFF-]|\\.)+)(?:\((['"]?)((?:\([^\)]+\)|[^\(\)]*)+)\2\))?/},leftMatch:{},attrMap:{"class":"className","for":"htmlFor"},attrHandle:{href:function(g){return g.getAttribute("href")}},
relative:{"+":function(g,h){var l=typeof h==="string",m=l&&!/\W/.test(h);l=l&&!m;if(m)h=h.toLowerCase();m=0;for(var q=g.length,p;m<q;m++)if(p=g[m]){for(;(p=p.previousSibling)&&p.nodeType!==1;);g[m]=l||p&&p.nodeName.toLowerCase()===h?p||false:p===h}l&&k.filter(h,g,true)},">":function(g,h){var l=typeof h==="string";if(l&&!/\W/.test(h)){h=h.toLowerCase();for(var m=0,q=g.length;m<q;m++){var p=g[m];if(p){l=p.parentNode;g[m]=l.nodeName.toLowerCase()===h?l:false}}}else{m=0;for(q=g.length;m<q;m++)if(p=g[m])g[m]=
l?p.parentNode:p.parentNode===h;l&&k.filter(h,g,true)}},"":function(g,h,l){var m=e++,q=d;if(typeof h==="string"&&!/\W/.test(h)){var p=h=h.toLowerCase();q=b}q("parentNode",h,m,g,p,l)},"~":function(g,h,l){var m=e++,q=d;if(typeof h==="string"&&!/\W/.test(h)){var p=h=h.toLowerCase();q=b}q("previousSibling",h,m,g,p,l)}},find:{ID:function(g,h,l){if(typeof h.getElementById!=="undefined"&&!l)return(g=h.getElementById(g[1]))?[g]:[]},NAME:function(g,h){if(typeof h.getElementsByName!=="undefined"){var l=[];
h=h.getElementsByName(g[1]);for(var m=0,q=h.length;m<q;m++)h[m].getAttribute("name")===g[1]&&l.push(h[m]);return l.length===0?null:l}},TAG:function(g,h){return h.getElementsByTagName(g[1])}},preFilter:{CLASS:function(g,h,l,m,q,p){g=" "+g[1].replace(/\\/g,"")+" ";if(p)return g;p=0;for(var v;(v=h[p])!=null;p++)if(v)if(q^(v.className&&(" "+v.className+" ").replace(/[\t\n]/g," ").indexOf(g)>=0))l||m.push(v);else if(l)h[p]=false;return false},ID:function(g){return g[1].replace(/\\/g,"")},TAG:function(g){return g[1].toLowerCase()},
CHILD:function(g){if(g[1]==="nth"){var h=/(-?)(\d*)n((?:\+|-)?\d*)/.exec(g[2]==="even"&&"2n"||g[2]==="odd"&&"2n+1"||!/\D/.test(g[2])&&"0n+"+g[2]||g[2]);g[2]=h[1]+(h[2]||1)-0;g[3]=h[3]-0}g[0]=e++;return g},ATTR:function(g,h,l,m,q,p){h=g[1].replace(/\\/g,"");if(!p&&n.attrMap[h])g[1]=n.attrMap[h];if(g[2]==="~=")g[4]=" "+g[4]+" ";return g},PSEUDO:function(g,h,l,m,q){if(g[1]==="not")if((f.exec(g[3])||"").length>1||/^\w/.test(g[3]))g[3]=k(g[3],null,null,h);else{g=k.filter(g[3],h,l,true^q);l||m.push.apply(m,
g);return false}else if(n.match.POS.test(g[0])||n.match.CHILD.test(g[0]))return true;return g},POS:function(g){g.unshift(true);return g}},filters:{enabled:function(g){return g.disabled===false&&g.type!=="hidden"},disabled:function(g){return g.disabled===true},checked:function(g){return g.checked===true},selected:function(g){return g.selected===true},parent:function(g){return!!g.firstChild},empty:function(g){return!g.firstChild},has:function(g,h,l){return!!k(l[3],g).length},header:function(g){return/h\d/i.test(g.nodeName)},
text:function(g){return"text"===g.type},radio:function(g){return"radio"===g.type},checkbox:function(g){return"checkbox"===g.type},file:function(g){return"file"===g.type},password:function(g){return"password"===g.type},submit:function(g){return"submit"===g.type},image:function(g){return"image"===g.type},reset:function(g){return"reset"===g.type},button:function(g){return"button"===g.type||g.nodeName.toLowerCase()==="button"},input:function(g){return/input|select|textarea|button/i.test(g.nodeName)}},
setFilters:{first:function(g,h){return h===0},last:function(g,h,l,m){return h===m.length-1},even:function(g,h){return h%2===0},odd:function(g,h){return h%2===1},lt:function(g,h,l){return h<l[3]-0},gt:function(g,h,l){return h>l[3]-0},nth:function(g,h,l){return l[3]-0===h},eq:function(g,h,l){return l[3]-0===h}},filter:{PSEUDO:function(g,h,l,m){var q=h[1],p=n.filters[q];if(p)return p(g,l,h,m);else if(q==="contains")return(g.textContent||g.innerText||a([g])||"").indexOf(h[3])>=0;else if(q==="not"){h=
h[3];l=0;for(m=h.length;l<m;l++)if(h[l]===g)return false;return true}else k.error("Syntax error, unrecognized expression: "+q)},CHILD:function(g,h){var l=h[1],m=g;switch(l){case "only":case "first":for(;m=m.previousSibling;)if(m.nodeType===1)return false;if(l==="first")return true;m=g;case "last":for(;m=m.nextSibling;)if(m.nodeType===1)return false;return true;case "nth":l=h[2];var q=h[3];if(l===1&&q===0)return true;h=h[0];var p=g.parentNode;if(p&&(p.sizcache!==h||!g.nodeIndex)){var v=0;for(m=p.firstChild;m;m=
m.nextSibling)if(m.nodeType===1)m.nodeIndex=++v;p.sizcache=h}g=g.nodeIndex-q;return l===0?g===0:g%l===0&&g/l>=0}},ID:function(g,h){return g.nodeType===1&&g.getAttribute("id")===h},TAG:function(g,h){return h==="*"&&g.nodeType===1||g.nodeName.toLowerCase()===h},CLASS:function(g,h){return(" "+(g.className||g.getAttribute("class"))+" ").indexOf(h)>-1},ATTR:function(g,h){var l=h[1];g=n.attrHandle[l]?n.attrHandle[l](g):g[l]!=null?g[l]:g.getAttribute(l);l=g+"";var m=h[2];h=h[4];return g==null?m==="!=":m===
"="?l===h:m==="*="?l.indexOf(h)>=0:m==="~="?(" "+l+" ").indexOf(h)>=0:!h?l&&g!==false:m==="!="?l!==h:m==="^="?l.indexOf(h)===0:m==="$="?l.substr(l.length-h.length)===h:m==="|="?l===h||l.substr(0,h.length+1)===h+"-":false},POS:function(g,h,l,m){var q=n.setFilters[h[2]];if(q)return q(g,l,h,m)}}},r=n.match.POS;for(var u in n.match){n.match[u]=new RegExp(n.match[u].source+/(?![^\[]*\])(?![^\(]*\))/.source);n.leftMatch[u]=new RegExp(/(^(?:.|\r|\n)*?)/.source+n.match[u].source.replace(/\\(\d+)/g,function(g,
h){return"\\"+(h-0+1)}))}var z=function(g,h){g=Array.prototype.slice.call(g,0);if(h){h.push.apply(h,g);return h}return g};try{Array.prototype.slice.call(s.documentElement.childNodes,0)}catch(C){z=function(g,h){h=h||[];if(j.call(g)==="[object Array]")Array.prototype.push.apply(h,g);else if(typeof g.length==="number")for(var l=0,m=g.length;l<m;l++)h.push(g[l]);else for(l=0;g[l];l++)h.push(g[l]);return h}}var B;if(s.documentElement.compareDocumentPosition)B=function(g,h){if(!g.compareDocumentPosition||
!h.compareDocumentPosition){if(g==h)i=true;return g.compareDocumentPosition?-1:1}g=g.compareDocumentPosition(h)&4?-1:g===h?0:1;if(g===0)i=true;return g};else if("sourceIndex"in s.documentElement)B=function(g,h){if(!g.sourceIndex||!h.sourceIndex){if(g==h)i=true;return g.sourceIndex?-1:1}g=g.sourceIndex-h.sourceIndex;if(g===0)i=true;return g};else if(s.createRange)B=function(g,h){if(!g.ownerDocument||!h.ownerDocument){if(g==h)i=true;return g.ownerDocument?-1:1}var l=g.ownerDocument.createRange(),m=
h.ownerDocument.createRange();l.setStart(g,0);l.setEnd(g,0);m.setStart(h,0);m.setEnd(h,0);g=l.compareBoundaryPoints(Range.START_TO_END,m);if(g===0)i=true;return g};(function(){var g=s.createElement("div"),h="script"+(new Date).getTime();g.innerHTML="<a name='"+h+"'/>";var l=s.documentElement;l.insertBefore(g,l.firstChild);if(s.getElementById(h)){n.find.ID=function(m,q,p){if(typeof q.getElementById!=="undefined"&&!p)return(q=q.getElementById(m[1]))?q.id===m[1]||typeof q.getAttributeNode!=="undefined"&&
q.getAttributeNode("id").nodeValue===m[1]?[q]:w:[]};n.filter.ID=function(m,q){var p=typeof m.getAttributeNode!=="undefined"&&m.getAttributeNode("id");return m.nodeType===1&&p&&p.nodeValue===q}}l.removeChild(g);l=g=null})();(function(){var g=s.createElement("div");g.appendChild(s.createComment(""));if(g.getElementsByTagName("*").length>0)n.find.TAG=function(h,l){l=l.getElementsByTagName(h[1]);if(h[1]==="*"){h=[];for(var m=0;l[m];m++)l[m].nodeType===1&&h.push(l[m]);l=h}return l};g.innerHTML="<a href='#'></a>";
if(g.firstChild&&typeof g.firstChild.getAttribute!=="undefined"&&g.firstChild.getAttribute("href")!=="#")n.attrHandle.href=function(h){return h.getAttribute("href",2)};g=null})();s.querySelectorAll&&function(){var g=k,h=s.createElement("div");h.innerHTML="<p class='TEST'></p>";if(!(h.querySelectorAll&&h.querySelectorAll(".TEST").length===0)){k=function(m,q,p,v){q=q||s;if(!v&&q.nodeType===9&&!x(q))try{return z(q.querySelectorAll(m),p)}catch(t){}return g(m,q,p,v)};for(var l in g)k[l]=g[l];h=null}}();
(function(){var g=s.createElement("div");g.innerHTML="<div class='test e'></div><div class='test'></div>";if(!(!g.getElementsByClassName||g.getElementsByClassName("e").length===0)){g.lastChild.className="e";if(g.getElementsByClassName("e").length!==1){n.order.splice(1,0,"CLASS");n.find.CLASS=function(h,l,m){if(typeof l.getElementsByClassName!=="undefined"&&!m)return l.getElementsByClassName(h[1])};g=null}}})();var E=s.compareDocumentPosition?function(g,h){return!!(g.compareDocumentPosition(h)&16)}:
function(g,h){return g!==h&&(g.contains?g.contains(h):true)},x=function(g){return(g=(g?g.ownerDocument||g:0).documentElement)?g.nodeName!=="HTML":false},ga=function(g,h){var l=[],m="",q;for(h=h.nodeType?[h]:h;q=n.match.PSEUDO.exec(g);){m+=q[0];g=g.replace(n.match.PSEUDO,"")}g=n.relative[g]?g+"*":g;q=0;for(var p=h.length;q<p;q++)k(g,h[q],l);return k.filter(m,l)};c.find=k;c.expr=k.selectors;c.expr[":"]=c.expr.filters;c.unique=k.uniqueSort;c.text=a;c.isXMLDoc=x;c.contains=E})();var eb=/Until$/,fb=/^(?:parents|prevUntil|prevAll)/,
gb=/,/;R=Array.prototype.slice;var Ia=function(a,b,d){if(c.isFunction(b))return c.grep(a,function(e,j){return!!b.call(e,j,e)===d});else if(b.nodeType)return c.grep(a,function(e){return e===b===d});else if(typeof b==="string"){var f=c.grep(a,function(e){return e.nodeType===1});if(Ua.test(b))return c.filter(b,f,!d);else b=c.filter(b,f)}return c.grep(a,function(e){return c.inArray(e,b)>=0===d})};c.fn.extend({find:function(a){for(var b=this.pushStack("","find",a),d=0,f=0,e=this.length;f<e;f++){d=b.length;
c.find(a,this[f],b);if(f>0)for(var j=d;j<b.length;j++)for(var i=0;i<d;i++)if(b[i]===b[j]){b.splice(j--,1);break}}return b},has:function(a){var b=c(a);return this.filter(function(){for(var d=0,f=b.length;d<f;d++)if(c.contains(this,b[d]))return true})},not:function(a){return this.pushStack(Ia(this,a,false),"not",a)},filter:function(a){return this.pushStack(Ia(this,a,true),"filter",a)},is:function(a){return!!a&&c.filter(a,this).length>0},closest:function(a,b){if(c.isArray(a)){var d=[],f=this[0],e,j=
{},i;if(f&&a.length){e=0;for(var o=a.length;e<o;e++){i=a[e];j[i]||(j[i]=c.expr.match.POS.test(i)?c(i,b||this.context):i)}for(;f&&f.ownerDocument&&f!==b;){for(i in j){e=j[i];if(e.jquery?e.index(f)>-1:c(f).is(e)){d.push({selector:i,elem:f});delete j[i]}}f=f.parentNode}}return d}var k=c.expr.match.POS.test(a)?c(a,b||this.context):null;return this.map(function(n,r){for(;r&&r.ownerDocument&&r!==b;){if(k?k.index(r)>-1:c(r).is(a))return r;r=r.parentNode}return null})},index:function(a){if(!a||typeof a===
"string")return c.inArray(this[0],a?c(a):this.parent().children());return c.inArray(a.jquery?a[0]:a,this)},add:function(a,b){a=typeof a==="string"?c(a,b||this.context):c.makeArray(a);b=c.merge(this.get(),a);return this.pushStack(qa(a[0])||qa(b[0])?b:c.unique(b))},andSelf:function(){return this.add(this.prevObject)}});c.each({parent:function(a){return(a=a.parentNode)&&a.nodeType!==11?a:null},parents:function(a){return c.dir(a,"parentNode")},parentsUntil:function(a,b,d){return c.dir(a,"parentNode",
d)},next:function(a){return c.nth(a,2,"nextSibling")},prev:function(a){return c.nth(a,2,"previousSibling")},nextAll:function(a){return c.dir(a,"nextSibling")},prevAll:function(a){return c.dir(a,"previousSibling")},nextUntil:function(a,b,d){return c.dir(a,"nextSibling",d)},prevUntil:function(a,b,d){return c.dir(a,"previousSibling",d)},siblings:function(a){return c.sibling(a.parentNode.firstChild,a)},children:function(a){return c.sibling(a.firstChild)},contents:function(a){return c.nodeName(a,"iframe")?
a.contentDocument||a.contentWindow.document:c.makeArray(a.childNodes)}},function(a,b){c.fn[a]=function(d,f){var e=c.map(this,b,d);eb.test(a)||(f=d);if(f&&typeof f==="string")e=c.filter(f,e);e=this.length>1?c.unique(e):e;if((this.length>1||gb.test(f))&&fb.test(a))e=e.reverse();return this.pushStack(e,a,R.call(arguments).join(","))}});c.extend({filter:function(a,b,d){if(d)a=":not("+a+")";return c.find.matches(a,b)},dir:function(a,b,d){var f=[];for(a=a[b];a&&a.nodeType!==9&&(d===w||a.nodeType!==1||!c(a).is(d));){a.nodeType===
1&&f.push(a);a=a[b]}return f},nth:function(a,b,d){b=b||1;for(var f=0;a;a=a[d])if(a.nodeType===1&&++f===b)break;return a},sibling:function(a,b){for(var d=[];a;a=a.nextSibling)a.nodeType===1&&a!==b&&d.push(a);return d}});var Ja=/ jQuery\d+="(?:\d+|null)"/g,V=/^\s+/,Ka=/(<([\w:]+)[^>]*?)\/>/g,hb=/^(?:area|br|col|embed|hr|img|input|link|meta|param)$/i,La=/<([\w:]+)/,ib=/<tbody/i,jb=/<|&#?\w+;/,ta=/<script|<object|<embed|<option|<style/i,ua=/checked\s*(?:[^=]|=\s*.checked.)/i,Ma=function(a,b,d){return hb.test(d)?
a:b+"></"+d+">"},F={option:[1,"<select multiple='multiple'>","</select>"],legend:[1,"<fieldset>","</fieldset>"],thead:[1,"<table>","</table>"],tr:[2,"<table><tbody>","</tbody></table>"],td:[3,"<table><tbody><tr>","</tr></tbody></table>"],col:[2,"<table><tbody></tbody><colgroup>","</colgroup></table>"],area:[1,"<map>","</map>"],_default:[0,"",""]};F.optgroup=F.option;F.tbody=F.tfoot=F.colgroup=F.caption=F.thead;F.th=F.td;if(!c.support.htmlSerialize)F._default=[1,"div<div>","</div>"];c.fn.extend({text:function(a){if(c.isFunction(a))return this.each(function(b){var d=
c(this);d.text(a.call(this,b,d.text()))});if(typeof a!=="object"&&a!==w)return this.empty().append((this[0]&&this[0].ownerDocument||s).createTextNode(a));return c.text(this)},wrapAll:function(a){if(c.isFunction(a))return this.each(function(d){c(this).wrapAll(a.call(this,d))});if(this[0]){var b=c(a,this[0].ownerDocument).eq(0).clone(true);this[0].parentNode&&b.insertBefore(this[0]);b.map(function(){for(var d=this;d.firstChild&&d.firstChild.nodeType===1;)d=d.firstChild;return d}).append(this)}return this},
wrapInner:function(a){if(c.isFunction(a))return this.each(function(b){c(this).wrapInner(a.call(this,b))});return this.each(function(){var b=c(this),d=b.contents();d.length?d.wrapAll(a):b.append(a)})},wrap:function(a){return this.each(function(){c(this).wrapAll(a)})},unwrap:function(){return this.parent().each(function(){c.nodeName(this,"body")||c(this).replaceWith(this.childNodes)}).end()},append:function(){return this.domManip(arguments,true,function(a){this.nodeType===1&&this.appendChild(a)})},
prepend:function(){return this.domManip(arguments,true,function(a){this.nodeType===1&&this.insertBefore(a,this.firstChild)})},before:function(){if(this[0]&&this[0].parentNode)return this.domManip(arguments,false,function(b){this.parentNode.insertBefore(b,this)});else if(arguments.length){var a=c(arguments[0]);a.push.apply(a,this.toArray());return this.pushStack(a,"before",arguments)}},after:function(){if(this[0]&&this[0].parentNode)return this.domManip(arguments,false,function(b){this.parentNode.insertBefore(b,
this.nextSibling)});else if(arguments.length){var a=this.pushStack(this,"after",arguments);a.push.apply(a,c(arguments[0]).toArray());return a}},remove:function(a,b){for(var d=0,f;(f=this[d])!=null;d++)if(!a||c.filter(a,[f]).length){if(!b&&f.nodeType===1){c.cleanData(f.getElementsByTagName("*"));c.cleanData([f])}f.parentNode&&f.parentNode.removeChild(f)}return this},empty:function(){for(var a=0,b;(b=this[a])!=null;a++)for(b.nodeType===1&&c.cleanData(b.getElementsByTagName("*"));b.firstChild;)b.removeChild(b.firstChild);
return this},clone:function(a){var b=this.map(function(){if(!c.support.noCloneEvent&&!c.isXMLDoc(this)){var d=this.outerHTML,f=this.ownerDocument;if(!d){d=f.createElement("div");d.appendChild(this.cloneNode(true));d=d.innerHTML}return c.clean([d.replace(Ja,"").replace(/=([^="'>\s]+\/)>/g,'="$1">').replace(V,"")],f)[0]}else return this.cloneNode(true)});if(a===true){ra(this,b);ra(this.find("*"),b.find("*"))}return b},html:function(a){if(a===w)return this[0]&&this[0].nodeType===1?this[0].innerHTML.replace(Ja,
""):null;else if(typeof a==="string"&&!ta.test(a)&&(c.support.leadingWhitespace||!V.test(a))&&!F[(La.exec(a)||["",""])[1].toLowerCase()]){a=a.replace(Ka,Ma);try{for(var b=0,d=this.length;b<d;b++)if(this[b].nodeType===1){c.cleanData(this[b].getElementsByTagName("*"));this[b].innerHTML=a}}catch(f){this.empty().append(a)}}else c.isFunction(a)?this.each(function(e){var j=c(this),i=j.html();j.empty().append(function(){return a.call(this,e,i)})}):this.empty().append(a);return this},replaceWith:function(a){if(this[0]&&
this[0].parentNode){if(c.isFunction(a))return this.each(function(b){var d=c(this),f=d.html();d.replaceWith(a.call(this,b,f))});if(typeof a!=="string")a=c(a).detach();return this.each(function(){var b=this.nextSibling,d=this.parentNode;c(this).remove();b?c(b).before(a):c(d).append(a)})}else return this.pushStack(c(c.isFunction(a)?a():a),"replaceWith",a)},detach:function(a){return this.remove(a,true)},domManip:function(a,b,d){function f(u){return c.nodeName(u,"table")?u.getElementsByTagName("tbody")[0]||
u.appendChild(u.ownerDocument.createElement("tbody")):u}var e,j,i=a[0],o=[],k;if(!c.support.checkClone&&arguments.length===3&&typeof i==="string"&&ua.test(i))return this.each(function(){c(this).domManip(a,b,d,true)});if(c.isFunction(i))return this.each(function(u){var z=c(this);a[0]=i.call(this,u,b?z.html():w);z.domManip(a,b,d)});if(this[0]){e=i&&i.parentNode;e=c.support.parentNode&&e&&e.nodeType===11&&e.childNodes.length===this.length?{fragment:e}:sa(a,this,o);k=e.fragment;if(j=k.childNodes.length===
1?(k=k.firstChild):k.firstChild){b=b&&c.nodeName(j,"tr");for(var n=0,r=this.length;n<r;n++)d.call(b?f(this[n],j):this[n],n>0||e.cacheable||this.length>1?k.cloneNode(true):k)}o.length&&c.each(o,Qa)}return this}});c.fragments={};c.each({appendTo:"append",prependTo:"prepend",insertBefore:"before",insertAfter:"after",replaceAll:"replaceWith"},function(a,b){c.fn[a]=function(d){var f=[];d=c(d);var e=this.length===1&&this[0].parentNode;if(e&&e.nodeType===11&&e.childNodes.length===1&&d.length===1){d[b](this[0]);
return this}else{e=0;for(var j=d.length;e<j;e++){var i=(e>0?this.clone(true):this).get();c.fn[b].apply(c(d[e]),i);f=f.concat(i)}return this.pushStack(f,a,d.selector)}}});c.extend({clean:function(a,b,d,f){b=b||s;if(typeof b.createElement==="undefined")b=b.ownerDocument||b[0]&&b[0].ownerDocument||s;for(var e=[],j=0,i;(i=a[j])!=null;j++){if(typeof i==="number")i+="";if(i){if(typeof i==="string"&&!jb.test(i))i=b.createTextNode(i);else if(typeof i==="string"){i=i.replace(Ka,Ma);var o=(La.exec(i)||["",
""])[1].toLowerCase(),k=F[o]||F._default,n=k[0],r=b.createElement("div");for(r.innerHTML=k[1]+i+k[2];n--;)r=r.lastChild;if(!c.support.tbody){n=ib.test(i);o=o==="table"&&!n?r.firstChild&&r.firstChild.childNodes:k[1]==="<table>"&&!n?r.childNodes:[];for(k=o.length-1;k>=0;--k)c.nodeName(o[k],"tbody")&&!o[k].childNodes.length&&o[k].parentNode.removeChild(o[k])}!c.support.leadingWhitespace&&V.test(i)&&r.insertBefore(b.createTextNode(V.exec(i)[0]),r.firstChild);i=r.childNodes}if(i.nodeType)e.push(i);else e=
c.merge(e,i)}}if(d)for(j=0;e[j];j++)if(f&&c.nodeName(e[j],"script")&&(!e[j].type||e[j].type.toLowerCase()==="text/javascript"))f.push(e[j].parentNode?e[j].parentNode.removeChild(e[j]):e[j]);else{e[j].nodeType===1&&e.splice.apply(e,[j+1,0].concat(c.makeArray(e[j].getElementsByTagName("script"))));d.appendChild(e[j])}return e},cleanData:function(a){for(var b,d,f=c.cache,e=c.event.special,j=c.support.deleteExpando,i=0,o;(o=a[i])!=null;i++)if(d=o[c.expando]){b=f[d];if(b.events)for(var k in b.events)e[k]?
c.event.remove(o,k):Ca(o,k,b.handle);if(j)delete o[c.expando];else o.removeAttribute&&o.removeAttribute(c.expando);delete f[d]}}});var kb=/z-?index|font-?weight|opacity|zoom|line-?height/i,Na=/alpha\([^)]*\)/,Oa=/opacity=([^)]*)/,ha=/float/i,ia=/-([a-z])/ig,lb=/([A-Z])/g,mb=/^-?\d+(?:px)?$/i,nb=/^-?\d/,ob={position:"absolute",visibility:"hidden",display:"block"},pb=["Left","Right"],qb=["Top","Bottom"],rb=s.defaultView&&s.defaultView.getComputedStyle,Pa=c.support.cssFloat?"cssFloat":"styleFloat",ja=
function(a,b){return b.toUpperCase()};c.fn.css=function(a,b){return X(this,a,b,true,function(d,f,e){if(e===w)return c.curCSS(d,f);if(typeof e==="number"&&!kb.test(f))e+="px";c.style(d,f,e)})};c.extend({style:function(a,b,d){if(!a||a.nodeType===3||a.nodeType===8)return w;if((b==="width"||b==="height")&&parseFloat(d)<0)d=w;var f=a.style||a,e=d!==w;if(!c.support.opacity&&b==="opacity"){if(e){f.zoom=1;b=parseInt(d,10)+""==="NaN"?"":"alpha(opacity="+d*100+")";a=f.filter||c.curCSS(a,"filter")||"";f.filter=
Na.test(a)?a.replace(Na,b):b}return f.filter&&f.filter.indexOf("opacity=")>=0?parseFloat(Oa.exec(f.filter)[1])/100+"":""}if(ha.test(b))b=Pa;b=b.replace(ia,ja);if(e)f[b]=d;return f[b]},css:function(a,b,d,f){if(b==="width"||b==="height"){var e,j=b==="width"?pb:qb;function i(){e=b==="width"?a.offsetWidth:a.offsetHeight;f!=="border"&&c.each(j,function(){f||(e-=parseFloat(c.curCSS(a,"padding"+this,true))||0);if(f==="margin")e+=parseFloat(c.curCSS(a,"margin"+this,true))||0;else e-=parseFloat(c.curCSS(a,
"border"+this+"Width",true))||0})}a.offsetWidth!==0?i():c.swap(a,ob,i);return Math.max(0,Math.round(e))}return c.curCSS(a,b,d)},curCSS:function(a,b,d){var f,e=a.style;if(!c.support.opacity&&b==="opacity"&&a.currentStyle){f=Oa.test(a.currentStyle.filter||"")?parseFloat(RegExp.$1)/100+"":"";return f===""?"1":f}if(ha.test(b))b=Pa;if(!d&&e&&e[b])f=e[b];else if(rb){if(ha.test(b))b="float";b=b.replace(lb,"-$1").toLowerCase();e=a.ownerDocument.defaultView;if(!e)return null;if(a=e.getComputedStyle(a,null))f=
a.getPropertyValue(b);if(b==="opacity"&&f==="")f="1"}else if(a.currentStyle){d=b.replace(ia,ja);f=a.currentStyle[b]||a.currentStyle[d];if(!mb.test(f)&&nb.test(f)){b=e.left;var j=a.runtimeStyle.left;a.runtimeStyle.left=a.currentStyle.left;e.left=d==="fontSize"?"1em":f||0;f=e.pixelLeft+"px";e.left=b;a.runtimeStyle.left=j}}return f},swap:function(a,b,d){var f={};for(var e in b){f[e]=a.style[e];a.style[e]=b[e]}d.call(a);for(e in b)a.style[e]=f[e]}});if(c.expr&&c.expr.filters){c.expr.filters.hidden=function(a){var b=
a.offsetWidth,d=a.offsetHeight,f=a.nodeName.toLowerCase()==="tr";return b===0&&d===0&&!f?true:b>0&&d>0&&!f?false:c.curCSS(a,"display")==="none"};c.expr.filters.visible=function(a){return!c.expr.filters.hidden(a)}}var sb=J(),tb=/<script(.|\s)*?\/script>/gi,ub=/select|textarea/i,vb=/color|date|datetime|email|hidden|month|number|password|range|search|tel|text|time|url|week/i,N=/=\?(&|$)/,ka=/\?/,wb=/(\?|&)_=.*?(&|$)/,xb=/^(\w+:)?\/\/([^\/?#]+)/,yb=/%20/g,zb=c.fn.load;c.fn.extend({load:function(a,b,d){if(typeof a!==
"string")return zb.call(this,a);else if(!this.length)return this;var f=a.indexOf(" ");if(f>=0){var e=a.slice(f,a.length);a=a.slice(0,f)}f="GET";if(b)if(c.isFunction(b)){d=b;b=null}else if(typeof b==="object"){b=c.param(b,c.ajaxSettings.traditional);f="POST"}var j=this;c.ajax({url:a,type:f,dataType:"html",data:b,complete:function(i,o){if(o==="success"||o==="notmodified")j.html(e?c("<div />").append(i.responseText.replace(tb,"")).find(e):i.responseText);d&&j.each(d,[i.responseText,o,i])}});return this},
serialize:function(){return c.param(this.serializeArray())},serializeArray:function(){return this.map(function(){return this.elements?c.makeArray(this.elements):this}).filter(function(){return this.name&&!this.disabled&&(this.checked||ub.test(this.nodeName)||vb.test(this.type))}).map(function(a,b){a=c(this).val();return a==null?null:c.isArray(a)?c.map(a,function(d){return{name:b.name,value:d}}):{name:b.name,value:a}}).get()}});c.each("ajaxStart ajaxStop ajaxComplete ajaxError ajaxSuccess ajaxSend".split(" "),
function(a,b){c.fn[b]=function(d){return this.bind(b,d)}});c.extend({get:function(a,b,d,f){if(c.isFunction(b)){f=f||d;d=b;b=null}return c.ajax({type:"GET",url:a,data:b,success:d,dataType:f})},getScript:function(a,b){return c.get(a,null,b,"script")},getJSON:function(a,b,d){return c.get(a,b,d,"json")},post:function(a,b,d,f){if(c.isFunction(b)){f=f||d;d=b;b={}}return c.ajax({type:"POST",url:a,data:b,success:d,dataType:f})},ajaxSetup:function(a){c.extend(c.ajaxSettings,a)},ajaxSettings:{url:location.href,
global:true,type:"GET",contentType:"application/x-www-form-urlencoded",processData:true,async:true,xhr:A.XMLHttpRequest&&(A.location.protocol!=="file:"||!A.ActiveXObject)?function(){return new A.XMLHttpRequest}:function(){try{return new A.ActiveXObject("Microsoft.XMLHTTP")}catch(a){}},accepts:{xml:"application/xml, text/xml",html:"text/html",script:"text/javascript, application/javascript",json:"application/json, text/javascript",text:"text/plain",_default:"*/*"}},lastModified:{},etag:{},ajax:function(a){function b(){e.success&&
e.success.call(k,o,i,x);e.global&&f("ajaxSuccess",[x,e])}function d(){e.complete&&e.complete.call(k,x,i);e.global&&f("ajaxComplete",[x,e]);e.global&&!--c.active&&c.event.trigger("ajaxStop")}function f(q,p){(e.context?c(e.context):c.event).trigger(q,p)}var e=c.extend(true,{},c.ajaxSettings,a),j,i,o,k=a&&a.context||e,n=e.type.toUpperCase();if(e.data&&e.processData&&typeof e.data!=="string")e.data=c.param(e.data,e.traditional);if(e.dataType==="jsonp"){if(n==="GET")N.test(e.url)||(e.url+=(ka.test(e.url)?
"&":"?")+(e.jsonp||"callback")+"=?");else if(!e.data||!N.test(e.data))e.data=(e.data?e.data+"&":"")+(e.jsonp||"callback")+"=?";e.dataType="json"}if(e.dataType==="json"&&(e.data&&N.test(e.data)||N.test(e.url))){j=e.jsonpCallback||"jsonp"+sb++;if(e.data)e.data=(e.data+"").replace(N,"="+j+"$1");e.url=e.url.replace(N,"="+j+"$1");e.dataType="script";A[j]=A[j]||function(q){o=q;b();d();A[j]=w;try{delete A[j]}catch(p){}z&&z.removeChild(C)}}if(e.dataType==="script"&&e.cache===null)e.cache=false;if(e.cache===
false&&n==="GET"){var r=J(),u=e.url.replace(wb,"$1_="+r+"$2");e.url=u+(u===e.url?(ka.test(e.url)?"&":"?")+"_="+r:"")}if(e.data&&n==="GET")e.url+=(ka.test(e.url)?"&":"?")+e.data;e.global&&!c.active++&&c.event.trigger("ajaxStart");r=(r=xb.exec(e.url))&&(r[1]&&r[1]!==location.protocol||r[2]!==location.host);if(e.dataType==="script"&&n==="GET"&&r){var z=s.getElementsByTagName("head")[0]||s.documentElement,C=s.createElement("script");C.src=e.url;if(e.scriptCharset)C.charset=e.scriptCharset;if(!j){var B=
false;C.onload=C.onreadystatechange=function(){if(!B&&(!this.readyState||this.readyState==="loaded"||this.readyState==="complete")){B=true;b();d();C.onload=C.onreadystatechange=null;z&&C.parentNode&&z.removeChild(C)}}}z.insertBefore(C,z.firstChild);return w}var E=false,x=e.xhr();if(x){e.username?x.open(n,e.url,e.async,e.username,e.password):x.open(n,e.url,e.async);try{if(e.data||a&&a.contentType)x.setRequestHeader("Content-Type",e.contentType);if(e.ifModified){c.lastModified[e.url]&&x.setRequestHeader("If-Modified-Since",
c.lastModified[e.url]);c.etag[e.url]&&x.setRequestHeader("If-None-Match",c.etag[e.url])}r||x.setRequestHeader("X-Requested-With","XMLHttpRequest");x.setRequestHeader("Accept",e.dataType&&e.accepts[e.dataType]?e.accepts[e.dataType]+", */*":e.accepts._default)}catch(ga){}if(e.beforeSend&&e.beforeSend.call(k,x,e)===false){e.global&&!--c.active&&c.event.trigger("ajaxStop");x.abort();return false}e.global&&f("ajaxSend",[x,e]);var g=x.onreadystatechange=function(q){if(!x||x.readyState===0||q==="abort"){E||
d();E=true;if(x)x.onreadystatechange=c.noop}else if(!E&&x&&(x.readyState===4||q==="timeout")){E=true;x.onreadystatechange=c.noop;i=q==="timeout"?"timeout":!c.httpSuccess(x)?"error":e.ifModified&&c.httpNotModified(x,e.url)?"notmodified":"success";var p;if(i==="success")try{o=c.httpData(x,e.dataType,e)}catch(v){i="parsererror";p=v}if(i==="success"||i==="notmodified")j||b();else c.handleError(e,x,i,p);d();q==="timeout"&&x.abort();if(e.async)x=null}};try{var h=x.abort;x.abort=function(){x&&h.call(x);
g("abort")}}catch(l){}e.async&&e.timeout>0&&setTimeout(function(){x&&!E&&g("timeout")},e.timeout);try{x.send(n==="POST"||n==="PUT"||n==="DELETE"?e.data:null)}catch(m){c.handleError(e,x,null,m);d()}e.async||g();return x}},handleError:function(a,b,d,f){if(a.error)a.error.call(a.context||a,b,d,f);if(a.global)(a.context?c(a.context):c.event).trigger("ajaxError",[b,a,f])},active:0,httpSuccess:function(a){try{return!a.status&&location.protocol==="file:"||a.status>=200&&a.status<300||a.status===304||a.status===
1223||a.status===0}catch(b){}return false},httpNotModified:function(a,b){var d=a.getResponseHeader("Last-Modified"),f=a.getResponseHeader("Etag");if(d)c.lastModified[b]=d;if(f)c.etag[b]=f;return a.status===304||a.status===0},httpData:function(a,b,d){var f=a.getResponseHeader("content-type")||"",e=b==="xml"||!b&&f.indexOf("xml")>=0;a=e?a.responseXML:a.responseText;e&&a.documentElement.nodeName==="parsererror"&&c.error("parsererror");if(d&&d.dataFilter)a=d.dataFilter(a,b);if(typeof a==="string")if(b===
"json"||!b&&f.indexOf("json")>=0)a=c.parseJSON(a);else if(b==="script"||!b&&f.indexOf("javascript")>=0)c.globalEval(a);return a},param:function(a,b){function d(i,o){if(c.isArray(o))c.each(o,function(k,n){b||/\[\]$/.test(i)?f(i,n):d(i+"["+(typeof n==="object"||c.isArray(n)?k:"")+"]",n)});else!b&&o!=null&&typeof o==="object"?c.each(o,function(k,n){d(i+"["+k+"]",n)}):f(i,o)}function f(i,o){o=c.isFunction(o)?o():o;e[e.length]=encodeURIComponent(i)+"="+encodeURIComponent(o)}var e=[];if(b===w)b=c.ajaxSettings.traditional;
if(c.isArray(a)||a.jquery)c.each(a,function(){f(this.name,this.value)});else for(var j in a)d(j,a[j]);return e.join("&").replace(yb,"+")}});var la={},Ab=/toggle|show|hide/,Bb=/^([+-]=)?([\d+-.]+)(.*)$/,W,va=[["height","marginTop","marginBottom","paddingTop","paddingBottom"],["width","marginLeft","marginRight","paddingLeft","paddingRight"],["opacity"]];c.fn.extend({show:function(a,b){if(a||a===0)return this.animate(K("show",3),a,b);else{a=0;for(b=this.length;a<b;a++){var d=c.data(this[a],"olddisplay");
this[a].style.display=d||"";if(c.css(this[a],"display")==="none"){d=this[a].nodeName;var f;if(la[d])f=la[d];else{var e=c("<"+d+" />").appendTo("body");f=e.css("display");if(f==="none")f="block";e.remove();la[d]=f}c.data(this[a],"olddisplay",f)}}a=0;for(b=this.length;a<b;a++)this[a].style.display=c.data(this[a],"olddisplay")||"";return this}},hide:function(a,b){if(a||a===0)return this.animate(K("hide",3),a,b);else{a=0;for(b=this.length;a<b;a++){var d=c.data(this[a],"olddisplay");!d&&d!=="none"&&c.data(this[a],
"olddisplay",c.css(this[a],"display"))}a=0;for(b=this.length;a<b;a++)this[a].style.display="none";return this}},_toggle:c.fn.toggle,toggle:function(a,b){var d=typeof a==="boolean";if(c.isFunction(a)&&c.isFunction(b))this._toggle.apply(this,arguments);else a==null||d?this.each(function(){var f=d?a:c(this).is(":hidden");c(this)[f?"show":"hide"]()}):this.animate(K("toggle",3),a,b);return this},fadeTo:function(a,b,d){return this.filter(":hidden").css("opacity",0).show().end().animate({opacity:b},a,d)},
animate:function(a,b,d,f){var e=c.speed(b,d,f);if(c.isEmptyObject(a))return this.each(e.complete);return this[e.queue===false?"each":"queue"](function(){var j=c.extend({},e),i,o=this.nodeType===1&&c(this).is(":hidden"),k=this;for(i in a){var n=i.replace(ia,ja);if(i!==n){a[n]=a[i];delete a[i];i=n}if(a[i]==="hide"&&o||a[i]==="show"&&!o)return j.complete.call(this);if((i==="height"||i==="width")&&this.style){j.display=c.css(this,"display");j.overflow=this.style.overflow}if(c.isArray(a[i])){(j.specialEasing=
j.specialEasing||{})[i]=a[i][1];a[i]=a[i][0]}}if(j.overflow!=null)this.style.overflow="hidden";j.curAnim=c.extend({},a);c.each(a,function(r,u){var z=new c.fx(k,j,r);if(Ab.test(u))z[u==="toggle"?o?"show":"hide":u](a);else{var C=Bb.exec(u),B=z.cur(true)||0;if(C){u=parseFloat(C[2]);var E=C[3]||"px";if(E!=="px"){k.style[r]=(u||1)+E;B=(u||1)/z.cur(true)*B;k.style[r]=B+E}if(C[1])u=(C[1]==="-="?-1:1)*u+B;z.custom(B,u,E)}else z.custom(B,u,"")}});return true})},stop:function(a,b){var d=c.timers;a&&this.queue([]);
this.each(function(){for(var f=d.length-1;f>=0;f--)if(d[f].elem===this){b&&d[f](true);d.splice(f,1)}});b||this.dequeue();return this}});c.each({slideDown:K("show",1),slideUp:K("hide",1),slideToggle:K("toggle",1),fadeIn:{opacity:"show"},fadeOut:{opacity:"hide"}},function(a,b){c.fn[a]=function(d,f){return this.animate(b,d,f)}});c.extend({speed:function(a,b,d){var f=a&&typeof a==="object"?a:{complete:d||!d&&b||c.isFunction(a)&&a,duration:a,easing:d&&b||b&&!c.isFunction(b)&&b};f.duration=c.fx.off?0:typeof f.duration===
"number"?f.duration:c.fx.speeds[f.duration]||c.fx.speeds._default;f.old=f.complete;f.complete=function(){f.queue!==false&&c(this).dequeue();c.isFunction(f.old)&&f.old.call(this)};return f},easing:{linear:function(a,b,d,f){return d+f*a},swing:function(a,b,d,f){return(-Math.cos(a*Math.PI)/2+0.5)*f+d}},timers:[],fx:function(a,b,d){this.options=b;this.elem=a;this.prop=d;if(!b.orig)b.orig={}}});c.fx.prototype={update:function(){this.options.step&&this.options.step.call(this.elem,this.now,this);(c.fx.step[this.prop]||
c.fx.step._default)(this);if((this.prop==="height"||this.prop==="width")&&this.elem.style)this.elem.style.display="block"},cur:function(a){if(this.elem[this.prop]!=null&&(!this.elem.style||this.elem.style[this.prop]==null))return this.elem[this.prop];return(a=parseFloat(c.css(this.elem,this.prop,a)))&&a>-10000?a:parseFloat(c.curCSS(this.elem,this.prop))||0},custom:function(a,b,d){function f(j){return e.step(j)}this.startTime=J();this.start=a;this.end=b;this.unit=d||this.unit||"px";this.now=this.start;
this.pos=this.state=0;var e=this;f.elem=this.elem;if(f()&&c.timers.push(f)&&!W)W=setInterval(c.fx.tick,13)},show:function(){this.options.orig[this.prop]=c.style(this.elem,this.prop);this.options.show=true;this.custom(this.prop==="width"||this.prop==="height"?1:0,this.cur());c(this.elem).show()},hide:function(){this.options.orig[this.prop]=c.style(this.elem,this.prop);this.options.hide=true;this.custom(this.cur(),0)},step:function(a){var b=J(),d=true;if(a||b>=this.options.duration+this.startTime){this.now=
this.end;this.pos=this.state=1;this.update();this.options.curAnim[this.prop]=true;for(var f in this.options.curAnim)if(this.options.curAnim[f]!==true)d=false;if(d){if(this.options.display!=null){this.elem.style.overflow=this.options.overflow;a=c.data(this.elem,"olddisplay");this.elem.style.display=a?a:this.options.display;if(c.css(this.elem,"display")==="none")this.elem.style.display="block"}this.options.hide&&c(this.elem).hide();if(this.options.hide||this.options.show)for(var e in this.options.curAnim)c.style(this.elem,
e,this.options.orig[e]);this.options.complete.call(this.elem)}return false}else{e=b-this.startTime;this.state=e/this.options.duration;a=this.options.easing||(c.easing.swing?"swing":"linear");this.pos=c.easing[this.options.specialEasing&&this.options.specialEasing[this.prop]||a](this.state,e,0,1,this.options.duration);this.now=this.start+(this.end-this.start)*this.pos;this.update()}return true}};c.extend(c.fx,{tick:function(){for(var a=c.timers,b=0;b<a.length;b++)a[b]()||a.splice(b--,1);a.length||
c.fx.stop()},stop:function(){clearInterval(W);W=null},speeds:{slow:600,fast:200,_default:400},step:{opacity:function(a){c.style(a.elem,"opacity",a.now)},_default:function(a){if(a.elem.style&&a.elem.style[a.prop]!=null)a.elem.style[a.prop]=(a.prop==="width"||a.prop==="height"?Math.max(0,a.now):a.now)+a.unit;else a.elem[a.prop]=a.now}}});if(c.expr&&c.expr.filters)c.expr.filters.animated=function(a){return c.grep(c.timers,function(b){return a===b.elem}).length};c.fn.offset="getBoundingClientRect"in s.documentElement?
function(a){var b=this[0];if(a)return this.each(function(e){c.offset.setOffset(this,a,e)});if(!b||!b.ownerDocument)return null;if(b===b.ownerDocument.body)return c.offset.bodyOffset(b);var d=b.getBoundingClientRect(),f=b.ownerDocument;b=f.body;f=f.documentElement;return{top:d.top+(self.pageYOffset||c.support.boxModel&&f.scrollTop||b.scrollTop)-(f.clientTop||b.clientTop||0),left:d.left+(self.pageXOffset||c.support.boxModel&&f.scrollLeft||b.scrollLeft)-(f.clientLeft||b.clientLeft||0)}}:function(a){var b=
this[0];if(a)return this.each(function(r){c.offset.setOffset(this,a,r)});if(!b||!b.ownerDocument)return null;if(b===b.ownerDocument.body)return c.offset.bodyOffset(b);c.offset.initialize();var d=b.offsetParent,f=b,e=b.ownerDocument,j,i=e.documentElement,o=e.body;f=(e=e.defaultView)?e.getComputedStyle(b,null):b.currentStyle;for(var k=b.offsetTop,n=b.offsetLeft;(b=b.parentNode)&&b!==o&&b!==i;){if(c.offset.supportsFixedPosition&&f.position==="fixed")break;j=e?e.getComputedStyle(b,null):b.currentStyle;
k-=b.scrollTop;n-=b.scrollLeft;if(b===d){k+=b.offsetTop;n+=b.offsetLeft;if(c.offset.doesNotAddBorder&&!(c.offset.doesAddBorderForTableAndCells&&/^t(able|d|h)$/i.test(b.nodeName))){k+=parseFloat(j.borderTopWidth)||0;n+=parseFloat(j.borderLeftWidth)||0}f=d;d=b.offsetParent}if(c.offset.subtractsBorderForOverflowNotVisible&&j.overflow!=="visible"){k+=parseFloat(j.borderTopWidth)||0;n+=parseFloat(j.borderLeftWidth)||0}f=j}if(f.position==="relative"||f.position==="static"){k+=o.offsetTop;n+=o.offsetLeft}if(c.offset.supportsFixedPosition&&
f.position==="fixed"){k+=Math.max(i.scrollTop,o.scrollTop);n+=Math.max(i.scrollLeft,o.scrollLeft)}return{top:k,left:n}};c.offset={initialize:function(){var a=s.body,b=s.createElement("div"),d,f,e,j=parseFloat(c.curCSS(a,"marginTop",true))||0;c.extend(b.style,{position:"absolute",top:0,left:0,margin:0,border:0,width:"1px",height:"1px",visibility:"hidden"});b.innerHTML="<div style='position:absolute;top:0;left:0;margin:0;border:5px solid #000;padding:0;width:1px;height:1px;'><div></div></div><table style='position:absolute;top:0;left:0;margin:0;border:5px solid #000;padding:0;width:1px;height:1px;' cellpadding='0' cellspacing='0'><tr><td></td></tr></table>";
a.insertBefore(b,a.firstChild);d=b.firstChild;f=d.firstChild;e=d.nextSibling.firstChild.firstChild;this.doesNotAddBorder=f.offsetTop!==5;this.doesAddBorderForTableAndCells=e.offsetTop===5;f.style.position="fixed";f.style.top="20px";this.supportsFixedPosition=f.offsetTop===20||f.offsetTop===15;f.style.position=f.style.top="";d.style.overflow="hidden";d.style.position="relative";this.subtractsBorderForOverflowNotVisible=f.offsetTop===-5;this.doesNotIncludeMarginInBodyOffset=a.offsetTop!==j;a.removeChild(b);
c.offset.initialize=c.noop},bodyOffset:function(a){var b=a.offsetTop,d=a.offsetLeft;c.offset.initialize();if(c.offset.doesNotIncludeMarginInBodyOffset){b+=parseFloat(c.curCSS(a,"marginTop",true))||0;d+=parseFloat(c.curCSS(a,"marginLeft",true))||0}return{top:b,left:d}},setOffset:function(a,b,d){if(/static/.test(c.curCSS(a,"position")))a.style.position="relative";var f=c(a),e=f.offset(),j=parseInt(c.curCSS(a,"top",true),10)||0,i=parseInt(c.curCSS(a,"left",true),10)||0;if(c.isFunction(b))b=b.call(a,
d,e);d={top:b.top-e.top+j,left:b.left-e.left+i};"using"in b?b.using.call(a,d):f.css(d)}};c.fn.extend({position:function(){if(!this[0])return null;var a=this[0],b=this.offsetParent(),d=this.offset(),f=/^body|html$/i.test(b[0].nodeName)?{top:0,left:0}:b.offset();d.top-=parseFloat(c.curCSS(a,"marginTop",true))||0;d.left-=parseFloat(c.curCSS(a,"marginLeft",true))||0;f.top+=parseFloat(c.curCSS(b[0],"borderTopWidth",true))||0;f.left+=parseFloat(c.curCSS(b[0],"borderLeftWidth",true))||0;return{top:d.top-
f.top,left:d.left-f.left}},offsetParent:function(){return this.map(function(){for(var a=this.offsetParent||s.body;a&&!/^body|html$/i.test(a.nodeName)&&c.css(a,"position")==="static";)a=a.offsetParent;return a})}});c.each(["Left","Top"],function(a,b){var d="scroll"+b;c.fn[d]=function(f){var e=this[0],j;if(!e)return null;if(f!==w)return this.each(function(){if(j=wa(this))j.scrollTo(!a?f:c(j).scrollLeft(),a?f:c(j).scrollTop());else this[d]=f});else return(j=wa(e))?"pageXOffset"in j?j[a?"pageYOffset":
"pageXOffset"]:c.support.boxModel&&j.document.documentElement[d]||j.document.body[d]:e[d]}});c.each(["Height","Width"],function(a,b){var d=b.toLowerCase();c.fn["inner"+b]=function(){return this[0]?c.css(this[0],d,false,"padding"):null};c.fn["outer"+b]=function(f){return this[0]?c.css(this[0],d,false,f?"margin":"border"):null};c.fn[d]=function(f){var e=this[0];if(!e)return f==null?null:this;if(c.isFunction(f))return this.each(function(j){var i=c(this);i[d](f.call(this,j,i[d]()))});return"scrollTo"in
e&&e.document?e.document.compatMode==="CSS1Compat"&&e.document.documentElement["client"+b]||e.document.body["client"+b]:e.nodeType===9?Math.max(e.documentElement["client"+b],e.body["scroll"+b],e.documentElement["scroll"+b],e.body["offset"+b],e.documentElement["offset"+b]):f===w?c.css(e,d):this.css(d,typeof f==="string"?f:f+"px")}});A.jQuery=A.$=c})(window);
/*
 * jQuery JSON Plugin
 * version: 2.1 (2009-08-14)
 *
 * This document is licensed as free software under the terms of the
 * MIT License: http://www.opensource.org/licenses/mit-license.php
 *
 * Brantley Harris wrote this plugin. It is based somewhat on the JSON.org 
 * website's http://www.json.org/json2.js, which proclaims:
 * "NO WARRANTY EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.", a sentiment that
 * I uphold.
 *
 * It is also influenced heavily by MochiKit's serializeJSON, which is 
 * copyrighted 2005 by Bob Ippolito.
 */
 
(function($) {
    /** jQuery.toJSON( json-serializble )
        Converts the given argument into a JSON respresentation.

        If an object has a "toJSON" function, that will be used to get the representation.
        Non-integer/string keys are skipped in the object, as are keys that point to a function.

        json-serializble:
            The *thing* to be converted.
     **/
    $.toJSON = function(o)
    {
        if (typeof(JSON) == 'object' && JSON.stringify)
            return JSON.stringify(o);
        
        var type = typeof(o);
    
        if (o === null)
            return "null";
    
        if (type == "undefined")
            return undefined;
        
        if (type == "number" || type == "boolean")
            return o + "";
    
        if (type == "string")
            return $.quoteString(o);
    
        if (type == 'object')
        {
            if (typeof o.toJSON == "function") 
                return $.toJSON( o.toJSON() );
            
            if (o.constructor === Date)
            {
                var month = o.getUTCMonth() + 1;
                if (month < 10) month = '0' + month;

                var day = o.getUTCDate();
                if (day < 10) day = '0' + day;

                var year = o.getUTCFullYear();
                
                var hours = o.getUTCHours();
                if (hours < 10) hours = '0' + hours;
                
                var minutes = o.getUTCMinutes();
                if (minutes < 10) minutes = '0' + minutes;
                
                var seconds = o.getUTCSeconds();
                if (seconds < 10) seconds = '0' + seconds;
                
                var milli = o.getUTCMilliseconds();
                if (milli < 100) milli = '0' + milli;
                if (milli < 10) milli = '0' + milli;

                return '"' + year + '-' + month + '-' + day + 'T' +
                             hours + ':' + minutes + ':' + seconds + 
                             '.' + milli + 'Z"'; 
            }

            if (o.constructor === Array) 
            {
                var ret = [];
                for (var i = 0; i < o.length; i++)
                    ret.push( $.toJSON(o[i]) || "null" );

                return "[" + ret.join(",") + "]";
            }
        
            var pairs = [];
            for (var k in o) {
                var name;
                var type = typeof k;

                if (type == "number")
                    name = '"' + k + '"';
                else if (type == "string")
                    name = $.quoteString(k);
                else
                    continue;  //skip non-string or number keys
            
                if (typeof o[k] == "function") 
                    continue;  //skip pairs where the value is a function.
            
                var val = $.toJSON(o[k]);
            
                pairs.push(name + ":" + val);
            }

            return "{" + pairs.join(", ") + "}";
        }
    };

    /** jQuery.evalJSON(src)
        Evaluates a given piece of json source.
     **/
    $.evalJSON = function(src)
    {
        if (typeof(JSON) == 'object' && JSON.parse)
            return JSON.parse(src);
        return eval("(" + src + ")");
    };
    
    /** jQuery.secureEvalJSON(src)
        Evals JSON in a way that is *more* secure.
    **/
    $.secureEvalJSON = function(src)
    {
        if (typeof(JSON) == 'object' && JSON.parse)
            return JSON.parse(src);
        
        var filtered = src;
        filtered = filtered.replace(/\\["\\\/bfnrtu]/g, '@');
        filtered = filtered.replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, ']');
        filtered = filtered.replace(/(?:^|:|,)(?:\s*\[)+/g, '');
        
        if (/^[\],:{}\s]*$/.test(filtered))
            return eval("(" + src + ")");
        else
            throw new SyntaxError("Error parsing JSON, source is not valid.");
    };

    /** jQuery.quoteString(string)
        Returns a string-repr of a string, escaping quotes intelligently.  
        Mostly a support function for toJSON.
    
        Examples:
            >>> jQuery.quoteString("apple")
            "apple"
        
            >>> jQuery.quoteString('"Where are we going?", she asked.')
            "\"Where are we going?\", she asked."
     **/
    $.quoteString = function(string)
    {
        if (string.match(_escapeable))
        {
            return '"' + string.replace(_escapeable, function (a) 
            {
                var c = _meta[a];
                if (typeof c === 'string') return c;
                c = a.charCodeAt();
                return '\\u00' + Math.floor(c / 16).toString(16) + (c % 16).toString(16);
            }) + '"';
        }
        return '"' + string + '"';
    };
    
    var _escapeable = /["\\\x00-\x1f\x7f-\x9f]/g;
    
    var _meta = {
        '\b': '\\b',
        '\t': '\\t',
        '\n': '\\n',
        '\f': '\\f',
        '\r': '\\r',
        '"' : '\\"',
        '\\': '\\\\'
    };
})(jQuery);
/*
 * @name BeautyTips
 * @desc a tooltips/baloon-help plugin for jQuery
 *
 * @author Jeff Robbins - Lullabot - http://www.lullabot.com
 * @version 0.9.5 release candidate 1  (5/20/2009)
 */

jQuery.bt = {version: '0.9.5-rc1'};

/*
 * @type jQuery
 * @cat Plugins/bt
 * @requires jQuery v1.2+ (not tested on versions prior to 1.2.6)
 *
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 *
 * Encourage development. If you use BeautyTips for anything cool
 * or on a site that people have heard of, please drop me a note.
 * - jeff ^at lullabot > com
 *
 * No guarantees, warranties, or promises of any kind
 *
 */

;(function($) {
  /**
   * @credit Inspired by Karl Swedberg's ClueTip
   *    (http://plugins.learningjquery.com/cluetip/), which in turn was inspired
   *    by Cody Lindley's jTip (http://www.codylindley.com)
   *
   * @fileoverview
   * Beauty Tips is a jQuery tooltips plugin which uses the canvas drawing element
   * in the HTML5 spec in order to dynamically draw tooltip "talk bubbles" around
   * the descriptive help text associated with an item. This is in many ways
   * similar to Google Maps which both provides similar talk-bubbles and uses the
   * canvas element to draw them.
   *
   * The canvas element is supported in modern versions of FireFox, Safari, and
   * Opera. However, Internet Explorer needs a separate library called ExplorerCanvas
   * included on the page in order to support canvas drawing functions. ExplorerCanvas
   * was created by Google for use with their web apps and you can find it here:
   * http://excanvas.sourceforge.net/
   *
   * Beauty Tips was written to be simple to use and pretty. All of its options
   * are documented at the bottom of this file and defaults can be overwritten
   * globally for the entire page, or individually on each call.
   *
   * By default each tooltip will be positioned on the side of the target element
   * which has the most free space. This is affected by the scroll position and
   * size of the current window, so each Beauty Tip is redrawn each time it is
   * displayed. It may appear above an element at the bottom of the page, but when
   * the page is scrolled down (and the element is at the top of the page) it will
   * then appear below it. Additionally, positions can be forced or a preferred
   * order can be defined. See examples below.
   *
   * To fix z-index problems in IE6, include the bgiframe plugin on your page
   * http://plugins.jquery.com/project/bgiframe - BeautyTips will automatically
   * recognize it and use it.
   *
   * BeautyTips also works with the hoverIntent plugin
   * http://cherne.net/brian/resources/jquery.hoverIntent.html
   * see hoverIntent example below for usage
   *
   * Usage
   * The function can be called in a number of ways.
   * $(selector).bt();
   * $(selector).bt('Content text');
   * $(selector).bt('Content text', {option1: value, option2: value});
   * $(selector).bt({option1: value, option2: value});
   *
   * For more/better documentation and lots of examples, visit the demo page included with the distribution
   *
   */
  
  // Addition: touchclick event, to detect taps instead of clicks
    var timeout = 0, timedout = false;
    jQuery.event.special.touchclick = {
        setup: function (data, namespaces) {
            var elem = this, $elem = jQuery(elem);
            if (window.Touch) {
                $elem.bind('touchstart', jQuery.event.special.touchclick.onTouchStart);
                $elem.bind('touchmove', jQuery.event.special.touchclick.onTouchMove);
                $elem.bind('touchend', jQuery.event.special.touchclick.onTouchEnd);
            } else {
                $elem.bind('click', jQuery.event.special.touchclick.click);
            }
        },
        
        click: function (event) {
            event.type = "touchclick";
            jQuery.event.handle.apply(this, arguments);
        },
        
        teardown: function (namespaces) {
            var elem = this, $elem = jQuery(elem);
            $elem.unbind('touchstart', jQuery.event.special.touchclick.onTouchStart);
            $elem.unbind('touchmove', jQuery.event.special.touchclick.onTouchMove);
            $elem.unbind('touchend', jQuery.event.special.touchclick.onTouchEnd);
        },
        
        onTouchStart: function (e) {
            this.moved = false;
            timedout = false;
            timeout = setTimeout(function() {
                       timedout = true;
                }, 500);
            $(this).addClass('touchactive');
        },
        
        onTouchMove: function (e) {
            this.moved = true;
            clearTimeout(timeout);
            $(this).removeClass('touchactive');
        },
        
        onTouchEnd: function (event) {
            if (!this.moved && !timedout) {
                event.type = "touchclick";
                jQuery.event.handle.apply(this, arguments)
            }
            clearTimeout(timeout);
            timedout = false;
            $(this).removeClass('touchactive');
        }
    };
  
  jQuery.fn.bt = function(content, options) {

    if (typeof content != 'string') {
      var contentSelect = true;
      options = content;
      content = false;
    }
    else {
      var contentSelect = false;
    }

    // if hoverIntent is installed, use that as default instead of hover
    if (jQuery.fn.hoverIntent && jQuery.bt.defaults.trigger == 'hover') {
      jQuery.bt.defaults.trigger = 'hoverIntent';
    }

    return this.each(function(index) {

      var opts = jQuery.extend(false, jQuery.bt.defaults, jQuery.bt.options, options);

      // clean up the options
      opts.spikeLength = numb(opts.spikeLength);
      opts.spikeGirth = numb(opts.spikeGirth);
      opts.overlap = numb(opts.overlap);

      var ajaxTimeout = false;

      /**
       * This is sort of the "starting spot" for the this.each()
       * These are the init functions to handle the .bt() call
       */

      if (opts.killTitle) {
        $(this).find('[title]').andSelf().each(function() {
          if (!$(this).attr('bt-xTitle')) {
            $(this).attr('bt-xTitle', $(this).attr('title')).attr('title', '');
          }
        });
      }

      if (typeof opts.trigger == 'string') {
        opts.trigger = [opts.trigger];
      }
      if (opts.trigger[0] == 'hoverIntent') {
        var hoverOpts = jQuery.extend(opts.hoverIntentOpts, {
          over: function() {
            this.btOn();
          },
          out: function() {
            this.btOff();
          }});
        $(this).hoverIntent(hoverOpts);

      }
      else if (opts.trigger[0] == 'hover') {
        $(this).hover(
          function() {
            this.btOn();
          },
          function() {
            this.btOff();
          }
        );
      }
      else if (opts.trigger[0] == 'now') {
        // toggle the on/off right now
        // note that 'none' gives more control (see below)
        if ($(this).hasClass('bt-active')) {
          this.btOff();
        }
        else {
          this.btOn();
        }
      }
      else if (opts.trigger[0] == 'none') {
        // initialize the tip with no event trigger
        // use javascript to turn on/off tip as follows:
        // $('#selector').btOn();
        // $('#selector').btOff();
      }
      else if (opts.trigger.length > 1 && opts.trigger[0] != opts.trigger[1]) {
        $(this)
          .bind(opts.trigger[0], function() {
            this.btOn();
          })
          .bind(opts.trigger[1], function() {
            this.btOff();
          });
      }
      else {
        // toggle using the same event
        $(this).bind(opts.trigger[0], function() {
          if ($(this).hasClass('bt-active')) {
            this.btOff();
          }
          else {
            this.btOn();
          }
        });
      }


      /**
       *  The BIG TURN ON
       *  Any element that has been initiated
       */
      this.btOn = function () {
        if (typeof $(this).data('bt-box') == 'object') {
          // if there's already a popup, remove it before creating a new one.
          this.btOff();
        }

        // trigger preBuild function
        // preBuild has no argument since the box hasn't been built yet
        opts.preBuild.apply(this);

        // turn off other tips
        $(jQuery.bt.vars.closeWhenOpenStack).btOff();

        // add the class to the target element (for hilighting, for example)
        // bt-active is always applied to all, but activeClass can apply another
        $(this).addClass('bt-active ' + opts.activeClass);

        if (contentSelect && opts.ajaxPath == null) {
          // bizarre, I know
          if (opts.killTitle) {
            // if we've killed the title attribute, it's been stored in 'bt-xTitle' so get it..
            $(this).attr('title', $(this).attr('bt-xTitle'));
          }
          // then evaluate the selector... title is now in place
          content = $.isFunction(opts.contentSelector) ? opts.contentSelector.apply(this) : eval(opts.contentSelector);
          if (opts.killTitle) {
            // now remove the title again, so we don't get double tips
            $(this).attr('title', '');
          }
        }

        // ----------------------------------------------
        // All the Ajax(ish) stuff is in this next bit...
        // ----------------------------------------------
        if (opts.ajaxPath != null && content == false) {
          if (typeof opts.ajaxPath == 'object') {
            var url = eval(opts.ajaxPath[0]);
            url += opts.ajaxPath[1] ? ' ' + opts.ajaxPath[1] : '';
          }
          else {
            var url = opts.ajaxPath;
          }
          var off = url.indexOf(" ");
          if ( off >= 0 ) {
            var selector = url.slice(off, url.length);
            url = url.slice(0, off);
          }

          // load any data cached for the given ajax path
          var cacheData = opts.ajaxCache ? $(document.body).data('btCache-' + url.replace(/\./g, '')) : null;
          if (typeof cacheData == 'string') {
            content = selector ? $("<div/>").append(cacheData.replace(/<script(.|\s)*?\/script>/g, "")).find(selector) : cacheData;
          }
          else {
            var target = this;

            // set up the options
            var ajaxOpts = jQuery.extend(false,
            {
              type: opts.ajaxType,
              data: opts.ajaxData,
              cache: opts.ajaxCache,
              url: url,
              complete: function(XMLHttpRequest, textStatus) {
                if (textStatus == 'success' || textStatus == 'notmodified') {
                  if (opts.ajaxCache) {
                    $(document.body).data('btCache-' + url.replace(/\./g, ''), XMLHttpRequest.responseText);
                  }
                  ajaxTimeout = false;
                  content = selector ?
                    // Create a dummy div to hold the results
                    $("<div/>")
                      // inject the contents of the document in, removing the scripts
                      // to avoid any 'Permission Denied' errors in IE
                      .append(XMLHttpRequest.responseText.replace(/<script(.|\s)*?\/script>/g, ""))

                      // Locate the specified elements
                      .find(selector) :

                    // If not, just inject the full result
                    XMLHttpRequest.responseText;

                }
                else {
                  if (textStatus == 'timeout') {
                    // if there was a timeout, we don't cache the result
                    ajaxTimeout = true;
                  }
                  content = opts.ajaxError.replace(/%error/g, XMLHttpRequest.statusText);
                }
                // if the user rolls out of the target element before the ajax request comes back, don't show it
                if ($(target).hasClass('bt-active')) {
                  target.btOn();
                }
              }
            }, opts.ajaxOpts);
            // do the ajax request
            jQuery.ajax(ajaxOpts);
            // load the throbber while the magic happens
            content = opts.ajaxLoading;
          }
        }
        // </ ajax stuff >


        // now we start actually figuring out where to place the tip

        // figure out how to compensate for the shadow, if present
        var shadowMarginX = 0; // extra added to width to compensate for shadow
        var shadowMarginY = 0; // extra added to height
        var shadowShiftX = 0;  // amount to shift the tip horizontally to allow for shadow
        var shadowShiftY = 0;  // amount to shift vertical

        if (opts.shadow && !shadowSupport()) {
          // if browser doesn't support drop shadows, turn them off
          opts.shadow = false;
          // and bring in the noShadows options
          jQuery.extend(opts, opts.noShadowOpts);
        }

        if (opts.shadow) {
          // figure out horizontal placement
          if (opts.shadowBlur > Math.abs(opts.shadowOffsetX)) {
            shadowMarginX = opts.shadowBlur * 2;
          }
          else {
            shadowMarginX = opts.shadowBlur + Math.abs(opts.shadowOffsetX);
          }
          shadowShiftX = (opts.shadowBlur - opts.shadowOffsetX) > 0 ? opts.shadowBlur - opts.shadowOffsetX : 0;

          // now vertical
          if (opts.shadowBlur > Math.abs(opts.shadowOffsetY)) {
            shadowMarginY = opts.shadowBlur * 2;
          }
          else {
            shadowMarginY = opts.shadowBlur + Math.abs(opts.shadowOffsetY);
          }
          shadowShiftY = (opts.shadowBlur - opts.shadowOffsetY) > 0 ? opts.shadowBlur - opts.shadowOffsetY : 0;
        }

        if (opts.offsetParent){
          // if offsetParent is defined by user
          var offsetParent = $(opts.offsetParent);
          var offsetParentPos = offsetParent.offset();
          var pos = $(this).offset();
          var top = numb(pos.top) - numb(offsetParentPos.top) + numb($(this).css('margin-top')) - shadowShiftY; // IE can return 'auto' for margins
          var left = numb(pos.left) - numb(offsetParentPos.left) + numb($(this).css('margin-left')) - shadowShiftX;
        }
        else {
          // if the target element is absolutely positioned, use its parent's offsetParent instead of its own
          var offsetParent = ($(this).css('position') == 'absolute') ? $(this).parents().eq(0).offsetParent() : $(this).offsetParent();
          var pos = $(this).btPosition();
          var top = numb(pos.top) + numb($(this).css('margin-top')) - shadowShiftY; // IE can return 'auto' for margins
          var left = numb(pos.left) + numb($(this).css('margin-left')) - shadowShiftX;
        }

        var width = $(this).btOuterWidth();
        var height = $(this).outerHeight();

        if (typeof content == 'object') {
          // if content is a DOM object (as opposed to text)
          // use a clone, rather than removing the original element
          // and ensure that it's visible
          var original = content;
          var clone = $(original).clone(true).show();
          // also store a reference to the original object in the clone data
          // and a reference to the clone in the original
          var origClones = $(original).data('bt-clones') || [];
          origClones.push(clone);
          $(original).data('bt-clones', origClones);
          $(clone).data('bt-orig', original);
          $(this).data('bt-content-orig', {original: original, clone: clone});
          content = clone;
        }
        if (typeof content == 'null' || content == '') {
          // if content is empty, bail out...
          return;
        }

        // create the tip content div, populate it, and style it
        var $text = $('<div class="bt-content"></div>').append(content).css({padding: opts.padding, position: 'absolute', width: (opts.shrinkToFit ? 'auto' : opts.width), zIndex: opts.textzIndex, left: shadowShiftX, top: shadowShiftY}).css(opts.cssStyles);
        // create the wrapping box which contains text and canvas
        // put the content in it, style it, and append it to the same offset parent as the target
        var $box = $('<div class="bt-wrapper"></div>').append($text).addClass(opts.cssClass).css({position: 'absolute', width: opts.width, zIndex: opts.wrapperzIndex, visibility:'hidden'}).appendTo(offsetParent);

        // use bgiframe to get around z-index problems in IE6
        // http://plugins.jquery.com/project/bgiframe
        if (jQuery.fn.bgiframe) {
          $text.bgiframe();
          $box.bgiframe();
        }

        if ($box.length) {
          opts.preSizeCalculation.apply(this, [$box[0]]);
        }

        $(this).data('bt-box', $box);

        // see if the text box will fit in the various positions
        var scrollTop = numb($(document).scrollTop());
        var scrollLeft = numb($(document).scrollLeft());
        var docWidth = numb($(window).width());
        var docHeight = numb($(window).height());
        var winRight = scrollLeft + docWidth;
        var winBottom = scrollTop + docHeight;
        var space = new Object();
        var thisOffset = $(this).offset();
        space.top = thisOffset.top - scrollTop;
        space.bottom = docHeight - ((thisOffset + height) - scrollTop);
        space.left = thisOffset.left - scrollLeft;
        space.right = docWidth - ((thisOffset.left + width) - scrollLeft);
        var textOutHeight = numb($text.outerHeight());
        var textOutWidth = numb($text.btOuterWidth());
        if (opts.positions.constructor == String) {
          opts.positions = opts.positions.replace(/ /, '').split(',');
        }
        if (opts.positions[0] == 'most') {
          // figure out which is the largest
          var position = 'top'; // prime the pump
          for (var pig in space) {  //            <-------  pigs in space!
            position = space[pig] > space[position] ? pig : position;
          }
        }
        else {
          for (var x in opts.positions) {
            var position = opts.positions[x];
            // @todo: acommodate shadow space in the following lines...
            if ((position == 'left' || position == 'right') && space[position] > textOutWidth + opts.spikeLength) {
              break;
            }
            else if ((position == 'top' || position == 'bottom') && space[position] > textOutHeight + opts.spikeLength) {
              break;
            }
          }
        }

        // horizontal (left) offset for the box
        var horiz = left + ((width - textOutWidth) * .5);
        // vertical (top) offset for the box
        var vert = top + ((height - textOutHeight) * .5);
        var points = new Array();
        var textTop, textLeft, textRight, textBottom, textTopSpace, textBottomSpace, textLeftSpace, textRightSpace, crossPoint, textCenter, spikePoint;

        // Yes, yes, this next bit really could use to be condensed
        // each switch case is basically doing the same thing in slightly different ways
        switch(position) {

          // =================== TOP =======================
          case 'top':
            // spike on bottom
            $text.css('margin-bottom', opts.spikeLength + 'px');
            $box.css({top: (top - $text.outerHeight(true)) + opts.overlap, left: horiz});
            // move text left/right if extends out of window
            textRightSpace = (winRight - opts.windowMargin) - ($text.offset().left + $text.btOuterWidth(true));
            var xShift = shadowShiftX;
            if (textRightSpace < 0) {
              // shift it left
              $box.css('left', (numb($box.css('left')) + textRightSpace) + 'px');
              xShift -= textRightSpace;
            }
            // we test left space second to ensure that left of box is visible
            textLeftSpace = ($text.offset().left + numb($text.css('margin-left'))) - (scrollLeft + opts.windowMargin);
            if (textLeftSpace < 0) {
              // shift it right
              $box.css('left', (numb($box.css('left')) - textLeftSpace) + 'px');
              xShift += textLeftSpace;
            }
            textTop = $text.btPosition().top + numb($text.css('margin-top'));
            textLeft = $text.btPosition().left + numb($text.css('margin-left'));
            textRight = textLeft + $text.btOuterWidth();
            textBottom = textTop + $text.outerHeight();
            textCenter = {x: textLeft + ($text.btOuterWidth()*opts.centerPointX), y: textTop + ($text.outerHeight()*opts.centerPointY)};
            // points[points.length] = {x: x, y: y};
            points[points.length] = spikePoint = {y: textBottom + opts.spikeLength, x: ((textRight-textLeft) * .5) + xShift, type: 'spike'};
            crossPoint = findIntersectX(spikePoint.x, spikePoint.y, textCenter.x, textCenter.y, textBottom);
            // make sure that the crossPoint is not outside of text box boundaries
            crossPoint.x = crossPoint.x < textLeft + opts.spikeGirth/2 + opts.cornerRadius ? textLeft + opts.spikeGirth/2 + opts.cornerRadius : crossPoint.x;
            crossPoint.x =  crossPoint.x > (textRight - opts.spikeGirth/2) - opts.cornerRadius ? (textRight - opts.spikeGirth/2) - opts.CornerRadius : crossPoint.x;
            points[points.length] = {x: crossPoint.x - (opts.spikeGirth/2), y: textBottom, type: 'join'};
            points[points.length] = {x: textLeft, y: textBottom, type: 'corner'};  // left bottom corner
            points[points.length] = {x: textLeft, y: textTop, type: 'corner'};     // left top corner
            points[points.length] = {x: textRight, y: textTop, type: 'corner'};    // right top corner
            points[points.length] = {x: textRight, y: textBottom, type: 'corner'}; // right bottom corner
            points[points.length] = {x: crossPoint.x + (opts.spikeGirth/2), y: textBottom, type: 'join'};
            points[points.length] = spikePoint;
            break;

          // =================== LEFT =======================
          case 'left':
            // spike on right
            $text.css('margin-right', opts.spikeLength + 'px');
            $box.css({top: vert + 'px', left: ((left - $text.btOuterWidth(true)) + opts.overlap) + 'px'});
            // move text up/down if extends out of window
            textBottomSpace = (winBottom - opts.windowMargin) - ($text.offset().top + $text.outerHeight(true));
            var yShift = shadowShiftY;
            if (textBottomSpace < 0) {
              // shift it up
              $box.css('top', (numb($box.css('top')) + textBottomSpace) + 'px');
              yShift -= textBottomSpace;
            }
            // we ensure top space second to ensure that top of box is visible
            textTopSpace = ($text.offset().top + numb($text.css('margin-top'))) - (scrollTop + opts.windowMargin);
            if (textTopSpace < 0) {
              // shift it down
              $box.css('top', (numb($box.css('top')) - textTopSpace) + 'px');
              yShift += textTopSpace;
            }
            textTop = $text.btPosition().top + numb($text.css('margin-top'));
            textLeft = $text.btPosition().left + numb($text.css('margin-left'));
            textRight = textLeft + $text.btOuterWidth();
            textBottom = textTop + $text.outerHeight();
            textCenter = {x: textLeft + ($text.btOuterWidth()*opts.centerPointX), y: textTop + ($text.outerHeight()*opts.centerPointY)};
            points[points.length] = spikePoint = {x: textRight + opts.spikeLength, y: ((textBottom-textTop) * .5) + yShift, type: 'spike'};
            crossPoint = findIntersectY(spikePoint.x, spikePoint.y, textCenter.x, textCenter.y, textRight);
            // make sure that the crossPoint is not outside of text box boundaries
            crossPoint.y = crossPoint.y < textTop + opts.spikeGirth/2 + opts.cornerRadius ? textTop + opts.spikeGirth/2 + opts.cornerRadius : crossPoint.y;
            crossPoint.y =  crossPoint.y > (textBottom - opts.spikeGirth/2) - opts.cornerRadius ? (textBottom - opts.spikeGirth/2) - opts.cornerRadius : crossPoint.y;
            points[points.length] = {x: textRight, y: crossPoint.y + opts.spikeGirth/2, type: 'join'};
            points[points.length] = {x: textRight, y: textBottom, type: 'corner'}; // right bottom corner
            points[points.length] = {x: textLeft, y: textBottom, type: 'corner'};  // left bottom corner
            points[points.length] = {x: textLeft, y: textTop, type: 'corner'};     // left top corner
            points[points.length] = {x: textRight, y: textTop, type: 'corner'};    // right top corner
            points[points.length] = {x: textRight, y: crossPoint.y - opts.spikeGirth/2, type: 'join'};
            points[points.length] = spikePoint;
            break;

          // =================== BOTTOM =======================
          case 'bottom':
            // spike on top
            $text.css('margin-top', opts.spikeLength + 'px');
            $box.css({top: (top + height) - opts.overlap, left: horiz});
            // move text up/down if extends out of window
            textRightSpace = (winRight - opts.windowMargin) - ($text.offset().left + $text.btOuterWidth(true));
            var xShift = shadowShiftX;
            if (textRightSpace < 0) {
              // shift it left
              $box.css('left', (numb($box.css('left')) + textRightSpace) + 'px');
              xShift -= textRightSpace;
            }
            // we ensure left space second to ensure that left of box is visible
            textLeftSpace = ($text.offset().left + numb($text.css('margin-left')))  - (scrollLeft + opts.windowMargin);
            if (textLeftSpace < 0) {
              // shift it right
              $box.css('left', (numb($box.css('left')) - textLeftSpace) + 'px');
              xShift += textLeftSpace;
            }
            textTop = $text.btPosition().top + numb($text.css('margin-top'));
            textLeft = $text.btPosition().left + numb($text.css('margin-left'));
            textRight = textLeft + $text.btOuterWidth();
            textBottom = textTop + $text.outerHeight();
            textCenter = {x: textLeft + ($text.btOuterWidth()*opts.centerPointX), y: textTop + ($text.outerHeight()*opts.centerPointY)};
            points[points.length] = spikePoint = {x: ((textRight-textLeft) * .5) + xShift, y: shadowShiftY, type: 'spike'};
            crossPoint = findIntersectX(spikePoint.x, spikePoint.y, textCenter.x, textCenter.y, textTop);
            // make sure that the crossPoint is not outside of text box boundaries
            crossPoint.x = crossPoint.x < textLeft + opts.spikeGirth/2 + opts.cornerRadius ? textLeft + opts.spikeGirth/2 + opts.cornerRadius : crossPoint.x;
            crossPoint.x =  crossPoint.x > (textRight - opts.spikeGirth/2) - opts.cornerRadius ? (textRight - opts.spikeGirth/2) - opts.cornerRadius : crossPoint.x;
            points[points.length] = {x: crossPoint.x + opts.spikeGirth/2, y: textTop, type: 'join'};
            points[points.length] = {x: textRight, y: textTop, type: 'corner'};    // right top corner
            points[points.length] = {x: textRight, y: textBottom, type: 'corner'}; // right bottom corner
            points[points.length] = {x: textLeft, y: textBottom, type: 'corner'};  // left bottom corner
            points[points.length] = {x: textLeft, y: textTop, type: 'corner'};     // left top corner
            points[points.length] = {x: crossPoint.x - (opts.spikeGirth/2), y: textTop, type: 'join'};
            points[points.length] = spikePoint;
            break;

          // =================== RIGHT =======================
          case 'right':
            // spike on left
            $text.css('margin-left', (opts.spikeLength + 'px'));
            $box.css({top: vert + 'px', left: ((left + width) - opts.overlap) + 'px'});
            // move text up/down if extends out of window
            textBottomSpace = (winBottom - opts.windowMargin) - ($text.offset().top + $text.outerHeight(true));
            var yShift = shadowShiftY;
            if (textBottomSpace < 0) {
              // shift it up
              $box.css('top', (numb($box.css('top')) + textBottomSpace) + 'px');
              yShift -= textBottomSpace;
            }
            // we ensure top space second to ensure that top of box is visible
            textTopSpace = ($text.offset().top + numb($text.css('margin-top'))) - (scrollTop + opts.windowMargin);
            if (textTopSpace < 0) {
              // shift it down
              $box.css('top', (numb($box.css('top')) - textTopSpace) + 'px');
              yShift += textTopSpace;
            }
            textTop = $text.btPosition().top + numb($text.css('margin-top'));
            textLeft = $text.btPosition().left + numb($text.css('margin-left'));
            textRight = textLeft + $text.btOuterWidth();
            textBottom = textTop + $text.outerHeight();
            textCenter = {x: textLeft + ($text.btOuterWidth()*opts.centerPointX), y: textTop + ($text.outerHeight()*opts.centerPointY)};
            points[points.length] = spikePoint = {x: shadowShiftX, y: ((textBottom-textTop) * .5) + yShift, type: 'spike'};
            crossPoint = findIntersectY(spikePoint.x, spikePoint.y, textCenter.x, textCenter.y, textLeft);
            // make sure that the crossPoint is not outside of text box boundaries
            crossPoint.y = crossPoint.y < textTop + opts.spikeGirth/2 + opts.cornerRadius ? textTop + opts.spikeGirth/2 + opts.cornerRadius : crossPoint.y;
            crossPoint.y =  crossPoint.y > (textBottom - opts.spikeGirth/2) - opts.cornerRadius ? (textBottom - opts.spikeGirth/2) - opts.cornerRadius : crossPoint.y;
            points[points.length] = {x: textLeft, y: crossPoint.y - opts.spikeGirth/2, type: 'join'};
            points[points.length] = {x: textLeft, y: textTop, type: 'corner'};     // left top corner
            points[points.length] = {x: textRight, y: textTop, type: 'corner'};    // right top corner
            points[points.length] = {x: textRight, y: textBottom, type: 'corner'}; // right bottom corner
            points[points.length] = {x: textLeft, y: textBottom, type: 'corner'};  // left bottom corner
            points[points.length] = {x: textLeft, y: crossPoint.y + opts.spikeGirth/2, type: 'join'};
            points[points.length] = spikePoint;
            break;
        } // </ switch >

        var canvas = document.createElement('canvas');
        $(canvas).attr('width', (numb($text.btOuterWidth(true)) + opts.strokeWidth*2 + shadowMarginX)).attr('height', (numb($text.outerHeight(true)) + opts.strokeWidth*2 + shadowMarginY)).appendTo($box).css({position: 'absolute', zIndex: opts.boxzIndex});


        // if excanvas is set up, we need to initialize the new canvas element
        if (typeof G_vmlCanvasManager != 'undefined') {
          canvas = G_vmlCanvasManager.initElement(canvas);
        }

        if (opts.cornerRadius > 0) {
          // round the corners!
          var newPoints = new Array();
          var newPoint;
          for (var i=0; i<points.length; i++) {
            if (points[i].type == 'corner') {
              // create two new arc points
              // find point between this and previous (using modulo in case of ending)
              newPoint = betweenPoint(points[i], points[(i-1)%points.length], opts.cornerRadius);
              newPoint.type = 'arcStart';
              newPoints[newPoints.length] = newPoint;
              // the original corner point
              newPoints[newPoints.length] = points[i];
              // find point between this and next
              newPoint = betweenPoint(points[i], points[(i+1)%points.length], opts.cornerRadius);
              newPoint.type = 'arcEnd';
              newPoints[newPoints.length] = newPoint;
            }
            else {
              newPoints[newPoints.length] = points[i];
            }
          }
          // overwrite points with new version
          points = newPoints;
        }

        var ctx = canvas.getContext("2d");
                     
        // adjust our drawing for retina displays (devicePixelRatio > 1)
        if (window.devicePixelRatio) {
             var hidefCanvasWidth = $(canvas).attr('width');
             var hidefCanvasHeight = $(canvas).attr('height');
             var hidefCanvasCssWidth = hidefCanvasWidth;
             var hidefCanvasCssHeight = hidefCanvasHeight;
             
             $(canvas).attr('width', hidefCanvasWidth * window.devicePixelRatio);
             $(canvas).attr('height', hidefCanvasHeight * window.devicePixelRatio);
             $(canvas).css('width', hidefCanvasCssWidth);
             $(canvas).css('height', hidefCanvasCssHeight);
             ctx.scale(window.devicePixelRatio, window.devicePixelRatio);
        }

        if (opts.shadow && opts.shadowOverlap !== true) {

          var shadowOverlap = numb(opts.shadowOverlap);

          // keep the shadow (and canvas) from overlapping the target element
          switch (position) {
            case 'top':
              if (opts.shadowOffsetX + opts.shadowBlur - shadowOverlap > 0) {
                $box.css('top', (numb($box.css('top')) - (opts.shadowOffsetX + opts.shadowBlur - shadowOverlap)));
              }
              break;
            case 'right':
              if (shadowShiftX - shadowOverlap > 0) {
                $box.css('left', (numb($box.css('left')) + shadowShiftX - shadowOverlap));
              }
              break;
            case 'bottom':
              if (shadowShiftY - shadowOverlap > 0) {
                $box.css('top', (numb($box.css('top')) + shadowShiftY - shadowOverlap));
              }
              break;
            case 'left':
              if (opts.shadowOffsetY + opts.shadowBlur - shadowOverlap > 0) {
                $box.css('left', (numb($box.css('left')) - (opts.shadowOffsetY + opts.shadowBlur - shadowOverlap)));
              }
              break;
          }
        }

        drawIt.apply(ctx, [points], opts.strokeWidth);
        ctx.fillStyle = opts.fill;
        if (opts.shadow) {
          ctx.shadowOffsetX = opts.shadowOffsetX;
          ctx.shadowOffsetY = opts.shadowOffsetY;
          ctx.shadowBlur = opts.shadowBlur;
          ctx.shadowColor =  opts.shadowColor;
        }
        ctx.closePath();
        ctx.fill();
        if (opts.strokeWidth > 0) {
          ctx.shadowColor = 'rgba(0, 0, 0, 0)'; //remove shadow from stroke
          ctx.lineWidth = opts.strokeWidth;
          ctx.strokeStyle = opts.strokeStyle;
          ctx.beginPath();
          drawIt.apply(ctx, [points], opts.strokeWidth);
          ctx.closePath();
          ctx.stroke();
        }

        // trigger preShow function
        // function receives the box element (the balloon wrapper div) as an argument
        opts.preShow.apply(this, [$box[0]]);

        // switch from visibility: hidden to display: none so we can run animations
        $box.css({display:'none', visibility: 'visible'});

        // Here's where we show the tip
        opts.showTip.apply(this, [$box[0]]);

        if (opts.overlay) {
          // EXPERIMENTAL AND FOR TESTING ONLY!!!!
          var overlay = $('<div class="bt-overlay"></div>').css({
              position: 'absolute',
              backgroundColor: 'blue',
              top: top,
              left: left,
              width: width,
              height: height,
              opacity: '.2'
            }).appendTo(offsetParent);
          $(this).data('overlay', overlay);
        }

        if ((opts.ajaxPath != null && opts.ajaxCache == false) || ajaxTimeout) {
          // if ajaxCache is not enabled or if there was a server timeout,
          // remove the content variable so it will be loaded again from server
          content = false;
        }

        // stick this element into the clickAnywhereToClose stack
        if (opts.clickAnywhereToClose) {
          jQuery.bt.vars.clickAnywhereStack.push(this);
          //$(document).click(jQuery.bt.docClick);
          $(document).bind('touchclick', jQuery.bt.docClick);
        }

        // stick this element into the closeWhenOthersOpen stack
        if (opts.closeWhenOthersOpen) {
          jQuery.bt.vars.closeWhenOpenStack.push(this);
        }

        // trigger postShow function
        // function receives the box element (the balloon wrapper div) as an argument
        opts.postShow.apply(this, [$box[0]]);


      }; // </ turnOn() >

      this.btOff = function() {

        var box = $(this).data('bt-box');

        // trigger preHide function
        // function receives the box element (the balloon wrapper div) as an argument
        opts.preHide.apply(this, [box]);

        var i = this;

        // set up the stuff to happen AFTER the tip is hidden
        i.btCleanup = function(){
          var box = $(i).data('bt-box');
          var contentOrig = $(i).data('bt-content-orig');
          var overlay = $(i).data('bt-overlay');
          if (typeof box == 'object') {
            $(box).remove();
            $(i).removeData('bt-box');
          }
          if (typeof contentOrig == 'object') {
            var clones = $(contentOrig.original).data('bt-clones');
            $(contentOrig).data('bt-clones', arrayRemove(clones, contentOrig.clone));
          }
          if (typeof overlay == 'object') {
            $(overlay).remove();
            $(i).removeData('bt-overlay');
          }

          // remove this from the stacks
          jQuery.bt.vars.clickAnywhereStack = arrayRemove(jQuery.bt.vars.clickAnywhereStack, i);
          jQuery.bt.vars.closeWhenOpenStack = arrayRemove(jQuery.bt.vars.closeWhenOpenStack, i);

          // remove the 'bt-active' and activeClass classes from target
          $(i).removeClass('bt-active ' + opts.activeClass);

          // trigger postHide function
          // no box argument since it has been removed from the DOM
          opts.postHide.apply(i);

        }

        opts.hideTip.apply(this, [box, i.btCleanup]);

      }; // </ turnOff() >

      var refresh = this.btRefresh = function() {
        this.btOff();
        this.btOn();
      };

    }); // </ this.each() >


    function drawIt(points, strokeWidth) {
      this.moveTo(points[0].x, points[0].y);
      for (i=1;i<points.length;i++) {
        if (points[i-1].type == 'arcStart') {
          // if we're creating a rounded corner
          //ctx.arc(round5(points[i].x), round5(points[i].y), points[i].startAngle, points[i].endAngle, opts.cornerRadius, false);
          this.quadraticCurveTo(round5(points[i].x, strokeWidth), round5(points[i].y, strokeWidth), round5(points[(i+1)%points.length].x, strokeWidth), round5(points[(i+1)%points.length].y, strokeWidth));
          i++;
          //ctx.moveTo(round5(points[i].x), round5(points[i].y));
        }
        else {
          this.lineTo(round5(points[i].x, strokeWidth), round5(points[i].y, strokeWidth));
        }
      }
    }; // </ drawIt() >

    /**
     * For odd stroke widths, round to the nearest .5 pixel to avoid antialiasing
     * http://developer.mozilla.org/en/Canvas_tutorial/Applying_styles_and_colors
     */
    function round5(num, strokeWidth) {
      var ret;
      strokeWidth = numb(strokeWidth);
      if (strokeWidth%2) {
        ret = num;
      }
      else {
        ret = Math.round(num - .5) + .5;
      }
      return ret;
    }; // </ round5() >

    /**
     * Ensure that a number is a number... or zero
     */
    function numb(num) {
      return parseInt(num) || 0;
    }; // </ numb() >

    /**
     * Remove an element from an array
     */
    function arrayRemove(arr, elem) {
      var x, newArr = new Array();
      for (x in arr) {
        if (arr[x] != elem) {
          newArr.push(arr[x]);
        }
      }
      return newArr;
    }; // </ arrayRemove() >

    /**
     * Does the current browser support canvas?
     * This is a variation of http://code.google.com/p/browser-canvas-support/
     */
    function canvasSupport() {
      var canvas_compatible = false;
      try {
        canvas_compatible = !!(document.createElement('canvas').getContext('2d')); // S60
      } catch(e) {
        canvas_compatible = !!(document.createElement('canvas').getContext); // IE
      }
      return canvas_compatible;
    }

    /**
     * Does the current browser support canvas drop shadows?
     */
    function shadowSupport() {

      // to test for drop shadow support in the current browser, uncomment the next line
      // return true;

      // until a good feature-detect is found, we have to look at user agents
      try {
        var userAgent = navigator.userAgent.toLowerCase();
        if (/webkit/.test(userAgent)) {
          // WebKit.. let's go!
          return true;
        }
        else if (/gecko|mozilla/.test(userAgent) && parseFloat(userAgent.match(/firefox\/(\d+(?:\.\d+)+)/)[1]) >= 3.1){
          // Mozilla 3.1 or higher
          return true;
        }
      }
      catch(err) {
        // if there's an error, just keep going, we'll assume that drop shadows are not supported
      }

      return false;

    } // </ shadowSupport() >

    /**
     * Given two points, find a point which is dist pixels from point1 on a line to point2
     */
    function betweenPoint(point1, point2, dist) {
      // figure out if we're horizontal or vertical
      var y, x;
      if (point1.x == point2.x) {
        // vertical
        y = point1.y < point2.y ? point1.y + dist : point1.y - dist;
        return {x: point1.x, y: y};
      }
      else if (point1.y == point2.y) {
        // horizontal
        x = point1.x < point2.x ? point1.x + dist : point1.x - dist;
        return {x:x, y: point1.y};
      }
    }; // </ betweenPoint() >

    function centerPoint(arcStart, corner, arcEnd) {
      var x = corner.x == arcStart.x ? arcEnd.x : arcStart.x;
      var y = corner.y == arcStart.y ? arcEnd.y : arcStart.y;
      var startAngle, endAngle;
      if (arcStart.x < arcEnd.x) {
        if (arcStart.y > arcEnd.y) {
          // arc is on upper left
          startAngle = (Math.PI/180)*180;
          endAngle = (Math.PI/180)*90;
        }
        else {
          // arc is on upper right
          startAngle = (Math.PI/180)*90;
          endAngle = 0;
        }
      }
      else {
        if (arcStart.y > arcEnd.y) {
          // arc is on lower left
          startAngle = (Math.PI/180)*270;
          endAngle = (Math.PI/180)*180;
        }
        else {
          // arc is on lower right
          startAngle = 0;
          endAngle = (Math.PI/180)*270;
        }
      }
      return {x: x, y: y, type: 'center', startAngle: startAngle, endAngle: endAngle};
    }; // </ centerPoint() >

    /**
     * Find the intersection point of two lines, each defined by two points
     * arguments are x1, y1 and x2, y2 for r1 (line 1) and r2 (line 2)
     * It's like an algebra party!!!
     */
    function findIntersect(r1x1, r1y1, r1x2, r1y2, r2x1, r2y1, r2x2, r2y2) {

      if (r2x1 == r2x2) {
        return findIntersectY(r1x1, r1y1, r1x2, r1y2, r2x1);
      }
      if (r2y1 == r2y2) {
        return findIntersectX(r1x1, r1y1, r1x2, r1y2, r2y1);
      }

      // m = (y1 - y2) / (x1 - x2)  // <-- how to find the slope
      // y = mx + b                 // the 'classic' linear equation
      // b = y - mx                 // how to find b (the y-intersect)
      // x = (y - b)/m              // how to find x
      var r1m = (r1y1 - r1y2) / (r1x1 - r1x2);
      var r1b = r1y1 - (r1m * r1x1);
      var r2m = (r2y1 - r2y2) / (r2x1 - r2x2);
      var r2b = r2y1 - (r2m * r2x1);

      var x = (r2b - r1b) / (r1m - r2m);
      var y = r1m * x + r1b;

      return {x: x, y: y};
    }; // </ findIntersect() >

    /**
     * Find the y intersection point of a line and given x vertical
     */
    function findIntersectY(r1x1, r1y1, r1x2, r1y2, x) {
      if (r1y1 == r1y2) {
        return {x: x, y: r1y1};
      }
      var r1m = (r1y1 - r1y2) / (r1x1 - r1x2);
      var r1b = r1y1 - (r1m * r1x1);

      var y = r1m * x + r1b;

      return {x: x, y: y};
    }; // </ findIntersectY() >

    /**
     * Find the x intersection point of a line and given y horizontal
     */
    function findIntersectX(r1x1, r1y1, r1x2, r1y2, y) {
      if (r1x1 == r1x2) {
        return {x: r1x1, y: y};
      }
      var r1m = (r1y1 - r1y2) / (r1x1 - r1x2);
      var r1b = r1y1 - (r1m * r1x1);

      // y = mx + b     // your old friend, linear equation
      // x = (y - b)/m  // linear equation solved for x
      var x = (y - r1b) / r1m;

      return {x: x, y: y};

    }; // </ findIntersectX() >

  }; // </ jQuery.fn.bt() >

  /**
   * jQuery's compat.js (used in Drupal's jQuery upgrade module, overrides the $().position() function
   *  this is a copy of that function to allow the plugin to work when compat.js is present
   *  once compat.js is fixed to not override existing functions, this function can be removed
   *  and .btPosion() can be replaced with .position() above...
   */
  jQuery.fn.btPosition = function() {

    function num(elem, prop) {
      return elem[0] && parseInt( jQuery.curCSS(elem[0], prop, true), 10 ) || 0;
    };

    var left = 0, top = 0, results;

    if ( this[0] ) {
      // Get *real* offsetParent
      var offsetParent = this.offsetParent(),

      // Get correct offsets
      offset       = this.offset(),
      parentOffset = /^body|html$/i.test(offsetParent[0].tagName) ? { top: 0, left: 0 } : offsetParent.offset();

      // Subtract element margins
      // note: when an element has margin: auto the offsetLeft and marginLeft
      // are the same in Safari causing offset.left to incorrectly be 0
      offset.top  -= num( this, 'marginTop' );
      offset.left -= num( this, 'marginLeft' );

      // Add offsetParent borders
      parentOffset.top  += num( offsetParent, 'borderTopWidth' );
      parentOffset.left += num( offsetParent, 'borderLeftWidth' );

      // Subtract the two offsets
      results = {
        top:  offset.top  - parentOffset.top,
        left: offset.left - parentOffset.left
      };
    }

    return results;
  }; // </ jQuery.fn.btPosition() >


  /**
  * jQuery's dimensions.js overrides the $().btOuterWidth() function
  *  this is a copy of original jQuery's outerWidth() function to
  *  allow the plugin to work when dimensions.js is present
  */
  jQuery.fn.btOuterWidth = function(margin) {

      function num(elem, prop) {
          return elem[0] && parseInt(jQuery.curCSS(elem[0], prop, true), 10) || 0;
      };

      return this["innerWidth"]()
      + num(this, "borderLeftWidth")
      + num(this, "borderRightWidth")
      + (margin ? num(this, "marginLeft")
      + num(this, "marginRight") : 0);

  }; // </ jQuery.fn.btOuterWidth() >

  /**
   * A convenience function to run btOn() (if available)
   * for each selected item
   */
  jQuery.fn.btOn = function() {
    return this.each(function(index){
      if (jQuery.isFunction(this.btOn)) {
        this.btOn();
      }
    });
  }; // </ $().btOn() >

  /**
   *
   * A convenience function to run btOff() (if available)
   * for each selected item
   */
  jQuery.fn.btOff = function() {
    return this.each(function(index){
      if (jQuery.isFunction(this.btOff)) {
        this.btOff();
      }
    });
  }; // </ $().btOff() >

  jQuery.bt.vars = {clickAnywhereStack: [], closeWhenOpenStack: []};

  /**
   * This function gets bound to the document's click event
   * It turns off all of the tips in the click-anywhere-to-close stack
   */
  jQuery.bt.docClick = function(e) {
    if (!e) {
      var e = window.event;
    };
    // if clicked element is a child of neither a tip NOR a target
    // and there are tips in the stack
    if (!$(e.target).parents().andSelf().filter('.bt-wrapper, .bt-active').length && jQuery.bt.vars.clickAnywhereStack.length) {
      // if clicked element isn't inside tip, close tips in stack
      $(jQuery.bt.vars.clickAnywhereStack).btOff();
      $(document).unbind('click', jQuery.bt.docClick);
    }
  }; // </ docClick() >

  /**
   * Defaults for the beauty tips
   *
   * Note this is a variable definition and not a function. So defaults can be
   * written for an entire page by simply redefining attributes like so:
   *
   *   jQuery.bt.options.width = 400;
   *
   * Be sure to use *jQuery.bt.options* and not jQuery.bt.defaults when overriding
   *
   * This would make all Beauty Tips boxes 400px wide.
   *
   * Each of these options may also be overridden during
   *
   * Can be overriden globally or at time of call.
   *
   */
  jQuery.bt.defaults = {
    trigger:         'hover',                // trigger to show/hide tip
                                             // use [on, off] to define separate on/off triggers
                                             // also use space character to allow multiple  to trigger
                                             // examples:
                                             //   ['focus', 'blur'] // focus displays, blur hides
                                             //   'dblclick'        // dblclick toggles on/off
                                             //   ['focus mouseover', 'blur mouseout'] // multiple triggers
                                             //   'now'             // shows/hides tip without event
                                             //   'none'            // use $('#selector').btOn(); and ...btOff();
                                             //   'hoverIntent'     // hover using hoverIntent plugin (settings below)
                                             // note:
                                             //   hoverIntent becomes default if available

    clickAnywhereToClose: true,              // clicking anywhere outside of the tip will close it
    closeWhenOthersOpen: false,              // tip will be closed before another opens - stop >= 2 tips being on

    shrinkToFit:      false,                 // should short single-line content get a narrower balloon?
    width:            '200px',               // width of tooltip box

    padding:          '10px',                // padding for content (get more fine grained with cssStyles)
    spikeGirth:       10,                    // width of spike
    spikeLength:      15,                    // length of spike
    overlap:          0,                     // spike overlap (px) onto target (can cause problems with 'hover' trigger)
    overlay:          false,                 // display overlay on target (use CSS to style) -- BUGGY!
    killTitle:        true,                  // kill title tags to avoid double tooltips

    textzIndex:       9999,                  // z-index for the text
    boxzIndex:        9998,                  // z-index for the "talk" box (should always be less than textzIndex)
    wrapperzIndex:    9997,
    offsetParent:     null,                  // DOM node to append the tooltip into.
                                             // Must be positioned relative or absolute. Can be selector or object
    positions:        ['most'],              // preference of positions for tip (will use first with available space)
                                             // possible values 'top', 'bottom', 'left', 'right' as an array in order of
                                             // preference. Last value will be used if others don't have enough space.
                                             // or use 'most' to use the area with the most space
    fill:             "rgb(255, 255, 102)",  // fill color for the tooltip box, you can use any CSS-style color definition method
                                             // http://www.w3.org/TR/css3-color/#numerical - not all methods have been tested

    windowMargin:     10,                    // space (px) to leave between text box and browser edge

    strokeWidth:      1,                     // width of stroke around box, **set to 0 for no stroke**
    strokeStyle:      "#000",                // color/alpha of stroke

    cornerRadius:     5,                     // radius of corners (px), set to 0 for square corners

                      // following values are on a scale of 0 to 1 with .5 being centered

    centerPointX:     .5,                    // the spike extends from center of the target edge to this point
    centerPointY:     .5,                    // defined by percentage horizontal (x) and vertical (y)

    shadow:           false,                 // use drop shadow? (only displays in Safari and FF 3.1) - experimental
    shadowOffsetX:    2,                     // shadow offset x (px)
    shadowOffsetY:    2,                     // shadow offset y (px)
    shadowBlur:       3,                     // shadow blur (px)
    shadowColor:      "#000",                // shadow color/alpha
    shadowOverlap:   false,                  // when shadows overlap the target element it can cause problem with hovering
                                             // set this to true to overlap or set to a numeric value to define the amount of overlap
    noShadowOpts:     {strokeStyle: '#999'},  // use this to define 'fall-back' options for browsers which don't support drop shadows

    cssClass:         '',                    // CSS class to add to the box wrapper div (of the TIP)
    cssStyles:        {},                    // styles to add the text box
                                             //   example: {fontFamily: 'Georgia, Times, serif', fontWeight: 'bold'}

    activeClass:      'bt-active',           // class added to TARGET element when its BeautyTip is active

    contentSelector:  "$(this).attr('title')", // if there is no content argument, use this selector to retrieve the title
                                             // a function which returns the content may also be passed here

    ajaxPath:         null,                  // if using ajax request for content, this contains url and (opt) selector
                                             // this will override content and contentSelector
                                             // examples (see jQuery load() function):
                                             //   '/demo.html'
                                             //   '/help/ajax/snip'
                                             //   '/help/existing/full div#content'

                                             // ajaxPath can also be defined as an array
                                             // in which case, the first value will be parsed as a jQuery selector
                                             // the result of which will be used as the ajaxPath
                                             // the second (optional) value is the content selector as above
                                             // examples:
                                             //    ["$(this).attr('href')", 'div#content']
                                             //    ["$(this).parents('.wrapper').find('.title').attr('href')"]
                                             //    ["$('#some-element').val()"]

    ajaxError:        '<strong>ERROR:</strong> <em>%error</em>',
                                             // error text, use "%error" to insert error from server
    ajaxLoading:     '<blink>Loading...</blink>',  // yes folks, it's the blink tag!
    ajaxData:         {},                    // key/value pairs
    ajaxType:         'GET',                 // 'GET' or 'POST'
    ajaxCache:        true,                  // cache ajax results and do not send request to same url multiple times
    ajaxOpts:         {},                    // any other ajax options - timeout, passwords, processing functions, etc...
                                             // see http://docs.jquery.com/Ajax/jQuery.ajax#options

    preBuild:         function(){},          // function to run before popup is built
    preSizeCalculation: function(){},          // function to run after loading content, but before calculating canvas size
    preShow:          function(box){},       // function to run before popup is displayed
    showTip:          function(box){
                        $(box).show();
                      },
    postShow:         function(box){},       // function to run after popup is built and displayed

    preHide:          function(box){},       // function to run before popup is removed
    hideTip:          function(box, callback) {
                        $(box).hide();
                        callback();   // you MUST call "callback" at the end of your animations
                      },
    postHide:         function(){},          // function to run after popup is removed

    hoverIntentOpts:  {                          // options for hoverIntent (if installed)
                        interval: 300,           // http://cherne.net/brian/resources/jquery.hoverIntent.html
                        timeout: 500
                      }

  }; // </ jQuery.bt.defaults >

  jQuery.bt.options = {};

})(jQuery);

// @todo
// use larger canvas (extend to edge of page when windowMargin is active)
// add options to shift position of tip vert/horiz and position of spike tip
// create drawn (canvas) shadows
// use overlay to allow overlap with hover
// experiment with making tooltip a subelement of the target
// handle non-canvas-capable browsers elegantly
$(document).ready(function() {
    // We have several click actions in the book content; a click can focus a highlight, display a pop-up, or follow a
    // link.  We want to be able to manage which of these happens, and in which order, when more than one event is
    // the possible response to a click (e.g. when the user taps a link inside a highlight).
    $("a").click(function(event) {
    event.stopPropagation();
    });
                  
    // enable tapping anywhere on a figure box to activate the thumbnail link; requires form submit to trigger uiwebview events correctly
    $(".fig, .fig-wide").click(function(event) {
        event.stopPropagation();
        var href = $(this).children('a').attr('href');
        $('<form>').attr({action: href, method: 'GET'}).appendTo($('body')).submit();
        event.preventDefault();
    });

});
var Halo = {};

jQuery.fn.cleanWhitespace = function(andTrim) { // recursive and (optionally) trims surrounding whitespaces
    this.contents().filter(function() {
        if (this.nodeType != 3) {
            $(this).cleanWhitespace(andTrim);
            return false;
        }
        else {
            var isEmpty = !/\S/.test(this.nodeValue);
            if(!isEmpty && andTrim) this.nodeValue = $.trim(this.nodeValue);
            return isEmpty;
        }
    }).remove();
    return this;
}
$(document).ready(function() {
	Halo.highlighter = new Halo.Highlighter();
	Halo.touchEventHandler = new Halo.TouchEventHandler(Halo.highlighter);
    //add copyright
	if($('body > .concept, #top-level > .concept, #review, #overview').length > 0) {
		$.ajax({
			   url: '../../html/copyright.html',
               success: function(data) {
               var divh = '<div style="height: 20px"> </div>';
			   $('body > .concept, #top-level > .concept, .chapter-end, #overview').append(data);
               $('body').animate({
               height: $('body > .concept, #top-level > .concept, .chapter-end, #overview').height()
               },300);
			}
		});
	}
});
var nsBridge = function() {
  var self = {};

  var $nsbridge = getBridgeElement();

  self.init = function() {
    self.sendEvent('webviewready');
  };

  self.sendEvent = function(scheme, resource, id, action) {
    $nsbridge = getBridgeElement();
    $nsbridge.attr("href", scheme + '://' + ['device', resource, id, action].join('/'));
    var event = document.createEvent('HTMLEvents');
    event.initEvent('click');
    $nsbridge[0].dispatchEvent(event);
  };

  return self;

  function getBridgeElement() {
    var $nsbridge = $("#nsbridge");
    if (!$nsbridge.length) {  // check for and insert element each time in case was previously removed
      $(document.body).append('<a id="nsbridge" style="display: none" onclick="">nsbridge</a>');
      $nsbridge = $("#nsbridge");
      if (!window.navigator.appVersion.match(/ipad/gi) || window.navigator.appVersion.match(/safari/gi)) {
        $nsbridge.click(function() {
          return false;
        });
      }
    }
    return $nsbridge;
  }
}();

$(document).ready(function() {
  nsBridge.init();
});
$(document).ready(function() {
                  Halo.prepareTooltipElements();
                  Halo.clicksOnNonTooltipElementsShouldCloseAnyTooltip();
                  });

Halo.prepareTooltipElements = function() {
    Halo.prepareTooltipElement($('a.keywords'));
}

Halo.prepareTooltipElement = function(element) {
    // hack to make text selection work in textbook
    if ($("#glossary-page, .answer-page").length == 0) {
        $(element).each( function(idx) {
                        var href = $(this).attr('href');
                        $(this).replaceWith($('<span class="keywords" href="' +href+ '">' + this.innerHTML + '</span>'));
                        });
        element = $("span.keywords");
    }
    
    $(element).click(function(event) {
                     event.stopPropagation();
                     //    nsBridge.sendEvent('put', 'glossary', $(this).attr('href'), 'showPopup');
                     event.preventDefault();
                     }).bt({
                           trigger: 'touchclick',
                           positions: ['top', 'bottom'],
                           width: '280px',
                           cornerRadius: 0,
                           shadow: true,
                           shadowOffsetX: 0,
                           shadowOffsetY: 2,
                           shadowBlur: 16,
                           shadowColor: 'rgba(0,0,0,.333)',
                           spikeGirth: 30,
                           spikeLength: 15,
                           fill: 'white', //'#55585f',
                           strokeStyle: 'rgba(0,0,0,0.1)', //'rgba(255,255,255,0.85)',
                           strokeWidth: 1,
                           ajaxPath: ["$(this).attr('href')", "div#shortdef"],
                           clickAnywhereToClose: true,
                           overlap: 12,
                           padding: 16,
                           windowMargin: 36,
                           killTitle: false, // don't need it, and it causes trouble with relationship answers
                           ajaxCache: false,
                           ajaxLoading: '',   // Don't show a loading box, since it interferes with animation
                           closeWhenOthersOpen: true,
                           offsetParent: '#top-level',
                           showTip: Halo.animateToolTipShow,
                           hideTip: Halo.animateToolTipHide,
                           preSizeCalculation: Halo.buildTooltipNavigationContent,
                           postShow: function(box){       // function to run after popup is built and displayed
                           nsBridge.sendEvent('put', 'glossary', $(this).attr('href'), 'showPopup');
                           }
                           });
};

Halo.buildTooltipNavigationContent = function(box) {
    if ($('#shortdef', box).length) {
        var href = $(this).attr('href');
        
        // fix &html; entities in the text
        var cleanText = $('.bt-content .human-authored', box).text();
        cleanText = $('<div/>').html(cleanText).text();
        $('.bt-content .human-authored', box).text(cleanText);
        
        if (cleanText.length > 290) {
            var newtext = cleanText.trim()    // remove leading and trailing spaces
            .substring(0, 290)    // get first 300 characters
            .split(" ")           // separate characters into an array of words
            .slice(0, -1)         // remove the last full or partial word
            .join(" ") + " \u2026"; // combine into a single string and append "…"
            $('.bt-content .human-authored', box).text(newtext);
        }
        
        //    $('.bt-content', box).append(" <a class='navigation' href=" + href + ">Read&nbsp;More</a>");
        //    $('.bt-content h3', box).wrapInner("<a href='" + href + "' />");
        $('.bt-content h3', box).prepend(" <a class='navigation' href=" + href + ">more</a>");
        
        // add CSS animations!
        $(box).css('opacity', 0);
        $(box).css('-webkit-transition', 'opacity 0.3s linear');
    }
};

Halo.animateToolTipShow = function(box) {
    /*   $(box).fadeIn(400); */
    $(box).css({
               'visible' : 'visible',
               'display' : 'block'
               });
    $(box).css('opacity', 1);
};

Halo.animateToolTipHide = function(box, callback) {
    /*   $(box).css('-webkit-transition', 'none'); */
    /*   $(box).animate({opacity: 0}, 400, callback); */
    $(box).css('opacity', 0);
    window.setTimeout(function() {  
                      callback();  
                      }, 400);
};

Halo.clicksOnNonTooltipElementsShouldCloseAnyTooltip = function() {
    var $tag = $('body > #top-level');
    if (!$tag[0]) {
        $('body > *').wrapAll('<div id="top-level"></div>');
    }
};

Halo.dismissAllTooltips = function() {
	$(jQuery.bt.vars.clickAnywhereStack).btOff();
};
$(document).ready(function() {
	Halo.prepareGlossary(true);
});

Halo.prepareGlossary = function(firstLoad) {
	Halo.prepareGlossaryButtons();
	Halo.prepareKindsOfToggles(firstLoad);
	Halo.prepareInheritanceToggles();
	Halo.formatGlossaryPages();
};

Halo.prepareGlossaryButtons = function() {
	$('#show-graph-button').prependTo($('#glossary-page h2'));
	
	$('#show-cmap').bind('touchstart touchend', function(event) {
		if (event.type == 'touchend') {
			$('#show-cmap').removeClass('active');
		} else {
			$('#show-cmap').addClass('active');
		}
	});
	$('#hide-cmap').live('touchstart touchend', function(event) {
		if (event.type == 'touchend') {
			$('#hide-cmap').removeClass('active');
		} else {
			$('#hide-cmap').addClass('active');
		}
	});
};

Halo.prepareKindsOfToggles = function(firstLoad) {
	
    $('#expList2 > li').each(function(index) {
        var header = $(this);
        var list = $(this).children('ul');
//        if (list.children('li').length < 2) return true; 
        list.hide();

        var getSpeed = function(target){
            return Math.min($(target).find('li, p').length * 80, 300);
        };

        var label = list.children('li').length + " function";
        if (list.children('li').length > 1) label += "s";

        $("<span class='show-button'>" + label + "</span>").insertAfter(header.children('a'))
        .toggle(function(e) {
            var showSpeed = getSpeed(list);
            list.slideDown(showSpeed);
            $(e.currentTarget).parent().addClass('visible');
            $(e.currentTarget).attr('rel', $(e.currentTarget).text());
            $(e.currentTarget).text("hide");
            return false;
        }, function(e) {
            var hideSpeed = getSpeed(list);
            list.slideUp(hideSpeed);
            $(e.currentTarget).parent().removeClass('visible');
            $(e.currentTarget).text($(e.currentTarget).attr('rel'));
            return false;
        });
    });
	
    // set up show/hide buttons for "Types of X" list
    $('#related, #types-of, #kinds-of').each(function(index) { //, #function
                                             
        $(this).cleanWhitespace(true);
                                             
        var list = $(this);
        var CUTOFF = 10;
        if (list.children('ul').children('li').length > CUTOFF) {
            var lis = list.children('ul').children('li');
            if(firstLoad) list.children('ul').hide(); // hidden for aesthetics at load time

            if (list.is('#function')) {
                // also trims functions list, though it's a bit of a hack
                lis.last().after("<li style='list-style:none;'> <span class='showFewerKinds'>hide</span></li>");
                lis.eq(CUTOFF-6).after("<li class='showMoreKinds' style='list-style:none;'><span>show all " + lis.length + "</span></li>");
            } else {
                lis.last().append(" <span class='showFewerKinds'>hide</span>");
                lis.eq(CUTOFF-1).after("<li class='showMoreKinds'>&hellip; <span>show all " + lis.length + "</span></li>");
            }
            list.find(".showMoreKinds").click(function(e) {
                $(this).hide();
                $(this).nextAll("li").fadeIn('fast');
                return false;
            });
            list.find(".showFewerKinds").click(function(e) {
                var $showMore = $(this).parent().parent().children('.showMoreKinds');
                $showMore.nextAll("li").fadeOut('fast', function(){
                     $showMore.show();
                });
                return false;
            });

            if (firstLoad) {
                $(window).load(function() {
                    list.find(".showMoreKinds").nextAll("li").hide();
                    list.children('ul').show();
                });
            } else {
                list.find(".showMoreKinds").nextAll("li").hide();
            }
        }
    });

    // handle subevents (used to do this for functions too, but no more!)
    $('#subevents ul li ul, .roles ul, #expList').each(function(index) { //#function ul li ul,
        var list = $(this);
        var CUTOFF = 2;
        if (list.children('li').length > CUTOFF) {
            var lis = list.children('li');
            lis.last().after("<li style='list-style:none;'> <span class='showFewerKinds'>hide</span></li>");
            lis.eq(CUTOFF-1).after("<li style='list-style:none;' class='showMoreKinds'><span>show all " + lis.length + "</span></li>");
            list.find(".showMoreKinds").nextAll("li").hide();

            list.find(".showMoreKinds").click(function(e) {
                $(this).hide();
                $(this).nextAll("li").fadeIn('fast');
                    return false;
            });
            list.find(".showFewerKinds").click(function(e) {
                var $showMore = $(this).parent().parent().children('.showMoreKinds');
                $showMore.nextAll("li").fadeOut('fast', function(){
                    $showMore.show();
                });
                return false;
            });
        }
    });
};

Halo.prepareInheritanceToggles = function() {
	if($('.glossary-page').length > 0 || $('.answer-page').length > 0) {
		
		var getSpeed = function(target){
			return Math.min($(target).find('li, p').length * 80, 200);
		};
		
/* 		TOGGLE BUTTONS FOR LISTS (PARTS, ETC) */
		$(".toggle > ul").hide();
		$(" <span class='show-button'>show</span>").insertAfter(".toggle .list-title")
		.toggle(function(e) {
			var showSpeed = getSpeed($(e.currentTarget).next("ul"));
			$(e.currentTarget).next("ul").slideDown(showSpeed);
			$(e.currentTarget).parent().addClass('visible');
			$(e.currentTarget).attr('rel', $(e.currentTarget).text());
			$(e.currentTarget).text("hide");
			return false;
		}, function(e) {
			var hideSpeed = getSpeed($(e.currentTarget).next("ul"));
			$(e.currentTarget).next("ul").slideUp(hideSpeed);
			$(e.currentTarget).parent().removeClass('visible');
			$(e.currentTarget).text($(e.currentTarget).attr('rel'));
			return false;
		});
		
/* 		TOGGLE BUTTONS FOR INHERITANCE LISTS  */
        $('.inheritance-list').each(function() {
            $(this).children(".list-title").cleanWhitespace(false);
            if ($(this).find(".sub-list").length > 0) {
                $(this).addClass('has-sub-lists');
                $(this).find(".sub-list").hide();
                var lists = $(this).children(".list-title").siblings('ul').children('.sub-list');
                                    
                var count = $(this).find(".sub-list > ul > li, ul > li:not(.sub-list)").length;
                var label = "show all " + count;
                                    
                if($(this).children(".list-title").siblings('ul').children('li:not(.sub-list)').length == 0) {
                    $(this).addClass('all-hidden');
                    if( $(this).hasClass('properties') && count == 1) {
                        label = "show";
                    } else {
                        label = "show " + count;
                    }
                }
                $(" <span class='show-button'>"+label+"</span>").insertAfter($(this).children(".list-title")).toggle(function(e) {
                    var showSpeed = getSpeed($(lists).children("ul"));
                    $(lists).slideDown(showSpeed);
                    $(e.currentTarget).parent().addClass('visible');
                    $(e.currentTarget).attr('rel', $(e.currentTarget).text());
                    $(e.currentTarget).text("hide inherited");
                    return false;
                }, function(e) {
                    var hideSpeed = getSpeed($(lists).children("ul"));
                    $(lists).slideUp(hideSpeed);
                    $(e.currentTarget).parent().removeClass('visible');
                    $(e.currentTarget).text($(e.currentTarget).attr('rel'));
                    return false;
                });
            }
        });
		
/* 		TOGGLE BUTTONS FOR SUB-PART DROP-DOWNS */
		$(".subpart .details").hide();
		$("<span> </span><span class='show-button'>i</span>").insertBefore(".subpart > .details")
		.toggle(function(e) {
			var showSpeed = getSpeed($(e.currentTarget).next(".details"));
			$(e.currentTarget).next(".details").slideDown(showSpeed);
			$(e.currentTarget).addClass("expanded").text("\u2715");
			return false;
		}, function(e) {
			var hideSpeed = getSpeed($(e.currentTarget).next(".details"));
			$(e.currentTarget).next(".details").slideUp(hideSpeed);
			$(e.currentTarget).removeClass("expanded").text("i");
			return false;
		});
	}
};

Halo.formatGlossaryPages = function(firstLoad) {
	$('.glossary-page ol li').wrapInner('<span> </span>').addClass('ol-li');
	
	if($('.cmap').length > 0) {
		//TODO: remove this when c-maps style themselves better
		$('body').css("background-image", "none");
		return;
	}
	
	if($('#structure h4').next('ul').children('li').not('.toggle').length == 0) {
		// hide the "Parts specific to X" header if there are no specific parts
		$('#structure h4').remove();
	}
	
	if($('.glossary-page #toc li').length == 0) $('.glossary-page #toc').hide();
	
	if ($('#glossary-sidebar').length == 0) {
		// make the sidebar
		if($('#glossary-page').length > 0) {
			var sidebar = $('<div id="glossary-sidebar" />').appendTo($('#definition'));
		} else {
			var sidebar = $('<div id="glossary-sidebar" />').appendTo($('.answer:not(.relationship-answer, .graph-intro, .diff, .sim)'));
		}
		// add figures to sidebar
		var mediaDiv = $('<div id="media" />');
		$('#glossary-page #media .fig, .answer:not(.sim) #media .fig, .answer-page > #media .fig').each(function() {
			var href = $(this).children('a').attr('href');
			var src = $(this).children('a').children('img').attr('src');
			var title = $(this).children('a').children('img').attr('alt');
			$(mediaDiv).append('<a class="fig" href="'+href+'" style="background-image:url('+src+')"><span>'+title+'</span></a>');
		});
		if( $(mediaDiv).is(":empty") == false ) {
			$(sidebar).append(mediaDiv);
		}
		$(sidebar).append($('#suggested-questions').clone());
	}
};

Halo.loadSuggestedQuestionsForConcept = function(concept, server) {
	if ($('#suggested-questions').length == 0) {
		$(document).ready(function() {
			$('#glossary-sidebar, #glossary-page').append('<div id="suggested-questions" class="suggested-questions glossary-section empty"><h3>Related questions</h3><ul></ul></div>');
			$('#toc').append('<li id="sq-toc" class="empty"><a class="toc-link" href="#suggested-questions">Related questions</a></li>');
	
			$.post('http://' + server + '/get_questions_for_glossary', 
				{ concept: concept }, 
				function(xml) {
					var questions = $(xml).find("question");
					if ($(questions).length > 0) {
						$('#sq-toc').removeClass('empty');
						$('.suggested-questions').removeClass('empty');

						$(questions).each(function() {
							 $('<li>' + $(this).text() + '</li>').appendTo('.suggested-questions ul');
						});
						Halo.addShowHideButtonToSuggestedQuestions(false);
					} else {
						$('#sq-toc').slideUp('fast');
						$('.suggested-questions').fadeOut(function(){ $(this).hide(); }); // Safari sometimes fails w/out this callback
					}
				}
			).error(
				function() { 
					$('<li><em>Unable to load suggested questions</em></li>').appendTo('.suggested-questions ul');
					$('.suggested-questions').removeClass('empty');
				}
			);

		});
	}
};

Halo.addShowHideButtonToSuggestedQuestions = function(firstRun) {
	var TO_SHOW = 4;
	$('.suggested-questions').each(function(index, list) {
		if ($(list).find('li').length > TO_SHOW) {
			var lis = $(list).find('li');
			if (!firstRun) $(list).children('ul').hide(); // hidden for aesthetics at load time

			lis.eq(TO_SHOW-1).after("<li class='showMoreKinds sqToggle'><span>show all " + lis.length + "</span></li>");
			lis.last().after("<li class=sqToggle> <span class='showFewerKinds'>hide</span></li>");
			$(list).find(".showMoreKinds > span").click(function(e) {
				$(this).parent().hide();
				$(this).parent().nextAll("li").fadeIn('fast');
				return false;
			});
			$(list).find(".showFewerKinds").click(function(e) {
				var $showMore = $(this).parent().parent().children('.showMoreKinds');
				$showMore.nextAll("li").fadeOut('fast', function(){
					$showMore.show();
				});
				return false;
			});
			
			$(list).find(".showMoreKinds").nextAll("li").hide();
			if (!firstRun) {
				$(list).find(".showMoreKinds").show();
				$(list).children('ul').fadeIn();
			}
		}
	});
};

Halo.Highlight = function(index, highlightRange) {
  initialize();

  var highlightNode, highlightRangeJSON;
  var self = {};

  self.__defineGetter__("id", function() {
    return Halo.Highlight.idPrefix + self.index;
  });

  self.__defineGetter__("index", function() {
    return index;
  });

  self.__defineGetter__("yOffset", function() {
    checkWasApplied();
    return highlightNode.offsetTop;
  });

  self.__defineGetter__("xOffset", function() {
    checkWasApplied();
    return highlightNode.offsetLeft;
  });

  self.__defineGetter__("height", function() {
    checkWasApplied();
    return highlightNode.offsetHeight;
  });

  self.__defineGetter__("text", function() {
    checkWasApplied();
    return highlightNode.textContent.replace(/\s+/g, ' ');
  });

  self.__defineGetter__("section", function() {
    checkWasApplied();
    return $(highlightNode).parents().filter(function() {
      return this.id.match(/section[0-9-]+/);
    })[0].id;
  });

  self.__defineGetter__("rangeJSON", function() {
    return highlightRangeJSON;
  });

  self.addMarkup = function() {
    highlightNode = document.createElement("div");
    $(highlightNode).attr('id', self.id);
    $(highlightNode).addClass("highlighted");
      
    highlightRange.surroundContents(highlightNode);
    if (highlightContainsBlockElements() || highlightContainsImageElements()) {
      $(highlightNode).addClass("block");
    }
  };

  self.removeMarkup = function() {
    $('#' + self.id).contents().unwrap();
  };

  self.focus = function() {
    $('#' + self.id).addClass('focused');
  };

  self.toJSON = function() {
    return $.toJSON({
      id: self.id,
      xOffset: self.xOffset,
      yOffset: self.yOffset,
      text: self.text,
      section: self.section,
      rangeJSON: self.rangeJSON
    });
  };

  return self;

  function initialize() {
    // Save the highlight range as JSON *before* adding the highlight node,
    // since adding the new node affects the range's offsets.
    try {
      serializeHighlightRange();
		//console.log("Created highlight range with JSON: " + highlightRangeJSON);
    } catch(x) {
      console.error("=============> Highlight.js FAIL!:" + x + "(" + highlightRange + ")");
    }
  }

  function checkWasApplied() {
    if (!highlightNode) {
      throw "Highlight with index '" + index + "' has been instantiated, but not applied to the DOM.";
    }
  }

  function serializeHighlightRange() {
    highlightRangeJSON = $.toJSON({
      startContainer: Halo.NodeSerializer.serialize(highlightRange.startContainer),
      startOffset: calculateAdditionalOffsetFromPreviousTextNodesAndHighlightElements(highlightRange.startContainer, highlightRange.startOffset),
      endContainer: Halo.NodeSerializer.serialize(highlightRange.endContainer),
      endOffset: calculateAdditionalOffsetFromPreviousTextNodesAndHighlightElements(highlightRange.endContainer, highlightRange.endOffset)
    });
  }

  function calculateAdditionalOffsetFromPreviousTextNodesAndHighlightElements(container, offset) {
    if (container.nodeType == Node.TEXT_NODE) {
      return offset + additionalTextOffsetAndContinue(container).additionalOffset;
    } else {
      return Halo.NodeIndexer.fixedOffsetForNodeInParentWithoutHighlights(container, offset);
    }
  }

  function additionalTextOffsetAndContinue(container, includeContainer) {
    var sibling = container;
    var additionalOffset = 0;
    var onlyTextNodesFound = true;

    if (!includeContainer) {
      sibling = sibling.previousSibling;
    }

    while (sibling && onlyTextNodesFound) {
      if (sibling.nodeType == Node.TEXT_NODE) {
        additionalOffset += sibling.textContent.length;
      } else if (isTransientElement(sibling)) {
        var result = additionalTextOffsetAndContinue(sibling.lastChild, true);
        additionalOffset += result.additionalOffset;
        onlyTextNodesFound = onlyTextNodesFound && result.onlyTextNodesFound;
      } else {
        onlyTextNodesFound = false;
      }
      sibling = sibling.previousSibling;
    }
    return { additionalOffset: additionalOffset, onlyTextNodesFound: onlyTextNodesFound };
  }

  function isTransientElement(element) {
    return $(element).hasClass('highlighted') || $(element).hasClass('touchable');
  }

  function highlightContainsBlockElements() {
    return $.grep($("> *", highlightNode), function(childNode) {
      return "block" == window.getComputedStyle(childNode).display;
    }).length;
  }

  function highlightContainsImageElements() {
    return $("img", highlightNode).length;
  }
};

Halo.Highlight.fromJSON = function(index, rangeJSON) {
  var rangeFromJSON = $.parseJSON(rangeJSON);

  var documentRange = document.createRange();
  documentRange.setStart(Halo.NodeSerializer.deserialize(rangeFromJSON.startContainer), rangeFromJSON.startOffset);
  documentRange.setEnd(Halo.NodeSerializer.deserialize(rangeFromJSON.endContainer), rangeFromJSON.endOffset);

  return new Halo.Highlight(index, documentRange);
};

Halo.Highlight.idPrefix = "highlight-";
Halo.Highlighter = function() {
  var self = {};
  var currentHighlight = null;
  var highlightCount = 0;
  var highlights = {};

  self.highlightSelection = function() {
    if (document.getSelection().rangeCount <= 0) return;
    var range = validHighlightRangeForRange(document.getSelection().getRangeAt(0));

    // Remove selection ranges *before* wrapping the current selection range in
    // a span.  Otherwise the UIWebView selection mechanism appears to get
    // confused and move the selection widget around idiosyncratically.
    document.getSelection().removeAllRanges();

    self.beginHighlighting();
    createHighlightForRange(range);
  };

  self.beginHighlighting = function() {
    currentHighlight = null;
  };

  self.createHighlightWithStartAndEndElements = function(startElement, endElement) {
    if (currentHighlight) {
      self.removeHighlight(--highlightCount);
      currentHighlight = null;
    }

    var range = document.createRange();
    range.setStartBefore(startElement);
    range.setEndAfter(endElement);

    if (range.collapsed) {
      range.setStartBefore(endElement);
      range.setEndAfter(startElement);
    }

    range = validHighlightRangeForRange(range);
    createHighlightForRange(range);
  };

  self.createPersistentHighlightWithStartAndEndElements = function(startElement, endElement) {

    if (currentHighlight) {
      self.removeHighlight(--highlightCount);
      currentHighlight = null;
    }

    var localRange = document.createRange();

    localRange.setStartBefore(startElement);
    localRange.setEndAfter(endElement);

    if (localRange.collapsed) {
      var tempStart = endElement;
      endElement = startElement;
      startElement = tempStart;

      localRange.setStartBefore(startElement);
      localRange.setEndAfter(endElement);
    }
    localRange = validHighlightRangeForRange(localRange);

    if (localRange.startContainer.childNodes[localRange.startOffset] === startElement) {
      startElement = startElement.firstChild;
    } else {
      startElement = localRange.startContainer.childNodes[localRange.startOffset];
    }

    if (localRange.endContainer.childNodes[localRange.endOffset - 1] === endElement) {
      endElement = endElement.firstChild;
    } else {
      endElement = localRange.endContainer.childNodes[localRange.endOffset - 1];
    }

    var newRange = document.createRange();
    var origStartOffset = localRange.startOffset;
    var origEndOffset = localRange.endOffset;

    // remove spans!!
    var paragraph = $(startElement).closest("p, li")[0];
    $(".touchable", paragraph).contents().unwrap();

    if(startElement.nodeType == Node.ELEMENT_NODE) {
      newRange.setStart(localRange.startContainer, origStartOffset);
    } else {
      newRange.setStart(startElement, 0);
    }

    if(endElement.nodeType == Node.ELEMENT_NODE) {
      newRange.setEnd(localRange.endContainer, origEndOffset);
    } else {
      newRange.setEnd(endElement, endElement.textContent.length);
    }

    createHighlightForRange(newRange);
  };
    
  self.hasHighlights = function() {
    return highlightCount > 0;
  }

  self.addHighlight = function(highlight) {
     // alert("highlight");
    highlights[highlightCount++] = highlight;
  };

  self.addMarkupForAllHighlights = function() {
     //  alert("add markup highlight testXicom");
    var highlightIndex;
    for (highlightIndex in highlights) {
      //  alert("add markup highlight 0");
      if (highlights.hasOwnProperty(highlightIndex)) {
        //  alert("add markup highlight 1");
        highlights[highlightIndex].addMarkup();
      }
    }
  };

  self.removeHighlight = function(index) {
    var highlight = highlights[index];
    highlight && highlight.removeMarkup();
  };

  self.__defineGetter__('currentHighlight', function() {
    return currentHighlight;
  });
    
  self.getHighlight = function(index) {
    return highlights[index];
  };

  self.__defineGetter__('precedingSiblingHighlightIndex', function() {
    var $previousSiblingHighlight = $("#" + currentHighlight.id).prev(".highlighted");
    if ($previousSiblingHighlight.length) {
      return $previousSiblingHighlight[0].id.substr(Halo.Highlight.idPrefix.length);
    }
    return '-1';
  });

  self.isSelectionOverlappingExistingHighlight = function() {
    if (document.getSelection().rangeCount <= 0) return true;
    var range = validHighlightRangeForRange(document.getSelection().getRangeAt(0));
    return self.isRangeOverlappingExistingHighlight(range);
  };

  self.isRangeOverlappingExistingHighlight = function(range) {
    return isSelfOrParentHighlighted(range) || containsHighlighted(range)
	  || $(range.startContainer).parents(".bt-wrapper").length > 0;
  };	
	
  self.focusHighlight = function(index) {
    var highlight = highlights[index];
    highlight.focus();
  };

  self.defocusHighlights = function() {
    $('.highlighted.focused').removeClass('focused');
  };

  return self;

  function isSelfOrParentHighlighted(range) {
    return  $(range.startContainer).parents('.highlighted').length > 0 || $(range.startContainer).is('.highlighted')
           || $(range.endContainer).parents('.highlighted').length > 0 || $(range.endContainer).is('.highlighted');
  }

  function containsHighlighted(range) {
    return !!range.cloneContents().querySelector('.highlighted');
  }

  function validHighlightRangeForRange(range) {
    var startContainer = range.startContainer;
    var endContainer = range.endContainer;

    if (startContainer != endContainer) {
      fixOverlyAggressiveEndSelection(range);

      // TODO: extract method
      while (!(startContainer == range.commonAncestorContainer) && !(Node.TEXT_NODE == startContainer.nodeType && startContainer.parentNode == range.commonAncestorContainer)) {
        range.setStartBefore(startContainer);
        startContainer = startContainer.parentNode;
      }

      while (!(endContainer == range.commonAncestorContainer) && !(Node.TEXT_NODE == endContainer.nodeType && endContainer.parentNode == range.commonAncestorContainer)) {
        range.setEndAfter(endContainer);
        endContainer = endContainer.parentNode;
      }
    }

    return range;
  }

  function fixOverlyAggressiveEndSelection(range) {
    // The range object appears to have a bug that causes it to partially
    // select the element following the selection if the selection starts and
    // ends on element boundaries.
    if (Node.ELEMENT_NODE == range.endContainer.nodeType) {
      if (0 == range.endOffset) {
        range.setEndBefore(range.endContainer);
      }
    }
  }

  function createHighlightForRange(range) {
    currentHighlight = new Halo.Highlight(highlightCount, range);
    highlights[highlightCount++] = currentHighlight;

    currentHighlight.addMarkup();
  }

};

$(document).ready(function() {
  if (window.Touch && $("#glossary-page, .answer-page").length == 0) {
                  
    $('body').delegate('.highlighted', 'touchclick', function() {
        var highlightId = this.id.split('-')[1];
        nsBridge.sendEvent('put', 'highlights', highlightId, 'focus');
        event.stopPropagation();
    });
          
    // hack to make text selection work in textbook
    $('span.keywords').bind('touchclick', function() {
        nsBridge.sendEvent('put', 'highlights', '', 'defocus');
        event.stopPropagation();
    });
          
    $('body').bind('touchclick', function(e) {
        if($(e.target).closest('.highlighted').length == 0) nsBridge.sendEvent('put', 'highlights', '', 'defocus');
        return true;
    });

//    $('a').bind('touchclick', function() {
//        nsBridge.sendEvent('put', 'highlights', '', 'defocus');
//        event.stopPropagation();
//    });
  }
});

Halo.NodeIndexer = function() {
  var self = {};

  self.indexOfNodeInParent = function(node) {
    var result;
    $(node.parentElement).contents().each(function(index, child) {
      if (child == node) {
        result = index;
      }
    });

    return result;
  };

  self.indexOfNodeInParentWithoutHighlights = function(node) {
    var index = 0;
    var sibling = node;

    while (sibling = sibling.previousSibling) {
      index += indexOfNodeWithoutHighlights(sibling);
    }

//    console.error("=============> indexOfNodeInParentWithoutHighlights: ", index);
    return index;
  };

  self.fixedOffsetForNodeInParentWithoutHighlights = function(parent, offset) {
    var index = 0;

    for (var i = offset - 1; i >= 0; --i) {
      var sibling = parent.childNodes[i];
      index += indexOfNodeWithoutHighlights(sibling);
    }

//    console.error("=============> fixedOffsetForNodeInParentWithoutHighlights: ", index);
    return index;
  };

  return self;

  function indexOfNodeWithoutHighlights(node) {
    var index = 0;

    if (nodeIsTransient(node)) {
      node.normalize();
      index = node.childNodes.length;

      if (transientNodeDidSplitTextAtStart(node) || transientNodeDidSplitTextAtEnd(node)) {
        --index;
        if (transientNodeDidSplitTextAtStartAndEnd(node)) {
          --index;
        }
      }
    } else {
      if (!nodeIsSplitTextNode(node)) {
        ++index;
      }
    }

//    console.error("=============> indexOfNodeWithoutHighlights: ", index);
    return index;
  }

  function nodeIsTransient(node) {
    return node.nodeType == Node.ELEMENT_NODE && $(node).hasClass("highlighted") || $(node).hasClass("touchable");
  }

  function transientNodeDidSplitTextAtStart(node) {
    return node.firstChild.nodeType === Node.TEXT_NODE && (node.previousSibling &&
           node.previousSibling.nodeType === Node.TEXT_NODE) ||
           (node.previousSibling && nodeIsTransient(node.previousSibling) && node.previousSibling.lastChild.nodeType === Node.TEXT_NODE);
  }

  function transientNodeDidSplitTextAtEnd(node) {
    return node.lastChild.nodeType === Node.TEXT_NODE && (node.nextSibling && node.nextSibling.nodeType === Node.TEXT_NODE) ||
           (node.nextSibling && nodeIsTransient(node.nextSibling) && node.nextSibling.firstChild.nodeType === Node.TEXT_NODE);
  }

  function transientNodeDidSplitTextAtStartAndEnd(node) {
    return node.lastChild.nodeType === Node.TEXT_NODE && node.firstChild.nodeType === Node.TEXT_NODE &&
           (node.nextSibling && node.nextSibling.nodeType === Node.TEXT_NODE) &&
           (node.previousSibling && node.previousSibling.nodeType === Node.TEXT_NODE);
  }

  function nodeIsSplitTextNode(node) {
    return node.nodeType == Node.TEXT_NODE && node.nextSibling && node.nextSibling.nodeType == Node.TEXT_NODE;
  }
}();
Halo.NodeSerializer = function() {
  var self = {};

  self.serialize = function(domNode) {
    if (domNode.id) {
      return {
        id: domNode.id
      };
    } else {
      return {
        parentElement: self.serialize(domNode.parentElement),
        childOffset: Halo.NodeIndexer.indexOfNodeInParentWithoutHighlights(domNode)
      };
    }
  };

  self.deserialize = function(serialized) {
    if (serialized.id) {
      return $("#" + serialized.id)[0];
    } else {
      return self.deserialize(serialized.parentElement).childNodes[serialized.childOffset];
    }
  };

  return self;
}();
Halo.TouchEventHandler = function(highlighter) {
  var paragraph, startElement, endElement;

  var self = {};

  self.__defineGetter__("endElement", function() {
    return endElement;
  });

  self.touchesBeganAtPoint = function(x, y) {
    if (paragraph = $(document.elementFromPoint(x, y)).closest("p, li")[0]) {
      if ($(paragraph).is("li") && $(paragraph).parents("#glossary-page").length > 0) return "false"; //TODO: handle glossary highlighting better
      wrapTextChildrenInSpans(paragraph);
      return "true";
    } else {
      return "false";
    }
  };

  self.startHighlightAtPoint = function(x, y) {
    var touchedElement = document.elementFromPoint(x, y);
    if ($(touchedElement).hasClass("touchable") && !elementIsInsideHighlight(touchedElement)) {
      startElement = touchedElement;
      highlighter.beginHighlighting();
      return "true";
    } else {
      return "false";
    }
  };

  self.updateHighlightFeedbackToPoint = function(x, y) {
    var touchedElement = document.elementFromPoint(x, y);
    if ($(touchedElement).hasClass("touchable") && !rangeContainsHighlight(startElement, touchedElement)){
      endElement = touchedElement;
      highlighter.createHighlightWithStartAndEndElements(startElement, endElement);
      highlighter.currentHighlight.focus();
    }
  };

  self.touchesEnded = function() {
    if (startElement && endElement) {
      highlighter.createPersistentHighlightWithStartAndEndElements(startElement, endElement);
    }
    unwrapTextChildren();
    startElement = null;
    endElement = null;
  };

  return self;
	
	
  function elementIsInsideHighlight(element) {
    var highlightedParents = $(element).parents('.highlighted');
    return (highlightedParents != null && highlightedParents.length > 0);
  }
  
  function rangeContainsHighlight(startElement, endElement) {
    var range = document.createRange();
    range.setStartBefore(startElement);
    range.setEndAfter(endElement);
    if (range.collapsed) {
      range.setStartBefore(endElement);
      range.setEndAfter(startElement);
    }
    
    var overlapping = isRangeOverlappingExistingHighlight(range);
    return overlapping;
  }


  function isRangeOverlappingExistingHighlight(range) {
    return (range.startContainer == range.endContainer && isSelfOrParentHighlighted(range)) || containsHighlighted(range);
  }
  
  
  function isSelfOrParentHighlighted(range) {
    return ($(range.startContainer.parentNode).hasClass('highlighted') && range.startContainer.parentNode.id != highlighter.currentHighlight.id)
    || ($(range.startContainer).hasClass('highlighted') && range.startContainer.id != highlighter.currentHighlight.id);
  }

  function containsHighlighted(range) {
    var highlights = range.cloneContents().querySelectorAll('.highlighted');
    if (highlights.length > 1) {
      return true;
    }
    else if (highlights.length == 1) {
      return highlights[0].id != highlighter.currentHighlight.id;
    }
    return false;
  }

  function wrapTextChildrenInSpans(element) {
    for (var i = 0; i < element.childNodes.length; ++i) {

      if (element.childNodes[i].nodeType === Node.TEXT_NODE) {
        var node = element.childNodes[i];
        var words = node.textContent.match(/\s*\S+\s?/gm);
        if (!words) {
          continue;
        }
        for (var j = 0; j < words.length; ++j) {
          var span = document.createElement("SPAN");
          var innerText = document.createTextNode(words[j]);
          span.className = "touchable";
          span.appendChild(innerText);
          element.insertBefore(span, node);
        }

        element.removeChild(node);

      } else if (element.childNodes[i].className !== "touchable") {
        wrapTextChildrenInSpans(element.childNodes[i]);
      }
    }
  }

  function unwrapTextChildren() {
    $(".touchable", paragraph).contents().unwrap();
  }
};
//$(document).ready(function() {
//});

Halo.removeAllUnhighlightedContent = function() {
	$('.sub-section > p, .sub-concept > p').each(function() {
		if ($(this).children('.highlighted:first').prev().length > 0) $(this).prepend('<span class=hellip> &hellip; </span>');
		//if ($(this).children('.highlighted:last').length > 0) $(this).append('<span class=hellip> &hellip; </span>');

		Halo.removeUnhighlightedContent(this);
		if ($(this).is(':empty')) {
            $(this).addClass("hellip");
			$(this).html('paragraph&hellip;');
		} else {
			$(this).contents().not('.hellip').after('<span class=hellip> &hellip; </span>');
		}
	});

//	$('.fig').removeClass('fig').addClass('fig-wide');

	var stylePath = '../../css/textbook-summary.css';
	$('head').append('<link rel="stylesheet" type="text/css" href="' + stylePath + '"/>');
    return true;
};

Halo.removeUnhighlightedContent = function(element) {
	var removedAll = true;
	$(element).contents().filter(function() {
		if (this.nodeType == 3) {
			return true;
		} else {
			if ($(this).hasClass('highlighted') || $(this).hasClass('hellip')) {
				return removedAll = false;
			} else {
				var removedAllChildren = Halo.removeUnhighlightedContent(this);
				removedAll &= removedAllChildren;
				return removedAllChildren;
			}
		}
	}).remove();
	return removedAll;
};function log(str) {
  var $log = $('#__log__');
  if (!$log.length) {
    var style = "display:block;background-color:rgba(0,0,0,0.7);color:rgba(0,255,0,1.0);float:left;position:absolute;width:768px;height:300px;top:704px;left:0;";
    $(document.body).append('<div id="__log__" style="' + style + '"></div>');
    $log = $('#__log__');
  }
  $log.prepend("<br/>" + str);
  console.error("=============>", str);
}

__original_console = console;
__original_error = console.error;
__original_log = console.log;

console = {
  msgs: new Array(),

  error: function() {
    var args = ['error: '];
    args.push.apply(args, arguments);
    console.msgs.push(args.join(' '));
    __original_error.apply(__original_console, arguments);
  },

  log: function() {
    var args = ['log: '];
    args.push.apply(args, arguments);
    console.msgs.push(args.join(' '));
    __original_log.apply(__original_console, arguments);
  },

  shift: function() {
    return console.msgs.shift();
  }
};
