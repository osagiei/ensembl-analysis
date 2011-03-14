
=pod

=head1 NAME

Bio::EnsEMBL::Analysis::Runnable::Sam2Bam

=head1 SYNOPSIS

  my $runnable = 
    Bio::EnsEMBL::Analysis::Runnable::Sam2Bam->new();

 $runnable->run;
 my @results = $runnable->output;
 
=head1 DESCRIPTION

This module uses samtools to convert a directory containing SAM
files into a single sorted indexed merged BAM file


=head1 CONTACT

ensembl-dev@ebi.ac.uk

=cut

package Bio::EnsEMBL::Analysis::Runnable::Sam2Bam;

use vars qw(@ISA);
use strict;

use Bio::EnsEMBL::Analysis::Runnable;
use Bio::EnsEMBL::Utils::Exception qw(throw warning);
use Bio::EnsEMBL::Utils::Argument qw( rearrange );

@ISA = qw(Bio::EnsEMBL::Analysis::Runnable);

sub new {
  my ( $class, @args ) = @_;
  my $self = $class->SUPER::new(@args);
  my ($regex, $samdir,$bamfile,$genome) = rearrange([qw(REGEX SAMDIR BAMFILE GENOME)],@args);
  $self->throw("You must defne a directory with sam files in\n")  unless $samdir ;
  $self->samdir($samdir);
  $self->throw("You must defne a regex\n")  unless $regex;
  $self->regex($regex);
  $self->throw("You must defne an output file\n")  unless $bamfile;
  $self->bamfile($bamfile);
  $self->throw("You must defne a genome file\n")  unless $genome;
  $self->genome($genome);
  return $self;
}

=head2 run

  Args       : none
  Description: Merges Sam files defined in the config using Samtools
  Returntype : none

=cut 

sub run {
  my ($self) = @_;
  # get a list of files to use
  my @files;

  my $dir = $self->samdir;
  my $regex = $self->regex;
  my $bamfile = $self->bamfile;
  my $program = $self->program;
  open  (my $fh,"ls -1 $dir |" ) || 
    $self->throw("Error finding sam files in $dir\n");
  while (<$fh>){
    if ( $_ =~ m/($regex)/) {
      push @files,$_;
    }
  }
  print "Found " . scalar(@files) ." files \n";
  # next make all the sam files into one big sam flie
  open (BAM ,">$bamfile.sam" ) or $self->throw("Cannot open sam file for merging $bamfile.sam");
  my $count = 0;
  foreach my $file ( @files ) {
    open ( SAM ,"$dir/$file") or $self->throw("Cannot open file $dir/$file\n");
    while (<SAM>) {
      # 1st file copy the header all the others just copy the data
      chomp;
      next if $_ =~ /^\@/ && $count > 0;
      print BAM "$_\n";
    }
    $count++;
  } 
  print "Merged $count files\n";
  # now call sam tools to do the conversion.
  # is the genome file indexed?
  # might want to check if it's already indexed first
  my $command = "$program faidx " . $self->genome ;
  open  ( $fh,"$command |" ) || 
    $self->throw("Error indexing fasta file $@\n");
  # write output
  while(<$fh>){
    chomp;
    print STDERR "INDEX $_";
  }
  $command = "$program import " . $self->genome ." $bamfile.sam  $bamfile.bam ";
  open  ( $fh,"$command |" ) || 
    $self->throw("Error making BAM file $@\n");
  # write output
  while(<$fh>){
    chomp;
    print STDERR "IMPORT $_";
  }
  $command = "$program sort $bamfile.bam ".$bamfile."_sorted";
  open  ( $fh,"$command |" ) || 
    $self->throw("Error sorting BAM file $@\n");
  # write output
  while(<$fh>){
    chomp;
    print STDERR "SORT $_";
  }
  $command = "$program index ".$bamfile."_sorted.bam";
  open  ( $fh,"$command |" ) || 
    $self->throw("Error sorting BAM file $@\n");
  # write output
  while(<$fh>){
    chomp;
    print STDERR "INDEXBAM $_";
  }
}




#Containers
#=================================================================

sub samdir {
  my ($self,$value) = @_;

  if (defined $value) {
    $self->{'_samdir'} = $value;
  }
  
  if (exists($self->{'_samdir'})) {
    return $self->{'_samdir'};
  } else {
    return undef;
  }
}

sub regex {
  my ($self,$value) = @_;

  if (defined $value) {
    $self->{'_regex'} = $value;
  }
  
  if (exists($self->{'_regex'})) {
    return $self->{'_regex'};
  } else {
    return undef;
  }
}

sub bamfile {
  my ($self,$value) = @_;

  if (defined $value) {
    $self->{'_bamfile'} = $value;
  }
  
  if (exists($self->{'_bamfile'})) {
    return $self->{'_bamfile'};
  } else {
    return undef;
  }
}


sub genome {
  my ($self,$value) = @_;

  if (defined $value) {
    $self->{'_genome'} = $value;
  }
  
  if (exists($self->{'_genome'})) {
    return $self->{'_genome'};
  } else {
    return undef;
  }
}