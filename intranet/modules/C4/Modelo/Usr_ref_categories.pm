package Usr_ref_categories;

# this class IS a "Usr_persona::DB::Object" 
# and contains all the methodes that 
# Usr_persona::DB::Object does
use base 'MeranDB::DB::Object';

# call the methode My::DB::Object->meta->setup() to 
# announce the layout of our database table;
=item
__PACKAGE__->meta->setup
  (
    table   => 'products',
    columns =>
        [
            id    => { type => 'integer', not_null => 1 },
            name  => { type => 'varchar', length => 255, not_null => 1 },
            price => { type => 'decimal' },
        ],
    primary_key_columns => 'id',
    unique_key => 'name',
    relationships => [],
);
=cut


  __PACKAGE__->meta->setup
  (
    table => 'usr_ref_categories',
    auto  => 1,
  );


sub getCategory_code{
    my ($self) = shift;
    return ($self->category_code);
}

sub setCategory_code{
    my ($self) = shift;
    my ($category_code) = @_;
    $self->category_code($category_code);
}


sub getDescription{
    my ($self) = shift;
    return ($self->description);
}

sub setDescription{
    my ($self) = shift;
    my ($description) = @_;
    $self->description($description);
}

sub getEnrolment_period{
    my ($self) = shift;
    return ($self->enrolment_period);
}

sub setEnrolment_period{
    my ($self) = shift;
    my ($enrolment_period) = @_;
    $self->enrolment_period($enrolment_period);
}

sub getUpper_age_limit{
    my ($self) = shift;
    return ($self->upper_age_limit);
}

sub setUpper_age_limit{
    my ($self) = shift;
    my ($upper_age_limit) = @_;
    $self->upper_age_limit($upper_age_limit);
}

sub getDate_of_birth_required{
    my ($self) = shift;
    return ($self->date_of_birth_required);
}

sub setDate_of_birth_required{
    my ($self) = shift;
    my ($date_of_birth_required) = @_;
    $self->date_of_birth_required($date_of_birth_required);
}

sub getFine_type{
    my ($self) = shift;
    return ($self->fine_type);
}

sub setFine_type{
    my ($self) = shift;
    my ($fine_type) = @_;
    $self->fine_type($fine_type);
}

sub getBulk{
    my ($self) = shift;
    return ($self->bulk);
}

sub setBulk{
    my ($self) = shift;
    my ($bulk) = @_;
    $self->bulk($bulk);
}

sub getEnrolment_fee{
    my ($self) = shift;
    return ($self->enrolment_fee);
}

sub setEnrolment_fee{
    my ($self) = shift;
    my ($enrolment_fee) = @_;
    $self->enrolment_fee($enrolment_fee);
}

sub getOver_due_notice_required{
    my ($self) = shift;
    return ($self->over_due_notice_required);
}

sub setOver_due_notice_required{
    my ($self) = shift;
    my ($over_due_notice_required) = @_;
    $self->over_due_notice_required($over_due_notice_required);
}

sub getIssue_limit{
    my ($self) = shift;
    return ($self->issue_limit);
}

sub setIssue_limit{
    my ($self) = shift;
    my ($issue_limit) = @_;
    $self->issue_limit($issue_limit);
}

sub getReserve_fee{
    my ($self) = shift;
    return ($self->reserve_fee);
}

sub setReserve_fee{
    my ($self) = shift;
    my ($reserve_fee) = @_;
    $self->reserve_fee($reserve_fee);
}

sub getBorrowing_days{
    my ($self) = shift;
    return ($self->borrowing_days);
}

sub setBorrowing_days{
    my ($self) = shift;
    my ($borrowing_days) = @_;
    $self->borrowing_days($borrowing_days);
}
1;
