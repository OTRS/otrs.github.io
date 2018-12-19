(window.webpackJsonp=window.webpackJsonp||[]).push([[95],{Iptl:function(t,e,s){"use strict";s("GkPX");var n=s("nS/B");e.a={components:{CommonNotice:function(){return s.e(112).then(s.bind(null,"mkLc"))},DocsExample:function(){return s.e(10).then(s.bind(null,"GD02"))},DocsComponentAPI:function(){return s.e(11).then(s.bind(null,"8txu"))}},computed:{doc:function(){var t=this.componentNamespace||"Components";return this.$store.getters.componentDoc[t][this.$options.name]||[]},summary:function(){return Object(n.b)(this.doc,"summary")},version:function(){return Object(n.b)(this.doc,"version")},description:function(){return Object(n.b)(this.doc,"description")},props:function(){return Object(n.a)(this.doc,"prop")},slots:function(){return Object(n.a)(this.doc,"slot")},events:function(){return Object(n.a)(this.doc,"event")},methods:function(){return Object(n.a)(this.doc,"method")}}}},L3aK:function(t,e,s){},Pgq9:function(t,e,s){"use strict";s.r(e);var n=s("Iptl"),i=(s("K/PF"),s("75LO"),s("W1QL"),{name:"DataTable",props:{items:{type:Array,default:null},columns:{type:Object,required:!0},emptyText:{type:String,default:"There are no records."},emptyIcon:{type:String,default:"check"},hideHeader:{type:Boolean,default:!1},size:{type:String}},computed:{containerClass:function(){return{"ItemList--Small":"sm"===this.size,"ItemList--Empty":!this.items||0===this.items.length}},filteredColumns:function(){var t=this,e={};return Object.keys(this.columns).forEach(function(s){t.columns[s].isHidden||(e[s]=t.columns[s])}),e}},methods:{columnTitle:function(t){return this.columns[t]&&void 0!==this.columns[t].text?this.columns[t].text:t},sort:function(t,e){if(this.columns[e].isSortable){var s=!0;this.columns[e].isSorted&&this.columns[e].isAscending&&(s=!1),this.$emit("sort",e,s)}},click:function(t,e){var s,n=this;if(Object.keys(this.columns).forEach(function(t){void 0===s&&n.columns[t].isRowKey&&(s=e[t])}),void 0===s){var i=Object.keys(this.columns)[0];s=e[i]}this.$emit("select",s)}}}),o=(s("kTqJ"),s("psIG")),a=Object(o.a)(i,function(){var t=this,e=t.$createElement,s=t._self._c||e;return s("div",{staticClass:"col-md-12 table-responsive ItemList__Table",class:t.containerClass},[t.items&&t.items.length>0?s("table",{staticClass:"table table-hover"},[t.hideHeader?t._e():s("thead",[s("tr",t._l(t.filteredColumns,function(e,n){return s("th",{key:n,class:{sorting:e.isSortable},on:{click:function(e){t.sort(e,n)}}},[t._v("\n                    "+t._s(t._f("translate")(t.columnTitle(n)))+"\n                    "),e.isSortable?s("i",{class:{"fas fa-sort":!e.isSorted,"fas fa-sort-down":e.isSorted&&e.isAscending,"fas fa-sort-up":e.isSorted&&!e.isAscending}}):t._e()])}))]),t._v(" "),s("tbody",t._l(t.items,function(e,n){return s("tr",{key:n,class:e.rowClass,on:{click:function(s){t.click(s,e)}}},t._l(t.filteredColumns,function(n,i){return s("td",{key:i,class:n.class},[t._t(i,[t._v("\n                        "+t._s(e[i])+"\n                    ")],{value:e[i]})],2)}))}))]):t._e(),t._v(" "),t.items&&0==t.items.length?s("div",{staticClass:"ItemList__EmptyText"},[s("CommonIcon",{staticClass:"ItemList__EmptyIcon",attrs:{icon:t.emptyIcon}}),t._v(" "),s("p",[t._v(t._s(t._f("translate")(t.emptyText)))])],1):t._e()])},[],!1,null,null,null);a.options.__file="index.vue";var c=a.exports,r={name:"DataTable",mixins:[n.a],data:function(){return{docVersion:"1.0.1",componentNamespace:"Components",componentPath:"Components/Data/DataTable",value:void 0,component:c,example:{items:{default:[{id:1,active:!1,title:"Something went wrong",state:"new",customerUser:"John Doe",created:"2018-01-01 12:00:00"},{id:2,active:!0,title:"Update failed",state:"closed",customerUser:"Johan Strauss",created:"2018-03-01 14:00:00"},{id:3,active:!1,title:"Hardware failure",state:"open",customerUser:"Jane Doe",created:"2018-05-01 11:00:00"}],type:"array"},columns:{default:{id:{text:"TicketID",isSortable:!0,isSorted:!1,isAscending:!0,isHidden:!0,isRowKey:!0,class:"ItemList__ID"},active:{text:"Active",isSortable:!0,isSorted:!1,isAscending:!1,isHidden:!1,isRowKey:!1,class:"ItemList__Active"},title:{text:"Title",isSortable:!0,isSorted:!1,isAscending:!1,isHidden:!1,isRowKey:!1,class:"ItemList__Title"},state:{text:"Status",isSortable:!0,isSorted:!1,isAscending:!1,isHidden:!1,isRowKey:!1,class:"ItemList__Status"},customerUser:{text:"Customer",isSortable:!0,isSorted:!1,isAscending:!1,isHidden:!1,isRowKey:!1,class:"ItemList__Customer"},created:{text:"Created",isSortable:!0,isSorted:!0,isAscending:!0,isHidden:!1,isRowKey:!1,class:"ItemList__Created"}},type:"object"},hideHeader:{type:"checkbox",default:!1},size:{type:"select",options:[{value:void 0,text:"-"},{value:"sm",text:"Small"}]}}}}},l=Object(o.a)(r,function(){var t=this,e=t.$createElement,s=t._self._c||e;return s("div",{staticClass:"main"},[s("h1",{staticClass:"design-system"},[t._v("\n            "+t._s(t.summary)+"\n            "),s("b-badge",{attrs:{variant:t.docVersion!==t.version?"warning":"info"}},[t._v(t._s(t.version))])],1),t._v(" "),s("p",[t._v("\n            "+t._s(t.description)+"\n        ")]),t._v(" "),t.docVersion!==t.version?[s("CommonNotice",{attrs:{text:"Please verify all changes to the component API have been properly documented\n                    ("+t.docVersion+" !== "+t.version+").",title:"Documentation for this component is out of date!",type:"Warning"}})]:t._e(),t._v(" "),s("h2",{staticClass:"design-system"},[t._v("\n            Table content\n        ")]),t._v(" "),s("h3",{staticClass:"design-system"},[t._v("\n            Columns\n        ")]),t._v(" "),t._m(0),t._v(" "),s("pre",{staticClass:"design-system"},[t._v("let columns = {\n    // Column key (identifier).\n    ticketNumber: {\n        // Column text (displayed in the table header).\n        text: 'Ticket number',\n        // Is this column sortable?\n        isSortable: true,\n        // Is table already sorted by this column?\n        isSorted: false,\n        // Is it sorted in ascending order?\n        isAscending: true,\n        // Should the column be hidden?\n        isHidden: true,\n        // If set, value of this column is sent on row click.\n        isRowKey: true,\n        // Column CSS class.\n        class: 'ItemList__ID',\n    },\n    ...\n};")]),t._v(" "),s("h3",{staticClass:"design-system"},[t._v("\n            Rows\n        ")]),t._v(" "),t._m(1),t._v(" "),s("pre",{staticClass:"design-system"},[t._v("let items = [\n    {\n        id: 1,\n        active: false,\n        title: 'Something went wrong',\n        rowClass: 'rowClass',\n    },\n    ...\n];")]),t._v(" "),s("b-tabs",{staticClass:"tab-content"},[s("b-tab",{staticClass:"tab-pane",attrs:{title:"Demo","title-link-class":"design-system",active:""}},[s("DocsExample",{attrs:{component:t.component,"component-path":t.componentPath,props:t.props,events:t.events,slots:t.slots,example:t.example}})],1),t._v(" "),s("b-tab",{staticClass:"tab-pane",attrs:{title:"API Documentation","title-link-class":"design-system"}},[s("DocsComponentAPI",{attrs:{props:t.props,events:t.events,slots:t.slots,methods:t.methods}})],1)],1)],2)},[function(){var t=this.$createElement,e=this._self._c||t;return e("p",[this._v("\n            Prop "),e("code",[this._v("columns")]),this._v(" contains data for the table columns and their headers. Note that the keys will\n            have to be used verbatim in the "),e("code",[this._v("items")]),this._v(" in order to reference specific column.\n        ")])},function(){var t=this.$createElement,e=this._self._c||t;return e("p",[this._v("\n            Prop "),e("code",[this._v("items")]),this._v(" contains data which will be displayed by the data table. Each array element\n            represents a row in the table, as an object which key/value pairs represent cell data. Object keys must\n            match column keys (which are in turn defined in "),e("code",[this._v("columns")]),this._v(" prop).\n        ")])}],!1,null,null,null);l.options.__file="DataTable.vue";e.default=l.exports},kTqJ:function(t,e,s){"use strict";var n=s("L3aK");s.n(n).a}}]);