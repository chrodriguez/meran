<div class="side_bar">
	<ul class="nav nav-tabs nav-stacked">
		[% FOREACH elem IN nav_elements %]
			[% IF loop.first %]
	        	<li class="active"><a href="#[% elem.id %]">[% elem.title %]</a></li>
	        [% ELSE %]
	        	<li><a href="#[% elem.id %]">[% elem.title %]</a></li>
	        [% END %]
	    [% END %]
	</ul>
</div>