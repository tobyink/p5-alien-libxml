#!/usr/bin/env perl

package MakeChanges {
	
	use Moose;
	use RDF::DOAP;
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
	
	has project => (
		is         => 'ro',
		isa        => 'RDF::DOAP::Project',
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
	
	sub _build_project {
		my $self = shift;
		RDF::DOAP->new->from_model($self->input_model)->project;
	}
	
	sub run {
		my $self = shift;
		
		warn "Writing @{[ $self->changes_destination ]}.\n";
		$self->changes_destination->spew($self->project->changelog);
		
		warn "Writing @{[ $self->doap_destination ]}.\n";
		RDF::TrineX::Serializer::MockTurtleSoup->new->serialize_model_to_file(
			$self->doap_destination->openw,
			$self->input_model,
		);
	}
}

MakeChanges->new->run unless caller;
