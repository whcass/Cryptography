#!/usr/bin/perl
=begin
Byte-at-a-time ECB decryption (Simple)
Copy your oracle function to a new function that encrypts buffers under ECB mode using a consistent but unknown key (for instance, assign a single random key, once, to a global variable).

Now take that same function and have it append to the plaintext, BEFORE ENCRYPTING, the following string:

Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24gc28gbXkg
aGFpciBjYW4gYmxvdwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHdhdmluZyBq
dXN0IHRvIHNheSBoaQpEaWQgeW91IHN0b3A/IE5vLCBJIGp1c3QgZHJvdmUg
YnkK
Spoiler alert.
Do not decode this string now. Don't do it.

Base64 decode the string before appending it. Do not base64 decode the string by hand; make your code do it. The point is that you don't know its contents.

What you have now is a function that produces:

AES-128-ECB(your-string || unknown-string, random-key)
It turns out: you can decrypt "unknown-string" with repeated calls to the oracle function!

Here's roughly how:

Feed identical bytes of your-string to the function 1 at a time --- start with 1 byte ("A"), then "AA", then "AAA" and so on. Discover the block size of the cipher. You know it, but do this step anyway.
Detect that the function is using ECB. You already know, but do this step anyways.
Knowing the block size, craft an input block that is exactly 1 byte short (for instance, if the block size is 8 bytes, make "AAAAAAA"). Think about what the oracle function is going to put in that last byte position.
Make a dictionary of every possible last byte by feeding different strings to the oracle; for instance, "AAAAAAAA", "AAAAAAAB", "AAAAAAAC", remembering the first block of each invocation.
Match the output of the one-byte-short input to one of the entries in your dictionary. You've now discovered the first byte of unknown-string.
Repeat for the next byte.
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
    my $inputText = $bitInsert;
    my $cipher = encryption_oracle($inputText);
    my $cipherLength = length($cipher);
    if($lastLength > $cipherLength){
        $blockSize = $lastLength-$cipherLength;
        last;
    }else{
        $lastLength = $cipherLength;
    }
}

print "[*] Block size: $blockSize\n";
my $inject = 'x' x 50;
my $cipher = encryption_oracle($inject);
my $blocks;
for(my $offset = 0; $offset < length($cipher); $offset += 16){
    my $block = substr $cipher, $offset, 16;
    if($blocks->{$block}++){
        print "[*] Using ECB Mode.\n";
        last;
    }
}

my @charArray = map(chr,(32..126));
#my @charArray = ("a".."z");
my $firstBlock;
my $bytes = "";
for(my $i = 1; $i<=$blockSize;$i++){
    my $injectPad = 'A' x int($blockSize-$i);
    $injectPad .= $bytes;
    
    my $injectResult = substr encryption_oracle($injectPad), 0, $blockSize;
    
    my @injectArray;
    my $byte;
    foreach my $char (@charArray){
        push @injectArray, $injectPad.$char;
    }
    
    foreach my $inject (@injectArray){
        my $result = substr encryption_oracle($inject), 0, $blockSize;
        #print "[i] $inject\n";
        #print "[r] $result\n";
        if($result eq $injectResult){
            #print "[*] found: $inject\n";
            $byte = substr $inject, $blockSize-1, 1;
            $bytes.=$byte;
            last;
        }
    }
    
}



print "[*] $bytes";

sub encryption_oracle {
    my ($plainText) = @_;
#     my $appendCode = "Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24gc28gbXkg
# aGFpciBjYW4gYmxvdwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHdhdmluZyBq
# dXN0IHRvIHNheSBoaQpEaWQgeW91IHN0b3A/IE5vLCBJIGp1c3QgZHJvdmUg
# YnkK";
    my $appendCode = "hello this is a test wokka wokka wokka wokka wokka wokka!!!";
    #$appendCode = decode_base64($appendCode);
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
    #my $beforePad = pad("",rand_between(5,10));
    my $beforePad = "";
    my $afterPad = pad("",rand_between(5,10));

    $plainText = $beforePad .= $plainText.= $afterPad;

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