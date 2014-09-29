<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright (c) Simulation Works, LLC 2014 All Rights Reserved.
This file is subject to the terms and conditions defined in
file 'LICENSE', which is part of this source code package.
-->
<xsl:stylesheet version="1.0"
xmlns="http://www.w3.org/1999/xhtml"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xv="http://xmlaspect.org/XmlView" 
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


	<xsl:template match="/">
		<html>
			<head>
				<title>XmlView - XmlAspect.org</title>
				<style>
					body{padding:0;margin:0;}
					table {border-collapse:collapse; width:100%; font-family: "HelveticaNeue-Light", "Helvetica Neue Light", "Helvetica Neue", Helvetica, Arial, "Lucida Grande", sans-serif;}
					caption{ text-align:left; }
					th {color: #FFFF80;background-image: linear-gradient(to bottom, #0F1FFF 0%, #AAAACC 100%); font-size:large;}
					tr:nth-child(even) {background-image: linear-gradient(to bottom, rgba(9, 16, 11, 0.2) 0%, rgba(90, 164, 110, 0.1) 100%);}
					tr:nth-child(odd) {background: rgba(255,255,255,0.2);}
					td{font-size:small;border-bottom: none;border-top: none;}
					th a{float:right; padding-right:0.5em;}
				</style>
			</head>
			<body>
Sort:<xsl:value-of select="sort"/>
				<xsl:if test="$sort"></xsl:if>
<hr/>
				<xsl:variable name="sortedData">
					<xsl:call-template name="StartSort">
						<xsl:with-param name="data" select="*"/>
						<xsl:with-param name="sortNode" select="document('sortParameters.xml')/*"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:apply-templates select="$sortedData" mode="DisplayAsTable" />
			</body>
			<head>
				<script>
					//document.body
				</script>
			</head>
		</html>
	</xsl:template>

	<xsl:template match="xv:sort" mode="SortSequence">
		<xsl:param name="data" />
		<xsl:param name="orderInSort" select="1" />
		<xsl:variable name="sorted">
			<xsl:call-template name="StartSort">
				<xsl:with-param name="data" select="$data"/>
				<xsl:with-param name="sortNode" select="*"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="*">
				<xsl:apply-templates mode="SortSequence" select="*">
					<xsl:with-param name="data" select="$sorted"/>
					<xsl:with-param name="orderInSort" select="$orderInSort + 1"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="$data"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="StartSort">
		<xsl:param name="data"/>
		<xsl:param name="sortNode"/>
		<xsl:apply-templates mode="SortSequence" select="$sortNode">
			<xsl:with-param name="data" />		
		</xsl:apply-templates>
	</xsl:template>
	
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
		
		<table border="1">
			<caption><!-- todo collapsible -->
				<var><xsl:value-of select="$childName"/></var>
			</caption>
			<thead>
				<tr>
					<xsl:for-each select="$headers">
						<th>
							<xsl:attribute name="col" >
								<xsl:value-of select="local-name()"/>
							</xsl:attribute>
							<a href="#"><span> </span><sub> </sub></a>
							<xsl:value-of select="local-name()"/>
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
								<xsl:value-of select="$rowNode/@*[local-name()=$key] | $rowNode/*[local-name()=$key]"/>
							</td>
						</xsl:for-each>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>
</xsl:stylesheet>