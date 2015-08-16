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
