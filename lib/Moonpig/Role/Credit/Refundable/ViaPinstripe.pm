
package Moonpig::Role::Credit::Refundable::ViaPinstripe;
# ABSTRACT: a refund that gets back to the payer via pinstripe

use Moose::Role;
use Stick::Util qw(ppack);
requires 

with(
  'Moonpig::Role::Credit::Refundable',
);

sub issue_refund {
  my ($self, $amount) = @_;

  my ($processor, $token_id) = split /:/, $self->{transaction_id};

  $self->ledger->queue_job('issue-refund', {
    processor => $processor,
    token_id  => $token_id,
    amount_cents => $amount
    });
}

1;