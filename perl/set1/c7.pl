#!/usr/bin/perl
=begin
AES in ECB mode
The Base64-encoded content in this file has been encrypted via AES-128 in ECB mode under the key

"YELLOW SUBMARINE".
(case-sensitive, without the quotes; exactly 16 characters; I like "YELLOW SUBMARINE" because it's exactly 16 bytes long, and now you do too).

Decrypt it. You know the key, after all.

Easiest way: use OpenSSL::Cipher and give it AES-128-ECB as the cipher.
=cut

use strict;
use warnings;
use Crypt::Mode::ECB;
use MIME::Base64;


my $m = Crypt::Mode::ECB->new('AES');
my $key = "YELLOW SUBMARINE";
my $file = "resources/7.txt";
my $cipherText;
{
    local $/;
    open my $fh, '<', $file or die "can't open $file: $!";
    $cipherText = <$fh>;
    $cipherText = decode_base64($cipherText);
}
my $plaintext = $m->decrypt($cipherText,$key);
print "[*] $plaintext";