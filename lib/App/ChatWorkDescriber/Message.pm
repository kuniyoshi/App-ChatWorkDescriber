package App::ChatWorkDescriber::Message;
use Mojo::Base -strict;
use Mojo::UserAgent;
use Mojo::URL;
use WebService::ChatWork::Message;

our $UA = Mojo::UserAgent->new;

sub does_description_need {
    my $_class  = shift;
    my $message = shift;
    my @lines = grep { length } split m{\n}, $message;
    return
        if @lines != 1;
    my $line = shift @lines;
    my $url = Mojo::URL->new( $line );
    return $url->scheme && $url->scheme =~ m{\A https? }msx && $url eq $line;
}

sub describe_message {
    my $_class = shift;
    my $url    = Mojo::URL->new( shift );
    my $title = $UA->get( $url )->res->dom->at( "title" )->text;
    my $message = WebService::ChatWork::Message->new( info => ( title => $title, message => "$url" ) );
    return $message;
}

1;
