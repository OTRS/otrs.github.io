(window.webpackJsonp=window.webpackJsonp||[]).push([[190],{"+J7U":function(t,e,n){var o,s,i=n("We69"),a=n("4feL"),r=0,c=0;t.exports=function(t,e,n){var u=e&&n||0,l=e||[],p=(t=t||{}).node||o,m=void 0!==t.clockseq?t.clockseq:s;if(null==p||null==m){var d=i();null==p&&(p=o=[1|d[0],d[1],d[2],d[3],d[4],d[5]]),null==m&&(m=s=16383&(d[6]<<8|d[7]))}var v=void 0!==t.msecs?t.msecs:(new Date).getTime(),f=void 0!==t.nsecs?t.nsecs:c+1,h=v-r+(f-c)/1e4;if(h<0&&void 0===t.clockseq&&(m=m+1&16383),(h<0||v>r)&&void 0===t.nsecs&&(f=0),f>=1e4)throw new Error("uuid.v1(): Can't create more than 10M uuids/sec");r=v,c=f,s=m;var b=(1e4*(268435455&(v+=122192928e5))+f)%4294967296;l[u++]=b>>>24&255,l[u++]=b>>>16&255,l[u++]=b>>>8&255,l[u++]=255&b;var y=v/4294967296*1e4&268435455;l[u++]=y>>>8&255,l[u++]=255&y,l[u++]=y>>>24&15|16,l[u++]=y>>>16&255,l[u++]=m>>>8|128,l[u++]=255&m;for(var _=0;_<6;++_)l[u+_]=p[_];return e||a(l)}},"4feL":function(t,e){for(var n=[],o=0;o<256;++o)n[o]=(o+256).toString(16).substr(1);t.exports=function(t,e){var o=e||0,s=n;return[s[t[o++]],s[t[o++]],s[t[o++]],s[t[o++]],"-",s[t[o++]],s[t[o++]],"-",s[t[o++]],s[t[o++]],"-",s[t[o++]],s[t[o++]],"-",s[t[o++]],s[t[o++]],s[t[o++]],s[t[o++]],s[t[o++]],s[t[o++]]].join("")}},Iptl:function(t,e,n){"use strict";n("GkPX");var o=n("nS/B");e.a={components:{CommonNotice:function(){return n.e(261).then(n.bind(null,"mkLc"))},DocsExample:function(){return n.e(69).then(n.bind(null,"GD02"))},DocsComponentAPI:function(){return n.e(71).then(n.bind(null,"8txu"))}},computed:{doc:function(){var t=this.componentNamespace||"Components";return this.$store.getters.componentDoc[t][this.$options.name]||[]},summary:function(){return Object(o.b)(this.doc,"summary")},version:function(){return Object(o.b)(this.doc,"version")},description:function(){return Object(o.b)(this.doc,"description")},props:function(){return Object(o.a)(this.doc,"prop")},slots:function(){return Object(o.a)(this.doc,"slot")},events:function(){return Object(o.a)(this.doc,"event")},methods:function(){return Object(o.a)(this.doc,"method")}},mounted:function(){var t=this;this.$nextTick(function(){t.$test.setFlag("DocComponent::".concat(t.component.name,"::Mounted"))})}}},We69:function(t,e){var n="undefined"!=typeof crypto&&crypto.getRandomValues&&crypto.getRandomValues.bind(crypto)||"undefined"!=typeof msCrypto&&"function"==typeof window.msCrypto.getRandomValues&&msCrypto.getRandomValues.bind(msCrypto);if(n){var o=new Uint8Array(16);t.exports=function(){return n(o),o}}else{var s=new Array(16);t.exports=function(){for(var t,e=0;e<16;e++)0==(3&e)&&(t=4294967296*Math.random()),s[e]=t>>>((3&e)<<3)&255;return s}}},jKEF:function(t,e,n){"use strict";n.r(e);var o=n("Iptl"),s=n("GgUG"),i={name:"Form",mixins:[o.a],data:function(){return{docVersion:"2.0.1",componentNamespace:"Components",componentPath:"Components/Form",value:void 0,component:s.default,filterText:"",example:{url:{type:"input",default:"path/to/form/endpoint"},hideDescription:{default:!1,type:"checkbox"},filterText:{type:"input",default:void 0},testMode:{default:!0},events:["valid"],enableCollisionDetection:{type:"checkbox",default:!1},emitValuesInComplexObject:{type:"checkbox",default:!1},collisionDetectionEvents:{type:"array"},collisionDetectionHandler:{type:"function"},collisionDetectionMessageClass:{type:"input"},initialValues:{type:"object"},slots:{"submit-buttons":{content:"    \x3c!-- BUTTON MARKUP GOES HERE --\x3e",render:function(t){return function(){return t("div",{class:{"mt-3":!0,"float-right":!0}},[t("b-button",{class:{"mr-2":!0},props:{type:"reset"}},["Reset"]),t("b-button",{props:{variant:"primary",type:"submit"}},["Submit"])])}}}}}}},mounted:function(){var t=this;this.$nextTick(function(){t.$test.setFlag("Form::Form::Mounted")})}},a=n("psIG"),r=Object(a.a)(i,function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("div",{staticClass:"DesignSystem__Main"},[n("h1",{staticClass:"DesignSystem"},[t._v("\n        "+t._s(t.summary)+"\n        "),n("b-badge",{attrs:{variant:t.docVersion!==t.version?"warning":"info"}},[t._v("\n            "+t._s(t.version)+"\n        ")])],1),t._v(" "),n("p",[t._v("\n        "+t._s(t.description)+"\n    ")]),t._v(" "),t.docVersion!==t.version?[n("CommonNotice",{attrs:{text:"Please verify all changes to the component API have been properly documented\n                ("+t.docVersion+" !== "+t.version+").",title:"Documentation for this component is out of date!",type:"Warning"}})]:t._e(),t._v(" "),n("h2",{staticClass:"DesignSystem"},[t._v("\n        Form submission\n    ")]),t._v(" "),t._m(0),t._v(" "),t._m(1),t._v(" "),n("b-tabs",{staticClass:"DesignSystem__TabContent"},[n("b-tab",{staticClass:"tab-pane tab-pane-demo",attrs:{title:"Demo","title-link-class":"DesignSystem",active:""}},[n("DocsExample",{attrs:{component:t.component,"component-namespace":t.componentNamespace,"component-path":t.componentPath,props:t.props,events:t.events,slots:t.slots,example:t.example},model:{value:t.value,callback:function(e){t.value=e},expression:"value"}})],1),t._v(" "),n("b-tab",{staticClass:"tab-pane tab-pane-api",attrs:{title:"API Documentation","title-link-class":"DesignSystem"}},[n("DocsComponentAPI",{attrs:{props:t.props,events:t.events,slots:t.slots,methods:t.methods}})],1)],1)],2)},[function(){var t=this.$createElement,e=this._self._c||t;return e("p",[this._v("\n        To submit the form, add a submit button ("),e("code",[this._v('type="submit"')]),this._v(") to the "),e("code",[this._v("submit-buttons")]),this._v(" slot\n        which will include it within the form tag. Button will then behave as expected.\n    ")])},function(){var t=this.$createElement,e=this._self._c||t;return e("p",[this._v("\n        Form component will emit either a "),e("code",[this._v("valid")]),this._v(" or "),e("code",[this._v("invalid")]),this._v(" event with validated data\n        against the configured form endpoint. You can then pass this data to an action endpoint, i.e. for storage.\n    ")])}],!1,null,null,null);e.default=r.exports},rpZP:function(t,e,n){"use strict";var o=n("+J7U"),s=n.n(o);e.a={data:function(){return{uuid:this.getUuid()}},methods:{getUuid:function(){return s()()}}}}}]);