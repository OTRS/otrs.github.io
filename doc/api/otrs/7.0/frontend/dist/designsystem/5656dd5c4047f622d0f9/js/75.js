(window.webpackJsonp=window.webpackJsonp||[]).push([[75],{"5v/B":function(e,t,n){(function(t){function n(e){var t=o([["iOS",/iP(hone|od|ad)/],["Android OS",/Android/],["BlackBerry OS",/BlackBerry|BB10/],["Windows Mobile",/IEMobile/],["Amazon OS",/Kindle/],["Windows 3.11",/Win16/],["Windows 95",/(Windows 95)|(Win95)|(Windows_95)/],["Windows 98",/(Windows 98)|(Win98)/],["Windows 2000",/(Windows NT 5.0)|(Windows 2000)/],["Windows XP",/(Windows NT 5.1)|(Windows XP)/],["Windows Server 2003",/(Windows NT 5.2)/],["Windows Vista",/(Windows NT 6.0)/],["Windows 7",/(Windows NT 6.1)/],["Windows 8",/(Windows NT 6.2)/],["Windows 8.1",/(Windows NT 6.3)/],["Windows 10",/(Windows NT 10.0)/],["Windows ME",/Windows ME/],["Open BSD",/OpenBSD/],["Sun OS",/SunOS/],["Linux",/(Linux)|(X11)/],["Mac OS",/(Mac_PowerPC)|(Macintosh)/],["QNX",/QNX/],["BeOS",/BeOS/],["OS/2",/OS\/2/],["Search Bot",/(nuhk)|(Googlebot)|(Yammybot)|(Openbot)|(Slurp)|(MSNBot)|(Ask Jeeves\/Teoma)|(ia_archiver)/]]).filter(function(t){return t.rule&&t.rule.test(e)})[0];return t?t.name:null}function a(){return void 0!==t&&t.version&&{name:"node",version:t.version.slice(1),os:t.platform}}function i(e){var t=o([["aol",/AOLShield\/([0-9\._]+)/],["edge",/Edge\/([0-9\._]+)/],["yandexbrowser",/YaBrowser\/([0-9\._]+)/],["vivaldi",/Vivaldi\/([0-9\.]+)/],["kakaotalk",/KAKAOTALK\s([0-9\.]+)/],["samsung",/SamsungBrowser\/([0-9\.]+)/],["chrome",/(?!Chrom.*OPR)Chrom(?:e|ium)\/([0-9\.]+)(:?\s|$)/],["phantomjs",/PhantomJS\/([0-9\.]+)(:?\s|$)/],["crios",/CriOS\/([0-9\.]+)(:?\s|$)/],["firefox",/Firefox\/([0-9\.]+)(?:\s|$)/],["fxios",/FxiOS\/([0-9\.]+)/],["opera",/Opera\/([0-9\.]+)(?:\s|$)/],["opera",/OPR\/([0-9\.]+)(:?\s|$)$/],["ie",/Trident\/7\.0.*rv\:([0-9\.]+).*\).*Gecko$/],["ie",/MSIE\s([0-9\.]+);.*Trident\/[4-7].0/],["ie",/MSIE\s(7\.0)/],["bb10",/BB10;\sTouch.*Version\/([0-9\.]+)/],["android",/Android\s([0-9\.]+)/],["ios",/Version\/([0-9\._]+).*Mobile.*Safari.*/],["safari",/Version\/([0-9\._]+).*Safari/],["facebook",/FBAV\/([0-9\.]+)/],["instagram",/Instagram\s([0-9\.]+)/],["ios-webview",/AppleWebKit\/([0-9\.]+).*Mobile/]]);if(!e)return null;var a=t.map(function(t){var n=t.rule.exec(e),a=n&&n[1].split(/[._]/).slice(0,3);return a&&a.length<3&&(a=a.concat(1==a.length?[0,0]:[0])),n&&{name:t.name,version:a.join(".")}}).filter(Boolean)[0]||null;return a&&(a.os=n(e)),/alexa|bot|crawl(er|ing)|facebookexternalhit|feedburner|google web preview|nagios|postrank|pingdom|slurp|spider|yahoo!|yandex/i.test(e)&&((a=a||{}).bot=!0),a}function o(e){return e.map(function(e){return{name:e[0],rule:e[1]}})}e.exports={detect:function(){return"undefined"!=typeof navigator?i(navigator.userAgent):a()},detectOS:n,getNodeVersion:a,parseUserAgent:i}}).call(this,n("5IsQ"))},DYqF:function(e,t,n){},Iptl:function(e,t,n){"use strict";n("GkPX");var a=n("nS/B");t.a={components:{CommonNotice:function(){return n.e(112).then(n.bind(null,"mkLc"))},DocsExample:function(){return n.e(10).then(n.bind(null,"GD02"))},DocsComponentAPI:function(){return n.e(11).then(n.bind(null,"8txu"))}},computed:{doc:function(){var e=this.componentNamespace||"Components";return this.$store.getters.componentDoc[e][this.$options.name]||[]},summary:function(){return Object(a.b)(this.doc,"summary")},version:function(){return Object(a.b)(this.doc,"version")},description:function(){return Object(a.b)(this.doc,"description")},props:function(){return Object(a.a)(this.doc,"prop")},slots:function(){return Object(a.a)(this.doc,"slot")},events:function(){return Object(a.a)(this.doc,"event")},methods:function(){return Object(a.a)(this.doc,"method")}}}},Ko5F:function(e,t,n){"use strict";var a=n("DYqF");n.n(a).a},pImI:function(e,t,n){"use strict";n.r(t);var a=n("Iptl"),i=(n("GkPX"),n("asZ9"),n("9ovy"),n("J8hF"),n("K/PF"),n("75LO"),n("W1QL"),n("e2Kn"),n("5v/B")),o=Object(i.detect)(),s={name:"CommonDownload",props:{variant:{type:String,default:"full"},columnSize:{type:Number,default:null},url:{type:String,required:!0},isExternal:{type:Boolean,default:!1},filename:{type:String,required:!0},filesize:{type:String},contentType:{type:String},additionalValues:{type:Object},downloadType:{type:String}},computed:{filetypeSimple:function(){var e=this,t={image:{name:"Image",iconclass:"fa-file-image"},audio:{name:"Audio",iconclass:"fa-file-audio"},video:{name:"Video",iconclass:"fa-file-video"},"application/pdf":{name:"PDF",iconclass:"fa-file-pdf"},"application/msword":{name:"Document",iconclass:"fa-file-word"},"application/vnd.ms-word":{name:"Document",iconclass:"fa-file-word"},"application/vnd.oasis.opendocument.text":{name:"Document",iconclass:"fa-file-word"},"application/vnd.openxmlformats-officedocument.wordprocessingml":{name:"Document",iconclass:"fa-file-word"},"application/vnd.ms-excel":{name:"Spreadsheet",iconclass:"fa-file-excel"},"application/vnd.openxmlformats-officedocument.spreadsheetml":{name:"Spreadsheet",iconclass:"fa-file-excel"},"application/vnd.oasis.opendocument.spreadsheet":{name:"Spreadsheet",iconclass:"fa-file-excel"},"application/vnd.ms-powerpoint":{name:"Presentation",iconclass:"fa-file-powerpoint"},"application/vnd.openxmlformats-officedocument.presentationml":{name:"Presentation",iconclass:"fa-file-powerpoint"},"application/vnd.oasis.opendocument.presentation":{name:"Presentation",iconclass:"fa-file-powerpoint"},"text/plain":{name:"Text",iconclass:"fa-file-text"},"text/html":{name:"HTML",iconclass:"fa-file-code"},"application/json":{name:"JSON",iconclass:"fa-file-code"},"text/calendar":{name:"Calendar",iconclass:"fa-calendar-alt"},"application/gzip":{name:"ZIP",iconclass:"fa-file-archive"},"application/zip":{name:"ZIP",iconclass:"fa-file-archive"}},n={name:"File",iconclass:"fa-file"};return void 0!==this.contentType&&Object.keys(t).forEach(function(a){var i=new RegExp(a);e.contentType.match(i)&&(n=t[a])}),n}},methods:{download:function(){var e=this;this.clientSendRequest({Path:this.url,Method:"head"}).then(function(){var t=document.createElement("a"),n=e.$store.getters.serverInfo,a=e.url.split("?");t.href="".concat(n.protocol,"//").concat(n.hostname,":").concat(n.port).concat(n.prefixPath,"/api")+"".concat(a[0]),o&&"ie"===o.name||e.downloadType&&"inline"===e.downloadType?t.setAttribute("target","_blank"):(t.href+="/download",t.setAttribute("download",e.filename)),a[1]&&(t.href+="?".concat(a[1])),document.body.appendChild(t),t.click(),t.remove()}).catch(function(){e.$bus.$emit("showNotification",{id:"downloadError",heading:"Download error!",text:"File could not be downloaded from server.",variant:"danger",persistent:!0})})}}},l=(n("Ko5F"),n("psIG")),r=Object(l.a)(s,function(){var e=this,t=e.$createElement,n=e._self._c||t;return"simple"!=e.variant||e.isExternal?"simple"==e.variant&&e.isExternal?n("span",{staticClass:"DownloadSimple"},[n("CommonLink",{staticClass:"btn btn-secondary Button Button--Secondary",attrs:{link:e.url,target:"_blank","is-external":""}},[n("CommonIcon",{staticClass:"mr-2",attrs:{icon:"paperclip"}}),e._v("\n        "+e._s(e.filename)+"\n        "),e.filesize?n("span",{staticClass:"Filesize"},[e._v("("+e._s(e._f("filesize")(e.filesize))+")")]):e._e()],1)],1):"plain"==e.variant?n("b-col",{staticClass:"Download DownloadPlain",attrs:{md:e.columnSize}},[n("b-row",[n("b-col",[n("ul",{staticClass:"small list-unstyled"},[n("li",{staticClass:"text-truncate Filename"},[e._v("\n                    "+e._s(e._f("translate")("Name"))+":\n                    "),n("span",{attrs:{title:e.filename}},[e._v(e._s(e.filename))])]),e._v(" "),e.contentType?n("li",{staticClass:"Filetype",attrs:{title:e.contentType}},[e._v("\n                    "+e._s(e._f("translate")("Type"))+":\n                    "),n("span",[e._v(e._s(e.filetypeSimple.name))])]):e._e(),e._v(" "),e.filesize?n("li",{staticClass:"Filesize"},[e._v("\n                    "+e._s(e._f("translate")("Size"))+":\n                    "),n("span",[e._v(e._s(e._f("filesize")(e.filesize)))])]):e._e(),e._v(" "),e._l(e.additionalValues,function(t,a){return n("li",{key:a},[e._v("\n                    "+e._s(e._f("translate")(a))+":\n                    "),n("span",[e._v(e._s(t))])])})],2)]),e._v(" "),n("b-col",{attrs:{md:"12"}},[e.isExternal?n("CommonLink",{staticClass:"btn btn-primary btn-block Button Button--PrimaryInverted",attrs:{link:e.url,target:"_blank","is-external":""}},[n("i",{staticClass:"fas fa-paperclip mr-2"}),e._v("\n                "+e._s(e._f("translate")("Download File"))+"\n            ")]):n("a",{staticClass:"btn btn-primary btn-block Button Button--PrimaryInverted",attrs:{href:""},on:{click:function(t){return t.preventDefault(),e.download(t)}}},[n("i",{staticClass:"fas fa-paperclip mr-2"}),e._v("\n                "+e._s(e._f("translate")("Download File"))+"\n            ")])],1)],1)],1):n("b-col",{staticClass:"Download DownloadFull",attrs:{md:e.columnSize}},[n("div",{staticClass:"border"},[n("b-row",[n("b-col",{staticClass:"text-right",attrs:{cols:"2"}},[n("i",{staticClass:"fas fa-lg Download__Icon",class:[e.filetypeSimple.iconclass]})]),e._v(" "),n("b-col",{attrs:{cols:"10"}},[n("ul",{staticClass:"small list-unstyled"},[n("li",{staticClass:"text-truncate Filename"},[e._v("\n                        "+e._s(e._f("translate")("Name"))+":\n                        "),n("span",{attrs:{title:e.filename}},[e._v(e._s(e.filename))])]),e._v(" "),e.contentType?n("li",{staticClass:"Filetype",attrs:{title:e.contentType}},[e._v("\n                        "+e._s(e._f("translate")("Type"))+":\n                        "),n("span",[e._v(e._s(e.filetypeSimple.name))])]):e._e(),e._v(" "),e.filesize?n("li",{staticClass:"Filesize"},[e._v("\n                        "+e._s(e._f("translate")("Size"))+":\n                        "),n("span",[e._v(e._s(e._f("filesize")(e.filesize)))])]):e._e(),e._v(" "),e._l(e.additionalValues,function(t,a){return n("li",{key:a},[e._v("\n                        "+e._s(e._f("translate")(a))+":\n                        "),n("span",[e._v(e._s(t))])])})],2)]),e._v(" "),n("b-col",{attrs:{md:"12"}},[e.isExternal?n("CommonLink",{staticClass:"btn btn-primary btn-block Button Button--PrimaryInverted",attrs:{link:e.url,target:"_blank","is-external":""}},[n("i",{staticClass:"fas fa-paperclip mr-2"}),e._v("\n                    "+e._s(e._f("translate")("Download File"))+"\n                ")]):n("a",{staticClass:"btn btn-primary btn-block Button Button--PrimaryInverted",attrs:{href:""},on:{click:function(t){return t.preventDefault(),e.download(t)}}},[n("i",{staticClass:"fas fa-paperclip mr-2"}),e._v("\n                    "+e._s(e._f("translate")("Download File"))+"\n                ")])],1)],1)],1)]):n("span",{staticClass:"DownloadSimple",on:{click:function(t){return t.preventDefault(),e.download(t)}}},[n("a",{staticClass:"d-inline-block btn btn-secondary Button Button--Secondary",attrs:{title:e.filename,href:"#"}},[n("CommonIcon",{staticClass:"mr-2",attrs:{icon:"paperclip"}}),e._v(" "),n("span",{staticClass:"align-text-bottom d-inline-block text-truncate",staticStyle:{"max-width":"200px"}},[e._v(e._s(e.filename))]),e._v(" "),e.filesize?n("span",{staticClass:"align-text-bottom d-inline-block Filesize"},[e._v("("+e._s(e._f("filesize")(e.filesize))+")")]):e._e()],1)])},[],!1,null,null,null);r.options.__file="index.vue";var c=r.exports,p={name:"CommonDownload",mixins:[a.a],data:function(){return{docVersion:"1.0.1",componentNamespace:"Components",componentPath:"Components/Common/CommonDownload",component:c,isGlobal:!0,example:{variant:{default:"full",type:"select",options:[{value:"full",text:"full"},{value:"plain",text:"plain"},{value:"simple",text:"simple"}]},columnSize:{default:5,type:"input"},url:{default:"/public/knowledge-base/1/attachment/2",type:"input"},filename:{default:"dummy.pdf",type:"input"},filesize:{default:"1024",type:"input"},contentType:{default:"application/pdf",type:"input"},additionalValues:{default:{Example:"Example Text"},type:"object"},downloadType:{default:"attachment",type:"input"}}}}},d=Object(l.a)(p,function(){var e=this,t=e.$createElement,n=e._self._c||t;return n("div",{staticClass:"main"},[n("h1",{staticClass:"design-system"},[e._v("\n        "+e._s(e.summary)+"\n        "),n("b-badge",{attrs:{variant:e.docVersion!==e.version?"warning":"info"}},[e._v(e._s(e.version))])],1),e._v(" "),n("p",[e._v("\n        "+e._s(e.description)+"\n    ")]),e._v(" "),e.docVersion!==e.version?[n("CommonNotice",{attrs:{text:"Please verify all changes to the component API have been properly documented\n                ("+e.docVersion+" !== "+e.version+").",title:"Documentation for this component is out of date!",type:"Warning"}})]:e._e(),e._v(" "),n("b-tabs",{staticClass:"tab-content"},[n("b-tab",{staticClass:"tab-pane",attrs:{title:"Demo","title-link-class":"design-system",active:""}},[n("DocsExample",{attrs:{component:e.component,"component-path":e.componentPath,"is-global":e.isGlobal,props:e.props,events:e.events,slots:e.slots,example:e.example}})],1),e._v(" "),n("b-tab",{staticClass:"tab-pane",attrs:{title:"API Documentation","title-link-class":"design-system"}},[n("DocsComponentAPI",{attrs:{props:e.props,events:e.events,slots:e.slots,methods:e.methods}})],1)],1)],2)},[],!1,null,null,null);d.options.__file="CommonDownload.vue";t.default=d.exports}}]);