<!--
    Transform rfc2629.xslt (HTML) to rfc2629toXHTML.xslt

    Copyright (c) 2006-2020, Julian Reschke (julian.reschke@greenbytes.de)
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimer in the documentation
      and/or other materials provided with the distribution.
    * Neither the name of Julian Reschke nor the names of its contributors
      may be used to endorse or promote products derived from this software
      without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
    AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
    IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
    ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
    LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
    CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
    SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
    INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
    CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
-->

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:myns="mailto:julian.reschke@greenbytes.de?subject=rfc2629.xslt">

<xsl:output method="xml" encoding="UTF-8"/>

<xsl:param name="src" />

<!-- rewrite xsl:output -->
<xsl:template match="xsl:output">
  <xsl:copy>
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