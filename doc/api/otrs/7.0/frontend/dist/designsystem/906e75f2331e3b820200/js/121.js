(window.webpackJsonp=window.webpackJsonp||[]).push([[121],{U8rn:function(t,n,e){},a0jn:function(t,n,e){"use strict";e.r(n);e("ScpY");var s={name:"LayoutSidebar",components:{LayoutFooter:function(){return e.e(99).then(e.bind(null,"2qWl"))}},data:function(){return{frontends:{agent:{label:"Agent Interface",value:"agent"},external:{label:"External Interface",value:"external"}},sections:[{id:"section1",title:"Guidelines",isCollapsed:!1,items:[{linkText:"Introduction",link:"/documentation/intro"},{linkText:"Components",link:"/documentation/components-usage"}]},{id:"section2",title:"Shared Components",isCollapsed:!1,items:this.$store.getters.components.Components},{id:"section3",title:"External Interface",isCollapsed:!1,items:this.$store.getters.components["Apps/External"]}]}},computed:{frontend:{get:function(){return this.$store.getters.frontend},set:function(t){this.$store.commit("frontend",{frontend:t})}}},methods:{switchFrontend:function(t){this.frontend=t},getCollapseIcon:function(t){return t.isCollapsed?"angle-right":"angle-down"},toggleCollapse:function(t){return!t.link&&(t.isCollapsed=!t.isCollapsed,!0)}}},o=(e("ybUm"),e("psIG")),i=Object(o.a)(s,function(){var t=this,n=t.$createElement,e=t._self._c||n;return e("b-container",{staticClass:"content",attrs:{fluid:""}},[e("b-row",[e("b-col",{staticClass:"aside",attrs:{cols:"2"}},[e("b-dropdown",{staticClass:"interface-selection",attrs:{text:t.frontends[t.frontend].label,hidden:""}},t._l(t.frontends,function(n,s){return e("b-dropdown-item",{key:s,attrs:{disabled:n.disabled},on:{click:function(n){t.switchFrontend(s)}}},[t._v("\n                    "+t._s(n.label)+"\n                ")])})),t._v(" "),t._l(t.sections,function(n){return e("section",{key:n.id,staticClass:"subnavigation"},[n.link?n.target?e("b-link",{attrs:{href:n.link,target:n.target}},[e("CommonIcon",{attrs:{icon:"external-link-alt",size:"sm"}}),t._v(" "),e("h6",{staticClass:"design-system"},[t._v(t._s(n.title))])],1):e("b-link",{attrs:{to:n.link}},[e("h6",{staticClass:"design-system"},[t._v(t._s(n.title))])]):e("b-link",{directives:[{name:"b-toggle",rawName:"v-b-toggle",value:n.id,expression:"section.id"}],on:{click:function(e){t.toggleCollapse(n)}}},[e("CommonIcon",{attrs:{icon:t.getCollapseIcon(n)}}),t._v(" "),e("h6",{staticClass:"design-system"},[t._v(t._s(n.title))])],1),t._v(" "),e("b-collapse",{attrs:{id:n.id,visible:""}},[e("ul",t._l(n.items,function(n){return e("li",{key:n.link||n.componentName},[n.link?e("b-link",{attrs:{to:n.link}},[t._v("\n                                "+t._s(n.linkText)+"\n                            ")]):n.componentName?e("b-link",{attrs:{to:{name:n.componentName}}},[t._v("\n                                "+t._s(n.linkText)+"\n                            ")]):e("b-link",{attrs:{disabled:""}},[t._v("\n                                "+t._s(n.linkText)+"\n                            ")]),t._v(" "),n.subItems?e("ul",t._l(n.subItems,function(s){return e("li",{key:s.link||n.componentName},[s.link?e("b-link",{attrs:{to:s.link}},[t._v("\n                                        "+t._s(s.linkText)+"\n                                    ")]):s.componentName?e("b-link",{attrs:{to:{name:s.componentName}}},[t._v("\n                                        "+t._s(s.linkText)+"\n                                    ")]):t._e()],1)})):t._e()],1)}))])],1)})],2),t._v(" "),e("b-col",[e("router-view"),t._v(" "),e("LayoutFooter")],1)],1)],1)},[],!1,null,"0327239e",null);i.options.__file="LayoutSidebar.vue";n.default=i.exports},ybUm:function(t,n,e){"use strict";var s=e("U8rn");e.n(s).a}}]);