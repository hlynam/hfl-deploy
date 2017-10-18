#!/usr/bin/env perl
use warnings;

# The window name can:
# 1. equal 'vim': this is the window name after vim has exited
# Action: set a new window name
# 2. equal 'new-window': this is the window name when the window
# is first created by the user
# Action: set a new window name
# 3. end with ': vim': this is what this script uses as a suffix when setting
# the window name.
# Action: set a new window name
# 4. Any other title: the user has manually set the window name, we don't
# want to overwrite it
# Action: don't set a new window name
my $currentWindowName = qx/tmux display-message -p '#W'/;
if ($currentWindowName !~ '(^vim$|^new-window$|: vim$)') { 
	exit;
}

# Get basename of each filename from stdin
s;.*/;; for (my @filenames = (<>));

# Remove trailing newlines
chomp @filenames;

# Remove empty string filenames
# http://www.perlmonks.org/?node_id=124970
@filenames = grep { $_ ne '' } @filenames;

# Remove duplicates
# https://perlmaven.com/unique-values-in-an-array-in-perl
my @unique = do { my %seen; grep { !$seen{$_}++ } @filenames };
@filenames = @unique;

# Convert array into string
$windowName = join('; ', @filenames);

# Remove whitespace
$windowName =~ s/(^\s+)|(\s+$)//g;

$windowName = ($windowName ne '') ? $windowName . ' : vim' : 'vim';
system('tmux', 'rename-window', $windowName);

