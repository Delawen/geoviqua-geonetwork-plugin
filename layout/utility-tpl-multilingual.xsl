<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all">


  <!-- Get the main metadata languages -->
  <xsl:template name="get-iso19139.geoviqua-language">
    <xsl:value-of select="$metadata/gmd:language/gco:CharacterString|
      $metadata/gmd:language/gmd:LanguageCode/@codeListValue"/>
  </xsl:template>


  <!-- Get the list of other languages in JSON -->
  <xsl:template name="get-iso19139.geoviqua-other-languages-as-json">
    <xsl:variable name="langs">
      <xsl:for-each select="$metadata/gmd:locale/gmd:PT_Locale">
        <lang><xsl:value-of select="concat('&quot;', gmd:languageCode/gmd:LanguageCode/@codeListValue, '&quot;:&quot;#', @id, '&quot;')"/></lang>
      </xsl:for-each>
    </xsl:variable>
    <xsl:text>{</xsl:text><xsl:value-of select="string-join($langs/lang, ',')"/><xsl:text>}</xsl:text>
  </xsl:template>

  <!-- Get the list of other languages -->
  <xsl:template name="get-iso19139.geoviqua-other-languages">
    <xsl:for-each select="$metadata/gmd:locale/gmd:PT_Locale">
      <lang id="{@id}" code="{gmd:languageCode/gmd:LanguageCode/@codeListValue}"/>
    </xsl:for-each>
  </xsl:template>
  

</xsl:stylesheet>
