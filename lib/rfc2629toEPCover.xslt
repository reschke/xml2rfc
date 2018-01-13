<!--
    XSLT transformation from RFC2629 XML format to EPub-XHTML

    Copyright (c) 2006-2015, Julian Reschke (julian.reschke@greenbytes.de)
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
               xmlns="http://www.w3.org/1999/xhtml"
               version="1.0">

<xsl:import href="rfc2629toXHTML.xslt"/>

<xsl:output doctype-public="-//W3C//DTD XHTML 1.1//EN" doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd" encoding="UTF-8" method="xml" indent="no"/>

<xsl:template match="/">
  <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
      <title><xsl:value-of select="/rfc/front/title"/></title>
      <link rel="stylesheet" href="rfc2629xslt.css" type="text/css"/>
    </head>
    <body>
      <xsl:if test="/rfc/@number">
        <p class="title">
          <object data="IETF_Logo.svg" type="image/svg+xml"/>
          <br/>
          <br/>
        </p>
        <p class="title">
          RFC <xsl:value-of select="/rfc/@number"/>
        </p>
      </xsl:if>
      <p class="title">
        <xsl:value-of select="/rfc/front/title"/>
        <br/>
        <br/>
        <xsl:for-each select="/rfc/front/author">
          <span class="filename">
            <xsl:value-of select="@fullname"/>
          </span>
          <xsl:if test="position()!=last()">
            <br/>
          </xsl:if>
        </xsl:for-each>
      </p>
    </body>
  </html>
</xsl:template>

</xsl:transform>