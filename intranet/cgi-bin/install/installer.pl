#!/usr/bin/perl
use strict;
use warnings;
use CGI::Session;
use Template;
use File::Basename;
use C4::AR::Auth;
use DBI;
use DBD::mysql;


sub checkDB{
    my $params = shift;
    my $session = shift;

    # CONFIG VARIABLES
    my $platform = "mysql";
    my $database = $params->{'dbname'};
    my $host = $params->{'dbaddress'};
    my $port = "3306";
    my $user = $params->{'dbuser'};
    my $pw = $params->{'dbpassword'};

    #DATA SOURCE NAME
    my $dsn = "dbi:mysql:$database:$host:3306";
    my $dbstore;
    # PERL DBI CONNECT (RENAMED HANDLE)
    if ($dbstore = DBI->connect($dsn, $user, $pw)){

        $session->param('dbname',$database);
        $session->param('dbuser',$user);
        $session->param('dbpassword',$pw);
        $session->param('dbaddress',$host);
        $session->flush();

        return 1;
    }else{
        return $DBI::errstr;    
    }
}

sub checkDependencies{



    my @dep = ();

    if (scalar(@dep)){
        return \@dep;
    }else{
        return 0;
    }

}



my $path = dirname(__FILE__);
my $query= CGI->new();
my $params = $query->Vars;
my $file;
my $vars;

my $template = Template->new({  ABSOLUTE    => 1,
                                INCLUDE_PATH    => [
                                                    $path.'/templates/',
                                            ],
                             });

my $session = CGI::Session->load() || CGI::Session->new();

my $action  = $params->{'action'} || 'default';

if ($action eq 'base'){
    $file = 'base.tmpl';
}elsif($action eq 'checkbase'){
    $file = 'base.tmpl';
    my $msj = checkDB($params,$session);    
    if ($msj != 1){
        $vars->{'mensaje'} = $msj;
        $vars->{'alert_class'} = 'alert-error';
    }else{
        $vars->{'mensaje'} = "La conexi&oacute;n con la base de datos se ha realizado correctamente.";
        $vars->{'alert_class'} = 'alert-success';    
        $vars->{'next'} = 1;
    }

    $vars->{'dbname'} = $params->{'dbname'};
    $vars->{'dbpassword'} = $params->{'dbpassword'};
    $vars->{'dbaddress'} = $params->{'dbaddress'};
    $vars->{'dbuser'} = $params->{'dbuser'};

}elsif($action eq 'nextbase'){
    my $msj = checkDB($params,$session);    
    if ($msj != 1){
        $file = 'base.tmpl';
        $vars->{'mensaje'} = $msj;
        $vars->{'alert_class'} = 'alert-error';
        $vars->{'dbname'} = $params->{'dbname'};
        $vars->{'dbpassword'} = $params->{'dbpassword'};
        $vars->{'dbaddress'} = $params->{'dbaddress'};
        $vars->{'dbuser'} = $params->{'dbuser'};
    }else{
        $file = 'uiconfig.tmpl';
    }
}elsif($action eq 'uiconfig'){
    $session->param('uiname',$params->{'uiname'});
    $session->param('uicode',$params->{'uicode'});
    $session->flush();
    
    $file = 'userconfig.tmpl';

}elsif($action eq 'adduser'){
    $session->param('sysuser',$params->{'sysuser'});
    $session->param('sysuserpassword',$params->{'sysuserpassword'});
    $session->flush();


    $vars->{'dbname'}           = $session->param('dbname');
    $vars->{'dbaddress'}        = $session->param('dbaddress');
    $vars->{'dbuser'}           = $session->param('dbuser');
    $vars->{'dbpassword'}       = $session->param('dbpassword');
    $vars->{'uiname'}           = $session->param('uiname');
    $vars->{'uicode'}           = $session->param('uicode');
    $vars->{'sysuser'}          = $session->param('sysuser');
    $vars->{'sysuserpassword'}  = $session->param('sysuserpassword');

    $file = 'finalstage.tmpl';
}elsif($action eq 'start'){
    my $msj = checkDB($params,$session);    
    if ($msj != 1){
        $file = 'base.tmpl';
        $vars->{'mensaje'} = $msj;
        $vars->{'alert_class'} = 'alert-error';
        $vars->{'dbname'} = $params->{'dbname'};
        $vars->{'dbpassword'} = $params->{'dbpassword'};
        $vars->{'dbaddress'} = $params->{'dbaddress'};
        $vars->{'dbuser'} = $params->{'dbuser'};
    }else{
        #ROCK DEL GATO
    }
}else{
    $file = 'index.tmpl';

    if (checkDependencies()){
        $vars->{'dependencies_not_satisfied'} = checkDependencies();

        $vars->{'mensaje'} = "Su sistema no cumple con los requisitos para que Meran pueda funcionar.";
        $vars->{'alert_class'} = 'alert-error';
    }

}


C4::AR::Auth::print_header($session);
$template->process($path.'/templates/'.$file, $vars)
    || die "Template process failed: ", $template->error(), "\n";

1;