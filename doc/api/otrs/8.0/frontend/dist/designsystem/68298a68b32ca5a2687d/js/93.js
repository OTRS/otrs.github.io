(window.webpackJsonp=window.webpackJsonp||[]).push([[93],{"3YP5":function(t,e,n){},Iptl:function(t,e,n){"use strict";n("GkPX");var s=n("nS/B");e.a={components:{CommonNotice:function(){return n.e(113).then(n.bind(null,"mkLc"))},DocsExample:function(){return n.e(10).then(n.bind(null,"GD02"))},DocsComponentAPI:function(){return n.e(11).then(n.bind(null,"8txu"))}},computed:{doc:function(){var t=this.componentNamespace||"Components";return this.$store.getters.componentDoc[t][this.$options.name]||[]},summary:function(){return Object(s.b)(this.doc,"summary")},version:function(){return Object(s.b)(this.doc,"version")},description:function(){return Object(s.b)(this.doc,"description")},props:function(){return Object(s.a)(this.doc,"prop")},slots:function(){return Object(s.a)(this.doc,"slot")},events:function(){return Object(s.a)(this.doc,"event")},methods:function(){return Object(s.a)(this.doc,"method")}},mounted:function(){var t=this;this.$nextTick(function(){t.$test.setFlag("DocComponent::".concat(t.component.name,"::Mounted"))})}}},"w+cV":function(t,e,n){"use strict";n.r(e);var s=n("Iptl"),o={name:"CommonPills",props:{items:{type:Array,required:!0},default:{type:String,required:!1},active:{type:String,required:!1}},data:function(){return{activeItem:null}},watch:{active:function(t){this.activeItem=t}},mounted:function(){this.activeItem=this.active||this.default},methods:{switchPills:function(t){this.activeItem!==t&&(this.activeItem=t,this.$emit("change",{id:t}))}}},i=(n("wARs"),n("psIG")),c=Object(i.a)(o,function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("b-nav",{staticClass:"Pills",attrs:{pills:""}},t._l(t.items,function(e){return n("b-nav-item",{key:e.key,staticClass:"Pills__Item",attrs:{active:t.activeItem===e.key,"active-class":"active Pills__Item--Active"},on:{click:function(n){t.switchPills(e.key)}}},[t._v("\n        "+t._s(t._f("translate")(e.value))+"\n    ")])}))},[],!1,null,null,null);c.options.__file="index.vue";var a=c.exports,r={name:"CommonPills",mixins:[s.a],data:function(){return{docVersion:"1.0.1",componentNamespace:"Components",componentPath:"Components/Common/CommonPills",component:a,example:{items:{default:[{key:"item1",value:"All Tickets"},{key:"item2",value:"Closed Tickets"}],type:"object"},default:{default:"item1",type:"input"},active:{type:"input"}}}}},l=Object(i.a)(r,function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("div",{staticClass:"main"},[n("h1",{staticClass:"design-system"},[t._v("\n        "+t._s(t.summary)+"\n        "),n("b-badge",{attrs:{variant:t.docVersion!==t.version?"warning":"info"}},[t._v(t._s(t.version))])],1),t._v(" "),n("p",[t._v("\n        "+t._s(t.description)+"\n    ")]),t._v(" "),t.docVersion!==t.version?[n("CommonNotice",{attrs:{text:"Please verify all changes to the component API have been properly documented\n                ("+t.docVersion+" !== "+t.version+").",title:"Documentation for this component is out of date!",type:"Warning"}})]:t._e(),t._v(" "),n("b-tabs",{staticClass:"tab-content"},[n("b-tab",{staticClass:"tab-pane",attrs:{title:"Demo","title-link-class":"design-system",active:""}},[n("DocsExample",{attrs:{component:t.component,"component-path":t.componentPath,props:t.props,events:t.events,slots:t.slots,example:t.example}})],1),t._v(" "),n("b-tab",{staticClass:"tab-pane",attrs:{title:"API Documentation","title-link-class":"design-system"}},[n("DocsComponentAPI",{attrs:{props:t.props,events:t.events,slots:t.slots,methods:t.methods}})],1)],1)],2)},[],!1,null,null,null);l.options.__file="CommonPills.vue";e.default=l.exports},wARs:function(t,e,n){"use strict";var s=n("3YP5");n.n(s).a}}]);