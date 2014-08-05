(function()
{   var XHTML   = "http://www.w3.org/1999/xhtml"
    ,   xslUrl  = "http://mylocal/xa/XmlView/AsTable.xsl"
    ,   b       = document.body || document.documentElement
    ,   msg     = createElement("div");

    cleanElement(b);
    msg.innerHTML = "<a href='" + xslUrl + "'> loading " + xslUrl + "</a>";
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

    function getXml( url, callback )
    {   var xhr = window.ActiveXObject ? new ActiveXObject("Msxml2.XMLHTTP") : new XMLHttpRequest();
        xhr.url = url;
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
        return document.createElementNS(XHTML, name);
    }
    function cleanElement( el )
    {
        while( el.lastChild )
            el.removeChild( el.lastChild );
    }
})()