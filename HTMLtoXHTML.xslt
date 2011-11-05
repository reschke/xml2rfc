<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:myns="mailto:julian.reschke@greenbytes.de?subject=rcf2629.xslt">

<xsl:output method="xml" encoding="ISO-8859-1"/>

<xsl:param name="src" />

<!-- rewrite xsl:output -->
<xsl:template match="xsl:output">
  <xsl:copy>
    <xsl:attribute name="doctype-public">-//W3C//DTD XHTML 1.0 Strict//EN</xsl:attribute>
    <xsl:attribute name="doctype-system">http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd</xsl:attribute>
    <xsl:attribute name="encoding">UTF-8</xsl:attribute>
    <xsl:attribute name="method">xml</xsl:attribute>
  </xsl:copy>
</xsl:template>

<!-- rewrite xsl:param outputExtension -->
<xsl:template match="xsl:param[@name='outputExtension']">
  <xsl:copy>
    <xsl:attribute name="name">outputExtension</xsl:attribute>
    <xsl:attribute name="select">'xhtml'</xsl:attribute>
  </xsl:copy>
</xsl:template>

<!-- kick HTML elements into XHTML namespace -->
<xsl:template match="*[namespace-uri()='' and not(ancestor-or-self::*/@myns:namespaceless-elements='xml2rfc')]">
  <xsl:element name="{local-name()}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:apply-templates select="@*" mode="xhtml" />
    <xsl:apply-templates select="node()" />
  </xsl:element>
</xsl:template>

<xsl:template match="@*" mode="xhtml">
  <xsl:copy-of select="."/>
</xsl:template>

<!-- rewrite lang attribute -->
<xsl:template match="@lang" mode="xhtml">
  <xsl:attribute name="xml:lang">
    <xsl:value-of select="."/>
  </xsl:attribute>
</xsl:template>

<!-- rewrite xsl:element elements -->
<xsl:template match="xsl:element">
  <xsl:copy>
    <xsl:attribute name="namespace">http://www.w3.org/1999/xhtml</xsl:attribute>
    <xsl:apply-templates select="node()|@*" />
  </xsl:copy>
</xsl:template>


<!-- rewrite document element -->
<xsl:template match="/">
  <xsl:copy>
    <xsl:text>&#10;</xsl:text>
    <xsl:comment>Auto-generated from <xsl:value-of select="$src" /> through HTMLtoXHTML.xslt</xsl:comment>
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates select="*|processing-instruction()" />
  </xsl:copy>
</xsl:template>


<!-- rules for identity transformations -->

<xsl:template match="node()|@*"><xsl:copy><xsl:apply-templates select="node()|@*" /></xsl:copy></xsl:template>

</xsl:transform>