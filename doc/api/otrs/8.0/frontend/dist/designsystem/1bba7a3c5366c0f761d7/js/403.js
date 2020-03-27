(window.webpackJsonp=window.webpackJsonp||[]).push([[403],{jsZX:function(t,n,e){"use strict";e.r(n);e("2Tod"),e("ABKx");var i=e("OvAC"),o=e.n(i);e("asZ9"),e("oMRA"),e("6d4m"),e("W1QL"),e("K/PF"),e("t91x"),e("75LO"),e("e2Kn");function c(t,n){var e=Object.keys(t);if(Object.getOwnPropertySymbols){var i=Object.getOwnPropertySymbols(t);n&&(i=i.filter(function(n){return Object.getOwnPropertyDescriptor(t,n).enumerable})),e.push.apply(e,i)}return e}var s={name:"BusinessObjectActions",components:{CommonActionMenu:function(){return e.e(428).then(e.bind(null,"nDnJ"))}},mixins:[{data:function(){return{skipDirectUpdateWidgetData:!1}},methods:{triggerDirectUpdateData:function(t){var n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:{};n.skipDirectUpdateWidgetData&&(this.skipDirectUpdateWidgetData=!0),n.refetchItemData&&this.$bus.$emit("screenItemDataUpdate",t,n.data),n.widgetDataUpdate&&this.$bus.$emit("widgetDataUpdate",t,n.data)},skipPushEventFetchScreenData:function(t,n,e){this.$bus.$emit("skipPushEventFetchScreenData",t,n,e)}}}],props:{redirectMode:{type:Boolean},redirectComponent:{type:String},showQuickActionsOnly:{type:Boolean},businessObjectType:{type:String,required:!0},actions:{type:Object},itemId:{type:[String,Number]},additionalActionParams:{type:Object},actionMenuIsNarrow:{type:Boolean},actionMenuIsInline:{type:Boolean},actionMenuPlacement:{type:String},context:{type:Object},triggerAction:{type:String},triggerActionParams:{type:Object,default:function(){}}},data:function(){return{selectedAction:null,selectedActionConfig:null,payload:{}}},computed:{actionRef:function(){return"".concat(this.businessObjectType,"Action")},lookupActions:function(){var t=this,n={};return Object.keys(this.actions).forEach(function(e){t.actions[e].forEach(function(t){var e=t.Component||t.component;n[e]=t})}),n},quickActions:function(){var t=this,n=[];return Object.keys(this.visibleActions).forEach(function(e){t.visibleActions[e].forEach(function(t){t.ShowIcon&&t.Icon&&n.push({icon:t.Icon,component:t.Component,name:t.Name})})}),n},visibleActions:function(){var t=this,n={};return Object.keys(this.actions).forEach(function(e){"Hidden"!==e&&(n[e]=t.actions[e])}),n},listenToActions:function(){return[this.businessObjectType]}},watch:{triggerAction:function(){this.handleTriggerAction()}},created:function(){this.listenToActions.length&&this.$bus.$on("runAction",this.runActionCallback),this.handleTriggerAction()},beforeDestroy:function(){this.listenToActions.length&&this.$bus.$off("runAction",this.runActionCallback)},methods:{onActionClick:function(t){this.runAction(t.Component||t.component,t)},onClose:function(t,n){var e=this;t&&this.triggerDirectUpdateData(this.selectedAction,n),this.selectedAction=null,this.payload={},this.$nextTick(function(){e.$test.setFlag("BusinessObjectAction::Closed")})},runAction:function(t,n){var e=this;if(this.redirectMode&&this.redirectComponent){var i={itemId:this.itemId};return this.context&&(i.listNavigationContext=this.context),void this.$router.push({name:this.redirectComponent,params:i,query:{TriggerAction:"".concat(this.businessObjectType,"::").concat(t),TriggerActionParams:JSON.stringify({articleId:this.additionalActionParams.articleId})}})}this.selectedAction&&this.selectedAction===t&&this.$refs[this.actionRef]&&"function"==typeof this.$refs[this.actionRef].run?(this.selectedActionConfig=n,this.$refs[this.actionRef].run()):this.selectedAction&&"function"==typeof this.$refs[this.actionRef].close?this.$refs[this.actionRef].close().then(function(){e.selectedActionConfig=n,e.selectedAction=t}).catch(function(){}):(this.selectedActionConfig=n,this.selectedAction=t)},runActionCallback:function(t,n,e){this.listenToActions.includes(t)&&(this.payload=e,this.runAction(n,null))},handleTriggerAction:function(){if(this.triggerAction){var t=this.triggerAction.split("::")||[];if(t){var n=t[0],e=t[1];this.listenToActions.includes(n)&&(this.payload=function(t){for(var n=1;n<arguments.length;n++){var e=null!=arguments[n]?arguments[n]:{};n%2?c(Object(e),!0).forEach(function(n){o()(t,n,e[n])}):Object.getOwnPropertyDescriptors?Object.defineProperties(t,Object.getOwnPropertyDescriptors(e)):c(Object(e)).forEach(function(n){Object.defineProperty(t,n,Object.getOwnPropertyDescriptor(e,n))})}return t}({},this.triggerActionParams,{isTriggerAction:!0}),this.runAction(e,null))}}}}},r=e("psIG"),a=Object(r.a)(s,function(){var t=this,n=t.$createElement,e=t._self._c||n;return t.actions&&Object.keys(t.actions).length>0?e("div",[t._l(t.quickActions,function(n){return e("CommonLink",{directives:[{name:"b-tooltip",rawName:"v-b-tooltip.hover",modifiers:{hover:!0}}],key:n.key,staticClass:"ml-2",attrs:{title:t._f("translate")(n.name)},on:{click:function(e){return e.stopPropagation(),t.onActionClick(n)}}},[e("CommonIcon",{attrs:{icon:n.icon}})],1)}),t._v(" "),t.showQuickActionsOnly?t._e():e("CommonActionMenu",{attrs:{actions:t.visibleActions,"is-narrow":t.actionMenuIsNarrow,"is-inline":t.actionMenuIsInline,placement:t.actionMenuPlacement},on:{"action-click":t.onActionClick},scopedSlots:t._u([{key:"label",fn:function(n){return[t._t("action-menu-label",null,null,n)]}}],null,!0)}),t._v(" "),t.selectedAction?e(t.selectedAction,{ref:t.actionRef,tag:"component",attrs:{"item-id":t.itemId,"action-config":t.selectedActionConfig||t.lookupActions[t.selectedAction],"additional-action-params":t.additionalActionParams,payload:t.payload,context:t.context},on:{close:t.onClose}}):t._e()],2):t._e()},[],!1,null,null,null);n.default=a.exports}}]);