(window.webpackJsonp=window.webpackJsonp||[]).push([[89],{Iptl:function(t,e,n){"use strict";n("GkPX");var i=n("nS/B");e.a={components:{CommonNotice:function(){return n.e(113).then(n.bind(null,"mkLc"))},DocsExample:function(){return n.e(10).then(n.bind(null,"GD02"))},DocsComponentAPI:function(){return n.e(11).then(n.bind(null,"8txu"))}},computed:{doc:function(){var t=this.componentNamespace||"Components";return this.$store.getters.componentDoc[t][this.$options.name]||[]},summary:function(){return Object(i.b)(this.doc,"summary")},version:function(){return Object(i.b)(this.doc,"version")},description:function(){return Object(i.b)(this.doc,"description")},props:function(){return Object(i.a)(this.doc,"prop")},slots:function(){return Object(i.a)(this.doc,"slot")},events:function(){return Object(i.a)(this.doc,"event")},methods:function(){return Object(i.a)(this.doc,"method")}},mounted:function(){var t=this;this.$nextTick(function(){t.$test.setFlag("DocComponent::".concat(t.component.name,"::Mounted"))})}}},"L/aA":function(t,e,n){"use strict";var i=n("tiAG");n.n(i).a},irtR:function(t,e,n){"use strict";n.r(e);var i=n("Iptl"),o=(n("W1QL"),{name:"LayoutPageSidebarNav",props:{navigation:{type:Array,default:function(){return[]}},baseLink:{type:String,default:""},activeItemId:{type:String},testMode:{type:Boolean,default:!1}},methods:{activeClass:function(t){var e=this,n=this.activeItemId&&parseInt(this.activeItemId,10)===parseInt(t.id,10);return t.children&&t.children.length&&t.children.forEach(function(t){e.activeItemId&&parseInt(e.activeItemId,10)===parseInt(t.id,10)&&(n=!0)}),{active:n}},linkGet:function(t){return this.testMode?"#":"".concat(this.baseLink).concat(t)}}}),s=(n("L/aA"),n("psIG")),a=Object(s.a)(o,function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("div",{staticClass:"PageSidebarNav"},[n("ul",t._l(t.navigation,function(e){return n("li",{key:e.id,staticClass:"PageSidebarNav__Item",class:t.activeClass(e)},[n("CommonLink",{staticClass:"text-truncate",attrs:{title:e.title,link:t.linkGet(e.id)}},[n("span",[t._v(t._s(e.title))])]),t._v(" "),e.children&&e.children.length?n("ul",{staticClass:"shadow"},t._l(e.children,function(e){return n("li",{key:e.id,staticClass:"has-sub PageSidebarNav__Item",class:t.activeClass(e)},[n("CommonLink",{staticClass:"text-truncate",attrs:{title:e.title,link:t.linkGet(e.id)}},[n("span",[t._v(t._s(e.title))])])],1)})):t._e()],1)}))])},[],!1,null,null,null);a.options.__file="index.vue";var c=a.exports,r={name:"LayoutPageSidebarNav",mixins:[i.a],data:function(){return{docVersion:"1.0.1",componentNamespace:"Apps/External",componentPath:"Apps/External/Components/Layout/LayoutPageSidebarNav",component:c,example:{navigation:{default:[{id:"1",title:"Home",children:[{id:"2",title:"Product 1"},{id:"3",title:"Product 2"},{id:"4",title:"Product 3"},{id:"5",title:"Product 4"},{id:"6",title:"Product 5"}]},{id:"7",title:"Products",children:[{id:"8",title:"Product 1"},{id:"9",title:"Product 2"},{id:"10",title:"Product 3"},{id:"11",title:"Product 4"},{id:"12",title:"Product 5"}]},{id:"13",title:"About",children:[{id:"14",title:"Product 1"},{id:"15",title:"Product 2"},{id:"16",title:"Product 3"},{id:"17",title:"Product 4"},{id:"18",title:"Product 5"}]},{id:"19",title:"Contact",children:[{id:"20",title:"Product 1"},{id:"21",title:"Product 2"},{id:"22",title:"Product 3"},{id:"23",title:"Product 4"},{id:"24",title:"Product 5"}]}],type:"array"},activeItemId:{default:"5",type:"input"},baseLink:{default:"/path/to/",type:"input"},testMode:{default:!0}}}}},l=Object(s.a)(r,function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("div",{staticClass:"main"},[n("h1",{staticClass:"design-system"},[t._v("\n        "+t._s(t.summary)+"\n        "),n("b-badge",{attrs:{variant:t.docVersion!==t.version?"warning":"info"}},[t._v(t._s(t.version))])],1),t._v(" "),n("p",[t._v("\n        "+t._s(t.description)+"\n    ")]),t._v(" "),t.docVersion!==t.version?[n("CommonNotice",{attrs:{text:"Please verify all changes to the component API have been properly documented\n                ("+t.docVersion+" !== "+t.version+").",title:"Documentation for this component is out of date!",type:"Warning"}})]:t._e(),t._v(" "),n("b-tabs",{staticClass:"tab-content"},[n("b-tab",{staticClass:"tab-pane",attrs:{title:"Demo","title-link-class":"design-system",active:""}},[n("DocsExample",{attrs:{component:t.component,"component-path":t.componentPath,props:t.props,events:t.events,slots:t.slots,example:t.example}})],1),t._v(" "),n("b-tab",{staticClass:"tab-pane",attrs:{title:"API Documentation","title-link-class":"design-system"}},[n("DocsComponentAPI",{attrs:{props:t.props,events:t.events,slots:t.slots,methods:t.methods}})],1)],1)],2)},[],!1,null,null,null);l.options.__file="LayoutPageSidebarNav.vue";e.default=l.exports},tiAG:function(t,e,n){}}]);