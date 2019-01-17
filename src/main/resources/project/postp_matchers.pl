use ElectricCommander;

push (@::gMatchers,
  {
        id =>          "licenseMatcher",
        pattern =>     q{ERROR: No license file found},
        action =>           q{
                              
                              my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');

                              $desc .= "No license found! Cannot continue.";
                              
                              setProperty("summary", $desc . "\n");
                              
                             },
  },
);

push (@::gMatchers,
  {
        id =>          "licenseMatcher",
        pattern =>     q{WARN: No coverage recordings found},
        action =>           q{
                              
                              my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');

                              $desc .= "No coverage recordings found";
                              
                              setProperty("summary", $desc . "\n");
                              
                             },
  },
);

push (@::gMatchers,
  {
        id =>          "expiredLicenseMatcher",
        pattern =>     q{.*Your license has expired(.*)},
        action =>           q{
                              
                              my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');

                              $desc .= "Clover license has expired";
                              
                              setProperty("summary", $desc . "\n");
                              
                             },
  },
);

push (@::gMatchers,
  {
        id =>          "instrumentedFilesMatcher",
        pattern =>     q{.*Instrumented (\d+) file(s*)},
        action =>           q{
                              
                              my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');

                              $desc .= "Files Instrumented: $1";                         
                              
                              setProperty("summary", $desc . "\n");
                              
                             },
  },
);

push (@::gMatchers,
  {
        id =>          "sourceLevelMatcher",
        pattern =>     q{Processing files at (\S+) source},
        action =>           q{
                              
                              my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');

                              $desc .= "Source Level: $1";                         
                              
                              setProperty("summary", $desc . "\n");
                              
                             },
  },
);

push (@::gMatchers,
  {
        id =>          "elapsedTimeMatcher",
        pattern =>     q{.*Elapsed time = (\d+.\d+) secs},
        action =>           q{
                              
                              my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');

                              $desc .= "Elapsed Time: $1 seconds";                         
                              
                              setProperty("summary", $desc . "\n");
                              
                             },
  },
);

push (@::gMatchers,
  {
        id =>          "instrumentedPackagesMatcher",
        pattern =>     q{(\d+) package(s*)},
        action =>           q{
                              
                              my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');

                              $desc .= "Packages Instrumented: $1";                              
                              
                              setProperty("summary", $desc . "\n");
                              
                             },
  },
);

push (@::gMatchers,
  {
        id =>          "methodCoverageMatcher",
        pattern =>     q{Methods: (.+)},
        action =>           q{
                              
                              my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');

                              $desc .= "Method Coverage: $1";
                              
                              setProperty("summary", $desc . "\n");
                              
                             },
  },
);

push (@::gMatchers,
  {
        id =>          "statementCoverageMatcher",
        pattern =>     q{Statements: (.+)},
        action =>           q{
                              
                              my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');

                              $desc .= "Statements Coverage: $1";
                              
                              setProperty("summary", $desc . "\n");
                              
                             },
  },
);

push (@::gMatchers,
  {
        id =>          "branchesCoverageMatcher",
        pattern =>     q{Branches: (.+)},
        action =>           q{
                              
                              my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');

                              $desc .= "Branch Coverage: $1";
                              
                              setProperty("summary", $desc . "\n");
                              
                             },
  },
);

push (@::gMatchers,
  {
        id =>          "dbQtyMatcher",
        pattern =>     q{Merging database \d+ of (\d+)},
        action =>           q{
                              
                              my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');

                              $desc .= "Databases found: $1";
                              
                              setProperty("summary", $desc . "\n");
                              
                             },
  },
);

push (@::gMatchers,
  {
        id =>          "completedMatcher",
        pattern =>     q{Merge complete},
        action =>           q{
                              
                              my $desc = ((defined $::gProperties{"summary"}) ? $::gProperties{"summary"} : '');

                              $desc .= "Merge completed";
                              
                              setProperty("summary", $desc . "\n");
                              
                             },
  },
);
