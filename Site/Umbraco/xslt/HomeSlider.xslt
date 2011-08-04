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
<xsl:variable name="SettingsDocTypeId" select="1127" />
<xsl:variable name="HomePageSettingsDocTypeId" select="1132" />
<xsl:variable name="home" select="$currentPage/ancestor-or-self::*[@level=1]" />
<xsl:variable name="lng" select="$home/@nodeName" />
<xsl:variable name="root" select="$home/parent::*" />
<xsl:variable name="settingsNode" select="$root/descendant::*[@nodeType=$SettingsDocTypeId]/descendant::*[@nodeName=$lng]/descendant::*[@nodeType=$HomePageSettingsDocTypeId]" />
    
<xsl:variable name="ReleasesHolderDocTypeID" select="1091" />
<xsl:variable name="ReleasesHolder" select="$currentPage/ancestor-or-self::*[@level=1]/descendant::*[@nodeType=$ReleasesHolderDocTypeID]" />
<xsl:variable name="DownloadHandlerDocTypeID" select="1097" />
<xsl:variable name="DownloadHelper" select="$currentPage/ancestor::*[name()='root']/descendant::*[@nodeType=$DownloadHandlerDocTypeID]" />
  
<xsl:template name="downloadLink">
  <xsl:for-each select="$ReleasesHolder/child::*[@isDoc and string(isStable)='1']">
    <xsl:sort select="umbraco.library:FormatDateTime(dateOfRelease, 'yyyyMMddHHmmss')" data-type="number" order="descending"/>
    <xsl:if test="position()=1">
      
      <xsl:variable name="fileName" select="umbraco.library:GetMedia(./installerFile, false)/installerFile" />
      <xsl:variable name="downloadUrl" select="concat(umbraco.library:NiceUrl($DownloadHelper/@id),'?id=',./@id)" />

      <xsl:value-of select="concat(umbraco.library:NiceUrl($DownloadHelper/@id),'?id=',./@id)" />
    </xsl:if>
  </xsl:for-each>
</xsl:template>
        
<xsl:template match="/">
    <div class="homeSlider">
      <div id="slider">
        <ul>        
          <xsl:for-each select="$settingsNode/child::*[@isDoc]">
            <xsl:if test="./image != ''">
              <xsl:variable name="image" select="umbraco.library:GetMedia(./image, false)/umbracoFile" />
              <xsl:if test="$image != ''">
                <li>
                  <xsl:if test="position()!=1"><xsl:attribute name="style">display:none;</xsl:attribute></xsl:if>
                  <a rel="nofollow">
                    <xsl:attribute name="href"><xsl:call-template name="downloadLink" /></xsl:attribute>
                    <img src="{$image}" alt="{./imageName}" />
                  </a>
                </li>
              </xsl:if>
            </xsl:if>
          </xsl:for-each>     
        </ul>
      </div>
    </div>
    <script type="text/javascript">
      $(document).ready(function(){  
        $("#slider").easySlider({
          prevText:   '',
          nextText:   ''
        });
        $("#slider li").show();
      });
    </script>

</xsl:template>

</xsl:stylesheet>