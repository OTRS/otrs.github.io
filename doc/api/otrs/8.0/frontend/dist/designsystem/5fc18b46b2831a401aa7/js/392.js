(window.webpackJsonp=window.webpackJsonp||[]).push([[392],{jsZX:function(t,n,i){"use strict";i.r(n);i("asZ9"),i("oMRA"),i("6d4m"),i("W1QL"),i("K/PF"),i("t91x"),i("75LO"),i("e2Kn");var o={name:"BusinessObjectActions",components:{CommonActionMenu:function(){return i.e(417).then(i.bind(null,"nDnJ"))}},props:{businessObjectType:{type:String,required:!0},actions:{type:Object},itemId:{type:[String,Number]},additionalActionParams:{type:Object},actionMenuIsNarrow:{type:Boolean},actionMenuIsInline:{type:Boolean},actionMenuPlacement:{type:String},context:{type:Object},triggerAction:{type:String}},data:function(){return{selectedAction:null,payload:{}}},computed:{actionRef:function(){return"".concat(this.businessObjectType,"Action")},lookupActions:function(){var t=this,n={};return Object.keys(this.actions).forEach(function(i){t.actions[i].forEach(function(t){var i=t.Component||t.component;n[i]=t})}),n},quickActions:function(){var t=this,n=[];return Object.keys(this.actions).forEach(function(i){t.actions[i].forEach(function(t){t.ShowIcon&&t.Icon&&n.push({icon:t.Icon,component:t.Component,name:t.Name})})}),n},listenToActions:function(){return[this.businessObjectType]}},created:function(){this.listenToActions.length&&this.$bus.$on("runAction",this.runActionCallback),this.handleTriggerAction()},beforeDestroy:function(){this.listenToActions.length&&this.$bus.$off("runAction",this.runActionCallback)},methods:{onActionClick:function(t){this.runAction(t.Component||t.component)},onClose:function(t,n){t&&this.$emit("updated",this.selectedAction,n),this.selectedAction=null,this.payload={}},runAction:function(t){var n=this;this.selectedAction&&this.selectedAction===t&&this.$refs[this.actionRef]&&"function"==typeof this.$refs[this.actionRef].run?this.$refs[this.actionRef].run():this.selectedAction&&"function"==typeof this.$refs[this.actionRef].close?this.$refs[this.actionRef].close().then(function(){n.selectedAction=t}).catch(function(){}):this.selectedAction=t},runActionCallback:function(t,n,i){this.listenToActions.includes(t)&&(this.payload=i,this.runAction(n))},handleTriggerAction:function(){if(this.triggerAction){var t=this.triggerAction.split("::")||[];if(t){var n=t[0],i=t[1];this.listenToActions.includes(n)&&this.lookupActions[i]&&this.runAction(i)}}}}},e=i("psIG"),c=Object(e.a)(o,function(){var t=this,n=t.$createElement,i=t._self._c||n;return t.actions&&Object.keys(t.actions).length>0?i("div",[t._l(t.quickActions,function(n){return i("CommonLink",{directives:[{name:"b-tooltip",rawName:"v-b-tooltip.hover",modifiers:{hover:!0}}],key:n.key,staticClass:"ml-2",attrs:{title:t._f("translate")(n.name)},on:{click:function(i){return i.stopPropagation(),t.onActionClick(n)}}},[i("CommonIcon",{attrs:{icon:n.icon}})],1)}),t._v(" "),i("CommonActionMenu",{attrs:{actions:t.actions,"is-narrow":t.actionMenuIsNarrow,"is-inline":t.actionMenuIsInline,placement:t.actionMenuPlacement},on:{"action-click":t.onActionClick},scopedSlots:t._u([{key:"label",fn:function(n){return[t._t("action-menu-label",null,null,n)]}}],null,!0)}),t._v(" "),t.selectedAction?i(t.selectedAction,{ref:t.actionRef,tag:"component",attrs:{"item-id":t.itemId,"action-config":t.lookupActions[t.selectedAction],"additional-action-params":t.additionalActionParams,payload:t.payload,context:t.context},on:{close:t.onClose}}):t._e()],2):t._e()},[],!1,null,null,null);n.default=c.exports}}]);