export const ACS = "ascending";
export const DES = "descending";

    export function
sortRules2arr(sortRulesArr)
{
    return sortRulesArr.map(function(el){ return ( DES === el.ord ? '-' : '' ) + el.key ; });
}
    export function
url2SortRules( params )
{
    ( p2o( params ).sort || [] ).forEach( triggerSortOrder );
}
    export function
triggerSortOrder( id, ord, sortRulesArr, states )
{
    if( 'number' == typeof ord )
        ord = ACS;

    var b = id.charAt(0);
    if( '-' === b )
    {	id = id.substring(1);
        ord = DES;
    }
    if( '+' === b )
    {	id = id.substring(1);
        ord = ACS;
    }

    let arr = sortRulesArr
    ,	i = -1
    ,	found= arr.some( function(el, n)
    {
        return el.key === id && ((i=n),true);
    });
    let el	= ( i < 0 )
            ? { key:id, ord: ord }
            : arr.splice(i,1)[0];
    el.ord = ord || states[el.ord];
    if( el.ord )
        arr.unshift(el);
}
    export function
p2o( urlParams )
{	var o = {};
    urlParams && urlParams.split('&').forEach(function (kv)
    {	var a = kv.split('=');
        if( a.length > 1 && a[1] )
            o[ a[0] ] = /*decodeURIComponent*/( a[1] ).split(',');
    });
    return o;
}
    export function
o2p( o )
{	var p = [];
    for( var k in o )
        p.push( k+'='+ /*encodeURIComponent*/( o[k].join(',') ) );
    return p.join('&');
}
    export function
unique( arr )
{   const rin = {};
    return arr.filter( r=> !(r in rin) && (rin[r] = r) );
}
    export function
Transform( xml, xsl, targetNode=(document.body || document.documentElement), sortRulesArr=[] )
{
    UpdateSortRules( xml, xsl, sortRulesArr );
    let t = targetNode;

    if( 'string' === typeof t )
        t = document.querySelector(t);
    const doc = t.ownerDocument;


    if ('undefined' == typeof XSLTProcessor)
    {	xsl.setProperty("AllowXsltScript", true);
        t.innerHTML = xml.transformNode(xsl);
        return t;
    }
    var p = new XSLTProcessor();
    p.importStylesheet(xsl);

    const r = p.transformToFragment(xml, doc);
    cleanElement(t);
    t.appendChild(r);
    return t;
}
    export function
UpdateSortRules( xml, xsl, sortRulesArr )
{
    if( !sortRulesArr || !sortRulesArr.length )
        return;
    // 1. create sorting template out of SortDataDefault
    var	ids = sortRulesArr.map(function(el){ return el.key; })
    ,	collectionId = "*[* [" +ids.join(" or ") + "] ]"
    ,	template = XPath_node("//xsl:template[@name='SortDataDefault']", xsl).cloneNode(true)
    ,	sortNode = XPath_node("//xsl:sort", template)
    ,	prevSort = XPath_node("//xsl:template[@priority='100']", xsl);

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
    var sortTemplate = xml.importNode(template,true);
    xml.documentElement.appendChild(sortTemplate);

    function sNode(){ return XPath_node("//*[@priority='100']", xml); }
}

    export function
XPath_node(xPath, node)
{
    var d = node.ownerDocument || node
    ,	nsResolver = d.createNSResolver && d.createNSResolver(d.documentElement);
    if( d.evaluate )
        return d.evaluate(xPath, node, nsResolver, 9, null).singleNodeValue;
    d.setProperty('SelectionLanguage', 'XPath');
    d.setProperty('SelectionNamespaces', 'xmlns:xsl="http://www.w3.org/1999/XSL/Transform"');

    return node.selectSingleNode( xPath );//,nsmgr )
}
    export function
XPath_str(xPath, node)
{
    var d = node.ownerDocument || node
    ,	nsResolver = d.createNSResolver && d.createNSResolver(d.documentElement);
    if( d.evaluate )
        return d.evaluate(xPath, node, nsResolver, 0, null).stringValue;
    d.setProperty('SelectionLanguage', 'XPath');
    d.setProperty('SelectionNamespaces', 'xmlns:xsl="http://www.w3.org/1999/XSL/Transform"');

    return node.selectSingleNode( xPath );//,nsmgr )
}
    export function
XPath_nl(xPath, node)
{
    var d = node.ownerDocument || node
        ,	nsResolver = d.createNSResolver && d.createNSResolver(d.documentElement);
    if( d.evaluate )
        return (node.ownerDocument || node).evaluate( xPath, node, nsResolver, 0, null );

    d.setProperty('SelectionLanguage', 'XPath');
    d.setProperty('SelectionNamespaces', 'xmlns:xsl="http://www.w3.org/1999/XSL/Transform"');
    return node.SelectNodes( xPath );//, nsmgr );
}
    export function
XPath_arr(xPath, node)
{
    const  nl = XPath_nl(xPath, node)
    ,     ret = [];
    let n;
    while( n = nl.iterateNext() )
        ret.push(n);
    return ret;
}
    export function
