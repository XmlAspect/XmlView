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
	<xsl:param name="url" />
	<xsl:param name="baseUrl" />
	<xsl:param name="sort" />
	<!-- select = "exslt:node-set($x) IE compatibility -->
		<msxsl:script language="JScript" implements-prefix="exslt">
			<![CDATA[
				var dd = eval("this['node-set'] =  function (x) { return x; }");
			]]>
		</msxsl:script>
	
	
	
	
	
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
					th a{ color: #FFFF80; text-decoration:none;}
				</style>
				<script type="text/javascript" src="XmlView.js">/**/</script>
			</head>
			<body>
				<xsl:variable name="sortedData">
					<xsl:call-template name="StartSort">
						<xsl:with-param name="data" select="*" />
						<xsl:with-param name="sortNode" select="document('sortParameters.xml')/*" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:apply-templates select="exslt:node-set($sortedData)" mode="DisplayAsTable" />
			</body>
			<head>
				<script>
					//function sortTH( th ){		alert( th.title );	}
				</script>
			</head>
		</html>
	</xsl:template>

<xsl:template name="StartSort">
	<xsl:param name="data"/>
	<xsl:param name="sortNode"/>
	<xsl:apply-templates mode="SortData" select="$data">
		<xsl:with-param name="sortNode" select="$sortNode" />		
	</xsl:apply-templates>
</xsl:template>
	
	
	
<xsl:template mode="SortData" match="*[*]" name="SortDataDefault">
	<xsl:param name="sortNode"/>
	<xsl:copy>
		<xsl:copy-of select="@*"/>		
		<xsl:apply-templates mode="SortData" select="*">
			<xsl:sort data-type="text" order="ascending" select="@stub-will-be-replaced"/>
			<xsl:with-param name="sortNode" select="$sortNode" />
		</xsl:apply-templates>
	</xsl:copy>
</xsl:template>
	
<xsl:template mode="SortData" match="*[not(*)]">
	<xsl:param name="sortNode"/>
	<xsl:copy>
		<xsl:copy-of select="@*"/>		
	</xsl:copy>
</xsl:template>
	
<!--
<xsl:include href="sortParameters.xsl"/>	
-->		
	<xsl:template match="*">
		<xsl:variable name="firstChildName" select="name(./*[1])"/>
		<xsl:choose>
			<xsl:when test="count( *[ name() = $firstChildName ] ) &gt; 1">
				<var><xsl:value-of select="name()"/></var>
				<xsl:apply-templates mode="DisplayAsTable" select="."/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="DisplayAsTree"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="DisplayAsTree">
		<xsl:value-of select="name()"/>
		<xsl:apply-templates select="*"></xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="DisplayAsTable" >
		<xsl:param name="childName" select="name(*[1])"/>
		<xsl:variable name="headers" select="*[1]/@*|*[1]/*" />		<!-- first child attributes and its children -->
																	<!-- TODO union of unique child names as not all rows have same children set. When sorting the missing attributes changing number of columns -->
		<xsl:variable name="collection"  select="."/>
		<xsl:variable name="collectionPath"><xsl:apply-templates mode="xpath" select="."></xsl:apply-templates></xsl:variable>
		
		<table border="1">
			<caption><!-- todo collapsible -->
				<var>
					<xsl:attribute name="title"><xsl:value-of select="$collectionPath"/></xsl:attribute>
					<xsl:value-of select="$childName"/>
				</var>
			</caption>
			<thead>
				<tr>
					<xsl:for-each select="$headers">
						<xsl:variable name="p" ><xsl:if test="count(.|../@*)=count(../@*)">@</xsl:if><xsl:value-of select="local-name()"/></xsl:variable>
						<xsl:variable name="fullPath" ><xsl:value-of select="$collectionPath"/>/<xsl:value-of select="$p"/></xsl:variable>

						<th><a	href="#" 
								onclick="sortTH(this);return false;" 
								title="{$p}" 
								xv:sortPath="{$p}"
							   ><span> </span><sub> </sub>
								<xsl:value-of select="local-name()"/>
							</a>
						</th>
					</xsl:for-each>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="*">
					<xsl:variable name="rowNode" select="." />
					<tr>
						<xsl:for-each select="$headers">
							<xsl:variable name="key" select="name()" />
							<td>
								<xsl:attribute name="title"><xsl:apply-templates mode="xpath" select="."></xsl:apply-templates></xsl:attribute>
								<xsl:value-of select="$rowNode/@*[local-name()=$key] | $rowNode/*[local-name()=$key]"/>
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
	
<xsl:template mode="ZZSortData" match="*[*[@region] ]" priority="2">
	<!-- this is how sort will be adjusted by JS but with priority=3 -->
	<xsl:param name="sortNode"/>
	<xsl:copy>
		<xsl:copy-of select="@*"/>		
		<xsl:apply-templates mode="SortData" select="*">
			<xsl:sort data-type="text" order="ascending" select="@stub-will-be-replaced"/>
			<xsl:sort data-type="text" order="descending" select="@region"/>
			<xsl:with-param name="sortNode" select="$sortNode" />
		</xsl:apply-templates>
	</xsl:copy>
</xsl:template>
	
</xsl:stylesheet>
