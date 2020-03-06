<!--
    Augment section links to RFCs and Internet Drafts, also cleanup 
    unneeded markup from kramdown2629

    Copyright (c) 2017-2020, Julian Reschke (julian.reschke@greenbytes.de)
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
               xmlns:x="http://purl.org/net/xml2rfc/ext"
>

<xsl:strip-space elements="abstract aside author address back dl front list middle note ol postal references reference rfc section table tbody thead tr ul"/>
<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" doctype-system=""/>

<!-- white-space separated list of specs which should be linked directly to -->
<xsl:param name="sibling-specs"/>

<!-- URI template for feedback, as described in https://www.greenbytes.de/tech/webdav/rfc2629xslt/rfc2629xslt.html#ext.element.feedback -->
<xsl:param name="feedback"/>

<xsl:template match="/">
  <xsl:variable name="t0">
    <xsl:apply-templates mode="refs-in-artwork"/>
  </xsl:variable>
  <xsl:variable name="t1">
    <xsl:for-each select="$t0">
      <xsl:apply-templates mode="insert-refs"/>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="t2">
    <xsl:for-each select="$t1">
      <xsl:apply-templates mode="strip-and-annotate-refs"/>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="t3">
    <xsl:for-each select="$t2">
      <xsl:apply-templates mode="remove-kramdownleftovers"/>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="t4">
    <xsl:for-each select="$t3">
      <xsl:apply-templates mode="link-sibling-specs"/>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="t5">
    <xsl:for-each select="$t4">
      <xsl:apply-templates mode="insert-feedback"/>
    </xsl:for-each>
  </xsl:variable>
  <xsl:for-each select="$t5">
    <xsl:apply-templates mode="insert-prettyprint"/>
  </xsl:for-each>
</xsl:template>

<xsl:template match="*|@*|comment()|processing-instruction()">
  <xsl:copy><xsl:apply-templates select="node()|@*"/></xsl:copy>
</xsl:template>

<xsl:template match="rfc" mode="insert-refs">
  <rfc xmlns:x="http://purl.org/net/xml2rfc/ext">
    <xsl:apply-templates select="node()|@*" mode="insert-refs"/>
  </rfc>
</xsl:template>

<xsl:template match="*|@*|comment()|processing-instruction()" mode="insert-refs">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="insert-refs"/></xsl:copy>
</xsl:template>

<xsl:template name="get-section-number">
  <xsl:choose>
    <xsl:when test="self::section and parent::back"><xsl:number count="section" format="a"/></xsl:when>
    <xsl:when test="self::section and parent::middle"><xsl:number count="section"/></xsl:when>
    <xsl:when test="self::section"><xsl:for-each select=".."><xsl:call-template name="get-section-number"/></xsl:for-each>.<xsl:number count="section"/></xsl:when>
    <xsl:otherwise/>
  </xsl:choose>
</xsl:template>

<xsl:template name="insert-target-metadata">
  <xsl:param name="file"/>
  <xsl:param name="sec"/>
  <xsl:if test="contains(concat(' ',$sibling-specs,' '),concat(' ',$file,' '))">
    <xsl:variable name="src" select="document(concat($file,'.xml'))"/>
    <xsl:if test="$src/rfc">
      <!-- find target section -->
      <xsl:for-each select="$src/rfc//section">
        <xsl:variable name="n">
          <xsl:call-template name="get-section-number"/>
        </xsl:variable>
        <xsl:if test="$n=$sec">
          <xsl:if test="@anchor">
            <xsl:processing-instruction name="aug-anchor"><xsl:value-of select="@anchor"/></xsl:processing-instruction>
          </xsl:if>
          <xsl:processing-instruction name="aug-title"><xsl:value-of select="@title"/></xsl:processing-instruction>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>
  </xsl:if>
</xsl:template>

