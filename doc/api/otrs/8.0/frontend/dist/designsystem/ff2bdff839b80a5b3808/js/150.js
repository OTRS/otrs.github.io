(window.webpackJsonp=window.webpackJsonp||[]).push([[150],{"+cb4":function(e,t,n){"use strict";n.r(t);var o=n("Iptl"),i=(n("Z8gF"),n("gki9")),a=n.n(i),s=(n("e2Kn"),n("F/wX")),l=n.n(s),r=n("lOrp"),c={name:"CommonDateTime",props:{dateTime:{type:String},deltaDateTime:{type:String},deltaSeconds:{type:[Number,String]},absoluteFormat:{type:String,default:"TimeShort",validator:function(e){return-1!==["TimeLong","TimeShort","Date"].indexOf(e)}},noAffix:{type:Boolean,default:!1},noTitle:{type:Boolean,default:!1},type:{type:String,validator:function(e){return-1!==["absolute","relative","combined"].indexOf(e)}}},computed:a()({},Object(r.b)(["config","userInfo","language"]),{relativeTime:function(){var e;return this.language&&l.a.locale(this.language.toLowerCase().replace("_","-")),e=this.deltaDateTime?this.localizeTimestamp(this.deltaDateTime).date:this.$now.date,this.deltaSeconds?l.a.duration(parseInt(this.deltaSeconds,10),"seconds").humanize(!0):this.localizeTimestamp(this.dateTime).date.from(e,this.noAffix)},localType:function(){return this.type?this.type:this.userInfo&&this.userInfo.UserDateTimeFormat?this.userInfo.UserDateTimeFormat:"relative"}}),created:function(){l.a.relativeTimeThreshold("h",24),l.a.relativeTimeThreshold("d",31),l.a.relativeTimeThreshold("M",12)},methods:{localizeTimestamp:function(e){var t="UTC",n="UTC";return this.config&&this.config.OTRSTimeZone&&(t=this.config.OTRSTimeZone),this.userInfo&&this.userInfo.UserTimeZone?n=this.userInfo.UserTimeZone:this.config&&this.config.UserDefaultTimeZone&&(n=this.config.UserDefaultTimeZone),{date:l.a.tz(e,t).clone().tz(n),timezone:n}}}},m=n("psIG"),u=Object(m.a)(c,function(){var e=this,t=e.$createElement,n=e._self._c||t;return e.deltaSeconds?n("span",[e._v("\n    "+e._s(e.relativeTime)+"\n")]):"absolute"!==e.localType||e.noTitle?"absolute"===e.localType&&e.noTitle?n("span",[e._v("\n    "+e._s(e._f("localize")(e.dateTime,e.absoluteFormat))+"\n")]):"relative"!==e.localType||e.noTitle?"relative"===e.localType&&e.noTitle?n("span",[e._v("\n    "+e._s(e.relativeTime)+"\n")]):n("span",[e._v("\n    "+e._s(e.relativeTime)+" ("+e._s(e._f("localize")(e.dateTime,e.absoluteFormat))+")\n")]):n("span",{directives:[{name:"b-tooltip",rawName:"v-b-tooltip.hover",modifiers:{hover:!0}}],attrs:{title:e._f("localize")(e.dateTime,e.absoluteFormat)}},[e._v("\n    "+e._s(e.relativeTime)+"\n")]):n("span",{directives:[{name:"b-tooltip",rawName:"v-b-tooltip.hover",modifiers:{hover:!0}}],attrs:{title:e.relativeTime}},[e._v("\n    "+e._s(e._f("localize")(e.dateTime,e.absoluteFormat))+"\n")])},[],!1,null,null,null).exports,p={name:"CommonDateTime",mixins:[o.a],data:function(){return{docVersion:"1.0.1",componentNamespace:"Components",componentPath:"Components/Common/CommonDateTime",component:u,isGlobal:!0,example:{type:{default:"absolute",type:"select",options:[{value:"absolute",text:"absolute"},{value:"relative",text:"relative"},{value:"combined",text:"combined"}]},dateTime:{default:"2001-12-01 12:34:56",type:"input"},deltaDateTime:{type:"input"},deltaSeconds:{type:"input"},absoluteFormat:{default:"TimeLong",type:"select",options:[{value:"TimeLong",text:"TimeLong"},{value:"TimeShort",text:"TimeShort"},{value:"Date",text:"Date"}]},noAffix:{default:!1,type:"checkbox"},noTitle:{default:!1,type:"checkbox"}}}}},d=Object(m.a)(p,function(){var e=this,t=e.$createElement,n=e._self._c||t;return n("div",{staticClass:"DesignSystem__Main"},[n("h1",{staticClass:"DesignSystem"},[e._v("\n        "+e._s(e.summary)+"\n        "),n("b-badge",{attrs:{variant:e.docVersion!==e.version?"warning":"info"}},[e._v("\n            "+e._s(e.version)+"\n        ")])],1),e._v(" "),n("p",[e._v("\n        "+e._s(e.description)+"\n    ")]),e._v(" "),e.docVersion!==e.version?[n("CommonNotice",{attrs:{text:"Please verify all changes to the component API have been properly documented\n                ("+e.docVersion+" !== "+e.version+").",title:"Documentation for this component is out of date!",type:"Warning"}})]:e._e(),e._v(" "),n("b-tabs",{staticClass:"DesignSystem__TabContent"},[n("b-tab",{staticClass:"tab-pane",attrs:{title:"Demo","title-link-class":"DesignSystem",active:""}},[n("DocsExample",{attrs:{component:e.component,"component-namespace":e.componentNamespace,"component-path":e.componentPath,"is-global":e.isGlobal,props:e.props,events:e.events,slots:e.slots,example:e.example}})],1),e._v(" "),n("b-tab",{staticClass:"tab-pane",attrs:{title:"API Documentation","title-link-class":"DesignSystem"}},[n("DocsComponentAPI",{attrs:{props:e.props,events:e.events,slots:e.slots,methods:e.methods}})],1)],1)],2)},[],!1,null,null,null);t.default=d.exports},Iptl:function(e,t,n){"use strict";n("GkPX");var o=n("nS/B");t.a={components:{CommonNotice:function(){return n.e(164).then(n.bind(null,"mkLc"))},DocsExample:function(){return n.e(21).then(n.bind(null,"GD02"))},DocsComponentAPI:function(){return n.e(23).then(n.bind(null,"8txu"))}},computed:{doc:function(){var e=this.componentNamespace||"Components";return this.$store.getters.componentDoc[e][this.$options.name]||[]},summary:function(){return Object(o.b)(this.doc,"summary")},version:function(){return Object(o.b)(this.doc,"version")},description:function(){return Object(o.b)(this.doc,"description")},props:function(){return Object(o.a)(this.doc,"prop")},slots:function(){return Object(o.a)(this.doc,"slot")},events:function(){return Object(o.a)(this.doc,"event")},methods:function(){return Object(o.a)(this.doc,"method")}},mounted:function(){var e=this;this.$nextTick(function(){e.$test.setFlag("DocComponent::".concat(e.component.name,"::Mounted"))})}}}}]);