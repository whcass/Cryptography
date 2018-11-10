#!/usr/bin/perl
=begin
Implement CBC mode
CBC mode is a block cipher mode that allows us to encrypt irregularly-sized messages, despite the fact that a block cipher natively only transforms individual blocks.

In CBC mode, each ciphertext block is added to the next plaintext block before the next call to the cipher core.

The first plaintext block, which has no associated previous ciphertext block, is added to a "fake 0th ciphertext block" called the initialization vector, or IV.

Implement CBC mode by hand by taking the ECB function you wrote earlier, making it encrypt instead of decrypt (verify this by decrypting whatever you encrypt to test), and using your XOR function from the previous exercise to combine them.

The file here is intelligible (somewhat) when CBC decrypted against "YELLOW SUBMARINE" with an IV of all ASCII 0 (\x00\x00\x00 &c)
=cut
use strict;
use warnings;
use MIME::Base64;
use Crypt::OpenSSL::AES;
use Carp;

my $file = "resources/2.txt";
my $cipherText;
{
    local $/;
    open my $fh, '<', $file or die "can't open $file: $!";
    $cipherText = <$fh>;
    $cipherText = decode_base64($cipherText);
}
my $key = "YELLOW SUBMARINE";
my $decrypt = Crypt::OpenSSL::AES->new($key);
my $encrypt = Crypt::OpenSSL::AES->new($key);
my $iv = "\x00" x 16;

my $cbc_decrypt = cbc_decrypt($cipherText,$iv,$decrypt);
print "$cbc_decrypt\n";
my $cbc_encrypt = cbc_encrypt($cbc_decrypt,$iv,$encrypt);
$cbc_encrypt = encode_base64($cbc_encrypt);
print "$cbc_encrypt\n";


sub cbc_decrypt {
    my ($cipherText,$iv,$decrypt) = @_;
    #my @blocks = unpack "(H16)*", $cipherText;
    my $result;
    my $state = $iv;
    for(my $offset = 0; $offset<length($cipherText);$offset+=16){
        my $block = substr($cipherText,$offset,16);
        my $dec = $decrypt->decrypt($block);
        $result .= "$dec" ^ "$state";
        $state = $block;
    }
    $result = unpad($result);
    return $result;
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

sub unpad {
    my ($data) = @_;
    my $count = ord(substr($data, -1, 1));
    if ($count == 0) {
        croak "invalid PKCS#7 padding";
    }
    for (1..$count) {
        unless (ord(chop $data) eq $count) {
            croak "invalid PKCS#7 padding";
        }
    }
    return $data;
}

sub pad {
    my ($data, $blocklen) = @_;
    my $mod = $blocklen - (length($data) % $blocklen);
    $mod ||= $blocklen;
    return $data . (chr($mod) x $mod);
}