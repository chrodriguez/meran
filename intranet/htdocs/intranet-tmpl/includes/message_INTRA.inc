<!-- Aca se definen todos los mensajes de catalogacion -->
[% INCLUDE 'localized_messages.inc' %]

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
ESTA_SEGURO_QUE_DESEA_BORRARLO= "&iquery;[% 'Est\u00e1 seguro que desea borrarlo' | i18n %]?";
HAY_BARCODES_REPETIDOS= "[% 'Hay barcodes repetidos' | i18n %]";
ELIJA_AL_MENOS_UN_EJEMPLAR= "[% 'Elija al menos un ejemplar para realizar la acción' | i18n %]";
FALTA_PARAMETRO_PARA_REFERENCIA= "[% 'Falta par\u00e1metro para referencia' | i18n %]";
CATALOGO_TITLE= "[% 'Advertencia de cat\u00e1logo' | i18n %]";
CATALOGO_ALERT_TITLE= "[% 'Advertencia de cat\u00e1logo' | i18n %]";
//=============================================Fin===Catalogacion=================================================

//================================================Usuarios========================================================
INGRESE_UN_DATO= "[% 'Ingrese un dato' | i18n %]";
NO_SE_SELECCIONO_NINGUN_USUARIO= "[% 'No seleccion\u00f3 ning\u00fan usuario' | i18n %]";
// mensaje compuesto
ESTA_SEGURO= "[% 'Esta seguro' | i18n %]";
TARJETA_NRO= "[% ' -  Tarjeta nro ' | i18n %]";
DATOS_ENVIADOS_INCORRECTOS= "[% 'No se recibieron datos del servidor, posiblemente debido a que se ha enviado informacion incorrecta.' | i18n %]";
// fin mensaje compuesto

SUPER_USER_GRANTED = "[% 'Ha concedido algunos permisos de super usuario, esta seguro que quiere continuar' | i18n %]?";
PERMISSION_GRANTED = "[% 'Ha concedido permisos, esta seguro que quiere continuar' | i18n %]?";

NEW_GRANT = "[% 'ATENCION: DANDO DE ALTA UN NUEVO PERMISO YA QUE EL USUARIO NO CUENTA CON PRIVILEGIOS PARA TAL COMBINACION ' | i18n %]";
// mensaje compuesto
UD_ESTA_A_PUNTO= "[% 'Usted est\u00e1 a punto de' | i18n %]";
A_LOS_PROPIETARIOS= "[% 'a los propietarios de' | i18n %]:";
// fin mensaje compuesto

PERMISOS_DE_ACCESO= "[% 'Permisos de Acceso' | i18n %]";
ELIJA_AL_MENOS_UN_PERMISO= "[% 'Elija al menos un permiso' | i18n %]";
POR_FAVOR_SELECCIONE_LA_CATEGORIA= "[% 'Por favor, seleccione la categor\u00eda' | i18n %]";
POR_FAVOR_INGRESE_SU_APELLIDO= "[% 'Por favor, ingrese su apellido' | i18n %]";
POR_FAVOR_INGRESE_SU_NOMBRE= "[% 'Por favor, ingrese su/s nombre/s' | i18n %]";
POR_FAVOR_INGRESE_LA_TARJETA_DE_IDENTIFICACION= "[% 'Por favor, ingrese la tarjeta de id.' | i18n %]";
POR_FAVOR_INGRESE_EL_SEXO= "[% 'Por favor, ingrese el sexo.' | i18n %]";
POR_FAVOR_INGRESE_LA_CALLE_DONDE_VIVE= "[% 'Por favor, ingrese la calle en donde vive.' | i18n %]";
POR_FAVOR_INGRESE_LA_CIUDAD_EN_DONDE_VIVE= "[% 'Por favor, ingrese La ciudad en donde vive.' | i18n %]";
POR_FAVOR_INGRESE_LA_FECHA_DE_NACIMIENTO= "[% 'Por favor, ingrese la fecha de nacimiento.' | i18n %]";
POR_FAVOR_INGRESE_EL_TELEFONO= "[% 'Por favor, ingrese el tel\u00e9fono.' | i18n %]";
POR_FAVOR_INGRESE_SU_NRO_DE_DNI= "[% 'Por favor, ingrese su nro. de documento' | i18n %]";
POR_FAVOR_INGRESE_SOLO_DIGITOS= "[% 'Por favor, ingrese s\u00f3lo d\u00edgitos' | i18n %]";
LA_LONG_DEL_DNI_DEBE_SER_DE_8_DIGITOS_INGRESO_MAS= "[% 'La longitud del documento debe ser de 8 d\u00edgitos (ha ingresado menos)' | i18n %]";
LA_LONG_DEL_DNI_DEBE_SER_DE_8_DIGITOS_INGRESO_MENOS= "[% 'La longitud del documento debe ser de 8 d\u00edgitos (ha ingresado m\u00e1s)' | i18n %]";
POR_FAVOR_INGRESE_UNA_DIR_DE_EMAIL_VALIDA= "[% 'Por favor, ingrese una direcci\u00f3n de email v\u00e1lida' | i18n %]";
POR_FAVOR_INGRESE_UNA_CONTRASENIA= "[% 'Por favor, ingrese ingrese una contraseña.' | i18n %]";
LAS_CLAVES_SON_DISTINTAS= "[% 'Las claves son distintas.\nIngreselas nuevamente.' | i18n %]";
CAMBIO_DE_CONTRASENIA= "[% 'Cambio de Contrase&ntilde;a' | i18n %]";
PRESTAMO_INTER_BIBLIO= "[% 'Pr\u00e9stamo Interbibliotecario' | i18n %]";
CONFIRMA_LA_BAJA= "[% 'Confirma la baja ?' | i18n %]";
FILTRO_POR= "[% 'filtro: ' | i18n %]";
SOLO_SERA_NUMERICO= "[% 'S\u00f3lo ser\u00e1 num\u00e9rico' | i18n %]";
CONFIRMAR_ELIMINAR_AFILIADO= "[% 'Desea eliminar el autorizado para este usuario?' | i18n %]";
GRANT_PERMISSION_TITLE= "[% 'Advertencia de cesion de Permisos' | i18n %]";
USUARIOS_ALERT_TITLE= "[% 'Advertencia de Usuarios' | i18n %]";
FALTA_INGRESAR_EL_NOMBRE_DEL_AUTORIZADO= "[% 'Falta ingresar el nombre del autorizado' | i18n %]";
FALTA_INGRESAR_EL_DNI_DEL_AUTORIZADO= "[% 'Falta ingresar el DNI del autorizado' | i18n %]";
FALTA_INGRESAR_EL_TELEFONO_DEL_AUTORIZADO= "[% 'Falta ingresar el Tel\u00e9fono del autorizado' | i18n %]";
//================================================Fin==Usuarios==================================================

