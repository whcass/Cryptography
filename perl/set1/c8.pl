#!/usr/bin/perl
=begin
Detect AES in ECB mode
In this file are a bunch of hex-encoded ciphertexts.

One of them has been encrypted with ECB.

Detect it.

Remember that the problem with ECB is that it is stateless and deterministic; the same 16 byte plaintext block will always produce the same 16 byte ciphertext.
=cut

use strict;
use warnings;
my $file = "resources/8.txt";
open my $cipherText, $file, or die "Could not open $file: $!";
my $mostLikelyLine = "";
my $smallestKeys = 9999999999;
while(my $line = <$cipherText>){
    my %seen;
    my @blocks = unpack "(A16)*", $line;
    my $prettyPrint = join ", ", @blocks;
    foreach my $chunk (@blocks){
        next unless $seen{$chunk}++;
    }
    my $count = keys %seen;
    if($count<$smallestKeys){
        $smallestKeys = $count;
        $mostLikelyLine = $line;
    }
}

print "[*] ECB Mode line:\n";
print "[*] $mostLikelyLine\n";