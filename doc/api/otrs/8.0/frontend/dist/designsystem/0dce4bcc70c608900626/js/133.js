(window.webpackJsonp=window.webpackJsonp||[]).push([[133],{"7gfG":function(t,n,e){},a0jn:function(t,n,e){"use strict";e.r(n);e("ScpY");var s={name:"LayoutSidebar",components:{LayoutFooter:function(){return e.e(108).then(e.bind(null,"2qWl"))}},data:function(){return{sections:[{id:"section1",title:"Guidelines",isCollapsed:!1,items:[{linkText:"Introduction",link:"/documentation/intro"},{linkText:"Components",link:"/documentation/components-usage"}]},{id:"section2",title:"Shared Components",isCollapsed:!1,items:this.$store.getters.components.Components},{id:"section3",title:"Agent Interface",isCollapsed:!1,items:this.$store.getters.components["Apps/Agent"]},{id:"section4",title:"External Interface",isCollapsed:!1,items:this.$store.getters.components["Apps/External"]}]}},methods:{getCollapseIcon:function(t){return t.isCollapsed?"angle-right":"angle-down"},toggleCollapse:function(t){return!t.link&&(t.isCollapsed=!t.isCollapsed,!0)}}},i=(e("oNI/"),e("psIG")),o=Object(i.a)(s,function(){var t=this,n=t.$createElement,e=t._self._c||n;return e("b-container",{staticClass:"DesignSystem DesignSystem__Content",attrs:{fluid:""}},[e("b-row",[e("b-col",{staticClass:"DesignSystem__Content--Aside",attrs:{cols:"2"}},t._l(t.sections,function(n){return e("section",{key:n.id,staticClass:"DesignSystem__SubNavigation"},[n.link?n.target?e("b-link",{attrs:{href:n.link,target:n.target}},[e("CommonIcon",{attrs:{icon:"external-link-alt",size:"sm"}}),t._v(" "),e("h6",{staticClass:"DesignSystem"},[t._v("\n                        "+t._s(n.title)+"\n                    ")])],1):e("b-link",{attrs:{to:n.link}},[e("h6",{staticClass:"DesignSystem"},[t._v("\n                        "+t._s(n.title)+"\n                    ")])]):e("b-link",{directives:[{name:"b-toggle",rawName:"v-b-toggle",value:n.id,expression:"section.id"}],on:{click:function(e){t.toggleCollapse(n)}}},[e("CommonIcon",{attrs:{icon:t.getCollapseIcon(n)}}),t._v(" "),e("h6",{staticClass:"DesignSystem"},[t._v("\n                        "+t._s(n.title)+"\n                    ")])],1),t._v(" "),e("b-collapse",{attrs:{id:n.id,visible:""}},[e("ul",t._l(n.items,function(n){return e("li",{key:n.link||n.componentName},[n.link?e("b-link",{attrs:{to:n.link}},[t._v("\n                                "+t._s(n.linkText)+"\n                            ")]):n.componentName?e("b-link",{class:["DesignSystem__DocComponent--"+n.componentName],attrs:{to:{name:n.componentName}}},[t._v("\n                                "+t._s(n.linkText)+"\n                            ")]):e("b-link",{attrs:{disabled:""}},[t._v("\n                                "+t._s(n.linkText)+"\n                            ")]),t._v(" "),n.subItems?e("ul",t._l(n.subItems,function(s){return e("li",{key:s.link||n.componentName},[s.link?e("b-link",{attrs:{to:s.link}},[t._v("\n                                        "+t._s(s.linkText)+"\n                                    ")]):s.componentName?e("b-link",{class:["DesignSystem__DocComponent--"+s.componentName],attrs:{to:{name:s.componentName}}},[t._v("\n                                        "+t._s(s.linkText)+"\n                                    ")]):t._e()],1)})):t._e()],1)}))])],1)})),t._v(" "),e("b-col",[e("router-view"),t._v(" "),e("LayoutFooter")],1)],1)],1)},[],!1,null,null,null);o.options.__file="LayoutSidebar.vue";n.default=o.exports},"oNI/":function(t,n,e){"use strict";var s=e("7gfG");e.n(s).a}}]);