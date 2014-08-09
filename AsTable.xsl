<?xml version="1.0" encoding="UTF-8"?>

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
		<table>
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