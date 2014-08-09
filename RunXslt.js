(function()
{   var XHTML   = "http://www.w3.org/1999/xhtml"
    ,   xslName = "AsTable.xsl"
    ,   baseUrl = "http://xmlaspect.org/XmlView/"
    ,   xslUrl  = baseUrl+xslName
    ,   b       = document.body || document.documentElement
    ,   msg     = createElement("div");
    forEach(document.getElementsByTagName('script'), function(el)
    {   var url = el.src
        ,   i   = url.indexOf('RunXslt.js');
        if( i>0 )
        {
            baseUrl = url.substring(0,i);
            xslUrl = baseUrl+"AsTable.xsl";
        }
    });
    
    cleanElement(b);
    msg.innerHTML = "<a href='" + xslUrl + "'> loading " + xslName + "</a>";
    b.appendChild(msg);

    getXml(document.URL, function (xml)
    {   getXml( xslUrl, function ( xsl, p, r )
        {
            if ('undefined' == typeof XSLTProcessor)
            {   msg.innerHTML = xml.transformNode(xsl);
                return;
            }
            p = new XSLTProcessor();
            p.importStylesheet(xsl);
            r = p.transformToFragment( xml, document );
            b.replaceChild( r, b.firstChild );
        });
    });
    function forEach( arr, callback, pThis )
    {
        for( var i=0; i<arr.length;i++)
           callback.call( pThis||arr, arr[i], i , pThis||arr );
    }
    function getXml( url, callback )
    {   var xhr = window.ActiveXObject ? new ActiveXObject("Msxml2.XMLHTTP") : new XMLHttpRequest();
 //       xhr.url = url;
        xhr.open("GET", url, false);
        try {xhr.responseType = "msxml-document"} catch(err) {} // Helping IE11
        xhr.onreadystatechange = function()
        {
            if( 4 != xhr.readyState )
                return;
            if( xhr.responseXML )
                return callback( xhr.responseXML );
            return new DOMParser().parseFromString( xhr.responseText, "application/xml" );
        }
        xhr.send();
    }
    function createElement(name)
    {
        return document.createElementNS ? document.createElementNS(XHTML, name) : document.createElement(name);
    }
    function cleanElement( el )
    {
        while( el.lastChild )
            el.removeChild( el.lastChild );
    }
})()