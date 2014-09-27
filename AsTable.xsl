<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright (c) Simulation Works, LLC 2014 All Rights Reserved.
This file is subject to the terms and conditions defined in
file 'LICENSE', which is part of this source code package.
-->
<xsl:stylesheet version="1.0"
xmlns="http://www.w3.org/1999/xhtml"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
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

				<xsl:apply-templates select="./*" />
			</body>
			<head>
				<script>
					//document.body
				</script>
			</head>
		</html>
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
		<xsl:variable name="headers0">
			<xsl:apply-templates select="." mode="FindHeaders"></xsl:apply-templates>
		</xsl:variable>
		<xsl:variable name="headers" select="*[1]/@*|*[1]/*" />
		<!-- first child attributes and its children -->
		
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
							<za href="#">
								&#9650;&#9660;&#9674;<sub>2</sub>
							</za>
							<xsl:value-of select="local-name()"/>
						</th>
					</xsl:for-each>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="*">
					<xsl:sort order="ascending" select="@continent"/>
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

	<xsl:template match="*" mode="FindHeaders">
		<xsl:for-each select="*[1]/@*">
			<xsl:element name="TH" >
				<xsl:attribute name="value" >
					<xsl:value-of select="."/>
				</xsl:attribute>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>