package IO::Stringy;

use vars qw($VERSION);
$VERSION = substr q$Revision: 1.213 $, 10;

1;
__END__


=head1 NAME

IO-stringy - I/O on in-core objects like strings and arrays


=head1 SYNOPSIS

    IO::
    ::AtomicFile   adpO  Write a file which is updated atomically     ERYQ
    ::Lines        bdpO  I/O handle to read/write to array of lines   ERYQ
    ::Scalar       RdpO  I/O handle to read/write to a string         ERYQ
    ::ScalarArray  RdpO  I/O handle to read/write to array of scalars ERYQ
    ::Wrap         RdpO  Wrap old-style FHs in standard OO interface  ERYQ
    ::WrapTie      adpO  Tie your handles & retain full OO interface  ERYQ


=head1 DESCRIPTION

This toolkit primarily provides modules for performing both traditional 
and object-oriented i/o) on things I<other> than normal filehandles; 
in particular, L<IO::Scalar|IO::Scalar>, L<IO::ScalarArray|IO::ScalarArray>, 
and L<IO::Lines|IO::Lines>.

If you have access to tie(), these classes will make use of the
L<IO::WrapTie|IO::WrapTie> module to inherit a convenient new_tie() 
constructor.  It also exports a nice wraptie() function.

In the more-traditional IO::Handle front, we 
have L<IO::AtomicFile|IO::AtomicFile>
which may be used to painlessly create files which are updated
atomically.

And in the "this-may-prove-useful" corner, we have L<IO::Wrap|IO::Wrap>, 
whose exported wraphandle() function will clothe anything that's not
a blessed object in an IO::Handle-like wrapper... so you can just
use OO syntax and stop worrying about whether your function's caller
handed you a string, a globref, or a FileHandle.


=head1 INSTALLATION

You know the drill...

    perl Makefile.PL
    make test
    make install



=head1 VERSION

$Id: Stringy.pm,v 1.213 2000/08/16 04:59:02 eryq Exp $



=head1 CHANGE LOG 

=over 4


=item Version 1.213   (2000/08/16)

Minor documentation fixes.


=item Version 1.212   (2000/06/02)

Fixed IO::InnerFile incompatibility with Perl5.004.
I<Thanks to many folks for reporting this.>


=item Version 1.210   (2000/04/17)

Added flush() and other no-op methods.
I<Thanks to Doru Petrescu for suggesting this.>


=item Version 1.209   (2000/03/17)

Small bug fixes.


=item Version 1.208   (2000/03/14)

Incorporated a number of contributed patches and extensions,
mostly related to speed hacks, support for "offset", and
WRITE/CLOSE methods.


=item Version 1.206   (1999/04/18)

Added creation of ./testout when Makefile.PL is run.


=item Version 1.205   (1999/01/15)

Verified for Perl5.005.


=item Version 1.202   (1998/04/18)

New IO::WrapTie and IO::AtomicFile added.


=item Version 1.110   

Added IO::WrapTie.


=item Version 1.107   

Added IO::Lines, and made some bug fixes to IO::ScalarArray. 
Also, added getc().


=item Version 1.105   

No real changes; just upgraded IO::Wrap to have a $VERSION string.

=back




=head1 AUTHOR

Eryq (F<eryq@zeegee.com>).
President, ZeeGee Software Inc (F<http://www.zeegee.com>).

Enjoy.  Yell if it breaks.


=cut








