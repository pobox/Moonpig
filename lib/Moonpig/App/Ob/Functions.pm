
package Ob;  # note weird package declaration
# This is the package in which unrecognized commands are evaluated as Perl
# expressions.

our $ob;

sub generate {
  my ($subcommand, @args) = @_;
  $subcommand ||= 'help';
  if ($subcommand eq 'ledger') {
    return class('Ledger')->new({ contact => _gen_contact() });
  } elsif ($subcommand eq 'contact') {
    return _gen_contact();
  } else {
    warn "Usage: generate [ledger|contact]\n";
    return "";
  }
}
*gen =\&generate;

{
  my $N = 'a';
  sub _gen_contact {
    my $name = "\U$N\E Jones";
    my $email = qq{$N\@example.com};
    $N++;
    return class('Contact')->new({ name => $name,
                                   email_addresses => [ $email ],
                                 });
  }
}

sub store {
  my (@argl) = @_;
  unless (@argl) {
    warn "Usage: store ledger...\n";
    return "";
  }
  $ob->storage->_store_ledger($_) for @argl;
}
*st =\&store;


sub x {
  my (@args) = @_;
  require Data::Dumper;
  $ob->output(Data::Dumper::Dumper(@args));
  return @args;
}
*d = \&x;

sub xid {
  my (@args) = @_;
  map $st->retrieve_ledger_for_xid($_), @args;
}

sub guid {
  my (@args) = @_;
  map $st->retrieve_ledger_for_guid($_), @args;
}

sub guids {
  $st->ledger_guids;
}

1;