require 5.004;

=head1 NAME

Barcode::Code128 - Generate CODE 128 bar codes

=head1 SYNOPSIS

  use Barcode::Code128;
  
  $code = new Barcode::Code128;

=head1 REQUIRES

Perl 5.004, Carp, Exporter, GD

=head1 EXPORTS

By default, nothing.  However there are a number of constants that
represent special characters used in the CODE 128 symbology that you
may wish to include.  For example if you are using the EAN-128 or
UCC-128 code, the string to encode begins with the FNC1 character.  To
encode the EAN-128 string "00 0 0012345 555555555 8", you would do the
following:

  use Barcode::Code128 'FNC1';
  $code = new Barcode::Code128;
  $code->text(FNC1.'00000123455555555558');

To have this module export one or more of these characters, specify
them on the C<use> statement or use the special token ':all' instead
to include all of them.  Examples:

  use Barcode::Code128 qw(FNC1 FNC2 FNC3 FNC4 Shift);
  use Barcode::Code128 qw(:all);

Here is the complete list of the exportable characters.  They are
assigned to high-order ASCII characters purely arbitrarily for the
purposes of this module; the values used do not reflect any part of
the CODE 128 standard.  B<Warning>: Using the C<CodeA>, C<CodeB>,
C<CodeC>, C<StartA>, C<StartB>, C<StartC>, and C<Stop> codes may cause
your barcodes to be invalid, and be rejected by scanners.  They are
inserted automatically as needed by this module.

  CodeA      0xf4        CodeB      0xf5         CodeC      0xf6
  FNC1       0xf7        FNC2       0xf8         FNC3       0xf9
  FNC4       0xfa        Shift      0xfb         StartA     0xfc
  StartB     0xfd        StartC     0xfe         Stop       0xff

=head1 DESCRIPTION

Barcode::Code128 generates bar codes using the CODE 128 symbology.
The typical use this is for generating a PNG file with the C<png()>
method which uses the GD package by Lincoln Stein.  When this PNG file
is printed, it can be scanned by most modern hand-held bar code
readers.  The application which drove the invention of this module
places the PNG file on a web page which the user must print out and
submit along with supporting documents.  The bar code helps the
receiving agency record when it has been received.

Since the GD module is required you will need to install it before
installing this module.  You can obtain it from the CPAN
(Comprehensive Perl Archive Network) repository of your choice under
the directory C<authors/id/LDS>.  Visit http://www.perl.com/ for more
information about CPAN.  The GD home page is:
http://stein.cshl.org/WWW/software/GD/GD.html

=head1 METHODS

=over 4

=cut

package Barcode::Code128;

use strict;

use vars qw($VERSION %CODE_CHARS %CODE @ENCODING @EXPORT_OK
	    %EXPORT_TAGS %FUNC_CHARS @ISA);

use constant CodeA  => chr(0xf4);
use constant CodeB  => chr(0xf5);
use constant CodeC  => chr(0xf6);
use constant FNC1   => chr(0xf7);
use constant FNC2   => chr(0xf8);
use constant FNC3   => chr(0xf9);
use constant FNC4   => chr(0xfa);
use constant Shift  => chr(0xfb);
use constant StartA => chr(0xfc);
use constant StartB => chr(0xfd);
use constant StartC => chr(0xfe);
use constant Stop   => chr(0xff);

use Carp;
use Exporter;
use GD;

@EXPORT_OK = qw(CodeA CodeB CodeC FNC1 FNC2 FNC3 FNC4 Shift StartA
		StartB StartC Stop);
%EXPORT_TAGS = (all => \@EXPORT_OK);
@ISA = qw(Exporter);

# Version information
$VERSION = '1.10';

