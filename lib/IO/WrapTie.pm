package IO::WrapTie;

# SEE DOCUMENTATION AT BOTTOM OF FILE

require 5.004;              # for tie
use Symbol qw(gensym);
use strict;
use vars qw($AUTOLOAD);

#------------------------------
# new IO_CLASS, IO_NEW_ARGS...
#------------------------------
# Class method.
#
# Notes:
# The thing $x we return must be a BLESSED REF, for ($x->print())...
# The underlying symbol must be a FILEHANDLE, for (print $x "foo")...
# It has to have a way of getting to the "real" back-end object...
#
sub new {
    my ($class, $io_class, @io_new_args) = @_;

    # Create $BARE, a new symbol we'll use for a unique filehandle name:
    my $BARE = gensym();

    # Create the back-end IO object by the act of tying $BARE to 
    # a new instance of IO_CLASS, where IO_CLASS must implement...
    #   (1) the tie methods: TIEHANDLE, PRINT, READLINE, etc.
    #   (2) the IO::Handle methods: print(), seek(), tell(), etc.
    tie *$BARE, $io_class, @io_new_args or die "tie [$io_class] failed";

    # Bless the glob into our class, giving us a blessed globref... that
    # should make it behave like a "real" filehandle object.
    # Then return that blessed-ref-to-a-tied-symbol-glob thingamajig:
    bless \*$BARE, $class;
}

#------------------------------
# AUTOLOAD
#------------------------------
# Automatically compiles a delegation method.
#
sub AUTOLOAD {
    my $method = $AUTOLOAD; 
    $method =~ s/.*:://;
    eval "sub $method { my \$s = shift; tied(*\$s)->$method(\@_) }";
    goto &$AUTOLOAD;
}


#------------------------------------------------------------
# IO::WrapTie::Mixin;
#------------------------------------------------------------
# Teeny private class providing a constructor...

package IO::WrapTie::Mixin;
sub new_tie {
    IO::WrapTie->new(@_);
}


#------------------------------
1;
__END__
package IO::WrapTie;      # for doc generator


=head1 NAME

IO::WrapTie - wrap tieable objects in IO::Handle interface


=head1 SYNOPSIS

First of all, you'll need tie(), so:

   require 5.004;

Use this with any existing class...

   use IO::WrapTie;
   use FooHandle;         # this is *not* an IO::Handle subclass (see below)
    
   # Assuming we want a "FooHandle->new(&FOO_RDWR, 2)", we can instead say...
   $FH = IO::WrapTie->new('FooHandle', &FOO_RDWR, 2);
   
   # Look, ma!  It works just like a real IO::Handle!  
   print $FH "Hello, ";            # traditional indirect-object syntax
   $FH->print("world!\n");         # OO syntax
   print $FH "Good", "bye!\n";     # traditional 
   $FH->seek(0, 0);                # OO
   @lines = <$FH>;                 # traditional (get the picture...?)


Or inherit from it to get a nifty new_tie() constructor...

   package FooHandle;     # this is *not* an IO::Handle subclass (see below)
   use IO::WrapTie;
   @ISA = qw(IO::WrapTie::Mixin);
   ...
   
   package main;    
   $FH = FooHandle->new_tie(&FOO_RDWR, 2);
   print $FH "Hello, ";            # traditional indirect-object syntax
   $FH->print("world!\n");         # OO syntax
    

=head1 DESCRIPTION

Suppose you have a class C<FooHandle>, where...

=over 4

=item *

FooHandle does I<not> inherit from IO::Handle; that is, it performs
filehandle-like I/O, but to something other than an underlying
file descriptor.  Good examples are IO::Scalar (for printing to a
string) and IO::Lines (for printing to an array of lines).

=item *

FooHandle implements the TIEHANDLE interface (see L<perltie>);
that is, it provides methods TIEHANDLE, GETC, PRINT, PRINTF,
READ, and READLINE.

=item *

FooHandle can be used in an ordinary OO-ish way via conventional
FileHandle- and IO::Handle-compatible methods like getline(), 
read(), print(), seek(), tell(), eof(), etc.

=back


Normally, users of your class would have two options:


=over 4

=item *

Use only OO syntax, and forsake named I/O operators like 'print'.

=item * 

Use with tie, and forsake treating it as a first-class object (i.e.,
class-specific methods can only be invoked through the underlying
object via tied()... giving the object a "split personality").

=back


But now with IO::WrapTie, you can say:

    $W = IO::WrapTie->new('FooHandle', &FOO_RDWR, 2);
    $W->print("Hello, world\n");   # OO syntax
    print $W "Yes!\n";             # Named operator syntax too!
    $W->weird_stuff;               # Other methods!

And if you're providing such a class, just inherit from 
C<IO::WrapTie::Mixin> and that first line becomes even prettier:

    $FH = FooHandle->new_tie(&FOO_RDWR, 2);

B<The bottom line:> now, almost any class can look and work exactly like
an IO::Handle... and be used both with OO and non-OO filehandle syntax.


=head1 NOTES

B<Why not simply use the object's OO interface?> 
    Because that means forsaking the use of named operators
like print(), and you may need to pass the object to a subroutine
which will attempt to use those operators:

    $O = FooHandle->new(&FOO_RDWR, 2);
    $O->print("Hello, world\n");  # OO syntax is okay, BUT....
    
    sub nope { print $_[0] "Nope!\n" }
 X  nope($O);                     # ERROR!!! (not a glob ref)
    

B<Why not simply use tie()?> 
    Because (1) you have to use tied() to invoke methods in the
object's public interface (yuck), and (2) you may need to pass 
the tied symbol to another subroutine which will attempt to treat 
it in an OO-way... and that will break it:

    tie *T, 'FooHandle', &FOO_RDWR, 2; 
    print T "Hello, world\n";     # Operator is okay, BUT... 
    
    tied(*T)->other_stuff;        # yuck! AND...
    
    sub nope { shift->print("Nope!\n") }
 X  nope(\*T);                    # ERROR!!! (method "print" on unblessed ref)


B<Why not simply write FooHandle to inherit from IO::Handle?>
    I tried this, with an implementation similar to that of IO::Socket.  
The problem is that I<the whole point is to use this with objects
that don't have an underlying file/socket descriptor.>.
Subclassing IO::Handle will work fine for the OO stuff, and fine with 
named operators I<if> you tie()... but if you just attempt to say:

    $IO = FooHandle->new(&FOO_RDWR, 2);
    print $IO "Hello!\n";

you get a warning from Perl like:

    Filehandle GEN001 never opened

because it's trying to do system-level i/o on an (unopened) file 
descriptor.  To avoid this, you apparently have to tie() the handle...
which brings us right back to where we started!  At least the
IO::WrapTie mixin lets us say:

    $IO = FooHandle->new_tie(&FOO_RDWR, 2);
    print $IO "Hello!\n";

and so is not I<too> bad.  C<:-)>


=head1 WARNINGS

B<Be aware that C<new_tie()> always returns an instance of IO::WrapTie...>
it does B<not> return an instance of the i/o class you're tying to!  
All OO-like use of this IO::WrapTie object is handled by the AUTOLOAD
method, which for each message I<msg> simply creates a "delegator"
method IO::WrapTie::I<msg> that passes I<msg> on to the back-end
object... so it I<looks> like you're manipulating a "FooHandle" object
directly, but you're not.

I have not explored all the ramifications of this use of tie().
I<Here there be dragons>.


=head1 AUTHOR

Eryq (F<eryq@zeegee.com>).
President, Zero G Inc (F<http://www.zeegee.com>).

=cut
