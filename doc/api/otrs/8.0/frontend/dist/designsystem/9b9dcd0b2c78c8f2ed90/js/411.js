(window.webpackJsonp=window.webpackJsonp||[]).push([[411],{FAt1:function(e,t,n){"use strict";n.r(t);n("2Tod"),n("ABKx"),n("W1QL"),n("K/PF"),n("t91x"),n("75LO");var i=n("OvAC"),s=n.n(i),o=n("lOrp");function r(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var i=Object.getOwnPropertySymbols(e);t&&(i=i.filter(function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable})),n.push.apply(n,i)}return n}var a={name:"AppReloadMessage",data:function(){return{manifest:void 0}},computed:function(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?r(Object(n),!0).forEach(function(t){s()(e,t,n[t])}):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):r(Object(n)).forEach(function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))})}return e}({},Object(o.b)(["seleniumTestMode"])),mounted:function(){this.seleniumTestMode||(this.manifestFetch(),this.intervalId=setInterval(this.manifestFetch,3e4))},beforeDestroy:function(){clearInterval(this.intervalId)},methods:{manifestFetch:function(){var e=this;return this.clientSendRequest({Path:"".concat(this.$router.options.base,"/manifest"),Method:"get"},{xhr:!0,apiPrefix:"",responseType:"text",skipAuthentication:!0}).then(function(t){e.manifestCheck(t.Body)}).catch(function(t){e.$log.error("Manifest check failed!",t)})},manifestCheck:function(e){this.seleniumTestMode||(void 0!==this.manifest?this.manifest!==e&&(this.manifest=e,this.$bus.$emit("showToastMessage",{id:"appReloadMessage",heading:"Update Available",text:"The application is currently out of date. Please reload the application as soon as possible.",variant:"warning",persistent:!0,dismissible:!1,callback:function(){window.location.reload(!0)}}),this.$router.options.reloadApp=!0):this.manifest=e)}},render:function(){return null}},c=n("psIG"),l=Object(c.a)(a,void 0,void 0,!1,null,null,null);t.default=l.exports}}]);