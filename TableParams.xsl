﻿<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:func="http://exslt.org/functions"
                xmlns:xv="@xmlaspect/xml-view"
                xmlns:xvxsl="http://www.w3.org/1999/XSL/TransformAlias"
                xmlns:exslt="http://exslt.org/common"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                exclude-result-prefixes="exslt msxsl"
                extension-element-prefixes="func"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://exslt.org/functions ">
<!--
* get entries for table presentation and
* fills in xsl:template mode="DisplayAs" for each
-->
    <xsl:output
            method="xml"
            omit-xml-declaration="no"
            standalone="yes"
            indent="yes"
    />
    <xsl:namespace-alias stylesheet-prefix="xvxsl" result-prefix="xsl"/>

    <!-- select = "exslt:node-set($x) IE compatibility -->
    <msxsl:script language="JScript" implements-prefix="exslt">
        <![CDATA[
				var dd = eval("this['node-set'] =  function (x) { return x; }");
			]]>
    </msxsl:script>

    <xsl:template match="/">
        <xv:params>
            <xsl:call-template name="CheckTables">
                <xsl:with-param name="tablesParentNode" select="./*"/>
            </xsl:call-template>
        </xv:params>
    </xsl:template>

    <xsl:template name="CheckTables" mode="CheckTables" match="*">
        <xsl:param name="tablesParentNode" select="."/>
        <xsl:param name="children" select="$tablesParentNode/*"/>
        <xsl:variable name="uniqueChildren">
            <xsl:call-template name="FilterUnique">
                <xsl:with-param name="nodes" select="$children"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:for-each select="exslt:node-set($uniqueChildren)/*">
            <xsl:variable name="tagName" select="name()"/>
            <xsl:variable name="uniqueNode" select="$children[ name() =$tagName ]"/>
            <xsl:choose>
                <xsl:when test="count( $uniqueNode) = 1"><!-- does not have same tag siblings  -->
                    <xsl:apply-templates mode="CheckTables" select="$uniqueNode"/>
                </xsl:when>
                <xsl:otherwise><!-- children with same names -->
                    <xsl:call-template name="AsTable">
                        <xsl:with-param name="rows" select="$uniqueNode"/>
                    </xsl:call-template>
					<xsl:apply-templates mode="CheckTables" select="$uniqueNode"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="AsTable">
        <xsl:param name="rows" select="*"/>
        <xsl:param name="fieldTableName" select="name($rows[1])"/>

        <xsl:variable name="xPath"><xsl:apply-templates mode="xpath" select="$rows[1]/.."
            />/<xsl:if test="namespace-uri(.)=namespace-uri(/*[1])"><xsl:value-of select="'xvs:'"
            /></xsl:if><xsl:value-of select="$fieldTableName"
            /></xsl:variable>
        <xsl:variable name="uniqueFields">
			<xsl:call-template name="FilterUnique">
				<xsl:with-param name="nodes" select="$rows[name()=$fieldTableName]/@*"/>
			</xsl:call-template>
			<xsl:call-template name="FilterUnique">
                <xsl:with-param name="nodes" select="$rows[name()=$fieldTableName]/*"/>
            </xsl:call-template>
        </xsl:variable>

        <xvxsl:template mode="Render" match="{$xPath}">
            <xvxsl:variable name="tagName" select="name()"/>
            <xvxsl:if test="not(following-sibling::*[name()=$tagName])">

                <i><b><xsl:value-of select="$xPath" /></b></i>
                <xvxsl:variable name="thead">
                    <xsl:for-each select="exslt:node-set($uniqueFields)">
                        <xsl:apply-templates mode="reportField" select="."/>
                    </xsl:for-each>
                </xvxsl:variable>
                <xvxsl:variable name="headStrSet">
                    <xvxsl:for-each select="exslt:node-set($thead)/*">|<xvxsl:value-of select="text()"/></xvxsl:for-each>
                </xvxsl:variable>
                <xvxsl:variable name="headStr" select="exslt:node-set($headStrSet)/text()"/>
                <xvxsl:call-template name="DisplayAsTable" >
                    <xvxsl:with-param name="collectionPath" select="'{$xPath}'"/>
                    <xvxsl:with-param name="collectionName" select="'{$fieldTableName}'"/>
                    <xvxsl:with-param name="thead" select="$thead"/>
                    <xvxsl:with-param name="trs">
                        <xvxsl:for-each select="../*[name()='{$fieldTableName}']">
                            <xvxsl:sort select="substring(normalize-space(Price),2)" order="ascending" data-type="number"/>
                            <xvxsl:sort select="Author"   order="descending"  />
                            <xvxsl:sort select="Title"    order="ascending"   />
                            <xvxsl:copy-of select="."/>
                        </xvxsl:for-each>
                    </xvxsl:with-param>
                </xvxsl:call-template>

            </xvxsl:if>
        </xvxsl:template>


    </xsl:template>





    <xsl:template name="DisplayAsTable" ></xsl:template><!-- stub in this XSL, actual implementation is in AsTable.xsl  -->

    <xsl:template mode="DisplayAs"	match="/SearchResult/BookSet/*[name()='Book'][1]" xml:id="tableTemplateStub">
        <i><b>/SearchResult/BookSet/Book</b></i>
        <xsl:variable name="thead">
            <th sort="2" order="descending"	data-field="Author"     > Author      </th>
            <th								data-field="BookCover"  > BookCover   </th>
            <th								data-field="ISBN"       > ISBN        </th>
            <th								data-field="ListPrice"  > ListPrice   </th>
            <th sort="1" order="ascending"	data-field="Price"      > Price       </th>
            <th								data-field="Synopsis"   > Synopsis    </th>
            <th sort="3" order="ascending"	data-field="Title"      > Title       </th>
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
                    <xsl:sort select="Author"   order="descending"  />
                    <xsl:sort select="Title"    order="ascending"   />
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="*" mode="reportField">
        <th data-field="{name()}"> <xsl:value-of select="name()" /> </th>
    </xsl:template>
    <xsl:template match="@*" mode="reportField">
        <th data-field="{name()}"> <xsl:value-of select="name()" /> </th>
    </xsl:template>
    <xsl:template match="node()[starts-with(name(), 'attr_')]" mode="reportField">
        <xsl:variable name="attributeName" select="substring(name(),6,128)"/>
        <th data-field="@{$attributeName}"> <xsl:value-of select="$attributeName" /> </th>
    </xsl:template>

	<xsl:template match="*"  mode="FilterUnique-Clone"><xsl:copy/></xsl:template>
	<xsl:template match="@*" mode="FilterUnique-Clone"><xsl:element name="attr_{substring(name(),1,128) }"/></xsl:template>

	<xsl:template match="*" name="FilterUnique">
        <xsl:param name="nodes" select="."/>
        <xsl:variable name="allFieldsSet" select="exslt:node-set($nodes)"/>
        <xsl:variable name="allFieldsSorted">
            <xsl:for-each select="$allFieldsSet">
                <xsl:sort select="name()"/>
				<xsl:apply-templates mode="FilterUnique-Clone" select="."/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="allFieldsSortedSet" select="exslt:node-set($allFieldsSorted)"/>

        <xsl:variable name="uniqueFields">
            <xsl:for-each select="$allFieldsSortedSet/*">
                <xsl:sort select="name()"/>
                <xsl:variable name="pos" select="position()"/>
                <xsl:if test="$pos = 1 or   name() != name($allFieldsSortedSet/*[$pos - 1])">
                    <xsl:copy/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:copy-of select="exslt:node-set($uniqueFields)"/>
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
        <xsl:if test="namespace-uri(.)=namespace-uri(/*[1])"><xsl:value-of select="'xvs:'"/></xsl:if>

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

</xsl:stylesheet>
