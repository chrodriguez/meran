#!/bin/sh
if [ ! -z $1 ] && [ -f $1 ]; then
		echo "Procesando $1";
	      else 
		echo "Error, debe pasar el nombre del archivo csv a procesar como parámetro, el csv debe ser separado por ;";
		echo "Invoque sh permisos.sh permisos.csv";
		exit;
	      fi 
echo "Recuerde que debe cambiar los permisos de los usuarios en el archivo permisos.xls y Guardar como csv separado por punto y coma. Presione Enter para continuar";
read; 
echo "Ingrese el usuario para el opac [userOPAC]";
read userOPAC;
if [ -z $userOPAC ]; then  
			userOPAC="userOPAC";
		       fi	
echo "Ingrese el usuario para el userDevelop [userDevelop]";
read userDevelop;
if [ -z $userDevelop ]; then  
			userDevelop="userDevelop";
		       fi	
echo "Ingrese el usuario para la Intranet  [userINTRA]";
read userINTRA;
if [ -z $userINTRA ]; then  
			userINTRA="userINTRA";
		       fi	
echo "Ingrese el usuario para el userAdmin [userAdmin]";
read userAdmin;
if [ -z $userAdmin ]; then  
			userAdmin="userAdmin";
		       fi	
echo "Agregar info para crear los usuarios?(S/N)";
read crear;
if [ $crear = S ]; then 
		echo "Ahora crearemos los usuarios $userOPAC,$userINTRA,$userDevelop y $userAdmin";
		echo "INSERT INTO \`user\` (\`Host\`, \`User\`, \`Password\`, \`Select_priv\`, \`Insert_priv\`, \`Update_priv\`, \`Delete_priv\`, \`Create_priv\`, \`Drop_priv\`, \`Reload_priv\`, \`Shutdown_priv\`, \`Process_priv\`, \`File_priv\`, \`Grant_priv\`, \`References_priv\`, \`Index_priv\`, \`Alter_priv\`, \`Show_db_priv\`, \`Super_priv\`, \`Create_tmp_table_priv\`, \`Lock_tables_priv\`, \`Execute_priv\`, \`Repl_slave_priv\`, \`Repl_client_priv\`, \`Create_view_priv\`, \`Show_view_priv\`, \`Create_routine_priv\`, \`Alter_routine_priv\`, \`Create_user_priv\`, \`ssl_type\`, \`ssl_cipher\`, \`x509_issuer\`, \`x509_subject\`, \`max_questions\`, \`max_updates\`, \`max_connections\`, \`max_user_connections\`) VALUES ('localhost', '$userOPAC', '*27AEDA0D3A56422C3F1D20DAFF0C8109058134F3', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'N', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', '', '', '', '', 0, 0, 0, 0);" > permisos$userOPAC.sql;
		echo "INSERT INTO \`user\` (\`Host\`, \`User\`, \`Password\`, \`Select_priv\`, \`Insert_priv\`, \`Update_priv\`, \`Delete_priv\`, \`Create_priv\`, \`Drop_priv\`, \`Reload_priv\`, \`Shutdown_priv\`, \`Process_priv\`, \`File_priv\`, \`Grant_priv\`, \`References_priv\`, \`Index_priv\`, \`Alter_priv\`, \`Show_db_priv\`, \`Super_priv\`, \`Create_tmp_table_priv\`, \`Lock_tables_priv\`, \`Execute_priv\`, \`Repl_slave_priv\`, \`Repl_client_priv\`, \`Create_view_priv\`, \`Show_view_priv\`, \`Create_routine_priv\`, \`Alter_routine_priv\`, \`Create_user_priv\`, \`ssl_type\`, \`ssl_cipher\`, \`x509_issuer\`, \`x509_subject\`, \`max_questions\`, \`max_updates\`, \`max_connections\`, \`max_user_connections\`) VALUES ('localhost', '$userINTRA', '*27AEDA0D3A56422C3F1D20DAFF0C8109058134F3', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'N', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', '', '', '', '', 0, 0, 0, 0);" > permisos$userINTRA.sql;
		echo "INSERT INTO \`user\` (\`Host\`, \`User\`, \`Password\`, \`Select_priv\`, \`Insert_priv\`, \`Update_priv\`, \`Delete_priv\`, \`Create_priv\`, \`Drop_priv\`, \`Reload_priv\`, \`Shutdown_priv\`, \`Process_priv\`, \`File_priv\`, \`Grant_priv\`, \`References_priv\`, \`Index_priv\`, \`Alter_priv\`, \`Show_db_priv\`, \`Super_priv\`, \`Create_tmp_table_priv\`, \`Lock_tables_priv\`, \`Execute_priv\`, \`Repl_slave_priv\`, \`Repl_client_priv\`, \`Create_view_priv\`, \`Show_view_priv\`, \`Create_routine_priv\`, \`Alter_routine_priv\`, \`Create_user_priv\`, \`ssl_type\`, \`ssl_cipher\`, \`x509_issuer\`, \`x509_subject\`, \`max_questions\`, \`max_updates\`, \`max_connections\`, \`max_user_connections\`) VALUES ('localhost', '$userDevelop', '*27AEDA0D3A56422C3F1D20DAFF0C8109058134F3', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'N', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', '', '', '', '', 0, 0, 0, 0);" > permisos$userDevelop.sql;
		echo "INSERT INTO \`user\` (\`Host\`, \`User\`, \`Password\`, \`Select_priv\`, \`Insert_priv\`, \`Update_priv\`, \`Delete_priv\`, \`Create_priv\`, \`Drop_priv\`, \`Reload_priv\`, \`Shutdown_priv\`, \`Process_priv\`, \`File_priv\`, \`Grant_priv\`, \`References_priv\`, \`Index_priv\`, \`Alter_priv\`, \`Show_db_priv\`, \`Super_priv\`, \`Create_tmp_table_priv\`, \`Lock_tables_priv\`, \`Execute_priv\`, \`Repl_slave_priv\`, \`Repl_client_priv\`, \`Create_view_priv\`, \`Show_view_priv\`, \`Create_routine_priv\`, \`Alter_routine_priv\`, \`Create_user_priv\`, \`ssl_type\`, \`ssl_cipher\`, \`x509_issuer\`, \`x509_subject\`, \`max_questions\`, \`max_updates\`, \`max_connections\`, \`max_user_connections\`) VALUES ('localhost', '$userAdmin', '*27AEDA0D3A56422C3F1D20DAFF0C8109058134F3', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'N', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', '', '', '', '', 0, 0, 0, 0);" > permisos$userAdmin.sql;
		 else
		echo '' > permisos$userOPAC.sql;
		echo '' > permisos$userINTRA.sql;
		echo '' > permisos$userDevelop.sql;
		echo '' > permisos$userAdmin.sql;
		 fi
