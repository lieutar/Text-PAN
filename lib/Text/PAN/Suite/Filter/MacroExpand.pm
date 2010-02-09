package Text::PAN::Suite::Filter::MacroExpand;
use Text::PAN::CONSTANTS qw(NS);
use Any::Moose;
use XML::LibXML;

my $xslt = XML::LibXML->load_xml(string => <<'EOF');
<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0"
                xmlns:pad="tag:neoteny.sakura.ne.jp,2009:xmlns/pad"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ill="tag:neoteny.sakura.ne.jp,2009:xmlns/pad-illegal"
                >

<xsl:output
     method="xml"
     encoding="utf-8"
     />

<xsl:template match="pad:def" />
<xsl:template match="pad:def" mode="x" 
  ><xsl:apply-templates /></xsl:template>
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

<xsl:template match="*"
  ><xsl:element
       name="{local-name()}"
       namespace="{namespace-uri()}"
    ><xsl:for-each select="./attribute::*"
       ><xsl:attribute
           name="{local-name()}"
           namespace="{namespace-uri()}"
        ><xsl:value-of select="."
      /></xsl:attribute
    ></xsl:for-each
    ><xsl:apply-templates
  /></xsl:element
></xsl:template>

</xsl:stylesheet>
EOF


sub xslt{ $xslt }

with qw( Text::PAN::Suite::Role::Filter::XSLT );

1;
__END__

