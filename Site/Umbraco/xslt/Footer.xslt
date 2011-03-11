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
<xsl:variable name="footerLinks" select="$currentPage/ancestor-or-self::*[@level=1]/descendant-or-self::*[string(includeInFooter)='1' and string(umbracoNaviHide)!='1']" />

<xsl:template match="/">

  <div class="footer">
    <xsl:for-each select="$footerLinks">
      <a href="{umbraco.library:NiceUrl(./@id)}"><xsl:value-of select="./title" /></a>
    </xsl:for-each>
    <span><a href="mailto:photodb@illusdolphin.net">©2011 Studio Illusion Dolphin</a></span>
  </div><!--footer-->

</xsl:template>

</xsl:stylesheet>