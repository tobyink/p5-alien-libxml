use strict;
use warnings;
use Test::More;

BEGIN {
	eval { require File::Which } or plan skip_all => 'need File::Which';
	File::Which->import('which');
};

use Config;
use File::Spec;

my $CC;
BEGIN {
	$CC = $Config{cc} || 'gcc';
	$CC = File::Spec->file_name_is_absolute($CC) ? $CC : which($CC)
		or plan skip_all => "could not find $CC";
	
	-x $CC
		or plan skip_all => "$CC is not executable";
};

use Alien::LibXML;
use Text::ParseWords qw( shellwords );

sub file ($) { File::Spec->catfile(split m{/}, $_[0]) }

my @libs   = shellwords( Alien::LibXML->libs );
my @cflags = shellwords( Alien::LibXML->cflags );

diag "COMPILER: $CC";
diag "CFLAGS:   @cflags";
diag "LIBS:     @libs";
diag "OUTPUT:   @{[ file 't/tree1.exe' ]}";
diag "INPUT:    @{[ file 't/tree1.c' ]}";

system(
	$CC, @cflags, @libs,
	-o => file 't/tree1.exe',
	      file 't/tree1.c',
);

ok -x 't/tree1.exe';

my $cmd = sprintf '%s %s', file 't/tree1.exe', file 't/tree1.xml';
is(`$cmd`, <<'EXPECTED');
node type: Element, name: root
node type: Element, name: inner
EXPECTED

# clean up
my $count = 0;
while (unlink file 't/tree1.exe') {
	last if ++$count > 5;
}

done_testing;

