<div id="div1">
	<p>
	<label for="campoX" style="float:left; width:13%">Seleccion: </label> 
	<!-- TMPL_VAR NAME="selectCampoX" -->
	</p>
</div>
<!-- TMPL_IF EXPR="(accion < 5)" -->
	<div id="id2">
	<!-- TMPL_IF EXPR="(accion > 1)" -->
		<p>
		<label for="campoX" style="float:left; width:13%">Campo: </label>
		<!-- TMPL_VAR NAME="selecttagField" -->
	<!-- /TMPL_IF -->
	<!-- TMPL_IF EXPR="(accion > 2)" -->
		Nombre: <!-- TMPL_VAR NAME="nombretagField" -->
		</p>
	</div>
	<div id="id3">
		<p align="left">
		<label for="tagsubField" style="float:left; width:13%">Subcampo: </label>
		<!-- TMPL_VAR NAME="selecttagsubfield" -->
		<input id="obligatorio" type="hidden" value="<!-- TMPL_VAR NAME='obligatorio' -->">
		Liblibrarian: <input id="lib" type="text" value="<!-- TMPL_VAR NAME = 'lib' -->" size="30"> 
		</p>
		<p>
		<label for="tabla" style="float:left; width:13%">Tabla de refencia: </label>
		<!-- TMPL_VAR NAME = "lista" -->
		Tipo de input: <select name="tipoInput" id="tipoInput">
			<option value="text" <!-- TMPL_IF EXPR="(tipoInput eq 'text')" -->selected <!-- /TMPL_IF -->>Texto</option>
			<option value="texta" <!-- TMPL_IF EXPR="(tipoInput eq 'texta')" -->selected <!-- /TMPL_IF -->>Texto area</option>
			<option value="texa2" <!-- TMPL_IF EXPR="(tipoInput eq 'texa2')" -->selected <!-- /TMPL_IF -->>Texto 1 por linea</option>
			<!--<option value="radio" <!-- TMPL_IF EXPR="(tipoInput eq 'radio')" -->selected <!-- /TMPL_IF -->>Radio button</option>-->
			<option value="combo" <!-- TMPL_IF EXPR="(tipoInput eq 'combo')" -->selected <!-- /TMPL_IF -->>Combo box</option>
		</select>
		</p>
	<!-- /TMPL_IF -->
	</div>
	<!-- TMPL_IF EXPR="(accion > 3) && (tabla != -1)" -->
	<div id="id4" valign="top">
		<label for="orden" style="float:left; width:13%">Orden: </label>
		<!-- TMPL_VAR NAME = "selectOrden" -->
		Campos: <input size="43" id="camposRef" name="camposRef" value="<!-- TMPL_VAR NAME = 'stringCampos' -->">
		separador: <input type="text" id="separador" name="separador">
		</p>
		<p>Ejemplo: <!-- TMPL_VAR NAME = "ejemplo" --></p>
		<p>NOTA: En Campos borras los campos que no desea ingresar y en el separador ingresar un caracter que no sea una letra ni un numero</p>
	</div>
	<!-- /TMPL_IF -->
<!-- /TMPL_IF -->
<input type="hidden" id="ok" value="<!-- TMPL_VAR NAME='ok' -->">