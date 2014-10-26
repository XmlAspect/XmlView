(function ()
{
	/*	
		1. Extract sorting rules from URL
		2. Get original XML, XSLT
		3. Sort the XML
		4. Transfrom with filtering
		5. populate back into body		
	*/
	var XHTML = "http://www.w3.org/1999/xhtml"
	,	ACS	= "ascending"
	,	DES = "descending"
    ,	xslName = "AsTable.xsl"
	,	NS = "http://xmlaspect.org/XmlView"
    ,	baseUrl = ((document.location.hostname == 'localhost' ) ? document.location.pathname.substring( 0,document.location.pathname.lastIndexOf('/')) : NS ) + '/'
    ,	xslUrl = baseUrl + xslName
	,	xmlUrl = document.location.href
    ,	b = document.body || document.documentElement
	,	sortRulesArr = []
	,	states = { descending: ACS, ascending: undefined, "undefined": DES, 'null': DES };

	url2SortRules( document.location.search.substring(1) );
	url2SortRules( document.location.hash.substring(1) );
	
	console.log( sortRulesArr );

	getXml( xmlUrl, function (xml)
	{	getXml( xslUrl, function (xsl, p, r)
		{	sortTH = function sortTH(th)
			{	var sp = th.getAttribute("xv:sortpath")
				,	xp = sp.split('/')
				, id = xp.pop()
				, collectionId = xp.join('/')
				, order = states[th.getAttribute('order')];

				triggerSortOrder(id);

				Transform(xml, xsl);
												
				var params = p2o( document.location.hash.substring(1) );
				params.sort = sortRules2arr();
				window.location.href = '#' + o2p(params);
			};
			if( sortRulesArr.length )
				Transform( xml, xsl );
		});
	});
	return; // ============================

	function
sortRules2arr()
{
	return sortRulesArr.map(function(el){ return ( DES == el.ord ? '-' : '' ) + el.key ; });
}
	function
url2SortRules( params )
{
	( p2o( params ).sort || [] ).forEach( triggerSortOrder );
}
	function
triggerSortOrder( id, ord )
{
	if( 'number' == typeof ord )
		ord = ACS;

	var b = id.charAt(0);
	if( '-' == b )
	{	id = id.substring(1);
		ord = DES;
	}
	if( '+' == b )
	{	id = id.substring(1);
		ord = ACS;
	}

	var arr = sortRulesArr
	,	i = -1
	,	found= arr.some( function(el, n)
		{ 
			return el.key == id && ((i=n),true); 
		} );
	var el	= ( i < 0 )
			? { key:id, ord: ord }
			: arr.splice(i,1)[0];
	el.ord = ord || states[el.ord];
	if( el.ord )
		arr.unshift(el);
}	
	function 
p2o( urlParams )
{	var o = {};
	urlParams && urlParams.split('&').forEach(function (kv)
	{	var a = kv.split('=');
		if( a.length > 1 && a[1] )
			o[ a[0] ] = /*decodeURIComponent*/( a[1] ).split(',');
	});
	return o;
}
	function
o2p( o )
{	var p = [];
	for( var k in o )
		p.push( k+'='+ /*encodeURIComponent*/( o[k].join(',') ) );
	return p.join('&');
}
	function 
unique( arr )
{
	//	return arr.filter(function(r, i, ar){ return ar.indexOf(r) === i; });
	var rin = {};
	return arr.filter(function (r)
	{
		return !(r in rin) && (rin[r] = r);
	});
}
	function 
Transform( xml, xsl )
{
console.log( "Transform" );
	UpdateSortRules( xml, xsl );
	if ('undefined' == typeof XSLTProcessor)
		return msg.innerHTML = xml.transformNode(xsl);
	var p = new XSLTProcessor();
	p.importStylesheet(xsl);
	var r = p.transformToFragment(xml, document);
	cleanElement(b);
	b.appendChild(r);
}
	function 
UpdateSortRules( xml, xsl )
{
	// 1. create sorting template out of SortDataDefault
	var	ids = sortRulesArr.map(function(el){ return el.key; })
	,	collectionId = "*[* [" +ids.join(" or ") + "] ]"
	,	template = XPath_node("//xsl:template[@name='SortDataDefault']", xsl).cloneNode(true)
	,	sortNode = XPath_node("//xsl:sort", template)
	,	prevSort = XPath_node("//xsl:template[@priority='100']", xsl);

	console.log( "UpdateSortRules",collectionId, ids);

	// 2. remove previous injection
	for( var n = sNode(); n; n = sNode() ) 
		n.parentNode.removeChild(n);
	if( prevSort )
		prevSort.parentNode.removeChild( prevSort );

	if( ! sortRulesArr.length )
		return;

	// 3. inject sorting template into XML
	template.setAttribute('match', collectionId);
	template.setAttribute( "priority", "100" );
	template.removeAttribute('name');
	ids.forEach( function( id, i )
	{	var n = sortNode.cloneNode(true)
		,	ord = sortRulesArr[i].ord ;
		n.setAttribute('select', id);
		// n.setAttribute('id', i+1);
		ord &&	n.setAttribute('order', ord );		
		sortNode.parentNode.appendChild( n );
	});

	xsl.documentElement.appendChild(template);
console.log( template.outerHTML );

	var sortTemplate = xml.importNode(template,true);
	xml.documentElement.appendChild(sortTemplate);

	function sNode(){ return XPath_node("//*[@priority='100']", xml); }
}
	function 
XPath_node(xPath, node)
{
	if ("SelectSingleNode" in node)
	{
		return node.selectSingleNode(xPath /* , XmlNamespaceManager nsmgr */)
	}
	var d = node.ownerDocument || node
, nsResolver = d.createNSResolver && d.createNSResolver(d.documentElement);
	return (node.ownerDocument || node)
	.evaluate(xPath, node, nsResolver, XPathResult.FIRST_ORDERED_NODE_TYPE, null)
	.singleNodeValue;
}
	function 
XPath_nl(xPath, node)
{
	return ("SelectNodes" in node)
		? node.SelectNodes(xPath /* , XmlNamespaceManager nsmgr */)
		: (node.ownerDocument || node).evaluate(xPath, node, nsResolver, XPathResult.ANY_TYPE, null);
}


function forEach(arr, callback, pThis)
{
	for (var i = 0; i < arr.length; i++)
		callback.call(pThis || arr, arr[i], i, pThis || arr);
}
function getXml(url, callback)
{
	var xhr = window.ActiveXObject ? new ActiveXObject("Msxml2.XMLHTTP") : new XMLHttpRequest();
	//       xhr.url = url;
	xhr.open("GET", url, false);
	try { xhr.responseType = "msxml-document" } catch (err) { } // Helping IE11
	xhr.onreadystatechange = function ()
	{
		if (4 != xhr.readyState)
			return;
		if (xhr.responseXML)
			return callback(xhr.responseXML);
		return new DOMParser().parseFromString(xhr.responseText, "application/xml");
	}
	xhr.send();
}
function createElement(name)
{
	return document.createElementNS ? document.createElementNS(XHTML, name) : document.createElement(name);
}
function cleanElement(el)
{
	while (el.lastChild)
		el.removeChild(el.lastChild);
}

})();