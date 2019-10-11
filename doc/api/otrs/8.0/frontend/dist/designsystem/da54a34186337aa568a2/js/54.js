(window.webpackJsonp=window.webpackJsonp||[]).push([[54],{2:function(e,t){},iAOG:function(e,t,n){"use strict";n.r(t);n("lQyR"),n("YhIr");var s=n("6DIm"),r=n("0NuS"),i=n.n(r),o=n("nxTg"),a=n.n(o),c=(n("+jjx"),n("ABKx"),n("J8hF"),n("GkPX"),n("e+GP")),u=n.n(c),h=(n("75LO"),n("Z8gF"),n("DbwS"),n("W1QL"),n("K/PF"),n("t91x"),n("zx98"),n("5hJT"),n("SDJZ")),l=n.n(h),p=n("NToG"),d=n.n(p),v=n("akKz"),f=n.n(v),b=(n("5Nsu"),n("kmNX")),_=n.n(b),y=function(){function e(){l()(this,e),this._items=new Map}return d()(e,[{key:"create",value:function(e,t,n){return this._rejectExistingRequest(e),this._createNewRequest(e,t,n)}},{key:"resolve",value:function(e,t){e&&this._items.has(e)&&this._items.get(e).resolve(t)}},{key:"reject",value:function(e,t){if(e&&this._items.has(e)){var n=new Error("Error getting valid response.");n.response=t,this._items.get(e).reject(n)}}},{key:"rejectAll",value:function(e){Object.keys(this._items).forEach(function(t){return t.isPending?t.reject(e):null})}},{key:"_rejectExistingRequest",value:function(e){var t=this._items.get(e);t&&t.isPending&&t.reject(new Error("WebSocket request is replaced, id: ".concat(e)))}},{key:"_createNewRequest",value:function(e,t,n){var s=this,r=new f.a;return this._items.set(e,r),r.timeout(n,"WebSocket request was rejected by timeout (".concat(n," ms). RequestId: ").concat(e)),_()(r.call(t),function(){return s._deleteRequest(e,r)})}},{key:"_deleteRequest",value:function(e,t){this._items.get(e)===t&&this._items.delete(e)}}]),e}(),m=(n("9ovy"),n("tb9w")),g=function(){function e(){l()(this,e),this._messages={},this._lastUid=-1}return d()(e,[{key:"_callSubscriber",value:function(e,t){setTimeout(function(){return e(t)},0)}},{key:"_deliverMessage",value:function(e,t){var n=this;m.a.debug("PubSub - _deliverMessage() - message",e),Object.keys(this._messages).forEach(function(s){n._messageFilter(n._messages[s],e)&&n._callSubscriber(n._messages[s].function,t)})}},{key:"_messageFilter",value:function(e,t){return!(Object.prototype.hasOwnProperty.call(e,"codes")&&e.codes.indexOf(parseInt(t.code,10))<0)&&(!(Object.prototype.hasOwnProperty.call(e,"methods")&&e.methods.indexOf(t.method.toUpperCase())<0)&&(!(Object.prototype.hasOwnProperty.call(e,"types")&&e.types.indexOf(t.type.toUpperCase())<0)&&!(Object.prototype.hasOwnProperty.call(e,"path")&&!t.path.match(e.path))))}},{key:"_messageHasSubscribers",value:function(e){var t=this,n=!1;return Object.keys(this._messages).forEach(function(s){t._messageFilter(t._messages[s],e)&&(n=!0)}),n}},{key:"_createDeliveryFunction",value:function(e,t){var n=this;return function(){n._deliverMessage(e,t)}}},{key:"publish",value:function(e,t){var n=this;return Object.prototype.hasOwnProperty.call(e,"path")?Object.prototype.hasOwnProperty.call(e,"method")?Object.prototype.hasOwnProperty.call(e,"code")?Object.prototype.hasOwnProperty.call(e,"type")?(setTimeout(function(){n._messageHasSubscribers(e)&&n._createDeliveryFunction(e,t)()},0),!0):(m.a.error("PubSub.js - publish()",'Parameter "message" requires "type".'),!1):(m.a.error("PubSub.js - publish()",'Parameter "message" requires "code".'),!1):(m.a.error("PubSub.js - publish()",'Parameter "message" requires "method".'),!1):(m.a.error("PubSub.js - publish()",'Parameter "message" requires "path".'),!1)}},{key:"subscribe",value:function(e,t){var n=this;if("function"!=typeof t)return!1;var s="uid_".concat(String(++this._lastUid));return Object.prototype.hasOwnProperty.call(this._messages,s)||(this._messages[s]={}),this._messages[s].function=t,Object.prototype.hasOwnProperty.call(e,"path")&&(this._messages[s].path=new RegExp(e.path)),Object.prototype.hasOwnProperty.call(e,"methods")&&e.methods.length&&(this._messages[s].methods=[],Object.keys(e.methods).forEach(function(t){n._messages[s].methods.push(e.methods[t].toUpperCase())})),Object.prototype.hasOwnProperty.call(e,"codes")&&e.codes.length&&(this._messages[s].codes=[],Object.keys(e.codes).forEach(function(t){n._messages[s].codes.push(parseInt(e.codes[t],10))})),Object.prototype.hasOwnProperty.call(e,"types")&&e.types.length&&(this._messages[s].types=[],Object.keys(e.types).forEach(function(t){n._messages[s].types.push(e.types[t].toUpperCase())})),{token:s,unsubscribe:function(){n.unsubscribe(s)}}}},{key:"clearAllSubscriptions",value:function(){this._messages={}}},{key:"unsubscribe",value:function(e){delete this._messages[e]}}]),e}(),P=function(){function e(){l()(this,e),this._pushEvents={},this._lastUid=-1}return d()(e,[{key:"_callSubscriber",value:function(e,t){setTimeout(function(){return e(t)},0)}},{key:"_deliverPushEvent",value:function(e){var t=this;m.a.debug("PushEvents - _deliverPushEvent() - pushEvent",e),Object.keys(this._pushEvents).forEach(function(n){t._pushEventFilter(t._pushEvents[n].name,e)&&t._callSubscriber(t._pushEvents[n].function,e)})}},{key:"_pushEventFilter",value:function(e,t){var n=e;return n=n.replace("<:PositiveInt>","\\d+"),!!new RegExp(n).test(t)}},{key:"_pushEventHasSubscribers",value:function(e){var t=this,n=!1;return Object.keys(this._pushEvents).forEach(function(s){t._pushEventFilter(t._pushEvents[s].name,e)&&(n=!0)}),n}},{key:"_createDeliveryFunction",value:function(e){var t=this;return function(){t._deliverPushEvent(e)}}},{key:"_publishPushEvent",value:function(e){var t=this;return e?(setTimeout(function(){t._pushEventHasSubscribers(e)&&t._createDeliveryFunction(e)()},0),!0):(m.a.error("PushEvents.js - publish()",'Parameter "pushEvent" is requird.'),!1)}},{key:"publish",value:function(e){var t=this;return Object.keys(e).forEach(function(n){t._publishPushEvent(e[n].Name)}),!0}},{key:"subscribe",value:function(e,t){var n=this;if("function"!=typeof t||!e)return!1;var s="uid_".concat(String(++this._lastUid));return Object.prototype.hasOwnProperty.call(this._pushEvents,s)||(this._pushEvents[s]={}),this._pushEvents[s].function=t,this._pushEvents[s].name=e,{token:s,unsubscribe:function(){n.unsubscribe(s)}}}},{key:"subscriptions",value:function(){var e=this,t=[];return Object.keys(this._pushEvents).forEach(function(n){t.push(e._pushEvents[n].name)}),t}},{key:"clearAllSubscriptions",value:function(){this._pushEvents={}}},{key:"unsubscribe",value:function(e){delete this._pushEvents[e]}}]),e}(),E=(n("it7j"),n("U8p0"),n("4aJ6"),new(function(){function e(){l()(this,e),this._registry={}}return d()(e,[{key:"enable",value:function(e,t){if(!(e instanceof RegExp||"string"==typeof e&&0!==e.length))throw new Error("invalid value for 'path' parameter, regexp or string is expected.");if("string"!=typeof t||0===t.length)throw new Error("invalid value for 'profile' parameter, string is expected");return this._registry[e.toString()]={type:e instanceof RegExp?"regexp":"string",name:t},!0}},{key:"disable",value:function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:null;if(null==e)return this._registry={},!0;if(!(e instanceof RegExp||"string"==typeof e&&0!==e.length))throw new Error("invalid value for 'path' parameter, regexp or string is expected.");return delete this._registry[e.toString()],!0}},{key:"profileForPath",value:function(e){var t=this;if(!(e instanceof RegExp||"string"==typeof e&&0!==e.length))throw new Error("invalid value for 'path' parameter, regexp or string is expected.");var n=Object.keys(this._registry).sort().reverse().find(function(n){var s=n;if("regexp"===t._registry[n].type){var r=s.match(/^\/(.*)\/([^\/]*)$/);s=new RegExp(r[1],r[2])}return!!e.match(s)});return n?this._registry[n].name:null}},{key:"addFromObject",value:function(e){var t=this;return Object.keys(e).forEach(function(n){t._registry[n]={type:e[n].type,name:e[n].name}}),!0}},{key:"toObject",value:function(){return JSON.parse(JSON.stringify(this._registry))}}]),e}())),I=function(e){var t="";return"object"!==u()(e)?t:(Object.keys(e).forEach(function(n,s){t+=0===s?"?":"&";var r=e[n];switch(u()(r)){case"object":Array.isArray(r)?r.forEach(function(e,s){s>0&&(t+="&"),t+="".concat(n,"=").concat(encodeURIComponent(e))}):t+="".concat(n,"=").concat(encodeURIComponent(JSON.stringify(r)));break;case"boolean":t+="".concat(n,"="),t+=r?1:0;break;case"string":case"number":default:t+="".concat(n,"=").concat(encodeURIComponent(e[n]))}}),t)},S=n("CcHi"),k=n.n(S),w=n("+J7U"),R=n.n(w),O=0,T=1,C=2,A=3,j={wsServer:{protocol:"ws:",hostname:"localhost",port:80,prefixPath:"",path:"/websocket"},xhrServer:{protocol:"http:",hostname:"localhost",port:80,prefixPath:""},primaryProtocol:"xhr",webSocketUpgrade:!0,createWebSocket:function(e){var t;try{t=new WebSocket(e)}catch(t){m.a.error("APIClient: Error connecting to '".concat(e,"'!"),t)}return t},packMessage:function(e){return JSON.stringify(e)},unpackMessage:function(e){return JSON.parse(e)},attachRequestId:function(e,t){return e.RequestID=t,e},extractRequestId:function(e){return e&&e.RequestID},openTimeout:0,closeTimeout:0,responseTimeout:3e4,reconnect:!0,reconnectionDelayIncrement:1e3,maxReconnectionDelay:1e4,maxReconnectionAttempts:10,pollingPushEventHandlerInterval:1e4,refreshPushEventSubscriptionsInterval:6e4,refreshPushEventSubscriptionsTimeout:2e3,accessToken:"",throwError:!0},D=new(function(){function e(){l()(this,e),this._options=Object.assign({},j),this._opening=new f.a,this._closing=new f.a,this._requests=new y,this._requestCount=0,this._ws=null,this._wsSubscription={},this._reconnectTimeoutId=null,this._reconnectionCount=0,this._reconnectionAttempt=0,this._reconnectionDelay=0,this._reconnectResetAttemptsTimeoutId=null,this._pubSub=new g,this._eventListeners=new Map,this._pushEvents=new P,this._pushEventHandlerIntervalId=null,this._pushEventSubscriptionRefreshIntervalId=null,this._pushEventSubscriptionRefreshTimeoutId=null,this._pushEventInitializeData=null,this._authenticatedUserId=null;var t=window.sessionStorage.getItem("frontendClientId");this._frontendClientId=t||R()(),t!==this._frontendClientId&&window.sessionStorage.setItem("frontendClientId",this._frontendClientId)}return d()(e,[{key:"open",value:function(){var e=this;return this.options.webSocketUpgrade?this.isClosing?(this._downgradeProtocol(),Promise.reject(new Error("Can't open WebSocket while closing."))):this.isOpened?this._opening.promise:(m.a.info("APIClient: Opening WebSocket connection..."),this._opening.call(function(){var t=e.options.openTimeout;e._opening.timeout(t,"Can't open WebSocket within allowed timeout: ".concat(t," ms.")),e._opening.promise.catch(function(t){return e._cleanup(t)}),e._createWS()})):(m.a.debug("APIClient: WebSocket protocol disabled, the connection cannot be open."),Promise.resolve())}},{key:"_reconnect",value:function(){var e=this;if(this.options.reconnect){if(this._reconnectionAttempt>=this.options.maxReconnectionAttempts)return this._reconnectTimeoutId&&clearTimeout(this._reconnectTimeoutId),m.a.debug("APIClient: Reconnection attempt limit reached (".concat(this._reconnectionAttempt,"), giving up.")),void(this._reconnectionAttempt=0);this._reconnectionDelay=this._reconnectionAttempt*this.options.reconnectionDelayIncrement,(this._reconnectionDelay>this.options.maxReconnectionDelay||this.options.fixedReconnectionDelay)&&(this._reconnectionDelay=this.options.maxReconnectionDelay),m.a.info("APIClient: Trying to reconnect in ".concat(this._reconnectionDelay/1e3,"s")),this._reconnectionCount++,this._reconnectionAttempt++,clearTimeout(this._reconnectTimeoutId),this._reconnectTimeoutId=setTimeout(function(){e.open()},this._reconnectionDelay)}else this._reconnectTimeoutId&&clearTimeout(this._reconnectTimeoutId)}},{key:"initializePushEvents",value:function(e){var t=this;return new Promise(function(n,s){t._pushEventInitializeData=e,"xhr"!==t.options.primaryProtocol?t._initializePushEventsWebSocket(e).then(function(){return n()}).catch(function(){return s()}):t._initializePushEventsXHR(e).then(function(){return n()}).catch(function(){return s()})})}},{key:"_initializePushEventsWebSocket",value:function(e){var t=this;return new Promise(function(n,s){t.sendRequest({Path:"/websocket/event/init",Method:"post",Body:{Token:t.options.accessToken,FrontendClientID:t._frontendClientId}}).then(function(){t._pushEventHandlerIntervalId&&(clearInterval(t._pushEventHandlerIntervalId),t._pushEventHandlerIntervalId=null),t._initializeRefreshPushEventSubscriptionsInterval(e.subscriptionPath).then(function(){return n()}).catch(function(){return s()})}).catch(function(e){m.a.error("APIClient: Could not initialize the push events!",e),s(e)})})}},{key:"_initializePushEventsXHR",value:function(e){var t=this;return clearInterval(this._pushEventHandlerIntervalId),this._pushEventHandlerIntervalId=setInterval(function(){t.sendRequest({Path:"".concat(e.handlerPath,"/").concat(t._frontendClientId),Method:"get"}).then(function(e){t._pushEvents.publish(e.Body.PushEvents)}).catch(function(e){m.a.error("APIClient: Could not fetch push event messages!",e)})},this.options.pollingPushEventHandlerInterval),new Promise(function(n,s){t._initializeRefreshPushEventSubscriptionsInterval(e.subscriptionPath).then(function(){return n()}).catch(function(){return s()})})}},{key:"_initializeRefreshPushEventSubscriptionsInterval",value:function(e){var t=this;return new Promise(function(n){clearTimeout(t._pushEventSubscriptionRefreshTimeoutId),clearInterval(t._pushEventSubscriptionRefreshIntervalId),t._pushEventSubscriptionRefreshTimeoutId=setTimeout(function(){t.refreshPushEventSubscriptions(e),t._pushEventSubscriptionRefreshIntervalId=setInterval(function(){t.refreshPushEventSubscriptions(e)},t.options.refreshPushEventSubscriptionsInterval),clearTimeout(t._pushEventSubscriptionRefreshTimeoutId),t._pushEventSubscriptionRefreshTimeoutId=null,n()},t.options.refreshPushEventSubscriptionsTimeout)})}},{key:"refreshPushEventSubscriptions",value:function(e){var t=this;return new Promise(function(n,s){t.sendRequest({Path:e,Method:"post",Body:{FrontendClientID:t._frontendClientId,Subscriptions:t._pushEvents.subscriptions()}}).then(function(){return n()}).catch(function(e){m.a.error("APIClient: Could not refresh push event subscriptions!",e),s(e)})})}},{key:"cleanupPushEvents",value:function(){"xhr"===this.options.primaryProtocol&&clearTimeout(this._pushEventHandlerIntervalId),clearTimeout(this._pushEventSubscriptionRefreshTimeoutId),clearInterval(this._pushEventSubscriptionRefreshIntervalId),this._pushEvents.clearAllSubscriptions(),this._pushEventInitializeData=null}},{key:"sendRequest",value:function(e){var t=this,n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:{},s=void 0!==n.responseTimeout?n.responseTimeout:this.options.responseTimeout;["Path","Method"].forEach(function(t){e[t]||m.a.error("APIClient: key '".concat(t,"' in param 'data' of the sendRequest() is required!"))}),e.Path=e.Path.replace(/^[/]/,""),n.apiPrefix&&!/[/]$/.test(n.apiPrefix)&&(n.apiPrefix+="/");var r=e.Path;e.Method=e.Method.toUpperCase(),e.Body&&Object.keys(e.Body).length&&("GET"===e.Method||"HEAD"===e.Method)&&m.a.error("APIClient: method ".concat(e.Method," does not support body parameters!"),e),Object.prototype.hasOwnProperty.call(e,"Headers")||(e.Headers={}),!n.skipAuthentication&&this.options.accessToken&&(e.Headers.Authorization="Bearer ".concat(this.options.accessToken)),"debug"===m.a.options.logLevel&&(e.Headers["X-OTRS-API-Debug"]="true"),e.Query&&(e.Path+=I(e.Query));var i=E.profileForPath(e.Path);if(i&&(e.Headers["X-OTRS-API-Debug-PerlProfiler"]=i),"xhr"===this.options.primaryProtocol&&(n.xhr=!0),this._isJsonReady(e.Body)||n.xhr||(n.xhr=!0,m.a.debug("APIClient: Falling back to XHR because of body unsuitable for JSON conversion:",e.Body)),n.xhr)return this._sendXHR(e,r,n,s);var o=n.requestId||++this._requestCount;return this._requests.create(o,function(){var n=t.options.attachRequestId(e,o);t._sendPacked(n,r)},s)}},{key:"_sendXHR",value:function(e,t,n,s){var r=this,i=new XMLHttpRequest,o=new f.a,a=this.options.xhrServer,c=a.port?":".concat(a.port):"",h="".concat(a.protocol,"//").concat(a.hostname).concat(c).concat(a.prefixPath,"/"),l=void 0!==n.apiPrefix?n.apiPrefix:"api/",p=n&&n.responseType||"json";return o.timeout(s,"Didn't get XHR response within allowed timeout (".concat(s," ms).")),o.call(function(){"function"==typeof n.onUploadProgress&&i.upload.addEventListener("progress",n.onUploadProgress),"function"==typeof n.onDownloadProgress&&i.addEventListener("progress",n.onDownloadProgress),i.addEventListener("load",function(){var n=i.response;n&&"json"===p&&"object"!==u()(n)&&(n=JSON.parse(i.response));var s={Path:t,Method:Object.prototype.hasOwnProperty.call(e,"Method")?e.Method:"GET",Code:i.status,Body:n};if(i.getResponseHeader("Content-Disposition")){var a=k.a.parse(i.getResponseHeader("Content-Disposition"));a&&a.parameters&&a.parameters.filename&&(s.Filename=a.parameters.filename)}if(i.status>=200&&i.status<300)o.resolve(s);else{var c=new Error("Error getting valid response.");c.response=s,o.reject(c)}m.a.debug("APIClient: Received XHR ".concat(s.Method," response for ").concat(s.Path,":"),s);var h={path:s.Path,method:s.Method,code:s.Code,type:"response"};i.getResponseHeader("X-OTRS-API-Debug-SQLTrace")&&r._debugSQL(i.getResponseHeader("X-OTRS-API-Debug-SQLTrace"),h),i.getResponseHeader("X-OTRS-API-Debug-STDERRLog")&&r._debugSTDERR(i.getResponseHeader("X-OTRS-API-Debug-STDERRLog"),h),r._pubSub.publish(h,s),r._dispatchEvent(new CustomEvent("message",{detail:s}))}),i.addEventListener("error",function(){return o.reject(i.statusText)}),i.addEventListener("abort",function(){return o.reject(i.statusText)}),i.open(e.Method||"GET",h+l+e.Path,!0),"XMLHttpRequest"===i.constructor.name&&(i.responseType=p),e.Headers&&Object.keys(e.Headers).forEach(function(t){i.setRequestHeader(t,e.Headers[t])}),r._isJsonReady(e.Body)?i.send(JSON.stringify(e.Body)):i.send(e.Body);var s={Path:t,Method:Object.prototype.hasOwnProperty.call(e,"Method")?e.Method:"GET",Code:200,Type:"request"};r._pubSub.publish({path:s.Path,method:s.Method,code:s.Code,type:s.Type},s),m.a.debug("APIClient: Sent XHR ".concat(e.Method," request to ").concat(e.Path,":"),e)})}},{key:"_isJsonReady",value:function(e){return!e||!(e instanceof FormData)}},{key:"_sendPacked",value:function(e,t){var n=this.options.packMessage(e);this._send(n,t)}},{key:"_send",value:function(e,t){var n=this;if(this.isOpened){this._ws.send(e);var s=this.options.unpackMessage(e),r={Path:t,Method:Object.prototype.hasOwnProperty.call(s,"Method")?e.Method:"GET",Code:200,Type:"request"};this._pubSub.publish({path:r.Path,method:r.Method,code:r.Code,type:r.Type},r),m.a.debug("APIClient: Sent WS ".concat(s.Method," request to ").concat(s.Path,":"),s)}else if(this.options.reconnect)setTimeout(function(){n._send(e)},this._reconnectionDelay);else if(this.options.throwError)throw new Error("Can't send data because WebSocket is not opened.")}},{key:"subscribe",value:function(e,t){var n=this._pubSub.subscribe(e,t);return m.a.debug("APIClient: Subscribed as ".concat(n.token)),n}},{key:"unsubscribe",value:function(e){var t=this;return Array.isArray(e)?Object.keys(e).forEach(function(n){m.a.debug("APIClient: Unsubscribing ".concat(e[n])),t._pubSub.unsubscribe(e[n])}):(m.a.debug("APIClient: Unsubscribing ".concat(e)),this._pubSub.unsubscribe(e)),!0}},{key:"subscribePushEvent",value:function(e,t){var n=this;if(Array.isArray(e)){var s=[];return Object.keys(e).forEach(function(r){s.push(n._preparePushEvent(e[r],t))}),this._pushEventInitializeData&&null===this._pushEventSubscriptionRefreshTimeoutId&&this._initializeRefreshPushEventSubscriptionsInterval(this._pushEventInitializeData.subscriptionPath),s}var r=this._preparePushEvent(e,t);return this._pushEventInitializeData&&null===this._pushEventSubscriptionRefreshTimeoutId&&this._initializeRefreshPushEventSubscriptionsInterval(this._pushEventInitializeData.subscriptionPath),r}},{key:"unsubscribePushEvent",value:function(e){var t=this;return Array.isArray(e)?Object.keys(e).forEach(function(n){m.a.debug("APIClient: Unsubscribing push event ".concat(e[n])),t._pushEvents.unsubscribe(e[n])}):(m.a.debug("APIClient: Unsubscribing push event ".concat(e)),this._pushEvents.unsubscribe(e)),!0}},{key:"_rejectDelay",value:function(e){return new Promise(function(t,n){setTimeout(n.bind(null,e),1e3)})}},{key:"_preparePushEvent",value:function(e,t){var n=this,s=new RegExp("<:AuthenticatedUserID>");return new Promise(function(r,i){if(s.test(e))if(n._authenticatedUserId){e=e.replace("<:AuthenticatedUserID>",n._authenticatedUserId);var o=n._pushEvents.subscribe(e,t);m.a.info("APIClient: Subscribed push event ".concat(e," as ").concat(o.token)),r(o)}else{for(var a=Promise.reject(),c=0;c<10;c++)a=a.catch(function(){return new Promise(function(e,t){n._authenticatedUserId?e():t()})}).catch(n._rejectDelay);a=a.then(function(){e=e.replace("<:AuthenticatedUserID>",n._authenticatedUserId);var s=n._pushEvents.subscribe(e,t);m.a.info("APIClient: Subscribed push event ".concat(e," as ").concat(s.token)),r(s)}).catch(function(){i(new Error("APIClient: Push event ".concat(e," could not be processed!")))})}else{var u=n._pushEvents.subscribe(e,t);m.a.debug("APIClient: Subscribed push event ".concat(e," as ").concat(u.token)),r(u)}})}},{key:"updateAuthenticatedUserId",value:function(e){return this._authenticatedUserId=e,!0}},{key:"close",value:function(){var e=this;return this.options.webSocketUpgrade?this.isClosed?Promise.resolve(this._closing.value):(m.a.info("APIClient: Closing WebSocket connection..."),this._closing.call(function(){var t=e.options.closeTimeout;e._closing.timeout(t,"Can't close WebSocket within allowed timeout: ".concat(t," ms.")),e._ws.close()})):(m.a.debug("APIClient: WebSocket protocol disabled, the connection cannot be closed."),Promise.resolve())}},{key:"_createWS",value:function(){var e=this,t=this.options.wsServer,n=t.port?":".concat(t.port):"",s="".concat(t.protocol,"//").concat(t.hostname).concat(n)+"".concat(t.prefixPath).concat(t.path);this._ws=this.options.createWebSocket(s),["open","message","error","close"].forEach(function(t){var n="_handle".concat(t.charAt(0).toUpperCase()+t.slice(1));e._ws.addEventListener(t,function(t){e[n](t)}),e._wsSubscription[t]=n})}},{key:"_handleOpen",value:function(e){var t=this;this._reconnectResetAttemptsTimeoutId=setTimeout(function(){t._reconnectionAttempt=0},this.options.reconnectionDelayIncrement),m.a.info("APIClient: WebSocket connected!"),"ws"!==this.options.primaryProtocol&&(this.options.primaryProtocol="ws",m.a.debug("APIClient: Upgraded primary protocol to WebSocket.")),this._pushEventInitializeData&&this._initializePushEventsWebSocket(this._pushEventInitializeData),this._opening.resolve(e),this._dispatchEvent(new CustomEvent("open"))}},{key:"_handleMessage",value:function(e){var t=e.data;this._handleUnpackedMessage(t)}},{key:"_handleUnpackedMessage",value:function(e){if(this.options.unpackMessage){var t=this.options.unpackMessage(e);void 0!==t&&(t.Headers&&t.Headers["X-OTRS-API-PushEvent-Message"]?m.a.debug("APIClient: Received WS push event message:",t):m.a.debug("APIClient: Received WS ".concat(t.Method," message for ").concat(t.Path,":"),t),this._handleResponse(t))}}},{key:"_handleResponse",value:function(e){if(this.options.extractRequestId){var t=this.options.extractRequestId(e);t&&(e.Code>=200&&e.Code<300?this._requests.resolve(t,e):this._requests.reject(t,e));var n={path:Object.prototype.hasOwnProperty.call(e,"Path")?e.Path:"",method:Object.prototype.hasOwnProperty.call(e,"Method")?e.Method:"",code:Object.prototype.hasOwnProperty.call(e,"Code")?e.Code:"",type:"response"};e.Headers&&e.Headers["X-OTRS-API-Debug-SQLTrace"]&&this._debugSQL(e.Headers["X-OTRS-API-Debug-SQLTrace"],n),e.Headers&&e.Headers["X-OTRS-API-Debug-STDERRLog"]&&this._debugSTDERR(e.Headers["X-OTRS-API-Debug-STDERRLog"],n),e.Headers&&e.Headers["X-OTRS-API-PushEvent-Message"]&&Object.prototype.hasOwnProperty.call(e,"PushEvents")&&this._pushEvents.publish(e.PushEvents),this._pubSub.publish(n,e),this._dispatchEvent(new CustomEvent("message",{detail:e}))}}},{key:"_handleError",value:function(){this._downgradeProtocol(),clearTimeout(this._reconnectResetAttemptsTimeoutId),this._reconnectResetAttemptsTimeoutId=null}},{key:"_handleClose",value:function(e){this._downgradeProtocol(),this._reconnect(),this._closing.resolve(e);var t=new Error("WebSocket closed with reason: ".concat(e.reason," (").concat(e.code,")."));this._opening.isPending&&this._opening.reject(t),this._cleanup(t),this._dispatchEvent(new CustomEvent("close",{detail:t}))}},{key:"_cleanupWS",value:function(){var e=this;this._ws&&(["open","message","error","close"].forEach(function(t){e._ws.removeEventListener(t,e[e._wsSubscription[t]])}),this._ws=null,this._wsSubscription={})}},{key:"_cleanup",value:function(e){this._cleanupWS(),this._requests.rejectAll(e)}},{key:"_downgradeProtocol",value:function(){"ws"===this.options.primaryProtocol&&(this.options.primaryProtocol="xhr",m.a.debug("APIClient: Downgraded primary protocol to XHR."))}},{key:"addEventListener",value:function(e,t){return!!/^(open|message|close)$/.test(e)&&("function"==typeof t&&(this._eventListeners.set(t.bind(this),{type:e,listener:t}),!0))}},{key:"removeEventListener",value:function(e,t){if(!/^(open|message|close)$/.test(e))return!1;if("function"!=typeof t)return!1;var n=!0,s=!1,r=void 0;try{for(var i,o=this._eventListeners[Symbol.iterator]();!(n=(i=o.next()).done);n=!0){var c=a()(i.value,2),u=c[0],h=c[1];h.type===e&&t===h.listener&&this._eventListeners.delete(u)}}catch(e){s=!0,r=e}finally{try{n||null==o.return||o.return()}finally{if(s)throw r}}return!0}},{key:"_dispatchEvent",value:function(e){Object.defineProperty(e,"target",{value:this});var t="on".concat(e.type);this[t]&&this[t](e);var n=!0,s=!1,r=void 0;try{for(var i,o=this._eventListeners[Symbol.iterator]();!(n=(i=o.next()).done);n=!0){var c=a()(i.value,2),u=c[0];c[1].type===e.type&&u(e)}}catch(e){s=!0,r=e}finally{try{n||null==o.return||o.return()}finally{if(s)throw r}}}},{key:"_debugSQL",value:function(e,t){var n=JSON.parse(e),s=n.length;if(s){var r=0;n.forEach(function(e){r+=e.Time}),r=r.toFixed(4),m.a.debug("".concat(t.method.toUpperCase()," message for ").concat(t.path," caused ").concat(s," SQL statements ")+"in ".concat(r,"s: "),n)}}},{key:"_debugSTDERR",value:function(e,t){var n=JSON.parse(e),s=n.length;s&&m.a.debug("".concat(t.method.toUpperCase()," message for ").concat(t.path," wrote ").concat(s," STDERR messages"),n)}},{key:"options",get:function(){return this._options},set:function(e){this._options=Object.assign({},this._options,e)}},{key:"isOpening",get:function(){return Boolean(this._ws&&this._ws.readyState===O)}},{key:"isOpened",get:function(){return Boolean(this._ws&&this._ws.readyState===T)}},{key:"isClosing",get:function(){return Boolean(this._ws&&this._ws.readyState===C)}},{key:"isClosed",get:function(){return Boolean(!this._ws||this._ws.readyState===A)}}]),e}());s.default.use(i.a,{color:"#8fffc7",failedColor:"#D12717",autoFinish:!1});var x={name:"CommonProgressBar",props:{testMode:{type:Boolean,default:!1}},data:function(){return{internalCounter:0,activeProgressBar:!1,errors:!1,intervalId:null,now:0,startTime:0}},computed:{counter:{get:function(){return this.internalCounter},set:function(e){var t=this;this.internalCounter=e,e>0?setTimeout(function(){!t.activeProgressBar&&t.internalCounter>0&&t.start()},150):0===e&&setTimeout(function(){t.activeProgressBar&&0===t.internalCounter&&t.finish()},300)}}},created:function(){var e=this;this.testMode?setInterval(function(){setTimeout(function(){e.increment(),setTimeout(function(){e.decrement({Code:200})},2e3)},500)},3e3):(new MutationObserver(function(t){t.forEach(function(t){Array.from(t.addedNodes).forEach(function(t){if(/^SCRIPT|LINK$/.test(t.tagName)){e.increment();var n=e;t.addEventListener("load",function(){n.decrement({Code:200}),t.removeEventListener("load",this)})}})})}).observe(document.head,{childList:!0}),D.subscribe({types:["request"]},function(){e.increment()}),D.subscribe({types:["response"]},function(t){e.decrement(t)}),this.$bus.$on("progressBarShow",function(){e.increment()}),this.$bus.$on("progressBarHide",function(){e.decrement({Code:200})}))},methods:{increment:function(){this.counter++},decrement:function(e){e.Code&&500!==e.Code||(this.errors=!0),0!==this.counter&&this.counter--},start:function(){var e=this;this.$Progress.start(),this.now=Date.now(),this.startTime=this.now,this.activeProgressBar=!0,this.intervalId||(this.intervalId=setInterval(function(){e.now=Date.now(),e.activeProgressBar&&e.now-e.startTime>=3e4?e.finish():e.activeProgressBar||e.clearIntervalId()},1e3))},finish:function(){this.errors?(this.$Progress.fail(),this.errors=!1):this.$Progress.finish(),this.counter=0,this.startTime=0,this.activeProgressBar=!1,this.clearIntervalId()},clearIntervalId:function(){this.intervalId&&(clearInterval(this.intervalId),this.intervalId=null)}}},H=n("psIG"),M=Object(H.a)(x,function(){var e=this.$createElement;return(this._self._c||e)("vue-progress-bar")},[],!1,null,null,null);t.default=M.exports}}]);