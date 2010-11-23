#!/usr/bin/perl

use strict;
use C4::Auth;

use JSON;
use CGI;

C4::Auth::_destruirSession('U400');