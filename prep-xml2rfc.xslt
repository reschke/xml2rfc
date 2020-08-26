<!--
    Experimental implementation of xml2rfc v3 preptool

    Copyright (c) 2016-2020, Julian Reschke (julian.reschke@greenbytes.de)
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
               version="2.0"
               xmlns:f="mailto:julian.reschke@greenbytes?subject=preptool"
               xmlns:xlink="http://www.w3.org/1999/xlink"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:pi="https://www.w3.org/TR/REC-xml/#sec-pi"
               xmlns:svg="http://www.w3.org/2000/svg"
               exclude-result-prefixes="f pi svg xlink xs"
>

<xsl:import href="rfc2629.xslt" />

<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" doctype-system=""/>

<xsl:param name="skip-steps" select="''"/>
<xsl:param name="mode">
  <xsl:choose>
    <xsl:when test="/rfc/@number">rfc</xsl:when>
    <xsl:otherwise>id</xsl:otherwise>
  </xsl:choose>
</xsl:param>
<xsl:param name="steps">
  <!-- note that boilerplate currently needs to run first, so that the templates can access "/" -->
  <xsl:text>pi xinclude rfc2629ext figextract artset artwork references cleansvg listdefaultstyle listextract lists listextract lists listextract lists tables removeinrfc boilerplate deprecation defaults normalization slug derivedcontent pn scripts idcheck preprocesssvg sanitizesvg preptime</xsl:text>
  <xsl:if test="$mode='rfc'"> rfccleanup</xsl:if>
</xsl:param>
<xsl:variable name="rfcnumber" select="/rfc/@number"/>

<xsl:template match="/">
  <xsl:variable name="n" select="f:apply-steps($steps,.)"/>
  <xsl:apply-templates select="$n" mode="prep-ser"/>
</xsl:template>

<xsl:function name="f:apply-steps">
  <xsl:param name="steps"/>
  <xsl:param name="nodes"/>
  <xsl:variable name="s" select="normalize-space($steps)"/>
  <xsl:choose>
    <xsl:when test="contains($s,' ')">
      <xsl:variable name="n" select="f:apply-steps(substring-before($s,' '), $nodes)"/>
      <xsl:sequence select="f:apply-steps(substring-after($s,' '), $n)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="contains(concat(' ',$skip-steps,' '),concat(' ',$s,' '))">
          <xsl:copy-of select="$nodes"/>
        </xsl:when>
        <xsl:when test="$s='artset'"> 
          <xsl:message>Step: artset</xsl:message>
          <xsl:apply-templates select="$nodes" mode="prep-artset"/>
        </xsl:when>
        <xsl:when test="$s='artwork'"> 
          <xsl:message>Step: artwork</xsl:message>
          <xsl:apply-templates select="$nodes" mode="prep-artwork"/>
        </xsl:when>
        <xsl:when test="$s='boilerplate'"> 
          <xsl:message>Step: boilerplate</xsl:message>
          <xsl:apply-templates select="$nodes" mode="prep-boilerplate"/>
        </xsl:when>
        <xsl:when test="$s='cleansvg'"> 
          <xsl:message>Step: cleansvg</xsl:message>
          <xsl:apply-templates select="$nodes" mode="prep-cleansvg"/>
        </xsl:when>
        <xsl:when test="$s='defaults'">
          <xsl:message>Step: defaults</xsl:message>
          <xsl:apply-templates select="$nodes" mode="prep-defaults"/>
        </xsl:when>
        <xsl:when test="$s='deprecation'">
          <xsl:message>Step: deprecation</xsl:message>
          <xsl:apply-templates select="$nodes" mode="prep-deprecation"/>
        </xsl:when>
        <xsl:when test="$s='derivedcontent'">
          <xsl:message>Step: derivedcontent</xsl:message>
          <xsl:apply-templates select="$nodes" mode="prep-derivedcontent"/>
        </xsl:when>
        <xsl:when test="$s='figextract'">
          <xsl:message>Step: figextract</xsl:message>
          <xsl:apply-templates select="$nodes" mode="prep-figextract"/>
        </xsl:when>
        <xsl:when test="$s='idcheck'">
          <xsl:message>Step: idcheck</xsl:message>
          <xsl:apply-templates select="$nodes" mode="prep-idcheck"/>
        </xsl:when>
        <xsl:when test="$s='listdefaultstyle'">
          <xsl:message>Step: listdefaultstyleract</xsl:message>
          <xsl:apply-templates select="$nodes" mode="prep-listdefaultstyle"/>
        </xsl:when>
        <xsl:when test="$s='listextract'">
          <xsl:message>Step: listextract</xsl:message>
          <xsl:apply-templates select="$nodes" mode="prep-listextract"/>
        </xsl:when>
        <xsl:when test="$s='lists'">
          <xsl:message>Step: lists</xsl:message>
          <xsl:apply-templates select="$nodes" mode="prep-lists"/>
        </xsl:when>
        <xsl:when test="$s='normalization'">
          <xsl:message>Step: normalization</xsl:message>
          <xsl:apply-templates select="$nodes" mode="prep-normalization"/>
        </xsl:when>
        <xsl:when test="$s='pi'">
          <xsl:message>Step: pi</xsl:message>
          <xsl:apply-templates select="$nodes" mode="prep-pi"/>
        </xsl:when>
        <xsl:when test="$s='pn'">
          <xsl:message>Step: pn</xsl:message>
          <xsl:apply-templates select="$nodes" mode="prep-pn"/>
        </xsl:when>
        <xsl:when test="$s='preprocesssvg'">
          <xsl:message>Step: preprocesssvg</xsl:message>
          <xsl:apply-templates select="$nodes" mode="prep-preprocesssvg"/>
        </xsl:when>
        <xsl:when test="$s='preptime'">
          <xsl:message>Step: preptime</xsl:message>
          <xsl:apply-templates select="$nodes" mode="prep-preptime"/>
        </xsl:when>
        <xsl:when test="$s='references'">
          <xsl:message>Step: references</xsl:message>
          <xsl:apply-templates select="$nodes" mode="prep-references"/>
        </xsl:when>
        <xsl:when test="$s='removeinrfc'">
          <xsl:message>Step: removeinrfc</xsl:message>
          <xsl:apply-templates select="$nodes" mode="prep-removeinrfc"/>
        </xsl:when>
        <xsl:when test="$s='rfc2629ext'"> 
          <xsl:message>Step: rfc2629ext</xsl:message>
          <xsl:apply-templates select="$nodes" mode="prep-rfc2629ext"/>
        </xsl:when>
        <xsl:when test="$s='rfccleanup'">
          <xsl:message>Step: rfccleanup</xsl:message>
          <xsl:apply-templates select="$nodes" mode="prep-rfccleanup"/>
        </xsl:when>
        <xsl:when test="$s='sanitizesvg'">
          <xsl:message>Step: sanitizesvg</xsl:message>
          <xsl:apply-templates select="$nodes" mode="prep-sanitizesvg"/>
        </xsl:when>
        <xsl:when test="$s='scripts'">
          <xsl:message>Step: scripts</xsl:message>
          <xsl:apply-templates select="$nodes" mode="prep-scripts">
            <xsl:with-param name="root" select="$nodes"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:when test="$s='slug'">
          <xsl:message>Step: slug</xsl:message>
          <xsl:apply-templates select="$nodes" mode="prep-slug">
            <xsl:with-param name="root" select="$nodes"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:when test="$s='tables'">
          <xsl:message>Step: tables</xsl:message>
          <xsl:apply-templates select="$nodes" mode="prep-tables"/>
        </xsl:when>
        <xsl:when test="$s='xinclude'">
          <xsl:message>Step: xinclude</xsl:message>
          <xsl:apply-templates select="$nodes" mode="prep-xinclude"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="error">
            <xsl:with-param name="inline" select="'no'"/>
            <xsl:with-param name="msg" select="concat('unknown processing step: ',$s)"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>


<!-- artset step -->

<xsl:template match="node()|@*" mode="prep-artset">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="prep-artset"/></xsl:copy>
</xsl:template>

<!-- anchor handling for artset -->
<xsl:template match="artset/artwork/@anchor" mode="prep-artset"/>
<xsl:template match="artset" mode="prep-artset">
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="prep-artset"/>
    <xsl:variable name="anchored-artwork" select="artwork[@anchor]"/>
    <xsl:if test="not(@anchor) and $anchored-artwork">
      <xsl:copy-of select="$anchored-artwork[1]/@anchor"/>
    </xsl:if>
    <xsl:apply-templates select="node()" mode="prep-artset"/>
  </xsl:copy>
</xsl:template>

<!-- xref to artwork inside artset -->
<xsl:template match="@target" mode="prep-artset">
  <xsl:variable name="r" select="ancestor::rfc[1]"/>
  <xsl:variable name="tn" select="$r//*[@anchor=current()]"/>
  <!--<xsl:message>link to <xsl:value-of select="local-name($tn)"/></xsl:message>-->
  <xsl:choose>
    <xsl:when test="$tn/self::artwork and $tn/parent::artset and $tn/../@anchor">
      <xsl:attribute name="target">
        <xsl:value-of select="$tn/../@anchor"/>
      </xsl:attribute>
    </xsl:when>
    <xsl:when test="$tn/self::artwork and $tn/parent::artset">
      <xsl:attribute name="target">
        <xsl:value-of select="$tn/../artwork[@anchor][1]/@anchor"/>
      </xsl:attribute>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="."/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- artwork step -->

