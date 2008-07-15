package C4::Biblio;
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
use C4::Context;
# use C4::Database;
use MARC::Record;
use C4::BookShelves;
use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
#
# don't forget MARCxxx subs are exported only for testing purposes. Should not be used
# as the old-style API and the NEW one are the only public functions.
#
@EXPORT = qw(
	     &itemcount
	     &checkitems &checkitemupdate
	     &addauthor
	     &getitemtypes
	     &getcountrytypes &getsupporttypes &getlanguages  &getlevels 
	     &getbiblioitembybiblionumber

	     &MARCfind_oldbiblionumber_from_MARCbibid
	     &MARCfind_MARCbibid_from_oldbiblionumber
		&MARCfind_marc_from_kohafield
	     &MARCfindsubfield
	     &MARCgettagslib

	     &MARCaddbiblio &MARCadditem
	     &MARCmodsubfield &MARCaddsubfield
	     &MARCmodbiblio &MARCmoditem
	     &MARCkoha2marcBiblio &MARCmarc2koha
		&MARCkoha2marcItem &MARChtml2marc
	     &MARCgetbiblio &MARCgetitem
	     &MARCaddword &MARCdelword
		&char_decode
		&guardarModificacion
		&deletereserves
		&changeAvailability

		&obtenerReferenciaAutor
		&signaturaUtilizada

		&getIndice
		&insertIndice
 );

#
#
# MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC
#
#
# all the following subs takes a MARC::Record as parameter and manage
# the MARC-DB. They are called by the 1.0/1.2 xxx subs, and by the
# NEWxxx subs (xxx deals with old-DB parameters, the NEWxxx deals with MARC-DB parameter)

=head1 NAME

C4::Biblio - acquisition, catalog  management functions

=head1 SYNOPSIS

move from 1.2 to 1.4 version :
1.2 and previous version uses a specific API to manage biblios. This API uses old-DB style parameters.
In the 1.4 version, we want to do 2 differents things :
 - keep populating the old-DB, that has a LOT less datas than MARC
 - populate the MARC-DB
To populate the DBs we have 2 differents sources :
 - the standard acquisition system (through book sellers), that does'nt use MARC data
 - the MARC acquisition system, that uses MARC data.

Thus, we have 2 differents cases :
- with the standard acquisition system, we have non MARC data and want to populate old-DB and MARC-DB, knowing it's an incomplete MARC-record
- with the MARC acquisition system, we have MARC datas, and want to loose nothing in MARC-DB. So, we can't store datas in old-DB, then copy in MARC-DB. we MUST have an API for true MARC data, that populate MARC-DB then old-DB

That's why we need 4 subs :
all I<subs beginning by MARC> manage only MARC tables. They manage MARC-DB with MARC::Record parameters
all I<subs beginning by OLD> manage only OLD-DB tables. They manage old-DB with old-DB parameters
all I<subs beginning by NEW> manage both OLD-DB and MARC tables. They use MARC::Record as parameters. it's the API that MUST be used in MARC acquisition system
all I<subs beginning by seomething else> are the old-style API. They use old-DB as parameter, then call internally the OLD and MARC subs.

- NEW and old-style API should be used in koha to manage biblio
- MARCsubs are divided in 2 parts :
* some of them manage MARC parameters. They are heavily used in koha.
* some of them manage MARC biblio : they are mostly used by NEW and old-style subs.
- OLD are used internally only

all subs requires/use $dbh as 1st parameter.

I<NEWxxx related subs>

all subs requires/use $dbh as 1st parameter.
those subs are used by the MARC-compliant version of koha : marc import, or marc management.

I<OLDxxx related subs>

all subs requires/use $dbh as 1st parameter.
those subs are used by the MARC-compliant version of koha : marc import, or marc management.

They all are the exact copy of 1.0/1.2 version of the sub without the OLD.
The OLDxxx is called by the original xxx sub.
the 1.4 xxx sub also builds MARC::Record an calls the MARCxxx

WARNING : there is 1 difference between initialxxx and OLDxxx :
the db header $dbh is always passed as parameter to avoid over-DB connexion

=head1 DESCRIPTION

=over 4

=item @tagslib = &MARCgettagslib($dbh,1|0);

last param is 1 for liblibrarian and 0 for libopac
returns a hash with tag/subfield meaning
=item ($tagfield,$tagsubfield) = &MARCfind_marc_from_kohafield($dbh,$kohafield);

finds MARC tag and subfield for a given kohafield
kohafield is "table.field" where table= biblio|biblioitems|items, and field a field of the previous table

=item $biblionumber = &MARCfind_oldbiblionumber_from_MARCbibid($dbh,$MARCbibi);

finds a old-db biblio number for a given MARCbibid number

=item $bibid = &MARCfind_MARCbibid_from_oldbiblionumber($dbh,$oldbiblionumber);

finds a MARC bibid from a old-db biblionumber

=item $MARCRecord = &MARCkoha2marcBiblio($dbh,$biblionumber,biblioitemnumber);

MARCkoha2marcBiblio is a wrapper between old-DB and MARC-DB. It returns a MARC::Record builded with old-DB biblio/biblioitem

=item $MARCRecord = &MARCkoha2marcItem($dbh,$biblionumber,itemnumber);

MARCkoha2marcItem is a wrapper between old-DB and MARC-DB. It returns a MARC::Record builded with old-DB item

=item $MARCRecord = &MARCkoha2marcSubtitle($dbh,$biblionumber,$subtitle);

MARCkoha2marcSubtitle is a wrapper between old-DB and MARC-DB. It returns a MARC::Record builded with old-DB subtitle

=item $olddb = &MARCmarc2koha($dbh,$MARCRecord);

builds a hash with old-db datas from a MARC::Record

=item &MARCaddbiblio($dbh,$MARC::Record,$biblionumber);

creates a biblio (in the MARC tables only). $biblionumber is the old-db biblionumber of the biblio

=item &MARCaddsubfield($dbh,$bibid,$tagid,$indicator,$tagorder,$subfieldcode,$subfieldorder,$subfieldvalue);

adds a subfield in a biblio (in the MARC tables only).

=item $MARCRecord = &MARCgetbiblio($dbh,$bibid);

Returns a MARC::Record for the biblio $bibid.

=item &MARCmodbiblio($dbh,$bibid,$record,$delete);

MARCmodbiblio changes a biblio for a biblio,MARC::Record passed as parameter
It 1st delete the biblio, then recreates it.
WARNING : the $delete parameter is not used anymore (too much unsolvable cases).
=item ($subfieldid,$subfieldvalue) = &MARCmodsubfield($dbh,$subfieldid,$subfieldvalue);

MARCmodsubfield changes the value of a given subfield

=item $subfieldid = &MARCfindsubfield($dbh,$bibid,$tag,$subfieldcode,$subfieldorder,$subfieldvalue);

MARCfindsubfield returns a subfield number given a bibid/tag/subfieldvalue values.
Returns -1 if more than 1 answer

=item $subfieldid = &MARCfindsubfieldid($dbh,$bibid,$tag,$tagorder,$subfield,$subfieldorder);

MARCfindsubfieldid find a subfieldid for a bibid/tag/tagorder/subfield/subfieldorder

=item &MARCdelsubfield($dbh,$bibid,$tag,$tagorder,$subfield,$subfieldorder);

MARCdelsubfield delete a subfield for a bibid/tag/tagorder/subfield/subfieldorder

=item &MARCdelbiblio($dbh,$bibid);

MARCdelbiblio delete biblio $bibid

=item &MARCkoha2marcOnefield

used by MARCkoha2marc and should not be useful elsewhere

=item &MARCmarc2kohaOnefield

used by MARCmarc2koha and should not be useful elsewhere

=item MARCaddword

used to manage MARC_word table and should not be useful elsewhere

=item MARCdelword

used to manage MARC_word table and should not be useful elsewhere

=cut

sub MARCgettagslib {
	my ($dbh,$forlibrarian)= @_;
	my $sth;
	my $libfield = ($forlibrarian eq 1)? 'liblibrarian' : 'libopac';
	$sth=$dbh->prepare("select tagfield,$libfield as lib,mandatory,repeatable from marc_tag_structure order by tagfield");
	$sth->execute;
	my ($lib,$tag,$res,$tab,$mandatory,$repeatable);
	while ( ($tag,$lib,$mandatory,$repeatable) = $sth->fetchrow) {
		$res->{$tag}->{lib}=$lib;
		$res->{$tab}->{tab}=""; # XXX
		$res->{$tag}->{mandatory}=$mandatory;
		$res->{$tag}->{repeatable} = $repeatable;
	}

	$sth=$dbh->prepare("select tagfield,tagsubfield,$libfield as lib,tab, mandatory, repeatable,authorised_value,thesaurus_category,value_builder,kohafield from marc_subfield_structure order by tagfield,tagsubfield");
	$sth->execute;

	my $subfield;
	my $authorised_value;
	my $thesaurus_category;
	my $value_builder;
	my $kohafield;
	while ( ($tag, $subfield, $lib, $tab, $mandatory, $repeatable,$authorised_value,$thesaurus_category,$value_builder,$kohafield) = $sth->fetchrow) {

		$res->{$tag}->{$subfield}->{lib}=$lib;
		$res->{$tag}->{$subfield}->{tab}=$tab;
		$res->{$tag}->{$subfield}->{mandatory}=$mandatory;
		$res->{$tag}->{$subfield}->{repeatable}=$repeatable;
		$res->{$tag}->{$subfield}->{authorised_value}=$authorised_value;
		$res->{$tag}->{$subfield}->{thesaurus_category}=$thesaurus_category;
		$res->{$tag}->{$subfield}->{value_builder}=$value_builder;
		$res->{$tag}->{$subfield}->{kohafield}=$kohafield;
	}
	return $res;
}

