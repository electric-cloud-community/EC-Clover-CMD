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

$::gCloverDir               = ($ec->getProperty( "clovercmddir" ))->findvalue('//value')->string_value;
$::gAdditionalInstrCommands = ($ec->getProperty( "additionalinstrcommands" ))->findvalue('//value')->string_value;
$::gAdditionalMergeCommands = ($ec->getProperty( "additionalmergecommands" ))->findvalue('//value')->string_value;
$::gMergeResults            = ($ec->getProperty( "merge" ))->findvalue('//value')->string_value;
$::gUpdateResults           = ($ec->getProperty( "update" ))->findvalue('//value')->string_value;
$::gReportType              = ($ec->getProperty( "reporttype" ))->findvalue('//value')->string_value;
$::gOutputFile              = ($ec->getProperty( "outputfile" ))->findvalue('//value')->string_value;
$::gCompileExec             = ($ec->getProperty( "compileexec" ))->findvalue('//value')->string_value;
$::gTestExec                = ($ec->getProperty( "testcaseexec" ))->findvalue('//value')->string_value;
$::gInitString              = ($ec->getProperty( "initstring" ))->findvalue('//value')->string_value;
$::gSourceFilePath          = ($ec->getProperty( "sourcefilepath" ))->findvalue('//value')->string_value;
$::gSourceFileDest          = ($ec->getProperty( "sourcefiledest" ))->findvalue('//value')->string_value;
$::gEnableVerbosity         = ($ec->getProperty( "verbose" ))->findvalue('//value')->string_value;
$::gAlwaysReport            = ($ec->getProperty( "alwaysreport" ))->findvalue('//value')->string_value;
$::gJavaPath                = ($ec->getProperty( "javapath" ))->findvalue('//value')->string_value;


# -------------------------------------------------------------------------
# Main functions
# -------------------------------------------------------------------------


########################################################################
# main - contains the whole process to be done by the plugin, it builds 
#        the command line, sets the properties and the working directory
#
# Arguments:
#   None
#
# Returns:
#   none
#
########################################################################
sub main() {
    
    # create args arrays
    my @instrumentArgs = ();
    my @javacArgs = ();
    my @mergeArgs = ();
    my @testArgs = ();
    my @reportingArgs = ();
    
    #properties' map
    my %props;
    
    #setting the executables
    push(@instrumentArgs, $::gJavaPath);
    push(@javacArgs, JAVA_COMPILER_NAME);
    push(@reportingArgs, $::gJavaPath);    
    
    #set the classpaths
    #requires java 6, usage of wildcard in classpath dependency
    if($::gCloverDir && $::gCloverDir ne '') {
        push(@instrumentArgs, '-cp "' . $::gCloverDir . '"');
        push(@reportingArgs, '-cp "' . $::gCloverDir . '"'); 
    }  
    
    my $instrumentMainClass = 'com.cenqua.clover.CloverInstr';
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
    push(@instrumentArgs, $instrumentMainClass);
    push(@reportingArgs, $reportingMainClass); 
    
    #additional commands for each program    
    if($::gAdditionalInstrCommands  && $::gAdditionalInstrCommands  ne '') {
        foreach my $command (split(' +', $::gAdditionalInstrCommands)) {
	    	push(@instrumentArgs, $command);
		}
    }

    if($::gEnableVerbosity && $::gEnableVerbosity ne ''){
        push(@instrumentArgs, '--verbose');
        push(@reportingArgs, '--verbose');
    }
    
    if($::gSourceFilePath && $::gSourceFilePath ne ''){
        push(@instrumentArgs, '--srcdir "' . $::gSourceFilePath . '"');
    }

    if($::gSourceFileDest && $::gSourceFileDest ne ''){
        push(@instrumentArgs, '--destdir "' . $::gSourceFileDest . '"');
    }

    if($::gInitString && $::gInitString ne ''){
        push(@instrumentArgs, '--initstring "' . $::gInitString . '"');
        push(@reportingArgs, '--initstring "' . $::gInitString . '"');
    }
    
    #merging result required?
    if($::gMergeResults && $::gMergeResults ne ''){
     
        #filling all necessary info for the merge command line
        
        push(@mergeArgs, JAVA_EXEC_NAME);
        
        #set the classpath
        if($::gCloverDir && $::gCloverDir ne '') {
            push(@mergeArgs, '-cp "' . $::gCloverDir . '"');
        }
        
        #main class to use
        my $mergeMainClass = 'com.cenqua.clover.CloverMerge';
        
        #insert into the command array the main class to use
        push(@mergeArgs, $mergeMainClass);
        
        #additional commands for each program
        if($::gAdditionalMergeCommands  && $::gAdditionalMergeCommands  ne '') {
            foreach my $command (split(' +', $::gAdditionalMergeCommands)) {
    	    	push(@mergeArgs, $command);
    	    }
        }    
        
        my $newMergedDatabase = '--initstring new.db';
        
        push(@mergeArgs, $newMergedDatabase);
        
        if($::gEnableVerbosity && $::gEnableVerbosity ne ''){
            push(@mergeArgs, '--verbose');
        }
        
        if($::gUpdateResults && $::gUpdateResults ne ''){
            push(@mergeArgs, '--update');
        }
        
        my $databaseToMerge = $::gInitString;
        
        #insert dbfile
        push(@mergeArgs, $databaseToMerge);
     
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
          
             push(@reportingArgs, '-o htmlReport');
             
         }elsif($::gReportType eq REPORT_TYPE_XML || $::gReportType eq REPORT_TYPE_PDF){
          
             push(@reportingArgs, '-o "' . $::gOutputFile . '"');
             
         }

    }else{
     
         if($::gReportType eq REPORT_TYPE_HTML){
          
             push(@reportingArgs, '-o htmlReport');
             
         }    
     
    }

    #register the report generated by the program
    registerReports();

    #generate the command to execute in console
    $props{'instrumentCommandLine'} = join(' ', @instrumentArgs);
    $props{'compileCommandLine'} = $::gCompileExec;
    $props{'mergeCommandLine'} = join(' ', @mergeArgs);
    $props{'testCommandLine'} = $::gTestExec;
    $props{'reportingCommandLine'} = join(' ', @reportingArgs);
    
    
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
#   none
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
#   None
#
# Returns:
#   none
#
########################################################################
sub registerReports(){
 
    # get an EC object
    my $ec = new ElectricCommander();
    $ec->abortOnError(0);
 
    $ec->setProperty("/myJob/artifactsDirectory", '');
    
    if($::gReportType eq REPORT_TYPE_HTML){
     
         #html report option generates a directory instead of a single file
         $ec->setProperty("/myJob/report-urls/Clover Coverage Result", 
          "jobSteps/$[jobStepId]/htmlReport/index.html");
          
    }elsif($::gOutputFile ne ''){
     
        my $fileName = '';
        my $fileIndex = rindex($::gOutputFile, '/');
        
        if($fileIndex == -1){
         
           $fileIndex = (rindex($::gOutputFile, '\\'));
         
        }
        
        if($fileIndex == -1){
         
            $fileName = $::gOutputFile;
         
        }else{
         
            $fileName = substr($::gOutputFile, $fileIndex+1, length($::gOutputFile)-$fileIndex);
         
        }
        
        $ec->setProperty("/myJob/report-urls/Clover Coverage Result", 
              "jobSteps/$[jobStepId]/" . $fileName);
     
    }     

}

main();

