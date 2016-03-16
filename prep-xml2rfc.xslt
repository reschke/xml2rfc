<!--
    Experimental implementation of xml2rfc v3 preptool

    Copyright (c) 2016, Julian Reschke (julian.reschke@greenbytes.de)
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
               exclude-result-prefixes="f"
>

<xsl:import href="rfc2629.xslt" />

<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" doctype-system=""/>

<xsl:param name="steps" select="'boilerplate tables deprecation slug pn'"/>

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
        <xsl:when test="$s='boilerplate'">
          <xsl:message>Step: boilerplate</xsl:message>
          <xsl:apply-templates select="$nodes" mode="prep-boilerplate"/>
        </xsl:when>
        <xsl:when test="$s='deprecation'">
          <xsl:message>Step: deprecation</xsl:message>
          <xsl:apply-templates select="$nodes" mode="prep-deprecation"/>
        </xsl:when>
        <xsl:when test="$s='listextract'">
          <xsl:message>Step: listextract</xsl:message>
          <xsl:apply-templates select="$nodes" mode="prep-listextract"/>
        </xsl:when>
        <xsl:when test="$s='pn'">
          <xsl:message>Step: pn</xsl:message>
          <xsl:apply-templates select="$nodes" mode="prep-pn"/>
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

<!-- boilerplate step -->

<xsl:template match="/rfc/front" mode="prep-boilerplate">
  <xsl:copy>
    <xsl:apply-templates select="node()|@*" mode="prep-boilerplate"/>
    <xsl:call-template name="insertPreamble"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="node()|@*" mode="prep-boilerplate">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="prep-boilerplate"/></xsl:copy>
</xsl:template>

<!-- deprecation step -->

<xsl:template match="node()|@*" mode="prep-deprecation">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="prep-deprecation"/></xsl:copy>
</xsl:template>

<xsl:template match="xref/@pageno" mode="prep-deprecation">
  <xsl:call-template name="info">
    <xsl:with-param name="msg" select="'pageno attribute removed'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="@title" mode="prep-deprecation">
  <!-- converted elsewhere to name element -->
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
    <xsl:apply-templates select="@*" mode="prep-deprecation"/>
    <xsl:if test="@title!=''">
      <xsl:choose>
        <xsl:when test="name">
          <!-- error -->
        </xsl:when>
        <xsl:otherwise>
          <name><xsl:value-of select="@title"/></name>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:apply-templates select="node()" mode="prep-deprecation"/>
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

<xsl:template match="note" mode="prep-deprecation">
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="prep-deprecation"/>
    <xsl:if test="@title!=''">
      <xsl:choose>
        <xsl:when test="name">
          <!-- error -->
        </xsl:when>
        <xsl:otherwise>
          <name><xsl:value-of select="@title"/></name>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:apply-templates select="node()" mode="prep-deprecation"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="references" mode="prep-deprecation">
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="prep-deprecation"/>
    <xsl:if test="@title!=''">
      <xsl:choose>
        <xsl:when test="name">
          <!-- error -->
        </xsl:when>
        <xsl:otherwise>
          <name><xsl:value-of select="@title"/></name>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:apply-templates select="node()" mode="prep-deprecation"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="section" mode="prep-deprecation">
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="prep-deprecation"/>
    <xsl:if test="@title!=''">
      <xsl:choose>
        <xsl:when test="name">
          <!-- error -->
        </xsl:when>
        <xsl:otherwise>
          <name><xsl:value-of select="@title"/></name>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:apply-templates select="node()" mode="prep-deprecation"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="texttable" mode="prep-deprecation">
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="prep-deprecation"/>
    <xsl:if test="@title!=''">
      <xsl:choose>
        <xsl:when test="name">
          <!-- error -->
        </xsl:when>
        <xsl:otherwise>
          <name><xsl:value-of select="@title"/></name>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:apply-templates select="node()" mode="prep-deprecation"/>
  </xsl:copy>
</xsl:template>

<!-- listextract step -->

