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
<xsl:variable name="ReleasesHolderDocTypeID" select="1091" />
<xsl:variable name="ReleasesHolder" select="$currentPage/ancestor-or-self::*[@level=1]/descendant::*[@nodeType=$ReleasesHolderDocTypeID]" />
<xsl:variable name="DownloadHandlerDocTypeID" select="1097" />
<xsl:variable name="DownloadHelper" select="$currentPage/ancestor::*[name()='root']/descendant::*[@nodeType=$DownloadHandlerDocTypeID]" />
    
<xsl:template match="/">

  <div class="release_list">
    <span class="info"><xsl:value-of select="$currentPage/listOfAllReleasesText" />:</span>
    
    
      <xsl:for-each select="$ReleasesHolder/child::*[@isDoc]">
        <xsl:sort select="umbraco.library:FormatDateTime(dateOfRelease, 'yyyyMMddHHmmss')" data-type="number" order="descending"/>
        <xsl:if test="position()&lt;5">      
          <xsl:variable name="fileName" select="umbraco.library:GetMedia(./installerFile, false)/installerFile" />
          <xsl:variable name="downloadUrl" select="concat(umbraco.library:NiceUrl($DownloadHelper/@id),'?file=',./installerFile)" />
          <div>
            <xsl:attribute name="class">release<xsl:if test="string(./isStable)='1'"> stable</xsl:if></xsl:attribute>
            <div class="release_download">
              <a href="{$downloadUrl}">
                <img src="/img/download-icon-windows-small.png" />                          
              </a>
            </div>
            <div class="release_name"><a href="{$downloadUrl}"><xsl:value-of select="./productName" />, <xsl:value-of select="$ReleasesHolder/buildText" />&nbsp;<xsl:value-of select="./build" /></a> (<xsl:value-of select="umbraco.library:FormatDateTime(./dateOfRelease, 'dd.MM.yyyy')" />) - <xsl:value-of select="Plib:GetDownloadCount(./installerFile)" /><xsl:value-of select="' '" /><xsl:value-of select="$ReleasesHolder/downloadsCountText" />, <xsl:value-of select="Plib:FormatFileSize(Plib:GetFileSize($fileName), 'Mb')" /></div>    
          </div>          
        </xsl:if>
      </xsl:for-each>
    
  </div>

</xsl:template>

</xsl:stylesheet>