@ENCODING = qw(11011001100 11001101100 11001100110 10010011000
	       10010001100 10001001100 10011001000 10011000100
	       10001100100 11001001000 11001000100 11000100100
	       10110011100 10011011100 10011001110 10111001100
	       
	       10011101100 10011100110 11001110010 11001011100
	       11001001110 11011100100 11001110100 11101101110
	       11101001100 11100101100 11100100110 11101100100
	       11100110100 11100110010 11011011000 11011000110
	       
	       11000110110 10100011000 10001011000 10001000110
	       10110001000 10001101000 10001100010 11010001000
	       11000101000 11000100010 10110111000 10110001110
	       10001101110 10111011000 10111000110 10001110110
	       
	       11101110110 11010001110 11000101110 11011101000
	       11011100010 11011101110 11101011000 11101000110
	       11100010110 11101101000 11101100010 11100011010
	       11101111010 11001000010 11110001010 10100110000
	       
	       10100001100 10010110000 10010000110 10000101100
	       10000100110 10110010000 10110000100 10011010000
	       10011000010 10000110100 10000110010 11000010010
	       11001010000 11110111010 11000010100 10001111010
	       
	       10100111100 10010111100 10010011110 10111100100
	       10011110100 10011110010 11110100100 11110010100
	       11110010010 11011011110 11011110110 11110110110
	       10101111000 10100011110 10001011110 10111101000
	       
	       10111100010 11110101000 11110100010 10111011110
	       10111101110 11101011110 11110101110 11010000100
	       11010010000 11010011100 1100011101011);

%CODE_CHARS = ( A => [ (map { chr($_) } 040..0137, 000..037),
		       FNC3, FNC2, Shift, CodeC, CodeB, FNC4, FNC1,
		       StartA, StartB, StartC, Stop ],
		B => [ (map { chr($_) } 040..0177),
		       FNC3, FNC2, Shift, CodeC, FNC4, CodeA, FNC1,
		       StartA, StartB, StartC, Stop ],
		C => [ ("00".."99"),
		       CodeB, CodeA, FNC1, StartA, StartB, StartC, Stop ]);

# Provide string equivalents to the constants
%FUNC_CHARS = ('CodeA'	=> CodeA,
	       'CodeB'	=> CodeB,
	       'CodeC'	=> CodeC,
	       'FNC1'	=> FNC1,
	       'FNC2'	=> FNC2,
	       'FNC3'	=> FNC3,
	       'FNC4'	=> FNC4,
	       'Shift'	=> Shift,
	       'StartA'	=> StartA,
	       'StartB'	=> StartB,
	       'StartC'	=> StartC,
	       'Stop'	=> Stop );

# Convert the above into a 2-dimensional hash
%CODE = ( A => { map { $CODE_CHARS{A}[$_] => $_ } 0..106 },
	  B => { map { $CODE_CHARS{B}[$_] => $_ } 0..106 },
	  C => { map { $CODE_CHARS{C}[$_] => $_ } 0..106 } );

##----------------------------------------------------------------------------

=item $object = new Barcode::Code128

Creates a new barcode object.

=cut

sub new
{
    my $type = shift;
    my $self = bless { @_ }, $type;
    $self->{encoded} ||= [];
    $self->{text}    ||= '';
    $self;
}

##----------------------------------------------------------------------------

=item $object->png($text)

=item $object->png($text, $x, $y)

Generate a PNG file and return it.  Typically you will either print
the result to standard output or save it to a file.  The contents of
the return value from this method are a binary file, so if you are
working on an operating system that makes a distinction between text
and binary files be sure to call binmode(FILEHANDLE) before writing
the PNG to it.  Example:

  open(PNG, ">code128.png") or die "Can't write code128.png: $!\n";
  binmode(PNG);
  print PNG $object->png("CODE 128");
  close(PNG);

Note: All of the arguments to this function are optional.  If you have
previously specified C<$text> to the C<barcode()>, C<encode()>, or
C<text()> methods, you do not need to specify it again.  The C<$x> and
C<$y> variables specify the size of the barcode within PNG file in
pixels.  The overall image will be an extra 20 pixels taller to
accomodate the plaintext rendering of the encoded message (in black on
a transparent background).  If size(s) are not specified, they will be
set to the minimum size, which is the length of the barcode plus 40
pixels horizontally, and 15% of the length of the barcode vertically.

=cut

