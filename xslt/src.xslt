<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0"
                xmlns="http://www.w3.org/1999/xhtml/"
                xmlns:pad="tag:neoteny.sakura.ne.jp,2009:xmlns/pad"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ill="tag:neoteny.sakura.ne.jp,2009:xmlns/pad-illegal"
                >
<xsl:output
     method="text"
     encoding="utf-8"
     doctype-public="-//W3C//DTD HTML 4.01 Strict//EN"
     doctype-system="http://www.w3.org/TR/html4/strict.dtd"
     indent="yes"
     />


<xsl:template match="/"
  ><xsl:apply-templates
  /></xsl:template>

<!--
OUTLINE OF xHTML
-->
<xsl:template match="pad:article"
><xsl:if test="./pad:meta/pad:title"
>= <xsl:value-of select="./pad:meta/pad:title" /></xsl:if>
<xsl:apply-templates select="./pad:section" />
</xsl:template>


<xsl:template match="/pad:article/pad:meta" />


<!--
VERB
-->
<xsl:template match="pad:verb">
<pre><xsl:apply-templates /></pre>
</xsl:template>

<!--
SECTION
-->
<xsl:template match="pad:section"
><xsl:for-each select="./ancestor::pad:section"
  >*</xsl:for-each> <xsl:apply-templates select="./pad:head"/>
<xsl:apply-templates select="./pad:head/following-sibling::*" 
/></xsl:template>


<!--
P
-->
<xsl:template match="pad:p">
<p><xsl:apply-templates /></p>
</xsl:template>


<!--
HR
-->
<xsl:template match="pad:hr">
----
</xsl:template>

<!--
CODE
-->
<xsl:template match="pad:code"><code><xsl:apply-templates /></code></xsl:template>

<!--
UL
-->
<xsl:template match="pad:ul">
<ul>
  <xsl:apply-templates select="pad:item" />
</ul>
</xsl:template>

<xsl:template match="pad:item">
<li><xsl:apply-templates /></li>
</xsl:template>




<!-- ============================================================
                      TOC
============================================================ -->
<xsl:template match="pad:section" mode="toc"
  ><li><a href="#{generate-id()}"
         ><xsl:apply-templates select="./pad:head"
       /></a
       ><xsl:if test="./pad:section"
         ><ul><xsl:apply-templates
                   select="./pad:section" mode="toc"
         /></ul
       ></xsl:if
  ></li
></xsl:template>

<xsl:template match="*" mode="toc" />

</xsl:stylesheet>

