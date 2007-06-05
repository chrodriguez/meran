package C4::SearchMarc;

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
require Exporter;
use DBI;
use C4::Context;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.02;

=head1 NAME

C4::Search - Functions for searching the Koha MARC catalog

=head1 SYNOPSIS

  use C4::Search;

  my ($count, @results) = catalogsearch();

=head1 DESCRIPTION

This module provides the searching facilities for the Koha MARC catalog

C<&catalogsearch> is a front end to all the other searches. Depending
on what is passed to it, it calls the appropriate search function.

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(&catalogsearch);
# make all your functions, whether exported or not;

# marcsearch : search in the MARC biblio table.
# everything is choosen by the user : what to search, the conditions...

sub catalogsearch {
	my ($dbh, $tags, $subfields, $and_or, $excluding, $operator, $value, $offset,$length) = @_;
	# build the sql request. She will look like :
	# select m1.bibid
	#		from marc_subfield_table as m1, marc_subfield_table as m2
	#		where m1.bibid=m2.bibid and
	#		(m1.subfieldvalue like "Des%" and m2.subfieldvalue like "27%")

	# "Normal" statements
	my @normal_tags = ();
	my @normal_subfields = ();
	my @normal_and_or = ();
	my @normal_operator = ();
	my @normal_value = ();

	# Extracts the NOT statements from the list of statements
	my @not_tags = ();
	my @not_subfields = ();
	my @not_and_or = ();
	my @not_operator = ();
	my @not_value = ();
	my $any_not = 0;

	for(my $i = 0 ; $i <= $#{$value} ; $i++)
	{
		if(@$excluding[$i])	# NOT statements
		{
			$any_not = 1;
			if(@$operator[$i] eq "contains")
			{
				foreach my $word (split(/ /, @$value[$i]))	# if operator is contains, splits the words in separate requests
				{
					unless (C4::Context->stopwords->{uc($word)}) {	#it's NOT a stopword => use it. Otherwise, ignore
						push @not_tags, @$tags[$i];
						push @not_subfields, @$subfields[$i];
						push @not_and_or, "or"; # as request is negated, finds "foo" or "bar" if final request is NOT "foo" and "bar"
						push @not_operator, @$operator[$i];
						push @not_value, $word;
					}
				}
			}
			else
			{
				push @not_tags, @$tags[$i];
				push @not_subfields, @$subfields[$i];
				push @not_and_or, "or"; # as request is negated, finds "foo" or "bar" if final request is NOT "foo" and "bar"
				push @not_operator, @$operator[$i];
				push @not_value, @$value[$i];
			}
		}
		else	# NORMAL statements
		{
			if(@$operator[$i] eq "contains") # if operator is contains, splits the words in separate requests
			{
				foreach my $word (split(/ /, @$value[$i]))
				{
					unless (C4::Context->stopwords->{uc($word)}) {	#it's NOT a stopword => use it. Otherwise, ignore
						push @normal_tags, @$tags[$i];
						push @normal_subfields, @$subfields[$i];
						push @normal_and_or, "and";	# assumes "foo" and "bar" if "foo bar" is entered
						push @normal_operator, @$operator[$i];
						push @normal_value, $word;
					}
				}
			}
			else
			{
				push @normal_tags, @$tags[$i];
				push @normal_subfields, @$subfields[$i];
				push @normal_and_or, @$and_or[$i];
				push @normal_operator, @$operator[$i];
				push @normal_value, @$value[$i];
			}
		}
	}

	# Finds the basic results without the NOT requests
	my ($sql_tables, $sql_where1, $sql_where2) = create_request(\@normal_tags, \@normal_subfields, \@normal_and_or, \@normal_operator, \@normal_value);

	my $sth;
#	warn "HERE (NORMAL)";
	if ($sql_where2) {
		$sth = $dbh->prepare("select distinct m1.bibid from $sql_tables where $sql_where2 and ($sql_where1)");
#		warn("-->select m1.bibid from $sql_tables where $sql_where2 and ($sql_where1)");
	} else {
		$sth = $dbh->prepare("select distinct m1.bibid from $sql_tables where $sql_where1");
#		warn("==>select m1.bibid from $sql_tables where $sql_where1");
	}

	$sth->execute();
	my @result = ();

	# Processes the NOT if any and there are results
	my ($not_sql_tables, $not_sql_where1, $not_sql_where2);

	if( ($sth->rows) && $any_not )	# some results to tune up and some NOT statements
	{
		($not_sql_tables, $not_sql_where1, $not_sql_where2) = create_request(\@not_tags, \@not_subfields, \@not_and_or, \@not_operator, \@not_value);

		my @tmpresult;

		while (my ($bibid) = $sth->fetchrow) {
			push @tmpresult,$bibid;
		}
		my $sth_not;
#		warn "HERE (NOT)";
		if ($not_sql_where2) {
			$sth_not = $dbh->prepare("select distinct m1.bibid from $not_sql_tables where $not_sql_where2 and ($not_sql_where1)");
#			warn("-->select m1.bibid from $not_sql_tables where $not_sql_where2 and ($not_sql_where1)");
		} else {
			$sth_not = $dbh->prepare("select distinct m1.bibid from $not_sql_tables where $not_sql_where1");
#			warn("==>select m1.bibid from $not_sql_tables where $not_sql_where1");
		}

		$sth_not->execute();

		if($sth_not->rows)
		{
			my %not_bibids = ();
			while(my $bibid = $sth_not->fetchrow()) {
				$not_bibids{$bibid} = 1;	# populates the hashtable with the bibids matching the NOT statement
			}

			foreach my $bibid (@tmpresult)
			{
				if(!$not_bibids{$bibid})
				{
					push @result, $bibid;
				}
			}
		}
		$sth_not->finish();
	}
	else	# no NOT statements
	{
		while (my ($bibid) = $sth->fetchrow) {
			push @result,$bibid;
		}
	}

	# we have bibid list. Now, loads title and author from [offset] to [offset]+[length]
	my $counter = $offset;
	$sth = $dbh->prepare("select author,title from biblio,marc_biblio where biblio.biblionumber=marc_biblio.biblionumber and bibid=?");
	my @finalresult = ();
	while (($counter <= $#result) && ($counter <= ($offset + $length))) {
		$sth->execute($result[$counter]);
		my ($author,$title) = $sth->fetchrow;
		my %line;
		$line{bibid}=$result[$counter];
		$line{author}=$author;
		$line{title}=$title;
		push @finalresult, \%line;
		$counter++;
	}

	my $nbresults = $#result + 1;
	return (\@finalresult, $nbresults);
}

# Creates the SQL Request

sub create_request {
	my ($tags, $subfields, $and_or, $operator, $value) = @_;

	my $sql_tables; # will contain marc_subfield_table as m1,...
	my $sql_where1; # will contain the "true" where
	my $sql_where2 = "("; # will contain m1.bibid=m2.bibid
	my $nb_active=0; # will contain the number of "active" entries. and entry is active is a value is provided.
	my $nb_table=1; # will contain the number of table. ++ on each entry EXCEPT when an OR  is provided.

	for(my $i=0; $i<=@$value;$i++) {
		if (@$value[$i]) {
			$nb_active++;
			if ($nb_active==1) {
				if (@$operator[$i] eq "start") {
					$sql_tables .= "marc_subfield_table as m$nb_table,";
					$sql_where1 .= "(m1.subfieldvalue like '@$value[$i]%'";
					if (@$tags[$i]) {
						$sql_where1 .=" and m1.tag=@$tags[$i] and m1.subfieldcode='@$subfields[$i]'";
					}
					$sql_where1.=")";
				} elsif (@$operator[$i] eq "contains") {
					$sql_tables .= "marc_word as m$nb_table,";
					$sql_where1 .= "(m1.word  like '@$value[$i]%'";
					if (@$tags[$i]) {
						 $sql_where1 .=" and m1.tag=@$tags[$i] and m1.subfieldid='@$subfields[$i]'";
					}
					$sql_where1.=")";
				} else {
					$sql_tables .= "marc_subfield_table as m$nb_table,";
					$sql_where1 .= "(m1.subfieldvalue @$operator[$i] '@$value[$i]' ";
					if (@$tags[$i]) {
						 $sql_where1 .=" and m1.tag=@$tags[$i] and m1.subfieldcode='@$subfields[$i]'";
					}
					$sql_where1.=")";
				}
			} else {
				if (@$operator[$i] eq "start") {
					$nb_table++;
					$sql_tables .= "marc_subfield_table as m$nb_table,";
					$sql_where1 .= "@$and_or[$i] (m$nb_table.subfieldvalue like '@$value[$i]%'";
					if (@$tags[$i]) {
					 	$sql_where1 .=" and m$nb_table.tag=@$tags[$i] and m$nb_table.subfieldcode='@$subfields[$i]'";
					}
					$sql_where1.=")";
					$sql_where2 .= "m1.bibid=m$nb_table.bibid and ";
				} elsif (@$operator[$i] eq "contains") {
					if (@$and_or[$i] eq 'and') {
						$nb_table++;
						$sql_tables .= "marc_word as m$nb_table,";
						$sql_where1 .= "@$and_or[$i] (m$nb_table.word like '@$value[$i]%'";
						if (@$tags[$i]) {
							$sql_where1 .=" and m$nb_table.tag=@$tags[$i] and m$nb_table.subfieldid='@$subfields[$i]'";
						}
						$sql_where1.=")";
						$sql_where2 .= "m1.bibid=m$nb_table.bibid and ";
					} else {
						$sql_where1 .= "@$and_or[$i] (m$nb_table.word like '@$value[$i]%'";
						if (@$tags[$i]) {
							$sql_where1 .="  and m$nb_table.tag=@$tags[$i] and m$nb_table.subfieldid='@$subfields[$i]'";
						}
						$sql_where1.=")";
						$sql_where2 .= "m1.bibid=m$nb_table.bibid and ";
					}
				} else {
					$nb_table++;
					$sql_tables .= "marc_subfield_table as m$nb_table,";
					$sql_where1 .= "@$and_or[$i] (m$nb_table.subfieldvalue @$operator[$i] '@$value[$i]'";
					if (@$tags[$i]) {
					 	$sql_where1 .="  and m$nb_table.tag=@$tags[$i] and m$nb_table.subfieldcode='@$subfields[$i]'";
					}
					$sql_where2 .= "m1.bibid=m$nb_table.bibid and ";
					$sql_where1.=")";
				}
			}
		}
	}

	if($sql_where2 ne "(")	# some datas added to sql_where2, processing
	{
		$sql_where2 = substr($sql_where2, 0, (length($sql_where2)-5)); # deletes the trailing ' and '
		$sql_where2 .= ")";
	}
	else	# no sql_where2 statement, deleting '('
	{
		$sql_where2 = "";
	}
	chop $sql_tables;	# deletes the trailing ','
	return ($sql_tables, $sql_where1, $sql_where2);
}


END { }       # module clean-up code here (global destructor)

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