sub png
{
    my($self, $text, $x, $y) = @_;
    my @barcode = split //, $self->barcode($text);
    my $n = scalar(@barcode);	# width of string
    my $min_x = $n*2 + 40;
    my $min_y = $n*2 * 0.15;	# 15% of width in pixels
    $x ||= $min_x;
    $y ||= $min_y;
    croak "Image width $x is too small for bar code"  if $x < $min_x;
    croak "Image height $y is too small for bar code" if $y < $min_y;
    my $image = new GD::Image($x, $y+20) or
	croak "Unable to create $x x $y PNG image";
    my $grey  = $image->colorAllocate(0xCC, 0xCC, 0xCC);
    my $white = $image->colorAllocate(0xFF, 0xFF, 0xFF);
    my $black = $image->colorAllocate(0x00, 0x00, 0x00);
    $image->transparent($grey);
    $image->rectangle(0, 0, $x-1, $y-1, $black);
    $image->rectangle(4, 4, $x-5, $y-5, $black);
    $image->fill(1, 1, $black);
    $image->fill(6, 6, $white);
    for (my $i = 0; $i < $n; ++$i)
    {
	my $pos = $x/2 - $n + $i*2;
	my $color = $barcode[$i] eq '#' ? $black : $white;
	$image->rectangle($pos, 5, $pos+1, $y-6, $color);
    }
    my $encoded = $self->{encoded};
    $image->string(gdLargeFont, 2, $y+2, $self->{text}, $black);
    return $image->png();
}

##----------------------------------------------------------------------------

=item $object->barcode($text)

Computes the bar code for the specified text.  The result will be a
string of '#' and space characters representing the dark and light
bands of the bar code.  You can use this if you have an alternate
printing system besides the C<png()> method.

Note: The C<$text> parameter is optional. If you have previously
specified C<$text> to the C<encode()> or C<text()> methods, you do not
need to specify it again.

=cut

