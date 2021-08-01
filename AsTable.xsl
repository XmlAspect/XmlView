<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright (c) Simulation Works, LLC 2014 All Rights Reserved.
This file is subject to the terms and conditions defined in
file 'LICENSE', which is part of this source code package.
-->
<xsl:stylesheet version="1.0"
xmlns="http://www.w3.org/1999/xhtml"
xmlns:xhtml="http://www.w3.org/1999/xhtml"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:func="http://exslt.org/functions" 
xmlns:my="my://own.uri" 
xmlns:xv="http://xmlaspect.org/XmlView" 
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
	<xsl:param name="url" />
	<xsl:param name="baseUrl" select="substring-before(substring-after(/processing-instruction('xml-stylesheet'),'href=&quot;'),'AsTable.xsl&quot;')"  />
	<xsl:param name="sort" />
	<!-- select = "exslt:node-set($x) IE compatibility -->
		<msxsl:script language="JScript" implements-prefix="exslt">
			<![CDATA[
				var dd = eval("this['node-set'] =  function (x) { return x; }");
			]]>
		</msxsl:script>

	<xsl:variable name="sorts"	select="//xsl:sort"	/>

    <func:function name="my:count-elements">
      <func:result select="count(//*)" />
</func:function>

	<xsl:template match="/">
		<html>
			<head>
				<title>XmlView - XmlAspect.org</title>
				<style>
					body{padding:0;margin:0;}
					table {border-collapse:collapse; width:100%; font-family: "HelveticaNeue-Light", "Helvetica Neue Light", "Helvetica Neue", Helvetica, Arial, "Lucida Grande", sans-serif;}
					caption{ text-align:left; }
					th					{background-image: linear-gradient(to bottom, #0F1FFF 0%, #AAAACC 100%); font-size:large;}
					tr:nth-child(even)	{background-image: linear-gradient(to bottom, rgba(9, 16, 11, 0.2) 0%, rgba(90, 164, 110, 0.1) 100%);}
					tr:nth-child(odd)	{background: rgba(255,255,255,0.2);}
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
					
					legend label{ text-shadow: -1px -1px 1px #fff, -1px 0px 1px #fff, 0px -1px 1px #fff, 1px 1px 1px #999, 0px 1px 1px #999, 1px 0px 1px #999, 1px 1px 5px #113;}
					legend label b, legend label i{ margin-right: 0.5em; } 
				</style>
				<script type="module" src="{$baseUrl}XmlView.js">/**/</script>
			</head>
			<body>
				<xsl:variable name="sortedData">
					<xsl:call-template name="StartSort">
						<xsl:with-param name="data" select="*" />
					</xsl:call-template>
				</xsl:variable>
				<div class="XmlViewRendered">
					<xsl:apply-templates select="exslt:node-set($sortedData)" mode="DisplayAs"/>
				</div>
			</body>
		</html>
	</xsl:template>
	<xsl:template match="/" priority="-20" name="BodyOnly">
		<xsl:variable name="sortedData">
			<xsl:call-template name="StartSort">
				<xsl:with-param name="data" select="*" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:apply-templates select="exslt:node-set($sortedData)" mode="DisplayAs"/>
	</xsl:template>
	
<xsl:template name="StartSort">
	<xsl:param name="data"/>
	<xsl:param name="sortNode"/>
	<xsl:apply-templates mode="SortData" select="$data">
		<xsl:with-param name="sortNode" select="$sortNode" />		
	</xsl:apply-templates>
</xsl:template>
	
	
	
<xsl:template mode="SortData" match="*[*]" name="SortDataDefault">
	<xsl:copy>
		<xsl:copy-of select="@*"/>		
		<xsl:apply-templates mode="SortData" select="*">
			<xsl:sort data-type="text" order="ascending" select="@stub-will-be-replaced"/>
		</xsl:apply-templates>
	</xsl:copy>
</xsl:template>
	
<xsl:template mode="SortData" match="*[not(*)]">
	<xsl:copy><xsl:copy-of select="@*"/><xsl:value-of select="."/></xsl:copy>
</xsl:template>

<!-- skip XmlView injected data from sorting results -->	
<xsl:template mode="SortData"		match="*[@priority='100']" priority="300"></xsl:template>

	<xsl:template mode="DisplayAs"	match="*" ><!-- distinct tags, match to 1st  -->
        <xsl:apply-templates select="." mode="DisplayAsTree" />
	</xsl:template>
	<xsl:template mode="DisplayAs"	match="@*" >
		<b><xsl:value-of select="name()"/></b>=<var><xsl:value-of select="."/></var>
	</xsl:template>
	<xsl:template mode="DisplayAsTree" match="*[not(*)]" priority="20">
		<div><label><xsl:value-of select="name()"/></label>
			<xsl:apply-templates select="@*" mode="DisplayAs"/>
			<var><xsl:value-of select="."/></var>
		</div>
	</xsl:template>
	
	<xsl:template mode="DisplayAsTree" match="*" >
		<xsl:variable name="xPath"><xsl:apply-templates mode="xpath" select="."/></xsl:variable>
		<input type="checkbox" id="collapse{$xPath}" class="collapseControl"/>
		<input type="checkbox" id="select{$xPath}"/>
		<fieldset>
			<legend><label for="collapse{$xPath}" class="collapse"><b>&#9654;</b><i>&#9660;</i></label> <label for="select{$xPath}" class="select"><b>&#10004;</b><i>&#10003;</i></label> <xsl:value-of select="name()"/></legend>
			<div>
				<xsl:apply-templates select="." mode="DisplayContent"/>
			</div>
		</fieldset>		
	</xsl:template>
	<xsl:template mode="DisplayContent" match="*">
		<xsl:for-each select="@*|*">
			<xsl:variable name="tagName" select="name()"/>

			<xsl:if test="not(preceding-sibling::*[name()=$tagName])">
				<xsl:apply-templates select="." mode="DisplayAs"/>
			</xsl:if>
		</xsl:for-each>
		<xsl:if test="normalize-space(text()) != '' ">
			<p><xsl:value-of select="text()"/></p>	
		</xsl:if>
	</xsl:template>

	<xsl:template name="DisplayAsTable" >
		<xsl:param name="thead" />
		<xsl:param name="trs" select="*"/>
		<xsl:param name="collectionPath"/>
		<xsl:param name="collectionName"/>

		<table border="1">
			<caption>
				<var>
					<xsl:attribute name="title"><xsl:value-of select="$collectionPath"/></xsl:attribute>
					<xsl:value-of select="$collectionName"/>
				</var>
			</caption>
			<thead>
				<tr>
					<xsl:for-each select="exslt:node-set($thead)/*">
                        <xsl:copy-of select="."/>
						<!--
                        <th><a	href="#"
								title="{$p}"
								xv:sortpath="{$p}"
							   ><span><xsl:value-of select="$direction"/> <sub><xsl:value-of select="$order"/> </sub></span>
								
								<xsl:value-of select="local-name()"/>
							</a>
						</th>
						-->
					</xsl:for-each>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="exslt:node-set($trs)/*">
					<xsl:variable name="rowNode" select="." />
					<tr>
						<xsl:for-each select="exslt:node-set($thead)/*">
							<xsl:variable name="th" select="." />
							<xsl:variable name="key" select="normalize-space(.)" />
							<td>
								<!-- xsl:attribute name="title"><xsl:apply-templates mode="xpath" select="."></xsl:apply-templates></xsl:attribute -->

                                <xsl:apply-templates mode="DisplayContent" select="$rowNode/*[name()=$key]|$rowNode/@*[name()=$key]" />
							</td>
						</xsl:for-each>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>
		
	<!-- XmlAspect/XOR/XPath/Dom2XPath.xsl -->
	<!-- Root -->
	<xsl:template match="/" mode="xpath">
		<xsl:text>/</xsl:text>
	</xsl:template>

	<!-- Element -->
	<xsl:template match="*" mode="xpath">
		<!-- Process ancestors first -->
		<xsl:apply-templates select=".." mode="xpath"/>

		<!-- Output / if not already output by the root node -->
		<xsl:if test="../..">/</xsl:if>

		<!-- Output the name of the element -->
		<xsl:value-of select="name()"/>

		<!-- Add the element's position to pinpoint the element exactly -->
		<xsl:if test="count(../*[name() = name(current())]) > 1">
			<xsl:text>[</xsl:text>
			<xsl:value-of
				select="count(preceding-sibling::*[name() = name(current())]) +1"/>
			<xsl:text>]</xsl:text>
		</xsl:if>

		<!-- Add 'name' predicate as a hint of which element -->
		<xsl:if test="@name">
			<xsl:text/>[@name="<xsl:value-of select="@name"/>"]<xsl:text/>
		</xsl:if>
	</xsl:template>

	<!-- Attribute -->
	<xsl:template match="@*" mode="xpath">
		<!-- Process ancestors first -->
		<xsl:apply-templates select=".." mode="xpath"/>

		<!-- Output the name of the attribute -->
		<xsl:text/>/@<xsl:value-of select="name()"/>

		<!-- Output the attribute's value as a predicate -->
		<xsl:text/>[.="<xsl:value-of select="."/>"]<xsl:text/>
	</xsl:template>


    <xvxsl:template mode="DisplayAs"	match="/SearchResult/BookSet/*[name()='Book'][1]" >
        <i><b>/SearchResult/BookSet/Book</b></i>
        <xsl:variable name="thead">
            <th> Author      </th>
            <th> BookCover   </th>
            <th> ISBN        </th>
            <th> ListPrice   </th>
            <th> Price       </th>
            <th> Synopsis    </th>
            <th> Title       </th>
        </xsl:variable>
        <xsl:variable name="headStrSet">
            <xsl:for-each select="exslt:node-set($thead)/*">|<xsl:value-of select="text()"/></xsl:for-each>
        </xsl:variable>

		
		<xsl:variable name="headStr" select="exslt:node-set($headStrSet)/text()"/>

		<xsl:call-template name="DisplayAsTable" >
			<xsl:with-param name="collectionPath" select="'/SearchResult/BookSet/Book'"/>
			<xsl:with-param name="collectionName" select="'Book'"/>
			<xsl:with-param name="thead" select="$thead"/>
            <xsl:with-param name="trs">
                <xsl:for-each select="../*[name()='Book']">
					<xsl:sort select="substring(normalize-space(Price),2)" order="ascending" data-type="number"/>
					<xsl:sort select="Author" order="descending"/>
                    <xsl:sort select="Title" order="ascending"/>
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </xsl:with-param>
        </xsl:call-template>
    </xvxsl:template>

</xsl:stylesheet>
