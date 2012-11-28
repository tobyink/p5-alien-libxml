#!/usr/bin/env perl

package MakeChanges {

	use Moose;
	use RDF::DOAP::ChangeSets;
	use RDF::TrineX::Parser::Pretdsl;
	use Path::Class qw( file dir );
	use URI::file;

	has destination => (
		is         => 'ro',
		isa        => 'Path::Class::File',
		default    => sub { file('Changes') },
	);

	has input_dir => (
		is         => 'ro',
		isa        => 'Path::Class::Dir',
		default    => sub { dir('meta') },
	);

	has input_model => (
		is         => 'ro',
		isa        => 'RDF::Trine::Model',
		lazy_build => 1,
	);

	sub _build_input_model {
		my $self  = shift;
		my $model = RDF::Trine::Model->new;
		warn "Reading @{[ $self->input_dir ]}...\n";
		foreach my $f ($self->input_dir->children) {
			next if $f->is_dir;
			warn "\tParsing $f\n";
			my $base = URI::file->new_abs("$f");
			if ($f =~ /\.pret$/) {
				RDF::TrineX::Parser::Pretdsl->parse_file_into_model("$base", "$f", $model);
			}
			else {
				RDF::Trine::Parser->parse_file_into_model("$base", "$f", $model);
			}
		}
		warn "Read @{[ $model->size ]} statements.\n";
		return $model;
	}
	
	sub run {
		my $self = shift;
		my $dcs = RDF::DOAP::ChangeSets->new(
			undef,
			$self->input_model,
			'current',
		);
		warn "Writing @{[ $self->destination ]}.\n";
		$dcs->to_file($self->destination);
	}
}

MakeChanges->new->run unless caller;
