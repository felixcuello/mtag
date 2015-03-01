package MTAG {

  use Cwd;
  use Moose;
  use common::sense;

  has 'services' => ( is => 'ro', isa => 'ArrayRef', default => sub { ['Amazon_com']; } );

  sub do_your_magic {
    my $self      = shift;
    my $directory = shift // getcwd();
    my $pattern   = shift // $self->get_pattern_from_directory( $directory );
    foreach my $service_name ( @{$self->services()} ) {
      my $instance = eval "use MTAG::Services::$service_name; MTAG::Services::$service_name->new()";
      die("$service_name not available! $@") if $@;
      print "Trying $service_name... ";
      if( $instance->try($directory, $pattern) ) {
        say 'GREAT!, your disk has been tagged!';
        last;
      } else {
        say 'OH NO!, I was unable to do my magic.';
      }
    }
  }

  sub get_pattern_from_directory {
    my $self      = shift;
    my $directory = shift;
    $directory =~ s/\/\s*$//g; # Remove trailing / from the directory
    my @dirs = split '/', $directory;
    return $dirs[$#dirs];
  }

}

1;
