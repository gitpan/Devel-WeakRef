#!/sig/local/bin/perl5 -w

use ExtUtils::MakeMaker;

WriteMakefile(
# $Format: " VERSION => '$DevelWeakRefRelease$',"$
 VERSION => '0.001',
              NAME => 'Devel::WeakRef',
	      PREREQ_PM => {
			    mods => 0.004
			   },
#	      EXE_FILES => []
);
