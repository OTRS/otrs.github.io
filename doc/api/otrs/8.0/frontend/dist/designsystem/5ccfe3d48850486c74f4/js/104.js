(window.webpackJsonp=window.webpackJsonp||[]).push([[104],{"3csR":function(t,n,e){},Iptl:function(t,n,e){"use strict";e("GkPX");var o=e("nS/B");n.a={components:{CommonNotice:function(){return e.e(148).then(e.bind(null,"mkLc"))},DocsExample:function(){return e.e(17).then(e.bind(null,"GD02"))},DocsComponentAPI:function(){return e.e(18).then(e.bind(null,"8txu"))}},computed:{doc:function(){var t=this.componentNamespace||"Components";return this.$store.getters.componentDoc[t][this.$options.name]||[]},summary:function(){return Object(o.b)(this.doc,"summary")},version:function(){return Object(o.b)(this.doc,"version")},description:function(){return Object(o.b)(this.doc,"description")},props:function(){return Object(o.a)(this.doc,"prop")},slots:function(){return Object(o.a)(this.doc,"slot")},events:function(){return Object(o.a)(this.doc,"event")},methods:function(){return Object(o.a)(this.doc,"method")}},mounted:function(){var t=this;this.$nextTick(function(){t.$test.setFlag("DocComponent::".concat(t.component.name,"::Mounted"))})}}},Ol63:function(t,n,e){"use strict";e.r(n);var o=e("Iptl"),s={name:"CommonLinkList",components:{FormButton:function(){return Promise.all([e.e(0),e.e(7)]).then(e.bind(null,"dphA"))}},props:{link:{type:String},linkText:{type:String},links:{type:Array},title:{type:String}}},i=(e("YADC"),e("psIG")),a=Object(i.a)(s,function(){var t=this,n=t.$createElement,e=t._self._c||n;return e("div",{staticClass:"LinkList"},[e("h3",{staticClass:"LinkList__Title"},[t._v("\n        "+t._s(t.title)+"\n    ")]),t._v(" "),e("div",{staticClass:"list-group list-group-flush mb-4"},t._l(t.links,function(n){return e("CommonLink",{key:JSON.stringify(n.link)+n.text,staticClass:"list-group-item pl-0 LinkList__Link",attrs:{link:n.link}},[t._v("\n            "+t._s(n.text)+"\n        ")])}),1),t._v(" "),e("CommonLink",{attrs:{disabled:!t.link||!t.link.length,link:t.link}},[t._v("\n        "+t._s(t.linkText)+"\n        "),t.link?e("CommonIcon",{staticClass:"ml-3 LinkList__Icon",attrs:{icon:"keyboard-arrow-right"}}):t._e()],1)],1)},[],!1,null,null,null).exports,c={name:"CommonLinkList",mixins:[o.a],data:function(){return{docVersion:"1.0.1",componentNamespace:"Apps/External",componentPath:"Apps/External/Components/Common/CommonLinkList",component:a,example:{title:{default:"List title",type:"input"},link:{default:"www.otrs.com",type:"input"},linkText:{default:"Read more...",type:"input"},links:{default:[{text:"First link",link:"www.otrs.com"},{text:"Second link",link:"www.otrs.com"},{text:"Third link",link:"www.otrs.com"}],type:"array"}}}}},r=Object(i.a)(c,function(){var t=this,n=t.$createElement,e=t._self._c||n;return e("div",{staticClass:"DesignSystem__Main"},[e("h1",{staticClass:"DesignSystem"},[t._v("\n        "+t._s(t.summary)+"\n        "),e("b-badge",{attrs:{variant:t.docVersion!==t.version?"warning":"info"}},[t._v("\n            "+t._s(t.version)+"\n        ")])],1),t._v(" "),e("p",[t._v("\n        "+t._s(t.description)+"\n    ")]),t._v(" "),t.docVersion!==t.version?[e("CommonNotice",{attrs:{text:"Please verify all changes to the component API have been properly documented\n                ("+t.docVersion+" !== "+t.version+").",title:"Documentation for this component is out of date!",type:"Warning"}})]:t._e(),t._v(" "),e("b-tabs",{staticClass:"DesignSystem__TabContent"},[e("b-tab",{staticClass:"tab-pane",attrs:{title:"Demo","title-link-class":"DesignSystem",active:""}},[e("DocsExample",{attrs:{component:t.component,"component-namespace":t.componentNamespace,"component-path":t.componentPath,props:t.props,events:t.events,slots:t.slots,example:t.example}})],1),t._v(" "),e("b-tab",{staticClass:"tab-pane",attrs:{title:"API Documentation","title-link-class":"DesignSystem"}},[e("DocsComponentAPI",{attrs:{props:t.props,events:t.events,slots:t.slots,methods:t.methods}})],1)],1)],2)},[],!1,null,null,null);n.default=r.exports},YADC:function(t,n,e){"use strict";var o=e("3csR");e.n(o).a}}]);