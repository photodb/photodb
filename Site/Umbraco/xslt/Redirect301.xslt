<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [ <!ENTITY nbsp "&#x00A0;"> ]>
<xsl:stylesheet version="1.0"    
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
        xmlns:msxsl="urn:schemas-microsoft-com:xslt"  
        xmlns:vb="urn:the-xml-files:xslt-vb"            
        xmlns:umbraco.library="urn:umbraco.library"    
        exclude-result-prefixes="umbraco.library"> 
        <xsl:output method="html"/> 
                  
<xsl:output method="xml" omit-xml-declaration="yes"/>

<xsl:param name="currentPage"/>


<msxsl:script language="VB" implements-prefix="vb">
<msxsl:assembly name="System.Web"/>
<![CDATA[
    Public Function Redirect(url As String)
         System.Web.HttpContext.Current.Response.Status = "301 Moved Permanently"
         System.Web.HttpContext.Current.Response.AddHeader("Location", url.ToString)
         Return ""
    End Function
        ]]>
</msxsl:script>
                  
<xsl:template match="/">

  <xsl:if test="$currentPage/redirectToPage!=''">
    <xsl:value-of select="vb:Redirect(umbraco.library:NiceUrl($currentPage/redirectToPage))" />
  </xsl:if>

</xsl:template>
        
</xsl:stylesheet>
