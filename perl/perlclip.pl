#!/usr/bin/perl

use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;
use commandProcessor;

TestClip::CommandProcessor->new->main;
