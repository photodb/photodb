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

<xsl:variable name="NewsHolderDocTypeID" select="1231" />
<xsl:variable name="Home" select="$currentPage/ancestor-or-self::*[@level=1]" />
<xsl:variable name="NewsHolder" select="$Home/descendant::*[@nodeType = $NewsHolderDocTypeID]" />
    
<xsl:template match="/">

<!-- Plib:IsLoggedIntoBackend() -->
<xsl:if test="1">
  <div class="news_listing">
    <xsl:for-each select="$NewsHolder/child::*[@isDoc]">
      <xsl:sort select="umbraco.library:FormatDateTime(dateOfRelease, 'yyyyMMddHHmmss')" data-type="number" order="descending"/>
      <xsl:if test="position()&lt;10">
        <div class="news_block">     
          <div class="news_title">
            <strong><a href="{umbraco.library:NiceUrl(./@id)}"><xsl:value-of select="./title" /></a></strong> (<xsl:value-of select="umbraco.library:FormatDateTime(./dateOfRelease, 'dd.MM.yyyy')" />)
          </div>
          <div class="news_content">
            <xsl:value-of select="newsContent" disable-output-escaping="yes"/>
          </div>
        </div>
      </xsl:if>
    </xsl:for-each>
  </div>
</xsl:if>

</xsl:template>

</xsl:stylesheet>