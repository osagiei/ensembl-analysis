
=head1 NAME

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

package Bio::EnsEMBL::Analysis::RunnableDB::ProteinAnnotation::PrositeProfile_wormbase;
use vars qw(@ISA);

use strict;
use Bio::EnsEMBL::Analysis::RunnableDB::ProteinAnnotation;
use Bio::EnsEMBL::Analysis::Runnable::ProteinAnnotation::PrositeProfile_wormbase;

@ISA = qw (Bio::EnsEMBL::Analysis::RunnableDB::ProteinAnnotation);


sub fetch_input {
  my ($self, @args) = @_;

  $self->SUPER::fetch_input(@args);

  my $run = Bio::EnsEMBL::Analysis::Runnable::ProteinAnnotation::PrositeProfile_wormbase->
      new(-query     => $self->query,
          -analysis  => $self->analysis);
  $self->runnable($run);
}


1;





