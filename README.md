XmlView
=======

Bookmarklet, esm JS, and XSLT for presenting XML or JSON as super-sortable HTML table. 

[![NPM version][npm-image]][npm-url]
[![git](https://cdnjs.cloudflare.com/ajax/libs/octicons/8.5.0/svg/mark-github.svg) GitHub](https://github.com/XmlAspect/XmlView)

Bookmarklet, XSLT rule will help to present XML in browser as a table.

[Live demo](https://unpkg.com/@xmlaspect/xml-view@1.0.2/demo/index.html)
| [Live docs and discussion](https://apifusion.com/wiki/index.php?title=XmlAspect.org/XmlView)

# API
## [XmlView.js](XmlView.js)

# Use
## Include in project
There are no dependencies, add to your project either by

    npm i -P @xmlaspect/xml-view

or use directly from CDN
```js
    import XmlView from 'https://unpkg.com/@xmlaspect/xml-view@1.0.2/XmlView.js';       
```
## Add transformation
### in XML 
add XSLT as in [AsTable.xml](demo/AsTable.xml) :
```html
<?xml-stylesheet type="text/xsl" href="../AsTable.xsl"?>
```

### Javascript
```js

```
[npm-image]:      https://img.shields.io/npm/v/@xmlaspect/xml-view.svg
[npm-url]:        https://npmjs.org/package/@xmlaspect/xml-view
