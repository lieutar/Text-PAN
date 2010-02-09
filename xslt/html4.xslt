<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0"
                xmlns="http://www.w3.org/1999/xhtml/"
                xmlns:pad="tag:neoteny.sakura.ne.jp,2009:xmlns/pad"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ill="tag:neoteny.sakura.ne.jp,2009:xmlns/pad-illegal"
                >
<xsl:output
     method="html"
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
<xsl:template match="pad:article">
<html lang="ja">
<head>
<meta http-equiv="Content-Type" content="application/x-html+xml" />
<link rel="stylesheet" href="" />
<title><xsl:value-of select="./pad:meta/pad:title" /></title>
<style type="text/css">
<xsl:value-of select="pad:value-of('css')" />
</style>
</head>
<body>

<div id="header">
<h1><xsl:value-of select="./pad:meta/pad:title" /></h1>
</div>

<div id="content">

<div id="abstract">
<xsl:apply-templates select="./pad:section[position() = 1]/preceding-sibling::*" />
</div>

<a name="toc" />
<div id="table-of-contents">
<h2>目次</h2>
<ul>
<xsl:apply-templates select="./pad:section" mode="toc" />
</ul>
</div>

<xsl:apply-templates select="./pad:section" />
</div>
<div id="footer">
This document is created by <dfn>Text::PAN</dfn>
</div>
</body>
</html>
</xsl:template>


<xsl:template match="/pad:article/pad:meta" />




<!--
NOTE
-->
<xsl:template match="pad:note">
<div class="note">
<div class="note-header">Note:</div>
<xsl:apply-templates />
</div>
</xsl:template>


<!--
VERB
-->
<xsl:template match="pad:verb">
<pre><xsl:apply-templates /></pre>
</xsl:template>

<!--
SECTION
-->
<xsl:template match="pad:section">

<xsl:variable name="section-depth"
  ><xsl:value-of select="2 + count(./ancestor::pad:section)"
  /></xsl:variable>


<div class="section section-{$section-depth}">
<a name="{generate-id()}" id="{generate-id()}" />
<xsl:element name="{concat('h', $section-depth)}">
<xsl:apply-templates select="./pad:head"/>
</xsl:element>

<div class="back-to-toc">
<a href="#toc">目次</a>
</div>

<xsl:apply-templates select="./pad:head/following-sibling::*" />
</div>

</xsl:template>

<!--
REF
-->
<xsl:template match="pad:ref[@url]">
<a href="{@url}"><xsl:apply-templates /></a>
</xsl:template>

<!--
P
-->
<xsl:template match="pad:p">
<p><xsl:apply-templates /></p>
</xsl:template>

<!--
FIGURE
-->
<xsl:template match="pad:figure">
<div class="figure">
<div class="figure-body">
<xsl:apply-templates
   select="./*[not(local-name() = 'caption' and
                namespace-uri() = 'tag:neoteny.sakura.ne.jp,2009:xmlns/pad')]" />
</div>
<div class="figure-caption">
<xsl:apply-templates select="./pad:caption" />
</div>
</div>
</xsl:template>

<!--
HR
-->
<xsl:template match="pad:hr"><hr /></xsl:template>

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

