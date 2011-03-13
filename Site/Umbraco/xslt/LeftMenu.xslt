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
<xsl:variable name="DownloadPageDocTypeId" select="1072" />
<xsl:variable name="DonatePageDocTypeId" select="1079" />
    
<xsl:template match="/">

<ul>  
  <li>
    <a class="selected" href="{umbraco.library:NiceUrl($currentPage/@id)}">
      <xsl:value-of select="$currentPage/title" />
    </a>
  </li>
  <xsl:if test="$currentPage/@nodeType!=$DownloadPageDocTypeId">
    <xsl:variable name="downloadPage" select="$currentPage/ancestor::*[@level=1]/descendant::*[@nodeType=$DownloadPageDocTypeId]" />
    <xsl:if test="count($downloadPage)!=0">
      <li>
        <a href="{umbraco.library:NiceUrl($downloadPage/@id)}">
          <xsl:value-of select="$downloadPage/title" />
        </a>
      </li>
    </xsl:if>
  </xsl:if>
  <xsl:if test="$currentPage/@nodeType!=$DonatePageDocTypeId">
    <xsl:variable name="donatePage" select="$currentPage/ancestor::*[@level=1]/descendant::*[@nodeType=$DonatePageDocTypeId]" />
    <xsl:if test="count($donatePage)!=0">
      <li>
        <a href="{umbraco.library:NiceUrl($donatePage/@id)}">
          <xsl:value-of select="$donatePage/title" />
        </a>
      </li>
    </xsl:if>
  </xsl:if>
</ul>

</xsl:template>

</xsl:stylesheet>