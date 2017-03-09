<!--
    Parse RFC Editor Errata pages into XML

    Copyright (c) 2017, Julian Reschke (julian.reschke@greenbytes.de)
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
>

<xsl:output encoding="UTF-8" indent="yes"/>

<xsl:param name="doc"/>

<xsl:template match="/">
  <errata for="{substring-before($doc,'.rawerrata')}">
    <xsl:variable name="src" select="unparsed-text($doc)"/>
    <xsl:if test="contains($src,'Errata ID: ')">
      <xsl:variable name="p" select="substring-before($src, 'Errata ID: ')"/>
      <xsl:call-template name="dump">
        <xsl:with-param name="s" select="substring($src, string-length($p))"/>
      </xsl:call-template>
    </xsl:if>
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
  <erratum>
    <xsl:analyze-string select="$s" regex="(.*)Errata ID: ([0-9]+)(.*)">
      <xsl:matching-substring>
        <xsl:attribute name="eid" select="regex-group(2)"/>
      </xsl:matching-substring>
    </xsl:analyze-string>
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
    <xsl:analyze-string select="$s" regex="(.*)Reported By: ([a-zA-Z\. ]*)(.*)">
      <xsl:matching-substring>
        <xsl:attribute name="reported-by" select="regex-group(2)"/>
      </xsl:matching-substring>
    </xsl:analyze-string>
    <xsl:analyze-string select="$s" regex="(.*)Type: ([a-zA-Z]*)(.*)">
      <xsl:matching-substring>
        <xsl:attribute name="type" select="regex-group(2)"/>
      </xsl:matching-substring>
    </xsl:analyze-string>

    <!-- section reference -->
    <xsl:if test="$raw-reference!=''">
      <raw-section>
        <xsl:value-of select="$raw-reference"/>
      </raw-section>
      <xsl:analyze-string select="$raw-reference" regex="([a-zA-Z0-9\.]+)(( )(.*))*">
        <xsl:matching-substring>
          <xsl:call-template name="sec-insert">
            <xsl:with-param name="s" select="regex-group(1)"/>
          </xsl:call-template>
        </xsl:matching-substring>
      </xsl:analyze-string>
    </xsl:if>
  </erratum>
</xsl:template>

<xsl:template name="sec-insert">
  <xsl:param name="s"/>
  <xsl:variable name="l" select="translate($s,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
  <xsl:choose>
    <xsl:when test="$l='nonspecific'">
      <!-- not a section number -->
    </xsl:when>
    <xsl:when test="$l='toc' or $l='boilerplate'">
      <section><xsl:value-of select="$l"/></section>
    </xsl:when>
    <xsl:when test="ends-with($s,'.')">
      <section><xsl:value-of select="substring($s,0,string-length($s))"/></section>
    </xsl:when>
    <xsl:otherwise>
      <section><xsl:value-of select="$s"/></section>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:transform>