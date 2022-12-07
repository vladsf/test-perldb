#!/usr/bin/perl -w
use strict;
use Data::Dumper;
our ($VER, $DEBUG, %DB, @SNAPSHOTS);

$DEBUG = 0;
$VER = '0.01'; 
%DB = ();
@SNAPSHOTS = ();

print "perldb server $VER. Type 'end' or Ctrl-D to exit.\n";
while (<STDIN>) {
	chomp;
	print "Read: $_\n" if $DEBUG;
	print db_get($_)."\n" if m/^get\s+/i;
	print db_set($_)."\n" if m/^set\s+/i;
	print db_unset($_)."\n" if m/^unset\s+/i;
	print db_find($_)."\n" if m/^find\s+/i;
	print db_counts($_)."\n" if m/^counts\s+/i;
	db_begin() if m/^begin/i;
	db_commit() if m/^commit/i;
	db_rollback() if m/^rollback/i;
	last if m/^end/i;
}

print Dumper(\@SNAPSHOTS) if $DEBUG;

print "End.\n";
exit 0;

sub db_begin {
    my %snapshot = %DB;
    push(@SNAPSHOTS, \%snapshot);
}

sub db_rollback {
    my $snapshot = pop(@SNAPSHOTS);
    %DB = %{$snapshot} if defined $snapshot;
    return;
}

sub db_commit {
    @SNAPSHOTS = ();
    return "OK";
}

sub db_get { 
	my $str = shift; 
	my ($cmd, $var) = split(/\s+/, $str);
	return defined $DB{$var} ? $DB{$var} : 'NULL';
}

sub db_set { 
	my $str = shift;
	my ($cmd, $var, $val) = split(/\s+/, $str);
	$DB{$var} = $val;
	return $val;
}

sub db_unset {
	my $str = shift; 
	my ($cmd, $var) = split(/\s+/, $str);
	undef $DB{$var};
	return "";
}

sub db_counts {
	my $str = shift; 
    my $count = 0;
	my ($cmd, $val) = split(/\s+/, $str);
	foreach (values %DB) { $count++ if $val == $_; }
	return $count;
}

sub db_find {
	my $str = shift; 
    my @vars;
	my ($cmd, $val) = split(/\s+/, $str);
	foreach (keys %DB) { push(@vars, $_) if $val == $DB{$_}; }
	return join(",", sort @vars);
}

# vim: set et ts=4 sw=4 ai sr tw=78 backspace=indent,eol,start:
