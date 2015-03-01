package MTAG::Services::Amazon_com {

  use Moose;

  extends 'MTAG::Services';

  around 'try' => sub {
    my $orig = shift;
    my $self = shift;

    $self->$orig(@_);
    return 0;
  };

  1;
};

