<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gts="http://www.isotc211.org/2005/gts"
	xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:fra="http://www.cnig.gouv.fr/2005/fra"
	xmlns:gmx="http://www.isotc211.org/2005/gmx" xmlns:srv="http://www.isotc211.org/2005/srv"
	xmlns:gml="http://www.opengis.net/gml/3.2" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:geonet="http://www.fao.org/geonetwork" xmlns:exslt="http://exslt.org/common"
	xmlns:gvq="http://www.geoviqua.org/QualityInformationModel/4.0"
	xmlns:updated19115="http://www.geoviqua.org/19115_updates"
	xmlns:gmd19157="http://www.geoviqua.org/gmd19157"
	xmlns:un="http://www.uncertml.org/2.0"
	exclude-result-prefixes="#all">
	
	<xsl:import href="../../iso19139/present/metadata-iso19139-fop.xsl"/>
	<xsl:import href="metadata-utils.xsl"/>
	<xsl:import href="metadata-subtemplates.xsl"/>

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


	<!-- ==================================================================== -->
	<!-- Metadata -->
	<!-- ==================================================================== -->

	<xsl:template mode="iso19139.gvq" match="gvq:GVQ_Metadata|*[@gco:isoType='gvq:GVQ_Metadata']">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>
		<xsl:param name="embedded"/>

		<xsl:variable name="dataset" select="gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='dataset' or normalize-space(gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue)=''"/>

		<!-- thumbnail -->
		<tr>
			<td valign="middle" colspan="2">
				<xsl:if test="$currTab='metadata' or $currTab='identification' or /root/gui/config/metadata-tab/*[name(.)=$currTab]/@flat">
					<div style="float:left;width:70%;text-align:center;">
						<xsl:variable name="md">
							<xsl:apply-templates mode="brief" select="."/>
						</xsl:variable>
						<xsl:variable name="metadata" select="exslt:node-set($md)/*[1]"/>
						<xsl:call-template name="thumbnail">
							<xsl:with-param name="metadata" select="$metadata"/>
						</xsl:call-template>
					</div>
				</xsl:if>
				<xsl:if test="/root/gui/config/editor-metadata-relation">
					<div style="float:right;">
						<xsl:call-template name="relatedResources">
							<xsl:with-param name="edit" select="$edit"/>
						</xsl:call-template>
					</div>
				</xsl:if>
			</td>
		</tr>

		<xsl:choose>

			<!-- metadata tab -->
			<xsl:when test="$currTab='metadata'">
				<xsl:call-template name="iso19139Metadata">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:call-template>
			</xsl:when>

			<!-- identification tab -->
			<xsl:when test="$currTab='identification'">
				<xsl:apply-templates mode="elementEP" select="gmd:identificationInfo|geonet:child[string(@name)='identificationInfo']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- maintenance tab -->
			<xsl:when test="$currTab='maintenance'">
				<xsl:apply-templates mode="elementEP" select="gmd:metadataMaintenance|geonet:child[string(@name)='metadataMaintenance']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- constraints tab -->
			<xsl:when test="$currTab='constraints'">
				<xsl:apply-templates mode="elementEP" select="gmd:metadataConstraints|geonet:child[string(@name)='metadataConstraints']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- spatial tab -->
			<xsl:when test="$currTab='spatial'">
				<xsl:apply-templates mode="elementEP" select="gmd:spatialRepresentationInfo|geonet:child[string(@name)='spatialRepresentationInfo']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- refSys tab -->
			<xsl:when test="$currTab='refSys'">
				<xsl:apply-templates mode="elementEP" select="gmd:referenceSystemInfo|geonet:child[string(@name)='referenceSystemInfo']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- distribution tab -->
			<xsl:when test="$currTab='distribution'">
				<xsl:apply-templates mode="elementEP" select="gmd:distributionInfo|geonet:child[string(@name)='distributionInfo']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- embedded distribution tab -->
			<xsl:when test="$currTab='distribution2'">
				<xsl:apply-templates mode="elementEP" select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- dataQuality tab -->
			<xsl:when test="$currTab='dataQuality'">
				<xsl:apply-templates mode="elementEP" select="gvq:dataQualityInfo|geonet:child[string(@name)='dataQualityInfo']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- appSchInfo tab -->
			<xsl:when test="$currTab='appSchInfo'">
				<xsl:apply-templates mode="elementEP" select="gmd:applicationSchemaInfo|geonet:child[string(@name)='applicationSchemaInfo']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- porCatInfo tab -->
			<xsl:when test="$currTab='porCatInfo'">
				<xsl:apply-templates mode="elementEP" select="gmd:portrayalCatalogueInfo|geonet:child[string(@name)='portrayalCatalogueInfo']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- contentInfo tab -->
			<xsl:when test="$currTab='contentInfo'">
				<xsl:apply-templates mode="elementEP" select="gmd:contentInfo|geonet:child[string(@name)='contentInfo']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- extensionInfo tab -->
			<xsl:when test="$currTab='extensionInfo'">
				<xsl:apply-templates mode="elementEP" select="gmd:metadataExtensionInfo|geonet:child[string(@name)='metadataExtensionInfo']">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>

			<!-- ISOMinimum tab -->
			<xsl:when test="$currTab='ISOMinimum'">
				<xsl:call-template name="isotabs">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
					<xsl:with-param name="dataset" select="$dataset"/>
					<xsl:with-param name="core" select="false()"/>
				</xsl:call-template>
			</xsl:when>

			<!-- ISOCore tab -->
			<xsl:when test="$currTab='ISOCore'">
				<xsl:call-template name="isotabs">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
					<xsl:with-param name="dataset" select="$dataset"/>
					<xsl:with-param name="core" select="true()"/>
				</xsl:call-template>
			</xsl:when>

			<!-- ISOAll tab -->
			<xsl:when test="$currTab='ISOAll'">
				<xsl:call-template name="iso19139Complete">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:call-template>
			</xsl:when>

			<!-- INSPIRE tab -->
			<xsl:when test="$currTab='inspire'">
				<xsl:call-template name="inspiretabs">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
					<xsl:with-param name="dataset" select="$dataset"/>
				</xsl:call-template>
			</xsl:when>


			<!-- default -->
			<xsl:otherwise>
				<xsl:call-template name="iso19139Simple">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="iso19139.gvqBrief">
		<metadata>
			<xsl:choose>
				<xsl:when test="geonet:info/isTemplate='s'">
					<xsl:call-template name="iso19139.gvq-subtemplate"/>
					<xsl:copy-of select="geonet:info" copy-namespaces="no"/>
				</xsl:when>
				<xsl:otherwise>
					<!-- call iso19139 brief -->
					<xsl:call-template name="iso19139-brief"/>
					<!-- now brief elements for mcp specific elements -->
					<xsl:call-template name="iso19139.gvq-brief"/>
				</xsl:otherwise>
			</xsl:choose>
		</metadata>
	</xsl:template>

	<xsl:template name="iso19139.gvq-brief"/>
	
	
	<xsl:template name="iso19139.gvqCompleteTab">
		<xsl:param name="tabLink"/>
		<xsl:param name="schema"/>
		
		<xsl:call-template name="iso19139CompleteTab">
			<xsl:with-param name="tabLink" select="$tabLink"/>
			<xsl:with-param name="schema" select="$schema"/>
		</xsl:call-template>
	</xsl:template>
	
	
	<!-- Check if any elements are overriden here in iso19139.gvq mode
	if not fallback to iso19139 -->
	<xsl:template name="metadata-iso19139.gvq" match="metadata-iso19139.gvq">
		<xsl:param name="schema"/>
		<xsl:param name="edit" select="false()"/>
		<xsl:param name="embedded"/>

		<!-- process in profile mode first -->
		<xsl:variable name="profileElements">
			<xsl:apply-templates mode="iso19139.gvq" select=".">
				<xsl:with-param name="schema" select="$schema"/>
				<xsl:with-param name="edit" select="$edit"/>
				<xsl:with-param name="embedded" select="$embedded"/>
			</xsl:apply-templates>
		</xsl:variable>

		<xsl:choose>
			<!-- if we got a match in profile mode then show it -->
			<xsl:when test="count($profileElements/*)>0">
				<xsl:copy-of select="$profileElements"/>
			</xsl:when>
			<!-- otherwise process in base iso19139 mode -->
			<xsl:otherwise>
				<xsl:apply-templates mode="iso19139" select=".">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit" select="$edit"/>
					<xsl:with-param name="embedded" select="$embedded"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<xsl:template name="iso19139.gvq-javascript"/>
</xsl:stylesheet>
