#!perl -s
use Mojo::Base -strict;
use Data::Dumper;
use Encode;
use App::ChatWorkDescriber;

our $token
    or die usage( );
our $name
    or die usage( );
our $verbose;

$name = Encode::decode_utf8( $name );

my $describer = App::ChatWorkDescriber->new( verbose => $verbose );
$describer->set_api( $token );
$describer->set_ticker;
$describer->add_room( $name );

exit $describer->loop;

sub usage {
    return <<END_USAGE;
usage: $0 [-verbose] -token=<your api token> -name=<chat name>
END_USAGE
}
