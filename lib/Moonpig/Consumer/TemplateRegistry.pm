package Moonpig::Consumer::TemplateRegistry;
use Moose;

use namespace::autoclean;

has _registry => (
  is  => 'ro',
  isa => 'HashRef',
  init_arg => undef,
  default  => sub {  {}  },
  traits   => [ 'Hash' ],
  handles  => {
    _template_exists   => 'exists',
    _register_template => 'set',
    _get_template      => 'get',
  },
);

sub template {
  my ($self, $name) = @_;

  my $template_sub = $self->_get_template($name);

  Moonpig::X->throw("unknown template") unless $template_sub;

  my $template = $template_sub->($name);
}

sub register_templates {
  my ($self, $templates) = @_;

  for my $name (keys %$templates) {
    confess "consumer template $name already registered"
      if $self->_template_exists($name);

    $self->_register_template($name, $templates->{$name});
  }
}

sub register_templates_with_prefix {
  my ($self, $prefix, $templates) = @_;

  my %new = map {; "$prefix.$_" => $templates->{$_} } keys %$templates;

  $self->register_templates(\%new);
}

1;
