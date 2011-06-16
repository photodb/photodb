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
<xsl:variable name="root" select="$currentPage/ancestor::*[name()='root']" />
<xsl:variable name="languageHolderDocTypeId" select="1045" />

<xsl:variable name="languageRoot" select="$currentPage/ancestor-or-self::*[@level=1]" />
<xsl:variable name="lng" select="$languageRoot/@nodeName" />
<xsl:variable name="SettingsDocTypeId" select="1127" />
<xsl:variable name="settingsNode" select="$root/descendant::*[@nodeType=$SettingsDocTypeId]" />
    
<xsl:template match="/">

  <div class="languages">
    <span class="changeLanguage"><xsl:value-of select="$languageRoot/changeLanguageText" /></span>
    <xsl:for-each select="$root/child::*[@isDoc and @nodeType=$languageHolderDocTypeId]">
      <xsl:variable name="languageHolder" select="." />
      <a href="{umbraco.library:NiceUrl(./@id)}"><img src="/img/lang/{./@nodeName}.png" alt="{$settingsNode/child::*[@nodeName=$languageHolder/@nodeName]/languageName}" /></a>
    </xsl:for-each>
  </div>
</xsl:template>

</xsl:stylesheet>