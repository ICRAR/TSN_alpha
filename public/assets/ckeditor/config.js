/*
 Copyright (c) 2003-2011, CKSource - Frederico Knabben. All rights reserved.
 For licensing, see LICENSE.html or http://ckeditor.com/license
 */
CKEDITOR.editorConfig=function(e){e.filebrowserBrowseUrl="/ckeditor/attachment_files",e.filebrowserFlashBrowseUrl="/ckeditor/attachment_files",e.filebrowserFlashUploadUrl="/ckeditor/attachment_files",e.filebrowserImageBrowseLinkUrl="/ckeditor/pictures",e.filebrowserImageBrowseUrl="/ckeditor/pictures",e.filebrowserImageUploadUrl="/ckeditor/pictures",e.filebrowserUploadUrl="/ckeditor/attachment_files",e.filebrowserParams=function(){for(var e,t,n,i=document.getElementsByTagName("meta"),o=new Object,r=0;r<i.length;r++)switch(n=i[r],n.name){case"csrf-token":e=n.content;break;case"csrf-param":t=n.content;break;default:continue}return void 0!==t&&void 0!==e&&(o[t]=e),o},e.addQueryString=function(e,t){var n=[];if(!t)return e;for(var i in t)n.push(i+"="+encodeURIComponent(t[i]));return e+(-1!=e.indexOf("?")?"&":"?")+n.join("&")},CKEDITOR.on("dialogDefinition",function(t){var n,i,o=t.data.name,r=t.data.definition;CKEDITOR.tools.indexOf(["link","image","attachment","flash"],o)>-1&&(n=r.getContents("Upload")||r.getContents("upload"),i=null==n?null:n.get("upload"),i&&i.filebrowser&&void 0===i.filebrowser.params&&(i.filebrowser.params=e.filebrowserParams(),i.action=e.addQueryString(i.action,i.filebrowser.params)))}),e.extraAllowedContent="*(*)"};