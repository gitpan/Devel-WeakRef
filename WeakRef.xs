/* Weak reference class. The constructor takes as argument a scalar
  which must be a reference. Returned is an opaque object which will
  return the original argument with the deref method, but does not tie
  up the reference count of the original. If all normal references to
  the original are removed, the object is collected, first voiding the
  pointer held by the weak reference.

  This type of object may be useful for implementing things like
  doubly-linked lists, trees, or any other kind of circular
  structures, provided you can decide which links to make weak; or it
  may be helpful in implementing heuristic cache tables, where weak
  refs can be the values in a hash table, e.g.  */

#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef __cplusplus
}
#endif

/* Mark the cell as being voided. */

static int clean_up (SV *sv, MAGIC *mg) {
  SvIOK_off(mg->mg_obj);
  return 1;
}

static MGVTBL cleaner_upper = {NULL, NULL, NULL, NULL, clean_up};

static char *baseclass="Devel::WeakRef";

MODULE = Devel::WeakRef		PACKAGE = Devel::WeakRef

SV *
new(class,obj)
 char *		class
 SV *		obj
PREINIT:
 SV *		actual;
 MAGIC *	mg;
 SV *		cell;
CODE:
 if (!SvROK(obj))
     croak("Object %p must be a reference type!", obj);
 actual=SvRV(obj);
 /* Find the already-existent magic cell if there is one. Note that
    since we are applying magic to an SV of unknown origin it is
    necessary to search exactly for what we want, keying off the class
    name. */
 mg=mg_find(actual, '~');
 while (mg && (mg->mg_type != '~' || mg->mg_virtual != &cleaner_upper))
     mg=mg->mg_moremagic;
 if (mg) {
   /* All set. */
   cell=mg->mg_obj;
 } else {
   /* Add a new tilde entry with an SVIV pointing to ourself. */
   cell=sv_2mortal(newSViv((I32)actual)); /* raw pointer! */
   sv_magic(actual, cell, '~', baseclass, strlen(baseclass));
   mg=mg_find(actual, '~');
   mg->mg_virtual=&cleaner_upper;
 }
 /* Ref counting of everything else is completely normal. */
 RETVAL=sv_bless(newRV_inc(cell), gv_stashpv(class, 1));
OUTPUT:
 RETVAL

SV *
deref(self)
 SV *		self
PREINIT:
 SV *		value;
CODE:
 if (!SvROK(self))
     croak("%p not a reference to deref!", self);
 if (!sv_isa(self, baseclass))
     croak("%p not a %s object!", self, baseclass);
 value=SvRV(self);
 /* We use the IOK flag to determine if the cell has been
    voided. Using zero would have worked as well. */
 if (SvIOK(value)) {
   RETVAL=newRV_inc((SV *)SvIV(value));
 } else {
   RETVAL=newSVsv(&sv_undef);
 }
OUTPUT:
 RETVAL

int
empty(self)
 SV *		self
CODE:
 if (!SvROK(self))
     croak("%p not a reference to empty!", self);
 if (!sv_isa(self, baseclass))
     croak("%p not a %s object!", self, baseclass);
 RETVAL=!SvIOK(SvRV(self));
OUTPUT:
 RETVAL
