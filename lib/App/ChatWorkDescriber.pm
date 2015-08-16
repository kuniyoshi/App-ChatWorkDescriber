package App::ChatWorkDescriber;
use Mojo::Base -base;
use App::ChatWorkDescriber::Ticker;
use App::ChatWorkDescriber::Room;
use WebService::ChatWorkApi;

# ABSTRACT: A describer which watches ChatWork room's message, and says more describe if needed

our $VERSION = "0.00";

has "api";
has rooms => sub { [ ] };
has "ticker";
has "verbose";

sub set_api {
    my $self  = shift;
    my $token = shift;
    my $api = WebService::ChatWorkApi->new(
        api_token => $token,
    );
    $self->api( $api );
    return;
}

sub set_ticker {
    my $self = shift;
    my $ticker = App::ChatWorkDescriber::Ticker->new(
        debug => $self->verbose,
    );
    $self->ticker( $ticker );
    return;
}

sub add_room {
    my $self = shift;
    my $name = shift;
    my $room = App::ChatWorkDescriber::Room->new(
        api   => $self->api,
        debug => $self->verbose,
    )->setup( $name );
    $room->on(
        new_messages => sub { my $e = shift; $e->post_described_messages },
    );
    push @{ $self->rooms }, $room;
    $self->ticker->on(
        tick => sub { $room->fetch },
    );
    return;
}

sub loop {
    my $self = shift;
    return $self->ticker->loop;
}

1;
