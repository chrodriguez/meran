package C4::AR::BackgroundJob;

use strict;
use C4::Context;
use C4::AR::Auth;
use Digest::MD5;

=head1 METHODS

=head2 new

 my $job = C4::BackgroundJob->new($sessionID, $job_name, $job_invoker, $num_work_units);

Create a new job object and set its status to 'running'.  C<$num_work_units>
should be a number representing the size of the job; the units of the
job size are up to the caller and could be number of records, 
number of bytes, etc.

=cut

sub new {
    my $class = shift;
    my ($job_name, $job_invoker, $num_work_units) = @_;

    my $self = {};
    $self->{'name'} = $job_name;
    $self->{'invoker'} = $job_invoker;
    $self->{'size'} = $num_work_units;
    $self->{'progress'} = 0;
    $self->{'status'} = "running";
    $self->{'jobID'} = Digest::MD5::md5_hex(Digest::MD5::md5_hex(time().{}.rand().{}.$$));

    bless $self, $class;
    $self->_serialize();

    return $self;
}

# store object in CGI session
sub _serialize {
    my $self = shift;

    my $prefix = "job_" . $self->{'jobID'};
    my $session = CGI::Session->load();
    $session->param($prefix, $self);
    $session->flush();
}

=head2 id

 my $jobID = $job->id();

Read-only accessor for job ID.

=cut

sub id {
    my $self = shift;
    return $self->{'jobID'};
}

=head2 name

 my $name = $job->name();
 $job->name($name);

Read/write accessor for job name.

=cut

sub name {
    my $self = shift;
    if (@_) {
        $self->{'name'} = shift;
        $self->_serialize();
    } else {
        return $self->{'name'};
    }
}

=head2 invoker

 my $invoker = $job->invoker();
i $job->invoker($invoker);

Read/write accessor for job invoker.

=cut

sub invoker {
    my $self = shift;
    if (@_) {
        $self->{'invoker'} = shift;
        $self->_serialize();
    } else {
        return $self->{'invoker'};
    }
}

=head2 progress

 my $progress = $job->progress();
 $job->progress($progress);

Read/write accessor for job progress.

=cut

sub progress {
    my $self = shift;
    if (@_) {
        $self->{'progress'} = shift;
        $self->_serialize();
    } else {
        return $self->{'progress'};
    }
}

=head2 status

 my $status = $job->status();

Read-only accessor for job status.

=cut

sub status {
    my $self = shift;
    return $self->{'status'};
}

=head2 size

 my $size = $job->size();
 $job->size($size);

Read/write accessor for job size.

=cut

sub size {
    my $self = shift;
    if (@_) {
        $self->{'size'} = shift;
        $self->_serialize();
    } else {
        return $self->{'size'};
    }
}

=head2 finish

 $job->finish($results_hashref);

Mark the job as finished, setting its status to 'completed'.
C<$results_hashref> should be a reference to a hash containing
the results of the job.

=cut

sub finish {
    my $self = shift;
    my $results_hashref = shift;
    $self->{'status'} = 'completed';
    $self->{'results'} = $results_hashref;
    $self->_serialize();
}

=head2 results

 my $results_hashref = $job->results();

Retrieve the results of the current job.  Returns undef 
if the job status is not 'completed'.

=cut

sub results {
    my $self = shift;
    return undef unless $self->{'status'} eq 'completed';
    return $self->{'results'};
}

=head2 fetch

 my $job = C4::BackgroundJob->fetch($sessionID, $jobID);

Retrieve a job that has been serialized to the database. 
Returns C<undef> if the job does not exist in the current 
session.

=cut

sub fetch {
    my $class = shift;
    my $jobID = shift;

    my $session = CGI::Session->load();
    my $prefix = "job_$jobID";
    unless (defined $session->param($prefix)) {
        return undef;
    }
    my $self = $session->param($prefix);
    bless $self, $class;
    return $self;
}

1;
__END__
