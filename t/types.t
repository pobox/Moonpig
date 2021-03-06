use strict;
use warnings;

use Test::More;

use Moonpig::Types qw(Millicents Time NonBlankLine TrimmedNonBlankLine);

use Scalar::Util qw(refaddr);

{
  my $val = 1.12;
  my $amt = Millicents->assert_coerce($val);
  is("$amt", "1", "we truncate away fractional amounts");
}

{
  my $datetime = DateTime->now;
  my $mp_dt    = Time->assert_coerce($datetime);

  isnt(
    refaddr($datetime),
    refaddr($mp_dt),
    "coerce DT -> M::DT gets a new object",
  );

  isa_ok($mp_dt, 'Moonpig::DateTime', 'coerce DT -> M::DT gets M::DT');
  cmp_ok($mp_dt, '==', $datetime, '...and the M::DT == the DT');
}

subtest "non blank lines" => sub {
  my $str = "foo bar baz";

  ok(   NonBlankLine->check(" $str ") );
  ok( ! NonBlankLine->check(" $str \n") );
  ok( ! TrimmedNonBlankLine->check(" $str ") );
  ok(   TrimmedNonBlankLine->check("$str") );
  ok(   TrimmedNonBlankLine->coerce(" $str ") );
};

done_testing;