<!-- https://www.w3.org/TR/xslt-30/#grouping-examples -->
<xsl:template match="t[list]" mode="prep-listextract">
  <xsl:for-each-group select="node()[not(self::text()) or normalize-space(.)!='']" group-adjacent="boolean(self::list)">
    <xsl:choose>
      <xsl:when test="current-grouping-key()">
        <t>
          <xsl:copy-of select="current-group()"/>  
        </t>
      </xsl:when>
      <xsl:otherwise>
        <t>
          <xsl:copy-of select="current-group()"/>
        </t>
      </xsl:otherwise>  
    </xsl:choose>
  </xsl:for-each-group>
</xsl:template>

<xsl:template match="node()|@*" mode="prep-listextract">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="prep-listextract"/></xsl:copy>
</xsl:template>

<!-- slug step -->

<xsl:template match="name" mode="prep-slug">
  <xsl:param name="root"/>
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="prep-slug">
      <xsl:with-param name="root" select="$root"/>
    </xsl:apply-templates>
    <xsl:if test="not(../@anchor)">
      <xsl:variable name="fr">ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.()-_ :%,/=&lt;&gt;</xsl:variable>
      <xsl:variable name="to">abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz0123456789.----------=-</xsl:variable>
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
    </xsl:if>
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

<!-- pn step -->

<xsl:template match="node()|@*" mode="prep-pn">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="prep-pn"/></xsl:copy>
</xsl:template>

<xsl:template match="@pn" mode="prep-pn"/>

<xsl:template name="pn-sn">
  <xsl:choose>
    <xsl:when test="self::abstract">s-abstract</xsl:when>
    <xsl:when test="self::boilerplate">s-boilerplate</xsl:when>
    <xsl:when test="self::figure">f-<xsl:number count="figure" level="any"/></xsl:when>
    <xsl:when test="self::note">s-note-<xsl:number count="note"/></xsl:when>
    <xsl:when test="self::table">t-<xsl:number count="table" level="any"/></xsl:when>
    <xsl:when test="self::references">
      <xsl:text>s-</xsl:text>
      <xsl:value-of select="1 + count(../../middle/section)"/>
      <xsl:if test="count(../references)!=1">
        <xsl:text>.</xsl:text>
        <xsl:value-of select="1 + count(preceding-sibling::references)"/>
      </xsl:if>
    </xsl:when>
    <xsl:when test="self::section and parent::back">s-<xsl:number count="section" format="a"/></xsl:when>
    <xsl:when test="self::section and parent::middle">s-<xsl:number count="section"/></xsl:when>
    <xsl:when test="self::section"><xsl:for-each select=".."><xsl:call-template name="pn-sn"/></xsl:for-each>.<xsl:number count="section"/></xsl:when>
    <xsl:otherwise/>
  </xsl:choose>
</xsl:template>

<xsl:template match="abstract|boilerplate|figure|note|references|section|table" mode="prep-pn">
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="prep-ser"/>
    <xsl:attribute name="pn"><xsl:call-template name="pn-sn"/></xsl:attribute>
    <xsl:apply-templates select="node()|@*" mode="prep-pn"/>
  </xsl:copy>
</xsl:template>

<!--<xsl:template match="section/*[not(self::figure or self::iref or self::name or self::table)]" mode="prep-pn">
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="prep-ser"/>
    <xsl:variable name="parent"><xsl:for-each select=".."><xsl:call-template name="pn-sn"/></xsl:for-each></xsl:variable>
    <xsl:attribute name="pn">p<xsl:value-of select="substring($parent,2)"/>-<xsl:number count="*[not(self::figure or self::iref or self::name or self::table)]"/></xsl:attribute>
    <xsl:apply-templates select="node()|@*" mode="prep-pn"/>
  </xsl:copy>
</xsl:template>-->

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

<!-- final serialization step -->

<xsl:template match="node()|@*" mode="prep-ser">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="prep-ser"/></xsl:copy>
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
  <xsl:if test="$pnode/self::element() and starts-with($ws,' ')">
    <xsl:text> </xsl:text>
  </xsl:if>
  <xsl:value-of select="$t"/>
  <!--<xsl:if test="$snode">
    <xsl:comment>s: <xsl:value-of select="name($snode)"/><xsl:text> </xsl:text><xsl:value-of select="ends-with($ws,' ')"/></xsl:comment>
  </xsl:if>-->
  <xsl:if test="$snode/self::element() and ends-with($ws,' ')">
    <xsl:text> </xsl:text>
  </xsl:if>
</xsl:template>

</xsl:transform>