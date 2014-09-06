use strict;
use warnings;

use Alien::Base::ModuleBuild;

my $builder = Alien::Base::ModuleBuild->new(
	module_name => 'Alien::LibXML',
	license => 'mit',
	configure_requires => {
		'Alien::Base'   => '0.001',
		'Module::Build' => '0.38',
		'File::Which'   => 0,       # remove this for non-dev release
	},
	requires => {
		'perl'        => '5.8.9',
		'Alien::Base' => '0',
	},
	dist_author => 'Toby Inkster <tobyink@cpan.org>',
	alien_name => 'libxml-2.0',
	alien_repository => {
		protocol => 'ftp',
		host     => 'xmlsoft.org',
		location => 'libxml2/',
		pattern  => qr/^libxml2-([\d\.]+)\.tar\.gz$/,
	},
	alien_build_commands => [
                '%pconfigure --prefix=%s --without-python --enable-shared --enable-static --with-pic',
                'make',
	],
);
$builder->create_build_script;

