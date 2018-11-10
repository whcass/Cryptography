#!/usr/bin/perl
=begin
An ECB/CBC detection oracle
Now that you have ECB and CBC working:

Write a function to generate a random AES key; that's just 16 random bytes.

Write a function that encrypts data under an unknown key --- that is, a function that generates a random key and encrypts under it.

The function should look like:

encryption_oracle(your-input)
=> [MEANINGLESS JIBBER JABBER]
Under the hood, have the function append 5-10 bytes (count chosen randomly) before the plaintext and 5-10 bytes after the plaintext.

Now, have the function choose to encrypt under ECB 1/2 the time, and under CBC the other half (just use random IVs each time for CBC). Use rand(2) to decide which to use.

Detect the block cipher mode the function is using each time. You should end up with a piece of code that, pointed at a block box that might be encrypting ECB or CBC, tells you which one is happening.
=cut
use strict;
use warnings;
use MIME::Base64;
use Crypt::OpenSSL::AES;
use Crypt::Mode::ECB;
use Data::Dumper;
my $file = 'resources/bobross.txt';

# my $plainText;
# {
#     local $/;
#     open my $fh, '<', $file or die "can't open $file: $!";
#     $plainText = <$fh>;
# }
my ($ecb, $cbc, $found) = (0,0,0);
my $plainText = 'x' x 50;
for (1..1000){
    my $cipher = encryption_oracle($plainText);
    my $blocks;
    for(my $offset = 0; $offset < length($cipher); $offset += 16){
        my $block = substr $cipher, $offset, 16;
        if($blocks->{$block}++){
            $found++;
            last;
        }
    }
}
print "[ecb] $ecb\n";
print "[cbc] $cbc\n";
print "[found] $found\n";

sub encryption_oracle {
    my ($plainText) = @_;
    $plainText = pad_plaintext($plainText);
    my $encryptType = int(rand(2));
    my $key = generate_aes_key();
    #my $key = "YELLOW SUBMARINE";
    my $encrypt = Crypt::OpenSSL::AES->new($key);
    my $cipher;
    if($encryptType == 0){
        my $iv = generate_aes_key();
        $cipher = cbc_encrypt($plainText,$iv,$encrypt);
        #print "[mode] CBC\n";
        $cbc++;
    }else{
        $cipher = ecb_encrypt($plainText,$encrypt);
        $ecb++;
        #print "[mode] ECB\n";
    }

    return $cipher;
}

sub pad_plaintext {
    my ($plainText) = @_;
    my $minimum = 5;
    my $maximum = 10;
    my $beforePad = pad("",rand_between(5,10));
    my $afterPad = pad("",rand_between(5,10));

    $plainText = $beforePad .= $plainText.= $afterPad;

    return $plainText;

}

sub rand_between {
    my ($min, $max) = @_;
    return $min + int(rand($max - $min))+1;
}

sub generate_aes_key {
    my @set = ('0'..'9','a'..'f');
    my $key = join '' => map $set[rand @set],1..16;
    return $key;
}

sub cbc_encrypt {
    my ($plainText,$iv,$encrypt) = @_;
    $plainText = pad($plainText,16);
    my $result;
    my $state = $iv;
    for(my $offset = 0; $offset<length($plainText);$offset+=16){
        my $block = substr($plainText,$offset,16);
        $block = "$block" ^ "$state";
        $state = $encrypt->encrypt($block);
        $result .= $state;
    }
    return $result;
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