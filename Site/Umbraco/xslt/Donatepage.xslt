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

<xsl:template match="/">

  <div class="donate_page">
    
    <div class="donate">
      
      <div class="donateInfo">
        
        <h1><xsl:value-of select="$currentPage/donateCommonInfo" /></h1>
        
        <h2><xsl:value-of select="$currentPage/donateMoneyCaption" /></h2>
        <p>
          <xsl:value-of select="$currentPage/donateMoneyText" />
        </p>
            
        <div class="donate_payment_info">
          <xsl:for-each select="$currentPage/child::*[@isDoc]">
            <xsl:if test="./donateImage!=''">
              <div class="payment_name">
                <xsl:value-of select="./name" />
              </div>
              <div class="paymentInfo">
                <img class="donateWmImg" src="{umbraco.library:GetMedia(./donateImage, false)/umbracoFile}" />
                  <div class="donateWmInfo">
                    <xsl:for-each select="./child::*[@isDoc]">
                      <xsl:value-of select="./detailText" /><br />
                    </xsl:for-each>
                  </div>
              </div><!--paymentInfo-->
            </xsl:if>
          </xsl:for-each>
        </div>
        
        <div class="donate_pay_warning">
          <div class="warning_image">
            <img src="/img/warning.gif" />
          </div>
          <xsl:value-of select="$currentPage/donateMoneyInfo" />
        </div>
        
        <h2><xsl:value-of select="$currentPage/donateInfoCaption" /></h2>
        
        <p>
          <xsl:value-of select="$currentPage/donateInfoText" />
        </p>
                  
        <h3><xsl:value-of select="$currentPage/thankYouText" /></h3>
          
      </div><!--donateInfo-->
      <a href="{umbraco.library:NiceUrl($currentPage/@id)}">
        <img id="donateImg" src="/img/donate.png"/>
      </a>             
      
    </div><!--donate-->
  </div><!--donate_page-->
  
    
</xsl:template>

</xsl:stylesheet>