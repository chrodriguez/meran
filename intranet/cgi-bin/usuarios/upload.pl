#!/usr/bin/perl
use CGI;
use C4::Context;
use C4::AR::UploadFile;

my $query=new CGI;
my $bornum= $query->param('bornum');
my $filepath= $query->param('picture');
open(A,">>/tmp/debug.txt");
print A "bornum ".$bornum."\n";
print A "picture ".$filepath."\n";
# my $foto_name= $query->param('foto_name');
# ($foto_name) || ($foto_name=0);
# my $msg= &C4::AR::UploadFile::uploadPhoto($bornum,$filepath);

# my $bornum= $obj->{'borrowernumber'};
# my $filepath= $obj->{'picture'};
my $msg= &C4::AR::UploadFile::uploadPhoto($bornum,$filepath);
close(A);

print $query->header;
