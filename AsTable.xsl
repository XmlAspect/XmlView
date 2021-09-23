<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright (c) Simulation Works, LLC 2014 All Rights Reserved.
This file is subject to the terms and conditions defined in
file 'LICENSE', which is part of this source code package.
-->
<xsl:stylesheet version="1.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:func="http://exslt.org/functions"
                xmlns:xvxsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exslt="http://exslt.org/common"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                exclude-result-prefixes="xhtml exslt msxsl"
                extension-element-prefixes="func"
>
    <xsl:output
            method="html"
            omit-xml-declaration="yes"
            standalone="yes"
            indent="yes"
    />
    <!--
        let processor = new XSLTProcessor();  // starts the XSL processor
        processor.setParameter(null, "baseUrl", new URL('./', import.meta.url).pathname);
    -->
    <xsl:param name="url"/>
    <xsl:param name="baseUrl"
               select="substring-before(substring-after(/processing-instruction('xml-stylesheet'),'href=&quot;'),'AsTable.xsl&quot;')"/>
    <xsl:param name="sort"/>
    <!-- select = "exslt:node-set($x) IE compatibility -->
    <msxsl:script language="JScript" implements-prefix="exslt">
        <![CDATA[
				var dd = eval("this['node-set'] =  function (x) { return x; }");
			]]>
    </msxsl:script>

    <xsl:template match="/">
        <html>
            <head>
                <title>XmlView - XmlAspect.org</title>
                <style><![CDATA[
                    body{padding:0;margin:0;}
                    table {border-collapse:collapse; width:100%; font-family: "HelveticaNeue-Light", "Helvetica Neue
                    Light", "Helvetica Neue", Helvetica, Arial, "Lucida Grande", sans-serif;}
                    caption{ text-align:left; }
                    th {background-image: linear-gradient(to bottom, #0F1FFF 0%, #AAAACC 100%); font-size:large;}
                    tr:nth-child(even) {background-image: linear-gradient(to bottom, rgba(9, 16, 11, 0.2) 0%, rgba(90,
                    164, 110, 0.1) 100%);}
                    tr:nth-child(odd) {background: rgba(255,255,255,0.2);}
                    td{font-size:small;border-bottom: none;border-top: none;}
                    th a{ color: #FFFF80; text-decoration:none; display:block;}
                    th a span{float:left;}
                    div>label, div>var{ margin-right:0.5em;}

                    fieldset{border-radius: 1em;border-bottom: none;border-left: none;}

                    /* collapse and select UI */
                    fieldset legend label{ cursor:pointer;}
                    input[type='checkbox']{ display:none;}

                    input[type='checkbox']:checked+fieldset{ border:2px solid red; }
                    input[type='checkbox']:checked+input+fieldset div,
                    input[type='checkbox']:checked+input+fieldset legend label.collapse i,
                    input[type='checkbox']:checked+fieldset .select i,
                    input[type='checkbox']+fieldset .collapse b,
                    input[type='checkbox']+fieldset .select b
                    {display:none; }

                    input[type='checkbox']:checked+input+fieldset .collapse b,
                    input[type='checkbox']+input:checked+fieldset .select b
                    { display:inline;}

                    legend label{ text-shadow: -1px -1px 1px #fff, -1px 0px 1px #fff, 0px -1px 1px #fff, 1px 1px 1px
                    #999, 0px 1px 1px #999, 1px 0px 1px #999, 1px 1px 5px #113;}
                    legend label b, legend label i{ margin-right: 0.5em; }
                    a.ascending:before{ content:'\25B2'; }
                    a.descending:before{ content:'\25BC'; }
                    label+var{ margin-left:1rem; }
                    ]]>
                </style>
                <script type="module" src="{$baseUrl}XmlView.js">/**/</script>
            </head>
            <body>
                <xsl:variable name="sortedData">
                    <xsl:call-template name="StartSort">
                        <xsl:with-param name="data" select="*"/>
                        <xsl:with-param name="sortNode" select="."/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:apply-templates select="exslt:node-set($sortedData)" mode="Render"/>
            </body>
        </html>
    </xsl:template>
    <xsl:template name="StartSort">
        <xsl:param name="data"/>
        <xsl:param name="sortNode"/>
        <xsl:apply-templates mode="SortData" select="$data">
            <xsl:with-param name="sortNode" select="$sortNode"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template mode="SortData" match="*" name="SortDataDefault">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="SortData" select="*">
                <xsl:sort data-type="text" order="ascending" select="@stub-will-be-replaced"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <xsl:template mode="SortData" match="*[not(*)]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:value-of select="."/>
        </xsl:copy>
    </xsl:template>

    <!-- skip XmlView injected data from sorting results -->
    <xsl:template mode="SortData" match="*[@priority='100']" priority="300"/>

    <xsl:template mode="Render" match="*">
        <fieldset>
            <legend>
                <xsl:value-of select="name()"/>
            </legend>
            <xsl:apply-templates mode="Render" select="*"/>
        </fieldset>
    </xsl:template>
    <xsl:template mode="Render" match="@*">
        <tr style="color: green">
            <th>
                <xsl:value-of select="name()"/>
            </th>
            <td>
                <xsl:value-of select="."/>
            </td>
        </tr>
    </xsl:template>

    <xsl:template mode="Render" match="*[not(*)]" priority="1"><!-- no children, display attributes -->
        <!-- todo template for each attribute for ability to override -->
        <fieldset>
            <legend>
                <xsl:value-of select="name()"/>
            </legend>
            <table>
                <xsl:apply-templates mode="Render" select="@*"/>
            </table>
            <xsl:value-of select="."/>
        </fieldset>
    </xsl:template>

    <xsl:template name="DisplayAsTableHead" >
        <xsl:param name="thead" />
        <xsl:param name="collectionPath"/>
        <xsl:param name="collectionName"/>

        <caption>
            <var>
                <xsl:attribute name="title"><xsl:value-of select="$collectionPath"/></xsl:attribute>
                <xsl:value-of select="$collectionName"/>
            </var>
        </caption>
        <thead>
            <tr>
                <xsl:for-each select="exslt:node-set($thead)/*">
                    <th><a	href="#{normalize-space(.)}"
                              class="{@order}"
                    ><sub><xsl:value-of select="@sort"/></sub>
                        <xsl:value-of select="text()"/>
                    </a>
                    </th>
                </xsl:for-each>
            </tr>
        </thead>
    </xsl:template>

    <xvxsl:template mode="Render" match="html:img" priority="4">
        <img><xsl:copy-of select="@*"/></img>
    </xvxsl:template>
</xsl:stylesheet>
