<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [ <!ENTITY nbsp "&#x00A0;"> ]>
<xsl:stylesheet 
  version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:msxml="urn:schemas-microsoft-com:xslt"
  xmlns:umbraco.library="urn:umbraco.library" xmlns:Exslt.ExsltCommon="urn:Exslt.ExsltCommon" xmlns:Exslt.ExsltDatesAndTimes="urn:Exslt.ExsltDatesAndTimes" xmlns:Exslt.ExsltMath="urn:Exslt.ExsltMath" xmlns:Exslt.ExsltRegularExpressions="urn:Exslt.ExsltRegularExpressions" xmlns:Exslt.ExsltStrings="urn:Exslt.ExsltStrings" xmlns:Exslt.ExsltSets="urn:Exslt.ExsltSets" xmlns:Plib="urn:Plib" 
  exclude-result-prefixes="msxml umbraco.library Exslt.ExsltCommon Exslt.ExsltDatesAndTimes Exslt.ExsltMath Exslt.ExsltRegularExpressions Exslt.ExsltStrings Exslt.ExsltSets Plib ">

<xsl:output method="xml" omit-xml-declaration="yes"/>

<xsl:param name="currentPage"/>
<xsl:variable name="root" select="$currentPage/ancestor::*[name()='root']" />
<xsl:variable name="languageRoot" select="$currentPage/ancestor-or-self::*[@level=1]" />
<xsl:variable name="lng" select="$languageRoot/@nodeName" />
<xsl:variable name="SettingsDocTypeId" select="1127" />
<xsl:variable name="settingsNode" select="$root/descendant::*[@nodeType=$SettingsDocTypeId]/descendant::*[@nodeName=$lng]" />
    
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
  
  <xsl:variable name="title">
    <xsl:choose>
      <xsl:when test="$currentPage/title!=''">
        <xsl:value-of select="$currentPage/title" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$currentPage/@nodeName" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
      
  <meta name="keywords" content="{$keywords}" />
  <meta name="description" content="{$currentPage/mETADescription}" />
  <title>Photo Database - <xsl:value-of select="$settingsNode/siteSlogan" /> - <xsl:value-of select="Plib:Coalesce($currentPage/mETATitle,$title)" /></title>
</xsl:template>

</xsl:stylesheet>