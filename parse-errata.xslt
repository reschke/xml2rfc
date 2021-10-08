<!--
    Parse RFC Editor Errata pages into XML

    Copyright (c) 2017-2021, Julian Reschke (julian.reschke@greenbytes.de)
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
               xmlns:my="#fun"
               xmlns:xp="http://www.w3.org/2005/xpath-functions"
               exclude-result-prefixes="my xp"
>

<xsl:output encoding="UTF-8" indent="yes"/>

<xsl:param name="doc"/>

<!-- name of JSON input file -->
<xsl:param name="json" select="replace($doc,'.rawerrata','.jerrata')"/>

<!-- Read the data -->
<xsl:variable name="jdata" select="json-to-xml(unparsed-text($json))"/>


<xsl:variable name="src" select="/"/>

<xsl:template match="/">
  <!--<xsl:copy-of select="$jdata"/>-->
  <errata for="{substring-before($doc,'.rawerrata')}">
    <xsl:variable name="tmp">
      <xsl:variable name="src" select="unparsed-text($doc)"/>
      <xsl:if test="contains($src,'Errata ID: ')">
        <xsl:variable name="p" select="substring-before($src, 'Errata ID: ')"/>
        <xsl:call-template name="dump">
          <xsl:with-param name="s" select="substring($src, string-length($p))"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:for-each select="$tmp/*">
      <xsl:sort select="number(@eid)"/>
      <xsl:variable name="j" select="$jdata/xp:array/xp:map[xp:number[@key='errata_id']=current()/@eid]"/>
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:copy-of select="*"/>
        <xsl:if test="$j">
          <xsl:if test="@status!=$j/xp:string[@key='errata_status_code']">
            <xsl:comment>@status does not match JSON: <xsl:value-of select="$j/xp:string[@key='errata_status_code']"/></xsl:comment>
          </xsl:if>
          <xsl:if test="@type!=$j/xp:string[@key='errata_type_code']">
            <xsl:comment>@type does not match JSON: <xsl:value-of select="$j/xp:string[@key='errata_type_code']"/></xsl:comment>
          </xsl:if>
          <xsl:if test="@reported-by!=$j/xp:string[@key='submitter_name']">
            <xsl:comment>@reported-by does not match JSON: <xsl:value-of select="$j/xp:string[@key='submitter_name']"/></xsl:comment>
          </xsl:if>
          <xsl:if test="@reported!=$j/xp:string[@key='submit_date']">
            <xsl:comment>@reported does not match JSON: <xsl:value-of select="$j/xp:string[@key='submit_date']"/></xsl:comment>
          </xsl:if>
          <xsl:if test="rawsection!=$j/xp:*[@key='section']">
            <xsl:comment>rawsection does not match JSON: <xsl:value-of select="$j/xp:*[@key='section']"/></xsl:comment>
          </xsl:if>
        </xsl:if>
      </xsl:copy>
    </xsl:for-each>
  </errata>
</xsl:template>

