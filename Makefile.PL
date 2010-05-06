use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Net::Plurk',
    AUTHOR              => 'Cheng-Lung Sung <clsung@cpan.org>',
    VERSION_FROM        => 'lib/Net/Plurk.pm',
    ABSTRACT_FROM       => 'lib/Net/Plurk.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'AnyEvent::HTTP' => 0,
        'JSON::Any' => 0,
        'DateTime::Format::Strptime' => 0,
        'Moose' => 0
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Net-Plurk-*' },
);
