﻿
    import {loadXml,Transform, toggleSort, xml2clipboard,XPath_arr, XPath_node,XPath_str} from '../xml-toolkit.js'
    const   modUrl  = relUrl => new URL(relUrl, import.meta.url).pathname;
    const xml        = await loadXml( modUrl('./zbooks.xml'          ) )
    // const xml        = await loadXml( modUrl('demo/books.xml'          ) )
    ,     xslParams  = await loadXml( modUrl('./TableParams.xsl'   ) )
    ,     xslAsTable = await loadXml( modUrl('./AsTable.xsl'       ) )
    ,          nsUri = xml.lookupNamespaceURI(null) || "urn:xml-view:source-ns";

    [xml,xslParams,xslAsTable].map( x=>x.documentElement.setAttribute("xmlns:xvs", nsUri) );
    if( !xml.documentElement.getAttribute("xmlns") )
        xml.documentElement.setAttribute("xmlns", nsUri);

    const xmlParams = Transform( xml, xslParams, xml.createElement('xv:params') );

    // xml2clipboard(xmlParams);
    const tableTemplates = XPath_arr('/*/*', xmlParams);
    tableTemplates.map( t=>xslAsTable.documentElement.append(t) )
    // xslAsTable.documentElement.append(xmlParams);
    xml2clipboard(xslAsTable);

    const outNode = Transform( xml, xslAsTable, mainDemo );
// Transform( xml, xslAsTable, mainDemo );


    document.addEventListener('click', onSortCommand);
    document.addEventListener('keypress', onKeyPress);

    function onKeyPress( ev ){   if( ev.keyCode == 32 ) return onSortCommand( ev ); }
    function onSortCommand( ev )
    {
        debugger;
        try
        {   const p = ev.target.parentElement.parentElement.parentElement.parentElement.dataset.path
            ,   h = ev.target.href;
            if( !h || !h.includes('#') || !p )
                return;
            ev.preventDefault();
            toggleSort( xslAsTable, p, ev.target.getAttribute('href').substring(1) );
            Transform( xml, xslAsTable, mainDemo );
            xml2clipboard( xslAsTable );
        }catch( err ){}
    }

    `TODO
*    convert TableParams to transform into xvxsl:template mode="DisplayAs"
        instead of xv:table+xvxsl:template mode="DisplayAs"
*   click handler
    `
