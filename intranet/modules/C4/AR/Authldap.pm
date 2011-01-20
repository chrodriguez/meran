package C4::AR::Authldap;


#package for ldap authentification
#Sirve tanto para utilizar el esquema propio de Meran como para 
#autenticarse en un dominio

require Exporter;
use strict;
use Net::LDAP;
use Net::LDAPS;
use Net::LDAP::LDIF;
use Net::LDAP::Util qw(ldap_error_text);
use Net::LDAP::Constant qw(LDAP_EXTENSION_START_TLS);

@ISA = qw(Exporter);
@EXPORT = qw(checkpwldap getldappassword checkpwDC);


sub _esSuperUsusario
{
    my ($userid, $password) = @_;
    my $superpasswd=C4::Context->config('pass');
   return ($userid eq C4::Context->config('user') && $password eq $superpasswd);
}


sub checkpwDC
{
    my ($userid, $password) = @_;
    my $LDAP_SERVER= C4::Context->config("ldapserver");
    my $LDAP_INFOS= C4::Context->config("ldapinfos");
    my $LDAP_PORT= C4::Context->config("ldapport");
    my $LDAP_TYPE=C4::Context->config("ldaptype");
    my $userDN = 'cn='.$userid.','.$LDAPINFOS;
    
    if ($LDAP_TYPE ne 'SSL'){
        my $ldap = Net::LDAP->new($LDAP_SERVER, port => $LDAP_PORT) or die "Coult not create LDAP object because:\n$!";
        if ($LDAP_TYPE eq 'TLS') {
            my $dse = $ldap->root_dse();
            my $doesSupportTLS = $dse->supported_extension(LDAP_EXTENSION_START_TLS);
            die "Server does not support TLS\n" unless($doesSupportTLS);
            my $startTLSMsg = $ldap->start_tls();
            die $startTLSMsg->error if $startTLSMsg->is_error;
        } 
    }
    else{
        my $ldap = Net::LDAPS->new($LDAP_SERVER, port => $LDAP_PORT) or die "Coult not create LDAP object because:\n$!";
    }
    
    #Primero me fijo si es un usuario del domnio 
    my $ldapMsg = $ldap->bind($userDN, password => $PASSWORD);
    if ($ldapMsg->done()) {
            my $consulta=$dbh->prepare("select cardnumber,branchcode from borrowers where cardnumber =?");
            $consulta->execute($userid);
            my ($usuario,$branchcode) = $consulta->fetchrow;
            if (($usuario  eq $userid)){
                    return 1,$userid,$branchcode;
            }
    }
    #Despues me fijo si es superusuario
    my $superbranch=C4::Context->config('branch');
    if (_esSuperUsusario($userid,$password)){
                    # Koha superuser account
                    return 2,0,$superbranch;
            }
    #Finalmente me fijo si el usuario es demo, esto esta deprecated
    if ($userid eq 'demo' && $password eq 'demo' && C4::Context->config('demo')) {
                    return 2,0,$superbranch;
            }
    die $ldapMsg->error if $ldapMsg->is_error;
    #Finalmente si no es ni usuario valido, ni superusuario, ni un sitio demo se marca como invalidas las credenciales
    return 0;

}

# Referencia http://blog.case.edu/jeremy.smith/2004/12/13/bind_ldap_perl


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
                return 2,0,$superbranch;
        }
        return 0;
}


sub getldappassword {
    #It gets the password for a particular userid
    my ($userid) = @_;
    my $ldapserver= C4::Context->config("ldapserver");
    my $ldapinfos= C4::Context->config("ldapinfos");
    my $ldaproot= C4::Context->config("ldaproot");
    my $ldappass= C4::Context->config("ldappass");
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
