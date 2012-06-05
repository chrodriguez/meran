use strict;

use Test::More tests => 42;

use DateTime::Format::MySQL;

my $mysql = 'DateTime::Format::MySQL';

{
    my $dt = $mysql->parse_date( '2003-02-15' );
    is( $dt->year, 2003 );
    is( $dt->month, 2 );
    is( $dt->day, 15 );
}

{
    my $dt = $mysql->parse_datetime( '2003-02-15 10:09:08' );
    is( $dt->year, 2003 );
    is( $dt->month, 2 );
    is( $dt->day, 15 );
    is( $dt->hour, 10 );
    is( $dt->minute, 9 );
    is( $dt->second, 8 );
}

{
    my $dt = $mysql->parse_timestamp( '2003-02-15 10:09:08' );
    is( $dt->year, 2003 );
    is( $dt->month, 2 );
    is( $dt->day, 15 );
    is( $dt->hour, 10 );
    is( $dt->minute, 9 );
    is( $dt->second, 8 );
}

{
    my $dt = $mysql->parse_timestamp('70');
    is( $dt->year, 1970 );
}

{
    my $dt = $mysql->parse_timestamp('69');
    is( $dt->year, 2069 );
}

{
    my $dt = $mysql->parse_timestamp('1202');
    is( $dt->year, 2012 );
    is( $dt->month, 2 );
}

{
    my $dt = $mysql->parse_timestamp('120211');
    is( $dt->year, 2012 );
    is( $dt->month, 2 );
    is( $dt->day_of_month, 11 );
}

{
    my $dt = $mysql->parse_timestamp('20120211');
    is( $dt->year, 2012 );
    is( $dt->month, 2 );
    is( $dt->day_of_month, 11 );
}

{
    my $dt = $mysql->parse_timestamp('1202110545');
    is( $dt->year, 2012 );
    is( $dt->month, 2 );
    is( $dt->day_of_month, 11 );
    is( $dt->hour, 5 );
    is( $dt->minute, 45 );
}

{
    my $dt = $mysql->parse_timestamp('120211054537');
    is( $dt->year, 2012 );
    is( $dt->month, 2 );
    is( $dt->day_of_month, 11 );
    is( $dt->hour, 5 );
    is( $dt->minute, 45 );
    is( $dt->second, 37 );
}

{
    my $dt = $mysql->parse_timestamp('20120211054537');
    is( $dt->year, 2012 );
    is( $dt->month, 2 );
    is( $dt->day_of_month, 11 );
    is( $dt->hour, 5 );
    is( $dt->minute, 45 );
    is( $dt->second, 37 );
}
