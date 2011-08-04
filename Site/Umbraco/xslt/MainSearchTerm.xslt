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
    
<xsl:template match="/"><xsl:value-of select="$settingsNode/siteSlogan" /></xsl:template>

</xsl:stylesheet>