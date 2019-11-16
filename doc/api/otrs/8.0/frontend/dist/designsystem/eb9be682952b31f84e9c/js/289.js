(window.webpackJsonp=window.webpackJsonp||[]).push([[289],{"7CRW":function(e,t,o){},"cZP/":function(e,t,o){"use strict";o.r(t);o("DbwS"),o("t91x");var n={name:"BusinessObjectWidgetPropertyLayout",components:{Form:function(){return Promise.all([o.e(9),o.e(11),o.e(22)]).then(o.bind(null,"GgUG"))}},props:{propertyName:{type:String,required:!0},active:{type:Boolean,default:!0},isEditable:{type:Boolean},isExpandable:{type:Boolean},label:{type:String,required:!0},formSchemaUrl:{type:String,required:!0},propertyUpdateUrl:{type:String,required:!0},formRequestParams:{type:Object},formMode:{type:Boolean,default:!1},columnLayout:{type:String}},data:function(){return{expanded:!1,dataChanged:!1}},computed:{localFormMode:{get:function(){return this.formMode},set:function(e){this.$emit("form-mode",e)}},xlCols:function(){switch(this.columnLayout){case"ThreeColumns":return this.expanded?12:6;case"TwoColumns":return this.expanded?12:4;case"OneColumn":default:return this.expanded?12:3}},lgCols:function(){switch(this.columnLayout){case"ThreeColumns":return 12;case"TwoColumns":return this.expanded?12:6;case"OneColumn":default:return this.expanded?12:4}},mdCols:function(){switch(this.columnLayout){case"ThreeColumns":case"TwoColumns":return 12;case"OneColumn":default:return this.expanded?12:6}}},methods:{toggleProperty:function(){this.expanded=!this.expanded,this.$emit("expanded",this.expanded)},toggleFormMode:function(){this.localFormMode?this.cancel():this.localFormMode=!this.localFormMode},saveAndClose:function(){this.$refs.form.submit()},onFormChanged:function(){this.dataChanged=!0},onFormValid:function(e){var t=this;if(!this.dataChanged)return this.$emit("cancel"),void(this.localFormMode=!1);var o=e;this.clientSendRequest({Path:this.propertyUpdateUrl,Method:"post",Body:o}).then(function(){t.$emit("updated"),t.dataChanged=!1,t.localFormMode=!1,t.$nextTick(function(){t.$test.setFlag("WidgetPropertyUpdate::".concat(t.propertyName))})}).catch(function(e){t.$log.error(e),t.$bus.$emit("showToastMessage",{id:"propertyUpdate",heading:"Error Updating Widget Property",text:"The widget property could not be updated. Please contact the administrator.",variant:"danger",persistent:!1})})},confirmCancel:function(){var e=this;return new Promise(function(t){e.dataChanged?e.$bus.$emit("showModalMessage",{id:"confirmCancel",heading:"Discard Changes",text:"You have unsaved changes. Do you really want to close?",buttonBehavior:"yesNo",okCallback:function(){e.$refs.form&&e.$refs.form.resetForm(!0,!0),t(!0)},cancelCallback:function(){t(!1)}}):t(!0)})},onFormInValid:function(e){this.$emit("invalid",e)},cancel:function(){var e=this;this.confirmCancel().then(function(t){t&&(e.$emit("cancel"),e.dataChanged=!1,e.localFormMode=!1)})}}},a=(o("vjyK"),o("psIG")),r=Object(a.a)(n,function(){var e=this,t=e.$createElement,o=e._self._c||t;return e.active?o("b-col",{attrs:{xl:e.xlCols,lg:e.lgCols,md:e.mdCols}},[o("b-row",[o("b-col",{staticClass:"border bg-white mr-3 mb-3 PropertyCard",class:"PropertyCard__"+e.propertyName},[o("b-row",{staticClass:"py-2 border-bottom",attrs:{"align-v":"center"}},[o("b-col",{staticClass:"PropertyCard__Header"},[o("h3",{staticClass:"p-0 m-0"},[e._v("\n                        "+e._s(e._f("translate")(e.label))+"\n                    ")])]),e._v(" "),o("b-col",{staticClass:"text-right",attrs:{cols:"auto"}},[e.isEditable?o("CommonLink",{on:{click:e.toggleFormMode}},[o("CommonIcon",{attrs:{icon:"content-pen-3"}})],1):e._e(),e._v(" "),e.isExpandable?o("CommonLink",{staticClass:"ml-2",on:{click:e.toggleProperty}},[o("CommonIcon",{attrs:{icon:e.expanded?"shrink-2":"expand-3"}})],1):e._e()],1)],1),e._v(" "),o("b-row",[o("b-col",{staticClass:"py-2 mx-3 px-0 PropertyCard__Content__Wrapper",class:e.formMode||e.expanded?"PropertyCard__Content--DynamicHeight":"PropertyCard__Content--FixedHeight"},[e.formMode?o("div",{key:"form"+e.propertyName+"Property"},[o("Form",{ref:"form",attrs:{url:e.formSchemaUrl,params:e.formRequestParams,"hide-description":"","emit-values-in-complex-object":""},on:{changed:e.onFormChanged,invalid:e.onFormInValid,valid:e.onFormValid}}),e._v(" "),o("b-row",{attrs:{"no-gutters":""}},[o("b-col",{staticClass:"col-12 text-right"},[o("CommonLink",{staticClass:"btn btn-secondary Button Button--Secondary",on:{click:function(t){return e.cancel()}}},[e._v("\n                                    "+e._s(e._f("translate")("Cancel"))+"\n                                ")]),e._v(" "),o("CommonLink",{staticClass:"btn btn-primary Button Button--Primary",on:{click:function(t){return e.saveAndClose()}}},[e._v("\n                                    "+e._s(e._f("translate")("Save"))+"\n                                ")])],1)],1)],1):e._t("default")],2)],1),e._v(" "),!e.isExpandable||e.expanded||e.localFormMode?e._e():o("div",{staticClass:"position-absolute w-100 PropertyCard__GradientOverlay"})],1)],1)],1):e._e()},[],!1,null,null,null);t.default=r.exports},vjyK:function(e,t,o){"use strict";var n=o("7CRW");o.n(n).a}}]);