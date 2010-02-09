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
     indent="yes"
     />



<xsl:template match="pad:def" />
<xsl:template match="pad:def" mode="x" 
  ><xsl:apply-templates 
/></xsl:template>
<xsl:key name="macro" match="//pad:def" use="@name" />

<xsl:template match="pad:x"
   ><xsl:variable name="name" select="text()" 
  /><xsl:variable name="macro" select="key('macro', $name)" 
  /><xsl:choose
     ><xsl:when test="$macro"
       ><xsl:apply-templates select="$macro" mode="x" /></xsl:when
     ><xsl:otherwise
       ><xsl:value-of select="$name"
     /></xsl:otherwise
  ></xsl:choose
></xsl:template>



<xsl:template match="/"
  ><xsl:apply-templates
  /></xsl:template>


<xsl:template match="/pad:article/pad:meta" />

<!--
OUTLINE OF xHTML
-->
<xsl:template match="pad:article">
\documentclass [dvipdfm,9pt] {jsarticle}

\title{<xsl:value-of select="./pad:meta/pad:title" />}

\usepackage{fancybox}
\usepackage{verbatim}
\usepackage{calc}

\begin{document}
\maketitle
\begin{abstract}
<xsl:apply-templates select="./pad:section[1]/preceding-sibling::*" />
\end{abstract}

\newpage

\tableofcontents

\newpage

<xsl:apply-templates select="./pad:section" />
\end{document}
</xsl:template>

<!--
NOTE
-->
<xsl:template match="pad:note">
{
\vskip 5mm
\fboxsep=5mm
\fboxrule=1mm
\cornersize*{3mm}
\ovalbox{\begin{minipage}{157mm}
{
\fboxsep=1mm
\fboxrule=1mm
\ovalbox{Note}
}

<xsl:apply-templates />
\end{minipage}}
\vskip 5mm
}
</xsl:template>


<!--
VERB
-->
<xsl:template match="pad:verb">


{
\vskip 5mm
\begin{Sbox}
  \begin{minipage}{.8\linewidth}%
\begin{Verbatim}
<xsl:apply-templates />\end{Verbatim}%
  \end{minipage}%
\end{Sbox}%
\fboxrule=.25mm
\cornersize*{1mm}
\ovalbox{\TheSbox}
\vskip 5mm
}


</xsl:template>

<!--
SECTION
-->
<xsl:template match="pad:section">

<xsl:variable name="section-depth"
  ><xsl:value-of select="count(./ancestor::pad:section)"
  /></xsl:variable>

<xsl:if test="0 = $section-depth">
\newpage
</xsl:if>

\<xsl:choose
 ><xsl:when test="0 = $section-depth"
 >section</xsl:when
 ><xsl:when test="1 = $section-depth"
 >subsection</xsl:when
 ><xsl:when test="2 = $section-depth"
 >subsubsection</xsl:when
 ><xsl:otherwise
 >subsubsubsection</xsl:otherwise
 ></xsl:choose>{<xsl:apply-templates select="./pad:head"/>}

<xsl:apply-templates select="./pad:head/following-sibling::*" />

</xsl:template>

<!--
REF
-->
<xsl:template match="pad:ref[@url]"><xsl:apply-templates /></xsl:template>

<!--
P
-->
<xsl:template match="pad:p">

<xsl:apply-templates />

</xsl:template>

<!--
FIGURE
-->

<!--
HR
-->
<xsl:template match="pad:hr">

\hrule

</xsl:template>

<!--
CODE
-->
<xsl:template match="pad:code">
{\ttfamily <xsl:apply-templates />}
</xsl:template>


<!--
UL
-->
<xsl:template match="pad:ul">
\begin{itemize}
  <xsl:apply-templates select="pad:item" mode="ul" />
\end{itemize}
</xsl:template>

<xsl:template match="pad:item" mode="ul">
\item{<xsl:apply-templates />}
</xsl:template>








 
</xsl:stylesheet>

