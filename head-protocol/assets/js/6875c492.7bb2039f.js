"use strict";(self.webpackChunkhydra_head_protocol_docs=self.webpackChunkhydra_head_protocol_docs||[]).push([[8610],{6299:function(e,t,a){a.d(t,{Z:function(){return s}});var n=a(7294),r=a(5999),l=a(1750);function s(e){var t=e.metadata,a=t.previousPage,s=t.nextPage;return n.createElement("nav",{className:"pagination-nav","aria-label":(0,r.I)({id:"theme.blog.paginator.navAriaLabel",message:"Blog list page navigation",description:"The ARIA label for the blog pagination"})},n.createElement("div",{className:"pagination-nav__item"},a&&n.createElement(l.Z,{permalink:a,title:n.createElement(r.Z,{id:"theme.blog.paginator.newerEntries",description:"The label used to navigate to the newer blog posts page (previous page)"},"Newer Entries")})),n.createElement("div",{className:"pagination-nav__item pagination-nav__item--next"},s&&n.createElement(l.Z,{permalink:s,title:n.createElement(r.Z,{id:"theme.blog.paginator.olderEntries",description:"The label used to navigate to the older blog posts page (next page)"},"Older Entries")})))}},9404:function(e,t,a){a.r(t),a.d(t,{default:function(){return c}});var n=a(7294),r=a(9960),l=a(8665),s=a(8561),o=a(5999),i=a(3725),g=a(6299);function c(e){var t,a=e.metadata,c=e.items,p=e.sidebar,m=e.listMetadata,d=a.allTagsPath,u=a.name,h=a.count,b=(t=(0,i.c2)().selectMessage,function(e){return t(e,(0,o.I)({id:"theme.blog.post.plurals",description:'Pluralized label for "{count} posts". Use as much plural forms (separated by "|") as your language support (see https://www.unicode.org/cldr/cldr-aux/charts/34/supplemental/language_plural_rules.html)',message:"One post|{count} posts"},{count:e}))}),f=(0,o.I)({id:"theme.blog.tagTitle",description:"The title of the page for a blog tag",message:'{nPosts} tagged with "{tagName}"'},{nPosts:b(h),tagName:u});return n.createElement(l.Z,{title:f,wrapperClassName:i.kM.wrapper.blogPages,pageClassName:i.kM.page.blogTagPostListPage,searchMetadata:{tag:"blog_tags_posts"},sidebar:p},n.createElement("header",{className:"margin-bottom--xl"},n.createElement("h1",null,f),n.createElement(r.Z,{href:d},n.createElement(o.Z,{id:"theme.tags.tagsPageLink",description:"The label of the link targeting the tag list page"},"View All Tags"))),c.map((function(e){var t=e.content;return n.createElement(s.Z,{key:t.metadata.permalink,frontMatter:t.frontMatter,assets:t.assets,metadata:t.metadata,truncated:!0},n.createElement(t,null))})),n.createElement(g.Z,{metadata:m}))}}}]);