sub barcode
{
    my($self, $text) = @_;
    $self->encode($text) if defined $text;
    my @encoded = @{ $self->{encoded} };
    croak "No encoded text found" unless @encoded;
    join '', map { $_ = $ENCODING[$_]; tr/01/ \#/; $_ } @encoded;
}

###---------------------------------------------------------------------------

=back

=head2 Housekeeping Functions

The rest of the methods defined here are only for internal use, or if
you really know what you are doing.  Some of them may be useful to
authors of classes that inherit from this one, or may be overridden by
subclasses.  If you just want to use this module to generate bar
codes, you can stop reading here.

=over 4

=cut

##----------------------------------------------------------------------------

=item $object->encode

=item $object->encode($text)

Do the encoding.  If C<$text> is supplied, will automatically call the
text() method to set that as the text value first.

=cut

sub encode
{
    my($self, $text) = @_;
    $self->text($text) if defined $text;
    croak "No text defined" unless defined($text = $self->text);
    # Reset internal variables
    my $encoded = $self->{encoded} = [];
    $self->{code} = undef;
    my $sanity = 0;
    while(length $text)
    {
	confess "Sanity Check Overflow" if $sanity++ > 1000;
	my @chars;
	if (@chars = _encodable('C', $text))
	{
	    $self->start('C');
	    push @$encoded, map { $CODE{C}{$_} } @chars;
	}
	else
	{
	    my %x = map { $_ => [ _encodable($_, $text) ] } qw(A B);
	    my $code = (@{$x{A}} >= @{$x{B}} ? 'A' : 'B'); # prefer A if equal
	    $self->start($code);
	    @chars = @{ $x{$code} };
	    push @$encoded, map { $CODE{$code}{$_} } @chars;
	}
	croak "Unable to find encoding for ``$text''" unless @chars;
	substr($text, 0, length join '', @chars) = '';
    }
    $self->stop;
    wantarray ? @$encoded : $encoded;
}

##----------------------------------------------------------------------------

=item $object->text($text)

=item $text = $object->text

Set or retrieve the text for this barcode.  This will be called
automatically by encode() or barcode() so typically this will not be
used directly by the user.

=cut

sub text
{
    my($self, $text) = @_;
    $self->{text} = $text if defined $text;
    $self->{text};
}

##----------------------------------------------------------------------------

=item $object->start($code)

If the code (see code()) is already defined, then adds the CodeA,
CodeB, or CodeC character as appropriate to the encoded message inside
the object.  Typically for internal use only.

=cut

sub start
{
    my($self, $new_code) = @_;
    my $old_code = $self->code;
    if (defined $old_code)
    {
	my $func = $FUNC_CHARS{"Code$new_code"} or
	    confess "Unable to switch from ``$old_code'' to ``$new_code''";
	push @{ $self->{encoded} }, $CODE{$old_code}{$func};
    }
    else
    {
	my $func = $FUNC_CHARS{"Start$new_code"} or
	    confess "Unable to start with ``$new_code''";
	@{ $self->{encoded} } = $CODE{$new_code}{$func};
    }
    $self->code($new_code);
}

##----------------------------------------------------------------------------

=item $object->stop()

Computes the check character and appends it along with the Stop
character, to the encoded string.  Typically for internal use only.

=cut

sub stop
{
    my($self) = @_;
    my $sum = $self->{encoded}[0];
    for (my $i = 1; $i < @{ $self->{encoded} }; ++$i)
    {
	$sum += $i * $self->{encoded}[$i];
    }
    my $stop = Stop;
    push @{ $self->{encoded} }, ($sum % 103), $CODE{C}{$stop};
}

##----------------------------------------------------------------------------

=item $object->code($code)

=item $code = $object->code

Set or retrieve the code for this barcode.  C<$code> may be 'A', 'B',
or 'C'.  Typically for internal use only.  Not particularly meaningful
unless called during the middle of encoding.

=cut

sub code
{
    my($self, $new_code) = @_;
    if (defined $new_code)
    {
	$new_code = uc $new_code;
	croak "Unknown code ``$new_code'' (should be A, B, or C)"
	    unless $new_code eq 'A' || $new_code eq 'B' || $new_code eq 'C';
	$self->{code} = $new_code;
    }
    $self->{code};
}

##----------------------------------------------------------------------------
## _encodable($code, $string)
##
## Internal use only.  Returns array of characters from $string that
## can be encoded using the specified $code (A B or C).  Note: not an
## object-oriented method.

sub _encodable
{
    my($code, $string) = @_;
    my @chars;
    while (length $string)
    {
	my $old = $string;
	push @chars, $1 while($code eq 'C' && $string =~ s/^(\d\d)//);
	my $char;
	while(defined($char = substr($string, 0, 1)))
	{
	    last if $code ne 'C' && $string =~ /^\d\d\d/;
	    last unless exists $CODE{$code}{$char};
	    push @chars, $char;
	    $string =~ s/^\Q$char\E//;
	}
	last if $old eq $string; # stop if no more changes made to $string
    }
    @chars;
}

=back

=head1 CLASS VARIABLES

None.

=head1 DIAGNOSTICS

=over 4

=item Image width $x is too small for bar code

You have specified an image width that does not allow enough space for
the bar code to be displayed.  The minimum allowable is the size of
the bar code itself plus 40 pixels.  If in doubt, just omit the width
value when calling C<png()> and it will use the minimum.

=item Image height $y is too small for bar code

You have specified an image height that does not allow enough space
for the bar code to be displayed.  The minimum allowable is 15% of the
width of the bar code.  If in doubt, just omit the height value when
calling C<png()> and it will use the minimum.

=item Unable to create $x x $y PNG image

An error occurred when initializing a GD::Image object for the
specified size.  Perhaps C<$x> and C<$y> are too large for memory?

=item No encoded text found

This message from C<barcode()> typically means that there was no text
message supplied either during the current method call or in a
previous method call on the same object.

=item No text defined

This message from C<encode()> typically means that there was no text
message supplied either during the current method call or in a
previous method call on the same object.

=item Unable to find encoding for ``$text''

Part or all of the message could not be encoded.  This may mean that
the message contained characters not encodable in the CODE 128
character set, such as a character with an ASCII value higher than 127
(except the special control characters defined in this module).

=item Sanity Check Overflow

This is a serious error in C<encode()> that indicates a serious
problem attempting to encode the requested message.  This means that
an infinite loop was generated.  If you get this error please contact
the author.

=item Unable to switch from ``$old_code'' to ``$new_code''

This is a serious error in C<start()> that indicates a serious problem
occurred when switching between the codes (A, B, or C) of CODE 128.
If you get this error please contact the author.

=item Unable to start with ``$new_code''

This is a serious error in C<start()> that indicates a serious problem
occurred when starting encoding in one of the codes (A, B, or C) of
CODE 128.  If you get this error please contact the author.

=item Unknown code ``$new_code'' (should be A, B, or C)

This is a serious error in C<code()> that indicates an invalid
argument was supplied.  Only the codes (A, B, or C) of CODE 128 may be
supplied here.  If you get this error please contact the author.

=back

=head1 BUGS

At least some Web browsers do not seem to handle PNG files with
transparent backgrounds correctly.  As a result your barcodes may have
a grey background behind the text version of the message.

=head1 AUTHOR

William R. Ward, wrw@bayview.com

=head1 SEE ALSO

perl(1), GD

=cut

1;
