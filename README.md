## About ##

A plugin which enables the creation, editing and cataloguing of metadata that uses the [GeoViQua 4.0 schema][3], within a standard [GeoNetwork v2.10.2][4] installation. 

## Installation ##

[Download the latest zip archive][2] of the metadata schema plugin and upload it through the [GeoNetwork administration interface][1]. It is crucial that the plugin name given is **iso19139.geoviqua**.

To install the schema plugin manually, the zip archive must be extracted to GeoNetwork's schema directory (by default this is `INSTALL_DIR/web/geonetwork/WEB-INF/data/config/schema_plugins`) and into a folder named **iso19139.geoviqua**.

Alternatively, you could clone the repo directly via Git:

	cd INSTALL_DIR/web/geonetwork/WEB-INF/data/config/schema_plugins
	git clone https://github.com/GeoViQua/geoviqua-geonetwork-plugin.git iso19139.geoviqua

## Configuration ##

After installing the schema plugin, some additional configuration is required so that the plugin functions optimally. Please follow the steps below.

Remember to restart GeoNetwork after making changes to the files below.

### 1. Enable Metadata Export Services ###

Additional metadata conversion services must be exposed so that, at a minimum, users can download GeoViQua metadata records directly from the GeoNetwork catalog as XML. `schema-conversions.xml` lists the available converters provided by this plugin.

To enable the export of GeoViQua documents, edit `INSTALL_DIR/web/geonetwork/WEB-INF/config-export.xml` to register the xml_geoviqua converter:
```xml
<geonet>
	<services package="org.fao.geonet">

		...

		<service name="xml_geoviqua">
			<class name=".services.metadata.Convert" />
			<error id="operation-not-allowed" sheet="error-embedded.xsl" statusCode="403">
				<xml name="error" file="xml/privileges-error.xml" />
			</error>
		</service>

		...

    </services>
</geonet>
```

Then edit `INSTALL_DIR/web/geonetwork/WEB-INF/user-profiles.xml` to enable user groups to use the xml_geoviqua converter:
```xml
<profiles>

	...

	<profile name="Guest">

		...

		<!-- Metadata export services -->
		<allow service="xml_geoviqua"/>

		...

	</profile>

	...

</profiles>
```

Users will then have the option to export GeoViQua documents as XML when viewing search results or individual metadata records, providing their user group has publish privileges enabled for the metadata record in question.
For anonymous users and web services, the publish privilege should be enabled for the "All" group.

### 2. Evaluate JavaScript In Search Results ###

The schema plugin's presentation XSLT includes some JavaScript that embeds a GEO Label directly into the metadata view. However, when viewing iso19139.geoviqua metadata records returned from a search result inline, the JavaScript won't be evaluated by the browser as the page has already finished loading and so the GEO label won't be displayed as expected.

To work around this, edit `INSTALL_DIR/web/geonetwork/scripts/lib/gn.search.js` and paste the following snippet at the beginning of line 276:
```javascript
Ext.select('#mdwhiteboard_' + e + ' script', true).each(function(el){
    eval(el.dom.innerHTML);
});
```
Note: eval is dangerous and if any other schema plugins you have installed contain malicious JavaScript in the presentation XSLT then the above code will execute it! Only do this if you're sure.


[1]: http://geonetwork-opensource.org/manuals/2.10.2/eng/users/managing_metadata/schemas/index.html
[2]: https://github.com/GeoViQua/geoviqua-geonetwork-plugin/archive/master.zip
[3]: http://schemas.geoviqua.org/GVQ/4.0/
[4]: http://www.geonetwork-opensource.org/
[5]: http://geonetwork-opensource.org/manuals/2.10.2/eng/users/admin/configuration/index.html
