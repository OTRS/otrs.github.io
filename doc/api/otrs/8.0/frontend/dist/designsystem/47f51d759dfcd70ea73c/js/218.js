(window.webpackJsonp=window.webpackJsonp||[]).push([[218,54],{"+J7U":function(t,e,n){var o,r,s=n("We69"),i=n("4feL"),c=0,a=0;t.exports=function(t,e,n){var p=e&&n||0,u=e||[],l=(t=t||{}).node||o,m=void 0!==t.clockseq?t.clockseq:r;if(null==l||null==m){var d=s();null==l&&(l=o=[1|d[0],d[1],d[2],d[3],d[4],d[5]]),null==m&&(m=r=16383&(d[6]<<8|d[7]))}var f=void 0!==t.msecs?t.msecs:(new Date).getTime(),v=void 0!==t.nsecs?t.nsecs:a+1,h=f-c+(v-a)/1e4;if(h<0&&void 0===t.clockseq&&(m=m+1&16383),(h<0||f>c)&&void 0===t.nsecs&&(v=0),v>=1e4)throw new Error("uuid.v1(): Can't create more than 10M uuids/sec");c=f,a=v,r=m;var b=(1e4*(268435455&(f+=122192928e5))+v)%4294967296;u[p++]=b>>>24&255,u[p++]=b>>>16&255,u[p++]=b>>>8&255,u[p++]=255&b;var y=f/4294967296*1e4&268435455;u[p++]=y>>>8&255,u[p++]=255&y,u[p++]=y>>>24&15|16,u[p++]=y>>>16&255,u[p++]=m>>>8|128,u[p++]=255&m;for(var g=0;g<6;++g)u[p+g]=l[g];return e||i(u)}},"4feL":function(t,e){for(var n=[],o=0;o<256;++o)n[o]=(o+256).toString(16).substr(1);t.exports=function(t,e){var o=e||0,r=n;return[r[t[o++]],r[t[o++]],r[t[o++]],r[t[o++]],"-",r[t[o++]],r[t[o++]],"-",r[t[o++]],r[t[o++]],"-",r[t[o++]],r[t[o++]],"-",r[t[o++]],r[t[o++]],r[t[o++]],r[t[o++]],r[t[o++]],r[t[o++]]].join("")}},"7oBH":function(t,e,n){"use strict";n.r(e);var o={name:"CommonPopover",components:{FormButton:function(){return Promise.all([n.e(1),n.e(302)]).then(n.bind(null,"dphA"))}},mixins:[n("rpZP").a],props:{link:{type:[String,Object]},preview:{type:String},linkText:{type:String},placement:{type:String,default:"left"}},data:function(){return{visible:!1}},computed:{popoverId:function(){return"popover-element-".concat(this.uuid)},iframeSrc:function(){return this.visible?this.preview:""}},methods:{shown:function(){this.visible=!0},hidden:function(){this.visible=!1}}},r=(n("aQJt"),n("psIG")),s=Object(r.a)(o,function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("div",{staticClass:"Popover"},[n("CommonLink",{staticClass:"btn btn-primary mt-2 Button Button--PrimaryInverted",attrs:{id:t.popoverId,link:t.link}},[n("CommonIcon",{staticClass:"mr-2",attrs:{weight:"bold",icon:"hyperlink-2"}}),t._v("\n        "+t._s(t.linkText)+"\n        "),n("b-popover",{attrs:{target:t.popoverId,placement:t.placement,triggers:"hover focus",boundary:"viewport",container:"#App"},on:{shown:t.shown,hidden:t.hidden}},[n("iframe",{staticClass:"Popover__Iframe",attrs:{src:t.iframeSrc,sandbox:"allow-scripts allow-forms",scrolling:"no"}})])],1)],1)},[],!1,null,null,null);e.default=s.exports},CPLt:function(t,e,n){},Iptl:function(t,e,n){"use strict";n("2Tod"),n("ABKx"),n("W1QL"),n("K/PF"),n("t91x"),n("75LO"),n("asZ9"),n("GkPX");var o=n("OvAC"),r=n.n(o),s=n("nS/B"),i=n("lOrp");function c(t,e){var n=Object.keys(t);if(Object.getOwnPropertySymbols){var o=Object.getOwnPropertySymbols(t);e&&(o=o.filter(function(e){return Object.getOwnPropertyDescriptor(t,e).enumerable})),n.push.apply(n,o)}return n}e.a={components:{CommonNotice:function(){return n.e(341).then(n.bind(null,"mkLc"))},DocsExample:function(){return n.e(74).then(n.bind(null,"GD02"))},DocsComponentAPI:function(){return n.e(77).then(n.bind(null,"8txu"))}},computed:function(t){for(var e=1;e<arguments.length;e++){var n=null!=arguments[e]?arguments[e]:{};e%2?c(n,!0).forEach(function(e){r()(t,e,n[e])}):Object.getOwnPropertyDescriptors?Object.defineProperties(t,Object.getOwnPropertyDescriptors(n)):c(n).forEach(function(e){Object.defineProperty(t,e,Object.getOwnPropertyDescriptor(n,e))})}return t}({doc:function(){var t=this.componentNamespace||"Components";return this.$store.getters.componentDoc[t][this.$options.name]||[]},summary:function(){return Object(s.b)(this.doc,"summary")},version:function(){return Object(s.b)(this.doc,"version")},description:function(){return Object(s.b)(this.doc,"description")},props:function(){return Object(s.a)(this.doc,"prop")},slots:function(){return Object(s.a)(this.doc,"slot")},events:function(){return Object(s.a)(this.doc,"event")},methods:function(){return Object(s.a)(this.doc,"method")},initialFrontend:function(){var t=this.componentNamespace.split("/");return t.length>1?t[1]:""}},Object(i.b)(["frontend"])),mounted:function(){var t=this;this.frontend!==this.initialFrontend&&this.$store.commit("frontend",{frontend:this.initialFrontend}),this.$nextTick(function(){t.$test.setFlag("DocComponent::".concat(t.component.name,"::Mounted"))})}}},We69:function(t,e){var n="undefined"!=typeof crypto&&crypto.getRandomValues&&crypto.getRandomValues.bind(crypto)||"undefined"!=typeof msCrypto&&"function"==typeof window.msCrypto.getRandomValues&&msCrypto.getRandomValues.bind(msCrypto);if(n){var o=new Uint8Array(16);t.exports=function(){return n(o),o}}else{var r=new Array(16);t.exports=function(){for(var t,e=0;e<16;e++)0==(3&e)&&(t=4294967296*Math.random()),r[e]=t>>>((3&e)<<3)&255;return r}}},aQJt:function(t,e,n){"use strict";var o=n("CPLt");n.n(o).a},r8hc:function(t,e,n){"use strict";n.r(e);var o=n("Iptl"),r=n("7oBH"),s={name:"CommonPopover",mixins:[o.a],data:function(){return{docVersion:"1.0.1",componentNamespace:"Components",componentPath:"Components/Common/CommonPopover",component:r.default,example:{link:{default:"https://otrs.com",type:"input"},preview:{default:"https://example.com",type:"input"},linkText:{default:"otrs.com",type:"input"},placement:{type:"select",default:"right",options:["auto","top","bottom","left","right","topleft","topright","bottomleft","bottomright","lefttop","leftbottom","righttop","rightbottom"]}}}}},i=n("psIG"),c=Object(i.a)(s,function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("div",{staticClass:"DesignSystem__Main"},[n("h1",{staticClass:"DesignSystem"},[t._v("\n        "+t._s(t.summary)+"\n        "),n("b-badge",{attrs:{variant:t.docVersion!==t.version?"warning":"info"}},[t._v("\n            "+t._s(t.version)+"\n        ")])],1),t._v(" "),n("p",[t._v("\n        "+t._s(t.description)+"\n    ")]),t._v(" "),t.docVersion!==t.version?[n("CommonNotice",{attrs:{text:"Please verify all changes to the component API have been properly documented\n                ("+t.docVersion+" !== "+t.version+").",title:"Documentation for this component is out of date!",type:"Warning"}})]:t._e(),t._v(" "),n("b-tabs",{staticClass:"DesignSystem__TabContent"},[n("b-tab",{staticClass:"tab-pane",attrs:{title:"Demo","title-link-class":"DesignSystem",active:""}},[n("DocsExample",{attrs:{component:t.component,"component-namespace":t.componentNamespace,"component-path":t.componentPath,props:t.props,events:t.events,slots:t.slots,example:t.example}})],1),t._v(" "),n("b-tab",{staticClass:"tab-pane",attrs:{title:"API Documentation","title-link-class":"DesignSystem"}},[n("DocsComponentAPI",{attrs:{props:t.props,events:t.events,slots:t.slots,methods:t.methods}})],1)],1)],2)},[],!1,null,null,null);e.default=c.exports},rpZP:function(t,e,n){"use strict";var o=n("+J7U"),r=n.n(o);e.a={data:function(){return{uuid:this.getUuid()}},methods:{getUuid:function(){return r()()}}}}}]);