<xsl:template name="dump">
  <xsl:param name="s"/>
  <xsl:variable name="p" select="substring-before(substring($s,7), 'Errata ID: ')"/>
  <xsl:variable name="r" select="substring($s, 6 + string-length($p))"/>
  <xsl:choose>
    <xsl:when test="$p=''">
      <xsl:call-template name="asxml">
        <xsl:with-param name="s" select="$s"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="asxml">
        <xsl:with-param name="s" select="substring($s, 0, 7 + string-length($p))"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:if test="contains($r,'Errata ID:')">
    <xsl:call-template name="dump">
      <xsl:with-param name="s" select="$r"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template name="asxml">
  <xsl:param name="s"/>
  <xsl:variable name="raw-reference">
    <xsl:variable name="t" select="normalize-space(translate($s,'&#13;&#10;&#9;','   '))"/>
    <xsl:analyze-string select="$t" regex="&lt;p>([iI]n )?([Ss]ection|[Aa]ppendix)( [Aa]ppendix)? ((.*?))(, it )?(says|states):( )?&lt;/p> &lt;pre class=.rfctext.">
      <xsl:matching-substring>
        <xsl:value-of select="normalize-space(regex-group(4))"/>
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:variable>
  <xsl:variable name="eid">
    <xsl:analyze-string select="$s" regex="(.*)Errata ID: (&lt;a href=.*>)?([0-9]+)(&lt;/a>)?(.*)">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(3)"/>
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:variable>
  <erratum eid="{$eid}">
    <xsl:analyze-string select="$s" regex="(.*)&lt;b>Status: ([A-Za-z ]*)(.*)">
      <xsl:matching-substring>
        <xsl:attribute name="status" select="regex-group(2)"/>
      </xsl:matching-substring>
    </xsl:analyze-string>
    <xsl:analyze-string select="$s" regex="(.*)Date Reported: (....\-..\-..)(.*)">
      <xsl:matching-substring>
        <xsl:attribute name="reported" select="regex-group(2)"/>
      </xsl:matching-substring>
    </xsl:analyze-string>
    <xsl:analyze-string select="$s" regex="(.*)Reported By: ([^&lt;]*)(.*)">
      <xsl:matching-substring>
        <xsl:attribute name="reported-by" select="regex-group(2)"/>
      </xsl:matching-substring>
    </xsl:analyze-string>
    <xsl:analyze-string select="$s" regex="(.*)&#10;Type: ([a-zA-Z]*)(.*)">
      <xsl:matching-substring>
        <xsl:attribute name="type" select="regex-group(2)"/>
      </xsl:matching-substring>
    </xsl:analyze-string>

    <!-- section reference -->
    <xsl:if test="$raw-reference!=''">
      <raw-section>
        <xsl:value-of select="$raw-reference"/>
      </raw-section>
      <xsl:choose>
        <xsl:when test="contains($raw-reference,'&amp;amp;')">
          <xsl:for-each select="tokenize($raw-reference,'&amp;amp;')">
            <xsl:call-template name="raw-sec-insert">
              <xsl:with-param name="s" select="."/>
              <xsl:with-param name="eid" select="$eid"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="contains($raw-reference,'and')">
          <xsl:for-each select="tokenize($raw-reference,'and')">
            <xsl:call-template name="raw-sec-insert">
              <xsl:with-param name="s" select="."/>
              <xsl:with-param name="eid" select="$eid"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="raw-sec-insert">
            <xsl:with-param name="s" select="$raw-reference"/>
            <xsl:with-param name="eid" select="$eid"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </erratum>
</xsl:template>

<xsl:template name="raw-sec-insert">
  <xsl:param name="s"/>
  <xsl:param name="eid"/>
  <xsl:analyze-string select="normalize-space($s)" regex="(A. )?([a-zA-Z0-9\.]+)(( )(.*))*">
    <xsl:matching-substring>
      <xsl:call-template name="sec-insert">
        <xsl:with-param name="s" select="regex-group(2)"/>
        <xsl:with-param name="eid" select="$eid"/>
      </xsl:call-template>
    </xsl:matching-substring>
  </xsl:analyze-string>
</xsl:template>

<xsl:template name="sec-insert">
  <xsl:param name="s"/>
  <xsl:param name="eid"/>
  <xsl:variable name="l" select="translate($s,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
  <xsl:choose>
    <xsl:when test="$l='nonspecific' or $l='section'">
      <!-- not a section number -->
    </xsl:when>
    <xsl:when test="$l='toc' or $l='boilerplate' or $l='abstract'">
      <xsl:copy-of select="my:section($l,$eid)"/>
    </xsl:when>
    <xsl:when test="ends-with($s,'.')">
      <xsl:copy-of select="my:section(substring($s,0,string-length($s)),$eid)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="my:section($s,$eid)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:function name="my:section">
  <xsl:param name="sec"/>
  <xsl:param name="eid"/>
  <xsl:variable name="mapped" select="$src/annotations/annotation/map-section[../@for-eid=$eid and @from=$sec]"/>
  <section>
    <xsl:if test="$mapped">
      <xsl:attribute name="part"><xsl:value-of select="$mapped/@to-part"/></xsl:attribute>
    </xsl:if>
    <xsl:value-of select="$sec"/>
  </section>
</xsl:function>

</xsl:transform>