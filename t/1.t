# -*- Perl -*-

######################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "1..3\n"; }
END {print "not ok 1\n" unless $loaded;}
use Barcode::Code128 qw(FNC1);
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):
use strict;
my $code = new Barcode::Code128;
my $encoded = $code->barcode("1234 abcd");
print "not " unless $encoded eq
    ("## #  ###  # ##  ###  #   # ##   # #### ### ## ##  ##  #  # ##    #".
     "  #    ## #    # ##  #    #  ## ###   # ## ##   ### # ##");
print "ok 2\n";
my $good;
{
    open IM, ">t/code128.png" or die "Can't read t/code128.png: $!";
    binmode IM;
    print IM $code->png("CODE 128");
    local($/) = undef;
    $good = <IM>;
    close IM;
}
my $test = $code->png("CODE 128");
print "not " unless $test eq $good;
print "ok 3\n";
