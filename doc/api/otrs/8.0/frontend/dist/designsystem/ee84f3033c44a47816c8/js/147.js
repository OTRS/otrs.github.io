(window.webpackJsonp=window.webpackJsonp||[]).push([[147],{T0ip:function(e,t,n){"use strict";n.r(t);var r=n("gki9"),a=n.n(r),i=n("lOrp"),o={name:"Base",props:{userType:{type:String,required:!0,validator:function(e){return-1!==["agent","customer"].indexOf(e)}},method:{type:Object}},data:function(){return{sharedSecret:null,emailSecurity:null}},computed:a()({},Object(i.b)(["userInfo","config"])),mounted:function(){this.sharedSecret=this.generateSecret()},methods:{cancel:function(){this.$emit("cancel")},provideSetupData:function(){this.$emit("setup-data-provided",{sharedSecret:this.sharedSecret})},generateSecret:function(){for(var e=["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","2","3","4","5","6","7"],t="",n=0;n<e.length;n++){var r=Math.floor(Math.random()*e.length),a=e[n];e[n]=e[r],e[r]=a}for(var i=0;i<16;i++)t+=e[i];return t}}},u=n("psIG"),c=Object(u.a)(o,void 0,void 0,!1,null,null,null);c.options.__file="Base.vue";t.default=c.exports}}]);