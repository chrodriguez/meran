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
use Digest::MD5 qw(md5_base64);
use C4::Context;
use Net::LDAP;
use Net::LDAP qw(:all);
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

@ISA = qw(Exporter);
@EXPORT = qw(checkpwldap getldappassword);

sub checkpwldap{
                                                                                                                             
# This should be modified to allow a selection of authentication schemes
# (e.g. LDAP), as well as local authentication through the borrowers
# tables passwd field
#

        my ($dbh, $userid, $password, $random_number) = @_;

	my $p= getldappassword($userid,$dbh);

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
	my ($userid,$dbh) = @_;
        my $sth=$dbh->prepare("select value from pref_preferencia_sistema where variable=?");
        $sth->execute("ldapserver");
        my $ldapserver = $sth->fetchrow;
        $sth->execute("ldapinfos");
        my $ldapinfos = $sth->fetchrow;
                                                                                                                             
        $sth->execute("ldaproot");
        my $ldaproot = $sth->fetchrow;
        $sth->execute("ldappass");
        my $ldappass = $sth->fetchrow;
                                                                                                                             
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
