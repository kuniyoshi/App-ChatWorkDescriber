package App::ChatWorkDescriber::Ticker;
use Mojo::Base "Mojo::EventEmitter";

has tick_per_seconds => 60;
has debug            => 0;

sub loop {
    my $self = shift;

    while ( 1 ) {
        if ( $self->debug ) {
            warn "start ticking...";
        }

        $self->emit( "tick" );

        sleep $self->tick_per_seconds;
    }

    return;
}

1;

__END__
=encoding utf8

=head1 NAME

App::ChatWorkDescriber::Ticker - An time ticker class

=head1 SYNOPSIS

  use App::ChatWorkDescriber::Ticker;
  my $ticker = App::ChatWorkDescriber::Ticker->new;
  $ticker->on( tick => sub { warn "tick" } );
  $ticker->loop;

=head1 DESCRIPTION

This class tickes time to when the rooms check the new messages.

Rooms should be registered to the tick instance to fetch new messages.
Then the rooms fetches new messages at the ticker emits tick event.
