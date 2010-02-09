package Text::PAN::Suite::Filter::URL2Ref;
use Any::Moose;
use XML::LibXML;
use Text::PAN::CONSTANTS 'NS';
use URI::Escape;

my $REGEX_URI = do{
  my $digit = q{[0-9]};
  my $alpha = q{[a-zA-Z]};
  my $alphanum = q{[a-zA-Z0-9]};
  my $hex = q{[0-9A-Fa-f]};
  my $escaped = qq{%$hex$hex};
  my $uric = q{(?:[-_.!~*'()a-zA-Z0-9;/?:@&=+$,]} . qq{|$escaped)};

  my $fragment = qq{$uric*};

  my $query = qq{$uric*};
  my $pchar = q{(?:[-_.!~*'()a-zA-Z0-9:@&=+$,]} . qq{|$escaped)};
  my $param = qq{$pchar*};
  my $segment = qq{$pchar*(?:;$param)*};
  my $path_segments = qq{$segment(?:/$segment)*};
  my $abs_path = qq{/$path_segments};
  my $port = qq{$digit*};
  my $IPv4address = qq{$digit+\\.$digit+\\.$digit+\\.$digit+};
  my $toplabel = qq{$alpha(?:} . q{[-a-zA-Z0-9]*} . qq{$alphanum)?};
  my $domainlabel = ( qq{$alphanum(?:} .
                      q{[-a-zA-Z0-9]*} .
                      qq{$alphanum)?} );
  my $hostname = qq{(?:$domainlabel\\.)*$toplabel\\.?};
  my $host = qq{(?:$hostname|$IPv4address)};
  my $hostport = qq{$host(?::$port)?};
  my $userinfo = q{(?:[-_.!~*'()a-zA-Z0-9;:&=+$,]|} . qq{$escaped)*};
  my $server = qq{(?:$userinfo\@)?$hostport};
  my $authority = qq{$server};
  my $scheme = q{(?:https?|shttp)};
  my $net_path = qq{//$authority(?:$abs_path)?};
  my $hier_part = qq{$net_path(?:\\?$query)?};
  my $absoluteURI = qq{$scheme:$hier_part};

  my $URI_reference = qq{$absoluteURI(?:#$fragment)?};
  qr{\b($URI_reference)};
};

sub __each_nodes{
  my ($n, $cb) = @_;
  $cb->($n);
  foreach my $c ($n->childNodes){
    __each_nodes($c, $cb);
  }
}

sub do_filter{
  my ($this, $src, %opt) = @_;
  my $doc = $src->ownerDocument;
  __each_nodes
    ($src,
     sub{
       my ($node) = @_;
       return if($node->nodeType != XML_TEXT_NODE);
       my $data = $node->nodeValue;
       return unless $data =~ /$REGEX_URI/;

       my @queue  = ();
       while(length ( $data )  and  $data =~ s/\A(.*?)($REGEX_URI|\z)//s){
         my $txt = $1;
         my $uri = $2;
         push @queue, $doc->createTextNode($txt);
         next unless $uri;
         my $ref = $doc->createElementNS(NS, 'ref');
         $ref->setAttribute('url', $uri);
         $ref->setAttribute('class', "url");
         $ref->appendChild($doc->createTextNode(uri_unescape($uri)));
         push @queue, $ref;
       }


       my $parent = $node->parentNode;
       my $prev   = $node;
       while(@queue){
         my $last = pop @queue;
         $parent->insertBefore($last, $prev);
         $prev = $last;
       };
       $parent->removeChild($node);
       $parent->normalize;
     });
  return $src unless $opt{as_string};
  $src->toString;
}


with qw( Text::PAN::Suite::Role::Filter );

1;
__END__

