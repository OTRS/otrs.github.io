(window.webpackJsonp=window.webpackJsonp||[]).push([[8],{"1BT7":function(e,t,o){"use strict";o.r(t);var n=o("gki9"),l=o.n(n),i=o("F/wX"),a=o.n(i),r={name:"FormAutocomplete",components:{FormSelect:function(){return Promise.all([o.e(0),o.e(2),o.e(22)]).then(o.bind(null,"cDBQ"))}},props:{value:{type:null},url:{type:String,required:!0},params:{type:Object},error:{type:String},label:{type:String},labelSrOnly:{type:Boolean,default:!1},required:{type:Boolean,default:!1},description:{type:String},autoFocus:{type:Boolean,default:!1},name:{type:String},noResultsText:{type:String},multiple:{type:Boolean,default:!1},searchPromptText:{type:String},disabled:{type:Boolean,default:!1},hidden:{type:Boolean,default:!1},hideDescription:{type:Boolean,default:!1},placeholder:{type:String},clearOnSelect:{type:Boolean,default:!1},testMode:{type:Boolean,default:!1}},data:function(){return{options:[],searchTimeout:{id:null,callback:null}}},computed:{localValue:{get:function(){return this.value},set:function(e,t){this.$emit("input",e,t)}},finalParams:function(){return this.params}},methods:{loadOptions:function(e){var t=this,o=e.action,n=e.callback,l=e.searchQuery;if("ASYNC_SEARCH"===o){if(this.searchQuery=l,this.searchTimeout.id&&(clearTimeout(this.searchTimeout.id),this.searchTimeout.callback(null,[]),this.searchTimeout.id=null,this.searchTimeout.callback=null),!l)return this.options=[],void n(null,this.options);this.searchTimeout.callback=n,this.searchTimeout.id=setTimeout(function(){t.fetchOptions(l,n)},400)}},fetchOptions:function(e,t){var o=this;this.testMode?setTimeout(function(){o.options=a.a.tz.names().reduce(function(t,o){return t.length<20&&-1!==o.toLowerCase().indexOf(e.toLowerCase())&&t.push({id:o,label:o,data:{timezoneId:o}}),t},[]),t(null,o.options)},300):this.clientSendRequest({Path:this.url,Method:"get",Query:l()({SearchTerm:e},this.finalParams)}).then(function(e){o.options=e.Body.Options,t(null,o.options)}).catch(function(e){o.options=[],o.$log.error(e),t("An error occurred while fetching the options.",[])})},focus:function(){this.$refs.input.$el.focus()},select:function(e,t){this.$emit("select",e,t)},filter:function(e){return this.$refs.formSelect.filter(e)}}},s=(o("Mk2q"),o("psIG")),c=Object(s.a)(r,function(){var e=this,t=e.$createElement,o=e._self._c||t;return o("FormSelect",{ref:"formSelect",staticClass:"Form__Autocomplete",attrs:{"auto-focus":e.autoFocus,error:e.error,label:e.label,"label-sr-only":e.labelSrOnly,required:e.required,description:e.description,name:e.name,multiple:e.multiple,disabled:e.disabled,hidden:e.hidden,"hide-description":e.hideDescription,placeholder:e.placeholder,"clear-on-select":e.clearOnSelect,options:e.options,"load-options":e.loadOptions,"cache-options":!1,"no-results-text":e.noResultsText,"search-prompt-text":e.searchPromptText,async:"","open-on-focus":""},on:{select:e.select},model:{value:e.localValue,callback:function(t){e.localValue=t},expression:"localValue"}},[o("template",{slot:"append-inline"},[e._t("append-inline")],2)],2)},[],!1,null,null,null);t.default=c.exports},"9Zdt":function(e,t,o){},Mk2q:function(e,t,o){"use strict";var n=o("9Zdt");o.n(n).a}}]);