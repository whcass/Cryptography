#!/usr/bin/perl
=begin
Detect single-character XOR
One of the 60-character strings in this file has been encrypted by single-character XOR.

Find it.

(Your code from #3 should help.)
=cut
use strict;
use warnings;

my $file = "resources/4.txt";
open my $info, $file, or die "Could not open $file: $!";

my @chars = pack "c*", (32..126);
#print $chars;
my $bestMatch = 0;
my $bestResult = "";
my $key = "";
while(my $line = <$info>){
    my $hex = pack "H*", $line;
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
}
print "[*] Best match found using - $key\n";
print "[*] Produces: $bestResult\n";
print "[*] Matches: $bestMatch\n";