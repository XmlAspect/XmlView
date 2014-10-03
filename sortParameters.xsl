<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright (c) Simulation Works, LLC 2014 All Rights Reserved.
This file is subject to the terms and conditions defined in
file 'LICENSE', which is part of this source code package.
-->
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>
	
					<xsl:template mode="SortData" 
match="countries[*]">
	<xsl:param name="sortNode"/>
	<xsl:copy>
		<xsl:copy-of select="@*"/>		
		<xsl:apply-templates mode="SortData" select="*">
			<xsl:sort data-type="text" order="ascending" select="@continent"/>
			<xsl:sort data-type="text" order="descending" select="@population"/>
		</xsl:apply-templates>
	</xsl:copy>
</xsl:template>	
					<xsl:template mode="SortData" 
match="geonames[*]">
	<xsl:copy>
		<xsl:copy-of select="@*"/>		
		<xsl:apply-templates mode="SortData" select="*">
			<xsl:sort data-type="number" order="descending" select="elevation"/>
		</xsl:apply-templates>
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>