//================================================Catalogo=======================================================
INGRESE_EL_USUARIO= "[% 'Ingrese el Usuario' | i18n %]";
ERROR_ITSELF= "[% 'Error' | i18n %]";
//================================================Fin==Catalogo==================================================
//================================================Circulacion===================================================
ESTA_SEGURO_QUE_DESEA_CANCELAR_LA_RESERVA= "&iquery;[% 'Esta seguro que desea cancelar la reserva' | i18n %]?";
//=============================================Fin===Circulacion=================================================
//================================================Control Autoridades==============================================
YA_EXISTE_EL_ELEMENTO= "[% 'Ya existe el elemento' | i18n %]";
CONFIRMA_LA_BAJA_DEL_SEUDONIMO= "&iquery;[% 'Confirma la baja del seudonimo' | i18n %]?";
CONFIRMA_LA_BAJA_DEL_SINONIMO= "&iquery;[% 'Confirma la baja del sinonimo' | i18n %]?";
CONTROL_AUTORIDADES_TITLE= "[% 'Advertencia de Control de Autoridades' | i18n %]";
//=============================================Fin===Control Autoridades===========================================

//================================================Visualizacion Opac==============================================
AGREGAR_ENCABEZADO= "[% 'Agregar Encabezado' | i18n %]";
CONFIRMA_LA_BAJA_DEL_ENCABEZADO = "[% 'Confirma la baja del Encabezado?' | i18n %]";
INGRESE_EL_ENCABEZADO = "[% 'Ingrese el encabezado' | i18n %]";
VISUALIZACION_OPAC_TITLE= "[% 'Advertencia de Visualizaci\u00f3n del Opac' | i18n %]";
NO_SE_PUEDE_SUBIR_MAS= "[% 'No se puede subir m\u00e1s' | i18n %]";
SELECCIONE_EL_FILTRO_PARA_CAMPOS= "[% 'Seleccione el filtro para campos' | i18n %]";
SELECCIONE_EL_CAMPO= "[% 'Seleccione el campo' | i18n %]";
SELECCIONE_EL_SUBCAMPO= "[% 'Seleccione el subcampo' | i18n %]";
INGRESE_EL_TEXTO_PREDECESOR= "[% 'Ingrese el texto predecesor' | i18n %]";
INGRESE_EL_TEXTO_SUCESOR= "[% 'Ingrese el texto sucesor' | i18n %]";
INGRESE_EL_SEPERADOR= "[% 'Ingrese el separador' | i18n %]";
//=============================================Fin===Visualizacion Opac===========================================
//================================================Busquedas==============================================
SELECCIONE_AL_MENOS_UN_CAMPO_PARA_BUSCAR= "[% 'Seleccione al menos un campo para buscar' | i18n %]";
//=============================================Fin===Busquedas===========================================

//================================================Reglas Sanciones==============================================
POR_FAVOR_SELECCIONE_TIPO_PRESTAMO= "[% 'Por favor, seleccione un tipo de pr\u00e9stamo' | i18n %]";
POR_FAVOR_SELECCIONE_CATEGORIA_SOCIO= "[% 'Por favor, seleccione una categor\u00eda de socio' | i18n %]"
//=============================================Fin===Reglas Sanciones===========================================

//================================================Sanciones==============================================
ESTA_SEGURO_QUE_DESEA_CANCELAR_LA_SANCION= "&iquery;[% 'Est\u00e1 seguro que desea cancelar la sanci\u00f3n' | i18n %]?";
SANCIONES_TITLE= "[% 'Advertencia de Sanciones' | i18n %]";
//===============================================Fin=Sanciones===========================================

//====================================================Admin==========================================================
DEBE_SELECCIONAR_UNA_OPCION= "[% 'Debe seleccionar al menos una opci\u00f3n' | i18n %]";
DEBE_SELECCIONAR_UNA_TABLA_DE_REFERENCIA= "[% 'Debe seleccionar una tabla de referencia' | i18n %]";
DEBE_SELECCIONAR_UN_VALOR_AUTORIZADO= "[% 'Debe seleccionar un valor autorizado' | i18n %]";

ADMIN_TITLE= "[% 'Advertencia de Administraci\u00f3n' | i18n %]";
//=================================================Fin===Admin=======================================================

</script>