<xsl:template match="node()|@*" mode="prep-artwork">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="prep-artwork"/></xsl:copy>
</xsl:template>

<xsl:template match="artwork[@src and (@type='svg' or @type='image/svg+xml')]|artwork[svg:svg]" mode="prep-artwork">
  <xsl:variable name="alt" select="@alt"/>
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="prep-artwork"/>
    <xsl:if test="@type">
      <!-- rewrites image/svg+xml to svg -->
      <xsl:attribute name="type">svg</xsl:attribute>
    </xsl:if>
    <xsl:if test="@src">
      <xsl:attribute name="originalSrc" select="@src"/>
    </xsl:if>
    <xsl:variable name="svg">
      <xsl:choose>
        <xsl:when test="@src">
          <xsl:copy-of select="document(@src)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="svg:svg"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:for-each select="$svg/*">
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:if test="$alt!='' and not(svg:desc)">
          <desc xmlns="http://www.w3.org/2000/svg"><xsl:value-of select="$alt"/></desc>
        </xsl:if>
        <xsl:copy-of select="node()"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:choose>
      <xsl:when test="svg:svg">
        <xsl:if test="*[not(self::svg:svg or self::pi:*)]">
          <xsl:message terminate="yes">FATAL: can't have non-svg child elements in artwork when one svg child is present.</xsl:message>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="*[not(self::pi:*)]">
          <xsl:message terminate="yes">FATAL: can't have child elements in artwork when @type='svg' and @src is present.</xsl:message>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:copy>
</xsl:template>
<xsl:template match="artwork[@src and (@type='svg' or @type='image/svg+xml')]/@src" mode="prep-artwork"/>
<xsl:template match="artwork[@src and (@type='svg' or @type='image/svg+xml')]/@type" mode="prep-artwork"/>
<xsl:template match="artwork[@src and (@type='svg' or @type='image/svg+xml')]/@originalSrc" mode="prep-artwork"/>
<xsl:template match="artwork/svg:svg" mode="prep-artwork"/>

<!-- boilerplate step -->

<xsl:template match="rfc/front/boilerplate" mode="prep-boilerplate">
  <xsl:call-template name="info">
    <xsl:with-param name="msg">removing existing boilerplate element</xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="rfc/front" mode="prep-boilerplate">
  <xsl:copy>
    <xsl:apply-templates select="node()|@*" mode="prep-boilerplate"/>
    <xsl:for-each select="..">
      <xsl:call-template name="insertPreamble"/>
    </xsl:for-each>
  </xsl:copy>
</xsl:template>

<xsl:template match="node()|@*" mode="prep-boilerplate">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="prep-boilerplate"/></xsl:copy>
</xsl:template>

<!-- cleansvg step -->

<xsl:template match="node()|@*" mode="prep-cleansvg">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="prep-cleansvg"/></xsl:copy>
</xsl:template>

<xsl:template match="svg:*/@xlink:actuate[.='onRequest']" mode="prep-cleansvg"/>
<xsl:template match="svg:*/@xlink:show[.='replace']" mode="prep-cleansvg"/>
<xsl:template match="svg:*/@xlink:type[.='simple']" mode="prep-cleansvg"/>

<!-- defaults step -->

<xsl:template match="node()|@*" mode="prep-defaults">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="prep-defaults"/></xsl:copy>
</xsl:template>

<xsl:template match="ol" mode="prep-defaults">
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="prep-defaults"/>
    <xsl:if test="not(@start) and @group">
      <xsl:attribute name="start">
        <xsl:call-template name="ol-start">
          <xsl:with-param name="node" select="."/>
        </xsl:call-template>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="node()" mode="prep-defaults"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="relref" mode="prep-defaults">
  <xsl:copy>
    <xsl:if test="not(@displayFormat)">
      <xsl:attribute name="displayFormat">of</xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="@*" mode="prep-defaults"/>
    <xsl:apply-templates select="node()" mode="prep-defaults"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="rfc" mode="prep-defaults">
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="prep-defaults"/>
    <xsl:choose>
      <xsl:when test="not(@version)">
        <xsl:attribute name="version">3</xsl:attribute>
      </xsl:when>
      <xsl:when test="@version!='3'">
        <xsl:call-template name="error">
          <xsl:with-param name="msg" select="'/rfc/@version, when specified, should be 3'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
    <xsl:apply-templates select="node()" mode="prep-defaults"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="section" mode="prep-defaults">
  <xsl:copy>
    <xsl:apply-templates select="@*[not(local-name()='toc')]" mode="prep-defaults"/>
    <xsl:variable name="t">
      <xsl:choose>
        <xsl:when test="ancestor::boilerplate">exclude</xsl:when>
        <xsl:when test=".//section[@toc='include']">
            <xsl:if test="@toc='exclude'">
              <xsl:call-template name="error">
                <xsl:with-param name="msg" select="'section excluded from toc has descendant that his included'"/>
              </xsl:call-template>
            </xsl:if>
            <xsl:text>include</xsl:text>
          </xsl:when>
        <xsl:when test="ancestor::section[@toc='exclude']">exclude</xsl:when>
        <xsl:when test="count(ancestor::section) > $parsedTocDepth">exclude</xsl:when>
        <xsl:otherwise>include</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:attribute name="toc" select="$t"/>
    <xsl:apply-templates select="node()" mode="prep-defaults"/>
  </xsl:copy>
</xsl:template>

<!-- deprecation step -->

<xsl:template match="node()|@*" mode="prep-deprecation">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="prep-deprecation"/></xsl:copy>
</xsl:template>

<xsl:template match="pi:rfc[@name='sortrefs']" mode="prep-deprecation"/>
<xsl:template match="pi:rfc[@name='symrefs']" mode="prep-deprecation"/>
<xsl:template match="pi:rfc[@name='toc']" mode="prep-deprecation"/>
<xsl:template match="pi:rfc[@name='tocdepth']" mode="prep-deprecation"/>
<xsl:template match="pi:rfc-ext[@name='include-index']" mode="prep-deprecation"/>

<xsl:template match="xref/@pageno" mode="prep-deprecation">
  <xsl:call-template name="info">
    <xsl:with-param name="msg" select="'pageno attribute removed'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="artwork/@xml:space" mode="prep-deprecation">
  <xsl:call-template name="info">
    <xsl:with-param name="msg" select="'xml:space attribute removed from artwork element'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="figure/@align" mode="prep-deprecation">
  <xsl:call-template name="info">
    <xsl:with-param name="msg" select="'align attribute removed from figure element'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="figure/@alt" mode="prep-deprecation">
  <xsl:call-template name="info">
    <xsl:with-param name="msg" select="'alt attribute removed from figure element'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="figure/preamble|figure/postamble" mode="prep-deprecation">
  <!-- converted elsewhere to t elements -->
</xsl:template>

<xsl:template match="figure" mode="prep-deprecation">
  <xsl:for-each select="preamble">
    <t>
      <xsl:apply-templates select="node()" mode="prep-deprecation"/>
    </t>
  </xsl:for-each>
  <xsl:copy>
    <xsl:apply-templates select="@*|node()" mode="prep-deprecation"/>
  </xsl:copy>
  <xsl:for-each select="postamble">
    <t>
      <xsl:apply-templates select="node()" mode="prep-deprecation"/>
    </t>
  </xsl:for-each>
</xsl:template>

<xsl:template match="facsimile" mode="prep-deprecation">
  <xsl:call-template name="info">
    <xsl:with-param name="msg" select="concat('&lt;facsimile&gt; element removed from reference ', ../../../../@anchor)"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="format" mode="prep-deprecation">
  <xsl:call-template name="info">
    <xsl:with-param name="msg" select="concat('&lt;format&gt; element removed from reference ', ../@anchor, ' - use target attribute on &lt;reference&gt; to provide a single URI')"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="reference" mode="prep-deprecation">
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="prep-deprecation"/>
    <xsl:apply-templates select="node() except seriesInfo" mode="prep-deprecation"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="reference/front" mode="prep-deprecation">
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="prep-deprecation"/>
    <xsl:apply-templates select="title" mode="prep-deprecation"/>
    <xsl:choose>
      <xsl:when test="seriesInfo and ../seriesInfo">
        <xsl:call-template name="warning">
          <xsl:with-param name="msg" select="'seriesInfo present both under reference and reference/front, ignoring the former'"/>
        </xsl:call-template>
        <xsl:apply-templates select="seriesInfo" mode="prep-deprecation"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="../seriesInfo">
          <xsl:call-template name="info">
            <xsl:with-param name="msg" select="'moving seriesInfo elements down from reference to reference/front'"/>
          </xsl:call-template>
          <xsl:apply-templates select="../seriesInfo" mode="prep-deprecation"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="node() except title" mode="prep-deprecation"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="rfc" mode="prep-deprecation">
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="prep-deprecation"/>
    <xsl:if test="not(@sortRefs) and $xml2rfc-sortrefs='yes'">
      <xsl:attribute name="sortRefs">true</xsl:attribute>
    </xsl:if>
    <xsl:if test="not(@symRefs) and $xml2rfc-symrefs='no'">
      <xsl:attribute name="symRefs">false</xsl:attribute>
    </xsl:if>
    <xsl:if test="not(@indexInclude) and $xml2rfc-ext-include-index='no'">
      <xsl:attribute name="indexInclude">false</xsl:attribute>
    </xsl:if>
    <xsl:if test="not(@tocInclude) and $xml2rfc-toc='no'">
      <xsl:attribute name="tocInclude">false</xsl:attribute>
    </xsl:if>
    <xsl:if test="not(@tocDepth) and $parsedTocDepth!=3">
      <xsl:attribute name="tocDepth"><xsl:value-of select="$parsedTocDepth"/></xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="node()" mode="prep-deprecation"/>
  </xsl:copy>