<xsl:template match="text()" mode="insert-refs">
  <xsl:variable name="ts" select="following-sibling::*[1]"/>
  <xsl:variable name="s" select="$ts[self::xref and not(text()) and (not(@format) or @format='default') and //reference[@anchor=$ts/@target]]"/>
  <xsl:variable name="tp" select="preceding-sibling::*[1]"/>
  <xsl:variable name="p" select="$tp[self::xref and not(text()) and (not(@format) or @format='default') and //reference[@anchor=$tp/@target]]"/>
  <xsl:variable name="secnum">([0-9A-Z]+(\.[0-9A-Z]+)*)</xsl:variable>
  <xsl:variable name="sp">(.*)(Section|Appendix)\s+<xsl:value-of select="$secnum"/>\s+of\s*$</xsl:variable>
  <xsl:variable name="sp2">((.*)(Sections|Appendices|Section|Appendix)\s+)<xsl:value-of select="$secnum"/>\s+and\s+(<xsl:value-of select="$secnum"/>*)\s+of\s*$</xsl:variable>
  <xsl:variable name="pp">^,\s+(Section|Appendix)\s+<xsl:value-of select="$secnum"/>(.*)</xsl:variable>
  <xsl:variable name="pp2">^(,\s+(Sections|Appendices|Section|Appendix)\s+)<xsl:value-of select="$secnum"/>\s+and\s+<xsl:value-of select="$secnum"/>(.*)</xsl:variable>
  <xsl:variable name="bad1">^\s+(Section|Appendix)\s+(<xsl:value-of select="$secnum"/>*)(.*)</xsl:variable>
  <xsl:variable name="bad2">^;\s+(Section|Appendix)\s+(<xsl:value-of select="$secnum"/>*)(.*)</xsl:variable>
  <xsl:choose>
    <xsl:when test="$s and matches(., $sp,'s')">
      <xsl:variable name="reftarget" select="//reference[@anchor=$s/@target]"/>
      <xsl:choose>
        <xsl:when test="$reftarget and $reftarget[seriesInfo/@name='RFC' or seriesInfo/@name='Internet-Draft']">
          <xsl:value-of select="replace(., $sp, '$1', 's')"/><xref INSERT="following" target="{$s/@target}" x:fmt="of" x:sec="{replace(., $sp, '$3', 's')}"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="$s and matches(., $sp2,'s')">
      <xsl:variable name="reftarget" select="//reference[@anchor=$s/@target]"/>
      <xsl:choose>
        <xsl:when test="$reftarget and $reftarget[seriesInfo/@name='RFC' or seriesInfo/@name='Internet-Draft']">
          <xsl:value-of select="replace(., $sp2, '$1', 's')"/>
          <xref target="{$s/@target}" x:fmt="number" x:sec="{replace(., $sp2, '$4', 's')}"/>
          <xsl:text> and </xsl:text>
          <xref target="{$s/@target}" x:fmt="number" x:sec="{replace(., $sp2, '$6', 's')}"/>
          <xsl:text> of </xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="$p and matches(., $pp2,'s')">
      <xsl:variable name="reftarget" select="//reference[@anchor=$p/@target]"/>
      <xsl:choose>
        <xsl:when test="$reftarget and $reftarget[seriesInfo/@name='RFC' or seriesInfo/@name='Internet-Draft']">
          <xsl:value-of select="replace(., $pp2, '$1', 's')"/>
          <xref target="{$p/@target}" x:fmt="number" x:sec="{replace(., $pp2, '$3', 's')}"/>
          <xsl:text> and </xsl:text>
          <xref target="{$p/@target}" x:fmt="number" x:sec="{replace(., $pp2, '$5', 's')}"/>
          <xsl:value-of select="replace(., $pp2, '$7', 's')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="$p and matches(., $pp,'s')">
      <xsl:variable name="reftarget" select="//reference[@anchor=$p/@target]"/>
      <xsl:choose>
        <xsl:when test="$reftarget and $reftarget[seriesInfo/@name='RFC' or seriesInfo/@name='Internet-Draft']">
          <xref INSERT="preceding" target="{$p/@target}" x:fmt="," x:sec="{replace(., $pp, '$2', 's')}"/><xsl:value-of select="replace(., $pp, '$4', 's')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="$p and matches(., $bad1,'s')">
      <xsl:variable name="reftarget" select="//reference[@anchor=$p/@target]"/>
      <xsl:choose>
        <xsl:when test="$reftarget and $reftarget[seriesInfo/@name='RFC' or seriesInfo/@name='Internet-Draft']">
          <xsl:message>INFO: weirdly formatted section xref to <xsl:value-of select="$p/@target"/>: <xsl:value-of select="replace(., $bad1, '$2', 's')"/>, converting anyway</xsl:message>
          <xref target="{$p/@target}" x:fmt="sec" x:sec="{replace(., $bad1, '$2', 's')}"/><xsl:value-of select="replace(., $bad1, '$5', 's')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="$p and matches(., $bad2,'s')">
      <xsl:variable name="reftarget" select="//reference[@anchor=$p/@target]"/>
      <xsl:choose>
        <xsl:when test="$reftarget and $reftarget[seriesInfo/@name='RFC' or seriesInfo/@name='Internet-Draft']">
          <xsl:message>INFO: weirdly formatted section xref to <xsl:value-of select="$p/@target"/>: <xsl:value-of select="replace(., $bad2, '$2', 's')"/>, converting anyway</xsl:message>
          <xsl:text>; </xsl:text><xref target="{$p/@target}" x:fmt="sec" x:sec="{replace(., $bad2, '$2', 's')}"/><xsl:value-of select="replace(., $bad2, '$5', 's')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="."/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*|@*|comment()|processing-instruction()" mode="strip-and-annotate-refs">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="strip-and-annotate-refs"/></xsl:copy>
