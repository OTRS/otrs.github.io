(window.webpackJsonp=window.webpackJsonp||[]).push([[44],{QAut:function(e,t,n){"use strict";n.r(t);n("2Tod"),n("ABKx"),n("W1QL"),n("K/PF"),n("t91x"),n("75LO");var i=n("OvAC"),r=n.n(i),a=n("yBo+");function c(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var i=Object.getOwnPropertySymbols(e);t&&(i=i.filter(function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable})),n.push.apply(n,i)}return n}var l={name:"DynamicField",components:function(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?c(Object(n),!0).forEach(function(t){r()(e,t,n[t])}):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):c(Object(n)).forEach(function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))})}return e}({CommonPopover:function(){return n.e(81).then(n.bind(null,"7oBH"))},CommonDateTime:function(){return n.e(45).then(n.bind(null,"g17x"))},DynamicFieldLabel:function(){return n.e(98).then(n.bind(null,"R4nj"))}},Object(a.a)("Components/DynamicField/Value")),props:{dynamicFieldConfig:{type:Object},dynamicField:{type:Object},type:{type:String},valueLabelClass:{type:String}},data:function(){return{isMultiline:!1}},computed:{classes:function(){var e=[],t="ListItem";return"list"!==this.type&&(t="DetailItem"),e.push(t),e},displayLink:function(){return this.dynamicField.Link||""},displayPreview:function(){return this.dynamicField.LinkPreview},displayValue:function(){return this.dynamicField.Value},isTranslatable:function(){return this.dynamicField.TranslatableValues&&"0"!==this.dynamicField.TranslatableValues},wrapper:function(){return"list"===this.type?"span":"p"}}},s=(n("mxws"),n("psIG")),o=Object(s.a)(l,function(){var e=this,t=e.$createElement,n=e._self._c||t;return n(e.wrapper,{tag:"component",class:e.classes},["list"!==e.type?n("DynamicFieldLabel",{attrs:{"css-class":e.valueLabelClass,type:e.type,text:e.dynamicFieldConfig.Label}}):e._e(),e._v(" "),"sidebar"===e.type?n("br"):e._e(),e._v(" "),n("DynamicFieldValue"+e.dynamicFieldConfig.FieldType,{tag:"component",attrs:{"dynamic-field-config":e.dynamicFieldConfig,"dynamic-field":e.dynamicField,type:e.type}})],1)},[],!1,null,"d5281cda",null);t.default=o.exports},b2gQ:function(e,t,n){},mxws:function(e,t,n){"use strict";var i=n("b2gQ");n.n(i).a}}]);