IFS=$'\n'
j=0
echo "Procesando el archivo ..... Aguarde";
for i in $(cat $1);
    do
    if [ $j -gt 1 ]; then 
    		  	echo $i |sed 's/"//g' | sed 's/|//g'| awk -F";" '{print "GRANT " $2 " on " $1 " to '$userOPAC@localhost'; " }' >> permisos$userOPAC.sql
    		  	echo $i |sed 's/"//g' | sed 's/|//g'| awk -F";" '{print "GRANT " $3 " on " $1 " to '$userINTRA@localhost'; " }' >> permisos$userINTRA.sql
    		  	echo $i |sed 's/"//g' | sed 's/|//g'| awk -F";" '{print "GRANT " $4 " on " $1 " to '$userDevelop@localhost'; " }' >> permisos$userDevelop.sql
    		  	echo $i |sed 's/"//g' | sed 's/|//g'| awk -F";" '{print "GRANT " $5 " on " $1 " to '$userAdmin@localhost'; " }' >> permisos$userAdmin.sql
		   else
			  let j+=1;
		   fi
    done;
echo "Ahora viene la parte de ejecutar las sentencias mysql. ¿Quiere hacerlo automaticamente (S/N)? ";
read automatico;
echo "Ingrese el nombre de la base de datos";
read basededato;
if [ $automatico = S ] || [ $automatico = s ] ; then 
			echo "Ejecutandose automaticamente ";
			echo "Para agregar permisos de usuario userOpac ejecutar:  mysql $basededato -p < permisos$userOPAC.sql ";
			mysql $basededato -p < permisos$userOPAC.sql;
			echo "Para agregar permisos de usuario $userINTRA ejecutar:  mysql $basededato -p < permisos$userINTRA.sql ";
			mysql $basededato -p < permisos$userINTRA.sql;
			echo "Para agregar permisos de usuario $userDevelop ejecutar:  mysql $basededato -p < permisos$userDevelop.sql ";
			mysql $basededato -p < permisos$userDevelop.sql;
			echo "Para agregar permisos de usuario $userAdmin ejecutar:  mysql $basededato -p < permisos$userAdmin.sql ";
			mysql $basededato -p < permisos$userAdmin.sql;
		       else
			echo "Ahora viene la parte a mano ";
			echo "Para agregar permisos de usuario userOpac ejecutar:  mysql $basededato -p < permisos$userOPAC.sql ";
			echo "Para agregar permisos de usuario $userINTRA ejecutar:  mysql $basededato -p < permisos$userINTRA.sql ";
			echo "Para agregar permisos de usuario $userDevelop ejecutar:  mysql $basededato -p < permisos$userDevelop.sql ";
			echo "Para agregar permisos de usuario $userAdmin ejecutar:  mysql $basededato -p < permisos$userAdmin.sql ";
		       fi;