</xsl:template>

<xsl:template match="xref[not(node())]" mode="strip-and-annotate-refs">
  <xsl:variable name="fx" select="following-sibling::*[1]"/>
  <xsl:variable name="f" select="$fx[self::xref and @INSERT='preceding']"/>
  <xsl:variable name="px" select="preceding-sibling::*[1]"/>
  <xsl:variable name="p" select="$px[self::xref and @INSERT='following']"/>
  <xsl:choose>
    <xsl:when test="$f or $p"/>
    <xsl:otherwise>
      <xsl:copy>
        <xsl:apply-templates select="@*" mode="strip-and-annotate-refs"/>
        <xsl:variable name="reftarget" select="//reference[@anchor=current()/@target]"/>
        <xsl:if test="@x:sec">
          <xsl:call-template name="insert-target-metadata">
            <xsl:with-param name="file" select="$reftarget/seriesInfo[@name='RFC' or @name='Internet-Draft']/@value"/>
            <xsl:with-param name="sec" select="@x:sec"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:apply-templates select="node()" mode="strip-and-annotate-refs"/>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="xref/@INSERT" mode="strip-and-annotate-refs"/>

<xsl:template match="*|@*|comment()|processing-instruction()" mode="remove-kramdownleftovers">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="remove-kramdownleftovers"/></xsl:copy>
</xsl:template>

<xsl:template match="artwork/@align[.='left']" mode="remove-kramdownleftovers"/>
<xsl:template match="artwork/@alt[.='']" mode="remove-kramdownleftovers"/>
<xsl:template match="artwork/@height[.='']" mode="remove-kramdownleftovers"/>
<xsl:template match="artwork/@name[.='']" mode="remove-kramdownleftovers"/>
<xsl:template match="artwork/@type[.='']" mode="remove-kramdownleftovers"/>
<xsl:template match="artwork/@width[.='']" mode="remove-kramdownleftovers"/>
<xsl:template match="artwork/@xml:space[.='preserve']" mode="remove-kramdownleftovers"/>
<xsl:template match="comment()[contains(.,'markdown-source')]" mode="remove-kramdownleftovers"/>
<xsl:template match="figure/@align[.='left']" mode="remove-kramdownleftovers"/>
<xsl:template match="figure/@alt[.='']" mode="remove-kramdownleftovers"/>
<xsl:template match="figure/@height[.='']" mode="remove-kramdownleftovers"/>
<xsl:template match="figure/@suppress-title[.='false']" mode="remove-kramdownleftovers"/>
<xsl:template match="figure/@title[.='']" mode="remove-kramdownleftovers"/>
<xsl:template match="figure/@width[.='']" mode="remove-kramdownleftovers"/>
<xsl:template match="organization[.='']" mode="remove-kramdownleftovers"/>
<xsl:template match="rfc/@obsoletes[.='']" mode="remove-kramdownleftovers"/>
<xsl:template match="rfc/@updates[.='']" mode="remove-kramdownleftovers"/>
<xsl:template match="rfc/@xml:lang[.='en']" mode="remove-kramdownleftovers"/>
<xsl:template match="reference/front/abstract" mode="remove-kramdownleftovers"/>
<xsl:template match="reference/format" mode="remove-kramdownleftovers"/>
<xsl:template match="section/@toc[.='default']" mode="remove-kramdownleftovers"/>
<xsl:template match="spanx/@style[.='emph']" mode="remove-kramdownleftovers"/>
<xsl:template match="spanx/@xml:space[.='preserve']" mode="remove-kramdownleftovers"/>
<xsl:template match="texttable/@align[.='center']" mode="remove-kramdownleftovers"/>
<xsl:template match="texttable/@style[.='full']" mode="remove-kramdownleftovers"/>
<xsl:template match="texttable/@suppress-title[.='false']" mode="remove-kramdownleftovers"/>
<xsl:template match="texttable/@title[.='']" mode="remove-kramdownleftovers"/>
<xsl:template match="xref/@format[.='default']" mode="remove-kramdownleftovers"/>
<xsl:template match="xref/@pageno[.='false']" mode="remove-kramdownleftovers"/>

