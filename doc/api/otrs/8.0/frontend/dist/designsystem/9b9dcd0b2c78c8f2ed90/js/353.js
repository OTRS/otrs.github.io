(window.webpackJsonp=window.webpackJsonp||[]).push([[353,373],{NSvX:function(t,i,n){"use strict";n.r(i);n("4aJ6"),n("t91x");var a={name:"DynamicFieldValueBase",components:{CommonPopover:function(){return n.e(82).then(n.bind(null,"7oBH"))},CommonDateTime:function(){return n.e(46).then(n.bind(null,"g17x"))}},props:{dynamicFieldConfig:{type:Object},dynamicField:{type:Object},type:{type:String}},data:function(){return{isMultiline:!1,isExpandable:!0}},computed:{isList:function(){return"list"===this.type},isSidebar:function(){return"sidebar"===this.type},isProperty:function(){return"property"===this.type||"property-expanded"===this.type},isTranslatable:function(){return this.dynamicField.TranslatableValues&&"0"!==this.dynamicField.TranslatableValues.toString()},noTooltipTitle:function(){return this.dynamicFieldConfig.noTooltipTitle},displayLink:function(){return this.dynamicField.Link||""},displayPreview:function(){return this.dynamicField.LinkPreview},displayValue:function(){return this.dynamicField.Value}},created:function(){this.$emit("load",{isMultiline:this.isMultiline,isExpandable:this.isExpandable})}},e=(n("Qeht"),n("psIG")),l=Object(e.a)(a,function(){var t=this,i=t.$createElement,n=t._self._c||i;return t.isList?n("span",{directives:[{name:"b-tooltip",rawName:"v-b-tooltip.hover.right",modifiers:{hover:!0,right:!0}}],staticClass:"DynamicFieldValue",attrs:{title:!t.noTooltipTitle&&t.displayValue.length>50?t.displayValue:""}},[t.isTranslatable?[t.displayValue.length>50?[t._v("\n                "+t._s(t._f("truncate")(t._f("translate")(t.displayValue),50))+"\n            ")]:[t._v("\n                "+t._s(t._f("translate")(t.displayValue))+"\n            ")]]:[t.displayValue.length>50?[t._v("\n                "+t._s(t._f("truncate")(t.displayValue,50))+"\n            ")]:[t._v("\n                "+t._s(t.displayValue)+"\n            ")]]],2):n("span",{staticClass:"DynamicFieldValue"},[t.dynamicField.LinkPreview?n("CommonPopover",{attrs:{link:t.displayLink,preview:t.displayPreview,"link-text":t.displayValue}}):t.displayLink?n("CommonLink",{attrs:{link:t.displayLink}},[t.isMultiline?n("pre",{staticClass:"DynamicFieldValue__Container"},[t._v(t._s(t.displayValue))]):n("span",[t.isTranslatable?[t._v("\n                    "+t._s(t._f("translate")(t.displayValue))+"\n                ")]:[t._v("\n                    "+t._s(t.displayValue)+"\n                ")]],2),t._v(" "),n("CommonIcon",{attrs:{icon:"app-window-link"}})],1):[t.isMultiline?n("pre",{staticClass:"DynamicFieldValue__Container"},[t._v(t._s(t.displayValue))]):n("span",[t.isTranslatable?[t._v("\n                    "+t._s(t._f("translate")(t.displayValue))+"\n                ")]:[t._v("\n                    "+t._s(t.displayValue)+"\n                ")]],2)]],2)},[],!1,null,null,null);i.default=l.exports},Qeht:function(t,i,n){"use strict";var a=n("mvJA");n.n(a).a},mvJA:function(t,i,n){},qAuO:function(t,i,n){"use strict";n.r(i);var a={name:"DynamicFieldValueContactWithData",extends:n("NSvX").default,computed:{goToContactManagement:function(){return""!==this.dynamicField.AdminLink},displayListValue:function(){return this.dynamicField.Contact[this.dynamicField.NameField]||this.dynamicField.Value}}},e=n("psIG"),l=Object(e.a)(a,function(){var t=this,i=t.$createElement,n=t._self._c||i;return t.isProperty?n("span",{staticClass:"DynamicFieldValue"},[t.goToContactManagement?n("div",{staticClass:"text-right"},[n("CommonLink",{staticClass:"btn btn-primary Button Button--Secondary",attrs:{link:t.dynamicField.AdminLink,target:"_blank","aria-label":t._f("translate")("Edit contact")}},[n("span",[t._v(t._s(t._f("translate")("Edit contact")))])])],1):t._e(),t._v(" "),t._l(t.dynamicField.SortOrder,function(i,a){return[n("div",{key:a,staticClass:"pb-3"},[n("span",{staticClass:"PropertyCard__Description"},[t._v("\n                "+t._s(t._f("translate")(i))+"\n            ")]),t._v(" "),n("br"),t._v(" "),n("span",{staticClass:"PropertyCard__Value"},[t._v("\n                "+t._s(t.dynamicField.Contact[i])+"\n            ")])])]})],2):n("span",{directives:[{name:"b-tooltip",rawName:"v-b-tooltip.hover.right",modifiers:{hover:!0,right:!0}}],staticClass:"DynamicFieldValue",attrs:{title:!t.noTooltipTitle&&t.displayListValue.length>50?t.displayListValue:""}},[[t.displayListValue.length>50?[t._v("\n            "+t._s(t._f("truncate")(t.displayListValue,50))+"\n        ")]:[t._v("\n            "+t._s(t.displayListValue)+"\n        ")]]],2)},[],!1,null,null,null);i.default=l.exports}}]);