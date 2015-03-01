package MTAG::Services { # Base class for all services

  use Moose;
  use LWP::UserAgent;
  use common::sense;
  use constant SUBSTRING_MATCH_LENGTH => 7;

  has '_lwp'     => ( is => 'ro', isa => 'LWP::UserAgent', default => sub { shift->_prepare_LWP() },, );
  has '_dir'     => ( is => 'ro', isa => 'ArrayRef',       default => sub { []; }, );
  has '_pattern' => ( is => 'ro', isa => 'Str',            default => '', );

  # try
  # In the base class prepares _dir and _pattern for derived classes
  sub try {
    my $self    = shift;
    my $dir     = shift || die("DIR is mandatory!\n");
    my $pattern = shift || die("PATTERN is mandatory!\n");
    opendir( DH, $dir ) || die("Can't access $dir\n");
    while( my $file = readdir(DH) ) {
      push(@{$self->{_dir}}, $file) if $file =~ /mp3\s*$/;
    }
    close( DH );
    $self->{_pattern} = $pattern;
  }

  # Returns true if two string matches
  sub match_strings {
    my $self = shift;
    my $a    = shift || die("+a is mandatory!");
    my $b    = shift || die("+b is mandatory!");
    return 1 if $self->_perfect_match_strings($a,$b);
    return 2 if $self->_fuzzy_match_strings($a,$b);
    return 0; # Damn!
  }

  # Returns a hash with matching positions in arrays
  sub match_arrays {
    my $self  = shift;
    my $left  = shift || [];
    my $right = shift || [];

    my $matches_found = 0;
    my $mapping       = {};
    for( my $l=0; $l<=$#{$left}; ++$l ) {
      for( my $r=0; $r<=$#{$left}; ++$r ) {
        if( $self->match_strings($left->[$l], $right->[$r]) ) {
          if( exists $mapping->{$l} ) {
            warn("*Premature End*, since $left->[$l] points to $right->[$r] and $right->[$mapping->{$l}]\n");
            return 0;
          }
          $mapping->{$l} = $r;
          $matches_found = 1;
        }
      }
      return 0 unless $matches_found;
    }
    return $mapping;
  }


# Helper Methods
#------------------------------------------------------------------

  sub _prepare_LWP {
    my $self = shift;
    my $ua   = LWP::UserAgent->new();
    $ua->agent( 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.111 Safari/537.36' );
    return $ua;
  }

  sub _perfect_match_strings {
    my $self = shift;
    my $a    = shift;
    my $b    = shift;
    $a       =~ s/\s//g;
    $b       =~ s/\s//g;
    return lc($a) eq lc($b);
  }

  sub _fuzzy_match_strings {
    my $self = shift;
    my $a    = shift;
    my $b    = shift;

    $a     =~ s/\s//g;
    $a     = lc($a);
    $b     =~ s/\s//g;
    $b     = lc($b);
    return 1 if $self->_no_vowels_match_strings($a, $b);
    return 1 if $self->_no_braces_match_strings($a, $b);
    return 1 if $self->_substring_match_strings($a, $b, SUBSTRING_MATCH_LENGTH);
    return 0;
  }

  sub _no_vowels_match_strings {
    my $self = shift;
    my $a    = shift;
    my $b    = shift;
    $a =~ s/[aeiou]//g;
    $b =~ s/[aeiou]//g;
    return $a eq $b;
  }

  sub _no_braces_match_strings {
    my $self = shift;
    my $a    = shift;
    my $b    = shift;
    $a =~ s/[\)\[\{].+?[\)\]\}]//g;
    $b =~ s/[\)\[\{].+?[\)\]\}]//g;
    return $a eq $b;
  }

  sub _substring_match_strings {
    my $self = shift;
    my $a    = shift;
    my $b    = shift;
    my $len  = shift;
    return substr($a,0,$len) eq substr($b,0,$len);
  }

  1;
};
