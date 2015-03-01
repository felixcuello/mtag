package MTAG::Services { # Base class for all services

  use Moose;
  use LWP::UserAgent;
  use common::sense;
  use constant SUBSTRING_MATCH_LENGTH => 7;

  has '_lwp' => ( is => 'ro', isa => 'LWP::UserAgent', default => sub { LWP::UserAgent->new(); } );

  # Tries to tag a directory given a pattern
  sub try {
    my $directory = shift;
    my $pattern   = shift;
    return 0;
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