</xsl:template>

<!-- derivedcontent step -->

<!-- Note that there are several issues with the definition of this,
     see https://github.com/rfc-format/draft-iab-rfcv3-preptool-bis/issues -->

<xsl:template match="node()|@*" mode="prep-derivedcontent">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="prep-derivedcontent"/></xsl:copy>
</xsl:template>

<xsl:template match="relref/@derivedLink" mode="prep-derivedcontent"/>

<xsl:template match="relref" mode="prep-derivedcontent">
  <xsl:variable name="d">
    <xsl:variable name="r" select="ancestor::rfc[1]"/>
    <xsl:variable name="t">
      <xsl:call-template name="computed-target">
        <xsl:with-param name="bib" select="$r//reference[@anchor=current()/@target]"/>
        <xsl:with-param name="ref" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="normalize-space($t)"/>
  </xsl:variable>
  <xsl:if test="@derivedLink and @derivedLink!=$d">
    <xsl:call-template name="warning">
      <xsl:with-param name="msg" select="concat('provided value for derivedLink does not match computed:', @derivedLink, ' vs ', $d)"/>
    </xsl:call-template>
  </xsl:if>
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="prep-derivedcontent"/>
    <xsl:attribute name="derivedLink" select="$d"/>
    <xsl:apply-templates select="node()" mode="prep-derivedcontent"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="xref[not(*|text())]/@derivedContent" mode="prep-derivedcontent"/>

<xsl:template match="xref[not(*|text())]" mode="prep-derivedcontent">
  <xsl:variable name="d">
    <xsl:variable name="t">
      <xsl:apply-templates select="."/>
    </xsl:variable>
    <xsl:value-of select="normalize-space($t)"/>
  </xsl:variable>
  <xsl:if test="@derivedContent and @derivedContent!=$d">
    <xsl:call-template name="warning">
      <xsl:with-param name="msg" select="concat('provided value for derivedContent does not match computed:', @derivedContent, ' vs ', $d)"/>
    </xsl:call-template>
  </xsl:if>
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="prep-derivedcontent"/>
    <xsl:attribute name="derivedContent" select="$d"/>
    <xsl:apply-templates select="node()" mode="prep-derivedcontent"/>
  </xsl:copy>
</xsl:template>

<!-- figextract step -->

<!-- https://www.w3.org/TR/xslt-30/#grouping-examples -->
<xsl:template match="t[figure and not(parent::list)]" mode="prep-figextract">
  <xsl:for-each-group select="node()[not(self::text()) or normalize-space(.)!='']" group-adjacent="boolean(self::figure)">
    <xsl:choose>
      <xsl:when test="current-grouping-key()">
        <xsl:copy-of select="current-group()"/>  
      </xsl:when>
      <xsl:otherwise>
        <t>
          <xsl:copy-of select="current-group()"/>
        </t>
      </xsl:otherwise>  
    </xsl:choose>
  </xsl:for-each-group>
</xsl:template>

<xsl:template match="node()|@*" mode="prep-figextract">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="prep-figextract"/></xsl:copy>
</xsl:template>

<!-- idcheck step -->

<xsl:template match="node()|@*" mode="prep-idcheck">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="prep-idcheck"/></xsl:copy>
</xsl:template>

<xsl:template match="*/@anchor|*/@pn|svg:*/@id" mode="prep-idcheck">
  <xsl:variable name="r" select="ancestor::rfc[1]"/>
  <xsl:variable name="targets" select="$r//*[@anchor=current()]|$r//svg:*[@id=current()]|$r//*[@pn=current()]"/>
  <xsl:if test="count($targets)>1">
    <xsl:call-template name="error">
      <xsl:with-param name="msg">Multiple anchors: <xsl:value-of select="current()"/> (<xsl:value-of select="count($targets)"/>).</xsl:with-param>
      <xsl:with-param name="inline" select="'no'"/>
    </xsl:call-template>
  </xsl:if>
  <xsl:copy-of select="."/>
</xsl:template>

<!-- listdefaultstyle step -->

<xsl:template match="list[not(@style)]" mode="prep-listdefaultstyle">
  <xsl:copy>
    <xsl:attribute name="style">
      <xsl:choose>
        <xsl:when test="ancestor::list[@style]"><xsl:value-of select="ancestor::list[@style][1]/@style"/></xsl:when>
        <xsl:otherwise>empty</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:apply-templates select="node()|@*" mode="prep-listdefaultstyle"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="node()|@*" mode="prep-listdefaultstyle">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="prep-listdefaultstyle"/></xsl:copy>
</xsl:template>

<!-- listextract step -->

<!-- https://www.w3.org/TR/xslt-30/#grouping-examples -->
<xsl:template match="t[list][not(ancestor::list)]" mode="prep-listextract">
  <xsl:for-each-group select="node()[not(self::text()) or normalize-space(.)!='']" group-adjacent="boolean(self::list)">
    <t>
      <xsl:copy-of select="current-group()"/>  
    </t>
  </xsl:for-each-group>
</xsl:template>

<xsl:template match="*[self::dd or self::li][list][not(ancestor::list)]" mode="prep-listextract">
  <xsl:copy>
    <xsl:for-each-group select="node()[not(self::text()) or normalize-space(.)!='']" group-adjacent="boolean(self::list)">
      <t>
        <xsl:copy-of select="current-group()"/>  
      </t>
    </xsl:for-each-group>
  </xsl:copy>
</xsl:template>

<xsl:template match="node()|@*" mode="prep-listextract">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="prep-listextract"/></xsl:copy>
</xsl:template>

<!-- lists step -->

<xsl:template match="node()|@*" mode="prep-lists">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="prep-lists"/></xsl:copy>
</xsl:template>

<xsl:template name="lists-insert-t-holding-surplus-anchor">
  <xsl:if test="@anchor and list/@anchor">
    <t anchor="{@anchor}"/>
  </xsl:if>
</xsl:template>

<xsl:template name="lists-insert-list-anchor">
  <xsl:choose>
    <xsl:when test="list/@anchor">
      <xsl:copy-of select="list/@anchor"/>
    </xsl:when>
    <xsl:when test="@anchor">
      <xsl:copy-of select="@anchor"/>
    </xsl:when>
    <xsl:otherwise/>
  </xsl:choose>
</xsl:template>

<!-- convert numbers/letters lists -->

<xsl:template match="t[normalize-space(.)=normalize-space(list) and count(*)=1 and (list/@style='letters' or list/@style='numbers')]" mode="prep-lists">
  <xsl:call-template name="lists-insert-t-holding-surplus-anchor"/>
  <ol>
    <xsl:if test="list/@style='letters'">
      <xsl:attribute name="type">a</xsl:attribute>
    </xsl:if>
    <xsl:call-template name="lists-insert-list-anchor"/>
    <xsl:apply-templates select="list/node()" mode="prep-lists"/>
  </ol>
</xsl:template>

<!-- convert 'format ' lists -->

<xsl:template match="t[normalize-space(.)=normalize-space(list) and count(*)=1]/list[@style='letters' or @style='numbers' or @style='symbols' or starts-with(@style,'format ')]/*[self::t or (local-name()='lt') and namespace-uri()='http://purl.org/net/xml2rfc/ext']" mode="prep-lists" priority="5">
  <li>
    <xsl:copy-of select="@anchor"/>
    <xsl:apply-templates select="node()" mode="prep-lists"/>
  </li>
</xsl:template>

<xsl:template match="t[normalize-space(.)=normalize-space(list) and count(*)=1 and starts-with(list/@style,'format ')]" mode="prep-lists" priority="9">
  <xsl:call-template name="lists-insert-t-holding-surplus-anchor"/>
  <xsl:variable name="type">
    <xsl:choose>
      <xsl:when test="list/@style='format %c.'">a</xsl:when>
      <xsl:when test="list/@style='format %C.'">A</xsl:when>
      <xsl:when test="list/@style='format %i.'">i</xsl:when>
      <xsl:when test="list/@style='format %I.'">I</xsl:when>
      <xsl:when test="list/@style='format %d.'"></xsl:when>
      <xsl:otherwise><xsl:value-of select="substring-after(list/@style,'format ')"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <ol>
    <xsl:if test="$type!=''">
      <xsl:attribute name="type"><xsl:value-of select="$type"/></xsl:attribute>
    </xsl:if>
    <xsl:if test="list/@counter">
      <xsl:attribute name="group"><xsl:value-of select="list/@counter"/></xsl:attribute>
    </xsl:if>
    <xsl:call-template name="lists-insert-list-anchor"/>
    <xsl:apply-templates select="list/node()" mode="prep-lists"/>
  </ol>
