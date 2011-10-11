use Test::Routine;
use Test::Routine::Util -all;
use Test::More;
use Test::Fatal;

with(
  'Moonpig::Test::Role::UsesStorage',
);
use Moonpig::Test::Factory qw(build_ledger);

use Moonpig::Context::Test -all, '$Context';
use Moonpig::Env::Test;

# use Moonpig::Util qw(class days dollars event);

use namespace::autoclean;

use File::Temp qw(tempdir);
use Moonpig::Util qw(class);

test "route to and get a simple resource" => sub {
  my ($self) = @_;

  my $ledger = build_ledger();

  my $guid = $ledger->guid;

  Moonpig->env->save_ledger($ledger);

  # XXX: temporary first draft of a route to get the guid
  # /ledger/by-guid/:GUID/gguid
  my ($resource) = Moonpig->env->route(
    [ 'ledger', 'by-guid', $guid ],
  );

  my $result = $resource->resource_request(get => {});

  isa_ok(
    $result,
    $ledger->meta->name,
    "...ledger by path",
  );

  is($result->guid, $ledger->guid, "...and the rightly-identified one");
};

test "route to and GET a method on a simple resource" => sub {
  my ($self) = @_;

  my $ledger = build_ledger();

  Moonpig->env->save_ledger($ledger);

  my $guid = $ledger->guid;

  # XXX: temporary first draft of a route to get the guid
  # /ledger/by-guid/:GUID/gguid
  my ($resource) = Moonpig->env->route(
    [ 'ledger', 'by-guid', $guid, 'gguid' ],
  );

  my $result = $resource->resource_request(get => {});

  is($result, $guid, "we can get the ledger's guid by routing to it");
};

run_me;
done_testing;
