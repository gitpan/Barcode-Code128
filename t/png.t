# -*- Perl -*-

# Make sure the module loads correctly - if GD is less than 1.20, use
# 1..0 to cause "skipped on this platform"

my $max;
BEGIN {
    eval { require GD; };
    $max = !$@ && $GD::VERSION >= 1.20 ? 2 : 0;
    $| = 1; print "1..$max\n";
}
END {print "not ok 1\n" unless $loaded;}
use Barcode::Code128 qw(FNC1);
$loaded = 1;
print "ok 1\n";
exit unless $max;

# Create a PNG file 
use strict;
my $code = new Barcode::Code128;
my $file = "t/code128.png";
my $good;
{
    open IM, $file or die "Can't read $file: $!";
    binmode IM;
    read IM, $good, -s $file;
    close IM;
}
my $test = $code->png("CODE 128");
print "not " unless $test eq $good;
print "ok 2\n";
