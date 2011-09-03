<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [ <!ENTITY nbsp "&#x00A0;"> ]>
<xsl:stylesheet 
  version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:msxml="urn:schemas-microsoft-com:xslt"
  xmlns:umbraco.library="urn:umbraco.library" xmlns:Exslt.ExsltCommon="urn:Exslt.ExsltCommon" xmlns:Exslt.ExsltDatesAndTimes="urn:Exslt.ExsltDatesAndTimes" xmlns:Exslt.ExsltMath="urn:Exslt.ExsltMath" xmlns:Exslt.ExsltRegularExpressions="urn:Exslt.ExsltRegularExpressions" xmlns:Exslt.ExsltStrings="urn:Exslt.ExsltStrings" xmlns:Exslt.ExsltSets="urn:Exslt.ExsltSets" 
  exclude-result-prefixes="msxml umbraco.library Exslt.ExsltCommon Exslt.ExsltDatesAndTimes Exslt.ExsltMath Exslt.ExsltRegularExpressions Exslt.ExsltStrings Exslt.ExsltSets ">

<xsl:output method="html" omit-xml-declaration="yes"/>

<xsl:param name="currentPage"/>
<xsl:variable name="level2Page" select="$currentPage/ancestor-or-self::*[@level=2]" />
    
<xsl:variable name="SkipDocTypeIds" select="',1056,1091,1245,'" />

<xsl:template match="/">

  <div class="mainMenuHorizontal">
    <ul>
      <xsl:for-each select="$currentPage/ancestor-or-self::*[@level=1]/descendant-or-self::*[@level &lt;= 2 and (string(umbracoNaviHide)!='1' or @id=$currentPage/@id) and not(contains($SkipDocTypeIds, @nodeType))]">
        <li>
          <a href="{umbraco.library:NiceUrl(./@id)}">
            <xsl:if test="./@id = $currentPage/@id or ./@id = $level2Page/@id">
              <xsl:attribute name="class">selected</xsl:attribute>
            </xsl:if>
            <xsl:choose>
              <xsl:when test="./title!=''">
                <xsl:value-of select="./title" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="./@nodeName" />
              </xsl:otherwise>
            </xsl:choose>
          </a>
        </li>
      </xsl:for-each>
      <li class="last"></li>
    </ul>
    
    <!-- Place this tag in your head or just before your close body tag -->
    <script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script>
    
    <!-- Place this tag where you want the +1 button to render -->
    <div class="plusone">
      <div class="g-plusone"></div> 
    </div>
  </div><!--mainMenu-->

</xsl:template>

</xsl:stylesheet>