sub MARCfind_marc_from_kohafield {
    my ($dbh,$kohafield) = @_;
    my $sth=$dbh->prepare("select tagfield,tagsubfield from marc_subfield_structure where kohafield=?");
    $sth->execute($kohafield);
    my ($tagfield,$tagsubfield) = $sth->fetchrow;
    return ($tagfield,$tagsubfield);
}

sub MARCfind_oldbiblionumber_from_MARCbibid {
    my ($dbh,$MARCbibid) = @_;
    my $sth=$dbh->prepare("select biblionumber from marc_biblio where bibid=?");
    $sth->execute($MARCbibid);
    my ($biblionumber) = $sth->fetchrow;
    return $biblionumber;
}

sub MARCfind_MARCbibid_from_oldbiblionumber {
    my ($dbh,$oldbiblionumber) = @_;
    my $sth=$dbh->prepare("select bibid from marc_biblio where biblionumber=?");
    $sth->execute($oldbiblionumber);
    my ($bibid) = $sth->fetchrow;
    return $bibid;
}

=cut
sub MARCupdatebiblio {
# pass the MARC::Record to this function, and it will create the records in the marc tables
my ($dbh,$record,$biblionumber,$bibid) = @_;
my @fields=$record->fields();
my $fieldcount=0;
# now, add subfields...
foreach my $field (@fields) {
    $fieldcount++;
    if ($field->tag() <10) {
	&MARCupdatesubfield($dbh,$bibid,$field->tag(),'',$fieldcount,'',1,$field->data());
		} else {
	my @subfields=$field->subfields();
	foreach my $subfieldcount (0..$#subfields) {
		&MARCupdatesubfield($dbh,$bibid,$field->tag(),$field->indicator(1).$field->indicator(2),$fieldcount,$subfields[$subfieldcount][0],$subfieldcount+1,$subfields[$subfieldcount][1]);
			}
		}
	}
	$dbh->do("unlock tables");
	return $bibid;
}
sub MARCupdatesubfield {
# actualizar un subfield en la bdd
my ($dbh,$bibid,$tagid,$tag_indicator,$tagorder,$subfieldcode,$subfieldorder,$subfieldvalues) = @_;
	# if not value, end of job, we do nothing
	if (length($subfieldvalues) ==0) {return;}
	if (not($subfieldcode)) { $subfieldcode=' ';}
	$subfieldvalues=~s/\n/\|/g;
	my @subfieldvalues = split /\|/,$subfieldvalues;
	foreach my $subfieldvalue (@subfieldvalues) {
		if (length($subfieldvalue)>255) {
		      #ver en MARCaddsubfield si es necesario
			} else {
			my $sth=$dbh->prepare("insert into marc_subfield_table (bibid,tag,tagorder,tag_indicator,subfieldcode,subfieldorder,subfieldvalue) values (?,?,?,?,?,?,?)");
			$sth->execute($bibid,(sprintf "%03s",$tagid),$tagorder,$tag_indicator,$subfieldcode,$subfieldorder,$subfieldvalue);
			if ($sth->errstr) {
			warn "ERROR ==> insert into marc_subfield_table (bibid,tag,tagorder,tag_indicator,subfieldcode,subfieldorder,subfieldvalue) values ($bibid,$tagid,$tagorder,$tag_indicator,$subfieldcode,$subfieldorder,$subfieldvalue)\n";
			}
		}
		&MARCaddword($dbh,$bibid,$tagid,$tagorder,$subfieldcode,$subfieldorder,$subfieldvalue);
	}
}
=cut

sub MARCaddbiblio {
# pass the MARC::Record to this function, and it will create the records in the marc tables
	my ($dbh,$record,$biblionumber,$biblioitemnumber,$bibid) = @_;
	my @fields=$record->fields();
# 	warn "IN MARCaddbiblio $bibid => ".$record->as_formatted;
# my $bibid;
# adding main table, and retrieving bibid
# if bibid is sent, then it's not a true add, it's only a re-add, after a delete (ie, a mod)
# if bibid empty => true add, find a new bibid number
	unless ($bibid) {
		$dbh->do("lock tables marc_biblio WRITE,marc_subfield_table WRITE, marc_word WRITE, marc_blob_subfield WRITE, stopwords READ");
		my $sth=$dbh->prepare("insert into marc_biblio (datecreated,biblionumber,biblioitemnumber) values (now(),?,?)");
		$sth->execute($biblionumber,$biblioitemnumber);
		$sth=$dbh->prepare("select max(bibid) from marc_biblio");
		$sth->execute;
		($bibid)=$sth->fetchrow;
		$sth->finish;
	}
	my $fieldcount=0;
open (L,">>/tmp/lio3");
	# now, add subfields...
	foreach my $field (@fields) {
		$fieldcount++;
		if ($field->tag() <10) {
					printf L "\n1 ".$field->tag();
					printf L "\n".$field->data();
				&MARCaddsubfield($dbh,$bibid,
						$field->tag(),
						'',
						$fieldcount,
						'',
						1,
						$field->data()
						);
		} else {
			my @subfields=$field->subfields();
			foreach my $subfieldcount (0..$#subfields) {
					printf L "\n2 ".$field->tag();
					printf L "\n".$subfields[$subfieldcount][0];
					printf L "\n".$subfields[$subfieldcount][1];
				
				&MARCaddsubfield($dbh,$bibid,
						$field->tag(),
						$field->indicator(1).$field->indicator(2),
						$fieldcount,
						$subfields[$subfieldcount][0],
						$subfieldcount+1,
						$subfields[$subfieldcount][1]
						);
			}
		}
	}
	$dbh->do("unlock tables");
	return $bibid;
}

sub MARCadditem {
# pass the MARC::Record to this function, and it will create the records in the marc tables
    my ($dbh,$record,$biblionumber) = @_;
#    warn "adding : ".$record->as_formatted();
# search for MARC biblionumber
    $dbh->do("lock tables marc_biblio WRITE,marc_subfield_table WRITE, marc_word WRITE, marc_blob_subfield WRITE, stopwords READ");
    my $bibid = &MARCfind_MARCbibid_from_oldbiblionumber($dbh,$biblionumber);
    my @fields=$record->fields();
    my $sth = $dbh->prepare("select max(tagorder) from marc_subfield_table where bibid=?");
    $sth->execute($bibid);
    my ($fieldcount) = $sth->fetchrow;
    # now, add subfields...
    foreach my $field (@fields) {
	my @subfields=$field->subfields();
	$fieldcount++;
	foreach my $subfieldcount (0..$#subfields) {
		    &MARCaddsubfield($dbh,$bibid,
				 $field->tag(),
				 $field->indicator(1).$field->indicator(2),
				 $fieldcount,
				 $subfields[$subfieldcount][0],
				 $subfieldcount+1,
				 $subfields[$subfieldcount][1]
				 );
	}
    }
    $dbh->do("unlock tables");
    return $bibid;
}

sub MARCaddsubfield {
# Add a new subfield to a tag into the DB.
	my ($dbh,$bibid,$tagid,$tag_indicator,$tagorder,$subfieldcode,$subfieldorder,$subfieldvalues) = @_;
	# if not value, end of job, we do nothing
	if (length($subfieldvalues) ==0) {
		return;
	}
	if (not($subfieldcode)) {
		$subfieldcode=' ';
	}
	$subfieldvalues=~s/\n/\|/g;
	my @subfieldvalues = split /\|/,$subfieldvalues;
	foreach my $subfieldvalue (@subfieldvalues) {
		if (length($subfieldvalue)>255) {
			$dbh->do("lock tables marc_blob_subfield WRITE, marc_subfield_table WRITE");
			my $sth=$dbh->prepare("insert into marc_blob_subfield (subfieldvalue) values (?)");
			$sth->execute($subfieldvalue);
			$sth=$dbh->prepare("select max(blobidlink)from marc_blob_subfield");
			$sth->execute;
			my ($res)=$sth->fetchrow;
			$sth=$dbh->prepare("insert into marc_subfield_table (bibid,tag,tagorder,tag_indicator,subfieldcode,subfieldorder,valuebloblink) values (?,?,?,?,?,?,?)");
			$sth->execute($bibid,(sprintf "%03s",$tagid),$tagorder,$tag_indicator,$subfieldcode,$subfieldorder,$res);
			if ($sth->errstr) {
				warn "ERROR ==> insert into marc_subfield_table (bibid,tag,tagorder,tag_indicator,subfieldcode,subfieldorder,subfieldvalue) values ($bibid,$tagid,$tagorder,$tag_indicator,$subfieldcode,$subfieldorder,$subfieldvalue)\n";
			}
		$dbh->do("unlock tables");
		} else {
			my $sth=$dbh->prepare("insert into marc_subfield_table (bibid,tag,tagorder,tag_indicator,subfieldcode,subfieldorder,subfieldvalue) values (?,?,?,?,?,?,?)");
			$sth->execute($bibid,(sprintf "%03s",$tagid),$tagorder,$tag_indicator,$subfieldcode,$subfieldorder,$subfieldvalue);
			if ($sth->errstr) {
			warn "ERROR ==> insert into marc_subfield_table (bibid,tag,tagorder,tag_indicator,subfieldcode,subfieldorder,subfieldvalue) values ($bibid,$tagid,$tagorder,$tag_indicator,$subfieldcode,$subfieldorder,$subfieldvalue)\n";
			}
		}
		&MARCaddword($dbh,$bibid,$tagid,$tagorder,$subfieldcode,$subfieldorder,$subfieldvalue);
	}
}

