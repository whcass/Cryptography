#!/usr/bin/perl
use strict;
use warnings;

my $input = pack "H*" ,"1c0111001f010100061a024b53535009181c";
my $key = pack "H*" ,"686974207468652062756c6c277320657965";
my $result = $key^$input;

$result = unpack "H*", $result;
print "[*] - $result";
