<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xhtml="http://www.w3.org/1999/xhtml">
    <xsl:output indent="no" method="xml" />

    <!-- Variables -->
    <!-- $xsltId is present only if transforming a template, not for dynamically generated XHTML -->
    <!-- realm styles scripts layout -->
    <xsl:variable name="systemId" select="base-uri()" />
    <xsl:variable name="layout_xhtml" select="document($layout)" />
    <xsl:variable name="layout_html" select="$layout_xhtml/xhtml:html|$layout_xhtml/html" />
    <xsl:variable name="layout_head" select="$layout_xhtml/xhtml:html/xhtml:head|$layout_xhtml/html/head" />
    <xsl:variable name="layout_body" select="$layout_xhtml/xhtml:html/xhtml:body|$layout_xhtml/html/body" />
    <xsl:variable name="template_body" select="/xhtml:html/xhtml:body|/html/body" />
    <xsl:variable name="origin">
        <xsl:if test="contains($xsltId,'://')">
            <xsl:value-of select="concat(substring-before($xsltId,'://'),'://',substring-before(substring-after($xsltId,'://'),'/'),'/')" />
        </xsl:if>
    </xsl:variable>
    <xsl:variable name="callback">
        <xsl:choose>
            <xsl:when test="starts-with($systemId,$origin)">
                <xsl:value-of select="$systemId" />
            </xsl:when>
            <xsl:when test="$origin and $systemId">
                <xsl:call-template name="divert">
                    <xsl:with-param name="diverted" select="concat($origin,'diverted;')" />
                    <xsl:with-param name="url" select="$systemId" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$systemId" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <!-- Template -->
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="@*|*|text()|comment()" />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*|comment()|text()">
        <xsl:copy />
    </xsl:template>

    <xsl:template match="@src|@href|@about|@resource">
        <xsl:attribute name="{name()}">
            <xsl:call-template name="resolve-path">
                <xsl:with-param name="relative" select="." />
                <xsl:with-param name="base" select="base-uri(.)" />
            </xsl:call-template>
        </xsl:attribute>
    </xsl:template>

    <!-- head -->
    <xsl:template match="head|xhtml:head">
        <xsl:copy>
            <xsl:call-template name="merge-attributes">
                <xsl:with-param name="one" select="." />
                <xsl:with-param name="two" select="$layout_head" />
            </xsl:call-template>
            <xsl:apply-templates mode="layout" select="$layout_head/*[local-name()='meta']" />
            <xsl:apply-templates mode="layout" select="$layout_head/*[local-name()!='script' and local-name()!='title' and local-name()!='meta']|$layout_head/comment()|$layout_head/text()" />
            <xsl:apply-templates select="*[local-name()!='script']|comment()|text()" />

            <script type="text/javascript" src="{$scripts}/web_bundle?source">&#160;</script>
            <xsl:if test="//form|//xhtml:form">
                <script type="text/javascript" src="{$scripts}/form_bundle?source">&#160;</script>
            </xsl:if>
            <xsl:apply-templates mode="layout" select="$layout_head/*[local-name()='script']" />
            <xsl:apply-templates select="*[local-name()='script']" />
        </xsl:copy>
    </xsl:template>

    <!-- body -->
    <xsl:template match="body|xhtml:body">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="//@id='sidebar'">
                    <xsl:call-template name="merge-attributes">
                        <xsl:with-param name="one" select="." />
                        <xsl:with-param name="two" select="$layout_body" />
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="merge-attributes">
                        <xsl:with-param name="one" select="." />
                        <xsl:with-param name="two" select="$layout_body" />
                        <xsl:with-param name="class" select="'nosidebar'" />
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates mode="layout" select="$layout_body/*|$layout_body/text()|$layout_body/comment()" />
            <xsl:if test="not($layout_body)">
                <xsl:apply-templates select="*|text()|comment()" />
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <!-- form -->
    <xsl:template match="form|xhtml:form">
        <xsl:apply-templates mode="form" select="." />
    </xsl:template>

    <!-- Form -->
    <xsl:template mode="form" match="*">
        <xsl:copy>
            <xsl:call-template name="data-attributes" />
            <xsl:apply-templates mode="form" select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template mode="form" match="@*|comment()|text()">
        <xsl:copy />
    </xsl:template>

    <xsl:template mode="form" match="@src|@href|@about|@resource">
        <xsl:attribute name="{name()}">
            <xsl:call-template name="resolve-path">
                <xsl:with-param name="relative" select="." />
                <xsl:with-param name="base" select="base-uri(.)" />
            </xsl:call-template>
        </xsl:attribute>
    </xsl:template>

    <xsl:template name="data-attributes">
        <xsl:if test="$callback">
            <xsl:apply-templates mode="data-var" select="@*"/>
            <xsl:apply-templates mode="data-expression" select="@*"/>
            <xsl:if test="text() and not(*|comment())">
                <xsl:call-template name="data-text-expression">
                    <xsl:with-param name="text" select="string(.)"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="xhtml:option[@selected='selected'][@about or @resource] or xhtml:label[@about or @resource]/xhtml:input[@checked='checked']">
                <xsl:if test=".//*[@typeof or @rel and @resource and not(starts-with(@resource,'?')) or @rev and @resource and not(starts-with(@resource,'?'))]">
                    <xsl:if test="not(@data-options)">
                        <!-- Called to populate select/radio/checkbox -->
                        <xsl:attribute name="data-options">
                            <xsl:value-of select="$callback" />
                            <xsl:text>?options&amp;element=</xsl:text>
                            <xsl:apply-templates mode="xptr-element" select="." />
                        </xsl:attribute>
                    </xsl:if>
                </xsl:if>
            </xsl:if>
            <xsl:if test="*[@about or @resource] and not(@data-construct)">
                <!-- Called when a resource URI is dropped to construct its label -->
                <xsl:attribute name="data-construct">
                    <xsl:value-of select="$callback" />
                    <xsl:text>?options&amp;element=</xsl:text>
                    <xsl:apply-templates mode="xptr-element" select="." />
                    <xsl:text>&amp;resource={resource}</xsl:text>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="*[@about or @resource] and not(@data-search)">
                <!-- Lookup possible members by label -->
                <xsl:attribute name="data-search">
                    <xsl:value-of select="$callback" />
                    <xsl:text>?options&amp;element=</xsl:text>
                    <xsl:apply-templates mode="xptr-element" select="." />
                    <xsl:text>&amp;q={searchTerms}</xsl:text>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="*[@about or @typeof or @resource or @property] and not(@data-add)">
                <!-- Called to insert another property value or node -->
                <xsl:attribute name="data-add">
                    <xsl:value-of select="$callback" />
                    <xsl:text>?element=</xsl:text>
                    <xsl:apply-templates mode="xptr-element" select="." />
                    <xsl:text>&amp;realm=</xsl:text>
                    <xsl:value-of select="encode-for-uri($realm)" />
                </xsl:attribute>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <!-- variable expressions -->
    <xsl:template mode="data-var" match="@*" />
    <xsl:template mode="data-var" match="@about|@resource|@content|@href|@src">
        <xsl:if test="starts-with(., '?')">
            <xsl:attribute name="data-var-{name()}">
                <xsl:value-of select="." />
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <xsl:template mode="data-expression" match="@*">
        <xsl:variable name="expression">
            <xsl:value-of select="substring-before(substring-after(., '{'), '}')"/>
        </xsl:variable>
        <xsl:if test="string(.) = concat('{', $expression, '}')">
            <xsl:attribute name="data-expression-{name()}">
                <xsl:value-of select="$expression" />
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <xsl:template name="data-text-expression">
        <xsl:param name="text" />
        <xsl:variable name="expression">
            <xsl:value-of select="substring-before(substring-after($text, '{'), '}')"/>
        </xsl:variable>
        <xsl:if test="$text = concat('{', $expression, '}')">
            <xsl:attribute name="data-text-expression">
                <xsl:value-of select="$expression" />
            </xsl:attribute>
        </xsl:if>
    </xsl:template>

    <!-- Layout -->
    <xsl:template mode="layout" match="*">
        <xsl:copy>
            <xsl:apply-templates mode="layout" select="@*|*|text()|comment()" />
        </xsl:copy>
    </xsl:template>
    <xsl:template mode="layout" match="@*|text()|comment()">
        <xsl:copy />
    </xsl:template>
    <xsl:template mode="layout" match="@src|@href|@about|@resource">
        <xsl:attribute name="{name()}">
            <xsl:call-template name="resolve-path">
                <xsl:with-param name="relative" select="." />
                <xsl:with-param name="base" select="$layout" />
            </xsl:call-template>
        </xsl:attribute>
    </xsl:template>

    <xsl:template mode="layout" match="xhtml:div[@id='content']|div[@id='content']">
        <xsl:copy>
            <xsl:apply-templates mode="layout" select="@*" />
            <xsl:apply-templates select="$template_body/*|$template_body/comment()|$template_body/text()" />
        </xsl:copy>
    </xsl:template>

    <!-- Helper Functions -->
    <xsl:template name="merge-attributes">
        <xsl:param name="one" />
        <xsl:param name="two" />
        <xsl:param name="class" />
        <xsl:if test="$one/@class or $two/@class or $class">
            <xsl:attribute name="class">
                <xsl:value-of select="$one/@class" />
                <xsl:text> </xsl:text>
                <xsl:value-of select="$two/@class" />
                <xsl:text> </xsl:text>
                <xsl:value-of select="$class" />
            </xsl:attribute>
        </xsl:if>
        <xsl:apply-templates select="$one/@*[name() != 'class']" />
        <xsl:for-each select="$two/@*[name() != 'class']">
            <xsl:variable name="name" select="name()" />
            <xsl:if test="not($one/@*[name()=$name])">
                <xsl:apply-templates select="." />
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="resolve-path">
        <xsl:param name="relative" />
        <xsl:param name="base" />
        <xsl:variable name="scheme" select="substring-before($base, '://')" />
        <xsl:variable name="authority" select="substring-before(substring-after($base, '://'), '/')" />
        <xsl:variable name="path" select="substring-after(substring-after($base, '://'), $authority)" />
        <xsl:choose>
            <xsl:when test="not($scheme) or not($authority)">
                <xsl:value-of select="$relative" />
            </xsl:when>
            <xsl:when test="contains($relative, '{') or contains($relative, ' ') or contains($relative, '&lt;') or contains($relative, '&gt;') or contains($relative, '&quot;') or contains($relative, &quot;'&quot;)">
                <xsl:value-of select="$relative" />
            </xsl:when>
            <xsl:when test="contains($relative, ':') or starts-with($relative,'//')">
                <xsl:value-of select="$relative" />
            </xsl:when>
            <xsl:when test="$relative='' or starts-with($relative,'?') or starts-with($relative,'#')">
                <xsl:value-of select="$relative" />
            </xsl:when>
            <xsl:when test="starts-with($relative, '/')">
                <xsl:call-template name="normalize-uri-path">
                    <xsl:with-param name="uri">
                        <xsl:value-of select="concat($scheme, '://', $authority)" />
                        <xsl:value-of select="$relative" />
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="normalize-uri-path">
                    <xsl:with-param name="uri">
                        <xsl:call-template name="substring-before-last">
                            <xsl:with-param name="arg" select="$base" />
                            <xsl:with-param name="delim" select="'/'" />
                        </xsl:call-template>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="$relative" />
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="normalize-uri-path">
        <xsl:param name="uri" />
        <xsl:variable name="path" select="concat('/',substring-after(substring-after($uri,'//'),'/'))" />
        <xsl:choose>
            <xsl:when test="(contains($uri,'://') or starts-with($uri,'//')) and contains($path, '?')">
                <xsl:value-of select="substring-before($uri,'//')" />
                <xsl:text>//</xsl:text>
                <xsl:value-of select="substring-before(substring-after($uri,'//'),'/')" />
                <xsl:call-template name="normalize-path">
                    <xsl:with-param name="path" select="substring-before($path,'?')" />
                </xsl:call-template>
                <xsl:text>?</xsl:text>
                <xsl:value-of select="substring-after($uri,'?')" />
            </xsl:when>
            <xsl:when test="(contains($uri,'://') or starts-with($uri,'//')) and contains($path, '#')">
                <xsl:value-of select="substring-before($uri,'//')" />
                <xsl:text>//</xsl:text>
                <xsl:value-of select="substring-before(substring-after($uri,'//'),'/')" />
                <xsl:call-template name="normalize-path">
                    <xsl:with-param name="path" select="substring-before($path,'#')" />
                </xsl:call-template>
                <xsl:text>#</xsl:text>
                <xsl:value-of select="substring-after($uri,'#')" />
            </xsl:when>
            <xsl:when test="contains($uri,'://') or starts-with($uri,'//')">
                <xsl:value-of select="substring-before($uri,'//')" />
                <xsl:text>//</xsl:text>
                <xsl:value-of select="substring-before(substring-after($uri,'//'),'/')" />
                <xsl:call-template name="normalize-path">
                    <xsl:with-param name="path" select="$path" />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="(starts-with($uri,'/') or starts-with($uri,'.')) and contains($uri, '?')">
                <xsl:call-template name="normalize-path">
                    <xsl:with-param name="path" select="substring-before($uri,'?')" />
                </xsl:call-template>
                <xsl:text>?</xsl:text>
                <xsl:value-of select="substring-after($uri,'?')" />
            </xsl:when>
            <xsl:when test="(starts-with($uri,'/') or starts-with($uri,'.')) and contains($uri, '#')">
                <xsl:call-template name="normalize-path">
                    <xsl:with-param name="path" select="substring-before($uri,'#')" />
                </xsl:call-template>
                <xsl:text>#</xsl:text>
                <xsl:value-of select="substring-after($uri,'#')" />
            </xsl:when>
            <xsl:when test="starts-with($uri,'/') or starts-with($uri,'.')">
                <xsl:call-template name="normalize-path">
                    <xsl:with-param name="path" select="$uri" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$uri" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="normalize-path">
        <xsl:param name="path" />
        <xsl:choose>
            <!-- A. If the input buffer begins with a prefix of "../" or "./",
                then remove that prefix from the input buffer; otherwise, -->
            <xsl:when test="starts-with($path,'../')">
                <xsl:call-template name="normalize-path">
                    <xsl:with-param name="path" select="substring($path, 4)" />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="starts-with($path,'./')">
                <xsl:call-template name="normalize-path">
                    <xsl:with-param name="path" select="substring($path, 3)" />
                </xsl:call-template>
            </xsl:when>
            <!-- B.  if the input buffer begins with a prefix of "/./" or "/.",
                where "." is a complete path segment, then replace that
                prefix with "/" in the input buffer; otherwise, -->
            <xsl:when test="starts-with($path,'/./')">
                <xsl:call-template name="normalize-path">
                    <xsl:with-param name="path" select="substring($path, 3)" />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$path='/.'">
                <xsl:text>/</xsl:text>
            </xsl:when>
            <!-- C.  if the input buffer begins with a prefix of "/../" or "/..",
                where ".." is a complete path segment, then replace that
                prefix with "/" in the input buffer and remove the last
                segment and its preceding "/" (if any) from the output
                buffer; otherwise, -->
            <xsl:when test="contains($path,'/../')">
                <xsl:call-template name="normalize-path">
                    <xsl:with-param name="path">
                        <xsl:call-template name="substring-before-last">
                            <xsl:with-param name="arg" select="substring-before($path,'/../')" />
                            <xsl:with-param name="delim" select="'/'" />
                        </xsl:call-template>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="substring-after($path,'/../')" />
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="substring($path,string-length($path)-2)='/..'">
                <xsl:call-template name="normalize-path">
                    <xsl:with-param name="path">
                        <xsl:call-template name="substring-before-last">
                            <xsl:with-param name="arg" select="substring($path,1,string-length($path)-3)" />
                            <xsl:with-param name="delim" select="'/'" />
                        </xsl:call-template>
                        <xsl:text>/</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <!-- D.  if the input buffer consists only of "." or "..", then remove
                 that from the input buffer; otherwise, -->
            <xsl:when test="contains($path,'/./')">
                <xsl:call-template name="normalize-path">
                    <xsl:with-param name="path">
                        <xsl:value-of select="substring-before($path,'/./')" />
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="substring-after($path,'/./')" />
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="substring($path,string-length($path)-1)='/.'">
                <xsl:call-template name="normalize-path">
                    <xsl:with-param name="path">
                        <xsl:value-of select="substring($path,string-length($path)-1)" />
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <!-- E.  move the first path segment in the input buffer to the end of
                the output buffer, including the initial "/" character (if
                any) and any subsequent characters up to, but not including,
                the next "/" character or the end of the input buffer. -->
            <xsl:otherwise>
                <xsl:value-of select="$path" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="substring-before-last">
        <xsl:param name="arg"/>
        <xsl:param name="delim"/>
        <xsl:if test="contains($arg, $delim)">
            <xsl:value-of select="substring-before($arg, $delim)" />
            <xsl:if test="contains(substring-after($arg, $delim), $delim)">
                <xsl:value-of select="$delim" />
                <xsl:call-template name="substring-before-last">
                    <xsl:with-param name="arg" select="substring-after($arg, $delim)"/>
                    <xsl:with-param name="delim" select="$delim"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template name="divert">
        <xsl:param name="diverted" />
        <xsl:param name="url" />
        <xsl:variable name="uri">
            <xsl:choose>
                <xsl:when test="contains($url,'?')">
                    <xsl:value-of select="substring-before($url,'?')" />
                </xsl:when>
                <xsl:when test="contains($url,'#')">
                    <xsl:value-of select="substring-before($url,'#')" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$url" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$diverted" />
        <xsl:call-template name="replace-string">
            <xsl:with-param name="text">
                <xsl:call-template name="replace-string">
                    <xsl:with-param name="text" select="$uri"/>
                    <xsl:with-param name="replace" select="'%'"/>
                    <xsl:with-param name="with" select="'%25'"/>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="replace" select="'+'"/>
            <xsl:with-param name="with" select="'%2B'"/>
        </xsl:call-template>
        <xsl:value-of select="substring-after($url,$uri)" />
    </xsl:template>

    <xsl:template name="replace-string">
        <xsl:param name="text"/>
        <xsl:param name="replace"/>
        <xsl:param name="with"/>
        <xsl:choose>
            <xsl:when test="contains($text,$replace)">
                <xsl:value-of select="substring-before($text,$replace)"/>
                <xsl:value-of select="$with"/>
                <xsl:call-template name="replace-string">
                    <xsl:with-param name="text" select="substring-after($text,$replace)"/>
                    <xsl:with-param name="replace" select="$replace"/>
                    <xsl:with-param name="with" select="$with"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- xptr-element -->
    <xsl:template mode="xptr-element" match="/xhtml:html/xhtml:body|/html/body">
        <xsl:text>content</xsl:text>
    </xsl:template>
    <xsl:template mode="xptr-element" match="*[@id]">
        <xsl:value-of select="@id" />
    </xsl:template>
    <xsl:template mode="xptr-element" match="*">
        <xsl:apply-templates mode="xptr-element" select=".." />
        <xsl:text>/</xsl:text>
        <xsl:value-of select="count(preceding-sibling::*) + 1" />
    </xsl:template>

</xsl:stylesheet>