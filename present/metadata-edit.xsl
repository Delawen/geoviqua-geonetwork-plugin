<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gts="http://www.isotc211.org/2005/gts"
  xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gmx="http://www.isotc211.org/2005/gmx"
  xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:gml="http://www.opengis.net/gml"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:geonet="http://www.fao.org/geonetwork"
  xmlns:exslt="http://exslt.org/common"
  xmlns:gvq="http://www.geoviqua.org/QualityInformationModel/4.0"
  exclude-result-prefixes="gmd gco gml gts srv xlink exslt geonet">

  <xsl:import href="metadata-utils.xsl"/>

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
      <xsl:with-param name="action" select="concat('Ext.getCmp(', $apos, 'editorPanel', $apos, 
        ').showFileUploadPanel(', //geonet:info/id, ', ', $apos, gmx:FileName/geonet:element/@ref, $apos, ');')"/>
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
      <xsl:with-param name="action" select="concat('Ext.getCmp(', $apos ,'editorPanel', $apos, ').showLogoSelectionPanel(', $apos, '_', 
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
    <xsl:param name="label" select="/root/gui/strings/file"/>
    
    
    <xsl:apply-templates mode="complexElement" select=".">
      <xsl:with-param name="schema"   select="$schema"/>
      <xsl:with-param name="edit"     select="$edit"/>
      <xsl:with-param name="content">
        
        <xsl:choose>
          <xsl:when test="$edit">
            <xsl:variable name="id" select="generate-id(.)"/>
            <xsl:variable name="isXLinked" select="count(ancestor-or-self::node()[@xlink:href]) > 0" />
            
            <div id="{$id}"/>
            
            <xsl:call-template name="simpleElementGui">
              <xsl:with-param name="schema" select="$schema"/>
              <xsl:with-param name="edit" select="$edit"/>
              <xsl:with-param name="title" select="$label"/>
              <xsl:with-param name="text">
                <xsl:if test="$visible">
                  <input id="_{$ref}_src" class="md" type="text" name="_{$ref}_src" value="{$src}" size="40">
                    <xsl:if test="$isXLinked"><xsl:attribute name="disabled">disabled</xsl:attribute></xsl:if>
                  </input>
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
                <input id="_{$ref}" class="md" type="text" name="_{$ref}" value="{$value}" size="40" >
                  <xsl:if test="$isXLinked"><xsl:attribute name="disabled">disabled</xsl:attribute></xsl:if>
                </input>
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
                  <div class="logo-wrap"><img class="logo" src="{gmx:FileName/@src}"/></div>
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

  <!-- Simple views is ISO19139 -->
  <xsl:template name="metadata-iso19139.gvqview-simple">
    <xsl:call-template name="metadata-iso19139view-simple"/>
  </xsl:template>

  <xsl:template name="view-with-header-iso19139.gvq">
    <xsl:param name="tabs"/>

    <xsl:call-template name="view-with-header-iso19139">
      <xsl:with-param name="tabs" select="$tabs"/>
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





  <!-- Tab configuration -->
  <xsl:template name="iso19139.gvqCompleteTab">
    <xsl:param name="tabLink"/>
    <xsl:param name="schema"/>

    <!-- Add custom tab if a custom view is needed -->
    <!--<xsl:call-template name="mainTab">
      <xsl:with-param name="title" select="/root/gui/schemas/*[name()=$schema]/strings/gvqTab"/>
      <xsl:with-param name="default">gvqTabDiscovery</xsl:with-param>
      <xsl:with-param name="menu">
        <item label="gvqTabDiscovery">gvqTabDiscovery</item>
        ...
      </xsl:with-param>
    </xsl:call-template>
    -->


    <!-- Preserve iso19139 complete tabs -->
    <xsl:call-template name="iso19139CompleteTab">
      <xsl:with-param name="tabLink" select="$tabLink"/>
      <xsl:with-param name="schema" select="$schema"/>
    </xsl:call-template>
  </xsl:template>



  <!-- Based template for dispatching each tabs -->
  <xsl:template mode="iso19139.gvq" match="gvq:GVQ_Metadata|*[@gco:isoType='gvq:GVQ_Metadata']"
    priority="3">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    <xsl:param name="embedded"/>

    <xsl:variable name="dataset"
      select="gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='dataset' or normalize-space(gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue)=''"/>
    <xsl:choose>

      <!-- metadata tab -->
      <xsl:when test="$currTab='metadata'">
        <xsl:call-template name="iso19139Metadata">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:call-template>
      </xsl:when>

      <!-- identification tab -->
      <xsl:when test="$currTab='identification'">
        <xsl:apply-templates mode="elementEP"
          select="gmd:identificationInfo|geonet:child[string(@name)='identificationInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- maintenance tab -->
      <xsl:when test="$currTab='maintenance'">
        <xsl:apply-templates mode="elementEP"
          select="gmd:metadataMaintenance|geonet:child[string(@name)='metadataMaintenance']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- constraints tab -->
      <xsl:when test="$currTab='constraints'">
        <xsl:apply-templates mode="elementEP"
          select="gmd:metadataConstraints|geonet:child[string(@name)='metadataConstraints']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- spatial tab -->
      <xsl:when test="$currTab='spatial'">
        <xsl:apply-templates mode="elementEP"
          select="gmd:spatialRepresentationInfo|geonet:child[string(@name)='spatialRepresentationInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- refSys tab -->
      <xsl:when test="$currTab='refSys'">
        <xsl:apply-templates mode="elementEP"
          select="gmd:referenceSystemInfo|geonet:child[string(@name)='referenceSystemInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- distribution tab -->
      <xsl:when test="$currTab='distribution'">
        <xsl:apply-templates mode="elementEP"
          select="gmd:distributionInfo|geonet:child[string(@name)='distributionInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- embedded distribution tab -->
      <xsl:when test="$currTab='distribution2'">
        <xsl:apply-templates mode="elementEP"
          select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- dataQuality tab -->
      <xsl:when test="$currTab='dataQuality'">
        <xsl:apply-templates mode="elementEP"
          select="gmd:dataQualityInfo|geonet:child[string(@name)='dataQualityInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- appSchInfo tab -->
      <xsl:when test="$currTab='appSchInfo'">
        <xsl:apply-templates mode="elementEP"
          select="gmd:applicationSchemaInfo|geonet:child[string(@name)='applicationSchemaInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- porCatInfo tab -->
      <xsl:when test="$currTab='porCatInfo'">
        <xsl:apply-templates mode="elementEP"
          select="gmd:portrayalCatalogueInfo|geonet:child[string(@name)='portrayalCatalogueInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- contentInfo tab -->
      <xsl:when test="$currTab='contentInfo'">
        <xsl:apply-templates mode="elementEP"
          select="gmd:contentInfo|geonet:child[string(@name)='contentInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- extensionInfo tab -->
      <xsl:when test="$currTab='extensionInfo'">
        <xsl:apply-templates mode="elementEP"
          select="gmd:metadataExtensionInfo|geonet:child[string(@name)='metadataExtensionInfo']">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:apply-templates>
      </xsl:when>

      <!-- ISOMinimum tab -->
      <xsl:when test="$currTab='ISOMinimum'">
        <xsl:call-template name="isotabs">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
          <xsl:with-param name="dataset" select="$dataset"/>
          <xsl:with-param name="core" select="false()"/>
        </xsl:call-template>
      </xsl:when>

      <!-- ISOCore tab -->
      <xsl:when test="$currTab='ISOCore'">
        <xsl:call-template name="isotabs">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
          <xsl:with-param name="dataset" select="$dataset"/>
          <xsl:with-param name="core" select="true()"/>
        </xsl:call-template>
      </xsl:when>

      <!-- ISOAll tab -->
      <xsl:when test="$currTab='ISOAll'">
        <xsl:call-template name="iso19139Complete">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
        </xsl:call-template>
      </xsl:when>

      <!-- INSPIRE tab -->
      <xsl:when test="$currTab='inspire'">
        <xsl:call-template name="inspiretabs">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
          <xsl:with-param name="dataset" select="$dataset"/>
        </xsl:call-template>
      </xsl:when>
      <!--
        Register your custom tabs here and create the related template
        <xsl:when test="$currTab='gvqTabDiscovery'">
        <xsl:call-template name="gvqTabDiscovery">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
          <xsl:with-param name="dataset" select="$dataset"/>
        </xsl:call-template>
      </xsl:when>-->
      <!-- default -->
      <xsl:otherwise>
        <xsl:call-template name="iso19139Simple">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit" select="$edit"/>
          <xsl:with-param name="flat"
            select="/root/gui/config/metadata-tab/*[name(.)=$currTab]/@flat"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- Custom tab -->
  <!--<xsl:template name="gvqTabDiscovery">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    <xsl:param name="dataset"/>
    <xsl:param name="core"/>
    
    <!-\- Do something ... -\->
  </xsl:template>
-->
</xsl:stylesheet>
