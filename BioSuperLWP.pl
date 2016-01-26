#!/usr/bin/env perl

# BioSuper web server standalone script
#
# http://ablab.ucsd.edu/BioSuper
#
# Author: Manuel Rueda Ph.D.
# University of California, San Diego
# Skaggs School of Pharmacy & Pharmaceutical Sciences
# 9500 Gilman Drive, MC 0747
# La Jolla, CA  92093-0747
# mrueda@scripps.edu
#
# Latest version: 1.1
#
# Notes:
#
# This is an example "generic" script. The user must replace
# the input parameters (see below) according to the naming of
# the files to compare.
#
# The script works either with "PDB IDs" or "PDB text files"
# To work with "PDB IDs" modify proteinRefPDB / proteinTarPDB parameters
# To work with "PDB text files"  modify proteinRefFile / proteinTarFile parameters
#
# For multiple BioSuper CGI executions we recommend these two options:
#
# i/  Use a loop from an external Linux shell script
#     (e.g., 'foreach' in TCSH, or 'for' in BASH).
#     The values of the POST paramaters must
#     be replaced. You can use 'sed' from outside,
#     or you may enter them as a Perl arguments (e.g., $ARGV[0], etc)
#
# ii/ Use a for loop inside this script which consists of
#     the names for the 'target' files to be compared
#
# PS: Please, do not abuse the web server
#     Run your calculations sequentially if possible. Thanks!
#     Do not hesitate to contact the author in case you get any error

use strict;
use LWP::UserAgent;
use HTTP::Request::Common qw(POST);

my $ua       = new LWP::UserAgent;
my $url      = 'http://wwww-ablab.ucsd.edu/BioSuper';
my $biosuper = $url . '/index.cgi';

# START HERE FOR LOOP WITH TARGET LIST <- OPTIONAL USER MODIFICATION

# Send form to the BioSuper Home page
my $req = POST $biosuper,
  Content_Type => 'form-data',
  Content      => [

    pageAction    => 'upload',
    newCode       => '23',
    MAX_FILE_SIZE => '6000000',

    #proteinRefFile => ["pdb1.pdb"],    #<- USER MODIFICATION
    #proteinTarFile => ["pdb2.pdb"],    #<- USER MODIFICATION

    proteinRefPDB => '1agi',    #<- USER MODIFICATION
    chainsRefPDB  => 'a',       #<- USER MODIFICATION
    proteinTarPDB => '1crn',    #<- USER MODIFICATION
    chainsTarPDB  => 'a',       #<- USER MODIFICATION

    atomSel  => 'ca',           #<- USER MODIFICATION
    bioUnits => 'no',           #<- USER MODIFICATION
    sp       => 'standard',     #<- USER MODIFICATION

    #sp            => 'weighted'
    #sp            => 'structural'
    #sp            => 'standard weighted structural',

    seqId    => '95.0',         #<- USER MODIFICATION
    ordAdjCh => 'no'            #<- USER MODIFICATION

  ];

die "Couldn't get $biosuper" unless defined $req;

##############################################################
# DO NOT TOUCH CODE BELOW UNLESS YOU KNOW WHAT YOU ARE DOING #
##############################################################

# Retrieve the content as a string
my $BioSuper_page_one = $ua->request($req)->as_string;

# Parse results to catch the final page
my ( $id_job, $link_page_two ) = ('') x 2;
while ( $BioSuper_page_one =~
    m/http:\/\/wwww-ablab.ucsd.edu\/BioSuper\/data\/(\d+)\//gi )
{
    $id_job = $1;    # The Id of the job
}
die "Couldn't get the Id Job URL" unless defined $id_job;

$link_page_two = $url . '/data/' . $id_job . '/BioSuper.html';

# Wait N seconds (the larger the protein the larger the wait)
sleep 5;             #<- OPTIONAL USER MODIFICATION

# Now we retrieve the actual results from the results page
# and we parse the results from the HTML
my $BioSuper_results = $ua->get($link_page_two)->as_string;
die "Couldn't get $link_page_two" unless defined $BioSuper_results;

my $req2 = POST $link_page_two, [];
die "Couldn't get $link_page_two" unless defined $req2;

my @BioSuper_results_lines = split /\n/, $BioSuper_results;
my $results_summary = '';
foreach (@BioSuper_results_lines) {
    $results_summary = $results_summary . $_ . "\n"
      if /Standard RMSD|Weighted RMSD|Structural RMSD/;
}

print "Id Job: $id_job\n";
$results_summary =~ s/\(\&#8491\)//g;
$results_summary =~
s#<a data-target="\#myModal-(...)" href="(\w+).html" role="button" data-toggle="modal"><i class="icon-eye-open"></i></a>##g;
$results_summary =~ s/<(\/)?td>//g;
die "Something went wrong, please check the nomenclature of your files\n"
  unless ( defined $id_job and defined $results_summary );
print $results_summary;

##################################################################
# DO NOT TOUCH the UPPER CODE UNLESS YOU KNOW WHAT YOU ARE DOING #
##################################################################

# END HERE FOR LOOP WITH TARGET LIST <- OPTIONAL USER MODIFICATION