Json2Xml( o, tag )
{   var noTag = "string" != typeof tag;

    if( o instanceof Array )
    {   noTag &&  (tag = 'array');
        return "<"+tag+">"+o.map(function(el){ return Json2Xml(el,tag); }).join()+"</"+tag+">";
    }
    noTag &&  (tag = 'r');
    tag=tag.replace( /[^a-z0-9]/gi,'_' );
    let oo  = {}
        ,   ret = [ "<"+tag+" "];
    for( let k in o )
        if( typeof o[k] == "object" )
            oo[k] = o[k];
        else
            ret.push( k.replace( /[^a-z0-9]/gi,'_' ) + '="'+o[k].toString().replace(/&/gi,'&#38;')+'"');
    if( oo )
    {   ret.push(">");
        for( let k in oo )
            ret.push( Json2Xml( oo[k], k ) );
        ret.push("</"+tag+">");
    }else
        ret.push("/>");
    return ret.join('\n');
}
    export function
getXml(url, callback, errback=()=>{})
{
    var xhr = window.ActiveXObject ? new ActiveXObject("Msxml2.XMLHTTP") : new XMLHttpRequest();
    //       xhr.url = url;
    xhr.open("GET", url, false);
    try { xhr.responseType = "msxml-document" } catch (err) { } // Helping IE11
    xhr.onreadystatechange = function ()
    {
        if( 4 !== xhr.readyState )
            return;
        try
        {
            if( xhr.responseXML )
                return callback(xhr.responseXML);
            var txt = xhr.responseText.trim();
            if( txt.charAt(0)!=='<' )
            {
                txt = Json2Xml( JSON.parse(txt) );
            }
            callback(new DOMParser().parseFromString( txt, "application/xml" ));
        }catch( ex )
        {   console.error("XHR handler error", ex );
            errback(ex);
        }
    }
    xhr.send();
}
    export function
createElement(name)
{
    return document.createElementNS ? document.createElementNS(XHTML, name) : document.createElement(name);
}
    export function
cleanElement(el)
{
    while (el.lastChild)
        el.removeChild(el.lastChild);
}

    export function
loadXml( url )
{
    return new Promise( (resolve,reject)=>{ getXml(url, xml=>resolve(xml), err=>reject(err) ); })
}
    export function
toggleSort( xsl, path, field )
{
    const createElement = tag => (xsl.ownerDocument || xsl).createElementNS('http://www.w3.org/1999/XSL/Transform',tag)
    const  template = XPath_node(`//*[@mode="DisplayAs"][@match="/SearchResult/BookSet/*[name()='Book'][1]"]`, xsl);
    const	    ths = XPath_arr (`.//xhtml:th`                                  , template);
    const	     th = XPath_node(`.//xhtml:th[@data-field="${field}"]`          , template);
    const sortsRoot = XPath_node(`.//*[@name="DisplayAsTable"]//xsl:for-each`    , template);
    const  sortNode = XPath_node(`xsl:sort[contains(@select,"${field}")]`       , sortsRoot) || createElement( 'sort' );
    const     sorts = XPath_arr (`xsl:sort[not( contains(@select,"${field}"))]` , sortsRoot);

    // sort
    sortNode.remove();
    sorts.forEach( s=> s.remove() );
    while( sorts.length )
        sortsRoot.insertBefore( sorts.pop(), sortsRoot.firstChild );

    const prevOrder = sortNode.getAttribute('order')
    ,         order = prevOrder ? { ascending: 'descending', descending: '', default: 'ascending' }[prevOrder] : 'ascending';

    if( order )
    {   sortNode.setAttribute('order',order);
        sortNode.setAttribute('select',field);
        sortsRoot.insertBefore( sortNode, sortsRoot.firstChild );
    }

    // table headers
    const attr = h => h.getAttribute('sort')*1;
    const oldSort = attr(th);
    if( order )
    {   ths.map( h =>
        {   const s = attr(h);
            let S;
            if( oldSort )
            {   if( s && s <= oldSort )
                    S = s+1;
            }else
            {   if( s )
                    S = s + 1;
            }
            S && h.setAttribute('sort',S);
        });
        th.setAttribute('sort','1');
        th.setAttribute('order',order);
    }else
    {   ths.map( h =>
        {   const s = h.getAttribute('sort');
            if( s && s*1 > oldSort )
                h.setAttribute('sort',s*1-1);
        });
        th.removeAttribute('sort');
        th.removeAttribute('order');
    }
}
    export function
text2Clipboard( text )
{
    document.body.focus(); // clipboard under debugger would not work without this line
    const type = "text/plain"
    ,     blob = new Blob([text], { type })
    ,     data = [new ClipboardItem({ [type]: blob })];
    return navigator.clipboard.write(data);
}
    export const
xml2clipboard = xml => text2Clipboard( new XMLSerializer().serializeToString( xml ) )