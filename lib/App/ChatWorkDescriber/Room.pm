package App::ChatWorkDescriber::Room;
use Mojo::Base "Mojo::EventEmitter";
use App::ChatWorkDescriber::Message;

has "api";
has "room";
has messages => sub { [ ] };
has debug    => 0;

sub setup {
    my $self = shift;
    my $name = shift;
    my( $room ) = $self->api->ds( "me" )->retrieve->rooms( name => $name );
    $self->room( $room );
    return $self;
}

sub fetch {
    my $self = shift;

    if ( $self->debug ) {
        warn "fetching...";
    }

    my @messages = $self->room->new_messages;
    @messages = map  { App::ChatWorkDescriber::Message->describe_message( $_ ) }
                grep { App::ChatWorkDescriber::Message->does_description_need( $_ ) }
                map  { $_->body }
                @messages;
    $self->messages( \@messages );

    if ( $self->debug ) {
        warn "got messages: ", scalar @messages;
    }

    $self->emit( "new_messages" )
        if @messages;

    return;
}

sub post_described_messages {
    my $self = shift;

    while ( my $message = shift @{ $self->messages } ) {
        if ( $self->debug ) {
            warn "posting message";
        }

        $self->room->post_message( $message );
    }

    return;
}

1;

__END__
=encoding utf8

=head1 NAME

App::ChatWorkDescriber::Room - Room class to fetch new messages, and post described message

=head1 SYNOPSIS

  use App::ChatWorkDescriber::Room;
  my $room = App::ChatWorkDescriber::Room->new(
      api => $api,
  );
  $room->setup( $room_name );
  $room->fetch;
  $room->post_described_messages;

=head1 DESCRIPTION

This class holds room data of WebService::ChatWorkApi, and query to the room to
wether new messages are posted.  If there exists new messages, then this instance
stores it to self, and then use it at posting described message.
