use strict;
use warnings;
use Test::More;

BEGIN {
	eval { require File::Which } or plan skip_all => 'need File::Which';
	File::Which->import('which');
};

my $CC;
BEGIN {
	$CC = which('gcc') or plan skip_all => 'could not find gcc';
	-x $CC or plan skip_all => 'gcc is not executable';
};

use Alien::LibXML;
use Text::ParseWords qw( shellwords );
use File::Spec;

sub file { File::Spec->catfile(split m{/}, $_[0]) }

my @libs   = shellwords( Alien::LibXML->libs );
my @cflags = shellwords( Alien::LibXML->cflags );

system(
	$CC, @cflags, @libs,
	'-o', file('t/tree1.exe'),
	file('t/tree1.c'),
);

ok -x 't/tree1.exe';

my $cmd = sprintf '%s %s', file('t/tree1.exe'), file('t/tree1.xml');
is(`$cmd`, <<'EXPECTED');
node type: Element, name: root
node type: Element, name: inner
EXPECTED

my $count = 0;
while (unlink file('t/tree1.exe')) {
	last if ++$count > 5;
}

done_testing;
