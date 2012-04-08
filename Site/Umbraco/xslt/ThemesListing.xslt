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
<xsl:variable name="stylesRoot" select="$currentPage/ancestor::root/descendant::Styles" />
    
<xsl:template match="/">

  <div class="themes_page">
    <xsl:value-of select="$currentPage/topContent" disable-output-escaping="yes"/>
    
    <div class="themes_list">
      <xsl:for-each select="$stylesRoot/child::*[@isDoc]">
        <div class="theme_details">
          <strong><xsl:value-of select="./name" /></strong>
          <br />
          <a title="download {./name}" href="{./styleFile}"><img alt="theme - vcl style {./name}" src="{./previewImage}" /></a>
          <br />
          <a href="{./styleFile}"><xsl:value-of select="$currentPage/downloadText" /></a>
        </div>
      </xsl:for-each>
    </div>
    <div class="clearDiv"></div>
    
    <xsl:value-of select="$currentPage/bottomContent" disable-output-escaping="yes"/>
  </div>
</xsl:template>

</xsl:stylesheet>