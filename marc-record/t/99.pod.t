use Test::More;

use File::Spec;
use File::Find;
use strict;

eval {
    require Pod::Simple;
};

my @files;

if ($@) {
    plan skip_all => "Pod::Simple required for testing POD";
} else {
    my $blib = File::Spec->catfile(qw(blib lib));
    find(\&wanted, $blib);
    plan tests => scalar @files;

    foreach my $file (@files) {
	my $checker = Pod::Simple->new;
	my $dummy;

	$checker->parse_file( $file );
	$checker->output_string( \$dummy );

	if ( $checker->any_errata_seen ) {
	    fail( $file );

	    my $lines = $checker->{errata};
	    for my $line ( sort { $a<=>$b } keys %$lines ) {
		my $errors = $lines->{$line};
		diag( "Line $line: $_" ) for @$errors;
	    }
	} else {
	    pass( $file );
	}
    }
}

sub wanted {
    push @files, $File::Find::name if /\.p(l|m|od)$/ || /\.t$/;
}
