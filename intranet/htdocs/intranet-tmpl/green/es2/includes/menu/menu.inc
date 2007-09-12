<script type="text/javascript" language="JavaScript" src="<!-- TMPL_VAR NAME="themelang" -->/includes/menu/DHTMLMenuExpanderV2.js"></script>
<script type="text/javascript" language="JavaScript" src="<!-- TMPL_VAR NAME="themelang" -->/includes/menu/EditMeHsample4.js"></script>
<LINK rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/includes/menu/DMEHorizontal.css">

<DIV id="menuSystem" >
<TABLE   id="mainTable" align="center" border="0" cellspacing="0" cellpadding="2"  width="100%">
	
	<TR>
	
	<TD width="10%">
	<TABLE  width="100%" bgcolor="#f7f6f6">
	<TR>
	<TH><p class="login"><A href="#" onClick="expand();">&nbsp;<img src="<!-- TMPL_VAR NAME='themelang' -->/images/arrow-right.png" width="10" height="10"  border="0">&nbsp; </A></p></TH>
	</TR>
	</TABLE>
	</TD>																			
		<TD width="10%">
			<TABLE  width="100%" bgcolor="#f7f6f6">
				<TR>
		<TH><A href="/cgi-bin/koha/intranet-mainpage.pl" onClick="document.window.frames['koha_main'].src='/cgi-bin/koha/mainpage.pl';">Inicio</A></TH>
				</TR>
			</TABLE>
		</TD>
		<TD width="11%">
			<TABLE width="100%" >
				<TR>
					<TH>Cat&aacute;logo</TH>
				</TR>
				<TR>
					<TD><A href="/cgi-bin/koha/loadmodules.pl?module=search&marc=0&type=intranet">B&uacute;squeda Avanzada</A></TD>
				</TR>
				<TR>
					<TD><A href="/cgi-bin/koha/loadmodules.pl?module=search&marc=1&type=intranet">B&uacute;squeda MARC</A></TD>
				</TR>
				<TR>
					<TD><A href="/cgi-bin/koha/shelves.pl?startfrom=0">Estantes virtuales</A></TD>
				</TR>
				<TR>
					<TD><A href="/cgi-bin/koha/loadmodules.pl?module=addbiblio&type=intranet">Agregar libro</A></TD>
				</TR>
				<TR>
					<TD><A href="/cgi-bin/koha/maint/catmaintain.pl">Mantenimiento</A></TD>
				</TR>
				<TR>
					<TD><A href="/cgi-bin/koha/importacion.pl">Importaci&oacute;n</A></TD>
				</TR>
				<TR>
					<TD><A href="#">Pedidos</A></TD>
				</TR>
			</TABLE>
		</TD>
		<TD width="11%">
			<TABLE width="100%" >
				<TR>
					<TH>Usuarios</TH>
				</TR>
				<TR>
					<TD><A href="/cgi-bin/koha/members-home.pl">Usuarios reales</A></TD>
				</TR>
				<TR>
					<TD><A href="/cgi-bin/koha/members-home2.pl">Usuarios Potenciales</A></TD>
				</TR>
				<TR>
					<TD><A href="/cgi-bin/koha/simpleredirect.pl?type=Agregar&chooseform=adult">Agregar usuario</A></TD>
				</TR>
				<TR>
					<TD><A href="/cgi-bin/koha/simpleredirect.pl?type=Agregar&chooseform=organisation">Agregar organizaci&oacute;n</A></TD>
				</TR>
			</TABLE>
		</TD>
		<TD width="11%">
			<TABLE width="100%" >
				<TR>
					<TH>Adquisici&oacute;n </TH>
				</TR>
				<TR>
					<TD><A href="/cgi-bin/koha/loadmodules.pl?module=acquisitions">Adquisici&oacute;n de ejemplares</A></TD>
				</TR>
				<TR>
					<TD><A href="/cgi-bin/koha/acqui.simple/addbiblio-nomarc.pl">Crear descripci&oacute;n bibliogr&aacute;fica</A></TD>
				</TR>
			</TABLE>
		</TD>
		<TD width="11%">
			<TABLE width="100%" >
				<TR>
					<TH>Circulaci&oacute;n</TH>
				</TR>
				<TR>
					<TD><A href="/cgi-bin/koha/circ/circulation.pl">Pr&eacute;stamos</A></TD>
				</TR>
				<TR>
					<TD><A href="/cgi-bin/koha/circ/returns.pl">Devoluciones</A></TD>
				</TR>
				<TR>
					<TD><A href="/cgi-bin/koha/circ/branchtransfers.pl">Transferencias</A></TD>
				</TR>
			</TABLE>
		</TD>
	
		<TD width="11%">
			<TABLE width="100%" >
				<TR>
					<TH>Par&aacute;metros</TH>
				</TR>
				<TR>
					<TD><A href="/cgi-bin/koha/admin/branches.pl">Unidades de informaci&oacute;n</A></TD>
				</TR>
				<TR>
					<TD><A href="/cgi-bin/koha/admin/aqbookfund.pl">Fondos</A></TD>
				</TR>
				<TR>
					<TD><A href="/cgi-bin/koha/admin/currency.pl">Monedas</A></TD>
				</TR>
				<TR>
					<TD><A href="/cgi-bin/koha/admin/itemtypes.pl">Tipos de documentos</A></TD>
				</TR>
				<TR>
					<TD><A href="/cgi-bin/koha/admin/categorie.pl">Categor&iacute;a de usuarios</A></TD>
				</TR>
				<TR>
					<TD><A href="/cgi-bin/koha/admin/charges.pl">Multas</A></TD>
				</TR>
				<TR>
					<TD><A href="/cgi-bin/koha/admin/authorised_values.pl">Valores autorizados</A></TD>
				</TR>
				<TR>
					<TD><A href="/cgi-bin/koha/admin/thesaurus.pl">Thesaurus</A></TD>
				</TR>
				<TR>
					<TD><A href="/cgi-bin/koha/admin/marctagstructure.pl">Estructura de MARC</A></TD>
				</TR>
					<TR>
					<TD><A href="/cgi-bin/koha/admin/koha2marclinks.pl">Links Koha-MARC</A></TD>
				</TR>
				<TR>
					<TD><A href="/cgi-bin/koha/admin/checkmarc.pl">Chequeo MARC</A></TD>
				</TR>
				<TR>
					<TD><A href="/cgi-bin/koha/admin/printers.pl">Impresoras</A></TD>
				</TR>
				<TR>
					<TD><A href="/cgi-bin/koha/admin/stopwords.pl'">Stop words</A></TD>
				</TR>
				<TR>
					<TD><A href="/cgi-bin/koha/admin/z3950servers.pl">Servidores Z39.50</A></TD>
				</TR>
				<TR>
					<TD><A href="/cgi-bin/koha/admin/systempreferences.pl">Preferencias del sistema</A></TD>
				</TR>
			</TABLE>
		</TD width="11%">
				<TD>
			<TABLE width="100%" >
				<TR>
					<TH>Herramientas</TH>
				</TR>
				<TR>
					<TD><A href="/cgi-bin/koha/export/marc.pl"> Exportaci&oacute;n</A></TD>
				</TR>
				<TR>
					<TD><A href="/cgi-bin/koha/import/breeding.pl">Importaci&oacute;n</A></TD>
				</TR>
			</TABLE>
		</TD>
		<TD width="11%">
			<TABLE width="100%" >
				<TR>
					<TH><A href="/cgi-bin/koha/reports-home.pl">Reportes</A></TH>
				</TR>
			</TABLE>
		</TD>
			<TD width="11%">
			<TABLE width="100%" >
				<TR>
					<TH><A href="/cgi-bin/koha/about.pl">Acerca de</A></TH>
				</TR>
			</TABLE>
		</TD>
	</TR>

</TABLE>
</DIV>
