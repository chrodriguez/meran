<div class="divDatosUsuario" >
    <div class="bordetabla" align="Center"> 
        <b>[% "Datos del usuario:" | i18n %]</b><br>
    </div>

    <div id="divFoto" align="Center"> 
        [% IF foto_name %]
            <img border="1" width="96" height="96"  src="/pictures/[% foto_name %]">

        [% END %]
    </div> 
    <ul class="common-vertical-list">
        <li>
            [% "Tarjeta de la biblioteca:" | i18n %]
                <b>[% socio.getNro_socio %]</b><br>
        </li>
        <li>
            [% "Categor&iacute;a:" | i18n %] 
                <b>[% socio.categoria.getDescription %]</b><br>
        </li>
        <li>
            [% "Apellido:" | i18n %]
                <b> [% socio.persona.getApellido %] </b><br>
        </li>
        <li>
            [% "Nombre:" | i18n %]
                    <b> [% socio.persona.getNombre %] </b><br>
        </li>
        <li>
            [% "Documento:" | i18n %]
                    <b> [% socio.persona.getVersion_documento %]&nbsp; [% socio.persona.getNro_documento %]</b><br>
        </li>
        <li>
            [% "Fecha de nacimiento:" | i18n %]
                    <b> [% socio.persona.getNacimiento %]</b><br>
        </li>
        <li>
            [% "Sexo:" | i18n %]
                    <b> [% socio.persona.getSexo %]</b><br>
        </li>
        <li>
            [% IF socio.persona.getTelefono %]
                <div class="tel">
                    <span class="type">
                        [% "Tel&eacute;fono:" | i18n %]
                    </span>
                    <b>[% socio.persona.getTelefono %]</b>
                </div>  
            [% END %]
        </li>
        <li>
            [% IF socio.persona.getAlt_telefono %]
                <div class="tel">
                    <span class="type">
                        [% "Tel&eacute;fono Alt:" | i18n %]
                    </span>
                    <b>[% socio.persona.getAlt_telefono %]</b><br>
                </div>  
            [% END %]
        </li>
        <li>
            [% IF socio.persona.getEmail %]
                E-mail: <b><a href="mailto:[% socio.persona.getEmail %]">
                                <span class="email"> [% socio.persona.getEmail %]</span>
                            </a>
                        </b>
            [% END %]
        </li>
        <li>
            [% "Legajo" | i18n %]:
                <b> [%  socio.persona.getLegajo %]</b><br>
        </li>
        <li>
            [% "Ciudad" | i18n %]:
                <b> [%  socio.persona.ciudad_ref.getNombre %]</b><br>
        </li>
        <li>
            [% "Calle" | i18n %]:
                <b> [%  socio.persona.getCalle %]</b>
        </li>
<!-- FIXME hacer preferencia para el cambio de password, para permitir o no cambio de pass desde OPAC-->
        <form action=/cgi-bin/koha/change_password.pl method=get id="formCambioPassword">
            <input type=hidden name="token" value="[% token %]" >
        </form>
        [% PERL %]
            print C4::AR::Filtros::to_Button( text    => "[% 'Cambiar Password' | i18n %]",
                                            boton   => "boton_miembros",
                                            width   => "150",
                                            onClick => "cambiarPassword();",
                                            class   => "",
                                            title   => "[% 'Cambiar Password' | i18n %]"
                                        ) ;
        [% END %]

        <li>
            [% IF foto_name %]
                        [% PERL %]
                            print C4::AR::Filtros::to_Button( text    => "[% 'Eliminar Foto' | i18n %]",
                                                            boton   => "boton_miembros",
                                                            width   => "125",
                                                            onClick => "eliminarFoto();",
                                                            class   => "",
                                                            title   => "[% 'Eliminar Foto' | i18n %]"
                                                        ) ;
                        [% END %]
            [% END %]
        </li>
        <li>
            <br><br><br>
            [% IF updatedata %]
                [% "Si alg&uacute;n dato es incorrecto o debe ser modificado, avisar al personal de la Biblioteca." | i18n %]<br>
            [% ELSE %]
                [% "Alguno de nuestros registros es incorrecto? Para solucionarlo:" | i18n %]<br> 

                [% PERL %]
                        print C4::AR::Filtros::link_to( text =>     "[% 'Actualizar Registro' | i18n %]",
                                                        url =>      "/cgi-bin/koha/opac-userupdate.pl", 
                                                    ) ;
                [% END %]
            </br>
            [% END %]
        <li>
    </ul>

    [% IF UploadPictureFromOPAC %]
        [% IF mensaje_error_foto %]
            <div>
                <font color="red">[% mensaje_error_foto %]</font>
            </div>
        [% END %]
        [% IF foto_name %]
        [% ELSE %]
            <form name="foto" method=post enctype="multipart/form-data"  action="/cgi-bin/koha/upload.pl" >
                <input type=file name="filepath" id="filepath">
                <input type=hidden name="nro_socio" value='[% socio.getNro_socio %]'>

                    <a  onMouseOut="swap('up','[% themelang %]/images/upload.png')" 
                        onMouseOver="swap('up','[% themelang %]/images/uploadbis.png')" onClick="document.foto.submit();">
                        <input name="up" id="up" type="image" value="[% 'Subir Foto' | i18n %]"  src="[% themelang %]/images/upload.png" border="0">
                    </a>
            </form>
        [% END %]
    [% END %]
</div>