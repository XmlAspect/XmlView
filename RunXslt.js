(function()
{   var xslUrl = "AsTable.xsl";
    document.body.innerHTML = "<a href='"+xslUrl+"'> loading "+xslUrl+"</a>";
    getXml( document.URL, function (xml)
    {   getXml( document.URL, function (xsl, p, r)
        {   p = new XSLTProcessor();
            p.importStylesheet(xsl);
            r = p.transformToFragment( xml, document );
            document.body.replaceChild( r, document.body.firstChild );
        });
    });

    function getXml(url, callback)
    {   var xhr = new XMLHttpRequest();
        xhr.url = url;
        xhr.open("GET", url, false);
        xhr.setRequestHeader( 'Origin', document.location.origin );
//        xhr.overrideMimeType( 'text/xml' );
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
})()