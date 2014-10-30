(function()
{   var XHTML   = "http://www.w3.org/1999/xhtml"
    ,   xslName = "AsTable.xsl"
    ,   baseUrl = "http://xmlaspect.org/XmlView/"
    ,   xslUrl  = baseUrl+xslName
    ,   jsUrl  = baseUrl+"XmlView.js"
    ,   b       = document.body || document.documentElement
    ,   msg     = createElement("div");
    forEach(document.getElementsByTagName('script'), function(el)
    {   var url = el.src
        ,   i   = url.indexOf('RunXslt.js');
        if( i>0 )
        {
			baseUrl = url.substring(0,i);
			xslUrl = baseUrl+"AsTable.xsl";
			jsUrl  = baseUrl+"XmlView.js"
        }
    });
    
    cleanElement(b);
    msg.innerHTML = "<a href='" + xslUrl + "'> loading " + xslName + "</a>";
    b.appendChild(msg);

    getXml(document.URL, function (xml)
    {   getXml( xslUrl, function ( xsl, p, r )
        {
            if ('undefined' == typeof XSLTProcessor)
            {	xsl.setProperty("AllowXsltScript", true);
				msg.innerHTML = xml.transformNode(xsl);
				injectJS();
                return;
            }
            p = new XSLTProcessor();
            p.importStylesheet(xsl);
            r = p.transformToFragment( xml, document );
            b.replaceChild( r, b.firstChild );
			injectJS();

				function
			injectJS()
			{	var d = document
				,	h = d.getElementsByTagName('head')[0] || d.getElementsByTagName('div')[0] || document.documentElement
				,	s = d.createElementNS ? d.createElementNS(h.namespaceURI || 'http://www.w3.org/1999/xhtml', 'script') : d.createElement('script');
				s.setAttribute('src', jsUrl);
				h.appendChild(s);
			}
        });
    });

    function 
forEach( arr, callback, pThis )
{
    for( var i=0; i<arr.length;i++)
        callback.call( pThis||arr, arr[i], i , pThis||arr );
}
        function
Json2Xml( o, tag )
{   var noTag = "string" != typeof tag;

    if( o instanceof Array )
    {   noTag &&  (tag = 'array');
        return "<"+tag+">"+o.map(function(el){ return Json2Xml(el,tag); }).join()+"</"+tag+">";
    }
    noTag &&  (tag = 'r');
	tag=tag.replace( /[^a-z0-9]/gi,'_' );
    var oo  = {}
    ,   ret = [ "<"+tag+" "];
    for( var k in o )
        if( typeof o[k] == "object" )
            oo[k] = o[k];
        else
            ret.push( k.replace( /[^a-z0-9]/gi,'_' ) + '="'+o[k].toString().replace(/&/gi,'&#38;')+'"');
    if( oo )
    {   ret.push(">");
        for( var k in oo )
            ret.push( Json2Xml( oo[k], k ) );
        ret.push("</"+tag+">");
    }else
        ret.push("/>");
    return ret.join('\n');
}

    function 
getXml( url, callback )
{
	var xhr = window.ActiveXObject ? new ActiveXObject("Msxml2.XMLHTTP") : new XMLHttpRequest();
    xhr.open("GET", url, false);
    try {xhr.responseType = "msxml-document"} catch(err) {} // Helping IE11
    xhr.onreadystatechange = function()
    {
        if( 4 != xhr.readyState )
            return;
        if( xhr.responseXML )
            return callback( xhr.responseXML );
        var txt = xhr.responseText.trim();
        if( txt.charAt(0)!='<' )
            txt = Json2Xml( JSON.parse(txt) );
		return callback(new DOMParser().parseFromString( txt, "application/xml" ));
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

})();