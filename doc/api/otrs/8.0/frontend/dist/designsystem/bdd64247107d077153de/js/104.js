(window.webpackJsonp=window.webpackJsonp||[]).push([[104],{Iptl:function(e,t,n){"use strict";n("GkPX");var o=n("nS/B");t.a={components:{CommonNotice:function(){return n.e(113).then(n.bind(null,"mkLc"))},DocsExample:function(){return n.e(10).then(n.bind(null,"GD02"))},DocsComponentAPI:function(){return n.e(11).then(n.bind(null,"8txu"))}},computed:{doc:function(){var e=this.componentNamespace||"Components";return this.$store.getters.componentDoc[e][this.$options.name]||[]},summary:function(){return Object(o.b)(this.doc,"summary")},version:function(){return Object(o.b)(this.doc,"version")},description:function(){return Object(o.b)(this.doc,"description")},props:function(){return Object(o.a)(this.doc,"prop")},slots:function(){return Object(o.a)(this.doc,"slot")},events:function(){return Object(o.a)(this.doc,"event")},methods:function(){return Object(o.a)(this.doc,"method")}},mounted:function(){var e=this;this.$nextTick(function(){e.$test.setFlag("DocComponent::".concat(e.component.name,"::Mounted"))})}}},uCJ7:function(e,t,n){"use strict";n.r(t);var o=n("Iptl"),s=(n("lQyR"),n("YhIr"),n("W1QL"),n("6DIm")),r=n("0NuS"),i=n.n(r),a=n("nxTg"),c=n.n(a),u=(n("+jjx"),n("ABKx"),n("GkPX"),n("e+GP")),h=n.n(u),p=(n("75LO"),n("Z8gF"),n("DbwS"),n("K/PF"),n("zx98"),n("5hJT"),n("SDJZ")),l=n.n(p),d=n("NToG"),m=n.n(d),f=n("akKz"),v=n.n(f),g=(n("5Nsu"),n("kmNX")),y=n.n(g),b=function(){function e(){l()(this,e),this._items=new Map}return m()(e,[{key:"create",value:function(e,t,n){return this._rejectExistingRequest(e),this._createNewRequest(e,t,n)}},{key:"resolve",value:function(e,t){e&&this._items.has(e)&&this._items.get(e).resolve(t)}},{key:"reject",value:function(e,t){if(e&&this._items.has(e)){var n=new Error("Error getting valid response.");n.response=t,this._items.get(e).reject(n)}}},{key:"rejectAll",value:function(e){Object.keys(this._items).forEach(function(t){return t.isPending?t.reject(e):null})}},{key:"_rejectExistingRequest",value:function(e){var t=this._items.get(e);t&&t.isPending&&t.reject(new Error("WebSocket request is replaced, id: ".concat(e)))}},{key:"_createNewRequest",value:function(e,t,n){var o=this,s=new v.a;return this._items.set(e,s),s.timeout(n,"WebSocket request was rejected by timeout (".concat(n," ms). RequestId: ").concat(e)),y()(s.call(t),function(){return o._deleteRequest(e,s)})}},{key:"_deleteRequest",value:function(e,t){this._items.get(e)===t&&this._items.delete(e)}}]),e}(),_=(n("J8hF"),n("9ovy"),n("tb9w")),P=function(){function e(){l()(this,e),this._messages={},this._lastUid=-1}return m()(e,[{key:"_callSubscriber",value:function(e,t){setTimeout(function(){return e(t)},0)}},{key:"_deliverMessage",value:function(e,t){var n=this;_.a.debug("PubSub - _deliverMessage() - message",e),Object.keys(this._messages).forEach(function(o){n._messageFilter(n._messages[o],e)&&n._callSubscriber(n._messages[o].function,t)})}},{key:"_messageFilter",value:function(e,t){return!(Object.prototype.hasOwnProperty.call(e,"codes")&&e.codes.indexOf(parseInt(t.code,10))<0)&&(!(Object.prototype.hasOwnProperty.call(e,"methods")&&e.methods.indexOf(t.method.toUpperCase())<0)&&(!(Object.prototype.hasOwnProperty.call(e,"types")&&e.types.indexOf(t.type.toUpperCase())<0)&&!(Object.prototype.hasOwnProperty.call(e,"path")&&!t.path.match(e.path))))}},{key:"_messageHasSubscribers",value:function(e){var t=this,n=0;return Object.keys(this._messages).forEach(function(o){return t._messageFilter(t._messages[o],e)&&(n=1),!0}),1===n}},{key:"_createDeliveryFunction",value:function(e,t){var n=this;return function(){n._deliverMessage(e,t)}}},{key:"publish",value:function(e,t){var n=this;return Object.prototype.hasOwnProperty.call(e,"path")?Object.prototype.hasOwnProperty.call(e,"method")?Object.prototype.hasOwnProperty.call(e,"code")?Object.prototype.hasOwnProperty.call(e,"type")?(setTimeout(function(){n._messageHasSubscribers(e)&&n._createDeliveryFunction(e,t)()},0),!0):(_.a.error("PubSub.js - publish()",'Parameter "message" requires "type".'),!1):(_.a.error("PubSub.js - publish()",'Parameter "message" requires "code".'),!1):(_.a.error("PubSub.js - publish()",'Parameter "message" requires "method".'),!1):(_.a.error("PubSub.js - publish()",'Parameter "message" requires "path".'),!1)}},{key:"subscribe",value:function(e,t){var n=this;if("function"!=typeof t)return!1;var o="uid_".concat(String(++this._lastUid));return Object.prototype.hasOwnProperty.call(this._messages,o)||(this._messages[o]={}),this._messages[o].function=t,Object.prototype.hasOwnProperty.call(e,"path")&&(this._messages[o].path=new RegExp(e.path)),Object.prototype.hasOwnProperty.call(e,"methods")&&e.methods.length&&(this._messages[o].methods=[],Object.keys(e.methods).forEach(function(t){n._messages[o].methods.push(e.methods[t].toUpperCase())})),Object.prototype.hasOwnProperty.call(e,"codes")&&e.codes.length&&(this._messages[o].codes=[],Object.keys(e.codes).forEach(function(t){n._messages[o].codes.push(parseInt(e.codes[t],10))})),Object.prototype.hasOwnProperty.call(e,"types")&&e.types.length&&(this._messages[o].types=[],Object.keys(e.types).forEach(function(t){n._messages[o].types.push(e.types[t].toUpperCase())})),{token:o,unsubscribe:function(){n.unsubscribe(o)}}}},{key:"clearAllSubscriptions",value:function(){this._messages={}}},{key:"unsubscribe",value:function(e){delete this._messages[e]}}]),e}(),w=(n("it7j"),n("U8p0"),n("4aJ6"),new(function(){function e(){l()(this,e),this._registry={}}return m()(e,[{key:"enable",value:function(e,t){if(!(e instanceof RegExp||"string"==typeof e&&0!==e.length))throw new Error("invalid value for 'path' parameter, regexp or string is expected.");if("string"!=typeof t||0===t.length)throw new Error("invalid value for 'profile' parameter, string is expected");return this._registry[e.toString()]={type:e instanceof RegExp?"regexp":"string",name:t},!0}},{key:"disable",value:function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:null;if(null==e)return this._registry={},!0;if(!(e instanceof RegExp||"string"==typeof e&&0!==e.length))throw new Error("invalid value for 'path' parameter, regexp or string is expected.");return delete this._registry[e.toString()],!0}},{key:"profileForPath",value:function(e){var t=this;if(!(e instanceof RegExp||"string"==typeof e&&0!==e.length))throw new Error("invalid value for 'path' parameter, regexp or string is expected.");var n=Object.keys(this._registry).sort().reverse().find(function(n){var o=n;if("regexp"===t._registry[n].type){var s=o.match(/^\/(.*)\/([^\/]*)$/);o=new RegExp(s[1],s[2])}return!!e.match(o)});return n?this._registry[n].name:null}},{key:"addFromObject",value:function(e){var t=this;return Object.keys(e).forEach(function(n){t._registry[n]={type:e[n].type,name:e[n].name}}),!0}},{key:"toObject",value:function(){return JSON.parse(JSON.stringify(this._registry))}}]),e}())),k=function(e){var t="";return"object"!==h()(e)?t:(Object.keys(e).forEach(function(n,o){t+=0===o?"?":"&";var s=e[n];switch(h()(s)){case"object":Array.isArray(s)?s.forEach(function(e,o){o>0&&(t+="&"),t+="".concat(n,"=").concat(encodeURIComponent(e))}):t+="".concat(n,"=").concat(encodeURIComponent(JSON.stringify(s)));break;case"boolean":t+="".concat(n,"="),t+=s?1:0;break;case"string":case"number":default:t+="".concat(n,"=").concat(encodeURIComponent(e[n]))}}),t)},S=0,C=1,O=2,I=3,R={wsServer:{protocol:"ws:",hostname:"localhost",port:80,prefixPath:"",path:"/websocket"},xhrServer:{protocol:"http:",hostname:"localhost",port:80,prefixPath:""},primaryProtocol:"xhr",webSocketUpgrade:!0,createWebSocket:function(e){var t;try{t=new WebSocket(e)}catch(t){_.a.error("APIClient: Error connecting to '".concat(e,"'!"),t)}return t},packMessage:function(e){return JSON.stringify(e)},unpackMessage:function(e){return JSON.parse(e)},attachRequestId:function(e,t){return e.RequestID=t,e},extractRequestId:function(e){return e&&e.RequestID},openTimeout:0,closeTimeout:0,responseTimeout:3e4,reconnect:!0,reconnectionDelayIncrement:1e3,maxReconnectionDelay:1e4,maxReconnectionAttempts:10,accessToken:"",throwError:!0},T=new(function(){function e(){l()(this,e),this._options=Object.assign({},R),this._opening=new v.a,this._closing=new v.a,this._requests=new b,this._requestCount=0,this._ws=null,this._wsSubscription={},this._reconnectTimeoutId=null,this._reconnectionCount=0,this._reconnectionAttempt=0,this._reconnectionDelay=0,this._reconnectResetAttemptsTimeoutId=null,this._pubSub=new P,this._eventListeners=new Map}return m()(e,[{key:"open",value:function(){var e=this;return this.options.webSocketUpgrade?this.isClosing?(this._downgradeProtocol(),Promise.reject(new Error("Can't open WebSocket while closing."))):this.isOpened?this._opening.promise:(_.a.info("APIClient: Opening WebSocket connection..."),this._opening.call(function(){var t=e.options.openTimeout;e._opening.timeout(t,"Can't open WebSocket within allowed timeout: ".concat(t," ms.")),e._opening.promise.catch(function(t){return e._cleanup(t)}),e._createWS()})):(_.a.debug("APIClient: WebSocket protocol disabled, the connection cannot be open."),Promise.resolve())}},{key:"_reconnect",value:function(){var e=this;if(this.options.reconnect){if(this._reconnectionAttempt>=this.options.maxReconnectionAttempts)return this._reconnectTimeoutId&&clearTimeout(this._reconnectTimeoutId),_.a.debug("APIClient: Reconnection attempt limit reached (".concat(this._reconnectionAttempt,"), giving up.")),void(this._reconnectionAttempt=0);this._reconnectionDelay=this._reconnectionAttempt*this.options.reconnectionDelayIncrement,(this._reconnectionDelay>this.options.maxReconnectionDelay||this.options.fixedReconnectionDelay)&&(this._reconnectionDelay=this.options.maxReconnectionDelay),_.a.info("APIClient: Trying to reconnect in ".concat(this._reconnectionDelay/1e3,"s")),this._reconnectionCount++,this._reconnectionAttempt++,clearTimeout(this._reconnectTimeoutId),this._reconnectTimeoutId=setTimeout(function(){e.open()},this._reconnectionDelay)}else this._reconnectTimeoutId&&clearTimeout(this._reconnectTimeoutId)}},{key:"sendRequest",value:function(e){var t=this,n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:{},o=void 0!==n.responseTimeout?n.responseTimeout:this.options.responseTimeout;["Path","Method"].forEach(function(t){e[t]||_.a.error("APIClient: key '".concat(t,"' in param 'data' of the sendRequest() is required!"))}),e.Path=e.Path.replace(/^[/]/,""),n.apiPrefix&&!/[/]$/.test(n.apiPrefix)&&(n.apiPrefix+="/");var s=e.Path;e.Method=e.Method.toUpperCase(),e.Body&&Object.keys(e.Body).length&&("GET"===e.Method||"HEAD"===e.Method)&&_.a.error("APIClient: method ".concat(e.Method," does not support body parameters!"),e),Object.prototype.hasOwnProperty.call(e,"Headers")||(e.Headers={}),!n.skipAuthentication&&this.options.accessToken&&(e.Headers.Authentication="Bearer ".concat(this.options.accessToken)),"debug"===_.a.options.logLevel&&(e.Headers["X-OTRS-API-Debug"]="true"),e.Query&&(e.Path+=k(e.Query));var r=w.profileForPath(e.Path);if(r&&(e.Headers["X-OTRS-API-Debug-PerlProfiler"]=r),"xhr"===this.options.primaryProtocol&&(n.xhr=!0),this._isJsonReady(e.Body)||n.xhr||(n.xhr=!0,_.a.debug("APIClient: Falling back to XHR because of body unsuitable for JSON conversion:",e.Body)),n.xhr)return this._sendXHR(e,s,n,o);var i=n.requestId||++this._requestCount;return this._requests.create(i,function(){var n=t.options.attachRequestId(e,i);t._sendPacked(n,s)},o)}},{key:"_sendXHR",value:function(e,t,n,o){var s=this,r=new XMLHttpRequest,i=new v.a,a=this.options.xhrServer,c=a.port?":".concat(a.port):"",u="".concat(a.protocol,"//").concat(a.hostname).concat(c).concat(a.prefixPath,"/"),p=void 0!==n.apiPrefix?n.apiPrefix:"api/",l=n&&n.responseType||"json";return i.timeout(o,"Didn't get XHR response within allowed timeout (".concat(o," ms).")),i.call(function(){"function"==typeof n.onUploadProgress&&r.upload.addEventListener("progress",n.onUploadProgress),r.addEventListener("load",function(){var n=r.response;n&&"json"===l&&"object"!==h()(n)&&(n=JSON.parse(r.response));var o={Path:t,Method:Object.prototype.hasOwnProperty.call(e,"Method")?e.Method:"GET",Code:r.status,Body:n};if(r.status>=200&&r.status<300)i.resolve(o);else{var a=new Error("Error getting valid response.");a.response=o,i.reject(a)}_.a.debug("APIClient: Received XHR ".concat(o.Method," response for ").concat(o.Path,":"),o);var c={path:o.Path,method:o.Method,code:o.Code,type:"response"};r.getResponseHeader("X-OTRS-API-Debug-SQLTrace")&&s._debugSQL(r.getResponseHeader("X-OTRS-API-Debug-SQLTrace"),c),r.getResponseHeader("X-OTRS-API-Debug-STDERRLog")&&s._debugSTDERR(r.getResponseHeader("X-OTRS-API-Debug-STDERRLog"),c),s._pubSub.publish(c,o),s._dispatchEvent(new CustomEvent("message",{detail:o}))}),r.addEventListener("error",function(){return i.reject(r.statusText)}),r.addEventListener("abort",function(){return i.reject(r.statusText)}),r.open(e.Method||"GET",u+p+e.Path,!0),"XMLHttpRequest"===r.constructor.name&&(r.responseType=l),e.Headers&&Object.keys(e.Headers).forEach(function(t){r.setRequestHeader(t,e.Headers[t])}),s._isJsonReady(e.Body)?r.send(JSON.stringify(e.Body)):r.send(e.Body);var o={Path:t,Method:Object.prototype.hasOwnProperty.call(e,"Method")?e.Method:"GET",Code:200,Type:"request"};s._pubSub.publish({path:o.Path,method:o.Method,code:o.Code,type:o.Type},o),_.a.debug("APIClient: Sent XHR ".concat(e.Method," request to ").concat(e.Path,":"),e)})}},{key:"_isJsonReady",value:function(e){return!e||!(e instanceof FormData)}},{key:"_sendPacked",value:function(e,t){var n=this.options.packMessage(e);this._send(n,t)}},{key:"_send",value:function(e,t){var n=this;if(this.isOpened){this._ws.send(e);var o=this.options.unpackMessage(e),s={Path:t,Method:Object.prototype.hasOwnProperty.call(o,"Method")?e.Method:"GET",Code:200,Type:"request"};this._pubSub.publish({path:s.Path,method:s.Method,code:s.Code,type:s.Type},s),_.a.debug("APIClient: Sent WS ".concat(o.Method," request to ").concat(o.Path,":"),o)}else if(this.options.reconnect)setTimeout(function(){n._send(e)},this._reconnectionDelay);else if(this.options.throwError)throw new Error("Can't send data because WebSocket is not opened.")}},{key:"subscribe",value:function(e,t){var n=this._pubSub.subscribe(e,t);return _.a.debug("APIClient: Subscribed as ".concat(n.token)),n}},{key:"unsubscribe",value:function(e){var t=this;return Array.isArray(e)?Object.keys(e).forEach(function(n){_.a.debug("APIClient: Unsubscribing ".concat(e[n])),t._pubSub.unsubscribe(e[n])}):(_.a.debug("APIClient: Unsubscribing ".concat(e)),this._pubSub.unsubscribe(e)),!0}},{key:"close",value:function(){var e=this;return this.options.webSocketUpgrade?this.isClosed?Promise.resolve(this._closing.value):(_.a.info("APIClient: Closing WebSocket connection..."),this._closing.call(function(){var t=e.options.closeTimeout;e._closing.timeout(t,"Can't close WebSocket within allowed timeout: ".concat(t," ms.")),e._ws.close()})):(_.a.debug("APIClient: WebSocket protocol disabled, the connection cannot be closed."),Promise.resolve())}},{key:"_createWS",value:function(){var e=this,t=this.options.wsServer,n=t.port?":".concat(t.port):"",o="".concat(t.protocol,"//").concat(t.hostname).concat(n)+"".concat(t.prefixPath).concat(t.path);this._ws=this.options.createWebSocket(o),["open","message","error","close"].forEach(function(t){var n="_handle".concat(t.charAt(0).toUpperCase()+t.slice(1));e._ws.addEventListener(t,function(t){e[n](t)}),e._wsSubscription[t]=n})}},{key:"_handleOpen",value:function(e){var t=this;this._reconnectResetAttemptsTimeoutId=setTimeout(function(){t._reconnectionAttempt=0},this.options.reconnectionDelayIncrement),_.a.info("APIClient: WebSocket connected!"),"ws"!==this.options.primaryProtocol&&(this.options.primaryProtocol="ws",_.a.debug("APIClient: Upgraded primary protocol to WebSocket.")),this._opening.resolve(e),this._dispatchEvent(new CustomEvent("open"))}},{key:"_handleMessage",value:function(e){var t=e.data;this._handleUnpackedMessage(t)}},{key:"_handleUnpackedMessage",value:function(e){if(this.options.unpackMessage){var t=this.options.unpackMessage(e);void 0!==t&&(_.a.debug("APIClient: Received WS ".concat(t.Method," message for ").concat(t.Path,":"),t),this._handleResponse(t))}}},{key:"_handleResponse",value:function(e){if(this.options.extractRequestId){var t=this.options.extractRequestId(e);t&&(e.Code>=200&&e.Code<300?this._requests.resolve(t,e):this._requests.reject(t,e));var n={path:Object.prototype.hasOwnProperty.call(e,"Path")?e.Path:"",method:Object.prototype.hasOwnProperty.call(e,"Method")?e.Method:"",code:Object.prototype.hasOwnProperty.call(e,"Code")?e.Code:"",type:"response"};e.Headers&&e.Headers["X-OTRS-API-Debug-SQLTrace"]&&this._debugSQL(e.Headers["X-OTRS-API-Debug-SQLTrace"],n),e.Headers&&e.Headers["X-OTRS-API-Debug-STDERRLog"]&&this._debugSTDERR(e.Headers["X-OTRS-API-Debug-STDERRLog"],n),this._pubSub.publish(n,e),this._dispatchEvent(new CustomEvent("message",{detail:e}))}}},{key:"_handleError",value:function(){this._downgradeProtocol(),clearTimeout(this._reconnectResetAttemptsTimeoutId),this._reconnectResetAttemptsTimeoutId=null}},{key:"_handleClose",value:function(e){this._downgradeProtocol(),this._reconnect(),this._closing.resolve(e);var t=new Error("WebSocket closed with reason: ".concat(e.reason," (").concat(e.code,")."));this._opening.isPending&&this._opening.reject(t),this._cleanup(t),this._dispatchEvent(new CustomEvent("close",{detail:t}))}},{key:"_cleanupWS",value:function(){var e=this;this._ws&&(["open","message","error","close"].forEach(function(t){e._ws.removeEventListener(t,e[e._wsSubscription[t]])}),this._ws=null,this._wsSubscription={})}},{key:"_cleanup",value:function(e){this._cleanupWS(),this._requests.rejectAll(e)}},{key:"_downgradeProtocol",value:function(){"ws"===this.options.primaryProtocol&&(this.options.primaryProtocol="xhr",_.a.debug("APIClient: Downgraded primary protocol to XHR."))}},{key:"addEventListener",value:function(e,t){return!!/^(open|message|close)$/.test(e)&&("function"==typeof t&&(this._eventListeners.set(t.bind(this),{type:e,listener:t}),!0))}},{key:"removeEventListener",value:function(e,t){if(!/^(open|message|close)$/.test(e))return!1;if("function"!=typeof t)return!1;var n=!0,o=!1,s=void 0;try{for(var r,i=this._eventListeners[Symbol.iterator]();!(n=(r=i.next()).done);n=!0){var a=c()(r.value,2),u=a[0],h=a[1];h.type===e&&t===h.listener&&this._eventListeners.delete(u)}}catch(e){o=!0,s=e}finally{try{n||null==i.return||i.return()}finally{if(o)throw s}}return!0}},{key:"_dispatchEvent",value:function(e){Object.defineProperty(e,"target",{value:this});var t="on".concat(e.type);this[t]&&this[t](e);var n=!0,o=!1,s=void 0;try{for(var r,i=this._eventListeners[Symbol.iterator]();!(n=(r=i.next()).done);n=!0){var a=c()(r.value,2),u=a[0];a[1].type===e.type&&u(e)}}catch(e){o=!0,s=e}finally{try{n||null==i.return||i.return()}finally{if(o)throw s}}}},{key:"_debugSQL",value:function(e,t){var n=JSON.parse(e),o=n.length;if(o){var s=0;n.forEach(function(e){s+=e.Time}),s=s.toFixed(4),_.a.debug("".concat(t.method.toUpperCase()," message for ").concat(t.path," caused ").concat(o," SQL statements ")+"in ".concat(s,"s: "),n)}}},{key:"_debugSTDERR",value:function(e,t){var n=JSON.parse(e),o=n.length;o&&_.a.debug("".concat(t.method.toUpperCase()," message for ").concat(t.path," wrote ").concat(o," STDERR messages"),n)}},{key:"options",get:function(){return this._options},set:function(e){this._options=Object.assign({},this._options,e)}},{key:"isOpening",get:function(){return Boolean(this._ws&&this._ws.readyState===S)}},{key:"isOpened",get:function(){return Boolean(this._ws&&this._ws.readyState===C)}},{key:"isClosing",get:function(){return Boolean(this._ws&&this._ws.readyState===O)}},{key:"isClosed",get:function(){return Boolean(!this._ws||this._ws.readyState===I)}}]),e}());s.default.use(i.a,{color:"#8fffc7",failedColor:"#D12717",autoFinish:!1});var E={name:"CommonProgressBar",props:{testMode:{type:Boolean,default:!1}},data:function(){return{internalCounter:0,activeProgressBar:!1,errors:!1,intervalId:null,now:0,startTime:0}},computed:{counter:{get:function(){return this.internalCounter},set:function(e){var t=this;this.internalCounter=e,e>0?setTimeout(function(){!t.activeProgressBar&&t.internalCounter>0&&t.start()},150):0===e&&setTimeout(function(){t.activeProgressBar&&0===t.internalCounter&&t.finish()},300)}}},created:function(){var e=this;this.testMode?setInterval(function(){setTimeout(function(){e.increment(),setTimeout(function(){e.decrement({Code:200})},2e3)},500)},3e3):(new MutationObserver(function(t){t.forEach(function(t){Array.from(t.addedNodes).forEach(function(t){if(/^SCRIPT|LINK$/.test(t.tagName)){e.increment();var n=e;t.addEventListener("load",function(){n.decrement({Code:200}),t.removeEventListener("load",this)})}})})}).observe(document.head,{childList:!0}),T.subscribe({types:["request"]},function(){e.increment()}),T.subscribe({types:["response"]},function(t){e.decrement(t)}),this.$bus.$on("progressBarShow",function(){e.increment()}),this.$bus.$on("progressBarHide",function(){e.decrement({Code:200})}))},methods:{increment:function(){this.counter++},decrement:function(e){e.Code&&500!==e.Code||(this.errors=!0),0!==this.counter&&this.counter--},start:function(){var e=this;this.$Progress.start(),this.now=Date.now(),this.startTime=this.now,this.activeProgressBar=!0,this.intervalId||(this.intervalId=setInterval(function(){e.now=Date.now(),e.activeProgressBar&&e.now-e.startTime>=3e4?e.finish():e.activeProgressBar||e.clearIntervalId()},1e3))},finish:function(){this.errors?(this.$Progress.fail(),this.errors=!1):this.$Progress.finish(),this.counter=0,this.startTime=0,this.activeProgressBar=!1,this.clearIntervalId()},clearIntervalId:function(){this.intervalId&&(clearInterval(this.intervalId),this.intervalId=null)}}},j=n("psIG"),x=Object(j.a)(E,function(){var e=this.$createElement;return(this._self._c||e)("vue-progress-bar")},[],!1,null,null,null);x.options.__file="CommonProgressBar.vue";var D=x.exports,A={name:"CommonProgressBar",mixins:[o.a],data:function(){return{docVersion:"1.0.1",componentNamespace:"Components",componentPath:"Components/Common/CommonProgressBar",component:D,example:{testMode:{default:!0}},customCode:[{tag:"p",value:"Take a look at the top of this window."}]}}},M=Object(j.a)(A,function(){var e=this,t=e.$createElement,n=e._self._c||t;return n("div",{staticClass:"DesignSystem__Main"},[n("h1",{staticClass:"DesignSystem"},[e._v("\n        "+e._s(e.summary)+"\n        "),n("b-badge",{attrs:{variant:e.docVersion!==e.version?"warning":"info"}},[e._v("\n            "+e._s(e.version)+"\n        ")])],1),e._v(" "),n("p",[e._v("\n        "+e._s(e.description)+"\n    ")]),e._v(" "),e.docVersion!==e.version?[n("CommonNotice",{attrs:{text:"Please verify all changes to the component API have been properly documented\n                ("+e.docVersion+" !== "+e.version+").",title:"Documentation for this component is out of date!",type:"Warning"}})]:e._e(),e._v(" "),n("h2",{staticClass:"DesignSystem"},[e._v("\n        Semi-automatic Mode\n    ")]),e._v(" "),n("p",[e._v("\n        While the component monitors network for any API requests and responses, it is still possible to activate it\n        manually. Just emit on the global event bus in order to start the progress bar:\n    ")]),e._v(" "),n("pre",{staticClass:"DesignSystem"},[e._v("this.$bus.$emit('progressBarShow');")]),e._v(" "),n("p",[e._v("In order to stop it, emit a different event:")]),e._v(" "),n("pre",{staticClass:"DesignSystem"},[e._v("this.$bus.$emit('progressBarHide');")]),e._v(" "),n("b-tabs",{staticClass:"DesignSystem__TabContent"},[n("b-tab",{staticClass:"tab-pane",attrs:{title:"Demo","title-link-class":"DesignSystem",active:""}},[n("DocsExample",{attrs:{component:e.component,"component-namespace":e.componentNamespace,"component-path":e.componentPath,"custom-code":e.customCode,props:e.props,events:e.events,slots:e.slots,example:e.example}})],1),e._v(" "),n("b-tab",{staticClass:"tab-pane",attrs:{title:"API Documentation","title-link-class":"DesignSystem"}},[n("DocsComponentAPI",{attrs:{props:e.props,events:e.events,slots:e.slots,methods:e.methods}})],1)],1)],2)},[],!1,null,null,null);M.options.__file="CommonProgressBar.vue";t.default=M.exports}}]);