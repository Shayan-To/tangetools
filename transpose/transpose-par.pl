#!/usr/bin/perl

use Text::CSV;
use File::Temp qw(tempfile tempdir);

my $csv;
my (@table);
my $first_line = 1;
my $col = 0;
while(my $l = <>) {
    if($first_line) {
	my $csv_setting = guess_csv_setting($l);
	$csv = Text::CSV->new($csv_setting)
	    or die "Cannot use CSV: ".Text::CSV->error_diag ();
	$first_line = 0;
    }
    if(not $csv->parse($l)) {
	die "CSV has unexpected format";
    }
    # append to each row
    my $row = 0;
    
    for($csv->fields()) {
	$table[$row][$col] = defined($_) ? $_ : '';
	$row++;
    }
    $col++;
}

print map { join("\t",@$_),"\n" } @table;

sub guess_csv_setting {
    # Based on two lines guess the csv_setting
    my $line = shift;
    # Potential field separators
    # Priority:
    # \0 if both lines have the same number
    # \t if both lines have the same number
    my @fieldsep = (",", "\t", "\0", ":", ";", "|", "/");
    my %count;
    @count{@fieldsep} = (0,0,0,0,0,0);
    # Count characters
    map { $count{$_}++ } split //,$line;
    my @sepsort = sort { $count{$b} <=> $count{$a} } @fieldsep;
    my $guessed_sep;
    if($count{"\0"} > 0) {
	# \0 is in the line => this is definitely the field sep
	$guessed_sep = "\0";
    } elsif($count{"\t"} > 0) {
	# \t is in the line => this is definitely the field sep
	$guessed_sep = "\t";
    } else {
	$guessed_sep = $sepsort[0];
    }
    return { binary => 1, sep_char => $guessed_sep };
}

sub _guess_csv_setting {
    # Try different csv_settings
    # Return a $csv object with the best setting
    my @csv_file_types = 
	( { binary => 1, sep_char => "\0" },
	  { binary => 1, sep_char => "\t" },
	  { binary => 1, sep_char => "," },
	  { binary => 1 },
	);

    my $succesful_csv_type;
    my $csv;
    for my $csv_file_type (@csv_file_types) {
	$csv = Text::CSV->new ( $csv_file_type )
	    or die "Cannot use CSV: ($csv_file_type) ".Text::CSV->error_diag ();
	$succesful_csv_type = $csv_file_type;
	my $last_n_fields;
	for my $line (@lines) {
	    if($csv->parse($line)) {
		my $n_fields = ($csv->fields());
		$last_fields ||= $n_fields;
		
	    } else{
		$succesful_csv_type = 0;
		last;
	    }
	}
	
    }
    if(not $succesful_csv_type) {
	$csv->error_diag();
    }
    
    $csv = Text::CSV->new ( $succesful_csv_type )  # should set binary attribute.
	or die "Cannot use CSV: ".Text::CSV->error_diag ();
    return($csv);
}
