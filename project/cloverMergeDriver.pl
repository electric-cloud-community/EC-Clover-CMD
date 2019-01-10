# -------------------------------------------------------------------------
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
       
       PLUGIN_NAME => 'EC-Clover-CMD',
       JAVA_EXEC_NAME => 'java',
       
};
  
# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
my $ec = ElectricCommander->new();
$ec->abortOnError(0);

$::gJavaPath                = ($ec->getProperty( "javapath" ))->findvalue('//value')->string_value;
$::gClasspath               = ($ec->getProperty( "classpath" ))->findvalue('//value')->string_value;
$::gAdditionalMergeCommands = ($ec->getProperty( "additionalmergecommands" ))->findvalue('//value')->string_value;
$::gMergeMainClass          = ($ec->getProperty( "mergemainclass" ))->findvalue('//value')->string_value;
$::gInitString              = ($ec->getProperty( "initstring" ))->findvalue('//value')->string_value;
$::gEnableVerbosity         = ($ec->getProperty( "verbose" ))->findvalue('//value')->string_value;
$::gUpdateResults           = ($ec->getProperty( "update" ))->findvalue('//value')->string_value;
$::gNewDbFiles              = ($ec->getProperty( "dbfilestomerge" ))->findvalue('//value')->string_value;


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
    my @mergeArgs = ();
    
    #properties' map
    my %props;

    #filling all necessary info for the merge command line
    
    #setting the executable
    my $exec = '';
    
    if($::gJavaPath && $::gJavaPath ne ''){
        $exec .= $::gJavaPath ;
    }
    
    push(@mergeArgs, $exec);
    
    
    #set the classpath
    if($::gClasspath && $::gClasspath ne '') {
        push(@mergeArgs, '-cp "' . $::gClasspath . '"');
    }
    
    #insert into the command array the main class to use
    push(@mergeArgs, $::gMergeMainClass);
    
    #additional commands for each program
    if($::gAdditionalMergeCommands  && $::gAdditionalMergeCommands  ne '') {
        foreach my $command (split(' +', $::gAdditionalMergeCommands)) {
            push(@mergeArgs, $command);
        }
    }    
    
    push(@mergeArgs, '--initstring ' . $::gInitString);
    
    if($::gEnableVerbosity && $::gEnableVerbosity ne ''){
        push(@mergeArgs, '--verbose');
    }
    
    if($::gUpdateResults && $::gUpdateResults ne ''){
        push(@mergeArgs, '--update');
    }
    
    #insert dbfile
    push(@mergeArgs, $::gNewDbFiles);
    
    #generate the command to execute in console
    $props{'cloverMergeCommandLine'} = join(' ', @mergeArgs);
    
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
