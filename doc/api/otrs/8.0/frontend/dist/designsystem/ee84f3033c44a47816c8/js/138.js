(window.webpackJsonp=window.webpackJsonp||[]).push([[138,14],{"3Hfo":function(e,t,n){"use strict";var o=n("8CHY");t.a={methods:{filter:function(e){var t=this,n="";return["label","description","localPlaceholder"].forEach(function(e){n+=t.$locale.translate(t[e])}),Object(o.a)(n,e)}}}},Hzqv:function(e,t,n){"use strict";n.r(t);var o=n("A86J"),a=n("3Hfo"),i={name:"FormCheckbox",directives:{focus:{inserted:function(e,t){t.value&&e.querySelector("input").focus()}}},mixins:[o.a,a.a],props:{value:{type:Boolean},name:{type:String},error:{type:String},label:{type:String},required:{type:Boolean,default:!1},description:{type:String},disabled:{type:Boolean,default:!1},hidden:{type:Boolean,default:!1},hideDescription:{type:Boolean,default:!1}},computed:{fieldId:function(){return"formCheckbox-".concat(this._uid)},localValue:{get:function(){return this.value},set:function(e,t){this.$emit("input",e,t)}}},methods:{onChange:function(e,t){this.$emit("change",e,t)}}},l=n("psIG"),r=Object(l.a)(i,function(){var e=this,t=e.$createElement,n=e._self._c||t;return n("b-form-group",{directives:[{name:"show",rawName:"v-show",value:!e.hidden,expression:"!hidden"}],attrs:{state:Boolean(e.error)?"invalid":null,description:e._f("translate")(e.description),"invalid-feedback":e._f("translate")(e.error)}},[e.label&&e.description&&e.hideDescription?n("template",{slot:"description"},[n("small",{staticClass:"sr-only"},[e._v("\n            "+e._s(e._f("translate")(e.description))+"\n        ")])]):e._e(),e._v(" "),n("b-form-checkbox",{directives:[{name:"focus",rawName:"v-focus",value:e.autoFocus,expression:"autoFocus"}],attrs:{id:e.fieldId,name:e.name,disabled:e.disabled,state:Boolean(e.error)?"invalid":null},on:{change:e.onChange},model:{value:e.localValue,callback:function(t){e.localValue=t},expression:"localValue"}},[e._v("\n        "+e._s(e._f("translate")(e.label))+"\n        "),e.label&&e.description&&e.hideDescription?[n("b-link",{directives:[{name:"b-tooltip",rawName:"v-b-tooltip.html",modifiers:{html:!0}}],staticClass:"float-right",attrs:{title:e._f("translate")(e.description)}},[n("CommonIcon",{staticClass:"mx-2",attrs:{icon:"info-circle"}})],1)]:e._e()],2)],2)},[],!1,null,null,null);r.options.__file="FormCheckbox.vue";t.default=r.exports}}]);