#!/usr/bin/perl
=begin comment
Single-byte XOR cipher
The hex encoded string:

1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736
... has been XOR'd against a single character. Find the key, decrypt the message.

You can do this by hand. But don't: write code to do it for you.

How? Devise some method for "scoring" a piece of English plaintext. Character frequency is a good metric. Evaluate each output and choose the one with the best score.

Achievement Unlocked
You now have our permission to make "ETAOIN SHRDLU" jokes on Twitter.
=cut
use strict;
use warnings;

my $input = "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736";
my $hex = pack "H*", $input;
my @chars = pack "c*", (32..126);
#print $chars;
my $bestMatch = 0;
my $bestResult = "";
my $key = "";
foreach my $char (split //, $chars[0]){
    my $result = "";

    $result .= $char ^ $_ foreach (split//, $hex);
    $result = unpack "A*", $result;
    my $matches = () = $result =~ /[ETAOIN SHRDLU]/mgi;
    if($matches>$bestMatch){
        $bestMatch = $matches;
        $key = $char;
        $bestResult = $result;
    }
}

print "[*] Best match found using - $key\n";
print "[*] Produces: $bestResult\n";
print "[*] Matches: $bestMatch\n";