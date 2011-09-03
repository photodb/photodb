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
<xsl:variable name="mode" select="'stable'" />
<xsl:variable name="home" select="$currentPage/ancestor-or-self::*[@level=1]" />
<xsl:variable name="releasesHolderDocTypeId" select="1091" /> 
<xsl:variable name="downloadPageDocTypeId" select="1072" />
<xsl:variable name="downloadPage" select="$home/descendant::*[@nodeType=$downloadPageDocTypeId]" />
<xsl:variable name="releases" select="$home/descendant::*[@nodeType=$releasesHolderDocTypeId]/child::*[@isDoc and (($mode='stable' and string(isStable)='1') or $mode!='stable')]" />
<xsl:variable name="u">
  http://<xsl:value-of select="umbraco.library:RequestServerVariables('SERVER_NAME')"/>
</xsl:variable>
<xsl:variable name="version" select="umbraco.library:RequestQueryString('v')" />
<xsl:variable name="build" select="Plib:GetVersionBuild($version)" />

<xsl:template match="/">

  <xsl:for-each select="$releases">
    <xsl:sort select="umbraco.library:FormatDateTime(./dateOfRelease, 'yyyyMMddHHmmss')" data-type="number" order="descending"/>
    <xsl:if test="position()=1">
      <update>
        <release><xsl:value-of select="./version" />.<xsl:value-of select="./major" />.<xsl:value-of select="./minor" />.<xsl:value-of select="./build" /></release>
        <build><xsl:value-of select="./build" /></build>
        <version><xsl:value-of select="./programVersion" /></version>
        <release_date><xsl:value-of select="umbraco.library:FormatDateTime(./dateOfRelease, 'yyyyMMddHHmm')"/></release_date>
        <release_notes><xsl:value-of select="./releaseNotes" /></release_notes>
        <!--release_text><xsl:choose><xsl:when test="./versionInfo!=''"><xsl:value-of select="./versionInfo" /></xsl:when><xsl:otherwise><xsl:value-of select="./releaseText" /></xsl:otherwise></xsl:choose></release_text-->
        <download_url><xsl:value-of select="$u" /><xsl:value-of select="umbraco.library:NiceUrl($downloadPage/@id)" /></download_url>
        <is_stable><xsl:if test="string(./isStable)='1'">true</xsl:if></is_stable>
        <request_build><xsl:value-of select="$build" /></request_build>
        <release_text>
          <xsl:for-each select="$releases">
            <xsl:sort select="umbraco.library:FormatDateTime(./dateOfRelease, 'yyyyMMddHHmmss')" data-type="number" order="descending"/>
            <xsl:if test="./build&gt;$build and ./versionInfo!=''"><xsl:if test="position()=1"><xsl:value-of select="./releaseNotes" /></xsl:if>&#xa;
&nbsp;<xsl:if test="position()!=1">[<xsl:value-of select="./version" />.<xsl:value-of select="./major" />.<xsl:value-of select="./minor" />.<xsl:value-of select="./build" />]&nbsp;</xsl:if>&#xa;<xsl:value-of select="./versionInfo" /><xsl:if test="position()=1">&#xa;</xsl:if></xsl:if>
          </xsl:for-each>
        </release_text>
      </update>
    </xsl:if>
  </xsl:for-each> 

</xsl:template>

</xsl:stylesheet>