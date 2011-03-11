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
<xsl:variable name="SettingsDocTypeId" select="1127" />
<xsl:variable name="HomePageSettingsDocTypeId" select="1132" />
<xsl:variable name="home" select="$currentPage/ancestor-or-self::*[@level=1]" />
<xsl:variable name="lng" select="$home/@nodeName" />
<xsl:variable name="root" select="$home/parent::*" />
<xsl:variable name="settingsNode" select="$root/descendant::*[@nodeType=$SettingsDocTypeId]/descendant::*[@nodeName=$lng]/descendant::*[@nodeType=$HomePageSettingsDocTypeId]" />
    
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
                  <a href="#">
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