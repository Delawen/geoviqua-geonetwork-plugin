<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:geonet="http://www.fao.org/geonetwork"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:gvq="http://www.geoviqua.org/QualityInformationModel/4.0"
  version="2.0">

  <!-- Override geonet:is-image function defined in utils-fn.xsl -->
  <xsl:function name="gvq:is-image" as="xs:boolean">
    <xsl:param name="fileName" as="xs:string?"/>
    <xsl:choose>
      <!-- Test the length of the filename and add the svg extension to the whitelist (for embedded GEO labels) -->
      <xsl:when test="string-length($fileName) != 0 and geonet:ends-with-any-of(lower-case($fileName), ('gif', 'png', 'jpg', 'jpeg', 'bmp', 'tiff', 'svg'))"><xsl:value-of select="true()"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>