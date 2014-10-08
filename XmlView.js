(function () {
	/*	
	1. Extract sorting rules from URL
	2. Get original XML, XSLT
	3. Sort the XML
	4. Transfrom with filtering
	5. populate back into body
		
	*/
	var XHTML = "http://www.w3.org/1999/xhtml"
    , xslName = "AsTable.xsl"
	, NS = "http://xmlaspect.org/XmlView"
    , baseUrl = "./"
    , xslUrl = baseUrl + xslName
	, xmlUrl = document.location.href
    , b = document.body || document.documentElement
	, sortRules = {}
	, states = { descending: 'ascending', ascending: undefined, "undefined": 'descending', 'null': 'descending' };

	getXml(xmlUrl, function (xml) {
		getXml(xslUrl, function (xsl, p, r) {
			sortTH = function sortTH(th) {
				/*	clone template node for given collection out of 
				mode="SortData" match="*[*]"
				replace the match to th.collection
				if( next(th.order) )
				in xsl:sort and add parameter according to next(th.order), th.data-type, th.select
				append template clone to root
				*/
				var xp = th.getAttribute("xv:sortPath").split('/')
				, id = xp.pop()
				, collectionId = xp.join('/')
				, template = XPath_node("//xsl:template[@name='SortDataDefault']", xsl).cloneNode(true)
				, sortNode = XPath_node("//xsl:sort", template)
				, order = states[th.getAttribute('order')];

				template.setAttribute('match', collectionId);
				template.removeAttribute('name');
				sortNode.setAttribute('select', id);
				if (order)
					sortNode.setAttribute('order', order);
				debugger;
				xsl.documentElement.appendChild(template);
				Transform(xml, xsl);
			};
			//			Transform( xml, xsl );
		});
	});
	return; // ============================

	function 
unique(arr) {
		//	return arr.filter(function(r, i, ar){ return ar.indexOf(r) === i; });
		var rin = {};
		return arr.filter(function (r) {
			return !(r in rin) && (rin[r] = r);
		});
	}
	function 
Transform(xml, xsl) {
		//		fixWebKitStylesheet(xsl);
		//	UpdateSortRules( xsl );
		if ('undefined' == typeof XSLTProcessor)
			return msg.innerHTML = xml.transformNode(xsl);
		var p = new XSLTProcessor();
		p.importStylesheet(xsl);
		var r = p.transformToFragment(xml, document);
		b.replaceChild(r, b.firstChild);
	}
	function 
UpdateSortRules(xsl) {
		var nodeRule = XPath_node("//*[ @mode='SortData' &amp; @match='*[*]' ]", xsl).cloneNode(true)
	, nodeSort = XPath_node("//xsl:sort", nodeRule);
		$(rules).forEach(function (rule) {
			var s = nodeSort.cloneNode(true);
			s.setAttribute("select", rule); // todo order, data-type
			nodeSort.parentNode().appendChild(s);
		});
		nodeRule.setAttribute("select", rule);
	}
	function 
XPath_node(xPath, node) {
		if ("SelectSingleNode" in node) {
			return node.selectSingleNode(xPath /* , XmlNamespaceManager nsmgr */)
		}
		var d = node.ownerDocument || node
	, nsResolver = d.createNSResolver && d.createNSResolver(d.documentElement);
		return (node.ownerDocument || node)
		.evaluate(xPath, node, nsResolver, XPathResult.FIRST_ORDERED_NODE_TYPE, null)
		.singleNodeValue;
	}
	function 
XPath_nl(xPath, node) {
		return ("SelectNodes" in node)
			? node.SelectNodes(xPath /* , XmlNamespaceManager nsmgr */)
			: (node.ownerDocument || node).evaluate(xPath, node, nsResolver, XPathResult.ANY_TYPE, null);
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