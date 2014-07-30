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
			  Table
			  <table>
				  <tbody>
					  <xsl:apply-templates select="*"></xsl:apply-templates>
				  </tbody>
			  </table>
		  </body>
	  </html>
  </xsl:template>
  <xsl:template match="*">
    <xsl:apply-templates select="*" ></xsl:apply-templates>
  </xsl:template>

  <xsl:template match="country">
	  <tr>
		  <td>
			  <xsl:value-of select="@iso"/>
		  </td>
		  <td>
			  <xsl:value-of select="@name"/>
		  </td>
		  <td>
			  <xsl:value-of select="@population"/>
		  </td>

	  </tr>
  </xsl:template>
</xsl:stylesheet>