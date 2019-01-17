# -------------------------------------------------------------------------
# Package
#    commandLineTemplate.pl
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
       JAVA_EXEC_NAME => 'java',
       
       REPORT_TYPE_CONSOLE => 'console',
       REPORT_TYPE_PDF => 'pdf',
       REPORT_TYPE_XML => 'xml',
       REPORT_TYPE_HTML => 'html',
       DEFAULT_HTML_DIR => 'clover_html',
       
       REPORT_NAME => 'Clover Coverage Result',
       
};
  
# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
my $ec = ElectricCommander->new();
$ec->abortOnError(0);

$::gJavaPath                = ($ec->getProperty( "javapath" ))->findvalue('//value')->string_value;
$::gClasspath                = ($ec->getProperty( "classpath" ))->findvalue('//value')->string_value;
$::gAdditionalReportCommands               = ($ec->getProperty( "additionalreportcommands" ))->findvalue('//value')->string_value;
$::gInitString                = ($ec->getProperty( "initstring" ))->findvalue('//value')->string_value;
$::gSourceFilePath               = ($ec->getProperty( "sourcefilepath" ))->findvalue('//value')->string_value;
$::gEnableVerbosity                = ($ec->getProperty( "verbose" ))->findvalue('//value')->string_value;
$::gReportType                 = ($ec->getProperty( "reporttype" ))->findvalue('//value')->string_value;
$::gOutputFile                = ($ec->getProperty( "outputfile" ))->findvalue('//value')->string_value;
$::gAlwaysReport                = ($ec->getProperty( "alwaysreport" ))->findvalue('//value')->string_value;


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
    
    # create args array
    my @reportingArgs = ();
    
    #properties' map
    my %props;
    
    #setting the executable
    my $exec = '';
    
    my $reportPath;
    
    if($::gJavaPath && $::gJavaPath ne ''){
        $exec .= $::gJavaPath;
    }
    
    push(@reportingArgs, $exec);
    
    #set the classpath
    #requires java 6, usage of wildcard in classpath dependency
    if($::gClasspath && $::gClasspath ne '') {
        push(@reportingArgs, '-cp "' . $::gClasspath . '"'); 
    }  
    
    my $reportingMainClass = '';
    
    #analyzing the report type to determine which main class will be used
    if($::gReportType eq REPORT_TYPE_CONSOLE){
        $reportingMainClass = 'com.cenqua.clover.reporters.console.ConsoleReporter';
    }elsif($::gReportType eq REPORT_TYPE_HTML){
        $reportingMainClass = 'com.cenqua.clover.reporters.html.HtmlReporter';
    }elsif($::gReportType eq REPORT_TYPE_XML){
        $reportingMainClass = 'com.cenqua.clover.reporters.xml.XMLReporter';
    }elsif($::gReportType eq REPORT_TYPE_PDF){
        $reportingMainClass = 'com.cenqua.clover.reporters.pdf.PDFReporter';
    }else{
        #not an expected report type value, cannot continue
        exit ERROR;
    }
    
    #insert into the command arrays the main classes to use
    push(@reportingArgs, $reportingMainClass); 
    
    #additional commands for each program    
    if($::gAdditionalReportCommands  && $::gAdditionalReportCommands  ne '') {
        foreach my $command (split(' +', $::gAdditionalReportCommands)) {
	    	push(@reportingArgs, $command);
		}
    }

    if($::gEnableVerbosity && $::gEnableVerbosity ne ''){
        push(@reportingArgs, '--verbose');
    }
    
    if($::gInitString && $::gInitString ne ''){
        push(@reportingArgs, '--initstring "' . $::gInitString . '"');
    }
    
    if($::gSourceFilePath && $::gSourceFilePath ne ''){
        push(@reportingArgs, '-p "' . $::gSourceFilePath . '"');
    }    
    
    if($::gAlwaysReport && $::gAlwaysReport ne ''){
        push(@reportingArgs, '-a');
    }     
    
    if($::gOutputFile && $::gOutputFile ne ''){
     
         #analyzing the report type to determine the correct parameter to add
         if($::gReportType eq REPORT_TYPE_HTML){
          
             push(@reportingArgs, '-o '. $::gOutputFile);
             
             $reportPath = $::gOutputFile . '/index.html';
             
             #register the report generated by the program
             registerReports($reportPath, REPORT_NAME);
             
         }elsif($::gReportType eq REPORT_TYPE_XML || $::gReportType eq REPORT_TYPE_PDF){
          
             push(@reportingArgs, '-o "' . $::gOutputFile . '"');
             
             $reportPath = $::gOutputFile;
             
             #register the report generated by the program
             registerReports($reportPath, REPORT_NAME);
             
         }

    }else{
     
         if($::gReportType eq REPORT_TYPE_HTML){
          
             push(@reportingArgs, '-o ' . DEFAULT_HTML_DIR);
             $reportPath = DEFAULT_HTML_DIR . '/index.html';
             
             #register the report generated by the program
             registerReports($reportPath, REPORT_NAME);
             
         }    
     
    }

    #generate the command to execute in console
    $props{'cloverReportingCommandLine'} = join(' ', @reportingArgs);
    
    
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
