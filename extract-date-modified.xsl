<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:gvq="http://www.geoviqua.org/QualityInformationModel/4.0">
	<xsl:template match="gvq:GVQ_Metadata">
		 <dateStamp><xsl:value-of select="gmd:dateStamp/*"/></dateStamp>
	</xsl:template>
</xsl:stylesheet>