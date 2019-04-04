(window.webpackJsonp=window.webpackJsonp||[]).push([[130,14],{"433n":function(e,t,i){"use strict";i.r(t);i("GkPX"),i("K/PF"),i("75LO"),i("W1QL");var a=i("8CHY"),o=i("A86J"),l=i("IA8J"),n={name:"FormUpload",directives:{focus:{inserted:function(e,t){t.value&&e.querySelector("input").focus()}}},mixins:[o.a],props:{name:{type:String},formId:{type:String,required:!0},uploadPath:{type:String,required:!0},error:{type:String},label:{type:String},labelSrOnly:{type:Boolean,default:!1},required:{type:Boolean,default:!1},description:{type:String},hidden:{type:Boolean,default:!1},hideDescription:{type:Boolean,default:!1},placeholder:{type:String,default:"Select or drop files here."},multiple:{type:Boolean,default:!0},testMode:{type:Boolean,default:!1},fileIconWeight:{type:String,default:"regular",validator:function(e){return-1!==["light","regular","bold"].indexOf(e)}},fileIcon:{type:String,default:"common-file-empty-alternate"},displayValue:{type:Object},value:{type:[Array,Object]}},data:function(){return{files:[],uploads:{},localValue:{},fileSizeUploadError:!1}},computed:{fieldId:function(){return"formUpload-".concat(this._uid)},hasUploadError:function(){var e=this,t=!1;return this.fileSizeUploadError||Object.keys(this.uploads).forEach(function(i){"danger"===e.uploads[i].variant&&(t=!0)}),t}},watch:{localValue:function(e){this.$emit("input",e)},displayValue:function(){this.uploads={}}},mounted:function(){this.initSelectedFiles()},methods:{uploadFiles:function(){var e=this,t=this.files;Array.isArray(t)||(t=[],null!==this.files&&t.push(this.files)),t.length&&(this.multiple||Object.keys(this.uploads).forEach(function(t){var i=e.uploads[t];e.deleteFile(i.fieldId,i.filename)}),t.forEach(function(t){if(e.$set(e.uploads,t.name,{filename:t.name,fileId:null,progress:0,variant:"",type:t.type,size:t.size}),e.testMode)return e.$nextTick(function(){e.uploads[t.name].progress=100}),Math.floor(2*Math.random())?e.uploadFileDisplay(t.name,t):(e.$refs.uploadFile.reset(),e.uploads[t.name].variant="danger"),void(e.files=[]);if(t.size>e.$store.getters.config.WebMaxFileUpload)return e.$refs.uploadFile.reset(),e.uploads[t.name].variant="danger",void(e.fileSizeUploadError=!0);e.fileSizeUploadError=!1;var i=new FormData;i.append("Upload",t),i.append("Disposition","attachment"),e.clientSendRequest({Path:"".concat(e.uploadPath,"/").concat(e.formId),Method:"post",Body:i},{xhr:!0,responseType:"json",responseTimeout:0,onUploadProgress:function(i){i.lengthComputable?e.uploads[t.name].progress=100*i.loaded/i.total:e.uploads[t.name].variant="warning"}}).then(function(i){e.uploadFileDisplay(t.name,i.Body),e.files=[]}).catch(function(i){e.$log.error(i),e.$refs.uploadFile.reset(),e.uploads[t.name].variant="danger",e.files=[]})}))},uploadFileDisplay:function(e,t){this.testMode&&(t.FileSize=t.size,delete t.size,t.ContentType=t.type,delete t.type,t.FileID=Math.floor(100*Math.random()+1));var i=t.FileID;this.$refs.uploadFile.reset(),this.$set(this.uploads[e],"fileId",i),this.$set(this.uploads[e],"variant","success"),this.$set(this.uploads[e],"size",t.FileSize),this.$set(this.uploads[e],"type",t.ContentType),this.$set(this.localValue,i,this.uploads[e]),this.$emit("input",this.localValue)},deleteFile:function(e,t){var i=this;if(e&&!this.testMode)this.clientSendRequest({Path:"".concat(this.uploadPath,"/").concat(this.formId),Method:"delete",Body:{Filename:t}}).then(function(){i.$delete(i.uploads,t),i.$delete(i.localValue,e)}).catch(function(e){i.$log.error(e),i.uploads[t].variant="danger"});else if(e)this.$delete(this.uploads,t),this.$delete(this.localValue,e);else{var a=this.uploads[t].fileId;this.$delete(this.uploads,t),this.localValue[a]&&this.$delete(this.localValue,a)}this.fileSizeUploadError=!1},reset:function(){this.files=[],this.$refs.uploadFile.reset(),this.uploads={},this.localValue={}},initSelectedFiles:function(){var e=this,t=this.value;t&&(Array.isArray(t)||(t=[t]),t.forEach(function(t){t&&Object.keys(t).forEach(function(i){var a=i,o=t[i].filename,l=t[i].type,n=t[i].size;e.$set(e.uploads,o,{fileId:a,filename:o,variant:"success",progress:100,type:l,size:n}),e.$set(e.localValue,a,o)})}))},filter:function(e){var t=this,i="";return["label","description","placeholder"].forEach(function(e){i+=t.$locale.translate(t[e])}),Object(a.a)(i,e)},fileMetadataLabel:function(e){var t;return t=e.filename,e.type&&(t+=" | ".concat(Object(l.a)(e.type).name)),e.size&&(t+=" | ".concat(this.$options.filters.filesize(e.size))),t}}},s=i("psIG"),r=Object(s.a)(n,function(){var e=this,t=e.$createElement,i=e._self._c||t;return i("b-form-group",{directives:[{name:"show",rawName:"v-show",value:!e.hidden,expression:"!hidden"}],attrs:{state:Boolean(e.error)?"invalid":null,label:e._f("translate")(e.label),"label-for":e.fieldId,"label-class":e.required?"required":null,"label-sr-only":e.labelSrOnly,description:e._f("translate")(e.description),"invalid-feedback":e._f("translate")(e.error)}},[e.label&&e.description&&e.hideDescription?[i("template",{slot:"label"},[e._v("\n            "+e._s(e._f("translate")(e.label))+"\n            "),i("b-link",{directives:[{name:"b-tooltip",rawName:"v-b-tooltip.html",modifiers:{html:!0}}],staticClass:"float-right",attrs:{title:e._f("translate")(e.description)}},[i("CommonIcon",{staticClass:"mx-2",attrs:{weight:"bold",icon:"information-circle"}})],1)],1),e._v(" "),i("template",{slot:"description"},[i("small",{staticClass:"sr-only"},[e._v("\n                "+e._s(e._f("translate")(e.description))+"\n            ")])])]:e._e(),e._v(" "),i("b-form-file",{directives:[{name:"focus",rawName:"v-focus",value:e.autoFocus,expression:"autoFocus"}],ref:"uploadFile",attrs:{id:e.fieldId,name:e.name,placeholder:e._f("translate")(e.placeholder),multiple:e.multiple},on:{input:function(t){return e.uploadFiles()}},model:{value:e.files,callback:function(t){e.files=t},expression:"files"}}),e._v(" "),i("div",{staticClass:"container-fluid"},[e.fileSizeUploadError?i("small",{staticClass:"form-text Form--Danger Form__Help"},[i("CommonIcon",{attrs:{weight:"bold",icon:"alert-circle"}}),e._v("\n            "+e._s(e._f("translate")("File too large"))+"\n        ")],1):e._e(),e._v(" "),e.hasUploadError?i("small",{staticClass:"form-text Form--Danger Form__Help"},[i("CommonIcon",{attrs:{weight:"bold",icon:"alert-circle"}}),e._v("\n            "+e._s(e._f("translate")("Something went wrong, please try again later."))+"\n        ")],1):e._e(),e._v(" "),e.displayValue?i("b-row",[i("b-col",{staticClass:"FormUpload__CurrentValue"},e._l(e.displayValue,function(t,a){return i("div",{key:"file-"+a},[i("CommonIcon",{attrs:{weight:e.fileIconWeight,icon:e.fileIcon}}),e._v("\n                    "+e._s(t)+"\n                ")],1)}),0)],1):e._e(),e._v(" "),e._l(e.uploads,function(t){return i("b-row",{key:t.filename,staticClass:"mt-2",attrs:{"align-v":"center"}},[i("b-col",[i("b-progress",{staticClass:"Form__Progress",attrs:{max:100}},[i("b-progress-bar",{staticClass:"Form__ProgressBar",attrs:{value:t.progress,variant:t.variant,label:e.fileMetadataLabel(t)}})],1)],1),e._v(" "),i("b-col",{attrs:{cols:"0"}},[i("CommonLink",{staticClass:"Form__UploadDelete",on:{click:function(i){return e.deleteFile(t.fileId,t.filename)}}},[i("CommonIcon",{attrs:{weight:"bold",icon:"close"}})],1)],1)],1)})],2)],2)},[],!1,null,null,null);t.default=r.exports},A86J:function(e,t,i){"use strict";t.a={directives:{focus:{inserted:function(e,t){t.value&&e.focus()}}},props:{autoFocus:{type:Boolean,default:!1}}}},IA8J:function(e,t,i){"use strict";i("9ovy"),i("J8hF"),i("K/PF"),i("75LO"),i("W1QL");t.a=function(e){var t={image:{name:"Image",icon:"image-file-landscape"},audio:{name:"Audio",icon:"audio-file"},video:{name:"Video",icon:"video-file-camera"},"application/pdf":{name:"PDF",icon:"office-file-pdf"},"application/msword":{name:"Document",icon:"office-file-doc"},"application/vnd.ms-word":{name:"Document",icon:"office-file-doc"},"application/vnd.oasis.opendocument.text":{name:"Document",icon:"office-file-doc"},"application/vnd.openxmlformats-officedocument.wordprocessingml":{name:"Document",icon:"office-file-doc"},"application/vnd.ms-excel":{name:"Spreadsheet",icon:"office-file-xls"},"application/vnd.openxmlformats-officedocument.spreadsheetml":{name:"Spreadsheet",icon:"office-file-xls"},"application/vnd.oasis.opendocument.spreadsheet":{name:"Spreadsheet",icon:"office-file-xls"},"application/vnd.ms-powerpoint":{name:"Presentation",icon:"office-file-ppt"},"application/vnd.openxmlformats-officedocument.presentationml":{name:"Presentation",icon:"office-file-ppt"},"application/vnd.oasis.opendocument.presentation":{name:"Presentation",icon:"office-file-ppt"},"text/plain":{name:"Text",icon:"common-file-text"},"text/html":{name:"HTML",icon:"file-code"},"application/json":{name:"JSON",icon:"file-code-1"},"text/calendar":{name:"Calendar",icon:"time-clock-file-1"},"application/gzip":{name:"ZIP",icon:"zip-file"},"application/zip":{name:"ZIP",icon:"zip-file"}},i={name:"File",icon:"common-file-empty"};return void 0!==e&&Object.keys(t).forEach(function(a){var o=new RegExp(a);e.match(o)&&(i=t[a])}),i}}}]);