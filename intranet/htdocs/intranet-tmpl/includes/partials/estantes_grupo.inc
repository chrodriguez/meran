[% USE HTML %]
<div id="grupo_estantes_[% id2 %]" class="grupo_estantes_[% id2 %]">
    <fieldset>
	<legend class="titulo_legend trigger trigger_4_[% id2 %] click">[% "Estantes virtuales del grupo"| i18n %]:</legend>
    
	<div id="estantes_[% id2 %]" class="estantes_[% id2 %]"></div>
    <script type="text/javascript">
      makeToggle('estantes_[% id2 %]','trigger_4_[% id2 %]',null,true);
      $('#grupo_estantes_[% id2 %]').hide();
    </script>
    </fieldset>	
</div>
