use strict;
use warnings;

use Carp qw(confess croak);
use Moonpig::Util qw(class days dollars event months);
use Test::More;
use Test::Routine;
use Test::Routine::Util;

use t::lib::TestEnv;

use Moonpig::Test::Factory qw(do_with_fresh_ledger);

with ('Moonpig::Test::Role::UsesStorage');

my $xid = "consumer:5y:test";

before run_test => sub {
  Moonpig->env->reset_clock;
};

sub do_with_b5 {
  my ($self, $code) = @_;
  do_with_fresh_ledger({ b5 => { template => 'fivemonth', xid => $xid } }, sub {
    my ($ledger) = @_;
    my $b5 = $ledger->get_component('b5');
    $code->($ledger, $b5);
  });
}

test setup_b5 => sub {
  my ($self) = @_;
  $self->do_with_b5(sub {
    my ($ledger, $b5) = @_;

    ok($ledger);
    ok($b5);
    is($ledger->active_consumer_for_xid($xid), $b5);
    ok(  $b5->is_active);
    ok($ledger->latest_invoice);
  });
};

sub pay_unpaid_invoices {
  my ($self, $ledger) = @_;
  my $total = 0;

  Moonpig->env->stop_clock();
  until ($ledger->payable_invoices) {
    Moonpig->env->elapse_time(days(1));
    Moonpig->env->storage->do_rw(sub {
                                   $ledger->handle_event( event('heartbeat') );
                                 });
  }

  for my $invoice ($ledger->invoices) {
    $total += $invoice->total_amount unless $invoice->is_paid;
  }
  printf "# Total amount payable: %.2f\n", $total / 100000;
  $ledger->add_credit(class('Credit::Simulated'), { amount => $total });
  $ledger->process_credits;
}

sub do_with_g1 {
  my ($self, $code) = @_;

  $self->do_with_b5(sub {
    my ($ledger, $b5) = @_;

    $self->pay_unpaid_invoices($ledger);
    Moonpig->env->stop_clock();
    print "# Time passes";
    until ($b5->has_replacement) {
      Moonpig->env->elapse_time(days(7));
      Moonpig->env->storage->do_rw(sub {
                                     $ledger->handle_event( event('heartbeat') );
                                   });
      print ".";

      Moonpig->env->clock_offset > months(5.5)
        and die "b5 never set up its replacement!!\n";
    }
    print "\n";
    { my $days =  Moonpig->env->clock_offset / days(1);
      my $months = int($days / 30);
      $days -= $months * 30;
      note sprintf "Replacement set up after %d mo %.2f dy", $months, $days
    }
    my $g1 = $b5->replacement;
    $code->($ledger, $b5, $g1);
  });
}

# test to make sure that coupon is properly inserted
test coupon_insertion => sub {
  my ($self) = @_;
  $self->do_with_b5(sub {
    my ($ledger, $b5) = @_;

    $self->pay_unpaid_invoices($ledger);
    ok(  $ledger->latest_invoice->is_paid);
    ok(! $ledger->latest_invoice->is_open);
    my $coupons = $ledger->coupon_array;
    is(@$coupons, 1, "exactly one coupon");
    my $coupon = $coupons->[0];
    ok($coupon->does("Moonpig::Role::Coupon::RequiredTags"));
    #  note "Coupon target tags: ", join ", ", $coupon->taglist;
    for my $tag ($b5->xid, "coupon.b5g1") {
      ok($coupon->has_target_tag($tag), "coupon has target tag '$tag'");
    }
  });
};

test setup_g1 => sub {
  my ($self) = @_;
  $self->do_with_g1(sub {
    my ($ledger, $b5, $g1) = @_;
    ok(! $g1->is_active);
    is($b5->replacement, $g1, "replacement ok");
    ok(! $g1->has_replacement);
    ok($g1->does("Moonpig::Role::Consumer::ByTime::FixedCost"));
    is($g1->xid, $b5->xid, "xids match");
  });
};

# test to make sure that if the coupon is there, the correct amount is invoiced
# test to make sure that when the invoice is paid, the coupon is properly applied
# and the self-funding consumer is created
test coupon_payment => sub {
   my ($self) = @_;
   $self->do_with_g1(sub {
     my ($ledger, $b5, $g1) = @_;

     is($ledger->latest_invoice->total_amount, dollars(100), "new invoice for correct amount");
     $ledger->process_credits;
     is($g1->unapplied_amount, dollars(100), 'consumer has $100');
     my ($coupon) = $ledger->coupon_array;
   });
};

# test to make sure everything is cancelled on account cancellation
test cancellation => sub {
 TODO: {
    local $TODO = 'x';
    fail("not implemented");
  }
};

run_me;
done_testing;
