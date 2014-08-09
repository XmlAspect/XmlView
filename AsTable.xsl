<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright (c) Simulation Works, LLC 2014 All Rights Reserved.
This file is subject to the terms and conditions defined in
file 'LICENSE', which is part of this source code package.
-->
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output
  method="html"
  omit-xml-declaration="no"
  standalone="yes"
  indent="yes"
  />
  
  <xsl:template match="/">
	  <html>
		  <head>
			  <style>
				  table {border-collapse:collapse; width:100%; font-family: "HelveticaNeue-Light", "Helvetica Neue Light", "Helvetica Neue", Helvetica, Arial, "Lucida Grande", sans-serif;}
				  th {color: #FFFF80;background-image: linear-gradient(to bottom, #0F1FFF 0%, #AAAACC 100%); font-size:large;}
				  tr:nth-child(even) {background-image: linear-gradient(to bottom, rgba(9, 16, 11, 0.3) 0%, rgba(90, 164, 110, 0.2) 100%);}
				  tr:nth-child(odd) {background: rgba(255,255,255,0.2);}
				  td{font-size:small;}
			  </style>
		  </head>
		  <body>
			  <xsl:apply-templates select="./*" mode="DisplayAsTable" />
		  </body>
	  </html>
  </xsl:template>
  <xsl:template match="*">
    <xsl:apply-templates select="*" ></xsl:apply-templates>
  </xsl:template>

	<xsl:template match="*" mode="DisplayAsTable" >
		<xsl:variable name="headers0"><xsl:apply-templates select="." mode="FindHeaders"></xsl:apply-templates></xsl:variable>
		<xsl:variable name="headers" select="*[1]/@*|*[1]/*" /><!-- first child attributes and its children -->
		<table border="1">
			<thead>
				<tr>
					<xsl:for-each select="$headers">
						<th>
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
								<xsl:value-of select="$rowNode/@*[local-name()=$key]"/>
							</td>
						</xsl:for-each>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>

	<xsl:template match="*" mode="FindHeaders">
		<xsl:for-each select="*[1]/@*">
			<xsl:element name="TH" ><xsl:attribute name="value" ><xsl:value-of select="."/></xsl:attribute></xsl:element>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>