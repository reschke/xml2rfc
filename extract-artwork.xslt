<!--
    Extract named artwork or sourcecode elements.

    Copyright (c) 2006-2023, Julian Reschke (julian.reschke@greenbytes.de)
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
               xmlns:x="http://purl.org/net/xml2rfc/ext"
               version="1.0"
>

<xsl:import href="clean-for-DTD.xslt"/>

<xsl:output method="text" encoding="UTF-8"/>

<xsl:param name="name" />
<xsl:param name="except-name" />

<!-- type attribute to match -->
<xsl:param name="type" />

<!-- position to extract -->
<xsl:param name="index" />

<xsl:template match="/" priority="9">
  
  <xsl:choose>
    <xsl:when test="$name!=''">
      <xsl:variable name="artwork" select="//artwork[@name=$name]|//sourcecode[@name=$name]"/>
      
      <xsl:choose>
        <xsl:when test="$artwork">
          <xsl:for-each select="$artwork">
            <xsl:call-template name="process-artwork"/>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>Artwork or sourcecode element named '<xsl:value-of select="$name"/>' not found.</xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="$type!=''">
      <xsl:variable name="artwork" select="//artwork[@type=$type]|//sourcecode[@type=$type]"/>
      
      <xsl:choose>
        <xsl:when test="$artwork">
          <xsl:for-each select="$artwork">
            <xsl:if test="$index='' or position()=$index">
              <xsl:choose>
                <xsl:when test="$except-name!='' and @name=$except-name">
                  <!-- do not emit this one -->
                </xsl:when>
                <xsl:otherwise>
                  <xsl:call-template name="process-artwork"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>Artwork or sourcecode element typed '<xsl:value-of select="$type"/>' not found.</xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message>Please specify either name or type parameter.</xsl:message>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="process-artwork">
  <xsl:value-of select="@x:extraction-note"/>
  <xsl:variable name="c0">
    <xsl:apply-templates select="." mode="cleanup"/>
  </xsl:variable>
  <xsl:variable name="c" select="translate($c0,'&#13;','')"/>
  <xsl:variable name="note-bs">NOTE: '\' line wrapping per RFC 8792&#10;&#10;</xsl:variable>
  <xsl:variable name="note-bsbs">NOTE: '\\' line wrapping per RFC 8792&#10;&#10;</xsl:variable>
  <xsl:variable name="out0">
    <xsl:choose>
      <xsl:when test="@x:line-folding='\' and starts-with($c,$note-bs)">
        <xsl:value-of select="substring-after($c,$note-bs)"/>
      </xsl:when>
      <xsl:when test="@x:line-folding='\\' and starts-with($c,$note-bsbs)">
        <xsl:value-of select="substring-after($c,$note-bsbs)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$c"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="out2">
    <xsl:choose>
      <xsl:when test="@x:line-folding='\'">
        <xsl:call-template name="unfold-content">
          <xsl:with-param name="seq" select="@x:line-folding"/>
          <xsl:with-param name="text" select="$out0"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$out0"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:value-of select="$out2"/>
</xsl:template>

<xsl:template name="unfold-content">
  <xsl:param name="seq"/>
  <xsl:param name="text"/>
  <xsl:variable name="line-end" select="concat($seq,'&#10;')"/>
  <xsl:choose>
    <xsl:when test="contains($text,$line-end)">
      <xsl:value-of select="substring-before($text,$line-end)"/>
      <xsl:call-template name="unfold-content">
        <xsl:with-param name="seq" select="$seq"/>
        <xsl:with-param name="text">
          <xsl:call-template name="eat-leading-sp">
            <xsl:with-param name="text" select="substring-after($text,$line-end)"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise><xsl:value-of select="$text"/></xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="eat-leading-sp">
  <xsl:param name="text"/>
  <xsl:choose>
    <xsl:when test="starts-with($text,' ')">
      <xsl:call-template name="eat-leading-sp">
        <xsl:with-param name="text" select="substring($text,2)"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise><xsl:value-of select="$text"/></xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:transform>