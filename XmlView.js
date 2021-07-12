import { getXml, o2p,p2o, ACS, DES, sortRules2arr, Transform, triggerSortOrder, url2SortRules } from "./xml-toolkit.js";

	/*
		1. Extract sorting rules from URL
		2. Get original XML, XSLT
		3. Sort the XML
		4. Transfrom with filtering
		5. populate back into body		
	*/
const xslUrl = new URL('AsTable.xsl', import.meta.url).pathname;

const XHTML        = "http://www.w3.org/1999/xhtml"
    , NS           = "http://xmlaspect.org/XmlView"
    , baseUrl      = "https://cdn.xml4jquery.com/ajax/libs/XmlView/1.0.0/"
    , xmlUrl       = document.location.href
    , b            = document.body || document.documentElement
    , sortRulesArr = []
    , states       = { descending: ACS, ascending: undefined, "undefined": DES, 'null': DES };

url2SortRules( document.location.search.substring(1) );
url2SortRules( document.location.hash  .substring(1) );
	

document.body || "complete" === document.readyState
    ? OnLoad()
    : document.addEventListener( "DOMContentLoaded", OnLoad, false );

	function 
OnLoad()
	{
		getXml( xmlUrl, function (xml)
		{	getXml( xslUrl, function (xsl, p, r)
			{	function sortTH(ev)
				{	const a = ev.target
                    ,   sp = a.getAttribute("xv:sortpath")
					,	xp = sp.split('/')
					, id = xp.pop()
					, collectionId = xp.join('/')
					, order = states[a.getAttribute('order')];

					triggerSortOrder(id, undefined, sortRulesArr, states );

                    enableSort( Transform( xml, xsl, sortRulesArr ) );
												
					const params = p2o( document.location.hash.substring(1) );
					params.sort = sortRules2arr(sortRulesArr);
					window.location.href = '#' + o2p(params);
				}
				const enableSort = dom =>
                    [...dom.querySelectorAll('[xv\\:sortpath]')]
                        .forEach(el=> el.addEventListener('click',sortTH) );
				if( sortRulesArr.length )
                    enableSort( Transform( xml, xsl, sortRulesArr ) );
				else
                    enableSort( document.body );
			});
		});
	}
