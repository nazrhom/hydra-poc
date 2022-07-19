"use strict";(self.webpackChunkhydra_head_protocol_docs=self.webpackChunkhydra_head_protocol_docs||[]).push([[7808],{3905:function(e,t,n){n.d(t,{Zo:function(){return p},kt:function(){return d}});var r=n(7294);function o(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function a(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var r=Object.getOwnPropertySymbols(e);t&&(r=r.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,r)}return n}function i(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?a(Object(n),!0).forEach((function(t){o(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):a(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function c(e,t){if(null==e)return{};var n,r,o=function(e,t){if(null==e)return{};var n,r,o={},a=Object.keys(e);for(r=0;r<a.length;r++)n=a[r],t.indexOf(n)>=0||(o[n]=e[n]);return o}(e,t);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(e);for(r=0;r<a.length;r++)n=a[r],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(o[n]=e[n])}return o}var l=r.createContext({}),u=function(e){var t=r.useContext(l),n=t;return e&&(n="function"==typeof e?e(t):i(i({},t),e)),n},p=function(e){var t=u(e.components);return r.createElement(l.Provider,{value:t},e.children)},s={inlineCode:"code",wrapper:function(e){var t=e.children;return r.createElement(r.Fragment,{},t)}},m=r.forwardRef((function(e,t){var n=e.components,o=e.mdxType,a=e.originalType,l=e.parentName,p=c(e,["components","mdxType","originalType","parentName"]),m=u(n),d=o,f=m["".concat(l,".").concat(d)]||m[d]||s[d]||a;return n?r.createElement(f,i(i({ref:t},p),{},{components:n})):r.createElement(f,i({ref:t},p))}));function d(e,t){var n=arguments,o=t&&t.mdxType;if("string"==typeof e||o){var a=n.length,i=new Array(a);i[0]=m;var c={};for(var l in t)hasOwnProperty.call(t,l)&&(c[l]=t[l]);c.originalType=e,c.mdxType="string"==typeof e?e:o,i[1]=c;for(var u=2;u<a;u++)i[u]=n[u];return r.createElement.apply(null,i)}return r.createElement.apply(null,n)}m.displayName="MDXCreateElement"},8250:function(e,t,n){n.r(t),n.d(t,{assets:function(){return p},contentTitle:function(){return l},default:function(){return d},frontMatter:function(){return c},metadata:function(){return u},toc:function(){return s}});var r=n(7462),o=n(3366),a=(n(7294),n(3905)),i=["components"],c={slug:3,title:"3. Asynchronous Duplex Client API",authors:[],tags:["Accepted"]},l=void 0,u={permalink:"/head-protocol/ja/adr/3",source:"@site/adr/2021-06-07_003-asynchronous-duplex-api.md",title:"3. Asynchronous Duplex Client API",description:"Status",date:"2021-06-07T00:00:00.000Z",formattedDate:"2021\u5e746\u67087\u65e5",tags:[{label:"Accepted",permalink:"/head-protocol/ja/adr/tags/accepted"}],readingTime:.845,truncated:!1,authors:[],frontMatter:{slug:"3",title:"3. Asynchronous Duplex Client API",authors:[],tags:["Accepted"]},prevItem:{title:"2. Reactive Core\n",permalink:"/head-protocol/ja/adr/2"},nextItem:{title:"4. Use Handle to model Effects\n",permalink:"/head-protocol/ja/adr/4"}},p={authorsImageUrls:[]},s=[{value:"Status",id:"status",level:2},{value:"Context",id:"context",level:2},{value:"Decision",id:"decision",level:2},{value:"Consequences",id:"consequences",level:2}],m={toc:s};function d(e){var t=e.components,n=(0,o.Z)(e,i);return(0,a.kt)("wrapper",(0,r.Z)({},m,n,{components:t,mdxType:"MDXLayout"}),(0,a.kt)("h2",{id:"status"},"Status"),(0,a.kt)("p",null,"Accepted"),(0,a.kt)("h2",{id:"context"},"Context"),(0,a.kt)("p",null,"The ",(0,a.kt)("a",{parentName:"p",href:"/adr/2"},(0,a.kt)("em",{parentName:"a"},"reactive")," nature of the Hydra node")," means that\nclients produce a ",(0,a.kt)("em",{parentName:"p"},"stream")," of ",(0,a.kt)("em",{parentName:"p"},"inputs")," to a node which in turns issues a stream\nof ",(0,a.kt)("em",{parentName:"p"},"outputs")," representing the outcome of previous inputs or resulting from\ninteraction with peers in the network."),(0,a.kt)("p",null,"For example, a client may send a ",(0,a.kt)("em",{parentName:"p"},"command")," as ",(0,a.kt)("em",{parentName:"p"},"input"),", upon which the node might\ndo something. When that something is finished, a ",(0,a.kt)("em",{parentName:"p"},"output")," does indicate that.\nHowever, there might also be an ",(0,a.kt)("em",{parentName:"p"},"output"),' emitted to the client when another peer\ninteracted with "our" node.'),(0,a.kt)("p",null,"Queries, messages by clients which do only fetch information from the node, are\nnot in scope of this ADR."),(0,a.kt)("h2",{id:"decision"},"Decision"),(0,a.kt)("ul",null,(0,a.kt)("li",{parentName:"ul"},"We use a single, full-duplex communication channel per client connected to a Hydra node"),(0,a.kt)("li",{parentName:"ul"},"This is implemented using a simple ",(0,a.kt)("a",{parentName:"li",href:"https://datatracker.ietf.org/doc/html/rfc6455"},"Websocket")," with messages corresponding to ",(0,a.kt)("inlineCode",{parentName:"li"},"Input"),"s and ",(0,a.kt)("inlineCode",{parentName:"li"},"Output"),"s.")),(0,a.kt)("h2",{id:"consequences"},"Consequences"),(0,a.kt)("ul",null,(0,a.kt)("li",{parentName:"ul"},"Clients needing a synchronous API need to implement it on top"),(0,a.kt)("li",{parentName:"ul"},"Clients can receive ",(0,a.kt)("em",{parentName:"li"},"outputs")," decorrelated from any ",(0,a.kt)("em",{parentName:"li"},"inputs")," and at any time")))}d.isMDXComponent=!0}}]);