sub MARCgetbiblio {
# Returns MARC::Record of the biblio passed in parameter.
    my ($dbh,$bibid)=@_;
    my $record = MARC::Record->new();
#---- TODO : the leader is missing
    $record->leader('                        ');
    my $sth=$dbh->prepare("select bibid,subfieldid,tag,tagorder,tag_indicator,subfieldcode,subfieldorder,subfieldvalue,valuebloblink
		 		 from marc_subfield_table
		 		 where bibid=? order by tag,tagorder,subfieldcode");
	my $sth2=$dbh->prepare("select subfieldvalue from marc_blob_subfield where blobidlink=?");
	$sth->execute($bibid);
	my $prevtagorder=1;
	my $prevtag='XXX';
	my $previndicator;
	my $field; # for >=10 tags
	my $prevvalue; # for <10 tags
	while (my $row=$sth->fetchrow_hashref) {
		if ($row->{'valuebloblink'}) { #---- search blob if there is one
			$sth2->execute($row->{'valuebloblink'});
			my $row2=$sth2->fetchrow_hashref;
			$sth2->finish;
			$row->{'subfieldvalue'}=$row2->{'subfieldvalue'};
		}
		if ($row->{tagorder} ne $prevtagorder || $row->{tag} ne $prevtag) {
			$previndicator.="  ";
			if ($prevtag <10) {
 			$record->add_fields((sprintf "%03s",$prevtag),$prevvalue) unless $prevtag eq "XXX"; # ignore the 1st loop
			} else {
				$record->add_fields($field) unless $prevtag eq "XXX";
			}
			undef $field;
			$prevtagorder=$row->{tagorder};
			$prevtag = $row->{tag};
			$previndicator=$row->{tag_indicator};
			if ($row->{tag}<10) {
				$prevvalue = $row->{subfieldvalue};
			} else {
				$field = MARC::Field->new((sprintf "%03s",$prevtag), substr($row->{tag_indicator}.'  ',0,1), substr($row->{tag_indicator}.'  ',1,1), $row->{'subfieldcode'}, $row->{'subfieldvalue'} );
			}
		} else {
			if ($row->{tag} <10) {
 				$record->add_fields((sprintf "%03s",$row->{tag}), $row->{'subfieldvalue'});
 			} else {
				$field->add_subfields($row->{'subfieldcode'}, $row->{'subfieldvalue'} );
 			}
 			$prevtag= $row->{tag};
			$previndicator=$row->{tag_indicator};
		}
	}
	# the last has not been included inside the loop... do it now !
	if ($prevtag ne "XXX") { # check that we have found something. Otherwise, prevtag is still XXX and we
						# must return an empty record, not make MARC::Record fail because we try to
						# create a record with XXX as field :-(
		if ($prevtag <10) {
			$record->add_fields($prevtag,$prevvalue);
		} else {
	#  		my $field = MARC::Field->new( $prevtag, "", "", %subfieldlist);
			$record->add_fields($field);
		}
	}
	return $record;
}
sub MARCgetitem {
# Returns MARC::Record of the biblio passed in parameter.
    my ($dbh,$bibid,$itemnumber)=@_;
    my $record = MARC::Record->new();
# search MARC tagorder
    my $sth2 = $dbh->prepare("select tagorder from marc_subfield_table,marc_subfield_structure where marc_subfield_table.tag=marc_subfield_structure.tagfield and marc_subfield_table.subfieldcode=marc_subfield_structure.tagsubfield and bibid=? and kohafield='items.itemnumber' and subfieldvalue=?");
    $sth2->execute($bibid,$itemnumber);
    my ($tagorder) = $sth2->fetchrow_array();
#---- TODO : the leader is missing
    my $sth=$dbh->prepare("select bibid,subfieldid,tag,tagorder,tag_indicator,subfieldcode,subfieldorder,subfieldvalue,valuebloblink
		 		 from marc_subfield_table
		 		 where bibid=? and tagorder=? order by subfieldcode,subfieldorder
		 	 ");
	$sth2=$dbh->prepare("select subfieldvalue from marc_blob_subfield where blobidlink=?");
	$sth->execute($bibid,$tagorder);
	while (my $row=$sth->fetchrow_hashref) {
	if ($row->{'valuebloblink'}) { #---- search blob if there is one
		$sth2->execute($row->{'valuebloblink'});
		my $row2=$sth2->fetchrow_hashref;
		$sth2->finish;
		$row->{'subfieldvalue'}=$row2->{'subfieldvalue'};
	}
	if ($record->field($row->{'tag'})) {
	    my $field;
#--- this test must stay as this, because of strange behaviour of mySQL/Perl DBI with char var containing a number...
#--- sometimes, eliminates 0 at beginning, sometimes no ;-\\\
	    if (length($row->{'tag'}) <3) {
		$row->{'tag'} = "0".$row->{'tag'};
	    }
	    $field =$record->field($row->{'tag'});
	    if ($field) {
		my $x = $field->add_subfields($row->{'subfieldcode'},$row->{'subfieldvalue'});
		$record->delete_field($field);
		$record->add_fields($field);
	    }
	} else {
	    if (length($row->{'tag'}) < 3) {
		$row->{'tag'} = "0".$row->{'tag'};
	    }
	    my $temp = MARC::Field->new($row->{'tag'}," "," ", $row->{'subfieldcode'} => $row->{'subfieldvalue'});
	    $record->add_fields($temp);
	}

    }
    return $record;
}

sub MARCmodbiblio {
	my ($dbh,$bibid,$record,$delete)=@_;
	my $oldrecord=&MARCgetbiblio($dbh,$bibid);
	open (L,">>/tmp/lio3");
	printf L $oldrecord;
	if ($oldrecord eq $record) {
		return;
	}
# 1st delete the biblio,
# 2nd recreate it
	my ($biblionumber,$biblioitemnumber) = MARCfind_oldbiblionumber_from_MARCbibid($dbh,$bibid);
	printf L $biblionumber;	
#	&MARCupdatebiblio($dbh,$record,$biblionumber,$bibid);
	&MARCdelbiblio($dbh,$bibid,1);
	&MARCaddbiblio($dbh,$record,$biblionumber,$biblioitemnumber,$bibid);
}

sub MARCdelbiblio {
	my ($dbh,$bibid,$keep_items) = @_;
# if the keep_item is set to 1, then all items are preserved.
# This flag is set when the delbiblio is called by modbiblio
# due to a too complex structure of MARC (repeatable fields and subfields),
# the best solution for a modif is to delete / recreate the record.

# 1st of all, copy the MARC::Record to deletedbiblio table => if a true deletion, MARC data will be kept.
# if deletion called before MARCmodbiblio => won't do anything, as the oldbiblionumber doesn't
# exist in deletedbiblio table
	my $record = MARCgetbiblio($dbh,$bibid);
	my $oldbiblionumber = MARCfind_oldbiblionumber_from_MARCbibid($dbh,$bibid);
	my $copy2deleted=$dbh->prepare("update deletedbiblio set marc=? where biblionumber=?");
	$copy2deleted->execute($record->as_usmarc(),$oldbiblionumber);
# now, delete in MARC tables.
	if ($keep_items eq 1) {
	#search item field code
		my $sth = $dbh->prepare("select tagfield,tagsubfield from marc_subfield_structure where kohafield like 'biblio.%' or kohafield like 'additionalauthors.%' or kohafield like 'bibliosubject.%' or kohafield like 'bibliosubtitle.%'");
		$sth->execute;
		while (my $itemtag = $sth->fetchrow_hashref){
		$dbh->do("delete from marc_subfield_table where bibid=$bibid and tag=$itemtag->{'tagfield'} and subfieldcode=$itemtag->{'tagsubfield'}");
		$dbh->do("delete from marc_word where bibid=$bibid and tag=$itemtag->{'tagfield'} and subfieldid=$itemtag->{'tagsubfield'}");
	}
	} else {
		$dbh->do("delete from marc_biblio where bibid=$bibid");
		$dbh->do("delete from marc_subfield_table where bibid=$bibid");
		$dbh->do("delete from marc_word where bibid=$bibid");
	}
}

sub MARCdelitem {
# delete the item passed in parameter in MARC tables.
	my ($dbh,$bibid,$itemnumber)=@_;
	#    my $record = MARC::Record->new();
	# search MARC tagorder
	my $record = MARCgetitem($dbh,$bibid,$itemnumber);
	my $copy2deleted=$dbh->prepare("update deleteditems set marc=? where itemnumber=?");
	$copy2deleted->execute($record->as_usmarc(),$itemnumber);

	my $sth2 = $dbh->prepare("select tagorder from marc_subfield_table,marc_subfield_structure where marc_subfield_table.tag=marc_subfield_structure.tagfield and marc_subfield_table.subfieldcode=marc_subfield_structure.tagsubfield and bibid=? and kohafield='items.itemnumber' and subfieldvalue=?");
	$sth2->execute($bibid,$itemnumber);
	my ($tagorder) = $sth2->fetchrow_array();
	my $sth=$dbh->prepare("delete from marc_subfield_table where bibid=? and tagorder=?");
	$sth->execute($bibid,$tagorder);
}

sub MARCmoditem {
	my ($dbh,$record,$bibid,$itemnumber,$delete,$resposanble)=@_;
	my $oldrecord=&MARCgetitem($dbh,$bibid,$itemnumber);
	# if nothing to change, don't waste time...
	if ($oldrecord eq $record) {
		return;
	}
	# otherwise, skip through each subfield...
	my @fields = $record->fields();
	# search old MARC item
	my $sth2 = $dbh->prepare("select tagorder from marc_subfield_table,marc_subfield_structure where marc_subfield_table.tag=marc_subfield_structure.tagfield and marc_subfield_table.subfieldcode=marc_subfield_structure.tagsubfield and bibid=? and kohafield='items.itemnumber' and subfieldvalue=?");
	$sth2->execute($bibid,$itemnumber);
	my ($tagorder) = $sth2->fetchrow_array();
	foreach my $field (@fields) {
		my $oldfield = $oldrecord->field($field->tag());
		my @subfields=$field->subfields();
		my $subfieldorder=0;
		foreach my $subfield (@subfields) {
			$subfieldorder++;
#			warn "compare : $oldfield".$oldfield->subfield(@$subfield[0]);
			if ($oldfield eq 0 or (length($oldfield->subfield(@$subfield[0])) ==0) ) {
		# just adding datas...
#		warn "addfield : / $subfieldorder / @$subfield[0] - @$subfield[1]";
#				warn "NEW subfield : $bibid,".$field->tag().",".$tagorder.",".@$subfield[0].",".$subfieldorder.",".@$subfield[1].")";
				&MARCaddsubfield($dbh,$bibid,$field->tag(),$field->indicator(1).$field->indicator(2),
						$tagorder,@$subfield[0],$subfieldorder,@$subfield[1]);
			} else {
#		warn "modfield : / $subfieldorder / @$subfield[0] - @$subfield[1]";
		# modify he subfield if it's a different string
				if ($oldfield->subfield(@$subfield[0]) ne @$subfield[1] ) {
					my $subfieldid=&MARCfindsubfieldid($dbh,$bibid,$field->tag(),$tagorder,@$subfield[0],$subfieldorder);
#					warn "changing : $subfieldid, $bibid,".$field->tag(),",$tagorder,@$subfield[0],@$subfield[1],$subfieldorder";
					&MARCmodsubfield($dbh,$subfieldid,@$subfield[1]);
				}
			}
		}
	}
}


sub MARCmodsubfield {
# Subroutine changes a subfield value given a subfieldid.
    my ($dbh, $subfieldid, $subfieldvalue )=@_;
    $dbh->do("lock tables marc_blob_subfield WRITE,marc_subfield_table WRITE");
    my $sth1=$dbh->prepare("select valuebloblink from marc_subfield_table where subfieldid=?");
    $sth1->execute($subfieldid);
    my ($oldvaluebloblink)=$sth1->fetchrow;
    $sth1->finish;
    my $sth;
    # if too long, use a bloblink
    if (length($subfieldvalue)>255 ) {
	# if already a bloblink, update it, otherwise, insert a new one.
	if ($oldvaluebloblink) {
	    $sth=$dbh->prepare("update marc_blob_subfield set subfieldvalue=? where blobidlink=?");
	    $sth->execute($subfieldvalue,$oldvaluebloblink);
	} else {
	    $sth=$dbh->prepare("insert into marc_blob_subfield (subfieldvalue) values (?)");
	    $sth->execute($subfieldvalue);
	    $sth=$dbh->prepare("select max(blobidlink) from marc_blob_subfield");
	    $sth->execute;
	    my ($res)=$sth->fetchrow;
	    $sth=$dbh->prepare("update marc_subfield_table set subfieldvalue=null, valuebloblink=? where subfieldid=?");
	    $sth->execute($res,$subfieldid);
	}
    } else {
	# note this can leave orphan bloblink. Not a big problem, but we should build somewhere a orphan deleting script...
	$sth=$dbh->prepare("update marc_subfield_table set subfieldvalue=?,valuebloblink=null where subfieldid=?");
	$sth->execute($subfieldvalue, $subfieldid);
    }
    $dbh->do("unlock tables");
    $sth->finish;
    $sth=$dbh->prepare("select bibid,tag,tagorder,subfieldcode,subfieldid,subfieldorder from marc_subfield_table where subfieldid=?");
    $sth->execute($subfieldid);
    my ($bibid,$tagid,$tagorder,$subfieldcode,$x,$subfieldorder) = $sth->fetchrow;
    $subfieldid=$x;
    &MARCdelword($dbh,$bibid,$tagid,$tagorder,$subfieldcode,$subfieldorder);
    &MARCaddword($dbh,$bibid,$tagid,$tagorder,$subfieldcode,$subfieldorder,$subfieldvalue);
    return($subfieldid, $subfieldvalue);
}

sub MARCfindsubfield {
    my ($dbh,$bibid,$tag,$subfieldcode,$subfieldorder,$subfieldvalue) = @_;
    my $resultcounter=0;
    my $subfieldid;
    my $lastsubfieldid;
    my $query="select subfieldid from marc_subfield_table where bibid=? and tag=? and subfieldcode=?";
    my @bind_values = ($bibid,$tag, $subfieldcode);
    if ($subfieldvalue) {
	$query .= " and subfieldvalue=?";
	push(@bind_values,$subfieldvalue);
    } else {
	if ($subfieldorder<1) {
	    $subfieldorder=1;
	}
	$query .= " and subfieldorder=?";
	push(@bind_values,$subfieldorder);
    }
    my $sti=$dbh->prepare($query);
    $sti->execute(@bind_values);
    while (($subfieldid) = $sti->fetchrow) {
	$resultcounter++;
	$lastsubfieldid=$subfieldid;
    }
    if ($resultcounter>1) {
	# Error condition.  Values given did not resolve into a unique record.  Don't know what to edit
	# should rarely occur (only if we use subfieldvalue with a value that exists twice, which is strange)
	return -1;
    } else {
	return $lastsubfieldid;
    }
}

sub MARCfindsubfieldid {
	my ($dbh,$bibid,$tag,$tagorder,$subfield,$subfieldorder) = @_;
	my $sth=$dbh->prepare("select subfieldid from marc_subfield_table
				where bibid=? and tag=? and tagorder=?
					and subfieldcode=? and subfieldorder=?");
	$sth->execute($bibid,$tag,$tagorder,$subfield,$subfieldorder);
	my ($res) = $sth->fetchrow;
	unless ($res) {
		$sth=$dbh->prepare("select subfieldid from marc_subfield_table
				where bibid=? and tag=? and tagorder=?
					and subfieldcode=?");
		$sth->execute($bibid,$tag,$tagorder,$subfield);
		($res) = $sth->fetchrow;
	}
    return $res;
}

sub MARCdelsubfield {
# delete a subfield for $bibid / tag / tagorder / subfield / subfieldorder
    my ($dbh,$bibid,$tag,$tagorder,$subfield,$subfieldorder) = @_;
    $dbh->do("delete from marc_subfield_table where bibid='$bibid' and
			tag='$tag' and tagorder='$tagorder'
			and subfieldcode='$subfield' and subfieldorder='$subfieldorder'
			");
}

sub MARCkoha2marcBiblio {
# this function builds partial MARC::Record from the old koha-DB fields
    my ($dbh,$biblionumber,$biblioitemnumber) = @_;
    my $sth=$dbh->prepare("select tagfield,tagsubfield from marc_subfield_structure where kohafield=?");
    my $record = MARC::Record->new();
#--- if bibid, then retrieve old-style koha data
    if ($biblionumber>0) {
	my $sth2=$dbh->prepare("select biblionumber,author,title,unititle,notes,abstract,serial,seriestitle,copyrightdate,timestamp
		from biblio where biblionumber=?");
	$sth2->execute($biblionumber);
	my $row=$sth2->fetchrow_hashref;
	my $autor=C4::Search::getautor($row->{'author'});
	$row->{'author'}=$autor->{'apellido'}.', '.$autor->{'nombre'};

	my $code;
	foreach $code (keys %$row) {
	    if ($row->{$code}) {
		&MARCkoha2marcOnefield($sth,$record,"biblio.".$code,$row->{$code});
	    }
	}
    }
#--- if biblioitem, then retrieve old-style koha data
    if ($biblioitemnumber gt 0) {
	my $sth2=$dbh->prepare(" SELECT biblioitemnumber,biblionumber,volume,number,classification,
						itemtype,url,issn,dewey,subclass,publicationyear,
						volumedate,volumeddesc,timestamp,illus,pages,notes AS bnotes,size,place
					FROM biblioitems
					WHERE biblioitemnumber=?
					");
	$sth2->execute($biblioitemnumber);
	my $row=$sth2->fetchrow_hashref;
	my $code;
	foreach $code (keys %$row) {
	    if ($row->{$code}) {
		&MARCkoha2marcOnefield($sth,$record,"biblioitems.".$code,$row->{$code});
	    }
	}
	my $sth2=$dbh->prepare(" SELECT publisher FROM publisher WHERE biblioitemnumber=?");
	$sth2->execute($biblioitemnumber);
	while (my $row=$sth2->fetchrow_hashref) {
			&MARCkoha2marcOnefield($sth,$record,"publisher.publisher",$row->{'publisher'});
		}
	$sth2=$dbh->prepare(" SELECT isbn FROM isbns WHERE biblioitemnumber=?");
	$sth2->execute($biblioitemnumber);
	while (my $row=$sth2->fetchrow_hashref) {
			&MARCkoha2marcOnefield($sth,$record,"isbns.isbn",$row->{'isbn'});
		}
    }
	# other fields => additional authors, subjects, subtitles
	my $sth2=$dbh->prepare(" SELECT author FROM additionalauthors WHERE biblionumber=?");
	$sth2->execute($biblionumber);
	while (my $row=$sth2->fetchrow_hashref) {
			
			 my $autor=C4::Search::getautor($row->{'author'});
			 $row->{'author'}=$autor->{'apellido'}.', '.$autor->{'nombre'};

			&MARCkoha2marcOnefield($sth,$record,"additionalauthors.author",$row->{'author'});
		}

	###COLABORADORES
	  my $sth2=$dbh->prepare(" SELECT idColaborador,tipo FROM colaboradores  WHERE biblionumber=?");
	          $sth2->execute($biblionumber);
		  while (my $row=$sth2->fetchrow_hashref) {
		  my $autor=C4::Search::getautor($row->{'idColaborador'});
		  $row->{'author'}=$autor->{'apellido'}.', '.$autor->{'nombre'}.' ('.$row->{'tipo'}.')' ;
		  &MARCkoha2marcOnefield($sth,$record,"additionalauthors.author",$row->{'author'});
		  }


	my $sth2=$dbh->prepare(" SELECT subject FROM bibliosubject WHERE biblionumber=?");
	$sth2->execute($biblionumber);
	while (my $row=$sth2->fetchrow_hashref) {
			&MARCkoha2marcOnefield($sth,$record,"bibliosubject.subject",$row->{'subject'});
		}
	my $sth2=$dbh->prepare(" SELECT subtitle FROM bibliosubtitle WHERE biblionumber=?");
	$sth2->execute($biblionumber);
	while (my $row=$sth2->fetchrow_hashref) {
			&MARCkoha2marcOnefield($sth,$record,"bibliosubtitle.subtitle",$row->{'subtitle'});
		}
    return $record;
}

sub MARCkoha2marcItem {
# this function builds partial MARC::Record from the old koha-DB fields
    my ($dbh,$biblionumber,$itemnumber) = @_;
#    my $dbh=&C4Connect;
    my $sth=$dbh->prepare("select tagfield,tagsubfield from marc_subfield_structure where kohafield=?");
    my $record = MARC::Record->new();
#--- if item, then retrieve old-style koha data
    if ($itemnumber>0) {
#	print STDERR "prepare $biblionumber,$itemnumber\n";
	my $sth2=$dbh->prepare("SELECT itemnumber,biblionumber,multivolumepart,biblioitemnumber,barcode,dateaccessioned,
						booksellerid,homebranch,price,replacementprice,replacementpricedate,datelastborrowed,
						datelastseen,multivolume,stack,notforloan,itemlost,wthdrawn,bulk,issues,renewals,
					reserves,restricted,binding,itemnotes,holdingbranch,timestamp
					FROM items
					WHERE itemnumber=?");
	$sth2->execute($itemnumber);
	my $row=$sth2->fetchrow_hashref;
	my $code;
	foreach $code (keys %$row) {
	    if ($row->{$code}) {
		&MARCkoha2marcOnefield($sth,$record,"items.".$code,$row->{$code});
	    }
	}
    }
    return $record;
}

sub MARCkoha2marcSubtitle {
# this function builds partial MARC::Record from the old koha-DB fields
    my ($dbh,$bibnum,$subtitle) = @_;
    my $sth=$dbh->prepare("select tagfield,tagsubfield from marc_subfield_structure where kohafield=?");
    my $record = MARC::Record->new();
    &MARCkoha2marcOnefield($sth,$record,"bibliosubtitle.subtitle",$subtitle);
    return $record;
}

sub MARCkoha2marcOnefield {
    my ($sth,$record,$kohafieldname,$value)=@_;
    my $tagfield;
    my $tagsubfield;
    $sth->execute($kohafieldname);
    if (($tagfield,$tagsubfield)=$sth->fetchrow) {
	if ($record->field($tagfield)) {
	    my $tag =$record->field($tagfield);
	    if ($tag) {
		$tag->add_subfields($tagsubfield,$value);
		$record->delete_field($tag);
		$record->add_fields($tag);
	    }
	} else {
	    $record->add_fields($tagfield," "," ",$tagsubfield => $value);
	}
    }
    return $record;
}

sub MARChtml2marc {
	my ($dbh,$rtags,$rsubfields,$rvalues,%indicators) = @_;
	my $prevtag = -1;
	my $record = MARC::Record->new();
# 	my %subfieldlist=();
	my $prevvalue; # if tag <10
	my $field; # if tag >=10
	for (my $i=0; $i< @$rtags; $i++) {
		# rebuild MARC::Record
		if (@$rtags[$i] ne $prevtag) {
			if ($prevtag < 10) {
				if ($prevvalue) {
					$record->add_fields((sprintf "%03s",$prevtag),$prevvalue);
				}
			} else {
				if ($field) {
					$record->add_fields($field);
				}
			}
			$indicators{@$rtags[$i]}.='  ';
			if (@$rtags[$i] <10) {
				$prevvalue= @$rvalues[$i];
			} else {
				$field = MARC::Field->new( (sprintf "%03s",@$rtags[$i]), substr($indicators{@$rtags[$i]},0,1),substr($indicators{@$rtags[$i]},1,1), @$rsubfields[$i] => @$rvalues[$i]);
			}
			$prevtag = @$rtags[$i];
		} else {
			if (@$rtags[$i] <10) {
				$prevvalue=@$rvalues[$i];
			} else {
				if (@$rvalues[$i]) {
					$field->add_subfields(@$rsubfields[$i] => @$rvalues[$i]);
				}
			}
			
			$prevtag= @$rtags[$i];
		}
	}
	# the last has not been included inside the loop... do it now !
	$record->add_fields($field);
# 	warn $record->as_formatted;
	return $record;
}


sub MARCmarc2koha {
	my ($dbh,$record) = @_;
	my $result;
	my $sth=$dbh->prepare("select tagfield,tagsubfield,kohafield from marc_subfield_structure where kohafield is not NULL");
	$sth->execute();	
	while (my ($tagfield,$subfield,$kohafield) = $sth->fetchrow){
		my $kohatable=(split(/\./,$kohafield))[0];
		$kohafield=(split(/\./,$kohafield))[1];
		foreach my $field ($record->field($tagfield)) {
		if ($field->tag()<10) { #Se manejan los primeros 10 campos
			if ($result->{$kohafield}) {
				$result->{$kohafield} .= " | ".reverse($field->data());
			} else {
				$result->{$kohafield} = $field->data();
			}
		}else {
			if ($field->subfield($subfield)) {
				if ($result->{$kohatable}->{$kohafield}) {
					$result->{$kohatable}->{$kohafield} .= " | ".$field->subfield($subfield);
				} else {
					$result->{$kohatable}->{$kohafield}=$field->subfield($subfield);
				}
			}
		}

		}

	}

# modify copyrightdate to keep only the 1st year found
	my $temp = $result->{'biblio'}->{'copyrightdate'};
	$temp =~ m/c(\d\d\d\d)/; # search cYYYY first
	if ($1>0) {
		$result->{'biblio'}->{'copyrightdate'} = $1;
	} else { # if no cYYYY, get the 1st date.
		$temp =~ m/(\d\d\d\d)/;
		$result->{'biblio'}->{'copyrightdate'} = $1;
	}
# modify publicationyear to keep only the 1st year found
	my $temp = $result->{'biblioitems'}->{'publicationyear'};
	$temp =~ m/c(\d\d\d\d)/; # search cYYYY first
	if ($1>0) {
		$result->{'biblioitems'}->{'publicationyear'} = $1;
	} else { # if no cYYYY, get the 1st date.
		$temp =~ m/(\d\d\d\d)/;
		$result->{'biblioitems'}->{'publicationyear'} = $1;
	}
	return $result;
}

=cut
sub MARCmarc2kohaBACK {
	my ($dbh,$record) = @_;
	my $sth=$dbh->prepare("select tagfield,tagsubfield from marc_subfield_structure where kohafield=?");
	my $result;
	my $sth2=$dbh->prepare("SHOW COLUMNS from biblio");
	$sth2->execute;
	my $field;
	#    print STDERR $record->as_formatted;
	while (($field)=$sth2->fetchrow) {
		$result=&MARCmarc2kohaOneField($sth,"biblio",$field,$record,$result);
	}
	$sth2=$dbh->prepare("SHOW COLUMNS from biblioitems");
	$sth2->execute;
	while (($field)=$sth2->fetchrow) {
		if ($field eq 'notes') { $field = 'bnotes'; }
		$result=&MARCmarc2kohaOneField($sth,"biblioitems",$field,$record,$result);
	}
	$sth2=$dbh->prepare("SHOW COLUMNS from items");
	$sth2->execute;
	while (($field)=$sth2->fetchrow) {
		$result = &MARCmarc2kohaOneField($sth,"items",$field,$record,$result);
	}
	# additional authors : specific
	$result = &MARCmarc2kohaOneField($sth,"bibliosubtitle","subtitle",$record,$result);
	$result = &MARCmarc2kohaOneField($sth,"additionalauthors","additionalauthors",$record,$result);
	$result = &MARCmarc2kohaOneField($sth,"additionalauthors","additionalauthors",$record,$result);
# modify copyrightdate to keep only the 1st year found
	my $temp = $result->{'copyrightdate'};
	$temp =~ m/c(\d\d\d\d)/; # search cYYYY first
	if ($1>0) {
		$result->{'copyrightdate'} = $1;
	} else { # if no cYYYY, get the 1st date.
		$temp =~ m/(\d\d\d\d)/;
		$result->{'copyrightdate'} = $1;
	}
# modify publicationyear to keep only the 1st year found
	my $temp = $result->{'publicationyear'};
	$temp =~ m/c(\d\d\d\d)/; # search cYYYY first
	if ($1>0) {
		$result->{'publicationyear'} = $1;
	} else { # if no cYYYY, get the 1st date.
		$temp =~ m/(\d\d\d\d)/;
		$result->{'publicationyear'} = $1;
	}
	return $result;
}
=cut
sub MARCmarc2kohaOneField {
# FIXME ? if a field has a repeatable subfield that is used in old-db, only the 1st will be retrieved...
	my ($sth,$kohatable,$kohafield,$record,$result)= @_;
#    warn "kohatable / $kohafield / $result / ";
	my $res="";
	my $tagfield;
	my $subfield;
	$sth->execute($kohatable.".".$kohafield);
	($tagfield,$subfield) = $sth->fetchrow;
	foreach my $field ($record->field($tagfield)) {
		if ($field->subfield($subfield)) {
		if ($result->{$kohafield}) {
			$result->{$kohafield} .= " | ".$field->subfield($subfield);
		} else {
			$result->{$kohafield}=$field->subfield($subfield);
		}
		}
	}
	return $result;
}

sub MARCaddword {
# split a subfield string and adds it into the word table.
# removes stopwords
    my ($dbh,$bibid,$tag,$tagorder,$subfieldid,$subfieldorder,$sentence) =@_;
    $sentence =~ s/(\.|\?|\:|\!|\'|,|\-|\"|\(|\)|\[|\]|\{|\})/ /g;
    my @words = split / /,$sentence;
    my $stopwords= C4::Context->stopwords;
    my $sth=$dbh->prepare("insert into marc_word (bibid, tag, tagorder, subfieldid, subfieldorder, word, sndx_word)
			values (?,?,?,?,?,?,soundex(?))");
    foreach my $word (@words) {
# we record only words longer than 2 car and not in stopwords hash
	if (length($word)>2 and !($stopwords->{uc($word)})) {
	    $sth->execute($bibid,$tag,$tagorder,$subfieldid,$subfieldorder,$word,$word);
	    if ($sth->err()) {
		warn "ERROR ==> insert into marc_word (bibid, tag, tagorder, subfieldid, subfieldorder, word, sndx_word) values ($bibid,$tag,$tagorder,$subfieldid,$subfieldorder,$word,soundex($word))\n";
	    }
	}
    }
}

sub MARCdelword {
# delete words. this sub deletes all the words from a sentence. a subfield modif is done by a delete then a add
    my ($dbh,$bibid,$tag,$tagorder,$subfield,$subfieldorder) = @_;
    my $sth=$dbh->prepare("delete from marc_word where bibid=? and tag=? and tagorder=? and subfieldid=? and subfieldorder=?");
    $sth->execute($bibid,$tag,$tagorder,$subfield,$subfieldorder);
}

#
#
# NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW
#
#
# all the following subs are useful to manage MARC-DB with complete MARC records.
# it's used with marcimport, and marc management tools
#





#sub NEWnewitemorig {
#	my ($dbh, $record,$bibid) = @_;
#	# add item in old-DB
#	my $item = &MARCmarc2koha($dbh,$record);
#	# needs old biblionumber and biblioitemnumber
#	$item->{'biblionumber'} = MARCfind_oldbiblionumber_from_MARCbibid($dbh,$bibid);
#	my $sth = $dbh->prepare("select biblioitemnumber from biblioitems where biblionumber=?");
#	$sth->execute($item->{'biblionumber'});
#	($item->{'biblioitemnumber'}) = $sth->fetchrow;
#	my ($itemnumber,$error) = &OLDnewitems($dbh,$item,$item->{barcode});
#	# add itemnumber to MARC::Record before adding the item.
#	my $sth=$dbh->prepare("select tagfield,tagsubfield from marc_subfield_structure where kohafield=?");
#	&MARCkoha2marcOnefield($sth,$record,"items.itemnumber",$itemnumber);
#	# add the item
#	my $bib = &MARCadditem($dbh,$record,$item->{'biblionumber'});
#}




#
#
# OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD
#
#

=item $biblionumber = OLDnewbiblio($dbh,$biblio);

adds a record in biblio table. Datas are in the hash $biblio.

=item $biblionumber = OLDmodbiblio($dbh,$biblio);

modify a record in biblio table. Datas are in the hash $biblio.

=item OLDmodsubtitle($dbh,$bibnum,$subtitle);

modify subtitles in bibliosubtitle table.

=item OLDmodaddauthor($dbh,$bibnum,$author);

adds or modify additional authors
NOTE :  Strange sub : seems to delete MANY and add only ONE author... maybe buggy ?

=item $errors = OLDmodsubject($dbh,$bibnum, $force, @subject);

modify/adds subjects

=item OLDmodbibitem($dbh, $biblioitem);

modify a biblioitem

=item OLDmodnote($dbh,$bibitemnum,$note

modify a note for a biblioitem

=item OLDnewbiblioitem($dbh,$biblioitem);

adds a biblioitem ($biblioitem is a hash with the values)

=item OLDnewsubject($dbh,$bibnum);

adds a subject

=item OLDnewsubtitle($dbh,$bibnum,$subtitle);

create a new subtitle

=item ($itemnumber,$errors)= OLDnewitems($dbh,$item,$barcode);

create a item. $item is a hash and $barcode the barcode.

=item OLDmoditem($dbh,$item);

modify item

=item OLDdelitem($dbh,$itemnum);

delete item

=item OLDdeletebiblioitem($dbh,$biblioitemnumber);

deletes a biblioitem
NOTE : not standard sub name. Should be OLDdelbiblioitem()

=item OLDdelbiblio($dbh,$biblio);

delete a biblio

=cut


=cut
Se agrega este metodo para buscar el codigo que corresponde al autor en la tabla aurores.
=cut
sub obtenerReferenciaAutor{
my ($dbh,$autor) = @_;
$autor =~ s/\n+$//; #elimina los \n
$autor =~ s/\r+$//; #elimina los \r
$autor =~ s/\s+$//; #elimina el espacio del final
$autor =~ s/^\s+//; #elimina el espacio del principio

my $sth = $dbh->prepare("Select id from autores where completo=?");
$sth->execute($autor);
my $data   = $sth->fetchrow_arrayref;
unless($data){ #El autor no existe, entonces lo agrego a la tabla de autores
		my @ars=split(',',$autor); #separa el autor en apellido,nombre
        	foreach my $ar (@ars)  {
			my $aux=$ar;
			$aux =~ s/\n+$//; #elimina los \n
			$aux =~ s/\r+$//; #elimina los \r
			$aux=~ s/\s+$//; #elimina el espacio del final
			$aux=~ s/^\s+//; #elimina el espacio del principio
			$ar=$aux;
			}
		$sth = $dbh->prepare ("insert into autores (nombre,apellido,completo) 
					values (?,?,?);");
            	(($ars[0])||($ars[0]=''));
		(($ars[1])||($ars[1]=''));
	    	$sth->execute($ars[1],$ars[0],$autor);
            	$sth = $dbh->prepare("Select id from autores where completo=?");
	  	$sth->execute($autor);
	  	$data= $sth->fetchrow_arrayref;
	}
$sth->finish;
return $$data[0];
		
}






sub OLDmodaddauthor {
    my ($dbh,$bibnum, $author) = @_;
#    my $dbh   = C4Connect;
    my $sth = $dbh->prepare("Delete from additionalauthors where biblionumber = ?");

    $sth->execute($bibnum);
    $sth->finish;

    if ($author ne '') {
        $sth   = $dbh->prepare("Insert into additionalauthors set author = ?, biblionumber = ?");

        $sth->execute($author,$bibnum);

        $sth->finish;
    } # if
} # sub modaddauthor

#MATIAS

sub addauthor {
    my ($bibnum, $author) = @_;
    my $dbh   = C4::Context->dbh;

    if ($author ne '') {    
#MATIAS Me fijo si no existe ya como autor adicional
	my $sth   = $dbh->prepare("Select count(author) as num from additionalauthors where  author = ? and biblionumber = ?");
        $sth->execute($author,$bibnum);
	my $aux= $sth->fetchrow;
        $sth->finish;

	if ($aux eq 0){
###
	$sth   = $dbh->prepare("Insert into additionalauthors set author = ?, biblionumber = ?");
        $sth->execute($author,$bibnum);
        $sth->finish;
##
	    }
##
    } # if
} # sub addauthor

sub signaturaUtilizada
 {
 my ($bulk,$biblionumber) = @_;
    my $dbh   = C4::Context->dbh;
    my $sth = $dbh->prepare("Select count(*) as cantidad from items  where bulk = ? and biblionumber <> ? and wthdrawn <> 2;"); 
    #No se chequea la singnatura del mismo grupo ni de los ejemplares compartidos
    $sth->execute($bulk,$biblionumber);
 my $aux= $sth->fetchrow;
    $sth->finish;
 return $aux;
} # sub signaturaUtilizada


#MATIAS


sub OLDmodsubject {
	my ($dbh,$bibnum, $force, @subject) = @_;
	#  my $dbh   = C4Connect;
	my $count = @subject;
	my $error;
	for (my $i = 0; $i < $count; $i++) {
		$subject[$i] =~ s/^ //g;
		$subject[$i] =~ s/ $//g;
		my $sth   = $dbh->prepare("select * from catalogueentry where entrytype = 's' and catalogueentry = ?");
		$sth->execute($subject[$i]);

		if (my $data = $sth->fetchrow_hashref) {
		} else {
			if ($force eq $subject[$i] || $force == 1) {
				# subject not in aut, chosen to force anway
				# so insert into cataloguentry so its in auth file
				my $sth2 = $dbh->prepare("Insert into catalogueentry (entrytype,catalogueentry) values ('s',?)");

				$sth2->execute($subject[$i]);
				$sth2->finish;
			} else {
				$error = "$subject[$i]\n no existe como materia";
				my $sth2 = $dbh->prepare("Select * from catalogueentry where entrytype = 's' and (catalogueentry like ? or catalogueentry like ? or catalogueentry like ?)");
				$sth2->execute("$subject[$i] %","% $subject[$i] %","% $subject[$i]");
				while (my $data = $sth2->fetchrow_hashref) {
					$error .= "<br>$data->{'catalogueentry'}";
				} # while
				$sth2->finish;
			} # else
		} # else
		$sth->finish;
	} # else
	if ($error eq '') {
		my $sth   = $dbh->prepare("Delete from bibliosubject where biblionumber = ?");
		$sth->execute($bibnum);
		$sth->finish;
		$sth = $dbh->prepare("Insert into bibliosubject values (?,?)");
		my $query;
		foreach $query (@subject) {
			$sth->execute($query,$bibnum);
		} # foreach
		$sth->finish;
	} # if

	#  $dbh->disconnect;
	return($error);
} # sub modsubject



#Funciones Adicionales para agregar dependencias
#

#Esta funcion es para guardar un log de que persona modifica que parte del biblio
sub guardarModificacion{
	my ($operacion,$responsable,$numero,$tipo)=@_;
        my $dbh= C4::Context->dbh;
	my $sth = $dbh->prepare ("insert into modificaciones (operacion,fecha,responsable,numero,tipo)
                           values (?,NOW(),?,?,?);");
        $sth->execute($operacion,$responsable,$numero,$tipo);
        $sth->finish;
}#Fin PEDRO



sub agregarColaboradores {
	my ($dbh,$bibnro,$additauth) = @_;
	my @ars=split(/^/,$additauth);
	my $sth;
	foreach my $ar (@ars)  {
        	my ($nombre,$funcion)=split('colaborando como:',$ar);
        	my $idCol=obtenerReferenciaAutor($dbh,$nombre);#Esto habria que cambiarlo si no corresponde que la misma tabla de referencia de autores sea la de colaboradores
		
		$funcion =~ s/^\s+//; #Quita los espacios al principio
		$funcion =~ s/\s+$//; #Quita los espacios al final
			
		($funcion ne ''||($funcion='indefinida'));
       		$sth = $dbh->prepare ("insert into colaboradores (biblionumber, idColaborador,tipo) values (?,?,?);");
	    	$sth->execute($bibnro,$idCol,$funcion);
	    	$sth->finish;
				
}}

#hasta aca llegan
# Matias "Edicion de un ejemplar"
sub getAvail
{       
        my ($cod) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT * from unavailable where code = ? ";
        my $sth = $dbh->prepare($query);
        $sth->execute($cod);
        my $res=$sth->fetchrow_hashref;
        $sth->finish();
        return ($res->{'description'});
}       
  
sub changeAvailability{
	my ($item,$wthdrawn,$notforloan,$homebranch) = @_;
	my $dbh= C4::Context->dbh;
	my $wth;
	my $loan;
	if ($notforloan eq 0){$loan="PRESTAMO";}else{$loan="SALA DE LECTURA";}
	if ($wthdrawn eq 0){$wth="Disponible";}else{$wth=(getAvail($wthdrawn));}
        my $sth = $dbh->prepare ("	insert into availability (item,avail,loan,date,branch) 
					values (?,?,?,NOW(),?);");
        $sth->execute($item,$wth,$loan,$homebranch);
        $sth->finish;

	}



#
# old functions
#
#

sub itemcount{
  my ($biblio)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select count(*) from items where biblionumber=?");
  $sth->execute($biblio);
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  return($data->{'count(*)'});
}

=item getorder

  ($order, $ordernumber) = &getorder($biblioitemnumber, $biblionumber);

Looks up the order with the given biblionumber and biblioitemnumber.

Returns a two-element array. C<$ordernumber> is the order number.
C<$order> is a reference-to-hash describing the order; its keys are
fields from the biblio, biblioitems, aqorders, and aqorderbreakdown
tables of the Koha database.

=cut
#'
# FIXME - This is effectively identical to &C4::Catalogue::getorder.
# Pick one and stick with it.
sub getorder{
  my ($bi,$bib)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select ordernumber
 	from aqorders
 	where biblionumber=? and biblioitemnumber=?");
  $sth->execute($bib,$bi);
  # FIXME - Use fetchrow_array(), since we're only interested in the one
  # value.
  my $ordnum=$sth->fetchrow_hashref;
  $sth->finish;
  my $order=getsingleorder($ordnum->{'ordernumber'});
  return ($order,$ordnum->{'ordernumber'});
}

=item getsingleorder

  $order = &getsingleorder($ordernumber);

Looks up an order by order number.

Returns a reference-to-hash describing the order. The keys of
C<$order> are fields from the biblio, biblioitems, aqorders, and
aqorderbreakdown tables of the Koha database.

=cut
#'
# FIXME - This is effectively identical to
# &C4::Catalogue::getsingleorder.
# Pick one and stick with it.
sub getsingleorder {
  my ($ordnum)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select * from biblio,biblioitems,aqorders left join aqorderbreakdown
  on aqorders.ordernumber=aqorderbreakdown.ordernumber
  where aqorders.ordernumber=?
  and biblio.biblionumber=aqorders.biblionumber
  and biblioitems.biblioitemnumber=aqorders.biblioitemnumber");
  $sth->execute($ordnum);
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  return($data);
}

#MATIAS

sub delcolaboradores {
    my ($dbh,$biblio)=@_;
    #   my $dbh   = C4Connect;
        my $sth = $dbh->prepare("Delete from colaboradores where biblionumber = ?");
	$sth->execute($biblio);
	$sth->finish;
    }



sub getitemtypes {
  my $dbh   = C4::Context->dbh;
  my $sth   = $dbh->prepare("select * from itemtypes order by description");
  my $count = 0;
  my @results;

  $sth->execute;
  while (my $data = $sth->fetchrow_hashref) {
    $results[$count] = $data;
    $count++;
  } # while

  $sth->finish;
  return($count, @results);
} # sub getitemtypes

sub getlanguages {
  my $dbh   = C4::Context->dbh;
  my $sth   = $dbh->prepare("select * from languages");
  my %resultslabels;
  $sth->execute;
  while (my $data = $sth->fetchrow_hashref) {
    $resultslabels{$data->{'idLanguage'}}= $data->{'description'};	
  } # while
  $sth->finish;
  return(%resultslabels);
} # sub getlanguages

#Nivel bibliografico
sub getlevels {
  my $dbh   = C4::Context->dbh;
  my $sth   = $dbh->prepare("select * from bibliolevel");
  my %resultslabels;
  $sth->execute;
  while (my $data = $sth->fetchrow_hashref) {
    $resultslabels{$data->{'code'}}= $data->{'description'};
  } # while
  $sth->finish;
  return(%resultslabels);
} # sub getlevels

=cut
sub getbookshelf {
  my $dbh   = C4::Context->dbh;
  my $sth   = $dbh->prepare("select * from bookshelf where parent=0 ");
  my %resultslabels;
  $sth->execute;
  while (my $data = $sth->fetchrow_hashref) {
    $resultslabels{$data->{'shelfnumber'}}= $data->{'shelfname'};
  } # while
  $sth->finish;
  return(%resultslabels);
} # sub getbookshelf

sub getbooksubshelf {
my ($shelf) = @_;
  my $dbh   = C4::Context->dbh;
  my $sth   = $dbh->prepare("select * from bookshelf where parent=? ");
  my %resultslabels;
  $sth->execute($shelf);
  while (my $data = $sth->fetchrow_hashref) {
    $resultslabels{$data->{'shelfnumber'}}= $data->{'shelfname'};
  } # while
  $sth->finish;
  return(%resultslabels);
} # sub getbooksubshelf
=cut



sub getsupporttypes {
  my $dbh   = C4::Context->dbh;
  my $sth   = $dbh->prepare("select * from supports");
  my %resultslabels;
  $sth->execute;
  while (my $data = $sth->fetchrow_hashref) {
    $resultslabels{$data->{'idSupport'}}= $data->{'description'};	
  } # while
  $sth->finish;
  return(%resultslabels);
} # sub getsupporttypes
sub getcountrytypes {
  my $dbh   = C4::Context->dbh;
  my $sth   = $dbh->prepare("select * from countries ");
  my %resultslabels;
  $sth->execute;
  while (my $data = $sth->fetchrow_hashref) {
    $resultslabels{$data->{'iso'}}= $data->{'printable_name'};	
} # while
  $sth->finish;
  return(%resultslabels);
} # sub getcountrytypes





sub getbiblioitembybiblionumber {
    my ($biblionumber) = @_;
    my $dbh   = C4::Context->dbh;
#Matias modifique para que se vea la descripcion del tipo

    my $sth   = $dbh->prepare("SELECT  biblioitems.*,itemtypes.description FROM biblioitems, itemtypes WHERE itemtypes.itemtype = biblioitems.itemtype AND biblionumber = ?");
    my $count = 0;
    my @results;

    $sth->execute($biblionumber);

    while (my $data = $sth->fetchrow_hashref) {
	$data->{'publishercode'}= C4::Search::publisherList($data->{'biblioitemnumber'},$dbh);
	$data->{'isbncode'}= C4::Search::isbnList($data->{'biblioitemnumber'},$dbh);
	my $classi=C4::Search::getLevel($data->{'classification'});
	if ($classi){
    	 $data->{'classification'}= $classi->{'description'};
	 		}

        $results[$count] = $data;
	$count++;
    } # while

    $sth->finish;
    return($count, @results);
} # sub



#------------------------------------------------
#para mostrar el indice del biblioitem
sub getIndice{

	my ($biblioitemnumber, $biblionumber) = @_;
	my $dbh = C4::Context->dbh;
	my $query = " SELECT indice FROM biblioitems ";
	$query .= " WHERE biblioitemnumber =  ?";
	$query .= " AND biblionumber = ? ";
	
    	my $sth=$dbh->prepare($query);
    	$sth->execute($biblioitemnumber, $biblionumber);
    	my $result = $sth->fetchrow_hashref;
    	return ($result);
}

#para mostrar el indice del biblioitem
sub insertIndice{

	my ($biblioitemnumber, $biblionumber, $infoIndice) = @_;
	my $dbh = C4::Context->dbh;
	my $query = " UPDATE biblioitems ";
	$query .= " SET indice = ? ";
	$query .= " WHERE biblioitemnumber =  ?";
	$query .= " AND biblionumber = ? ";
	
    	my $sth=$dbh->prepare($query);
    	$sth->execute($infoIndice, $biblioitemnumber, $biblionumber);
#     	my $result = $sth->fetchrow_hashref;
#     	return ($result);
}


sub char_decode {
	# converts ISO 5426 coded string to ISO 8859-1
	# sloppy code : should be improved in next issue
	my ($string,$encoding) = @_ ;
	$_ = $string ;
# 	$encoding = C4::Context->preference("marcflavour") unless $encoding;
	if ($encoding eq "UNIMARC") {
		s/\xe1/�/gm ;
		s/\xe2/�/gm ;
		s/\xe9/�/gm ;
		s/\xec/�/gm ;
		s/\xf1/�/gm ;
		s/\xf3/�/gm ;
		s/\xf9/�/gm ;
		s/\xfb/�/gm ;
		s/\xc1\x61/�/gm ;
		s/\xc1\x65/�/gm ;
		s/\xc1\x69/�/gm ;
		s/\xc1\x6f/�/gm ;
		s/\xc1\x75/�/gm ;
		s/\xc1\x41/�/gm ;
		s/\xc1\x45/�/gm ;
		s/\xc1\x49/�/gm ;
		s/\xc1\x4f/�/gm ;
		s/\xc1\x55/�/gm ;
		s/\xc2\x41/�/gm ;
		s/\xc2\x45/�/gm ;
		s/\xc2\x49/�/gm ;
		s/\xc2\x4f/�/gm ;
		s/\xc2\x55/�/gm ;
		s/\xc2\x59/�/gm ;
		s/\xc2\x61/�/gm ;
		s/\xc2\x65/�/gm ;
		s/\xc2\x69/�/gm ;
		s/\xc2\x6f/�/gm ;
		s/\xc2\x75/�/gm ;
		s/\xc2\x79/�/gm ;
		s/\xc3\x41/�/gm ;
		s/\xc3\x45/�/gm ;
		s/\xc3\x49/�/gm ;
		s/\xc3\x4f/�/gm ;
		s/\xc3\x55/�/gm ;
		s/\xc3\x61/�/gm ;
		s/\xc3\x65/�/gm ;
		s/\xc3\x69/�/gm ;
		s/\xc3\x6f/�/gm ;
		s/\xc3\x75/�/gm ;
		s/\xc4\x41/�/gm ;
		s/\xc4\x4e/�/gm ;
		s/\xc4\x4f/�/gm ;
		s/\xc4\x61/�/gm ;
		s/\xc4\x6e/�/gm ;
		s/\xc4\x6f/�/gm ;
		s/\xc8\x45/�/gm ;
		s/\xc8\x49/�/gm ;
		s/\xc8\x65/�/gm ;
		s/\xc8\x69/�/gm ;
		s/\xc8\x76/�/gm ;
		s/\xc9\x41/�/gm ;
		s/\xc9\x4f/�/gm ;
		s/\xc9\x55/�/gm ;
		s/\xc9\x61/�/gm ;
		s/\xc9\x6f/�/gm ;
		s/\xc9\x75/�/gm ;
		s/\xca\x41/�/gm ;
		s/\xca\x61/�/gm ;
		s/\xd0\x43/�/gm ;
		s/\xd0\x63/�/gm ;
		# this handles non-sorting blocks (if implementation requires this)
		$string = nsb_clean($_) ;
	} elsif ($encoding eq "USMARC" || $encoding eq "MARC21") {
		if(/[\xc1-\xff]/) {
			s/\xe1\x61/�/gm ;
			s/\xe1\x65/�/gm ;
			s/\xe1\x69/�/gm ;
			s/\xe1\x6f/�/gm ;
			s/\xe1\x75/�/gm ;
			s/\xe1\x41/�/gm ;
			s/\xe1\x45/�/gm ;
			s/\xe1\x49/�/gm ;
			s/\xe1\x4f/�/gm ;
			s/\xe1\x55/�/gm ;
			s/\xe2\x41/�/gm ;
			s/\xe2\x45/�/gm ;
			s/\xe2\x49/�/gm ;
			s/\xe2\x4f/�/gm ;
			s/\xe2\x55/�/gm ;
			s/\xe2\x59/�/gm ;
			s/\xe2\x61/�/gm ;
			s/\xe2\x65/�/gm ;
			s/\xe2\x69/�/gm ;
			s/\xe2\x6f/�/gm ;
			s/\xe2\x75/�/gm ;
			s/\xe2\x79/�/gm ;
			s/\xe3\x41/�/gm ;
			s/\xe3\x45/�/gm ;
			s/\xe3\x49/�/gm ;
			s/\xe3\x4f/�/gm ;
			s/\xe3\x55/�/gm ;
			s/\xe3\x61/�/gm ;
			s/\xe3\x65/�/gm ;
			s/\xe3\x69/�/gm ;
			s/\xe3\x6f/�/gm ;
			s/\xe3\x75/�/gm ;
			s/\xe4\x41/�/gm ;
			s/\xe4\x4e/�/gm ;
			s/\xe4\x4f/�/gm ;
			s/\xe4\x61/�/gm ;
			s/\xe4\x6e/�/gm ;
			s/\xe4\x6f/�/gm ;
			s/\xe8\x45/�/gm ;
			s/\xe8\x49/�/gm ;
			s/\xe8\x65/�/gm ;
			s/\xe8\x69/�/gm ;
			s/\xe8\x76/�/gm ;
			s/\xe9\x41/�/gm ;
			s/\xe9\x4f/�/gm ;
			s/\xe9\x55/�/gm ;
			s/\xe9\x61/�/gm ;
			s/\xe9\x6f/�/gm ;
			s/\xe9\x75/�/gm ;
			s/\xea\x41/�/gm ;
			s/\xea\x61/�/gm ;
			# this handles non-sorting blocks (if implementation requires this)
			$string = nsb_clean($_) ;
		}
	}
	# also remove |
	$string =~ s/\|//g;
	return($string) ;
}

sub nsb_clean {
	my $NSB = '\x88' ;		# NSB : begin Non Sorting Block
	my $NSE = '\x89' ;		# NSE : Non Sorting Block end
	# handles non sorting blocks
	my ($string) = @_ ;
	$_ = $string ;
	s/$NSB/(/gm ;
	s/[ ]{0,1}$NSE/) /gm ;
	$string = $_ ;
	return($string) ;
}
		

END { }       # module clean-up code here (global destructor)


