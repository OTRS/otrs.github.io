(window.webpackJsonp=window.webpackJsonp||[]).push([[263,284],{"330A":function(e,i,a){"use strict";a.r(i);var t={name:"DynamicFieldValueDate",extends:a("NSvX").default,data:function(){return{isExpandable:!1}}},n=a("psIG"),l=Object(n.a)(t,function(){var e=this,i=e.$createElement,a=e._self._c||i;return e.isList&&e.displayValue?a("CommonDateTime",{staticClass:"DynamicFieldValue",attrs:{type:e.dynamicFieldConfig.OutputTypeFormat,"date-time":e.displayValue,"absolute-format":"Date"}}):e.isProperty?a("span",[a("b-row",[a("b-col",[a("CommonIcon",{attrs:{icon:"calendar-date"}}),e._v(" "),a("CommonDateTime",{staticClass:"DynamicFieldValue",attrs:{"date-time":e.displayValue,type:"absolute","absolute-format":"Date","no-title":""}})],1)],1)],1):e.isList?e._e():a("span",{staticClass:"DynamicFieldValue"},[e.dynamicField.LinkPreview?a("CommonPopover",{attrs:{link:e.displayLink,preview:e.displayPreview,"link-text":e._f("localize")(e.displayValue,"Date")}}):e.displayLink?a("CommonLink",{attrs:{link:e.displayLink}},[e.displayValue?a("CommonDateTime",{attrs:{type:e.dynamicFieldConfig.OutputTypeFormat,"date-time":e.displayValue,"absolute-format":"Date","no-title":""}}):e._e(),e._v(" "),a("CommonIcon",{attrs:{icon:"app-window-link"}})],1):[e.displayValue?a("CommonDateTime",{attrs:{type:e.dynamicFieldConfig.OutputTypeFormat,"date-time":e.displayValue,"absolute-format":"Date","no-title":""}}):e._e()]],2)},[],!1,null,null,null);i.default=l.exports},NSvX:function(e,i,a){"use strict";a.r(i);var t={name:"DynamicFieldValueBase",components:{CommonPopover:function(){return a.e(51).then(a.bind(null,"7oBH"))},CommonDateTime:function(){return a.e(53).then(a.bind(null,"g17x"))}},props:{dynamicFieldConfig:{type:Object},dynamicField:{type:Object},type:{type:String}},data:function(){return{isMultiline:!1,isExpandable:!0}},computed:{isList:function(){return"list"===this.type},isSidebar:function(){return"sidebar"===this.type},isProperty:function(){return"property"===this.type||"property-expanded"===this.type},isTranslatable:function(){return this.dynamicField.TranslatableValues&&"0"!==this.dynamicField.TranslatableValues},displayLink:function(){return this.dynamicField.Link||""},displayPreview:function(){return this.dynamicField.LinkPreview},displayValue:function(){return this.dynamicField.Value}},created:function(){this.$emit("load",{isMultiline:this.isMultiline,isExpandable:this.isExpandable})}},n=a("psIG"),l=Object(n.a)(t,function(){var e=this,i=e.$createElement,a=e._self._c||i;return e.isList?a("span",{staticClass:"text-truncate w-100 d-inline-block DynamicFieldValue",attrs:{title:e.displayValue}},[e.isTranslatable?[e._v("\n            "+e._s(e._f("translate")(e.displayValue))+"\n        ")]:[e._v("\n            "+e._s(e.displayValue)+"\n        ")]],2):a("span",{staticClass:"DynamicFieldValue"},[e.dynamicField.LinkPreview?a("CommonPopover",{attrs:{link:e.displayLink,preview:e.displayPreview,"link-text":e.displayValue}}):e.displayLink?a("CommonLink",{attrs:{link:e.displayLink}},[e.isMultiline?a("pre",{staticClass:"DynamicFieldValue__Container"},[e._v(e._s(e.displayValue)+"\n            ")]):a("span",[e.isTranslatable?[e._v("\n                    "+e._s(e._f("translate")(e.displayValue))+"\n                ")]:[e._v("\n                    "+e._s(e.displayValue)+"\n                ")]],2),e._v(" "),a("CommonIcon",{attrs:{icon:"app-window-link"}})],1):[e.isMultiline?a("pre",{staticClass:"DynamicFieldValue__Container"},[e._v(e._s(e.displayValue)+"\n            ")]):a("span",[e.isTranslatable?[e._v("\n                    "+e._s(e._f("translate")(e.displayValue))+"\n                ")]:[e._v("\n                    "+e._s(e.displayValue)+"\n                ")]],2)]],2)},[],!1,null,null,null);i.default=l.exports}}]);