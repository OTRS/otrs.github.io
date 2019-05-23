(window.webpackJsonp=window.webpackJsonp||[]).push([[158,164],{"9xT8":function(t,e,a){"use strict";a.r(e);a("Z8gF"),a("9ovy");var n=a("T0ip"),r=a("+a/P"),o=a.n(r),s={name:"AuthenticatorApp",components:{FormButton:function(){return a.e(0).then(a.bind(null,"dphA"))},FormInput:function(){return a.e(17).then(a.bind(null,"CJfq"))}},extends:n.default,data:function(){return{helpMessage:!1,disabledButton:!0,initialSetup:!0,qrCodeDataUrl:void 0}},computed:{readableSharedSecret:function(){return this.sharedSecret.toLowerCase().match(/.{1,4}/g).join(" ")}},mounted:function(){var t=this,e=encodeURIComponent(this.config.ProductName.replace(/:/g,"")),a=encodeURIComponent(this.userInfo.UserLogin.replace(/:/g,"")),n="otpauth://totp/".concat(e,":").concat(a,"?secret=").concat(this.sharedSecret,"&issuer=").concat(e);o.a.toDataURL(n).then(function(e){t.qrCodeDataUrl=e,t.disabledButton=!1}).catch(function(e){t.$log.error(e)}),this.$nextTick(function(){t.$test.setFlag("AuthenticatorApp::Mounted")})},methods:{showHelpScreen:function(){var t=this;this.initialSetup=!1,this.$nextTick(function(){t.$test.setFlag("AuthenticatorApp::ShowHelpScreen")})},toggleHelpMessage:function(){this.helpMessage=!this.helpMessage}}},c=a("psIG"),l=Object(c.a)(s,function(){var t=this,e=t.$createElement,a=t._self._c||e;return a("b-row",[a("b-col",[a("b-row",[a("b-col",{staticClass:"mt-4 mb-3 text-center"},[a("h3",[t._v(t._s(t._f("translate")("Two-factor Setup")))])])],1),t._v(" "),t.initialSetup?[a("b-row",[a("b-col",{staticClass:"text-center"},[a("p",[t._v("\n                        "+t._s(t._f("translate")("Please open your preferred authenticator app and scan the QR code below."))+"\n                    ")])])],1),t._v(" "),a("b-row",{staticClass:"TwoFASetup"},[a("b-col",[a("b-row",[a("b-col",[a("FormButton",{attrs:{text:t._f("translate")("How do I get the app?"),variant:"primary",block:""},on:{click:function(e){return t.toggleHelpMessage()}}})],1)],1),t._v(" "),a("b-row",{directives:[{name:"show",rawName:"v-show",value:t.helpMessage,expression:"helpMessage"}]},[a("b-col",[a("ol",[a("li",[t._v(t._s(t._f("translate")("Go to your app store.")))]),t._v(" "),a("li",[t._v(t._s(t._f("translate")('Search for an "Authenticator" app.')))]),t._v(" "),a("li",[t._v(t._s(t._f("translate")("Install and follow the instructions on the screen.")))]),t._v(" "),a("li",[t._v(t._s(t._f("translate")("Scan the code below.")))])])])],1),t._v(" "),a("b-row",{staticClass:"text-center"},[a("b-col",[a("img",{attrs:{src:t.qrCodeDataUrl,alt:t._f("translate")("QR code")}})])],1),t._v(" "),a("b-row",{staticClass:"text-center"},[a("b-col",[a("CommonLink",{on:{click:function(e){return t.showHelpScreen()}}},[t._v("\n                                "+t._s(t._f("translate")("Can't scan it?"))+"\n                            ")])],1)],1),t._v(" "),a("b-row",[a("b-col",{staticClass:"my-3",attrs:{cols:"6"}},[a("FormButton",{attrs:{text:t._f("translate")("Cancel"),variant:"secondary",block:""},on:{click:function(e){return t.cancel()}}})],1),t._v(" "),a("b-col",{staticClass:"my-3",attrs:{cols:"6"}},[a("FormButton",{attrs:{text:t._f("translate")("Next"),disabled:t.disabledButton,variant:"primary",block:"","auto-focus":""},on:{click:function(e){return t.provideSetupData()}}})],1)],1)],1)],1)]:[a("b-row",{staticClass:"TwoFASetup"},[a("b-col",[a("b-row",[a("b-col",[a("ol",[a("li",[t._v(t._s(t._f("translate")("Open the app and setup an account.")))]),t._v(" "),a("li",[t._v(t._s(t._f("translate")("Choose to manually enter a provided key.")))]),t._v(" "),a("li",[t._v("\n                                    "+t._s(t._f("translate")("Enter your email address and this secret key:"))+"\n                                    "),a("FormInput",{attrs:{"field-classes":{TwoFASetup__AuthenticatorCode:!0},readonly:""},model:{value:t.readableSharedSecret,callback:function(e){t.readableSharedSecret=e},expression:"readableSharedSecret"}})],1),t._v(" "),a("li",[t._v("\n                                    "+t._s(t._f("translate")("Make sure that time-based algorithm is turned on, and save it."))+"\n                                ")])])])],1),t._v(" "),a("b-row",[a("b-col",{staticClass:"my-3",attrs:{cols:"6"}},[a("FormButton",{attrs:{text:t._f("translate")("Cancel"),variant:"primary",block:""},on:{click:function(e){return t.cancel()}}})],1),t._v(" "),a("b-col",{staticClass:"my-3",attrs:{cols:"6"}},[a("FormButton",{attrs:{text:t._f("translate")("Next"),disabled:!t.sharedSecret,variant:"primary",block:""},on:{click:function(e){return t.provideSetupData()}}})],1)],1)],1)],1)]],2)],1)},[],!1,null,null,null);e.default=l.exports},T0ip:function(t,e,a){"use strict";a.r(e);var n=a("gki9"),r=a.n(n),o=a("lOrp"),s={name:"Base",props:{userType:{type:String,required:!0,validator:function(t){return-1!==["agent","customer"].indexOf(t)}},method:{type:Object}},data:function(){return{sharedSecret:null,emailSecurity:null}},computed:r()({},Object(o.b)(["userInfo","config"])),mounted:function(){this.sharedSecret=this.generateSecret()},methods:{cancel:function(){this.$emit("cancel")},provideSetupData:function(){this.$emit("setup-data-provided",{sharedSecret:this.sharedSecret})},generateSecret:function(){for(var t=["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","2","3","4","5","6","7"],e="",a=0;a<t.length;a++){var n=Math.floor(Math.random()*t.length),r=t[a];t[a]=t[n],t[n]=r}for(var o=0;o<16;o++)e+=t[o];return e}}},c=a("psIG"),l=Object(c.a)(s,void 0,void 0,!1,null,null,null);e.default=l.exports}}]);