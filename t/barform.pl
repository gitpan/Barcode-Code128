#!/usr/bin/perl
# Perl script for generating a barcode image and display in browser
# by Guenter Knauf eflash@gmx.net
# 
use Barcode::Code128 qw(:all);
#use strict;

if (GD->VERSION < 1.20) {$itype = 'gif'} else {$itype = 'png'};
$modver = 'Barcode::Code128.pm '.Barcode::Code128->VERSION.' GD.pm '.GD->VERSION; 

&parse_form_data;
$input = $form_results{value} || 'CODE 128';

if ($form_results{input} ne '') {
	&process_request;
} else {
	&print_form;
}


sub print_header {
	print<<EOM;
Content-type: text/html

<HTML>
<HEAD><TITLE>Barcode Code128 Test</TITLE></HEAD>
<BODY BGCOLOR="#ffffff">
<H1>Barcode Code128 Test</H1>
<FONT SIZE="-1"><FONT COLOR="green">$modver</FONT></FONT>
<HR>
EOM
}

sub print_form {
	&print_header;
	print<<EOM;
<FORM>
<FONT SIZE="+1"><B>Input:
<INPUT NAME="input" SIZE="22" VALUE="$input"> 
Startcode: 
<SELECT NAME="char" SIZE="1">
<OPTION SELECTED>
<OPTION>FNC1
<OPTION>FNC2
<OPTION>FNC3
<OPTION>FNC4
<OPTION>CodeA
<OPTION>CodeB
<OPTION>CodeC
<OPTION>Shift
<OPTION>StartA
<OPTION>StartB
<OPTION>StartC
<OPTION>Stop
</SELECT>
<INPUT TYPE="submit" VALUE="Generate Barcode">
<INPUT TYPE="reset" VALUE="Clear">
</B></FONT>
</FORM>
</BODY>
</HTML>
EOM
}

sub process_request {
	$input = $form_results{input};
	$char = $form_results{char};
	if ($char ne '') {
	    $input = eval($char).$input;
	}
	my $code = new Barcode::Code128;
	print "Pragma: no-cache\n";
	print "Content-type: image/$itype\n\n";
	binmode STDOUT;
	print $code->mkbc($input);
}

sub parse_form_data {
	%form_results;  # this is the hash which will store the form results
	@name_value_pairs = split (/&/, $ENV{'QUERY_STRING'});
	foreach $pair (@name_value_pairs) {
	    ($key, $value) = split (/=/, $pair);
	    $value =~ tr/+/ /;
	    $value =~ s/%([\dA-Fa-f][\dA-Fa-f])/pack ("C", hex ($1))/eg;
	    $form_results{$key} = $value;
	}
}
