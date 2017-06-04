<?php
header("Access-Control-Allow-Origin: *");
?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>XmlView - XmlAspect.org</title>
    <style>
        iframe{float:right; width:30%; height:10em;}
        .BookmarkletTag{ font-size:large; }
    </style>
    <script type="text/javascript">
		var XmlHost = "localhost"
		,	XslHost = "mylocal";
		document.domain = XmlHost;

        function onLoad()
        {
    var baseUrl = "https://cdn.xml4jquery.com/ajax/libs/XmlView/1.0.0/"
    ,   xslUrl = baseUrl+"AsTable.xsl"
	,	xmlUrl = baseUrl+'countries.xml';
    document.body.innerHTML = "<a href='"+xslUrl+"'> loading "+xslUrl+"</a>";
    getXml( xmlUrl, function (xml)
    {   //document.domain = XslHost;
		getXml( xslUrl, function (xsl, p, r)
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
//        xhr.setRequestHeader( 'Origin', document.location.origin );
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
}
    </script>
</head>
<body onload="onLoad();">
    <h1>Loading...</h1>
</body>
</html>
