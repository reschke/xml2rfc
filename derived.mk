rfc2629-no-doctype.xslt: rfcxml.xslt
	fgrep -v "<xsl:output method=\"html\" encoding=\"utf-8\" doctype-system=\"about:legacy-compat\" indent=\"no\"/>" $< > $@

