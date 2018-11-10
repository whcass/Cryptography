#!/usr/bin/perl
=begin
ECB cut-and-paste
Write a k=v parsing routine, as if for a structured cookie. The routine should take:

foo=bar&baz=qux&zap=zazzle
... and produce:

{
  foo: 'bar',
  baz: 'qux',
  zap: 'zazzle'
}
(you know, the object; I don't care if you convert it to JSON).

Now write a function that encodes a user profile in that format, given an email address. You should have something like:

profile_for("foo@bar.com")
... and it should produce:

{
  email: 'foo@bar.com',
  uid: 10,
  role: 'user'
}
... encoded as:

email=foo@bar.com&uid=10&role=user
Your "profile_for" function should not allow encoding metacharacters (& and =). Eat them, quote them, whatever you want to do, but don't let people set their email address to "foo@bar.com&role=admin".

Now, two more easy functions. Generate a random AES key, then:

Encrypt the encoded user profile under the key; "provide" that to the "attacker".
Decrypt the encoded user profile and parse it.
Using only the user input to profile_for() (as an oracle to generate "valid" ciphertexts) and the ciphertexts themselves, make a role=admin profile.
=cut
use strict;
use warnings;
use Data::Dumper;
use Crypt::Mode::ECB;
my $key = generate_aes_key();

my $cookie = profile_for("admin\@bar.com");
print Dumper read_profile($cookie);
#my $decrypted = decrypt_cookie($encrypted);
#my %parsed = parse_cookie($decrypted);

#print "[*] $cookie\n";
#print "[*] $encrypted\n";
#print "[*] $decrypted\n";



sub oracle {
    my ($email) = @_;
    return profile_for($email);
}

sub parse_cookie {
    my ($cookie) = @_;
    my @kvs = split /&/, $cookie;
    my %kvs = map { split /=/ } @kvs;
    return \%kvs;
}

sub profile_for {
    my ($input) = @_;
    $input =~ s/[\&\=]//g;
    my $data = {
        email=> $input,
        role=> 'user',
        uid=> 10,
    };
    #my $encoded = "email=$input&uid=10&role=user";
    return encrypt_cookie(write_cookie($data, [qw/ email uid role /]));
}


sub generate_aes_key {
    my @set = ('0'..'9','a'..'f');
    my $key = join '' => map $set[rand @set],1..16;
    return $key;
}

sub encrypt_cookie {
    my ($plainText) = @_;
    my $m = Crypt::Mode::ECB->new('AES');
    my $cipherText = $m->encrypt($plainText,$key);
    return $cipherText;
}

sub decrypt_cookie {
    my ($cipherText) = @_;
    my $m = Crypt::Mode::ECB->new('AES');
    my $plainText = $m->decrypt($cipherText,$key);
    return $plainText;
}

sub write_cookie {
    my ($kvs, $keys) = @_;
    my @cookie;
    for my $k (@$keys) {
        my $key = $k;
        $key =~ s/[&=]//g;
        my $value = $kvs->{$k};
        $value =~ s/[&=]//g;
        push @cookie, "$key=$value";
    }
    return join '&', @cookie;
}

sub read_profile {
    my ($cookie) = @_;
    my $encoded = decrypt_cookie($cookie);
    return parse_cookie($encoded);
}