<!-- Aca se definen todos los mensajes de catalogacion -->

<!--\u00e1 -> á
\u00e9 -> é
\u00ed -> í
\u00f3 -> ó
\u00fa -> ú
\u00c1 -> Á
\u00c9 -> É
\u00cd -> Í
\u00d3 -> Ó
\u00da -> Ú
\u00f1 -> ñ
\u00d1 -> Ñ -->
<!-- FIXME falta acomodar los acentos -->

<script>

//================================================Circulacion=================================================
FALLO_NOTA = "[% 'La nota no se ha podido guardar' | i18n %]";
NOTA_GUARDADA = "[% 'La nota se actualizo correctamente' | i18n %]";

//================================================Catalogacion===================================================
CAMPO_NO_PUEDE_ESTAR_EN_BLANCO= "[% 'El campo no puede estar en blanco' | i18n %]";
ESTE_CAMPO_NO_PUEDE_ESTAR_EN_BLANCO= "[% 'Este campo es requerido, no lo deje en blanco' | i18n %]";
ESTA_SEGURO_QUE_DESEA_BORRARLO= "[% 'Esta seguro que desea borrarlo?' | i18n %]";
HAY_BARCODES_REPETIDOS= "[% 'Hay barcodes repetidos' | i18n %]";
ELIJA_AL_MENOS_UN_EJEMPLAR= "[% 'Elija al menos un ejemplar para realizar la acción' | i18n %]";
FALTA_PARAMETRO_PARA_REFERENCIA= "[% 'Falta parámetro para referencia' | i18n %]";
CATALOGO_TITLE= "[% 'Advertencia de Catalogo' | i18n %]";
//=============================================Fin===Catalogacion=================================================

//================================================Usuarios========================================================
INGRESE_UN_DATO= "[% 'Ingrese un dato' | i18n %]";
NO_SE_SELECCIONO_NINGUN_USUARIO= "[% 'No selecciono ningun usuario ' | i18n %]";
// mensaje compuesto
ESTA_SEGURO= "[% '\n\nEsta seguro?' | i18n %]";
TARJETA_NRO= "[% ' -  Tarjeta nro ' | i18n %]";
DATOS_ENVIADOS_INCORRECTOS= "[% 'No se recibieron datos del servidor, posiblemente debido a que se ha enviado informacion incorrecta.' | i18n %]";
// fin mensaje compuesto

SUPER_USER_GRANTED = "[% 'Ha concedido algunos permisos de super usuario, esta seguro que quiere continuar?' | i18n %]";

NEW_GRANT = "[% 'ATENCION: DANDO DE ALTA UN NUEVO PERMISO YA QUE EL USUARIO NO CUENTA CON PRIVILEGIOS PARA TAL COMBINACION ' | i18n %]";
// mensaje compuesto
UD_ESTA_A_PUNTO= "[% 'Usted esta a punto de ' | i18n %]";
A_LOS_PROPIETARIOS= "[% ' a los propietarios de:\n' | i18n %]";
// fin mensaje compuesto

