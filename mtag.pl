#!/usr/bin/perl

use common::sense;
use MTAG;

my $search_pattern = shift; usage() if $search_pattern =~ /(-h|--help)/i;
my $directory      = shift // '.';
my $mtag           = MTAG->new();
$mtag->do_your_magic( $directory, $search_pattern );

sub usage {
  print <<MTAG_USAGE;

  $0 [directory] [pattern]

  If no directory is supplied it will use the current directory
  If no pattern is supplied it will use the directory name

MTAG_USAGE
  exit(1);
}

__END__
