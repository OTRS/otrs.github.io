(window.webpackJsonp=window.webpackJsonp||[]).push([[93],{"+3YS":function(e,t){e.exports=function(e){if(Array.isArray(e))return e}},"+bRE":function(e,t){e.exports=function(){throw new TypeError("Invalid attempt to destructure non-iterable instance")}},DAvA:function(e,t,i){"use strict";i.r(t);var n=i("nxTg"),r=i.n(n),l=i("gki9"),a=i.n(l),s=(i("2UZ+"),i("GkPX"),i("9ovy"),i("it7j"),i("K/PF"),i("75LO"),i("W1QL"),i("e2Kn"),{name:"FormFilterBy",components:{FormGroup:function(){return Promise.all([i.e(15),i.e(181)]).then(i.bind(null,"yFPx"))},FormSelect:function(){return Promise.all([i.e(1),i.e(2),i.e(182)]).then(i.bind(null,"cDBQ"))}},props:{value:{type:Object},filters:{type:Object},fields:{type:Array},errors:{type:Object},propOverride:{type:Object},name:{type:String,default:""},label:{type:String},description:{type:String},hint:{type:String},setValue:{type:Function},removeValue:{type:Function},columnLayout:{type:Number,default:1},isRoot:{type:Boolean},hideDescription:{type:Boolean},filterText:{type:String}},data:function(){return{adding:[],localFields:[],filtered:{}}},computed:{availableFilters:function(){var e=this,t=[];return Object.keys(this.filters).forEach(function(i){var n=e.filters[i];Object.keys(e.value).find(function(t){return t.match("^".concat(e.name,".").concat(i))})||t.push({id:i,label:n.Label})}),t},canAdd:function(){if(this.availableFilters.length){var e=0;return this.adding.forEach(function(t){t||(e+=1)}),e<this.availableFilters.length}return!1},isHidden:function(){if(this.isRoot)return!1;var e=Object.keys(this.filtered).length;return this.adding.length===e}},watch:{fields:function(e){var t=this,i=this.adding.indexOf(null);-1!==i&&this.adding.splice(i,1),e.forEach(function(e){var i=t.localFields.findIndex(function(t){return e.Name===t.Name});-1!==i?t.localFields[i]=e:t.localFields.push(e)});for(var n=this.localFields.length,r=function(){n-=1;var i=t.localFields[n];e.find(function(e){return e.Name===i.Name})||t.localFields.splice(n,1)};n>0;)r();this.checkState()}},created:function(){this.localFields=this.fields.map(function(e){return e}),this.checkState()},methods:{add:function(){this.canAdd&&this.adding.push(null)},remove:function(e){for(var t=this.filters[e],i=t.Fields.length;i>0;){i-=1;var n=t.Fields[i],r=[this.name,e,n.Name].join("."),l=a()({},n,{UpdateForm:!1});this.removeValue(l,r)}var s=this.localFields.findIndex(function(t){return t.Name===e});this.localFields.splice(s,1);var o=this.adding.indexOf(e);-1!==o&&(this.$refs.filterSelect[o].clear(),this.adding.splice(o,1)),this.checkState()},onSelect:function(e,t){var i=this;if(t){this.adding[e]=t;var n=this.filters[t];n.Fields.forEach(function(e){var n=[i.name,t,e.Name].join("."),r=a()({},e,{UpdateForm:!1});i.setValue(r,n,null)}),this.localFields.push({Name:t,Type:"FormGroup",Label:n.Label,Config:{Fields:n.Fields}})}},checkState:function(){var e=this;this.$nextTick(function(){e.localFields.forEach(function(t,i){-1===e.adding.indexOf(t.Name)&&e.adding.splice(i,0,t.Name)}),e.adding.length||e.add()})},removeAdding:function(e){this.adding.splice(e,1)},onFiltering:function(e,t){t.result?this.$set(this.filtered,e,!0):this.$delete(this.filtered,e),this.$emit("filtering",this.isHidden),this.isRoot&&this.isHidden&&this.$emit("filtered",this.isHidden)},getFilterLabel:function(e){var t=this.filters[e];if(!t)return null;var i=t.Label,n=t.Fields;return n.length>1?i:r()(n,1)[0].Label===i?null:i}}}),o=(i("PEK1"),i("psIG")),c=Object(o.a)(s,function(){var e=this,t=e.$createElement,i=e._self._c||t;return i("b-form-group",{directives:[{name:"show",rawName:"v-show",value:!e.isHidden,expression:"!isHidden"}],staticClass:"FormFilterBy",attrs:{label:e._f("translate")(e.label),description:e._f("translate")(e.description)}},[e.label&&e.description&&e.hideDescription?[i("template",{slot:"label"},[e._v("\n            "+e._s(e._f("translate")(e.label))+"\n            "),i("b-link",{directives:[{name:"b-tooltip",rawName:"v-b-tooltip.html",modifiers:{html:!0}}],staticClass:"float-right",attrs:{title:e._f("translate")(e.description)}},[i("CommonIcon",{staticClass:"mx-2",attrs:{weight:"bold",icon:"information-circle"}})],1)],1),e._v(" "),i("template",{slot:"description"},[i("small",{staticClass:"sr-only"},[e._v("\n                "+e._s(e._f("translate")(e.description))+"\n            ")])])]:e._e(),e._v(" "),e._l(e.localFields,function(t){return i("b-row",{key:t.Name},[i("b-col",{directives:[{name:"show",rawName:"v-show",value:!e.filtered[t.Name],expression:"!filtered[field.Name]"}],attrs:{cols:"10"}},[i("FormGroup",{attrs:{name:e.name+"."+t.Name,"set-value":e.setValue,fields:t.Config.Fields,errors:e.errors,"prop-override":e.propOverride,"column-layout":e.columnLayout,"hide-description":e.hideDescription,"filter-text":e.filterText,disabled:t.Disabled,label:e.getFilterLabel(t.Name)},on:{filtering:function(i){return e.onFiltering(t.Name,i)}},model:{value:e.value,callback:function(t){e.value=t},expression:"value"}})],1),e._v(" "),t.Disabled?e._e():i("b-col",{directives:[{name:"show",rawName:"v-show",value:!e.filtered[t.Name],expression:"!filtered[field.Name]"}],staticClass:"mb-3 pb-2",attrs:{cols:"2"}},[i("CommonLink",{on:{click:function(i){return e.remove(t.Name)}}},[i("CommonIcon",{staticClass:"mr-3",attrs:{weight:"regular",icon:"bin-2-alternate"}})],1)],1)],1)}),e._v(" "),e._l(e.adding,function(t,n){return i("b-row",{key:n},[i("b-col",{attrs:{cols:"10"}},[i("FormSelect",{directives:[{name:"show",rawName:"v-show",value:!e.adding[n],expression:"!adding[index]"}],ref:"filterSelect",refInFor:!0,attrs:{placeholder:e._f("translate")("Select..."),options:e.availableFilters},on:{input:function(t){return e.onSelect(n,t)}}})],1),e._v(" "),i("b-col",{directives:[{name:"show",rawName:"v-show",value:!e.adding[n]&&e.adding.length>1,expression:"!adding[index] && adding.length > 1"}],staticClass:"mb-3 pb-2",attrs:{cols:"2"}},[i("CommonLink",{staticClass:"mr-3",on:{click:function(t){return e.removeAdding(n)}}},[i("CommonIcon",{attrs:{weight:"regular",icon:"bin"}})],1)],1)],1)}),e._v(" "),e.canAdd?i("b-row",[i("b-col",{staticClass:"text-right"},[i("CommonLink",{staticClass:"FormFilterBy__Add",on:{click:e.add}},[e._v("\n                "+e._s(e._f("translate")("+ add new filter"))+"\n            ")])],1)],1):e._e()],2)},[],!1,null,null,null);t.default=c.exports},PEK1:function(e,t,i){"use strict";var n=i("qiHR");i.n(n).a},S411:function(e,t){e.exports=function(e,t){var i=[],n=!0,r=!1,l=void 0;try{for(var a,s=e[Symbol.iterator]();!(n=(a=s.next()).done)&&(i.push(a.value),!t||i.length!==t);n=!0);}catch(e){r=!0,l=e}finally{try{n||null==s.return||s.return()}finally{if(r)throw l}}return i}},nxTg:function(e,t,i){var n=i("+3YS"),r=i("S411"),l=i("+bRE");e.exports=function(e,t){return n(e)||r(e,t)||l()}},qiHR:function(e,t,i){}}]);