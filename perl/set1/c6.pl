#!/usr/bin/perl
=begin
Break repeating-key XOR
It is officially on, now.
This challenge isn't conceptually hard, but it involves actual error-prone coding. The other challenges in this set are there to bring you up to speed. This one is there to qualify you. If you can do this one, you're probably just fine up to Set 6.

There's a file here. It's been base64'd after being encrypted with repeating-key XOR.

Decrypt it.

Here's how:

Let KEYSIZE be the guessed length of the key; try values from 2 to (say) 40.
Write a function to compute the edit distance/Hamming distance between two strings. The Hamming distance is just the number of differing bits. The distance between:
this is a test
and
wokka wokka!!!
is 37. Make sure your code agrees before you proceed.
For each KEYSIZE, take the first KEYSIZE worth of bytes, and the second KEYSIZE worth of bytes, and find the edit distance between them. Normalize this result by dividing by KEYSIZE.
The KEYSIZE with the smallest normalized edit distance is probably the key. You could proceed perhaps with the smallest 2-3 KEYSIZE values. Or take 4 KEYSIZE blocks instead of 2 and average the distances.
Now that you probably know the KEYSIZE: break the ciphertext into blocks of KEYSIZE length.
Now transpose the blocks: make a block that is the first byte of every block, and a block that is the second byte of every block, and so on.
Solve each block as if it was single-character XOR. You already have code to do this.
For each block, the single-byte XOR key that produces the best looking histogram is the repeating-key XOR key byte for that block. Put them together and you have the key.
This code is going to turn out to be surprisingly useful later on. Breaking repeating-key XOR ("Vigenere") statistically is obviously an academic exercise, a "Crypto 101" thing. But more people "know how" to break it than can actually break it, and a similar technique breaks something much more important.

=cut
use strict;
use warnings;
use MIME::Base64;
use List::Util qw/ sum /;

my $file = "resources/6.txt";
my $input;
{
    local $/;
    open my $fh, '<', $file or die "can't open $file: $!";
    $input = <$fh>;
    $input = decode_base64($input);
}
# Get the keysize
my $keysizes;
foreach my $keysize (2..40){
    my @dists;
    foreach my $x (1..10){
        foreach my $y (0..10){
            last if $x==$y;
            my $a = substr($input,$x*$keysize,$keysize);
            my $b = substr($input,$y*$keysize,$keysize);
            push @dists, getHammingDistance($a,$b)/$keysize;
        }
    }
    my $averageDistance = sum(@dists)/scalar @dists;
    #print "[*] Dist: $averageDistance\n[*] Keysize: $keysize\n";
    $keysizes->{$keysize} = $averageDistance;
}

my @sizes = sort { $keysizes->{$a} <=> $keysizes->{$b} } keys %$keysizes;
my $keysize = $sizes[0];
print "[*] keysize: $keysize\n";

#my $template = "a$keySize" x (length($input)/$keysize);
#my @chunks = unpack $template, $input;

sub getHammingDistance { 
    my ($a, $b) = @_;
    my $aBits = unpack "B*",$a;
    my $bBits = unpack "B*",$b;
    my $count = 0;
    foreach my $i (0..length($aBits)-1){
        my $aBit = substr($aBits,$i,1);
        my $bBit = substr($bBits,$i,1);
        
        $count++ if $aBit != $bBit;
    }
    return $count;
}