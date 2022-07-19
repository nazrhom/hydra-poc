"use strict";(self.webpackChunkhydra_head_protocol_docs=self.webpackChunkhydra_head_protocol_docs||[]).push([[5380],{3905:function(e,t,n){n.d(t,{Zo:function(){return u},kt:function(){return m}});var r=n(7294);function a(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function o(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var r=Object.getOwnPropertySymbols(e);t&&(r=r.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,r)}return n}function i(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?o(Object(n),!0).forEach((function(t){a(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):o(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function l(e,t){if(null==e)return{};var n,r,a=function(e,t){if(null==e)return{};var n,r,a={},o=Object.keys(e);for(r=0;r<o.length;r++)n=o[r],t.indexOf(n)>=0||(a[n]=e[n]);return a}(e,t);if(Object.getOwnPropertySymbols){var o=Object.getOwnPropertySymbols(e);for(r=0;r<o.length;r++)n=o[r],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(a[n]=e[n])}return a}var s=r.createContext({}),p=function(e){var t=r.useContext(s),n=t;return e&&(n="function"==typeof e?e(t):i(i({},t),e)),n},u=function(e){var t=p(e.components);return r.createElement(s.Provider,{value:t},e.children)},c={inlineCode:"code",wrapper:function(e){var t=e.children;return r.createElement(r.Fragment,{},t)}},d=r.forwardRef((function(e,t){var n=e.components,a=e.mdxType,o=e.originalType,s=e.parentName,u=l(e,["components","mdxType","originalType","parentName"]),d=p(n),m=a,f=d["".concat(s,".").concat(m)]||d[m]||c[m]||o;return n?r.createElement(f,i(i({ref:t},u),{},{components:n})):r.createElement(f,i({ref:t},u))}));function m(e,t){var n=arguments,a=t&&t.mdxType;if("string"==typeof e||a){var o=n.length,i=new Array(o);i[0]=d;var l={};for(var s in t)hasOwnProperty.call(t,s)&&(l[s]=t[s]);l.originalType=e,l.mdxType="string"==typeof e?e:a,i[1]=l;for(var p=2;p<o;p++)i[p]=n[p];return r.createElement.apply(null,i)}return r.createElement.apply(null,n)}d.displayName="MDXCreateElement"},9749:function(e,t,n){n.r(t),n.d(t,{assets:function(){return u},contentTitle:function(){return s},default:function(){return m},frontMatter:function(){return l},metadata:function(){return p},toc:function(){return c}});var r=n(7462),a=n(3366),o=(n(7294),n(3905)),i=["components"],l={slug:8,title:"8. Custom Prelude\n",authors:[],tags:["Accepted"]},s=void 0,p={permalink:"/head-protocol/adr/8",source:"@site/adr/2021-06-18_008-use-custom-prelude.md",title:"8. Custom Prelude\n",description:"Status",date:"2021-06-18T00:00:00.000Z",formattedDate:"June 18, 2021",tags:[{label:"Accepted",permalink:"/head-protocol/adr/tags/accepted"}],readingTime:1.68,truncated:!1,authors:[],frontMatter:{slug:"8",title:"8. Custom Prelude\n",authors:[],tags:["Accepted"]},prevItem:{title:"7. Use with-pattern based component interfaces\n",permalink:"/head-protocol/adr/7"},nextItem:{title:"9. Simplify Logging\n",permalink:"/head-protocol/adr/9"}},u={authorsImageUrls:[]},c=[{value:"Status",id:"status",level:2},{value:"Context",id:"context",level:2},{value:"Decision",id:"decision",level:2},{value:"Consequences",id:"consequences",level:2}],d={toc:c};function m(e){var t=e.components,n=(0,a.Z)(e,i);return(0,o.kt)("wrapper",(0,r.Z)({},d,n,{components:t,mdxType:"MDXLayout"}),(0,o.kt)("h2",{id:"status"},"Status"),(0,o.kt)("p",null,"Accepted"),(0,o.kt)("h2",{id:"context"},"Context"),(0,o.kt)("p",null,"In a Haskell project, we often get to use and re-use the same libraries and functions. Haskell comes with a default ",(0,o.kt)("inlineCode",{parentName:"p"},"Prelude")," package with the ",(0,o.kt)("inlineCode",{parentName:"p"},"base")," library, which provides a good and sensible starting point. However, the base ",(0,o.kt)("inlineCode",{parentName:"p"},"Prelude")," also comes with a few quirks:"),(0,o.kt)("ul",null,(0,o.kt)("li",{parentName:"ul"},"Many commonly used functions or constructors are not exported by default (e.g. ",(0,o.kt)("inlineCode",{parentName:"li"},"bracket"),", ",(0,o.kt)("inlineCode",{parentName:"li"},"foldM"),", ",(0,o.kt)("inlineCode",{parentName:"li"},"first"),", ",(0,o.kt)("inlineCode",{parentName:"li"},"lift"),", ",(0,o.kt)("inlineCode",{parentName:"li"},"forM"),", ",(0,o.kt)("inlineCode",{parentName:"li"},"when"),", ",(0,o.kt)("inlineCode",{parentName:"li"},"SomeException"),", ",(0,o.kt)("inlineCode",{parentName:"li"},"Set"),", ",(0,o.kt)("inlineCode",{parentName:"li"},"&")," ...etc)."),(0,o.kt)("li",{parentName:"ul"},"Many functions in the base Prelude are partial, like ",(0,o.kt)("inlineCode",{parentName:"li"},"head")," or ",(0,o.kt)("inlineCode",{parentName:"li"},"read"),". "),(0,o.kt)("li",{parentName:"ul"},"Many functions simply happens in plain ",(0,o.kt)("inlineCode",{parentName:"li"},"IO"),", whereas applications usually try to push IO to the boundary as much as possible (for example, using mtl-style class constraints)."),(0,o.kt)("li",{parentName:"ul"},"The interface for I/O operations in the base Prelude is ",(0,o.kt)("inlineCode",{parentName:"li"},"String"),", which comes with quite major performance hit and often forces to convert back and forth to ",(0,o.kt)("inlineCode",{parentName:"li"},"Text")," or ",(0,o.kt)("inlineCode",{parentName:"li"},"ByteString")," equivalents.")),(0,o.kt)("p",null,"All-in-all, while it ",(0,o.kt)("em",{parentName:"p"},"does the job"),", the base ",(0,o.kt)("inlineCode",{parentName:"p"},"Prelude")," may not necessarily be the most ",(0,o.kt)("em",{parentName:"p"},"convenient")," prelude for an active project development. "),(0,o.kt)("h2",{id:"decision"},"Decision"),(0,o.kt)("p",null,"We'll use a custom prelude to help us get more productive and more importantly, to reduce the daily friction of our interactions with the base prelude. While ",(0,o.kt)("a",{parentName:"p",href:"https://hackage.haskell.org/package/relude"},(0,o.kt)("inlineCode",{parentName:"a"},"relude"))," makes for a good candidate, we still chose to re-wrap it in a custom ",(0,o.kt)("inlineCode",{parentName:"p"},"Hydra.Prelude")," module to grant us the ability to add or remove a few things specifics to Hydra and Cardano in general. In particular, we will hide from ",(0,o.kt)("inlineCode",{parentName:"p"},"relude")," all the re-exports of the ",(0,o.kt)("a",{parentName:"p",href:"https://hackage.haskell.org/package/stm"},(0,o.kt)("inlineCode",{parentName:"a"},"stm"))," library in favor of ",(0,o.kt)("a",{parentName:"p",href:"https://github.com/input-output-hk/ouroboros-network/tree/e338f2cf8e1078fbda9555dd2b169c6737ef6774/io-classes"},(0,o.kt)("inlineCode",{parentName:"a"},"io-classes"))," which we already use pervasively and which provides (among other things) most of the same capabilities."),(0,o.kt)("h2",{id:"consequences"},"Consequences"),(0,o.kt)("ul",null,(0,o.kt)("li",{parentName:"ul"},"Remove uses of 'cardano-prelude' in favor of a new 'hydra-prelude' module."),(0,o.kt)("li",{parentName:"ul"},"Cleaning up of imports from existing file modules."),(0,o.kt)("li",{parentName:"ul"},"Happier feeling day after day from using a developer-friendly prelude."),(0,o.kt)("li",{parentName:"ul"},"Stop loosing time in often re-importing the same functions over and over. "),(0,o.kt)("li",{parentName:"ul"},"Have an explicit point for discouraging / blessing usage of one or the other function, as well as documenting such decisions")))}m.isMDXComponent=!0}}]);