<xsl:template match="reference[seriesInfo/@name='RFC']/@target[starts-with(.,'http://www.rfc-editor.org/info/') or starts-with(.,'https://www.rfc-editor.org/info/')]" mode="remove-kramdownleftovers">
  <xsl:variable name="rsi" select="../seriesInfo[@name='RFC']"/>
  <xsl:variable name="no" select="$rsi/@value"/>
  <xsl:if test=". != concat('http://www.rfc-editor.org/info/rfc',$no) and . != concat('https://www.rfc-editor.org/info/rfc',$no)">
    <xsl:copy/>
  </xsl:if>
</xsl:template>

<xsl:template match="*|@*|comment()|processing-instruction()" mode="link-sibling-specs">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="link-sibling-specs"/></xsl:copy>
</xsl:template>

<xsl:template match="reference" mode="link-sibling-specs">
  <xsl:copy>
    <xsl:apply-templates select="node()|@*" mode="link-sibling-specs"/>
    <xsl:variable name="draftName" select="normalize-space(seriesInfo[@name='Internet-Draft']/@value)"/>
    <xsl:if test="not(x:source) and $draftName!='' and contains(concat(' ',normalize-space($sibling-specs),' '), $draftName)">
      <x:source href="{$draftName}.xml" basename="{$draftName}"/>
    </xsl:if>
  </xsl:copy>
</xsl:template>

<xsl:template match="*|@*|comment()|processing-instruction()" mode="insert-feedback">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="insert-feedback"/></xsl:copy>
</xsl:template>

<xsl:template match="rfc" mode="insert-feedback">
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="insert-feedback"/>
    <xsl:if test="$feedback!='' and not(x:feedback)">
      <x:feedback template="{$feedback}"/>
    </xsl:if>
    <xsl:apply-templates select="node()" mode="insert-feedback"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="*|@*|comment()|processing-instruction()" mode="insert-prettyprint">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="insert-prettyprint"/></xsl:copy>
</xsl:template>

<xsl:template match="rfc" mode="insert-prettyprint">
  <xsl:processing-instruction name="rfc-ext">html-pretty-print="prettyprint https://cdn.rawgit.com/google/code-prettify/master/loader/run_prettify.js"</xsl:processing-instruction>
  <xsl:text>&#10;</xsl:text>
  <xsl:copy-of select="."/>
</xsl:template>

<xsl:template match="*|@*|comment()|processing-instruction()" mode="refs-in-artwork">
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="refs-in-artwork"/></xsl:copy>
</xsl:template>