PERMISOS_DE_ACCESO= "[% 'Permisos de Acceso' | i18n %]";
ELIJA_AL_MENOS_UN_PERMISO= "[% 'Elija al menos un permiso' | i18n %]";
POR_FAVOR_SELECCIONE_LA_CATEGORIA= "[% 'Por favor, seleccione la categoría' | i18n %]";
POR_FAVOR_INGRESE_SU_APELLIDO= "[% 'Por favor, ingrese su apellido' | i18n %]";
POR_FAVOR_INGRESE_SU_NOMBRE= "[% 'Por favor, ingrese su/s nombre/s' | i18n %]";
POR_FAVOR_INGRESE_LA_TARJETA_DE_IDENTIFICACION= "[% 'Por favor, ingrese la tarjeta de id.' | i18n %]";
POR_FAVOR_INGRESE_EL_SEXO= "[% 'Por favor, ingrese el sexo.' | i18n %]";
POR_FAVOR_INGRESE_LA_CALLE_DONDE_VIVE= "[% 'Por favor, ingrese la calle en donde vive.' | i18n %]";
POR_FAVOR_INGRESE_LA_CIUDAD_EN_DONDE_VIVE= "[% 'Por favor, ingrese La ciudad en donde vive.' | i18n %]";
POR_FAVOR_INGRESE_LA_FECHA_DE_NACIMIENTO= "[% 'Por favor, ingrese la fecha de nacimiento.' | i18n %]";
POR_FAVOR_INGRESE_EL_TELEFONO= "[% 'Por favor, ingrese el tel&eacute;fono.' | i18n %]";
POR_FAVOR_INGRESE_SU_NRO_DE_DNI= "[% 'Por favor, ingrese su nro. de documento' | i18n %]";
POR_FAVOR_INGRESE_SOLO_DIGITOS= "[% 'Por favor, ingrese s&oacute;lo d&iacute;gitos' | i18n %]";
LA_LONG_DEL_DNI_DEBE_SER_DE_8_DIGITOS_INGRESO_MAS= "[% 'La longitud del documento debe ser de 8 d&iacute;gitos (ha ingresado menos)' | i18n %]";
LA_LONG_DEL_DNI_DEBE_SER_DE_8_DIGITOS_INGRESO_MENOS= "[% 'La longitud del documento debe ser de 8 d&iacute;gitos (ha ingersado m&aacute;s)' | i18n %]";
POR_FAVOR_INGRESE_UNA_DIR_DE_EMAIL_VALIDA= "[% 'Por favor, ingrese una direcci&oacute;n de email v&aacute;lida' | i18n %]";
POR_FAVOR_INGRESE_UNA_CONTRASENIA= "[% 'Por favor, ingrese ingrese una contraseña.' | i18n %]";
LAS_CLAVES_SON_DISTINTAS= "[% 'Las claves son distintas.\nIngreselas nuevamente.' | i18n %]";
CAMBIO_DE_CONTRASENIA= "[% 'Cambio de Contrase&ntilde;a' | i18n %]";
PRESTAMO_INTER_BIBLIO= "[% 'Prestamo Interbibliotecario' | i18n %]";
CONFIRMA_LA_BAJA= "[% 'Confirma la baja ?' | i18n %]";
FILTRO_POR= "[% 'filtro: ' | i18n %]";
SOLO_SERA_NUMERICO= "[% 'Solo sera numerico' | i18n %]";
CONFIRMAR_ELIMINAR_AFILIADO= "[% 'Desea eliminar el autorizado para este usuario?' | i18n %]";
GRANT_PERMISSION_TITLE= "[% 'Advertencia de cesion de Permisos' | i18n %]";
//================================================Fin==Usuarios==================================================

//================================================Catalogo=======================================================
INGRESE_EL_USUARIO= "[% 'Ingrese el Usuario' | i18n %]";
ERROR_ITSELF= "[% 'Error' | i18n %]";
//================================================Fin==Catalogo==================================================
//================================================Circulacion===================================================
ESTA_SEGURO_QUE_DESEA_CANCELAR_LA_RESERVA= "[% 'Esta seguro que desea cancelar la reserva?' | i18n %]";
//=============================================Fin===Circulacion=================================================
//================================================Control Autoridades==============================================
YA_EXISTE_EL_ELEMENTO= "[% 'Ya existe el elemento' | i18n %]";
CONFIRMA_LA_BAJA_DEL_SEUDONIMO= "[% 'Confirma la baja del seudonimo?' | i18n %]";
CONFIRMA_LA_BAJA_DEL_SINONIMO= "[% 'Confirma la baja del sinonimo?' | i18n %]";
CONTROL_AUTORIDADES_TITLE= "[% 'Advertencia de Control de Autoridades' | i18n %]";
//=============================================Fin===Control Autoridades===========================================

//================================================Visualizacion Opac==============================================
AGREGAR_ENCABEZADO= "[% 'Agregar Encabezado' | i18n %]";
//=============================================Fin===Visualizacion Opac===========================================
//================================================Busquedas==============================================
SELECCIONE_AL_MENOS_UN_CAMPO_PARA_BUSCAR= "[% 'Seleccione al menos un campo para buscar' | i18n %]";
//=============================================Fin===Busquedas===========================================

//================================================Reglas Sanciones==============================================
POR_FAVOR_SELECCIONE_TIPO_PRESTAMO= "[% 'Por favor, seleccione un tipo de préstamo' | i18n %]";
POR_FAVOR_SELECCIONE_CATEGORIA_SOCIO= "[% 'Por favor, seleccione una categoría de socio' | i18n %]"
//=============================================Fin===Reglas Sanciones===========================================

//================================================Sanciones==============================================
ESTA_SEGURO_QUE_DESEA_CANCELAR_LA_SANCION= [% "Esta seguro que desea cancelar la sancion?" | i18n %]
SANCIONES_TITLE= "[% 'Advertencia de Sanciones' | i18n %]";
//===============================================Fin=Sanciones===========================================

</script>
