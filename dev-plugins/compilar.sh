#!/bin/sh
if [ $(uname -a|grep amd64|wc -l) -gt 0 ]
	then 
		 PATH=$PATH:$(pwd)/node64/bin/;
	else
		 PATH=$PATH:$(pwd)/node/bin/;
fi;
if [ $# -eq 0 ] 
	then
		TEMA="default";
	else
		TEMA=$1;
	fi
	
export PATH;
cd bootstrapless/intranet/$TEMA/ 
lessc --verbose --compress meran.less  > $OLDPWD/../intranet/htdocs/intranet-tmpl/temas/$TEMA/includes/intranet.css
cd $OLDPWD
cd bootstrapless/opac/$TEMA/
lessc --compress meran.less  > $OLDPWD/../opac/htdocs/opac-tmpl/temas/$TEMA/includes/opac.css
cd $OLDPWD
