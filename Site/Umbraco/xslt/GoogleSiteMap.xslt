<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [ <!ENTITY nbsp "&#x00A0;"> ]>
<xsl:stylesheet 
  version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:msxml="urn:schemas-microsoft-com:xslt"
  xmlns:umbraco.library="urn:umbraco.library" xmlns:Exslt.ExsltCommon="urn:Exslt.ExsltCommon" xmlns:Exslt.ExsltDatesAndTimes="urn:Exslt.ExsltDatesAndTimes" xmlns:Exslt.ExsltMath="urn:Exslt.ExsltMath" xmlns:Exslt.ExsltRegularExpressions="urn:Exslt.ExsltRegularExpressions" xmlns:Exslt.ExsltStrings="urn:Exslt.ExsltStrings" xmlns:Exslt.ExsltSets="urn:Exslt.ExsltSets" xmlns:Plib="urn:Plib" 
  exclude-result-prefixes="msxml umbraco.library Exslt.ExsltCommon Exslt.ExsltDatesAndTimes Exslt.ExsltMath Exslt.ExsltRegularExpressions Exslt.ExsltStrings Exslt.ExsltSets Plib ">

<xsl:output method="xml" omit-xml-declaration="yes" indent="yes"/>

<xsl:param name="currentPage"/>
<xsl:variable name="maxLevelForSitemap" select="2"/>
<xsl:variable name="skipTypes">,</xsl:variable>
<xsl:variable name="skipTemplates">,</xsl:variable>
<xsl:variable name="rootUrl">http://<xsl:value-of select="umbraco.library:RequestServerVariables('SERVER_NAME')" /></xsl:variable>
    
<xsl:template match="/">
  <!-- rendering first level node -->
  <urlset>
    <url>
      <loc><xsl:value-of select="$rootUrl"/><xsl:value-of select="umbraco.library:NiceUrl($currentPage/ancestor-or-self::*[@level=1]/@id)"/></loc>
      <lastmod><xsl:value-of select="umbraco.library:FormatDateTime($currentPage/ancestor-or-self::*[@level=1]/@updateDate, 'yyyy-MM-dd')" /></lastmod>
      <!-- optional: changefreq | values: always, hourly, daily, weekly, monthly, yearly, never -->
      <!-- <changefreq>weekly</changefreq>-->
      <!-- optional: priority | vaalues: 0.0 to 1.0 -->
      <priority>0.8</priority>
      <changefreq>weekly</changefreq>
    </url>
    <xsl:call-template name="drawNodes">
      <xsl:with-param name="parent" select="$currentPage/ancestor-or-self::*[@level=1]"/>
    </xsl:call-template>
  </urlset>
</xsl:template>

<xsl:template name="drawNodes">
  <xsl:param name="parent"/>

  <xsl:for-each select="$parent/child::*[@isDoc][not(contains($skipTemplates,@template)) and not(contains($skipTypes,@nodeType)) and (string(umbracoNaviHide) != '1') and @level &lt;= $maxLevelForSitemap]">
    <url>
      <loc><xsl:value-of select="$rootUrl"/><xsl:value-of select="umbraco.library:NiceUrl(./@id)"/></loc>
      <lastmod><xsl:value-of select="umbraco.library:FormatDateTime(./@updateDate, 'yyyy-MM-dd')" /></lastmod>
      <!-- optional: changefreq | values: always, hourly, daily, weekly, monthly, yearly, never -->
      <!-- <changefreq>weekly</changefreq>-->
      <!-- optional: priority | vaalues: 0.0 to 1.0 -->
      <priority>0.5</priority>
      <changefreq>weekly</changefreq>
    </url>
    <xsl:if test="count(./child::*[@isDoc][not(contains($skipTemplates,@template)) and not(contains($skipTypes,@nodeType)) and (string(umbracoNaviHide) != '1') and @level &lt;= $maxLevelForSitemap]) &gt; 0">
      <xsl:call-template name="drawNodes">
        <xsl:with-param name="parent" select="."/>
      </xsl:call-template>
    </xsl:if>
  </xsl:for-each>
</xsl:template>

</xsl:stylesheet>