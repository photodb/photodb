<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [ <!ENTITY nbsp "&#x00A0;"> ]>
<xsl:stylesheet 
  version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:msxml="urn:schemas-microsoft-com:xslt"
  xmlns:umbraco.library="urn:umbraco.library" xmlns:Exslt.ExsltCommon="urn:Exslt.ExsltCommon" xmlns:Exslt.ExsltDatesAndTimes="urn:Exslt.ExsltDatesAndTimes" xmlns:Exslt.ExsltMath="urn:Exslt.ExsltMath" xmlns:Exslt.ExsltRegularExpressions="urn:Exslt.ExsltRegularExpressions" xmlns:Exslt.ExsltStrings="urn:Exslt.ExsltStrings" xmlns:Exslt.ExsltSets="urn:Exslt.ExsltSets" xmlns:Plib="urn:Plib" 
  exclude-result-prefixes="msxml umbraco.library Exslt.ExsltCommon Exslt.ExsltDatesAndTimes Exslt.ExsltMath Exslt.ExsltRegularExpressions Exslt.ExsltStrings Exslt.ExsltSets Plib ">

<xsl:output method="html" omit-xml-declaration="yes"/>

<xsl:param name="currentPage"/>

<xsl:template match="/">

  <xsl:variable name="keywords">
    <xsl:choose>
      <xsl:when test="$currentPage/mETAKeywords!=''">
        <xsl:value-of select="$currentPage/mETAKeywords" />
      </xsl:when>
      <xsl:when test="$currentPage/title!=''">
        <xsl:value-of select="'Photo Database '" />
        <xsl:value-of select="$currentPage/title" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'Photo Database '" />
        <xsl:value-of select="$currentPage/@nodeName" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
      
    <meta name="keywords" content="{$keywords}" />
    <meta name="description" content="{$currentPage/mETADescription}" />

</xsl:template>

</xsl:stylesheet>