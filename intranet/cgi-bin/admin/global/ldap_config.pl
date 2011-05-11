#!/usr/bin/perl

use strict;
use CGI;
use C4::AR::Auth;
use C4::Output;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                        template_name   => "admin/global/ldapConfig.tmpl",
                        query           => $input,
                        type            => "intranet",
                        authnotrequired => 0,
                        flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                        debug           => 1,
			    });

#preguntamos si esta guardando la informacion o mostrando el tmpl normalmente 
if($input->param('adding') == 1){

    # FIXME: armar una HASH envez de uno por uno

    C4::AR::Authldap::setVariableLdap('ldap_version',$input->param('version'));
    C4::AR::Authldap::setVariableLdap('ldap_server',$input->param('host_url'));
    
    # agregadas luego
    C4::AR::Authldap::setVariableLdap('ldap_port',$input->param('host_port'));
    C4::AR::Authldap::setVariableLdap('ldap_type',$input->param('host_type'));
    C4::AR::Authldap::setVariableLdap('ldap_user_prefijo',$input->param('user_prefijo'));
    C4::AR::Authldap::setVariableLdap('ldap_prefijo_base',$input->param('prefijo_base'));
    C4::AR::Authldap::setVariableLdap('ldap_agregar_user',$input->param('agregar_user_ldap'));
    # fin
    
    C4::AR::Authldap::setVariableLdap('ldap_encoding',$input->param('ldapencoding'));
    C4::AR::Authldap::setVariableLdap('ldap_preventpassindb',$input->param('preventpassindb'));
    C4::AR::Authldap::setVariableLdap('ldap_bind_dn',$input->param('bind_dn'));
    C4::AR::Authldap::setVariableLdap('ldap_bind_pw',$input->param('bind_pw'));
    C4::AR::Authldap::setVariableLdap('ldap_user_type',$input->param('user_type'));
    C4::AR::Authldap::setVariableLdap('ldap_contexts',$input->param('contexts'));
    C4::AR::Authldap::setVariableLdap('ldap_search_sub',$input->param('search_sub'));
    C4::AR::Authldap::setVariableLdap('ldap_opt_deref',$input->param('opt_deref'));
    C4::AR::Authldap::setVariableLdap('ldap_user_attribute',$input->param('user_attribute'));
    C4::AR::Authldap::setVariableLdap('ldap_memberattribute',$input->param('memberattribute'));
    C4::AR::Authldap::setVariableLdap('ldap_memberattribute_isdn',$input->param('memberattribute_isdn'));
    C4::AR::Authldap::setVariableLdap('ldap_objectclass',$input->param('objectclass'));
    C4::AR::Authldap::setVariableLdap('ldap_forcechangepassword',$input->param('forcechangepassword'));
    C4::AR::Authldap::setVariableLdap('ldap_stdchangepassword',$input->param('stdchangepassword'));
    C4::AR::Authldap::setVariableLdap('ldap_passtype',$input->param('passtype'));
    C4::AR::Authldap::setVariableLdap('ldap_changepasswordurl',$input->param('changepasswordurl'));
    C4::AR::Authldap::setVariableLdap('ldap_expiration',$input->param('expiration'));
    C4::AR::Authldap::setVariableLdap('ldap_expiration_warning',$input->param('expiration_warning'));
    C4::AR::Authldap::setVariableLdap('ldap_expireattr',$input->param('expireattr'));
    C4::AR::Authldap::setVariableLdap('ldap_gracelogins',$input->param('gracelogins'));
    C4::AR::Authldap::setVariableLdap('ldap_graceattr',$input->param('graceattr'));
    C4::AR::Authldap::setVariableLdap('ldap_auth_user_create',$input->param('auth_user_create'));
    C4::AR::Authldap::setVariableLdap('ldap_create_context',$input->param('create_context'));
    C4::AR::Authldap::setVariableLdap('ldap_creators',$input->param('creators'));
    C4::AR::Authldap::setVariableLdap('ldap_removeuser',$input->param('removeuser'));
    C4::AR::Authldap::setVariableLdap('ldap_ntlmsso_enabled',$input->param('ntlmsso_enabled'));
    C4::AR::Authldap::setVariableLdap('ldap_ntlmsso_subnet',$input->param('ntlmsso_subnet'));
    C4::AR::Authldap::setVariableLdap('ldap_ntlmsso_ie_fastpath',$input->param('ntlmsso_ie_fastpath'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_map_firstnames',$input->param('lockconfig_field_map_firstnames'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_updatelocal_firstname',$input->param('lockconfig_field_updatelocal_firstname'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_updateremote_firstname',$input->param('lockconfig_field_updateremote_firstname'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_lock_firstname',$input->param('lockconfig_field_lock_firstname'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_map_lastname',$input->param('lockconfig_field_map_lastname'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_updatelocal_lastname',$input->param('lockconfig_field_updatelocal_lastname'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_updateremote_lastname',$input->param('lockconfig_field_updateremote_lastname'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_lock_lastname',$input->param('lockconfig_field_lock_lastname'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_map_email',$input->param('lockconfig_field_map_email'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_updatelocal_email',$input->param('lockconfig_field_updatelocal_email'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_updateremote_email',$input->param('lockconfig_field_updateremote_email'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_lock_email',$input->param('lockconfig_field_lock_email'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_map_city',$input->param('lockconfig_field_map_city'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_updatelocal_city',$input->param('lockconfig_field_updatelocal_city'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_updateremote_city',$input->param('lockconfig_field_updateremote_city'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_lock_city',$input->param('lockconfig_field_lock_city'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_map_country',$input->param('lockconfig_field_map_country'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_updatelocal_country',$input->param('lockconfig_field_updatelocal_country'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_updateremote_country',$input->param('lockconfig_field_updateremote_country'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_lock_country',$input->param('lockconfig_field_lock_country'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_map_lang',$input->param('lockconfig_field_map_lang'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_updatelocal_lang',$input->param('lockconfig_field_updatelocal_lang'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_updateremote_lang',$input->param('lockconfig_field_updateremote_lang'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_lock_lang',$input->param('lockconfig_field_lock_lang'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_map_description',$input->param('lockconfig_field_map_description'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_updatelocal_description',$input->param('lockconfig_field_updatelocal_description'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_updateremote_description',$input->param('lockconfig_field_updateremote_description'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_lock_description',$input->param('lockconfig_field_lock_description'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_map_url',$input->param('lockconfig_field_map_url'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_updatelocal_url',$input->param('lockconfig_field_updatelocal_url'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_updateremote_url',$input->param('lockconfig_field_updateremote_url'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_lock_url',$input->param('lockconfig_field_lock_url'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_map_idnumber',$input->param('lockconfig_field_map_idnumber'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_updatelocal_idnumber',$input->param('lockconfig_field_updatelocal_idnumber'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_updateremote_idnumber',$input->param('lockconfig_field_updateremote_idnumber'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_lock_idnumber',$input->param('lockconfig_field_lock_idnumber'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_map_institution',$input->param('lockconfig_field_map_institution'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_updatelocal_institution',$input->param('lockconfig_field_updatelocal_institution'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_updateremote_institution',$input->param('lockconfig_field_updateremote_institution'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_lock_institution',$input->param('lockconfig_field_lock_institution'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_map_departament',$input->param('lockconfig_field_map_departament'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_updatelocal_departament',$input->param('lockconfig_field_updatelocal_departament'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_updateremote_departament',$input->param('lockconfig_field_updateremote_departament'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_lock_departament',$input->param('lockconfig_field_lock_departament'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_map_phone1',$input->param('lockconfig_field_map_phone1'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_updatelocal_phone1',$input->param('lockconfig_field_updatelocal_phone1'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_updateremote_phone1',$input->param('lockconfig_field_updateremote_phone1'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_lock_phone1',$input->param('lockconfig_field_lock_phone1'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_map_phone2',$input->param('lockconfig_field_map_phone2'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_updatelocal_phone2',$input->param('lockconfig_field_updatelocal_phone2'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_updateremote_phone2',$input->param('lockconfig_field_updateremote_phone2'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_lock_phone2',$input->param('lockconfig_field_lock_phone2'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_map_adress',$input->param('lockconfig_field_map_adress'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_updatelocal_adress',$input->param('lockconfig_field_updatelocal_adress'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_updateremote_adress',$input->param('lockconfig_field_updateremote_adress'));
    C4::AR::Authldap::setVariableLdap('ldap_lockconfig_field_lock_adress',$input->param('lockconfig_field_lock_adress'));

}
# mostramos el template cargando los datos de configuracion ldap desde la db
# lo hacemos siempre asi cuando se guardan los cambios se reflejan en el template tambien
my $variables_ldap_hash              = C4::AR::Authldap::getLdapPreferences();
$t_params->{'preferencias'}             = $variables_ldap_hash;
$t_params->{'page_sub_title'}       = C4::AR::Filtros::i18n("Configuraci&oacute;n Servidor LDAP");
C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
