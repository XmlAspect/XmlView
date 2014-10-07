(function () {
/*	
	1. Extract sorting rules from URL
	2. Get original XML, XSLT
	3. Sort the XML
	4. Transfrom with filtering
	5. populate back into body
		
*/
	var XHTML	= "http://www.w3.org/1999/xhtml"
    , xslName	= "AsTable.xsl"
	, NS		= "http://xmlaspect.org/XmlView"
    , baseUrl	= "./"
    , xslUrl = baseUrl + xslName
	, xmlUrl = document.location.href
    , b = document.body || document.documentElement
	, sortRules = {}
	, states = { descending: ascending, ascending: undefined, "undefined": descending };

	getXml(xmlUrl, function (xml) 
	{
		getXml(xslUrl, function (xsl, p, r) 
		{
			sortTH = function sortTH( th )
			{
				var xp = th.getAttribute( "xv:sortPath" ).split('/')
				,	id = xp.pop()
				,	collectionId = xp.join('/')
				,	arr = sortRules[collectionId] || []
				,	ids	= arr.map( function(el){ return el.id; })
				,	it	= findItem(id);

				it.order = states[ it.order + '' ];
				if( 'undefined' == it.order )
					ids = ids.map( function(el){ return el.id != id; });
				else
				{	ids.unshift( id );
					ids = unique(ids);
				}
				sortRules[collectionId] = ids.map( function( id ){ return findItem(id); } );
				
				console.log( "sorting by ", collectionId, id, sortRules );
				Transform( xml, xsl );

				function findItem(id){ return arr.filter( function(el){ return el.id == id;})[0] || {}; }
			};
//			$( "th a" ).addEventListener( "click", sortTH );
			Transform( xml, xsl );
		});
	});
	return; // ============================

	function
unique( arr )
{
//	return arr.filter(function(r, i, ar){ return ar.indexOf(r) === i; });
	var	rin	= {};
	return arr.filter( function( r )
	{
		return !(r in rin) && (rin[ r ] = r);
	});
}
	function
Transform( xml, xsl, sortPath )
{
	UpdateSortRules( xsl );
	if( 'undefined' == typeof XSLTProcessor )
		return msg.innerHTML = xml.transformNode(xsl);
	p = new XSLTProcessor();
	p.importStylesheet(xsl);
	r = p.transformToFragment(xml, document);
	b.replaceChild(r, b.firstChild);		
}
	function 
UpdateSortRules( xsl )
{
	var nodeRule = XPath_node( "//*[ @mode='SortData' &amp; @match='*[*]' ]", xsl ).cloneNode(true)
	,	nodeSort = XPath_node( "//xsl:sort", nodeRule );
	$(rules).forEach( function( rule )
	{
		var s = nodeSort.cloneNode(true);
		s.setAttribute( "select", rule );// todo order, data-type
		nodeSort.parentNode().appendChild(s);
	});
	nodeRule.setAttribute("select", rule); 
}
	function
XPath_node( xPath, node )
{
	return ( "SelectSingleNode" in node )
			? node.selectSingleNode( xPath /* , XmlNamespaceManager nsmgr */ )
			: ( node.ownerDocument || node ).evaluate( xPath, node, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null );
}
	function
XPath_nl( xPath, node )
{
	return ( "SelectNodes" in node )
			? node.SelectNodes( xPath /* , XmlNamespaceManager nsmgr */ )
			: ( node.ownerDocument || node ).evaluate( xPath, node, null, XPathResult.ANY_TYPE, null );
}
	
	// ============================================================

	var XHTML = "http://www.w3.org/1999/xhtml"
    , xslName = "AsTable.xsl"
    , baseUrl = "http://xmlaspect.org/XmlView/"
    , xslUrl = baseUrl + xslName
    , b = document.body || document.documentElement
    , msg = createElement("div");
	forEach(document.getElementsByTagName('script'), function (el) {
		var url = el.src
        , i = url.indexOf('RunXslt.js');
		if (i > 0) {
			baseUrl = url.substring(0, i);
			xslUrl = baseUrl + "AsTable.xsl";
		}
	});

	cleanElement(b);
	msg.innerHTML = "<a href='" + xslUrl + "'> loading " + xslName + "</a>";
	b.appendChild(msg);

	getXml(document.URL, function (xml) {
		getXml(xslUrl, function (xsl, p, r) {
			if ('undefined' == typeof XSLTProcessor) {
				msg.innerHTML = xml.transformNode(xsl);
				return;
			}
			p = new XSLTProcessor();
			p.importStylesheet(xsl);
			r = p.transformToFragment(xml, document);
			b.replaceChild(r, b.firstChild);
		});
	});
	function forEach(arr, callback, pThis) {
		for (var i = 0; i < arr.length; i++)
			callback.call(pThis || arr, arr[i], i, pThis || arr);
	}
	function getXml(url, callback) {
		var xhr = window.ActiveXObject ? new ActiveXObject("Msxml2.XMLHTTP") : new XMLHttpRequest();
		//       xhr.url = url;
		xhr.open("GET", url, false);
		try { xhr.responseType = "msxml-document" } catch (err) { } // Helping IE11
		xhr.onreadystatechange = function () {
			if (4 != xhr.readyState)
				return;
			if (xhr.responseXML)
				return callback(xhr.responseXML);
			return new DOMParser().parseFromString(xhr.responseText, "application/xml");
		}
		xhr.send();
	}
	function createElement(name) {
		return document.createElementNS ? document.createElementNS(XHTML, name) : document.createElement(name);
	}
	function cleanElement(el) {
		while (el.lastChild)
			el.removeChild(el.lastChild);
	}
})()