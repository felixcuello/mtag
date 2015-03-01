package MTAG::Services::Amazon_com {

  use Moose;
  use common::sense;

  extends 'MTAG::Services';

  sub try {
    my $self = shift;
    say "***************************** amazon.com *****************************";
    return 0;
  }
  1;
};

