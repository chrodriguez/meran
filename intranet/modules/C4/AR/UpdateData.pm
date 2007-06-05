package C4::AR::UpdateData;


use strict;
require Exporter;

use C4::Context;
use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(checkUpdateData);


sub checkUpdateData{
my $dbh = C4::Context->dbh;
my $sth=$dbh->prepare("select value from systempreferences where variable=?");
$sth->execute("CheckUpdateDataEnabled");
 
return ($sth->fetchrow eq 'no');
}
