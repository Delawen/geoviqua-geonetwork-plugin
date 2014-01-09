<xsl:stylesheet version="2.0" xmlns:xsl ="http://www.w3.org/1999/XSL/Transform"
  xmlns:gvq="http://www.geoviqua.org/QualityInformationModel/4.0"
  xmlns:gmd="http://www.isotc211.org/2005/gmd"
  xmlns:gco="http://www.isotc211.org/2005/gco"
  xmlns:geonet="http://www.fao.org/geonetwork"
  exclude-result-prefixes="gvq gmd gco geonet">

  <!-- Subtemplate mode - overrides for iso19139 are placed in here
	     -->
  <xsl:template name="iso19139.geoviqua-subtemplate">
		<xsl:variable name="gvqElements">
			<xsl:apply-templates mode="iso19139.geoviqua-subtemplate" select="."/>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="normalize-space(geonet:info/title)!=''">
				<title><xsl:value-of select="geonet:info/title"/></title>
			</xsl:when>
			<xsl:when test="count($gvqElements/*)>0">
				<xsl:copy-of select="$gvqElements"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="iso19139-subtemplate" select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

  <xsl:template mode="iso19139.geoviqua-subtemplate" match="*"/>
  
</xsl:stylesheet>
