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

__END__
=encoding utf8

=head1 NAME

App::ChatWorkDescriber::Message - Provides functions to wether description is needed

=head1 SYNOPSIS

  use App::ChatWorkDescriber::Message;
  my $message = "http://example.com";
  warn App::ChatWorkDescriber::Message->does_description_need; # <- 1;
  warn App::ChatWorkDescriber::Message->describe_message; # <- Example Domain;

=head1 DESCRIPTION

This module provides a few functions which will be applied to message.

=head1 FUNCTIONS (CLASS METHODS)

=over

=item does_description_need

Returns bool wether the message needs to be described.

=item describe_message

Returns a description which is tagged.  The tag spec. is ChatWork spec.

=back
