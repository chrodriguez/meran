package C4::Breeding;

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
use C4::Biblio;
use MARC::File::USMARC;
require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::Breeding : script to add a biblio in marc_breeding table.

=head1 SYNOPSIS

	use C4::Scan;
	&ImportBreeding($marcrecords,$overwrite_biblio,$filename,$z3950random);

	C<$marcrecord> => the MARC::Record
	C<$overwrite_biblio> => if set to 1 a biblio with the same ISBN will be overwritted.
  								if set to 0 a biblio with the same isbn will be ignored (the previous will be kept)
								if set to -1 the biblio will be added anyway (more than 1 biblio with the same ISBN possible in the breeding
	C<$encoding> => USMARC
						or UNIMARC. used for char_decoding.
						If not present, the parameter marcflavour is used instead
	C<$z3950random> => the random value created during a z3950 search result.

=head1 DESCRIPTION

This module doesn't do anything.

=cut

@ISA = qw(Exporter);
@EXPORT = qw(&ImportBreeding &BreedingSearch);

sub  ImportBreeding {
	my ($marcrecords,$overwrite_biblio,$filename,$encoding,$z3950random) = @_;
	my @marcarray = split /\x1D/, $marcrecords;
	my $dbh = C4::Context->dbh;
	my $searchisbn = $dbh->prepare("select biblioitemnumber from biblioitems where isbn=?");
	my $searchissn = $dbh->prepare("select biblioitemnumber from biblioitems where issn=?");
	my $searchbreeding = $dbh->prepare("select id from marc_breeding
where isbn=? and title=?");
	my $insertsql = $dbh->prepare("insert into marc_breeding (file,isbn,title,author,marc,encoding,z3950random) values(?,?,?,?,?,?,?)");
	my $replacesql = $dbh->prepare("update marc_breeding set file=?,isbn=?,title=?,author=?,marc=?,encoding=?,z3950random=? where id=?");
	$encoding = C4::Context->preference("marcflavour") unless $encoding;
	# fields used for import results
	my $imported=0;
	my $alreadyindb = 0;
	my $alreadyinfarm = 0;
	my $notmarcrecord = 0;
	for (my $i=0;$i<=$#marcarray;$i++) {
		my $marcrecord = MARC::File::USMARC::decode($marcarray[$i]."\x1D");
		my @warnings = $marcrecord->warnings();
		if (scalar($marcrecord->fields()) == 0) {
			$notmarcrecord++;
		} else {
			my $oldbiblio = MARCmarc2koha($dbh,$marcrecord,'');
			$oldbiblio->{title} = char_decode($oldbiblio->{title},$encoding);
			$oldbiblio->{author} = char_decode($oldbiblio->{author},$encoding);
			# if isbn found and biblio does not exist, add it. If isbn found and biblio exists, overwrite or ignore depending on user choice
			# drop every "special" char : spaces, - ...
			$oldbiblio->{isbn} =~ s/ |-|\.//g,
			$oldbiblio->{isbn} = substr($oldbiblio->{isbn},0,10);
			$oldbiblio->{issn} =~ s/ |-|\.//g,
			$oldbiblio->{issn} = substr($oldbiblio->{issn},0,10);
			# search if biblio exists
			my $biblioitemnumber;
			if ($oldbiblio->{isbn}) {
				$searchisbn->execute($oldbiblio->{isbn});
				($biblioitemnumber) = $searchisbn->fetchrow;
			} else {
				$searchissn->execute($oldbiblio->{issn});
				($biblioitemnumber) = $searchissn->fetchrow;
			}
			if ($biblioitemnumber) {
				$alreadyindb++;
			} else {
				# search in breeding farm
				my $breedingid;
				if ($oldbiblio->{isbn}) {
					$searchbreeding->execute($oldbiblio->{isbn},$oldbiblio->{title});
					($breedingid) = $searchbreeding->fetchrow;
				} elsif ($oldbiblio->{issn}){
					$searchbreeding->execute($oldbiblio->{issn},$oldbiblio->{title});
					($breedingid) = $searchbreeding->fetchrow;
				}
				if ($breedingid && $overwrite_biblio eq 0) {
					$alreadyinfarm++;
				} else {
					my $recoded;
					$recoded = $marcrecord->as_usmarc();
					if ($breedingid && $overwrite_biblio eq 1) {
						$replacesql ->execute($filename,substr($oldbiblio->{isbn}.$oldbiblio->{issn},0,10),$oldbiblio->{title},$oldbiblio->{author},$recoded,$encoding,$z3950random,$breedingid);
					} else {
						$insertsql ->execute($filename,substr($oldbiblio->{isbn}.$oldbiblio->{issn},0,10),$oldbiblio->{title},$oldbiblio->{author},$recoded,$encoding,$z3950random);
					}
					$imported++;
				}
			}
		}
	}
	return ($notmarcrecord,$alreadyindb,$alreadyinfarm,$imported);
}


=item BreedingSearch

  ($count, @results) = &BreedingSearch($title,$isbn,$random);
C<$title> contains the title,
C<$isbn> contains isbn or issn,
C<$random> contains the random seed from a z3950 search.

C<$count> is the number of items in C<@results>. C<@results> is an
array of references-to-hash; the keys are the items from the C<marc_breeding> table of the Koha database.

=cut

sub BreedingSearch {
	my ($title,$isbn,$z3950random) = @_;
	my $dbh   = C4::Context->dbh;
	my $count = 0;
	my ($query,@bind);
	my $sth;
	my @results;

	$query = "Select id,file,isbn,title,author from marc_breeding where ";
	if ($z3950random) {
		$query .= "z3950random = ?";
		@bind=($z3950random);
	} else {
	    @bind=();
		if ($title) {
			$query .= "title like ?";
			push(@bind,"$title%");
		}
		if ($title && $isbn) {
			$query .= " and ";
		}
		if ($isbn) {
			$query .= "isbn like ?";
			push(@bind,"$isbn%");
		}
	}
	$sth   = $dbh->prepare($query);
	$sth->execute(@bind);
	while (my $data = $sth->fetchrow_hashref) {
			$results[$count] = $data;
			$count++;
	} # while

	$sth->finish;
	return($count, @results);
} # sub breedingsearch


END { }       # module clean-up code here (global destructor)
