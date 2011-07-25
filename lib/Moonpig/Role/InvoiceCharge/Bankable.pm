package Moonpig::Role::InvoiceCharge::Bankable;
# ABSTRACT: a charge that, when paid, should have a bank created for the paid amount
use Moose::Role;

with(
  'Moonpig::Role::InvoiceCharge',
);

use Moonpig::Util qw(class);

use namespace::autoclean;

has consumer => (
  is   => 'ro',
  does => 'Moonpig::Role::Consumer',
  required => 1,
  handles  => [ qw(ledger) ],
);

1;
