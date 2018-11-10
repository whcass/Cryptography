#!/usr/bin/perl
=begin
Byte-at-a-time ECB decryption (Harder)
Take your oracle function from #12. Now generate a random count of random bytes and prepend this string to every plaintext. You are now doing:

AES-128-ECB(random-prefix || attacker-controlled || target-bytes, random-key)
Same goal: decrypt the target-bytes.

Stop and think for a second.
What's harder than challenge #12 about doing this? How would you overcome that obstacle? The hint is: you're using all the tools you already have; no crazy math is required.

Think "STIMULUS" and "RESPONSE".
=cut
use strict;
use warnings;
use MIME::Base64;
use Crypt::OpenSSL::AES;
use Data::Dumper;
my $key = generate_aes_key();


my $blockSize = 0;
my $diff = 0;
my $lastLength = 0;
for my $i (1..40){
    my $bitInsert = "A" x $i;
    my $cipher = encryption_oracle($bitInsert);
    my $cipherLength = length($cipher);
    if($lastLength == 0){
        $lastLength = $cipherLength;
    }elsif($cipherLength>$lastLength){
        $blockSize = $cipherLength - $lastLength;
        last;
    }
}

print "[*] Block size: $blockSize\n";
my $injectForMode = 'x' x 50;
my $cipher = encryption_oracle($injectForMode);
my $blocks;
for(my $offset = 0; $offset < length($cipher); $offset += 16){
    my $block = substr $cipher, $offset, 16;
    if($blocks->{$block}++){
        print "[*] Using ECB Mode.\n";
        last;
    }
}

my $numOfBlocks = length(encryption_oracle())/$blockSize;
print "[*] Num of Blocks: $numOfBlocks\n";
my @charArray = map(chr,(0..255));
my $bruteForced = "";

for(my $j = 1; $j<=$numOfBlocks;$j++){
    my $paddingLength =(int($blockSize-1));
    my $prefix = 'A' x $paddingLength;
    my $lastBlock = $bruteForced;
    for(my $i = 0; $i<$blockSize;$i++){
        my $trying = $prefix.$lastBlock;

        my $injectResult = substr encryption_oracle($prefix), 0, $blockSize*$j;
        
        my @injectArray;
        my $byte;
        foreach my $char (@charArray){
            push @injectArray, $prefix.$lastBlock.$char;
        }
        
        foreach my $inject (@injectArray){
            my $result = substr encryption_oracle($inject), 0, $blockSize*$j;

            if($result eq $injectResult){
;
                $byte = substr $inject, ($blockSize*$j)-1, 1;

                $lastBlock.=$byte;

                chop $prefix;
                last;
            }
        }
        
    }

    $bruteForced=$lastBlock;
}

print "[*] $bruteForced";

sub encryption_oracle {
    my ($plainText) = @_;
    my $appendCode = "Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24gc28gbXkg
aGFpciBjYW4gYmxvdwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHdhdmluZyBq
dXN0IHRvIHNheSBoaQpEaWQgeW91IHN0b3A/IE5vLCBJIGp1c3QgZHJvdmUg
YnkK";
    
    #my $appendCode = "hello this is a test wokka wokka wokka wokka wokka wokka!!!";
    $appendCode = decode_base64($appendCode);
    $plainText.=$appendCode;
    $plainText = pad_plaintext($plainText);
    my $encrypt = Crypt::OpenSSL::AES->new($key);
    my $cipher;
    $cipher = ecb_encrypt($plainText,$encrypt);
    

    return $cipher;
}

sub pad_plaintext {
    my ($plainText) = @_;
    my $minimum = 5;
    my $maximum = 10;
    my $beforePad = pad("",rand_between(5,10));
    #my $beforePad = "";
    #my $afterPad = pad("",rand_between(5,10));

    $plainText = $beforePad .= $plainText;

    return $plainText;

}

sub generate_aes_key {
    my @set = ('0'..'9','a'..'f');
    my $key = join '' => map $set[rand @set],1..16;
    return $key;
}

sub ecb_encrypt {
    my ($plaintext,$cipher) = @_;
    $plaintext = pad($plaintext, 16);
    my $ciphertext = '';
    for (my $offset = 0; $offset < length($plaintext); $offset += 16) {
        my $block = substr($plaintext, $offset, 16);
        $ciphertext .= $cipher->encrypt($block);
    }
    return $ciphertext;
}

sub pad {
    my ($data, $blocklen) = @_;
    my $mod = $blocklen - (length($data) % $blocklen);
    $mod ||= $blocklen;
    return $data . (chr($mod) x $mod);
}

sub rand_between {
    my ($min, $max) = @_;
    return $min + int(rand($max - $min))+1;
}