<xsl:template match="rfc" mode="refs-in-artwork">
  <!-- check whether we need to -->
  <xsl:variable name="refs">
    <xsl:for-each select="//artwork[not(*)][@type='abnf']|//sourcecode[not(*)][@type='abnf']">
      <xsl:variable name="text" select="."/>
      <xsl:for-each select="//reference">
        <xsl:variable name="checkfor" select="concat('[',@anchor,']')"/>
        <xsl:if test="$text[contains(.,$checkfor)]">
          <xsl:value-of select="$checkfor"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:variable>
  <xsl:if test="$refs!=''">
    <xsl:processing-instruction name="rfc-ext">allow-markup-in-artwork="yes"</xsl:processing-instruction>
  </xsl:if>
  <xsl:text>&#10;</xsl:text>
  <xsl:copy><xsl:apply-templates select="node()|@*" mode="refs-in-artwork"/></xsl:copy>
</xsl:template>

<xsl:template match="artwork[not(*)][@type='abnf']|sourcecode[not(*)][@type='abnf']" mode="refs-in-artwork">
  <xsl:variable name="text" select="."/>
  <xsl:variable name="refs">
    <xsl:for-each select="//reference">
      <xsl:variable name="checkfor" select="concat('[',@anchor,']')"/>
      <xsl:if test="$text[contains(.,$checkfor)]">
        <xsl:value-of select="$checkfor"/><xsl:text> </xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="$refs!=''">
      <xsl:copy>
        <xsl:apply-templates select="@*" mode="refs-in-artwork"/>
        <xsl:call-template name="refs-in-artwork">
          <xsl:with-param name="refs" select="$refs"/>
        </xsl:call-template>
      </xsl:copy>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy><xsl:apply-templates select="node()|@*" mode="refs-in-artwork"/></xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="refs-in-artwork">
  <xsl:param name="refs"/>
  <xsl:param name="text" select="."/>
  <xsl:choose>
    <xsl:when test="contains($text,'&#10;')">
      <xsl:call-template name="refs-in-artwork-line">
        <xsl:with-param name="refs" select="$refs"/>
        <xsl:with-param name="text" select="substring-before($text,'&#10;')"/>
      </xsl:call-template>
      <xsl:text>&#10;</xsl:text>
      <xsl:call-template name="refs-in-artwork">
        <xsl:with-param name="refs" select="$refs"/>
        <xsl:with-param name="text" select="substring-after($text,'&#10;')"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="refs-in-artwork-line">
        <xsl:with-param name="refs" select="$refs"/>
        <xsl:with-param name="text" select="$text"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="refs-in-artwork-line">
  <xsl:param name="refs"/>
  <xsl:param name="text"/>
  <xsl:choose>
    <xsl:when test="contains($text,'; ')">
      <xsl:value-of select="substring-before($text,'; ')"/>
      <xsl:text>; </xsl:text>
      <xsl:call-template name="refs-in-artwork-comment">
        <xsl:with-param name="refs" select="$refs"/>
        <xsl:with-param name="text" select="substring-after($text,'; ')"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="contains($text,' &lt;')">
      <xsl:value-of select="substring-before($text,' &lt;')"/>
      <xsl:text> &lt;</xsl:text>
      <xsl:call-template name="refs-in-artwork-comment">
        <xsl:with-param name="refs" select="$refs"/>
        <xsl:with-param name="text" select="substring-after($text,' &lt;')"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$text"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="refs-in-artwork-comment">
  <xsl:param name="refs"/>
  <xsl:param name="text"/>
  <xsl:variable name="after-open" select="substring-after($text,'[')"/>
  <xsl:choose>
    <xsl:when test="$after-open!=''">
      <xsl:value-of select="substring-before($text,'[')"/>
      <xsl:variable name="contents" select="substring-before($after-open,']')"/>
      <xsl:variable name="check-for" select="concat('[',$contents,']')"/>
      <xsl:choose>
        <xsl:when test="contains($refs,$check-for)">
          <xref target="{$contents}"/>
          <xsl:call-template name="refs-in-artwork-comment">
            <xsl:with-param name="refs" select="$refs"/>
            <xsl:with-param name="text" select="substring-after($text,']')"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>[</xsl:text>
          <xsl:call-template name="refs-in-artwork-comment">
            <xsl:with-param name="refs" select="$refs"/>
            <xsl:with-param name="text" select="substring-after($text,'[')"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$text"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:transform>

