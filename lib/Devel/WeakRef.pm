package Devel::WeakRef;
use mods q{
  DynaLoader();
  [DynaLoader];
  # $Format: "  {$VERSION='$DevelWeakRefRelease$'}"$
  {$VERSION='0.001'}
};

bootstrap Devel::WeakRef $VERSION;

1;

__END__

=head1 NAME

B<Devel::WeakRef> - weak references (not reference-counted)

=head1 SYNOPSIS

 my $foo={a => 1, b => 2};	# Some sort of reference scalar.
 my $foo_=new Devel::WeakRef $foo;
 my $bar=$foo_->deref;		# Hard ref through dereference
 $foo_->deref->{c}=3;		# Dereference
 $foo=$bar=77;			# OK, hash collected
 $foo_->deref;			# Yields undef now
 $foo_->empty;			# True now.

=head1 DESCRIPTION

A weak reference maintains a "pointer" to an object (specified by a reference to it,
just like C<bless>) that does not contribute to the object's reference count; thus, the
object's storage will be freed (and its destructor invoked) when only weak references
remain to it. (It is fine to have multiple weak references to a single object.) The
B<deref> method derefences the weak reference. Dereferencing a weak reference whose
target has already been destroyed results in C<undef>.

B<empty> tests if the reference is invalid; C<$ref-E<gt>empty> is equivalent to
C<!defined $ref-E<gt>deref>.

The most likely applications of this are:

=over 4

=item Cyclic Structures

Various structures, like arbitrarily-traversable trees, or doubly-linked lists, or some
queues, naturally have cyclic pointer structures in them. If you are not very careful,
removing external references without breaking up the internal links will give you a
memory leak. With weak references, you need only be sure that there is no cyclic
structure of I<hard> (normal) references; back-links and other convenient links can
easily be made weak.

=item Caches

For some applications it is desirable to maintain a cache of lookups (search results)
keyed off (say) search string. The values might be some objects. To have these entries
removed when an object is destroyed, you want to leave each object's reference count
untouched (so it will be collected as it would have otherwise), and make sure its
destructor removes the appropriate keys from the caching table.

=back

=head1 AUTHORS

Jesse Glick, B<jglick@sig.bsh.com>.

=head1 BUGS

If you mess with the internal structure of a weak ref you will probably dump core.

Putting a weak ref on a reference object places extension-magic (C<~>, see
L<perlguts(1P)>) on that object. This could conflict with other user extensions using
custom magic. To avoid this, B<Devel::WeakRef> specifically looks for its own magic and
only its own magic; however, another extension might not do so for itself and become
extremely confused, if it was specifically looking for its own magic (probably not so
common).

There should be versions of the class to make weakly-referenced arrays and hashes,
mostly to conserve space and for notational convenience.

=cut