</xsl:template>

<!-- convert symbol lists -->

<xsl:template match="t[normalize-space(.)=normalize-space(list) and count(*)=1 and list/@style='symbols']" mode="prep-lists" priority="9">
  <xsl:call-template name="lists-insert-t-holding-surplus-anchor"/>
  <ul>
    <xsl:call-template name="lists-insert-list-anchor"/>
    <xsl:apply-templates select="list/node()" mode="prep-lists"/>
  </ul>
</xsl:template>

<!-- convert empty lists -->

<xsl:template match="t[normalize-space(.)=normalize-space(list) and count(*)=1]/list[@style='empty']/*[self::t or (local-name()='lt') and namespace-uri()='http://purl.org/net/xml2rfc/ext']" mode="prep-lists" priority="5">
  <li>
    <xsl:copy-of select="@anchor"/>
    <xsl:apply-templates select="node()" mode="prep-lists"/>
  </li>
</xsl:template>

<xsl:template match="t[normalize-space(.)=normalize-space(list) and count(*)=1 and (list/@style='empty')]" mode="prep-lists" priority="9">
  <xsl:call-template name="lists-insert-t-holding-surplus-anchor"/>
  <ul empty="true">
    <xsl:apply-templates select="list/node()" mode="prep-lists"/>
  </ul>
</xsl:template>

<!-- convert hanging lists -->

<xsl:template match="t[normalize-space(.)=normalize-space(list) and count(*)=1]/list[@style='hanging']/t" mode="prep-lists" priority="5">
  <dt>
    <xsl:copy-of select="@anchor"/>
    <xsl:value-of select="@hangText"/>
  </dt>
  <dd>
    <xsl:apply-templates select="node()" mode="prep-lists"/>
  </dd>
</xsl:template>

<xsl:template match="t[normalize-space(.)=normalize-space(list) and count(*)=1 and list/@style='hanging']" mode="prep-lists" priority="9">
  <xsl:call-template name="lists-insert-t-holding-surplus-anchor"/>
  <dl>
    <xsl:call-template name="lists-insert-list-anchor"/>
    <xsl:apply-templates select="list/node()" mode="prep-lists"/>
  </dl>
</xsl:template>

<!-- slug step -->

<xsl:template match="name" mode="prep-slug">
  <xsl:param name="root"/>
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="prep-slug">
      <xsl:with-param name="root" select="$root"/>
    </xsl:apply-templates>
    <xsl:variable name="fr">ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.'"()+-_ :%,/@=&lt;&gt;*</xsl:variable>
    <xsl:variable name="to">abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz0123456789.__----_----------</xsl:variable>
    <xsl:variable name="canslug" select="translate(normalize-space(.),$fr,'')=''"/>
    <xsl:choose>
      <xsl:when test="$canslug">
        <xsl:variable name="slug" select="translate(normalize-space(.),$fr,$to)"/>
        <xsl:variable name="conflicts" select="$root//*[not(@anchor)]/name[$slug=translate(normalize-space(.),$fr,$to)]"/>
        <xsl:attribute name="slugifiedName">
          <xsl:choose>
            <xsl:when test="count($conflicts)>1">
              <xsl:variable name="c" select="preceding::*[not(@anchor)]/name[$slug=translate(normalize-space(.),$fr,$to)]"/>
              <xsl:value-of select="concat('n-',$slug,'_',(1+count($c)))"/>
              <!--<xsl:message><xsl:value-of select="concat('n-',$slug,'_',(1+count($c)))"/></xsl:message>-->
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat('n-',$slug)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="info">
          <xsl:with-param name="msg" select="concat('No usable name for slug, using random ID instead: ',normalize-space(.))"/>
        </xsl:call-template>
        <xsl:attribute name="slugifiedName">n-id_<xsl:value-of select="generate-id(.)"/></xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="node()" mode="prep-slug">
      <xsl:with-param name="root" select="$root"/>
    </xsl:apply-templates>
  </xsl:copy>
</xsl:template>

<xsl:template match="name/@slugifiedName" mode="prep-slug"/>

<xsl:template match="node()|@*" mode="prep-slug">
  <xsl:param name="root"/>
  <xsl:copy>
    <xsl:apply-templates select="node()|@*" mode="prep-slug">
      <xsl:with-param name="root" select="$root"/>
    </xsl:apply-templates>
  </xsl:copy>
</xsl:template>

<!-- scripts step -->

