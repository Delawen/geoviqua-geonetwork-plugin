<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gts="http://www.isotc211.org/2005/gts"
	xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:fra="http://www.cnig.gouv.fr/2005/fra"
	xmlns:gmx="http://www.isotc211.org/2005/gmx" xmlns:srv="http://www.isotc211.org/2005/srv"
	xmlns:gml="http://www.opengis.net/gml/3.2" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:geonet="http://www.fao.org/geonetwork" xmlns:exslt="http://exslt.org/common"
	xmlns:saxon="http://saxon.sf.net/"
	xmlns:gvq="http://www.geoviqua.org/QualityInformationModel/4.0"
	xmlns:updated19115="http://www.geoviqua.org/19115_updates"
	xmlns:gmd19157="http://www.geoviqua.org/gmd19157"
	xmlns:un="http://www.uncertml.org/2.0"
	exclude-result-prefixes="#all">
	
	<xsl:import href="../../iso19139/present/metadata-iso19139-fop.xsl"/>
	<xsl:import href="metadata-utils.xsl"/>
	<xsl:import href="metadata-subtemplates.xsl"/>

	<xsl:output name="serialize" method="xml" omit-xml-declaration="no" indent="yes" saxon:indent-spaces="1"/>

	<!-- ================================================================= -->
	<!-- codelists -->
	<!-- ================================================================= -->

	<!-- load geoviqua codelists -->
	<xsl:variable name="codelistsgvq" select="document('../schema/GVQ/4.0/resources/Codelist/gvqCodelists.xml')"/>
	<xsl:variable name="codelistsgmd19157" select="document('../schema/ISO/19157/20120707_GVQ/resources/Codelist/gmd19157_Codelists.xml')"/>
	<xsl:variable name="codelistsgmd19115updates" select="document('../schema/ISO/19139/20120707_GVQ/resources/Codelist/gmxUpdatedCodelists.xml')"/>
	<!-- load INSPIRE codelists -->
	<xsl:variable name="codelistsgmdINSPIRE" select="document('../schema/ISO/19139/20130610_INSPIRE/resources/codelist/gmxINSPIRECodelists.xml')"/>
	<!-- load iso19139 codelists -->
	<xsl:variable name="codelistsgmx19139" select="document('../schema/ISO/19139/20070417/resources/Codelist/gmxCodelists.xml')"/>

	<!-- deep-copy each set of codelists to combine them -->
	<xsl:variable name="codelistsCopy">
		<xsl:for-each select="$codelistsgvq | $codelistsgmd19157 | $codelistsgmd19115updates | $codelistsgmdINSPIRE | $codelistsgmx19139">
			<xsl:copy-of select="."/>
		</xsl:for-each>
	</xsl:variable>

	<!-- index code definitions on their gml:id attribute so we can search for duplicates -->
	<xsl:key name="kCodeDefinitionById" match="//gmx:codeEntry/gmx:CodeDefinition" use="@gml:id"/>

	<!-- recursively copy all nodes & attributes -->
	<xsl:template mode="codelistsCopyProcessing" match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates mode="codelistsCopyProcessing" select="node()|@*"/>
		</xsl:copy>
	</xsl:template>

	<!-- discard code definitions that occur more than once in the document and don't have the GeoViQua or ISOTC211/19157 codespace -->
	<xsl:template mode="codelistsCopyProcessing" match="//gmx:codeEntry[gmx:CodeDefinition[(gml:identifier/@codeSpace != 'GeoViQua' and gml:identifier/@codeSpace != 'ISOTC211/19157') and (count(key('kCodeDefinitionById', @gml:id)) > 1)]]"/>

	<!-- process the combined codelists -->
	<xsl:variable name="codelistsProcessed">
		<xsl:apply-templates mode="codelistsCopyProcessing" select="$codelistsCopy"/>
	</xsl:variable>

	<xsl:template mode="iso19139.gvq" match="gmd:*[*/@codeList]|gvq:*[*/@codeList]|updated19115:*[*/@codeList]|gmd19157:*[*/@codeList]">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>

		<xsl:call-template name="gvqCodelist">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template mode="iso19139.gvq" match="//gvq:GVQ_Metadata/gmd:characterSet|//*[@gco:isoType='gvq:GVQ_Metadata']/gmd:characterSet" priority="2">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>

		<xsl:call-template name="gvqCodelist">
			<xsl:with-param name="schema"  select="$schema"/>
			<xsl:with-param name="edit"    select="false()"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="gvqCodelist">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>

		<xsl:apply-templates mode="simpleElement" select=".">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="text">
				<xsl:apply-templates mode="gvqGetAttributeText" select="*/@codeListValue">
					<xsl:with-param name="schema" select="$schema"/>
					<xsl:with-param name="edit"   select="$edit"/>
				</xsl:apply-templates>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template mode="gvqGetAttributeText" match="@*">
		<xsl:param name="schema"/>
		<xsl:param name="edit"/>

		<xsl:variable name="name"     select="local-name(..)"/>
		<xsl:variable name="qname"    select="name(..)"/>
		<xsl:variable name="value"    select="../@codeListValue"/>

		<xsl:choose>
			<xsl:when test="$qname='gmd:LanguageCode'">
				<xsl:apply-templates mode="iso19139" select="..">
					<xsl:with-param name="edit" select="$edit"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>

				<xsl:variable name="codelist" select="$codelistsProcessed/gmx:CT_CodelistCatalogue/gmx:codelistItem/gmx:CodeListDictionary[gml:identifier=$name]" />
				<xsl:variable name="isXLinked" select="count(ancestor-or-self::node()[@xlink:href]) > 0" />

				<xsl:choose>
					<xsl:when test="$edit=true()">
						<!-- codelist in edit mode -->
						<select class="md" name="_{../geonet:element/@ref}_{name(.)}" id="_{../geonet:element/@ref}_{name(.)}" size="1">
							<!-- Check element is mandatory or not -->
							<xsl:if test="../../geonet:element/@min='1' and $edit">
								<xsl:attribute name="onchange">validateNonEmpty(this);</xsl:attribute>
							</xsl:if>
							<xsl:if test="$isXLinked">
								<xsl:attribute name="disabled">disabled</xsl:attribute>
							</xsl:if>
							<option name=""/>
							<xsl:for-each select="$codelist/gmx:codeEntry">
								<xsl:sort select="gmx:CodeDefinition/gml:identifier"/>
								<option>
									<xsl:if test="gmx:CodeDefinition/gml:identifier=$value">
										<xsl:attribute name="selected"/>
									</xsl:if>
									<xsl:attribute name="value"><xsl:value-of select="gmx:CodeDefinition/gml:identifier"/></xsl:attribute>
									<xsl:value-of select="gmx:CodeDefinition/gml:identifier"/>
								</option>
							</xsl:for-each>
						</select>
					</xsl:when>
					<xsl:otherwise>
						<!-- codelist in view mode -->
						<xsl:if test="normalize-space($value)!=''">
							<b><xsl:value-of select="$value"/></b>
							<xsl:value-of select="concat(': ',$codelist/gmx:codeEntry[gmx:CodeDefinition/gml:identifier=$value]/gmx:CodeDefinition/gml:description)"/>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
		<!--
		<xsl:call-template name="getAttributeText">
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
		</xsl:call-template>
		-->
	</xsl:template>


  <!-- gmx:FileName could be used as substitution of any
    gco:CharacterString. To turn this on add a schema 
    suggestion.
    -->
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

		<!-- header -->
		<tr>
			<td valign="middle" colspan="2">
				<xsl:if test="$currTab='metadata' or $currTab='identification' or /root/gui/config/metadata-tab/*[name(.)=$currTab]/@flat">
					<div style="float:left;width:70%;">
						<!-- geolabel -->
						<div id="xhr_geolabel" style="position: relative; overflow: hidden; float: left; text-align: center; margin: 0 20px; width: 150px; height: 150px;">
							<input name="xhr_metadata" id="xhr_metadata" type="hidden">
								<xsl:attribute name="value"><xsl:value-of select="saxon:serialize(., 'serialize')" /></xsl:attribute>
							</input>
						</div>
						<xsl:call-template name="iso19139.gvq-javascript"/>
						<!-- thumbnail -->
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
					<!-- now brief elements for gvq specific elements -->
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

	<!-- ================================================================= -->
	<!-- Main processing -->
	<!-- ================================================================= -->
	
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

	<!-- To support processing in two modes we need to add a null template to the profile mode  -->
	<xsl:template mode="iso19139.gvq" match="*|@*"/>

	<!-- Javascript used by functions in this presentation XSLT -->
	<xsl:template name="iso19139.gvq-javascript">
		<script type="text/javascript">
		<![CDATA[
		function createCORSRequest(method, url) {
			var xhr = new XMLHttpRequest();
			if ("withCredentials" in xhr) {

				// Check if the XMLHttpRequest object has a "withCredentials" property.
				// "withCredentials" only exists on XMLHTTPRequest2 objects.
				xhr.open(method, url, true);
			}
			else if (typeof XDomainRequest != "undefined") {

				// Otherwise, check if XDomainRequest.
				// XDomainRequest only exists in IE, and is IE's way of making CORS requests.
				xhr = new XDomainRequest();
				xhr.open(method, url);
			}
			else {

				// Otherwise, CORS is not supported by the browser.
				xhr = null;
			}
			return xhr;
		}

		function requestGEOlabel() {

			var xhr = createCORSRequest('POST', 'http://tutorial.geoviqua.org/geolabel.php?cors'),
				params = "metadata=" + encodeURIComponent(document.getElementById('xhr_metadata').value) + "&size=150";

			if (!xhr) {
				container.innerHTML = "No GEO label available (your browser is not HTML5 compatible)";
				return;
			}

			xhr.onloadstart = function() {
				var preload = document.createElement('img');
				preload.setAttribute('src', [
				'data:image/gif;base64,R0lGODlhMgAyAKUAAAQCBISChMTCxERCRKSipOTi5CQiJGRmZJSSlNTS1LSytPTy9DQyNBQSFFRWVHx6fAwKDIyKjMz',
				'KzExKTKyqrOzq7CwqLGxubJyanNza3Ly6vPz6/Dw6PBwaHFxeXAQGBISGhMTGxERGRKSmpOTm5CQmJGxqbJSWlNTW1LS2tPT29DQ2NBQWFFxaXHx+',
				'fAwODIyOjMzOzExOTKyurOzu7CwuLHRydJyenNze3Ly+vPz+/Dw+PP///wAAAAAAAAAAACH/C05FVFNDQVBFMi4wAwEAAAAh+QQIBgAAACwAAAAAM',
				'gAyAAAG/kCecEgsGnmbAKsRUB2f0Gj0BKgCTtKs9imzAmTbMHGDqHFmRpP3IG7fPtVPoogyVA2oYyKnaxsdXhFGJBgnJEcqJRAZfkUXXiNtOg8tC4',
				'1EBStVDk5+fZdENDkhnaCmp6iplzo5FyAVqo0aEFUipbFEGSm3Qy1eMbhFGxYAN0dqVS+MwUM6Dh05Rxl2AA+fzEIqBVALGijX2OHi4+Tl5udbNBQ',
				'C4OhCBcTVG+g6FK88EVYQNOgxtGwwrLzgdy7BCwA2eJDQ9AFEO3I5CBBUISCPu4sYM2rcqFFHBV4XVQBioWCcDgIucBxRYIUByFg5qkyYV2SElRIv',
				'VbEEsINmYKgdHxoYE7cBhAdgiEIs48i0qVMtKTiImNNGxQkXh0yRYFGFw0MpIGSeynAQgAGfWw5UqXFqg9oPCI6QePAga5EEK2qUPKUiQYavE8Qiy',
				'omLWgeOCF6wiLtRBw4cX8UEAQAh+QQIBgAAACwAAAAAMgAyAIUEAgSEhoREQkTExsQkJiTk5uSkpqRkYmQUEhTU1tS0trR0cnQ0NjT09vSUlpRUUl',
				'QMCgzMzswsLizs7uysrqxsamwcGhzc3ty8vrx8enyMjoxMSkw8Pjz8/vykoqRcWlwEBgRERkTMyswsKizs6uysqqxkZmQUFhTc2ty8urx0dnQ8Ojz',
				'8+vycmpxUVlQMDgzU0tQ0MjT08vS0srRsbmwcHhzk4uTEwsR8fnyUkpT///8AAAAAAAAAAAAAAAAAAAAG/kCdcEgsGoUUDqfEOjqfUOgNAgCAUtGs',
				'1qmqVivHRmMbxXwOEWPOCwgUWQ5CrTIhH0VUwIlUJK2qDAVFKWwqdkY4bCVGDRgpMkY0bDFjh0MtbDd2AWwhTZZCMi4gLzQddiQSVSeaoEMsMCinh',
				'yQeDiiuubq7vEYXLRSfvZYoNVUms8NGMrJHnFUINspGLA8grUUOXhaC00QdOCMJRxMCVg7eRh3C6ih86fDx8vP09fa9HQnd94zWCC38hEyAcWqGFw',
				'KQ7nVgAIKCDgUHK9ljsaKhjgYfQCAwEFAHiQTJLtTpSLKkyZMo+a1DyUKDBQYw6EXwMLJIAhBVNsyz8QKAbYkjEbxwmHcTgItkrw68sIBFXocSGS4',
				'46YBiX8qrWLM6uZBBQ0I7HW4YkOiKRYwqCyxRwEljFwkEVQQg1bIGgM5dCwC84Lgsh4Z3RQq4EDCAF4sENuYKyQvggBMW7OJtqDL0pAgJEjCkbBAZ',
				'VBAAIfkECAYAAAAsAAAAADIAMgCFBAIEhIKExMLEREJEJCIkpKKk5OLkZGJkFBIUlJKU1NLUVFJUNDI0tLK09PL0dHZ0DAoMjIqMzMrMTEpMLCosr',
				'Kqs7OrsbGpsHBocnJqc3NrcXFpcPDo8vLq8/Pr8fH58BAYEhIaExMbEREZEJCYkpKak5ObkZGZkFBYUlJaU1NbUVFZUNDY0tLa09Pb0fHp8DA4MjI',
				'6MzM7MTE5MLC4srK6s7O7sbG5sHB4cnJ6c3N7cXF5cPD48vL68/P78////Bv7An3BILBqFitNJcmw6n1AdBgBAqKDYbDNHpca04KLmEzEZG11Awdg',
				'bcRKesNGAozJcRc+OusATVTBdOXJFJWlMeSoycUUJaTM+hEMdaQZhNWknkkM+Dxg4KXIuM1QUOptDHiYWki4CLWaosrO0Wj6MRw49MrVPAjMcLw5G',
				'NjwAEF+9RhpTVBdGFV0kw8pEKWkYNkUtXTR+1UIFaQTfQi4nABgd4EQmNF3JRi647EI2ITctkfX8/f7/AAOGmSewiYcHMAj0KGgulgIQVAbQA7gDA',
				'6+HESf+O2Dxh4cPMEiIYPjDQSwhHjSSXMmypcuXMP/5qDHhAbV+LiwdMYCASmQEfz5mYGhxRAVEAA/8eXg3yMhBBDQ0/NPRQ6UQE+Viat3KdYiNGB',
				'myajEgY5+sDVQ+EFIQKAMtBlR2EEID4AatGiQYIMrTooHYHy4e7DhFy8HNIikghnj5gMqBlwZmjJDadVMQACH5BAgGAAAALAAAAAAyADIAhQQCBIS',
				'ChMTCxERGROTi5CQiJKSipGRmZBQSFNTS1PTy9JSSlFxaXDQyNLSytHR2dAwKDIyKjMzKzExOTOzq7CwqLGxubBwaHNza3Pz6/Ly6vKyqrJyanGRi',
				'ZDw+PHx+fAQGBISGhMTGxExKTOTm5CQmJKSmpGxqbBQWFNTW1PT29JSWlFxeXDQ2NLS2tHx6fAwODIyOjMzOzFRSVOzu7CwuLHRydBweHNze3Pz+/',
				'Ly+vP///wAAAAAAAAAAAAAAAAb+wJ1wSCwahaRFjHBsOp9QVQMAqNCg2GxTR6U6tOAibeNQGRMgKkhkxFg6uvBR5aGycsYADPbKFBU3VBBsckQCXQ',
				'BXRTk0NH5FLog2hUQpMFQIZmAJiBGURCslDS5yORYQAAOKn0IKmnIZKTKvrLW2t7Y5GBS4TwQPDCaPRBkdMBcavUc0U1QrRhJdHspGkV0NRilpACP',
				'URVzSRjkRFy0p3kQKE2pfRznD6EIqBiEJ8ff4+fr7/P22ODZmCMvBoQIDEv4IBKISwBKVF/5WIEKB4RIAiP0WILqQIcaNEQj74bjQBaM/IglYDFgB',
				'76TLlzBjypSZ4EQIWvHeNVHRggphh3w5XtQ4Z0RBAYb5MkyAEOfIhhITVt2jgaHlzKtYs7LK4EIAnkIZrFIKQMVEIRUMGuC4xYDKh0IEUAAgZUuEh',
				'xFrj6RI8LWaAZyfVIjdoQMGhHYxJQLwJJPGiQO8tNYKAgAh+QQIBgAAACwAAAAAMgAyAIUEAgSEgoTEwsREQkQkIiSkoqTk4uRkZmQUEhSUkpTU0t',
				'Q0MjS0srT08vRUUlR0dnQMCgyMiozMyswsKiysqqzs6uxsbmwcGhycmpzc2tw8Ojy8urz8+vxcWlxMSkx8fnwEBgSEhoTExsRERkQkJiSkpqTk5uR',
				'samwUFhSUlpTU1tQ0NjS0trT09vRUVlR8enwMDgyMjozMzswsLiysrqzs7ux0cnQcHhycnpzc3tw8Pjy8vrz8/vxcXlz///8AAAAG/kCfcEgsGoWt',
				'DatxbDqfUJ4LAHDwoNhsMwOiglTacJEjy3CMJhgVYjLWMJGc+Mg7AECxI45wwxg5A1Q3BnNFKmoAN1dGDUxGKlRUfoVDFShUK2dhJl1UNJRELBojC',
				'oUJFzAHmqCsQyY5i62ys7SsNbG1jDgBMkccNigacrljDlQwO4+dL8RFCp0ALkYGEFR5zUMq1VQHfyUDFo7YPhwWVCi9dONjOyVt6/Dx8vP09fZaDS',
				'm8QhIOD+LzGmhYQ6PFDGv2WEQCMKABCSoh7DFYqMPHjgEHKtircfBOgXtFTASwwAKkyZMoU6pcVyPGgx24KiVgEJNYhQWRUvwxBkIAZzwcC0msQqK',
				'DCgV4MRZeAChEgAcLLeCpuMQtpYARM17UUMkh6sqvrHhkeEepJiUKABCkE8PjQw+mlB5QKVGoxQQAGWblcHAArhAOZoXI2BB4DuAmFTTo0JhSBggQ',
				'pVLyYECjMNgwQQAAIfkECAYAAAAsAAAAADIAMgCFBAIEhIKEREJExMLEJCIk5OLkpKKkZGJkFBIU1NLUNDI09PL0tLK0dHJ0lJKUVFJUDAoMTEpMz',
				'MrMLCos7OrsrKqsbGpsHBoc3NrcPDo8/Pr8vLq8fHp8nJqcjIqMXFpcBAYEREZExMbEJCYk5ObkpKakZGZkFBYU1NbUNDY09Pb0tLa0dHZ0lJaUVF',
				'ZUDA4MTE5MzM7MLC4s7O7srK6sbG5sHB4c3N7cPD48/P78vL68fH58nJ6cjI6M////AAAABv5An3BILBqFuQQqd2w6n1Df7gUJRK9Y4wICALxU2fB',
				'QcyMdVbauTWPU6BgzsTFXAyBWxw0ONziaugJgckMFCF0wTRpsWl1dOoNDKhNdLGIqJ10gCZBDKDUeC3IMEyM9nKdEKnGorK2ur7A+OToVZkcMKQer',
				'sUgsIAAjN0YzaQAOvISYXVZFC5MAHchCJBeNpkYDLjuC0j1dCrbSUTcii+Ln6Onq6+ztRRorPLY3HAbm6SofXRcJOSFdeNYlaASghgYcXWiwi0HQg',
				'g8UB3pww/fPjgh3RBbw8IACo8ePIEOKdKWBAQ9hZzZsEqcCRpcXfYw0AHAiHK8NBCPMcdFlJV8yGgQzHMFgogUTaSRGNGoBEiKMDvc8Hh3JjkKJk6',
				'00TM1CQYaaGKhuyPgw8UoAgg+2iqJZQMyfRimiWuIRMAwDgjvOqThgoqwPDQFsXDARSlyBExcoNFGlTgJYqqyCAAAh+QQIBgAAACwAAAAAMgAyAIU',
				'EAgSEgoTEwsREQkQkIiSkoqTk4uRkYmQUEhSUkpTU0tQ0MjS0srT08vR0cnRUVlQMCgyMiozMyswsKiysqqzs6uxsamwcGhycmpzc2tw8Ojy8urz8',
				'+vxMSkx8enxcXlwEBgSEhoTExsRERkQkJiSkpqTk5uRkZmQUFhSUlpTU1tQ0NjS0trT09vRcWlwMDgyMjozMzswsLiysrqzs7uxsbmwcHhycnpzc3',
				'tw8Pjy8vrz8/vx8fnz///8AAAAAAAAG/sCecEgsGoW7jOHIbDqfQhgCVYBar0cUADDBeouNFnOwfRw5GQXne6SQcpmjwcGrHCMgQG3NHu5IWzVfHF',
				'oALzh9RGQAEV87MlsXNIlDJjwpYl8xIxoblJ+goaKjpKVNGSKZRhIuEXymQykvICMNRi0rW56wQjSAWzNGHIsivEItE1sALEcZHiU7xkIzLwAfqtJ',
				'OLRXR2d7f4OHi4+MKOpk0NwLjOzwQIBp2FgAIKuIVEMopPR8AEAriTOTZkqCHiRAMuoHjUGOLDBPkiHDQMWNSxIsYM2rcKGqHgg3Yiph4xYuDgy0k',
				'EBlhceEDSVMKBgJwcCQFgAUvS4mQeeBIaAsWKo01yLEFgo6MFULUEKCQo1NwLQQIsAiqKZYWHbZogPiJxoMQOZ/cUAbAAygFAGSExZECA1ciAch+q',
				'LoBoBEFF7bYCCpkp7IS0vopE1SEwgoZKcKOGkHWzMUEZG9gbOHAhg1Xn4IAACH5BAgGAAAALAAAAAAyADIAhQQCBISChMTCxERCRCQiJOTi5KSipG',
				'RiZBQSFJSSlNTS1DQyNPTy9LSytHRydFRSVAwKDIyKjMzKzCwqLOzq7GxqbBwaHJyanNza3Dw6PPz6/Ly6vExKTKyqrHx6fAQGBISGhMTGxERGRCQ',
				'mJOTm5KSmpGRmZBQWFJSWlNTW1DQ2NPT29LS2tHR2dFxaXAwODIyOjMzOzCwuLOzu7GxubBweHJyenNze3Dw+PPz+/Ly+vP///wAAAAAAAAAAAAAA',
				'AAb+wJ1wSCwahyvNcclsOoU6mUrxrFqPOADgce0WNcqjS9s65gqYsLcYwrkoR1IANjuWIB/P2jjQorwaWQAnDHtENAAfLGsVWipqhislApBWDCAtB',
				'YabnJ2en6ChXhQ3OUs3Hg2iRywWLxWVOzkPiZqrQxoqWgApRhpjLyS3Qzl9iTdHMwYSw0QSMhYwps1VOdPU2Nna29zd3sm2Oxopdd42CB8HKzsdHw',
				'PeDDW7OjslADjwFvPiCnDeKC8+uFj3jQiJFLEKKlzIsKHDTaQSCgGTLcEHABzKFYkxAQS2Aid22TiyQeC1Wzde7IpwRAOGQtQ0HNBSI1xBSReQPdy',
				'5JgVoihL+uoxD2ElHSAALNFar8ALCwE0ajGlJ0EXHLgAGNq2YcFVPkRksdMAkYuMqy02IdgkoQkKGFhxjhYDU8iIGpxkmLIxAcXKHh6t/NrpwQc8T',
				'A4JFZu7yWrDBRQAQQizUYCMDDlWcggAAIfkECAYAAAAsAAAAADIAMgCFBAIEhIKExMLEREJEpKKk5OLkJCIkZGJkFBIUlJKU1NLUVFJUtLK09PL0N',
				'DI0dHJ0DAoMjIqMzMrMTEpMrKqs7OrsHBocnJqc3NrcXFpcvLq8/Pr8PDo8fHp8LCosbGpsBAYEhIaExMbEREZEpKak5ObkJCYkZGZkFBYUlJaU1N',
				'bUVFZUtLa09Pb0NDY0dHZ0DA4MjI6MzM7MTE5MrK6s7O7sHB4cnJ6c3N7cXF5cvL68/P78PD48fH58////AAAABv5An3BILBqPyKRyeVSMFgWmdHr',
				'MAAAdqpbau96QrdYWicn0xMYWjbU5Chwe1th4uurGiytvXowBECpjL1cnfEQbMiVzDSkpDYaQkZKTlJWWSS2KSBsaOJdGKh4oL21GCQAupZ9CdVdR',
				'RjQWGTurQwFXCJpGJWi1PjUfM3K+xMXGx8jJystaO70+JY/KGgYwIbQSKB/KLRxXMBg+2dvJLS7f4dDPxxo21qrMPs7x9PX29587DB8hNcUb62xdA',
				'eDAXy0GKEA8WFfDxkAAFGrVMDHwDpEKKB5+WVXDwEAGRg4MtPFqVQgIAHhII1LjhYsFMorJ0BFwyAZ4+HJepCGgJmCTCiVoQVJBEcAKnEwi2LDQQe',
				'icHTkeDpuCYSAIEYY2jHh4IY0CDEh1PKQB6dQ3T0QaTAAA4gDOFkUN6JrTIoaLEQKM3HhokUiJEAHQ1ro1kAQ9GTCuWJi7TECODzEhBQEAIfkECAY',
				'AAAAsAAAAADIAMgCFBAIEhIaExMbEREJEpKak5ObkZGJkJCIkFBIUlJaU1NbUdHJ0VFJUvLq89Pb0NDI0DAoMjI6MzM7MrK6s7O7sbGpsHBocnJ6c',
				'3N7cfHp8XFpcTEpMLCosxMLE/P78PD48BAYEjIqMzMrMREZErKqs7OrsZGZkFBYUnJqc3NrcdHZ0VFZUvL68/Pr8NDY0DA4MlJKU1NLUtLK09PL0b',
				'G5sHB4cpKKk5OLkfH58XF5cLC4s////AAAAAAAAAAAAAAAABv7AnXBILBqPyKRyeSwYFhSmdHrEAQAXqpZKgCA6SEdrG740kJ6YApkafWJk4wRgKZ',
				'BV11y8mNJpHGQ2VyF7RS0ecS0sLGOFjo+QkZKTlHEeKVGVRTcbOhNIDSAaiJpDGVccgEYSHAGlRDBXH6pGja9CMwEVa7e9vr/AwcLDSy0JIyYpxEQ',
				'LVwA1dsEYIxYJHi/OACjCNFcIGAjZWcF4ACc3p1c1JcI3DDpZDigMNBjL9/j5+vuvEiEEtl4dQkICxBUGtDRJeFADBikiD7IJeOXhwxUQ9oh4OJCN',
				'hUAXF+EUiWAQwIdMpWSceEEjoJAWNjSoiHarBAaX/HJOmSEhBVtOKQ4S7ilh8UUGMhNccBhXyIozXjuxAXiRcU+FbGCKeChB4eGQAs5AiHAUCpXQF',
				'jReIHBlaMWVEUK3eGiQQ0XVIWUBQIA6xIGMCTN6EZCIrwRHk3HbJUDBzlEQACH5BAgGAAAALAAAAAAyADIAhQQCBISChMTCxERCROTi5CQiJKSipG',
				'RiZBQSFNTS1PTy9LSytHRydJSSlFRSVDQyNAwKDMzKzExKTOzq7KyqrGxqbBwaHNza3Pz6/Ly6vHx6fJyanDw6PIyKjCwqLFxaXAQGBISGhMTGxER',
				'GROTm5KSmpGRmZBQWFNTW1PT29LS2tHR2dJSWlDQ2NAwODMzOzExOTOzu7KyurGxubBweHNze3Pz+/Ly+vHx+fJyenDw+PCwuLFxeXP///wAAAAAA',
				'AAb+wJ5wSCwaj8ikcnnElBY2pnR6jIBAKKqWSmoNYknMFmm7ZZFiZOzwIYyNCdAuNd4AALh3MfYJRbciLiAyekV/bwQ1hYuMjY5DGGmPYzEMOyMCk',
				'2MHdwAnippEChUwEUYxJ50AG6FEBncDkkIpBaolrUMZdzyHQw2dLWC4PRgyLBNHNhkrHQrDz9DR0tPU1WQZMx3C1kMbIHcPztQkBwM3PQ+qGdU4dz',
				'sYHKqZ1O0ALSklEHc6dNQxKw4SCImAI0c/bggTKlzIUBqJEgJ6DZNFJAKCOyskaopRYYAMij0+dEIACleAOy5IGHHQCcIZXAzugCg5RIWLOx9ATrr',
				'w4IRoBp0RAhiMhmFbw6NvMNRQuTAFDwQWWG15MULHuUUlWhplYsPDHRpbt7BQ5caIgoNEMFwE4KKsngsW7ozQyKKAh1tGQnyr0OhCiBziiNS4CQBB',
				'WAwoEuicZEWmW24YJOxiqGCBCrRvggAAIfkECAYAAAAsAAAAADIAMgCFBAIEhIaEREJExMbEJCIkrKqsZGJk5ObkFBIUlJaU1NbUNDI0dHJ0VFJUv',
				'Lq89Pb0DAoMjI6MTEpMzM7MLCostLK0bGps7O7sHBocnJ6c3N7cPDo8fHp8XFpcxMLE/P78BAYEjIqMREZEzMrMJCYkrK6sZGZk7OrsFBYUnJqc3N',
				'rcNDY0dHZ0vL68/Pr8DA4MlJKUTE5M1NLULC4stLa0bG5s9PL0HB4cpKKk5OLkPD48fH58XF5c////AAAAAAAABv7AnnBILBqPyKRyiRxNmFDm5YH',
				'MoW6nqLZ4MWEIEZfxYTBRt2gWYA2ooD+l1Bk9dC3YgBpagwC06EQuInghaDYNKzmARAMYawsXdB9ii0QaKTiRlZucmx+dnC4JMQYqoIshbBRZp0Yu',
				'ERamRjN4NK1GI2sdRzp4HrdFGi8AO0cOEGsNc8BCMi3Llik0lMzV1tfY2drbnDIBODbcRy19ADHU2g8BpT08eAriBWsiPQZ4stslIAANPROOAHh84',
				'vYAxw5FPQ4UaIFOnMOHECNKnNjjwQANFA9QWAMD2wMODUYcCcAGyzUYa2ZA68GBDYYD11IBIBGuiIobAEAUu3ahw2UKB0gO4PAwkKLRo0xs1JwYgM',
				'AMoGguBKiBb9EIZAAwNGRSI+XWLTTYgFjZw8XXD4MAoGC1yMaGNXqMONAh4JeREsNYdLpQguEYgASK1jmg4WurC8MAvCDLjQMECAEoulCgQDCgIAA7'
				].join(''));
				preload.setAttribute('alt', 'Requesting GEO label...');
				preload.style.cssText = 'position: absolute; top: 50%; left: 50%; margin-left: -25px; margin-top: -25px;';
				container.appendChild(preload);
			}

			xhr.onload = function() {
				var json = JSON.parse(xhr.responseText);

				if (xhr.status === 500 || json.status === "error") {
					container.innerHTML = "Error: " + json.message;
				}
				else if (xhr.status === 200) {
					container.innerHTML = json.data.label_svg;
					if (sessionStorage) {
						sessionStorage.setItem('geolabel', json.data.label_svg);
					}
				}
			};

			xhr.onerror = function() {
				container.innerHTML = "No GEO label available (could not connect to the GEO label proxy service)";
			};

			xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
			xhr.setRequestHeader("Content-length", params.length);
			xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
			xhr.send(params);
		}

		var container = document.getElementById('xhr_geolabel');

		if (sessionStorage && sessionStorage.getItem('geolabel')) {
			container.innerHTML = sessionStorage.getItem('geolabel');
		}
		else {
			requestGEOlabel();
		}
		]]>
		</script>
	</xsl:template>
</xsl:stylesheet>
