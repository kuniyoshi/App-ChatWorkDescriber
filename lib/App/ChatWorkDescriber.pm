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

__END__
=encoding utf8

=head1 NAME

App::ChatWorkDescriber - A describer which watches ChatWork room's message, and says more describe if needed

=head1 SYNOPSIS

  use App::ChatWorkDescriber;
  my $token = "your secret token";
  my $room_name = "room name to watch, and describe";

  my $describer = App::ChatWorkDescriber->new( verbose => 1 );
  $describer->set_api( $token );
  $describer->set_ticker;
  $describer->add_room( $room_name );
  $describer->loop;

=head1 DESCRIPTION

This module posts titled URL when it found blunt messages.

I do not want to see the message which includes only URL.
It has no information to wether should I need to see it,
or how quickly to see?

The best solution I think is, ChatWork adds title,
and description when the message includes only URL.

But, ChatWork does not.  Thus, I wrote this module to
describe the URL only message.

The worst point of this module is, make message duplicate.
Describing message needs to post a new described message,
then there exists two messages; these are, original message,
and new described message.  If you, and your roommates
do not care that, this module keeps you, and your roommates
mind stable.
