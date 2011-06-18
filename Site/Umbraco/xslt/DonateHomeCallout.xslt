<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [ <!ENTITY nbsp "&#x00A0;"> ]>
<xsl:stylesheet 
  version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:msxml="urn:schemas-microsoft-com:xslt"
  xmlns:umbraco.library="urn:umbraco.library" xmlns:Exslt.ExsltCommon="urn:Exslt.ExsltCommon" xmlns:Exslt.ExsltDatesAndTimes="urn:Exslt.ExsltDatesAndTimes" xmlns:Exslt.ExsltMath="urn:Exslt.ExsltMath" xmlns:Exslt.ExsltRegularExpressions="urn:Exslt.ExsltRegularExpressions" xmlns:Exslt.ExsltStrings="urn:Exslt.ExsltStrings" xmlns:Exslt.ExsltSets="urn:Exslt.ExsltSets" 
  exclude-result-prefixes="msxml umbraco.library Exslt.ExsltCommon Exslt.ExsltDatesAndTimes Exslt.ExsltMath Exslt.ExsltRegularExpressions Exslt.ExsltStrings Exslt.ExsltSets ">

<xsl:output method="xml" omit-xml-declaration="yes"/>

<xsl:param name="currentPage"/>
<xsl:variable name="DonatePageDocTypeId" select="1079" />
<xsl:variable name="DonatePage" select="$currentPage/ancestor-or-self::*[@level=1]/descendant::*[@nodeType=$DonatePageDocTypeId]" />

<xsl:template match="/">

  <xsl:if test="count($DonatePage)!=0">
    <div class="donate">
      <div class="donateInfo">
        <span><xsl:value-of select="$DonatePage/textDonate" disable-output-escaping="yes"/></span>
        <xsl:for-each select="$DonatePage/child::*[@isDoc]">
          <div class="paymentInfo">
            <img class="donateWmImg" alt="{./name}" src="{umbraco.library:GetMedia(./donateImage, false)/umbracoFile}" />
              <div class="donateWmInfo">
                <xsl:if test="string(./paddingTop)!=''"><xsl:attribute name="style">padding-top:<xsl:value-of select="./paddingTop" />px</xsl:attribute></xsl:if>
                
                <xsl:for-each select="./child::*[@isDoc]">
                  <span>
                    <xsl:if test="string(./fontSize)!=''"><xsl:attribute name="style">font-size:<xsl:value-of select="./fontSize" />px</xsl:attribute></xsl:if>
                    <xsl:value-of select="./detailText" />
                  </span>
                  <br />                    
                </xsl:for-each>
              </div>
          </div><!--paymentInfo-->
        </xsl:for-each>
      </div><!--donateInfo-->
      <a href="{umbraco.library:NiceUrl($DonatePage/@id)}">
        <img id="donateImg" src="/img/donate.png" alt="donate please"/>
      </a>
    </div><!--donate-->
  </xsl:if>
</xsl:template>

</xsl:stylesheet>