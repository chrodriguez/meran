#!/usr/bin/perl
use CGI;
use C4::Context;
use C4::AR::UploadFile;

my $query=new CGI;
my $bornum= $query->param('bornum');
my $filepath= $query->param('picture');
my $foto_name= $query->param('foto_name');
($foto_name) || ($foto_name=0);
my $msg= uploadPicture($bornum,$foto_name,$filepath);

print $query->redirect("/cgi-bin/koha/usuarios/reales/datosUsuario.pl?bornum=$bornum&msg=$msg");