<xsl:template name="get-script-names">
  <xsl:param name="node"/>

  <xsl:variable name="common-and-latin">&#9;&#10;&#13;&#x20;&#x21;&#x22;&#x23;&#x24;&#x25;&#x26;&#x27;&#x28;&#x29;&#x2a;&#x2b;&#x2c;&#x2d;&#x2e;&#x2f;0123456789&#x3a;&#x3b;&#x3c;&#x3d;&#x3e;&#x3f;&#x40;ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz&#x5b;&#x5c;&#x5d;&#x5e;&#x5f;&#x60;ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz&#x7b;&#x7c;&#x7d;&#x7e;&#x7f;&#xa0;&#xa9;&#xe9;&#x200a;&#x2011;&#x2014;&#x201c;&#x201d;</xsl:variable>

  <xsl:variable name="text">
    <xsl:for-each select="$node//text()|$node//@*">
      <xsl:variable name="t" select="translate(.,$common-and-latin,'')"/>
      <xsl:variable name="t2">
        <xsl:call-template name="remove-duplicates">
          <xsl:with-param name="s" select="$t"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:value-of select="$t2"/>
    </xsl:for-each>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="$text=''">
      <xsl:text>Common,Latin</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="text-shrunk">
        <xsl:variable name="t2">
          <xsl:call-template name="remove-duplicates">
            <!-- Always include Common and Latin -->
            <xsl:with-param name="s" select="concat('0A',$text)"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$t2"/>
      </xsl:variable>
      <xsl:variable name="out2">
        <xsl:call-template name="dump-string">
          <xsl:with-param name="s" select="$text-shrunk"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="unique-codepoints">
        <xsl:for-each-group select="$out2/c" group-by=".">
          <xsl:sort select="."/>
          <c cp="{string-to-codepoints(.)}"><xsl:value-of select="."/></c>
        </xsl:for-each-group>
      </xsl:variable>
      <xsl:variable name="codepoints-message">
        <xsl:for-each select="$unique-codepoints/c[@cp > 127]">
          <xsl:value-of select="@cp"/>
          <xsl:if test="position()!=last()">
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:call-template name="info">
        <xsl:with-param name="msg" select="concat('Need to lookup Unicode script names for codepoints: ', $codepoints-message)"/>
      </xsl:call-template>
      <xsl:call-template name="info">
        <xsl:with-param name="msg">(will need a local copy of ftp://www.unicode.org/Public/UCD/latest/ucd/Scripts.txt)</xsl:with-param>
      </xsl:call-template>
      <xsl:variable name="scriptlist">
        <xsl:for-each select="$unique-codepoints/c">
          <c sc="{f:get-script(number(@cp))}"/>
        </xsl:for-each>
      </xsl:variable>
      <xsl:for-each-group select="$scriptlist/c" group-by="@sc">
        <xsl:sort select="@sc"/>
        <xsl:value-of select="@sc"/>
        <xsl:if test="position()!=last()">
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:for-each-group>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="remove-duplicates">
  <xsl:param name="s"/>
  <xsl:param name="p" select="1"/>
  <xsl:choose>
    <xsl:when test="$p &lt;= string-length($s)">
      <xsl:variable name="c" select="substring($s, $p, 1)"/>
      <xsl:if test="not(contains(substring($s, 1, $p - 1), $c))">
        <xsl:value-of select="$c"/>
      </xsl:if>
      <xsl:call-template name="remove-duplicates">
        <xsl:with-param name="s" select="$s"/>
        <xsl:with-param name="p" select="$p + 1"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise/>
  </xsl:choose>
</xsl:template>

<xsl:template name="dump-string">
  <xsl:param name="s"/>
  <xsl:param name="p" select="1"/>
  <xsl:choose>
    <xsl:when test="$p &lt;= string-length($s)">
      <c><xsl:value-of select="substring($s,$p,1)"/></c>
      <xsl:call-template name="dump-string">
        <xsl:with-param name="s" select="$s"/>
        <xsl:with-param name="p" select="$p + 1"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise/>
  </xsl:choose>
</xsl:template>

<!-- Read information from ftp://www.unicode.org/Public/UCD/latest/ucd/Scripts.txt
     and parse it into a list of range/script mappings -->

<xsl:template name="getscripts">
  <xsl:variable name="raw" select="unparsed-text('Scripts.txt')"/>

  <xsl:analyze-string select="$raw" regex="(.*);(.*)#(.*)">
    <xsl:matching-substring>
      <xsl:variable name="p1" select="normalize-space(regex-group(1))"/>
      <xsl:variable name="p2" select="normalize-space(regex-group(2))"/>
      <xsl:choose>
        <xsl:when test="contains($p1,'..')">
          <range script="{$p2}" from="{f:parse-hex(substring-before($p1,'..'))}" to="{f:parse-hex(substring-after($p1,'..'))}"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="v" select="f:parse-hex($p1)"/>
          <range script="{$p2}" from="{$v}" to="{$v}"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:matching-substring>
    <xsl:non-matching-substring/>
  </xsl:analyze-string>
</xsl:template>

<!-- given a code point return the name of the Unicode script -->

<xsl:function name="f:get-script">
  <xsl:param name="cp"/>

  <xsl:variable name="ranges">
    <xsl:call-template name="getscripts"/>
  </xsl:variable>  

  <xsl:variable name="entry" select="$ranges/range[@from &lt;= $cp and $cp &lt;= @to]"/>
  <xsl:choose>
    <xsl:when test="$entry">
      <xsl:value-of select="$entry/@script"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message>ERROR: no script found for codepoint <xsl:value-of select="$cp"/></xsl:message>
      <xsl:text>???</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- utilities for CSS color values -->
<xsl:function name="f:normalize-css-color">
  <xsl:param name="cssc"/>
  <xsl:choose>
    <xsl:when test="starts-with($cssc,'#')">
      <xsl:value-of select="translate($cssc,$lcase,$ucase)"/>
    </xsl:when>
    <xsl:otherwise><xsl:value-of select="$cssc"/></xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:compute-css-color-brightness">
  <xsl:param name="cssc"/>
  <xsl:choose>
    <xsl:when test="starts-with($cssc,'#') and string-length($cssc)=7">
      <xsl:variable name="r" select="f:parse-hex(substring($cssc,2,2))"/>
      <xsl:variable name="g" select="f:parse-hex(substring($cssc,4,2))"/>
      <xsl:variable name="b" select="f:parse-hex(substring($cssc,6,2))"/>
      <xsl:value-of select="($r + $g + $b) div 3"/>
    </xsl:when>
    <xsl:when test="starts-with($cssc,'#') and string-length($cssc)=4">
      <xsl:variable name="r" select="f:parse-hex(substring($cssc,2,1))"/>
      <xsl:variable name="g" select="f:parse-hex(substring($cssc,3,1))"/>
      <xsl:variable name="b" select="f:parse-hex(substring($cssc,4,1))"/>
      <xsl:value-of select="(($r * 256) + ($g * 256) + ($b * 256)) div 3"/>
    </xsl:when>
    <xsl:otherwise>-1</xsl:otherwise>
  </xsl:choose>
</xsl:function>


<!-- utilities for parsing hex numbers -->

<xsl:function name="f:parse-hex">
  <xsl:param name="hex"/>
  <xsl:value-of select="f:parse-hex-internal($hex,0)"/>
</xsl:function>

<xsl:function name="f:parse-hex-internal">
  <xsl:param name="hex"/>
  <xsl:param name="num"/>
  <xsl:variable name="MSB" select="translate(substring($hex, 1, 1), 'abcdef', 'ABCDEF')"/>
  <xsl:variable name="value" select="string-length(substring-before('0123456789ABCDEF', $MSB))"/>
  <xsl:variable name="result" select="16 * $num + $value"/>
  <xsl:choose>
    <xsl:when test="string-length($hex) > 1">
      <xsl:value-of select="f:parse-hex-internal(substring($hex, 2),$result)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$result"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:template match="rfc/@scripts" mode="prep-scripts"/>
<xsl:template match="rfc" mode="prep-scripts">
  <xsl:param name="root"/>
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="prep-scripts">
      <xsl:with-param name="root" select="$root"/>
    </xsl:apply-templates>
    <xsl:attribute name="scripts">
      <xsl:call-template name="get-script-names">
        <xsl:with-param name="node" select="$root"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:apply-templates select="node()" mode="prep-scripts">
      <xsl:with-param name="root" select="$root"/>
    </xsl:apply-templates>
  </xsl:copy>
</xsl:template>

<xsl:template match="node()|@*" mode="prep-scripts">
  <xsl:param name="root"/>
  <xsl:copy>
    <xsl:apply-templates select="node()|@*" mode="prep-scripts">
      <xsl:with-param name="root" select="$root"/>
    </xsl:apply-templates>
  </xsl:copy>
</xsl:template>

<!-- normalization step -->

<xsl:template match="node()|@*" mode="prep-normalization">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="prep-normalization"/></xsl:copy>
</xsl:template>

<xsl:template match="rfc/front/date/@month" mode="prep-normalization">
  <xsl:attribute name="month">
    <xsl:value-of select="number($pub-month-numeric)"/>
  </xsl:attribute>
</xsl:template>

<xsl:template match="cite/@ascii|code/@ascii|country/@ascii|email/@ascii|organization/@ascii|postalLine/@ascii|region/@ascii|street/@ascii|title/@ascii" mode="prep-normalization">
  <xsl:choose>
    <xsl:when test="normalize-space(.) != normalize-space(..)">
      <xsl:copy-of select="."/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="warning">
        <xsl:with-param name="msg" select="concat('removing unneeded @', local-name(.), ' attribute from: ', local-name(..))"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="author/@asciiInitials|author/@asciiFullname|author/@asciiSurname" mode="prep-normalization">
  <xsl:choose>
    <xsl:when test="local-name(.)='asciiInitials' and normalize-space(.) != normalize-space(../@initials)">
      <xsl:copy-of select="."/>
    </xsl:when>
    <xsl:when test="local-name(.)='asciiSurname' and normalize-space(.) != normalize-space(../@surname)">
      <xsl:copy-of select="."/>
    </xsl:when>
    <xsl:when test="local-name(.)='asciiFullname' and normalize-space(.) != normalize-space(../@fullname)">
      <xsl:copy-of select="."/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="warning">
        <xsl:with-param name="msg" select="concat('removing unneeded @', local-name(.), ' attribute from: ', local-name(..))"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="@title" mode="prep-normalization"/>

<xsl:template match="figure|note|references|section|texttable" mode="prep-normalization">
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="prep-normalization"/>
    <xsl:if test="@title!=''">
      <xsl:choose>
        <xsl:when test="name">
          <xsl:call-template name="error">
            <xsl:with-param name="msg" select="concat(local-name(.), ' contains both name and @title, @title ignored')"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <name><xsl:value-of select="normalize-space(@title)"/></name>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:apply-templates select="node()" mode="prep-normalization"/>
  </xsl:copy>
</xsl:template>



<!-- pi step -->

<xsl:template match="node()|@*" mode="prep-pi">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="prep-pi"/></xsl:copy>
</xsl:template>

<xsl:template match="processing-instruction('rfc')|processing-instruction('rfc-ext')" mode="prep-pi" priority="9">
  <xsl:variable name="s" select="local-name()"/>
  <xsl:analyze-string select="." regex='\s*([^=]*)\s*=\s*("([^"]*)"|&apos;([^&apos;]*)&apos;)\s*'>
    <xsl:matching-substring>
      <xsl:element name="pi:{$s}">
        <xsl:attribute name="name">
          <xsl:value-of select="regex-group(1)"/>
        </xsl:attribute>
        <xsl:attribute name="value">
          <xsl:value-of select="concat(regex-group(3),regex-group(4))"/>
        </xsl:attribute>
        <!--<xsl:attribute name="g1">
          <xsl:value-of select="regex-group(1)"/>
        </xsl:attribute>
        <xsl:attribute name="g2">
          <xsl:value-of select="regex-group(2)"/>
        </xsl:attribute>
        <xsl:attribute name="g3">
          <xsl:value-of select="regex-group(3)"/>
        </xsl:attribute>
        <xsl:attribute name="g4">
          <xsl:value-of select="regex-group(4)"/>
        </xsl:attribute>-->
      </xsl:element>
    </xsl:matching-substring>
  </xsl:analyze-string>
</xsl:template>

<!-- pn step -->

<xsl:template match="node()|@*" mode="prep-pn">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="prep-pn"/></xsl:copy>
</xsl:template>

<xsl:template name="pn-sn">
  <xsl:choose>
    <xsl:when test="self::abstract">s-abstract</xsl:when>
    <xsl:when test="self::boilerplate">s-boilerplate</xsl:when>
    <xsl:when test="self::figure">f-<xsl:number count="figure" level="any"/></xsl:when>
    <xsl:when test="self::note">s-note-<xsl:number count="note"/></xsl:when>
    <xsl:when test="self::table">t-<xsl:number count="table" level="any"/></xsl:when>
    <xsl:when test="self::references">
      <xsl:choose>
        <xsl:when test="parent::references">
          <xsl:for-each select=".."><xsl:call-template name="pn-sn"/></xsl:for-each>.<xsl:number count="references"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>s-</xsl:text>
          <xsl:value-of select="1 + count(../../middle/section)"/>
          <xsl:if test="count(../references)!=1">
            <xsl:text>.</xsl:text>
            <xsl:value-of select="1 + count(preceding-sibling::references)"/>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="self::section and parent::back">s-<xsl:number count="section" format="a"/></xsl:when>
    <xsl:when test="self::section and parent::middle">s-<xsl:number count="section"/></xsl:when>
    <xsl:when test="self::section and ancestor::boilerplate">s-boilerplate-<xsl:number count="section"/></xsl:when>
    <xsl:when test="self::section"><xsl:for-each select=".."><xsl:call-template name="pn-sn"/></xsl:for-each>.<xsl:number count="section"/></xsl:when>
    <xsl:when test="self::artset or self::artwork or self::aside or self::blockquote or self::dd or self::dl or self::dt or self::li or self::ol or self::sourcecode or self::t or self::tbody or self::td or self::th or self::thead or self::tr or self::ul">
      <xsl:for-each select="..">
        <xsl:call-template name="pn-sn"/>
        <xsl:choose>
          <xsl:when test="self::section or self::boilerplate or self::abstract or self::note or self::figure">-</xsl:when>
          <xsl:otherwise>.</xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
      <xsl:number count="artset|artwork|aside|blockquote|dd|dl|dt|li|ol|sourcecode|t|tbody|td|th|thead|tr|ul"/>
    </xsl:when>
    <xsl:otherwise/>
  </xsl:choose>
</xsl:template>

<xsl:template match="abstract|artset|artwork|aside|blockquote|boilerplate|dd|dl|dt|figure|li|note|ol|references|section|sourcecode|t|table|tbody|td|th|thead|tr|ul" mode="prep-pn">
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="prep-pn"/>
    <!-- https://github.com/rfc-format/draft-iab-rfcv3-preptool-bis/issues/7 -->
    <xsl:if test="not(ancestor::reference)">
      <xsl:attribute name="pn"><xsl:call-template name="pn-sn"/></xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="node()" mode="prep-pn"/>
  </xsl:copy>
</xsl:template>
<xsl:template match="@pn" mode="prep-pn"/>

<!-- preptime step -->

<xsl:template match="node()|@*" mode="prep-preptime">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="prep-preptime"/></xsl:copy>
</xsl:template>

<xsl:template match="/rfc/@prepTime" mode="prep-preptime"/>

<xsl:template match="rfc" mode="prep-preptime">
  <xsl:copy>
    <xsl:attribute name="prepTime" select="adjust-dateTime-to-timezone(current-dateTime(),xs:dayTimeDuration('PT0H'))"/>
    <xsl:apply-templates select="@*" mode="prep-preptime"/>
    <xsl:apply-templates select="node()" mode="prep-preptime"/>
  </xsl:copy>
</xsl:template>

<!-- references step -->

<xsl:template match="node()|@*" mode="prep-references">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="prep-references"/></xsl:copy>
</xsl:template>

<xsl:template match="references[parent::back]" mode="prep-references">
  <xsl:choose>
    <xsl:when test="not(preceding-sibling::references) and count(../references)!=1">
      <references>
        <name>References</name>
        <xsl:copy-of select="."/>
        <xsl:apply-templates select="following-sibling::references" mode="prep-references"/>
      </references>
    </xsl:when>
    <xsl:when test="not(preceding-sibling::references) and count(../references)=1">
      <xsl:copy-of select="."/>
    </xsl:when>
    <xsl:otherwise/>
  </xsl:choose>
</xsl:template>

<!-- removeinrfc step -->

<xsl:template match="node()|@*" mode="prep-removeinrfc">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="prep-removeinrfc"/></xsl:copy>
</xsl:template>

<xsl:template match="@removeInRFC" mode="prep-removeinrfc"/>
<xsl:template match="section|note" mode="prep-removeinrfc">
  <xsl:choose>
    <xsl:when test="$mode!='rfc'">
      <xsl:copy>
        <xsl:apply-templates select="@*" mode="prep-removeinrfc"/>
        <xsl:copy-of select="@removeInRFC"/>
        <xsl:apply-templates select="name" mode="prep-removeinrfc"/>
        <xsl:if test="self::section and @removeInRFC='true' and t[1]!=$section-removeInRFC">
          <t><xsl:value-of select="$section-removeInRFC"/></t>
        </xsl:if>
        <xsl:if test="self::note and @removeInRFC='true' and t[1]!=$note-removeInRFC">
          <t><xsl:value-of select="$note-removeInRFC"/></t>
        </xsl:if>
        <xsl:apply-templates select="node()[not(self::name)]" mode="prep-removeinrfc"/>
      </xsl:copy>
    </xsl:when>
    <xsl:otherwise>
      <xsl:if test="not(@removeInRFC='true')">
        <xsl:copy>
          <xsl:apply-templates select="@*" mode="prep-removeinrfc"/>
          <xsl:apply-templates select="node()" mode="prep-removeinrfc"/>
        </xsl:copy>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- rfc2629ext step -->

<xsl:template match="node()|@*" mode="prep-rfc2629ext">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="prep-rfc2629ext"/></xsl:copy>
</xsl:template>

<xsl:template match="reference" mode="prep-rfc2629ext">
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="prep-rfc2629ext"/>
    <xsl:if test="not(@quoteTitle) and front/title[@x:quotes='false']" xmlns:x="http://purl.org/net/xml2rfc/ext">
      <xsl:attribute name="quoteTitle">false</xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="node()" mode="prep-rfc2629ext"/>
  </xsl:copy>
</xsl:template>
<xsl:template match="@x:quotes" mode="prep-rfc2629ext" xmlns:x="http://purl.org/net/xml2rfc/ext"/>

<xsl:template match="x:source" mode="prep-rfc2629ext" xmlns:x="http://purl.org/net/xml2rfc/ext">
  <xsl:if test="not(../front)">
    <xsl:copy-of select="document(@href)/rfc/front"/>
  </xsl:if>
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="prep-rfc2629ext"/>
    <xsl:apply-templates select="node()" mode="prep-rfc2629ext"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="x:link[not(@basename)]" mode="prep-rfc2629ext" xmlns:x="http://purl.org/net/xml2rfc/ext">
  <link>
    <xsl:apply-templates select="@*" mode="prep-rfc2629ext"/>
  </link>
</xsl:template>

<xsl:template match="x:note" mode="prep-rfc2629ext" xmlns:x="http://purl.org/net/xml2rfc/ext">
  <aside>
    <xsl:apply-templates select="@*|node()" mode="prep-rfc2629ext"/>
  </aside>
</xsl:template>

<!-- rfccleanup step -->

<xsl:template match="*|text()|processing-instruction()|@*" mode="prep-rfccleanup">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="prep-rfccleanup"/></xsl:copy>
</xsl:template>

<xsl:template match="cref|comment()" mode="prep-rfccleanup"/>

<xsl:template match="link[@rel='alternate']" mode="prep-rfccleanup"/>

<xsl:template match="@xml:base" mode="prep-rfccleanup"/>

<xsl:template match="rfc" mode="prep-rfccleanup">
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="prep-rfccleanup"/>
    <xsl:if test="not(link[lower-case(@rel)='item' and lower-case(@href)='urn:issn:2070-1721'])">
      <link rel="item" href="urn:issn:2070-1721"/>
    </xsl:if>
    <xsl:variable name="doi" select="concat('https://dx.doi.org/10.17487/RFC',format-number($rfcnumber,'#0000'))"/>
    <xsl:if test="not(link[lower-case(@rel)='describedby' and lower-case(@href)=$doi])">
      <link rel="describedBy" href="{$doi}"/>
    </xsl:if>
    <xsl:if test="not(link[lower-case(@rel)='convertedfrom' and starts-with(@href,'https://datatracker.ietf.org/doc/draft-')])">
      <xsl:message terminate="yes">FATAL: missing &lt;link rel='convertedFrom' href='https://datatracker.ietf.org/doc/draft-'...</xsl:message>
    </xsl:if>
    <xsl:apply-templates select="node()" mode="prep-rfccleanup"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="link[lower-case(@rel)='alternate']" mode="prep-rfccleanup"/>
<xsl:template match="link[lower-case(@rel)='describedby' and starts-with(@href,'https://dx.doi.org/')]" mode="prep-rfccleanup"/>

<!-- tables step -->

<xsl:template match="node()|@*" mode="prep-tables">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="prep-tables"/></xsl:copy>
</xsl:template>

<xsl:template match="texttable/@title" mode="prep-tables"/>

<xsl:template match="texttable" mode="prep-tables">
  <xsl:for-each select="preamble">
    <t>
      <xsl:apply-templates select="node()|@*" mode="prep-tables"/>
    </t>
  </xsl:for-each>
  <table>
    <xsl:apply-templates select="@anchor" mode="prep-tables"/>
    <xsl:apply-templates select="iref" mode="prep-tables"/>
    <xsl:choose>
      <xsl:when test="not(name) and @title!=''">
        <name><xsl:value-of select="@title"/></name>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="name" mode="prep-tables"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="ttcol/text()!=''">
      <thead>
        <tr>
          <xsl:for-each select="ttcol">
            <th>
              <xsl:if test="@align and @align!='left'">
                <xsl:copy-of select="@align"/>
              </xsl:if>
              <xsl:value-of select="."/>
            </th>
          </xsl:for-each>
        </tr>
      </thead>
    </xsl:if>
    <xsl:if test="c">
      <xsl:variable name="columns" select="count(ttcol)"/>
      <xsl:variable name="fields" select="c"/>
      <tbody>
        <xsl:for-each select="$fields[$columns=1 or (position() mod $columns) = 1]">
          <tr>
            <xsl:for-each select=". | following-sibling::c[position() &lt; $columns]">
              <xsl:variable name="p" select="position()"/>
              <xsl:variable name="col" select="../ttcol[$p]"/>
              <td>
                <xsl:if test="$col/@align and $col/@align!='left'">
                  <xsl:copy-of select="$col/@align"/>
                </xsl:if>
                <xsl:apply-templates select="node()" mode="prep-tables"/>
              </td>
            </xsl:for-each>
          </tr>
        </xsl:for-each>
      </tbody>
    </xsl:if>
  </table>
  <xsl:for-each select="postamble">
    <t>
      <xsl:apply-templates select="node()|@*" mode="prep-tables"/>
    </t>
  </xsl:for-each>
</xsl:template>


<!-- preprocesssvg step -->

<xsl:template match="node()|@*" mode="prep-preprocesssvg">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="prep-preprocesssvg"/></xsl:copy>
</xsl:template>

<xsl:template match="svg:*/@style" mode="prep-preprocesssvg" priority="9">
  <xsl:message>ERROR: <xsl:value-of select="node-name(..)"/>/@<xsl:value-of select="node-name(.)"/>=<xsl:value-of select="."/> not allowed in SVG content (dropped)</xsl:message>
  <xsl:analyze-string select="." regex='\s*([-A-Za-z]*)\s*(:)\s*([^;]*)\s*(;)?'>
    <xsl:matching-substring>
      <xsl:message>INFO: inserting <xsl:value-of select="regex-group(1)"/>=<xsl:value-of select="regex-group(3)"/> instead</xsl:message>
      <xsl:attribute name="{regex-group(1)}"><xsl:value-of select="regex-group(3)"/></xsl:attribute>
    </xsl:matching-substring>
  </xsl:analyze-string>
</xsl:template>

<!-- sanitizesvg step, TBD: add to whitelist, check specific attribute values -->

<xsl:template match="node()|@*" mode="prep-sanitizesvg">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="prep-sanitizesvg"/></xsl:copy>
</xsl:template>

<xsl:template match="*[ancestor::svg:svg][not(self::pi:*)]" mode="prep-sanitizesvg">
  <xsl:message>ERROR: <xsl:value-of select="node-name(.)"/> not allowed in SVG content (dropped)</xsl:message>
</xsl:template>

<xsl:template match="*[ancestor::svg:svg][not(self::pi:*)]/@*" mode="prep-sanitizesvg">
  <xsl:message>ERROR: <xsl:value-of select="node-name(..)"/>/@<xsl:value-of select="node-name(.)"/> not allowed in SVG content (dropped)</xsl:message>
</xsl:template>

<xsl:template match="svg:a|svg:defs|svg:desc|svg:ellipse|svg:g|svg:line|svg:path|svg:polyline|svg:polygon|svg:rect|svg:style|svg:text|svg:title|svg:tspan|svg:use" mode="prep-sanitizesvg" priority="9">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="prep-sanitizesvg"/></xsl:copy>
</xsl:template>

<xsl:template match="svg:a/@xlink:href|svg:a/@xlink:title" mode="prep-sanitizesvg" priority="9">
  <xsl:copy/>
</xsl:template>

<xsl:template match="svg:defs/@class" mode="prep-sanitizesvg" priority="9">
  <xsl:copy/>
</xsl:template>

<xsl:template match="svg:ellipse/@cx|svg:ellipse/@cy|svg:ellipse/@rx|svg:ellipse/@ry" mode="prep-sanitizesvg" priority="9">
  <xsl:copy/>
</xsl:template>

<xsl:template match="svg:g/@class|svg:g/@id|svg:g/@transform" mode="prep-sanitizesvg" priority="9">
  <xsl:copy/>
</xsl:template>

<xsl:template match="svg:line/@class|svg:line/@fill-opacity|svg:line/@id|svg:line/@stroke-dasharray|svg:line/@stroke-width|svg:line/@style|svg:line/@x1|svg:line/@x2|svg:line/@y1|svg:line/@y2" mode="prep-sanitizesvg" priority="9">
  <xsl:copy/>
</xsl:template>

<xsl:template match="svg:path/@class|svg:path/@d|svg:path/@stroke-dasharray|svg:path/@stroke-width|svg:path/@style" mode="prep-sanitizesvg" priority="9">
  <xsl:copy/>
</xsl:template>

<xsl:template match="svg:polygon/@class|svg:polygon/@fill-opacity|svg:polygon/@points|svg:polygon/@stroke-width|svg:polygon/@style" mode="prep-sanitizesvg" priority="9">
  <xsl:copy/>
</xsl:template>

<xsl:template match="svg:polyline/@points" mode="prep-sanitizesvg" priority="9">
  <xsl:copy/>
</xsl:template>

<xsl:template match="svg:rect/@class|svg:rect/@fill-opacity|svg:rect/@height|svg:rect/@rx|svg:rect/@ry|svg:rect/@stroke-width|svg:rect/@width|svg:rect/@x|svg:rect/@y" mode="prep-sanitizesvg" priority="9">
  <xsl:copy/>
</xsl:template>

<xsl:template match="svg:text/@class|svg:text/@font-size|svg:text/@style|svg:text/@x|svg:text/@y" mode="prep-sanitizesvg" priority="9">
  <xsl:copy/>
</xsl:template>

<xsl:template match="svg:title/@content" mode="prep-sanitizesvg" priority="9">
  <xsl:copy/>
</xsl:template>

<xsl:template match="svg:tspan/@class|svg:tspan/@fill|svg:tspan/@font-size|svg:tspan/@x|svg:tspan/@y" mode="prep-sanitizesvg" priority="9">
  <xsl:copy/>
</xsl:template>

<xsl:template match="svg:use/@transform|svg:use/@x|svg:use/@y|svg:use/@xlink:href" mode="prep-sanitizesvg" priority="9">
  <xsl:copy/>
</xsl:template>

<xsl:template match="svg:ellipse/@fill|svg:line/@fill|svg:path/@fill|svg:polygon/@fill|svg:rect/@fill|svg:text/@fill" mode="prep-sanitizesvg" priority="9">
  <xsl:variable name="v" select="f:normalize-css-color(.)"/>
  <xsl:variable name="brightness" select="f:compute-css-color-brightness($v)"/>

  <xsl:choose>
    <xsl:when test="$v='none' or $v='black' or $v='white' or $v='#000000' or $v='#FFFFFF'">
      <xsl:copy/>
    </xsl:when>
    <xsl:when test="$brightness >= 128">
      <xsl:message>WARN: <xsl:value-of select="node-name(..)"/>/@<xsl:value-of select="node-name(.)"/>=<xsl:value-of select="."/> not allowed in SVG content (replaced by 'white')</xsl:message>
      <xsl:attribute name="fill">white</xsl:attribute>
    </xsl:when>
    <xsl:when test="$brightness >= 0 and $brightness &lt; 128">
      <xsl:message>WARN: <xsl:value-of select="node-name(..)"/>/@<xsl:value-of select="node-name(.)"/>=<xsl:value-of select="."/> not allowed in SVG content (replaced by 'black')</xsl:message>
      <xsl:attribute name="fill">black</xsl:attribute>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message>ERROR: <xsl:value-of select="node-name(..)"/>/@<xsl:value-of select="node-name(.)"/>=<xsl:value-of select="."/> not allowed in SVG content (dropped)</xsl:message>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="svg:ellipse/@stroke|svg:line/@stroke|svg:path/@stroke|svg:polygon/@stroke|svg:rect/@stroke|svg:tspan/@stroke" mode="prep-sanitizesvg" priority="9">
  <xsl:variable name="v" select="f:normalize-css-color(.)"/>
  <xsl:variable name="brightness" select="f:compute-css-color-brightness($v)"/>

  <xsl:choose>
    <xsl:when test="$v='none' or $v='currentColor' or $v='black' or $v='white' or $v='#000000' or $v='#FFFFFF'">
      <xsl:copy/>
    </xsl:when>
    <xsl:when test="$brightness >= 128">
      <xsl:message>WARN: <xsl:value-of select="node-name(..)"/>/@<xsl:value-of select="node-name(.)"/>=<xsl:value-of select="."/> not allowed in SVG content (replaced by 'white')</xsl:message>
      <xsl:attribute name="stroke">white</xsl:attribute>
    </xsl:when>
    <xsl:when test="$brightness >= 0 and $brightness &lt; 128">
      <xsl:message>WARN: <xsl:value-of select="node-name(..)"/>/@<xsl:value-of select="node-name(.)"/>=<xsl:value-of select="."/> not allowed in SVG content (replaced by 'black')</xsl:message>
      <xsl:attribute name="stroke">black</xsl:attribute>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message>ERROR: <xsl:value-of select="node-name(..)"/>/@<xsl:value-of select="node-name(.)"/>=<xsl:value-of select="."/> not allowed in SVG content (dropped)</xsl:message>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="svg:text/@font-family|svg:tspan/@font-family" mode="prep-sanitizesvg" priority="9">
  <xsl:choose>
    <xsl:when test=".='serif' or .='sans-serif' or .='monospace'">
      <xsl:copy/>
    </xsl:when>
    <xsl:when test=".='Times New Roman'">
      <xsl:message>WARN: <xsl:value-of select="node-name(..)"/>/@<xsl:value-of select="node-name(.)"/>=<xsl:value-of select="."/> not allowed in SVG content (replaced by 'serif')</xsl:message>
      <xsl:attribute name="font-family">serif</xsl:attribute>
    </xsl:when>
    <xsl:when test="contains(.,'monospace')">
      <xsl:message>WARN: <xsl:value-of select="node-name(..)"/>/@<xsl:value-of select="node-name(.)"/>=<xsl:value-of select="."/> not allowed in SVG content (replaced by 'monospace')</xsl:message>
      <xsl:attribute name="font-family">monospace</xsl:attribute>
    </xsl:when>
    <xsl:when test="contains(.,'sans-serif')">
      <xsl:message>WARN: <xsl:value-of select="node-name(..)"/>/@<xsl:value-of select="node-name(.)"/>=<xsl:value-of select="."/> not allowed in SVG content (replaced by 'sans-serif')</xsl:message>
      <xsl:attribute name="font-family">sans-serif</xsl:attribute>
    </xsl:when>
    <xsl:when test="contains(.,'serif')">
      <xsl:message>WARN: <xsl:value-of select="node-name(..)"/>/@<xsl:value-of select="node-name(.)"/>=<xsl:value-of select="."/> not allowed in SVG content (replaced by 'serif')</xsl:message>
      <xsl:attribute name="font-family">serif</xsl:attribute>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message>ERROR: <xsl:value-of select="node-name(..)"/>/@<xsl:value-of select="node-name(.)"/>=<xsl:value-of select="."/> not allowed in SVG content (dropped)</xsl:message>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="svg:text/@text-anchor" mode="prep-sanitizesvg" priority="9">
  <xsl:choose>
    <xsl:when test=".='start' or .='middle' or .='end' or .='inherit'">
      <xsl:copy/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message>ERROR: <xsl:value-of select="node-name(..)"/>/@<xsl:value-of select="node-name(.)"/>=<xsl:value-of select="."/> not allowed in SVG content (dropped)</xsl:message>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="svg:text/@font-style|svg:tspan/@font-style" mode="prep-sanitizesvg" priority="9">
  <xsl:choose>
    <xsl:when test=".='normal' or .='italic' or .='oblique'">
      <xsl:copy/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message>ERROR: <xsl:value-of select="node-name(..)"/>/@<xsl:value-of select="node-name(.)"/>=<xsl:value-of select="."/> not allowed in SVG content (dropped)</xsl:message>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="svg:text/@font-weight|svg:tspan/@font-weight" mode="prep-sanitizesvg" priority="9">
  <xsl:choose>
    <xsl:when test=".='normal' or .='bold' or .='bolder' or .='lighter'">
      <xsl:copy/>
    </xsl:when>
    <xsl:when test=".='400'">
      <xsl:message>WARN: <xsl:value-of select="node-name(..)"/>/@<xsl:value-of select="node-name(.)"/>=<xsl:value-of select="."/> not allowed in SVG content (replaced by 'normal')</xsl:message>
      <xsl:attribute name="font-weight">normal</xsl:attribute>
    </xsl:when>
    <xsl:when test=".='700'">
      <xsl:message>WARN: <xsl:value-of select="node-name(..)"/>/@<xsl:value-of select="node-name(.)"/>=<xsl:value-of select="."/> not allowed in SVG content (replaced by 'bold')</xsl:message>
      <xsl:attribute name="font-weight">bold</xsl:attribute>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message>ERROR: <xsl:value-of select="node-name(..)"/>/@<xsl:value-of select="node-name(.)"/>=<xsl:value-of select="."/> not allowed in SVG content (dropped)</xsl:message>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="svg:path/@stroke-linejoin|svg:rect/@stroke-linejoin" mode="prep-sanitizesvg" priority="9">
  <xsl:choose>
    <xsl:when test=".='miter' or .='round' or .='bevel'">
      <xsl:copy/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message>ERROR: <xsl:value-of select="node-name(..)"/>/@<xsl:value-of select="node-name(.)"/>=<xsl:value-of select="."/> not allowed in SVG content (dropped)</xsl:message>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- xinclude step -->

<xsl:template match="node()|@*" mode="prep-xinclude">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="prep-xinclude"/></xsl:copy>
</xsl:template>

<xsl:template match="xi:include" xmlns:xi="http://www.w3.org/2001/XInclude" mode="prep-xinclude">
  <xsl:if test="@parse and @parse!='xml'">
    <xsl:message terminate="yes">FATAL: &lt;xi:include> parse mode '<xsl:value-of select="@parse"/>' not supported.</xsl:message>
  </xsl:if>
  <xsl:if test="@xpointer">
    <xsl:message terminate="yes">FATAL: &lt;xi:include> xpointer not supported.</xsl:message>
  </xsl:if>
  <xsl:variable name="content" select="document(@href)"/>
  <xsl:variable name="href" select="@href"/>
  <xsl:for-each select="$content/*">
    <xsl:copy>
      <xsl:attribute name="xml:base" select="$href"/>
      <xsl:copy-of select="@*[not(name()='xml:base')]"/>
      <xsl:copy-of select="node()"/>
    </xsl:copy>
  </xsl:for-each>
</xsl:template>

<!-- while we're doing xinclude we can do this as well, right? -->
<xsl:template match="pi:rfc[@name='include']" mode="prep-xinclude">
  <xsl:variable name="content" select="document(@value)"/>
  <xsl:choose>
    <xsl:when test="$content">
      <xsl:for-each select="$content/*">
        <xsl:copy>
          <xsl:attribute name="xml:base" select="@value"/>
          <xsl:copy-of select="@*[not(name()='xml:base')]"/>
          <xsl:copy-of select="node()"/>
        </xsl:copy>
      </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
      <!-- retry with .xml -->
      <xsl:variable name="content2" select="document(concat(@value,'.xml'))"/>
      <xsl:for-each select="$content2/*">
        <xsl:copy>
          <xsl:attribute name="xml:base" select="concat(@value,'.xml')"/>
          <xsl:copy-of select="@*[not(name()='xml:base')]"/>
          <xsl:copy-of select="node()"/>
        </xsl:copy>
      </xsl:for-each>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- final serialization step -->

<xsl:template match="node()|@*" mode="prep-ser">
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="prep-ser">
      <xsl:sort select="name()"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="node()" mode="prep-ser"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="rfc" mode="prep-ser">
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="prep-ser">
      <xsl:sort select="name()"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="node()" mode="prep-ser"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="text()[not(ancestor::artwork or ancestor::sourcecode)]" mode="prep-ser">
  <xsl:variable name="ws" select="translate(.,'&#10;&#13;&#9;','   ')"/>
  <xsl:variable name="t" select="normalize-space(.)"/>
  <xsl:variable name="pnode" select="(preceding-sibling::text()|preceding-sibling::element())[last()]"/>
  <xsl:variable name="snode" select="(following-sibling::text()|following-sibling::element())[1]"/>
  <!-- <xsl:comment>ws: |<xsl:value-of select="."/>|<xsl:value-of select="$ws"/>|</xsl:comment>-->
  <!--<xsl:if test="$pnode">
    <xsl:comment>p: <xsl:value-of select="name($pnode)"/><xsl:text> </xsl:text><xsl:value-of select="starts-with($ws,' ')"/><xsl:text> """</xsl:text><xsl:value-of select="."/>"""</xsl:comment>
  </xsl:if>-->
  <xsl:if test="$pnode/self::element() and starts-with($ws,' ') and $t!=''">
    <xsl:text> </xsl:text>
  </xsl:if>
  <xsl:value-of select="$t"/>
  <!--<xsl:if test="$snode">
    <xsl:comment>s: <xsl:value-of select="name($snode)"/><xsl:text> </xsl:text><xsl:value-of select="ends-with($ws,' ')"/></xsl:comment>
  </xsl:if>-->
  <xsl:if test="$snode/self::element() and ends-with($ws,' ') and $t!=''">
    <xsl:text> </xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="pi:rfc|pi:rfc-ext" mode="prep-ser">
  <xsl:processing-instruction name="{local-name()}">
    <xsl:choose>
      <xsl:when test="contains(@value,'&quot;')">
        <xsl:value-of select="@name"/><xsl:text>='</xsl:text><xsl:value-of select="@value"/><xsl:text>'</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@name"/><xsl:text>="</xsl:text><xsl:value-of select="@value"/><xsl:text>"</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:processing-instruction>
</xsl:template>

</xsl:transform>