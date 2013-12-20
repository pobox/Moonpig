package t::lib::Role::Consumer::VaryingCharge;
use Moose::Role;
use Moonpig::Util qw(class dollars);
use Moonpig::Types qw(Factory  NonNegativeMillicents);
use MooseX::Types::Moose qw(ArrayRef);

use namespace::autoclean -also =>
  [qw(ArrayRef is_ArrayRef to_ArrayRef Factory is_Factory to_Factory
      NonNegativeMillicents is_NonNegativeMillicents
      to_NonNegativeMillicents)];

has total_charge_amount => (
  is => 'rw',
  isa => NonNegativeMillicents,
  required => 1,
);

with(
  'Moonpig::Role::Consumer::ByTime',
);

has charge_description => (
  is => 'ro',
  isa => 'Str',
  default => 'charge',
  traits => [ qw(Copy) ],
);

around initial_invoice_charge_structs => sub {
  my ($orig, $self, @args) = @_;
  return $self->charge_structs_on();
};

sub charge_structs_on {
  return({
    description => 'charge',
    amount      => $_[0]->total_charge_amount,
  });
}

1;
