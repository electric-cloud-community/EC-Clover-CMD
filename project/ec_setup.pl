my %runCloverCmd = (
    label       => "Clover - Command",
    procedure   => "runCloverCmd",
    description => "Execute a Clover instrumented compile & test",
    category    => "Code Analysis"
);

my %runCloverInstr = (
    label       => "Clover - Instrumentation",
    procedure   => "runCloverInstr",
    description => "Copy and instrument individual java source files, or a directory of source files.",
    category    => "Code Analysis"
);

my %runCloverMerge = (
    label       => "Clover - Merge",
    procedure   => "runCloverMerge",
    description => "Merge existing Clover databases to allow for combined reports to be generated.",
    category    => "Code Analysis"
);

my %runCloverReport = (
    label       => "Clover - Report",
    procedure   => "runCloverReport",
    description => "Produce coverage reports in several formats.",
    category    => "Code Analysis"
);

$batch->deleteProperty("/server/ec_customEditors/pickerStep/Clover - Command");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/Clover - Instrumentation");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/Clover - Merge");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/Clover - Report");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/EC-Clover-CMD - runCloverCmd");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/EC-Clover-CMD - runCloverInstr");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/EC-Clover-CMD - runCloverMerge");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/EC-Clover-CMD - runCloverReport");

@::createStepPickerSteps = (\%runCloverCmd, \%runCloverInstr, \%runCloverMerge, \%runCloverReport);
