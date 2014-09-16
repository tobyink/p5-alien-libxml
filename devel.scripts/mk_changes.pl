#!/usr/bin/env perl

package MakeChanges {

	use Moose;
	use RDF::DOAP::ChangeSets;
	use RDF::TrineX::Serializer::MockTurtleSoup;
	use RDF::TrineX::Parser::Pretdsl;
	use Path::Class qw( file dir );
	use URI::file;

	has changes_destination => (
		is         => 'ro',
		isa        => 'Path::Class::File',
		default    => sub { file('Changes') },
	);

	has doap_destination => (
		is         => 'ro',
		isa        => 'Path::Class::File',
		default    => sub { file('doap.ttl') },
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
		warn "Writing @{[ $self->changes_destination ]}.\n";
		$dcs->to_file($self->changes_destination);
		
		my $ser = RDF::TrineX::Serializer::MockTurtleSoup->new;
		warn "Writing @{[ $self->doap_destination ]}.\n";
		$ser->serialize_model_to_file(
			$self->doap_destination->openw,
			$self->input_model,
		);
	}
}

MakeChanges->new->run unless caller;
