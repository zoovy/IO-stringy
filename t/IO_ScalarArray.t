use lib "./t", "./lib";
use IO::ScalarArray;
use Checker;

$Checker::OUTPUT = 0;
print STDERR "\n";
print STDERR "\tTesting basic OO interface...\n";

# Set the counter:
print "1..", (($] >= 5.004) ? 15 : 12), "\n";

my @LIMERICKA = (
		 "A diner while ",
		 "dining at Crewe\n",
		 "Found a rather large ",
		 "mouse in his stew\n   Said the waiter, \"Don't shout,\n",
		 "   And ",
		 "wave it about..."
		 );
my $LIMERICK = join "", @LIMERICKA;
my $LIMERICKFULL = $LIMERICK . "\nor the rest will be wanting one too.\"\n";

sub hrule   {print '.','-'x30,"\n| $_[0]\n", '`','-'x30,"\n"}
sub present {print "I GOT: <<", @_, ">>\n";}
my $BUF = '';



# 1: Open a scalar on a string:
my $SH = IO::ScalarArray->new(\@LIMERICKA);
check $SH, 
    "open a scalar on a ref to a string";

# 2: Append with print
$SH->print("\nor the rest");
$SH->print(" will be wanting one ", 
           "too.\"\n");
check((join('',@LIMERICKA) eq $LIMERICKFULL), 
      "append to string with print");

# 3: Seek and getline:
$SH->seek(3,0);
$_ = $SH->getline;	
### print STDERR "<<$_>>\n";
check(($_ eq "iner while dining at Crewe\n"), 
      "seek(3,START) and getline() gets part of 1st line");

# 4: Subsequent getline:
$_ = $SH->getline;	
check(($_ eq "Found a rather large mouse in his stew\n"), 
      "getline() gets subsequent line");

# 5: EOF:
$_ = $SH->getline;
$_ = $SH->getline;
$_ = $SH->getline;
$_ = $SH->getline;
check(!$_,
      "repeated getline() finds end of stream");

# 6: getlines
$SH->seek(0,0);
my $t6 = join('', $SH->getlines);
check(($t6 eq $LIMERICKFULL),
      "seek(0,0) and getlines() slurps in string");

# 7: read:
$SH->seek(0,0);
$SH->read($BUF,10);
check (($BUF eq "A diner wh"),
       "reading first 10 bytes with seek(0,START) + read(10)");

# 8: read:
$SH->read($BUF,10);
check (($BUF eq "ile dining"),
       "reading next 10 bytes with read(10)");

# 9: tell:
$_ = $SH->tell;
check(($_ == 20),
      "tell() the current location as 20 ($_)");

# 10: slurp:
$SH->seek(0,0);
$SH->read($BUF,1000);
check(($BUF eq $LIMERICKFULL),
      "seek(0,START) + read(1000) reads in whole string");

if (0) { 
# 11:
$SH->seek(-6,2);
$SH->read($BUF,3);
check(($BUF eq 'too'),
      "seek(-6,END) + read(3) returns 'too'");
}
check 1, "bogus";

if (0) {
# 12:
$SH->seek(-3,1);
$SH->read($BUF,3);
present $BUF;
check(($BUF eq 'too'), 
      "seek(-3,CUR) + read(3) returns 'too' again");
}
check 1, "bogus";


if ($] >= 5.004) {
    print STDERR "\tTesting TIEHANDLE interface...\n";

    # 13:
    my @a; 
    tie *OUT, 'IO::ScalarArray', \@a;
    print OUT "line 1\nline 2\n", "line 3";
    my $s = join '', @a;
    check(($s eq "line 1\nline 2\nline 3"), 
	  "tied handle: print");

    # 14:
    tied(*OUT)->seek(0,0);
    my @lines;
    while (<OUT>) { push @lines, $_ }  
    check(($lines[1] eq "line 2\n"),
	  "tied handle: setpos and scalar <> gets expected lines");

    # 15:
    tied(*OUT)->seek(0,0);
    @lines = <OUT>;
    check(((join '', @lines) eq "line 1\nline 2\nline 3"),
	  "tied handle: setpos and array <> slurps in string");

}

# So we know everything went well...






