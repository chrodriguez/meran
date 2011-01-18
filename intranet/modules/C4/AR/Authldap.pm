package C4::AR::Authldap;


#package for ldap authentification
#written 24/06/2003 by lerenarm@esiee.fr

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

require Exporter;
use strict;
use Net::LDAP;

@ISA = qw(Exporter);
@EXPORT = qw(checkpwldap getldappassword);

sub checkpwldap{
    my ($userid, $password, $random_number) = @_;
    my $dbh = C4::Context->dbh;
    #FIXME el pass del ldap deberia estar en el archivo de configuracion y no en la base de datos.	
    my $p= getldappassword($userid);
	$p= md5_base64($p.$random_number);
    my $consulta=$dbh->prepare("select cardnumber,branchcode from borrowers where cardnumber =?");
	$consulta->execute($userid);
	my ($usuario,$branchcode) = $consulta->fetchrow;

	if (($p eq $password)  && ($usuario  eq $userid)){
		return 1,$userid,$branchcode;
        }
	my $superpasswd=C4::Context->config('pass');
	$superpasswd= md5_base64(md5_base64($superpasswd).$random_number);
	my $superbranch=C4::Context->config('branch');
	if ($userid eq C4::Context->config('user') && $password eq $superpasswd) {
        	# Koha superuser account
                return 2,0,$superbranch;
        }

        if ($userid eq 'demo' && $password eq 'demo' && C4::Context->config('demo')) {
                # DEMO => the demo user is allowed to do everything (if demo set to 1 in koha.conf
                # some features won't be effective : modify systempref, modify MARC structure,
                return 2;
        }
        return 0;
}


sub getldappassword {
    #It gets the password for a particular userid
	my ($userid) = @_;
    my $ldapserver= C4::AR::Preferencias->getValorPreferencia("ldapserver");
    my $ldapinfos= C4::AR::Preferencias->getValorPreferencia("ldapinfos");
    my $ldaproot= C4::AR::Preferencias->getValorPreferencia("ldaproot");
    my $ldappass= C4::AR::Preferencias->getValorPreferencia("ldappass");
    my %bindargs;
    my $nom  = "uid=$userid, $ldapinfos";
    my $db = Net::LDAP->new($ldapserver);
    my $res = $db->bind( 'cn='.$ldaproot.','.$ldapinfos , password => $ldappass) or die "$@";
    my $entries = $db->search(
                    base   => $ldapinfos,
                    filter => "(uid = $userid)"
                    );
    my $p;
    my $entry;
    my @values;
    foreach $entry ($entries->all_entries) {
            @values = $entry->get_value("userPassword");
            $p= @values[0];
    }
    return($p);
}
