#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use JSON;
use CGI;

C4::Auth::_destruirSession('U400');