use ExtUtils::MakeMaker;

WriteMakefile(NAME	   => 'Barcode::Code128',
	      VERSION_FROM => 'lib/Barcode/Code128.pm', # finds $VERSION
	      PREREQ_PM    => { GD => 0 },
	     );
