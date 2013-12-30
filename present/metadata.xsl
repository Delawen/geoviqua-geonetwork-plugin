<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gts="http://www.isotc211.org/2005/gts"
	xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:fra="http://www.cnig.gouv.fr/2005/fra"
	xmlns:gmx="http://www.isotc211.org/2005/gmx" xmlns:srv="http://www.isotc211.org/2005/srv"
	xmlns:gml="http://www.opengis.net/gml" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:geonet="http://www.fao.org/geonetwork" xmlns:exslt="http://exslt.org/common"
	xmlns:gvq="http://www.geoviqua.org/QualityInformationModel/4.0"
	xmlns:updated19115="http://www.geoviqua.org/19115_updates"
	xmlns:gmd19157="http://www.geoviqua.org/gmd19157"
	xmlns:un="http://www.uncertml.org/2.0"
	exclude-result-prefixes="#all">
	
	<xsl:import href="../../iso19139/present/metadata-iso19139-fop.xsl"/>
	<xsl:import href="metadata-utils.xsl"/>

	<xsl:template mode="iso19139.gvq" name="gvq-file-upload" match="*[gmx:FileName]">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>

		<xsl:variable name="src" select="gmx:FileName/@src"/>

		<xsl:call-template name="gvq-file-or-logo-upload">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit" select="$edit"/>
			<xsl:with-param name="ref" select="gmx:FileName/geonet:element/@ref"/>
			<xsl:with-param name="value" select="gmx:FileName"/>
			<xsl:with-param name="src" select="$src"/>
			<xsl:with-param name="delButton" select="normalize-space(gmx:FileName)!=''"/>
			<xsl:with-param name="setButton" select="normalize-space(gmx:FileName)=''"/>
			<xsl:with-param name="visible" select="false()"/>
			<xsl:with-param name="action" select="concat('startFileUpload(', /root/*/geonet:info/id, ', ', $apos, gmx:FileName/geonet:element/@ref, $apos, ');')"/>
		</xsl:call-template>
	</xsl:template>

	<!-- Add exception to update-fixed-info to avoid URL creation for downloadable resources -->
	<xsl:template mode="iso19139.gvq" match="gmd:contactInstructions[gmx:FileName]" priority="2">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>

		<xsl:call-template name="gvq-file-or-logo-upload">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit" select="$edit"/>
			<xsl:with-param name="ref" select="gmx:FileName/geonet:element/@ref"/>
			<xsl:with-param name="value" select="gmx:FileName"/>
			<xsl:with-param name="src" select="gmx:FileName/@src"/>
			<xsl:with-param name="action" select="concat('showLogoSelectionPanel(', $apos, '_',
				gmx:FileName/geonet:element/@ref, '_src', $apos, ');')"/>
			<xsl:with-param name="delButton" select="false()"/>
			<xsl:with-param name="setButton" select="true()"/>
			<xsl:with-param name="visible" select="true()"/>
			<xsl:with-param name="setButtonLabel" select="/root/gui/strings/chooseLogo"/>
			<xsl:with-param name="label" select="/root/gui/strings/orgLogo"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="gvq-file-or-logo-upload">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		<xsl:param name="ref"/>
		<xsl:param name="value"/>
		<xsl:param name="src"/>
		<xsl:param name="action"/>
		<xsl:param name="delButton" select="normalize-space($value)!=''"/>
		<xsl:param name="setButton" select="normalize-space($value)!=''"/>
		<xsl:param name="visible" select="not($setButton)"/>
		<xsl:param name="setButtonLabel" select="/root/gui/strings/insertFileMode"/>
		<!-- Create a new simple element with this label and @src value -->
		<xsl:param name="label" select="/root/gui/strings/file"/>


		<xsl:apply-templates mode="complexElement" select=".">
			<xsl:with-param name="schema"   select="$schema"/>
			<xsl:with-param name="edit"     select="$edit"/>
			<xsl:with-param name="content">

				<xsl:choose>
					<xsl:when test="$edit">
						<xsl:variable name="id" select="generate-id(.)"/>
						<div id="{$id}"/>

						<xsl:call-template name="simpleElementGui">
							<xsl:with-param name="schema" select="$schema"/>
							<xsl:with-param name="edit" select="$edit"/>
							<xsl:with-param name="title" select="$label"/>
							<xsl:with-param name="text">
								<xsl:if test="$visible">
									<input id="_{$ref}_src" class="md" type="text" name="_{$ref}_src" value="{$src}" size="40" />
								</xsl:if>
								<button class="content" onclick="{$action}" type="button">
									<xsl:value-of select="$setButtonLabel"/>
								</button>
							</xsl:with-param>
							<xsl:with-param name="id" select="concat('db_',$ref)"/>
							<xsl:with-param name="visible" select="$setButton"/>
						</xsl:call-template>

						<xsl:if test="$delButton">
							<xsl:apply-templates mode="iso19139FileRemove" select="gmx:FileName">
								<xsl:with-param name="access" select="'public'"/>
								<xsl:with-param name="id" select="$id"/>
								<xsl:with-param name="geo" select="false()"/>
							</xsl:apply-templates>
						</xsl:if>

						<xsl:call-template name="simpleElementGui">
							<xsl:with-param name="schema" select="$schema"/>
							<xsl:with-param name="edit" select="$edit"/>
							<xsl:with-param name="title">
								<xsl:call-template name="getTitle">
									<xsl:with-param name="name"   select="name(.)"/>
									<xsl:with-param name="schema" select="$schema"/>
								</xsl:call-template>
							</xsl:with-param>
							<xsl:with-param name="text">
								<input id="_{$ref}" class="md" type="text" name="_{$ref}" value="{$value}" size="40" />
							</xsl:with-param>
							<xsl:with-param name="id" select="concat('di_',$ref)"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<!-- in view mode, if a label is provided display a simple element for this label
						with the link variable (could be an image or a hyperlink)-->
						<xsl:variable name="link">
							<xsl:choose>
								<xsl:when test="gvq:is-image(gmx:FileName/@src)">
									<img class="logo-wrap logo" src="{gmx:FileName/@src}"/>
								</xsl:when>
								<xsl:otherwise>
									<a href="{gmx:FileName/@src}"><xsl:value-of select="gmx:FileName"/></a>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>

						<xsl:if test="$label">
							<xsl:call-template name="simpleElementGui">
								<xsl:with-param name="schema" select="$schema"/>
								<xsl:with-param name="edit" select="$edit"/>
								<xsl:with-param name="title" select="$label"/>
								<xsl:with-param name="text">
									<xsl:copy-of select="$link"/>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:if>

						<xsl:call-template name="simpleElementGui">
							<xsl:with-param name="schema" select="$schema"/>
							<xsl:with-param name="edit" select="$edit"/>
							<xsl:with-param name="title">
								<xsl:call-template name="getTitle">
									<xsl:with-param name="name"   select="name(.)"/>
									<xsl:with-param name="schema" select="$schema"/>
								</xsl:call-template>
							</xsl:with-param>
							<xsl:with-param name="text">
								<xsl:choose>
									<xsl:when test="$label">
										<xsl:value-of select="gmx:FileName"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:copy-of select="$link"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template name="iso19139.gvqBrief">
		<metadata>
			<xsl:choose>
				<xsl:when test="geonet:info/isTemplate='s'">
					<xsl:call-template name="iso19139-subtemplate"/>
					<xsl:copy-of select="geonet:info" copy-namespaces="no"/>
				</xsl:when>
				<xsl:otherwise>
					
					<!-- call iso19139 brief -->
					<xsl:call-template name="iso19139-brief"/>
				</xsl:otherwise>
			</xsl:choose>
		</metadata>
	</xsl:template>
	
	
	<xsl:template name="iso19139.gvqCompleteTab">
		<xsl:param name="tabLink"/>
		<xsl:param name="schema"/>
		
		<xsl:call-template name="iso19139CompleteTab">
			<xsl:with-param name="tabLink" select="$tabLink"/>
			<xsl:with-param name="schema" select="$schema"/>
		</xsl:call-template>
	</xsl:template>
	
	
	<xsl:template name="metadata-iso19139.gvq">
		<xsl:param name="schema"/>
		<xsl:param name="edit" select="false()"/>
		<xsl:param name="embedded"/>
		
		<xsl:apply-templates mode="iso19139" select=".">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit" select="$edit"/>
			<xsl:with-param name="embedded" select="$embedded"/>
		</xsl:apply-templates>
	</xsl:template>
	
	
	<xsl:template name="iso19139.gvq-javascript"/>
</xsl:stylesheet>
