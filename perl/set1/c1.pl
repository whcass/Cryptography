#!/usr/bin/perl
use strict;
use warnings;
use MIME::Base64;

my $input = "49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d";
my $hex = pack("H*",$input);
my $digest = encode_base64($hex);

print "[*] - $digest";
