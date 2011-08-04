<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [ <!ENTITY nbsp "&#x00A0;"> ]>
<xsl:stylesheet 
  version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:msxml="urn:schemas-microsoft-com:xslt"
  xmlns:umbraco.library="urn:umbraco.library" xmlns:Exslt.ExsltCommon="urn:Exslt.ExsltCommon" xmlns:Exslt.ExsltDatesAndTimes="urn:Exslt.ExsltDatesAndTimes" xmlns:Exslt.ExsltMath="urn:Exslt.ExsltMath" xmlns:Exslt.ExsltRegularExpressions="urn:Exslt.ExsltRegularExpressions" xmlns:Exslt.ExsltStrings="urn:Exslt.ExsltStrings" xmlns:Exslt.ExsltSets="urn:Exslt.ExsltSets" 
  exclude-result-prefixes="msxml umbraco.library Exslt.ExsltCommon Exslt.ExsltDatesAndTimes Exslt.ExsltMath Exslt.ExsltRegularExpressions Exslt.ExsltStrings Exslt.ExsltSets ">

<xsl:output method="xml" omit-xml-declaration="yes"/>

<xsl:param name="currentPage"/>

<xsl:template match="/">

  <div class="breadCrumbs">
    <xsl:call-template name="DrawNode">
      <xsl:with-param name="node" select="$currentPage" />
    </xsl:call-template>
  </div><!--breadCrumbs-->

</xsl:template>
    
<xsl:template name="DrawNode">
  <xsl:param name="node" />
  <xsl:if test="count($node)!=0">
    <xsl:choose>
      <xsl:when test="$node/@level=1">
        <a href="{umbraco.library:NiceUrl($node/@id)}"><img src="/img/breadCrumbs/home.gif" alt="home"/></a>
        <a href="{umbraco.library:NiceUrl($node/@id)}" class="crumb"><xsl:value-of select="$node/title" /></a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="DrawNode">
          <xsl:with-param name="node" select="$node/parent::*" />
        </xsl:call-template>
        <img src="/img/breadCrumbs/arrow.gif" alt="arrow"/>
        <a href="{umbraco.library:NiceUrl($node/@id)}" class="crumb"><xsl:value-of select="$node/title" /></a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>