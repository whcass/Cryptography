#!/usr/bin/perl
use strict;
use warnings;

my $input = pack "H*" ,"1c0111001f010100061a024b53535009181c";
my $key = pack "H*" ,"686974207468652062756c6c277320657965";
#my $result = substr($key,0,length($key))^substr($input,0,length($input));
my $result = $key^$input;
$result = unpack "H*", $result;
#for $i (0..length($input)-1){
#	$result += substr()
#

print "[*] - $result";
