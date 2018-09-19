(window.webpackJsonp=window.webpackJsonp||[]).push([[72],{Iptl:function(e,t,s){"use strict";var n=s("nS/B");t.a={components:{CommonNotice:function(){return s.e(117).then(s.bind(null,"mkLc"))},DocsExample:function(){return s.e(7).then(s.bind(null,"GD02"))},DocsComponentAPI:function(){return s.e(8).then(s.bind(null,"8txu"))}},computed:{doc:function(){var e=this.componentNamespace||"Components";return this.$store.getters.componentDoc[e][this.$options.name]||[]},summary:function(){return Object(n.b)(this.doc,"summary")},version:function(){return Object(n.b)(this.doc,"version")},description:function(){return Object(n.b)(this.doc,"description")},props:function(){return Object(n.a)(this.doc,"prop")},slots:function(){return Object(n.a)(this.doc,"slot")},events:function(){return Object(n.a)(this.doc,"event")},methods:function(){return Object(n.a)(this.doc,"method")}}}},uCJ7:function(e,t,s){"use strict";s.r(t);var n=s("Iptl"),o=s("7lnb"),i=s.n(o),r=s("6DIm"),a=s("0NuS"),c=s.n(a),u=s("t3kO"),h=s.n(u),l=s("6J4u"),p=s.n(l),d=s("wv3L"),m=s.n(d),v=s("tZmG"),_=s.n(v),f=s("OBCi"),b=s.n(f),y=s("q3sO"),g=s.n(y),P=s("PSh9"),w=s.n(P),C=s("Zv/C"),k=s.n(C),S=s("2lBV"),O=s.n(S),R=s("/9Wh"),T=s.n(R),I=s("akKz"),E=s.n(I),j=(s("5Nsu"),s("kmNX")),D=s.n(j),A=function(){function e(){k()(this,e),this._items=new g.a}return O()(e,[{key:"create",value:function(e,t,s){return this._rejectExistingRequest(e),this._createNewRequest(e,t,s)}},{key:"resolve",value:function(e,t){e&&this._items.has(e)&&this._items.get(e).resolve(t)}},{key:"reject",value:function(e,t){if(e&&this._items.has(e)){var s=new Error("Error getting valid response.");s.response=t,this._items.get(e).reject(s)}}},{key:"rejectAll",value:function(e){_()(this._items).forEach(function(t){return t.isPending?t.reject(e):null})}},{key:"_rejectExistingRequest",value:function(e){var t=this._items.get(e);t&&t.isPending&&t.reject(new Error("WebSocket request is replaced, id: "+e))}},{key:"_createNewRequest",value:function(e,t,s){var n=this,o=new E.a;return this._items.set(e,o),o.timeout(s,"WebSocket request was rejected by timeout ("+s+" ms). RequestId: "+e),D()(o.call(t),function(){return n._deleteRequest(e,o)})}},{key:"_deleteRequest",value:function(e,t){this._items.get(e)===t&&this._items.delete(e)}}]),e}(),M=s("tb9w"),q=function(){function e(){k()(this,e),this._messages={},this._lastUid=-1}return O()(e,[{key:"_callSubscriber",value:function(e,t){setTimeout(function(){return e(t)},0)}},{key:"_deliverMessage",value:function(e,t){var s=this;M.a.info("PubSub - _deliverMessage() - message",e),_()(this._messages).forEach(function(n){s._messageFilter(s._messages[n],e)&&s._callSubscriber(s._messages[n].function,t)})}},{key:"_messageFilter",value:function(e,t){return!(Object.prototype.hasOwnProperty.call(e,"codes")&&e.codes.indexOf(parseInt(t.code,10))<0)&&(!(Object.prototype.hasOwnProperty.call(e,"methods")&&e.methods.indexOf(t.method.toUpperCase())<0)&&(!(Object.prototype.hasOwnProperty.call(e,"types")&&e.types.indexOf(t.type.toUpperCase())<0)&&!(Object.prototype.hasOwnProperty.call(e,"path")&&!t.path.match(e.path))))}},{key:"_messageHasSubscribers",value:function(e){var t=this,s=0;return _()(this._messages).forEach(function(n){return t._messageFilter(t._messages[n],e)&&(s=1),!0}),1===s}},{key:"_createDeliveryFunction",value:function(e,t){var s=this;return function(){s._deliverMessage(e,t)}}},{key:"publish",value:function(e,t){var s=this;return Object.prototype.hasOwnProperty.call(e,"path")?Object.prototype.hasOwnProperty.call(e,"method")?Object.prototype.hasOwnProperty.call(e,"code")?Object.prototype.hasOwnProperty.call(e,"type")?(setTimeout(function(){s._messageHasSubscribers(e)&&s._createDeliveryFunction(e,t)()},0),!0):(M.a.error("PubSub.js - publish()",'Parameter "message" requires "type".'),!1):(M.a.error("PubSub.js - publish()",'Parameter "message" requires "code".'),!1):(M.a.error("PubSub.js - publish()",'Parameter "message" requires "method".'),!1):(M.a.error("PubSub.js - publish()",'Parameter "message" requires "path".'),!1)}},{key:"subscribe",value:function(e,t){var s=this;if("function"!=typeof t)return!1;var n="uid_"+String(++this._lastUid);return Object.prototype.hasOwnProperty.call(this._messages,n)||(this._messages[n]={}),this._messages[n].function=t,Object.prototype.hasOwnProperty.call(e,"path")&&(this._messages[n].path=new RegExp(e.path)),Object.prototype.hasOwnProperty.call(e,"methods")&&e.methods.length&&(this._messages[n].methods=[],_()(e.methods).forEach(function(t){s._messages[n].methods.push(e.methods[t].toUpperCase())})),Object.prototype.hasOwnProperty.call(e,"codes")&&e.codes.length&&(this._messages[n].codes=[],_()(e.codes).forEach(function(t){s._messages[n].codes.push(parseInt(e.codes[t],10))})),Object.prototype.hasOwnProperty.call(e,"types")&&e.types.length&&(this._messages[n].types=[],_()(e.types).forEach(function(t){s._messages[n].types.push(e.types[t].toUpperCase())})),{token:n,unsubscribe:function(){s.unsubscribe(n)}}}},{key:"clearAllSubscriptions",value:function(){this._messages={}}},{key:"unsubscribe",value:function(e){delete this._messages[e]}}]),e}(),x=function(e){var t="";return"object"!==(void 0===e?"undefined":m()(e))?t:(_()(e).forEach(function(s,n){t+=0===n?"?":"&";var o=e[s];switch(void 0===o?"undefined":m()(o)){case"object":Array.isArray(o)?o.forEach(function(e,n){n>0&&(t+="&"),t+=s+"="+encodeURIComponent(e)}):t+=s+"="+encodeURIComponent(T()(o));break;case"boolean":t+=s+"=",t+=o?1:0;break;case"string":case"number":default:t+=s+"="+encodeURIComponent(e[s])}}),t)},L=0,H=1,B=2,W=3,U={wsServer:{protocol:"ws:",hostname:"localhost",port:80,prefixPath:"",path:"/websocket"},xhrServer:{protocol:"http:",hostname:"localhost",port:80,prefixPath:""},primaryProtocol:"ws",createWebSocket:function(e){return new WebSocket(e)},packMessage:function(e){return T()(e)},unpackMessage:function(e){return JSON.parse(e)},attachRequestId:function(e,t){return e.RequestID=t,e},extractRequestId:function(e){return e&&e.RequestID},openTimeout:0,closeTimeout:0,responseTimeout:3e4,reconnect:!0,reconnectionDelayIncrement:1e3,maxReconnectionDelay:1e4,accessToken:"",throwError:!0},N=new(function(){function e(){k()(this,e),this._options=w()({},U),this._opening=new E.a,this._closing=new E.a,this._requests=new A,this._requestCount=0,this._ws=null,this._wsSubscription={},this._reconnectTimeoutId=null,this._reconnectionCount=0,this._reconnectionAttempt=0,this._reconnectionDelay=0,this._reconnectResetAttemptsTimeoutId=null,this._pubSub=new q,this._eventListeners=new g.a}return O()(e,[{key:"open",value:function(){var e=this;return"ws"!==this._options.primaryProtocol?(M.a.debug("APIClient: WebSocket connection disabled, check the configuration."),b.a.resolve()):this.isClosing?b.a.reject(new Error("Can't open WebSocket while closing.")):this.isOpened?this._opening.promise:(M.a.info("APIClient: Opening WebSocket connection..."),this._opening.call(function(){var t=e._options.openTimeout;e._opening.timeout(t,"Can't open WebSocket within allowed timeout: "+t+" ms."),e._opening.promise.catch(function(t){return e._cleanup(t)}),e._createWS()}))}},{key:"_reconnect",value:function(){var e=this;this._options.reconnect?(this._reconnectionDelay=this._reconnectionAttempt*this._options.reconnectionDelayIncrement,(this._reconnectionDelay>this._options.maxReconnectionDelay||this._options.fixedReconnectionDelay)&&(this._reconnectionDelay=this._options.maxReconnectionDelay),M.a.info("APIClient: Trying to reconnect in "+this._reconnectionDelay/1e3+"s"),this._reconnectionCount++,this._reconnectionAttempt++,clearTimeout(this._reconnectTimeoutId),this._reconnectTimeoutId=setTimeout(function(){e.open()},this._reconnectionDelay)):this._reconnectTimeoutId&&clearTimeout(this._reconnectTimeoutId)}},{key:"sendRequest",value:function(e){var t=this,s=arguments.length>1&&void 0!==arguments[1]?arguments[1]:{},n=void 0!==s.responseTimeout?s.responseTimeout:this._options.responseTimeout;["Path","Method"].forEach(function(t){e[t]||M.a.error("APIClient: key '"+t+"' in param 'data' of the sendRequest() is required!")});var o=e.Path;if(e.Method=e.Method.toUpperCase(),e.Body&&_()(e.Body).length&&("GET"===e.Method||"HEAD"===e.Method)&&M.a.error("APIClient: method "+e.Method+" does not support body parameters!",e),!s.skipAuthentication&&this._options.accessToken&&(Object.prototype.hasOwnProperty.call(e,"Headers")||(e.Headers={}),e.Headers.Authentication="Bearer "+this._options.accessToken),"debug"===M.a.options.logLevel&&(Object.prototype.hasOwnProperty.call(e,"Headers")||(e.Headers={}),e.Headers["X-OTRS-API-Debug"]="true"),e.Query&&(e.Path+=x(e.Query)),"xhr"===this._options.primaryProtocol&&(s.xhr=!0),this._isJsonReady(e.Body)||s.xhr||(s.xhr=!0,M.a.debug("APIClient: Falling back to XHR because of body unsuitable for JSON conversion:",e.Body)),s.xhr)return this._sendXHR(e,o,s,n);var i=s.requestId||++this._requestCount;return this._requests.create(i,function(){var s=t._options.attachRequestId(e,i);t._sendPacked(s,o)},n)}},{key:"_sendXHR",value:function(e,t,s,n){var o=this,i=new XMLHttpRequest,r=new E.a,a=this._options.xhrServer,c=a.protocol+"//"+a.hostname+":"+a.port+a.prefixPath+"/",u=void 0!==s.apiPrefix?s.apiPrefix:"api/",h=s&&s.responseType||"json";return r.timeout(n,"Didn't get XHR response within allowed timeout ("+n+" ms)."),r.call(function(){"function"==typeof s.onUploadProgress&&i.upload.addEventListener("progress",s.onUploadProgress),i.addEventListener("load",function(){var s=i.response;s&&"json"===h&&"object"!==(void 0===s?"undefined":m()(s))&&(s=JSON.parse(i.response));var n={Path:t,Method:Object.prototype.hasOwnProperty.call(e,"Method")?e.Method:"GET",Code:i.status,Body:s};if(i.status>=200&&i.status<300)r.resolve(n);else{var a=new Error("Error getting valid response.");a.response=n,r.reject(a)}M.a.debug("APIClient: Received XHR "+n.Method+" response for "+n.Path+":",n);var c={path:n.Path,method:n.Method,code:n.Code,type:"response"};i.getResponseHeader("X-OTRS-API-Debug-SQLTrace")&&o._debugSQL(i.getResponseHeader("X-OTRS-API-Debug-SQLTrace"),c),i.getResponseHeader("X-OTRS-API-Debug-STDERRLog")&&o._debugSTDERR(i.getResponseHeader("X-OTRS-API-Debug-STDERRLog"),c),o._pubSub.publish(c,n),o._dispatchEvent(new CustomEvent("message",{detail:n}))}),i.addEventListener("error",function(){return r.reject(i.statusText)}),i.addEventListener("abort",function(){return r.reject(i.statusText)}),i.open(e.Method||"GET",c+u+e.Path,!0),"XMLHttpRequest"===i.constructor.name&&(i.responseType=h),e.Headers&&_()(e.Headers).forEach(function(t){i.setRequestHeader(t,e.Headers[t])}),o._isJsonReady(e.Body)?i.send(T()(e.Body)):i.send(e.Body);var n={Path:t,Method:Object.prototype.hasOwnProperty.call(e,"Method")?e.Method:"GET",Code:200,Type:"request"};o._pubSub.publish({path:n.Path,method:n.Method,code:n.Code,type:n.Type},n),M.a.debug("APIClient: Sent XHR "+e.Method+" request to "+e.Path+":",e)})}},{key:"_isJsonReady",value:function(e){return!e||!(e instanceof FormData)}},{key:"_sendPacked",value:function(e,t){var s=this._options.packMessage(e);this._send(s,t)}},{key:"_send",value:function(e,t){var s=this;if(this.isOpened){this._ws.send(e);var n=this._options.unpackMessage(e),o={Path:t,Method:Object.prototype.hasOwnProperty.call(n,"Method")?e.Method:"GET",Code:200,Type:"request"};this._pubSub.publish({path:o.Path,method:o.Method,code:o.Code,type:o.Type},o),M.a.debug("APIClient: Sent WS "+n.Method+" request to "+n.Path+":",n)}else if(this._options.reconnect)setTimeout(function(){s._send(e)},this._reconnectionDelay);else if(this._options.throwError)throw new Error("Can't send data because WebSocket is not opened.")}},{key:"subscribe",value:function(e,t){var s=this._pubSub.subscribe(e,t);return M.a.debug("APIClient: Subscribed as "+s.token),s}},{key:"unsubscribe",value:function(e){var t=this;return Array.isArray(e)?_()(e).forEach(function(s){M.a.debug("APIClient: Unsubscribing "+e[s]),t._pubSub.unsubscribe(e[s])}):(M.a.debug("APIClient: Unsubscribing "+e),this._pubSub.unsubscribe(e)),!0}},{key:"close",value:function(){var e=this;return"ws"!==this._options.primaryProtocol?(M.a.debug("APIClient: WebSocket connection disabled, check the configuration."),b.a.resolve()):this.isClosed?b.a.resolve(this._closing.value):(M.a.info("APIClient: Closing WebSocket connection..."),this._closing.call(function(){var t=e._options.closeTimeout;e._closing.timeout(t,"Can't close WebSocket within allowed timeout: "+t+" ms."),e._ws.close()}))}},{key:"_createWS",value:function(){var e=this,t=this._options.wsServer,s=t.protocol+"//"+t.hostname+":"+t.port+t.prefixPath+t.path;this._ws=this._options.createWebSocket(s),["open","message","error","close"].forEach(function(t){var s="_handle"+(t.charAt(0).toUpperCase()+t.slice(1));e._ws.addEventListener(t,function(t){e[s](t)}),e._wsSubscription[t]=s})}},{key:"_handleOpen",value:function(e){var t=this;this._reconnectResetAttemptsTimeoutId=setTimeout(function(){t._reconnectionAttempt=0},this._options.reconnectionDelayIncrement),M.a.info("APIClient: WebSocket connected!"),this._opening.resolve(e),this._dispatchEvent(new CustomEvent("open"))}},{key:"_handleMessage",value:function(e){var t=e.data;this._handleUnpackedMessage(t)}},{key:"_handleUnpackedMessage",value:function(e){if(this._options.unpackMessage){var t=this._options.unpackMessage(e);void 0!==t&&(M.a.debug("APIClient: Received WS "+t.Method+" message for "+t.Path+":",t),this._handleResponse(t))}}},{key:"_handleResponse",value:function(e){if(this._options.extractRequestId){var t=this._options.extractRequestId(e);t&&(e.Code>=200&&e.Code<300?this._requests.resolve(t,e):this._requests.reject(t,e));var s={path:Object.prototype.hasOwnProperty.call(e,"Path")?e.Path:"",method:Object.prototype.hasOwnProperty.call(e,"Method")?e.Method:"",code:Object.prototype.hasOwnProperty.call(e,"Code")?e.Code:"",type:"response"};e.Headers&&e.Headers["X-OTRS-API-Debug-SQLTrace"]&&this._debugSQL(e.Headers["X-OTRS-API-Debug-SQLTrace"],s),e.Headers&&e.Headers["X-OTRS-API-Debug-STDERRLog"]&&this._debugSTDERR(e.Headers["X-OTRS-API-Debug-STDERRLog"],s),this._pubSub.publish(s,e),this._dispatchEvent(new CustomEvent("message",{detail:e}))}}},{key:"_handleError",value:function(){clearTimeout(this._reconnectResetAttemptsTimeoutId),this._reconnectResetAttemptsTimeoutId=null}},{key:"_handleClose",value:function(e){this._reconnect(),this._closing.resolve(e);var t=new Error("WebSocket closed with reason: "+e.reason+" ("+e.code+").");this._opening.isPending&&this._opening.reject(t),this._cleanup(t),this._dispatchEvent(new CustomEvent("close",{detail:t}))}},{key:"_cleanupWS",value:function(){var e=this;this._ws&&(["open","message","error","close"].forEach(function(t){e._ws.removeEventListener(t,e[e._wsSubscription[t]])}),this._ws=null,this._wsSubscription={})}},{key:"_cleanup",value:function(e){this._cleanupWS(),this._requests.rejectAll(e)}},{key:"addEventListener",value:function(e,t){return!!/^(open|message|close)$/.test(e)&&("function"==typeof t&&(this._eventListeners.set(t.bind(this),{type:e,listener:t}),!0))}},{key:"removeEventListener",value:function(e,t){if(!/^(open|message|close)$/.test(e))return!1;if("function"!=typeof t)return!1;var s=!0,n=!1,o=void 0;try{for(var i,r=h()(this._eventListeners);!(s=(i=r.next()).done);s=!0){var a=i.value,c=p()(a,2),u=c[0],l=c[1];l.type===e&&t===l.listener&&this._eventListeners.delete(u)}}catch(e){n=!0,o=e}finally{try{!s&&r.return&&r.return()}finally{if(n)throw o}}return!0}},{key:"_dispatchEvent",value:function(e){Object.defineProperty(e,"target",{value:this});var t="on"+e.type;this[t]&&this[t](e);var s=!0,n=!1,o=void 0;try{for(var i,r=h()(this._eventListeners);!(s=(i=r.next()).done);s=!0){var a=i.value,c=p()(a,2),u=c[0];c[1].type===e.type&&u(e)}}catch(e){n=!0,o=e}finally{try{!s&&r.return&&r.return()}finally{if(n)throw o}}}},{key:"_debugSQL",value:function(e,t){var s=JSON.parse(e),n=s.length;if(n){var o=0;s.forEach(function(e){o+=e.Time}),o=o.toFixed(4),M.a.debug(t.method.toUpperCase()+" message for "+t.path+" caused "+n+" SQL statements in "+o+"s: ",s)}}},{key:"_debugSTDERR",value:function(e,t){var s=JSON.parse(e),n=s.length;n&&M.a.debug(t.method.toUpperCase()+" message for "+t.path+" wrote "+n+" STDERR messages",s)}},{key:"options",get:function(){return this._options},set:function(e){this._options=w()({},this._options,e)}},{key:"isOpening",get:function(){return Boolean(this._ws&&this._ws.readyState===L)}},{key:"isOpened",get:function(){return Boolean(this._ws&&this._ws.readyState===H)}},{key:"isClosing",get:function(){return Boolean(this._ws&&this._ws.readyState===B)}},{key:"isClosed",get:function(){return Boolean(!this._ws||this._ws.readyState===W)}}]),e}());r.default.use(c.a,{color:"#8fffc7",failedColor:"#ff0000",autoFinish:!1});var X={name:"CommonProgressBar",props:{testMode:{type:Boolean,default:!1}},data:function(){return{internalCounter:0,activeProgressBar:!1,errors:!1,intervalId:void 0,now:0,startTime:0}},computed:{counter:{get:function(){return this.internalCounter},set:function(e){var t=this;this.internalCounter=e,e>0?setTimeout(function(){!t.activeProgressBar&&t.internalCounter>0&&t.start()},150):0===e&&setTimeout(function(){t.activeProgressBar&&0===t.internalCounter&&t.finish()},300)}}},created:function(){var e=this;this.testMode?setInterval(function(){setTimeout(function(){e.increment(),setTimeout(function(){e.decrement({Code:200})},2e3)},500)},3e3):(new MutationObserver(function(t){t.forEach(function(t){i()(t.addedNodes).forEach(function(t){if(/^SCRIPT|LINK$/.test(t.tagName)){e.increment();var s=e;t.addEventListener("load",function(){s.decrement({Code:200}),t.removeEventListener("load",this)})}})})}).observe(document.head,{childList:!0}),N.subscribe({types:["request"]},function(){e.increment()}),N.subscribe({types:["response"]},function(t){e.decrement(t)}),this.$bus.$on("progressBarShow",function(){e.increment()}),this.$bus.$on("progressBarHide",function(){e.decrement({Code:200})}))},methods:{increment:function(){this.counter++},decrement:function(e){e.Code&&500!==e.Code||(this.errors=!0),0!==this.counter&&this.counter--},start:function(){var e=this;this.$Progress.start(),this.now=Date.now(),this.startTime=this.now,this.activeProgressBar=!0,this.intervalId=setInterval(function(){e.now=Date.now(),e.activeProgressBar&&e.now-e.startTime>=3e4?e.finish():e.activeProgressBar||clearInterval(e.intervalId)},1e3)},finish:function(){this.errors?(this.$Progress.fail(),this.errors=!1):this.$Progress.finish(),this.startTime=0,this.activeProgressBar=!1,clearInterval(this.intervalId)}}},$=s("psIG"),J=Object($.a)(X,function(){var e=this.$createElement;return(this._self._c||e)("vue-progress-bar")},[],!1,null,null,null);J.options.__file="CommonProgressBar.vue";var Q=J.exports,F={name:"CommonProgressBar",mixins:[n.a],data:function(){return{docVersion:"1.0.1",componentNamespace:"Components",componentPath:"Components/Common/CommonProgressBar",component:Q,example:{testMode:{default:!0}},customCode:[{tag:"p",value:"Take a look at the top of this window."}]}}},G=Object($.a)(F,function(){var e=this,t=e.$createElement,s=e._self._c||t;return s("div",{staticClass:"main"},[s("h1",{staticClass:"design-system"},[e._v("\n        "+e._s(e.summary)+"\n        "),s("b-badge",{attrs:{variant:e.docVersion!==e.version?"warning":"info"}},[e._v(e._s(e.version))])],1),e._v(" "),s("p",[e._v("\n        "+e._s(e.description)+"\n    ")]),e._v(" "),e.docVersion!==e.version?[s("CommonNotice",{attrs:{text:"Please verify all changes to the component API have been properly documented\n                ("+e.docVersion+" !== "+e.version+").",title:"Documentation for this component is out of date!",type:"Warning"}})]:e._e(),e._v(" "),s("CommonNotice",{attrs:{type:"Warning",title:"Under construction",text:"Please be aware that the documentation of this component is currently under construction."}}),e._v(" "),s("h2",{staticClass:"design-system"},[e._v("\n        Semi-automatic Mode\n    ")]),e._v(" "),s("p",[e._v("\n        While the component monitors network for any API requests and responses, it is still possible to activate it\n        manually. Just emit on the global event bus in order to start the progress bar:\n    ")]),e._v(" "),s("pre",{staticClass:"design-system"},[e._v("this.$bus.$emit('progressBarShow');")]),e._v(" "),s("p",[e._v("In order to stop it, emit a different event:")]),e._v(" "),s("pre",{staticClass:"design-system"},[e._v("this.$bus.$emit('progressBarHide');")]),e._v(" "),s("b-tabs",{staticClass:"tab-content"},[s("b-tab",{staticClass:"tab-pane",attrs:{title:"Demo","title-link-class":"design-system",active:""}},[s("DocsExample",{attrs:{component:e.component,"component-path":e.componentPath,"custom-code":e.customCode,props:e.props,events:e.events,slots:e.slots,example:e.example}})],1),e._v(" "),s("b-tab",{attrs:{title:"Usage","title-link-class":"design-system"}},[s("h2",{staticClass:"design-system"},[e._v("Header Level 2")]),e._v(" "),s("ol",{staticClass:"design-system"},[s("li",[e._v("Lorem ipsum dolor sit amet, consectetuer adipiscing elit.")]),e._v(" "),s("li",[e._v("Aliquam tincidunt mauris eu risus.")])]),e._v(" "),s("b-container",{staticClass:"dosdonts",attrs:{fluid:""}},[s("b-row",[s("b-col",{attrs:{sm:"6"}},[s("div",[s("h5",{staticClass:"design-system"},[e._v("Do")]),e._v(" "),s("p",[e._v("Lorem ipsum dolor sit amet, consectetuer adipiscing ept.")])])]),e._v(" "),s("b-col",{attrs:{sm:"6"}},[s("div",[s("h5",{staticClass:"design-system"},[e._v("Don't")]),e._v(" "),s("p",[e._v("Lorem ipsum dolor sit amet, consectetuer adipiscing ept.")])])])],1)],1),e._v(" "),s("h3",{staticClass:"design-system"},[e._v("Header Level 3")]),e._v(" "),s("ul",{staticClass:"design-system"},[s("li",[e._v("Lorem ipsum dolor sit amet, consectetuer adipiscing elit.")]),e._v(" "),s("li",[e._v("Aliquam tincidunt mauris eu risus.")])])],1),e._v(" "),s("b-tab",{staticClass:"tab-pane",attrs:{title:"API Documentation","title-link-class":"design-system"}},[s("DocsComponentAPI",{attrs:{props:e.props,events:e.events,slots:e.slots,methods:e.methods}})],1)],1)],2)},[],!1,null,null,null);G.options.__file="CommonProgressBar.vue";t.default=G.exports}}]);