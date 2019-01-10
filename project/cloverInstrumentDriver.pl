# -------------------------------------------------------------------------
#
# Dependencies
#    None
#
# Purpose
#    Template for Single Command-line Plug-ins
#
# Template Version
#    1.0
#
# Date
#    11/05/2010
#
# Engineer
#    Alonso Blanco
#
# Copyright (c) 2010 Electric Cloud, Inc.
# All rights reserved
# -------------------------------------------------------------------------
   
   
# -------------------------------------------------------------------------
# Includes
# -------------------------------------------------------------------------
use ElectricCommander;
use warnings;
use strict;
$|=1;
   
# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------
use constant {
       
       SUCCESS => 0,
       ERROR   => 1,

       GENERATE_REPORT => 1,
       DO_NOT_GENERATE_REPORT => 0,
       
       PLUGIN_NAME => 'EC-Clover-CMD',
       JAVA_COMPILER_NAME => 'javac',
       
       REPORT_TYPE_CONSOLE => 'console',
       REPORT_TYPE_PDF => 'pdf',
       REPORT_TYPE_XML => 'xml',
       REPORT_TYPE_HTML => 'html',
       
};
  
# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
my $ec = ElectricCommander->new();
$ec->abortOnError(0);

$::gJavaPath                = ($ec->getProperty( "javapath" ))->findvalue('//value')->string_value;
$::gAdditionalInstrCommands = ($ec->getProperty( "additionalinstrcommands" ))->findvalue('//value')->string_value;
$::gClasspath               = ($ec->getProperty( "classpath" ))->findvalue('//value')->string_value;
$::gInstrumentMainClass     = ($ec->getProperty( "instrmainclass" ))->findvalue('//value')->string_value;
$::gInitString              = ($ec->getProperty( "initstring" ))->findvalue('//value')->string_value;
$::gSourceFilePath          = ($ec->getProperty( "sourcefilepath" ))->findvalue('//value')->string_value;
$::gSourceFileDest          = ($ec->getProperty( "sourcefiledest" ))->findvalue('//value')->string_value;
$::gEnableVerbosity         = ($ec->getProperty( "verbose" ))->findvalue('//value')->string_value;

# ---------------------------------------------------------------------
# Main functions
# ---------------------------------------------------------------------


########################################################################
# main - contains the whole process to be done by the plugin, it builds 
#        the command line, sets the properties and the working directory
#
# Arguments:
#   -none
#
# Returns:
#   -none
#
########################################################################
sub main() {
    
    # create args arrays
    my @instrumentArgs = ();
    
    #properties' map
    my %props;
    
    #setting the executable
    my $exec = '';
    
    if($::gJavaPath && $::gJavaPath ne ''){
        $exec .= $::gJavaPath ;
    }
    
    push(@instrumentArgs, $exec);
    
    #set the classpaths
    #requires java 6, usage of wildcard in classpath dependency
    if($::gClasspath && $::gClasspath ne '') {
        push(@instrumentArgs, '-cp "' . $::gClasspath . '"');
    }  
    
    #insert into the command arrays the main classes to use
    push(@instrumentArgs, $::gInstrumentMainClass);
    
    #additional commands for each program    
    if($::gAdditionalInstrCommands  && $::gAdditionalInstrCommands  ne '') {
        foreach my $command (split(' +', $::gAdditionalInstrCommands)) {
            push(@instrumentArgs, $command);
        }
    }

    if($::gEnableVerbosity && $::gEnableVerbosity ne ''){
        push(@instrumentArgs, '--verbose');
    }
    
    if($::gSourceFilePath && $::gSourceFilePath ne ''){
        push(@instrumentArgs, '--srcdir "' . $::gSourceFilePath . '"');
    }

    if($::gSourceFileDest && $::gSourceFileDest ne ''){
        push(@instrumentArgs, '--destdir "' . $::gSourceFileDest . '"');
    }

    if($::gInitString && $::gInitString ne ''){
        push(@instrumentArgs, '--initstring "' . $::gInitString . '"');
    }

    #generate the command to execute in console
    $props{'cloverInstrumentCommandLine'} =  join(' ', @instrumentArgs);

    #set the properties into the Electric Commander
    setProperties(\%props);
    
}

  
  ########################################################################
  # setProperties - set a group of properties into the Electric Commander
  #
  # Arguments:
  #   -propHash: hash containing the ID and the value of the properties 
  #              to be written into the Electric Commander
  #
  # Returns:
  #   -nothing
  #
  ########################################################################
  sub setProperties($) {
   
      my ($propHash) = @_;
      
      # get an EC object
      my $ec = new ElectricCommander();
      $ec->abortOnError(0);
      
      foreach my $key (keys % $propHash) {
          my $val = $propHash->{$key};
          $ec->setProperty("/myCall/$key", $val);
      }
  }
  
  ########################################################################
  # registerReports - creates a link for registering the generated report
  # in the job step detail
  #
  # Arguments:
  #   -reportFilename: name of the archive which will be linked to the job detail
  #   -reportName: name which will be given to the generated linked report
  #
  # Returns:
  #   -none
  #
  ########################################################################
  sub registerReports($){
      
      my ($reportFilename, $reportName) = @_;
      
      if($reportFilename && $reportFilename ne ''){	
      	
          # get an EC object
          my $ec = new ElectricCommander();
          $ec->abortOnError(0);
          
          $ec->setProperty("/myJob/artifactsDirectory", "");
          		
          $ec->setProperty("/myJob/report-urls/" . $reportName, 
     		"jobSteps/$[jobStepId]/" . $reportFilename);
      		
      }
            
  }
  
  main();
   
  1;
