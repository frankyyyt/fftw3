dnl @synopsis AX_GCC_ARCHFLAG(PORTABLE?, [ACTION-SUCCESS], [ACTION-FAILURE])
dnl
dnl This macro tries to guess the "native" arch corresponding to
dnl the host architecture for use with gcc's -march=arch or -mtune=arch
dnl flags.  If found, the cache variable $ax_cv_gcc_archflag is set to this
dnl flag and ACTION-SUCCESS is executed; otherwise $ax_cv_gcc_archflag is
dnl is set to "unknown" and ACTION-FAILURE is executed.  The default
dnl ACTION-SUCCESS is to add $ax_cv_gcc_archflag to the end of $CFLAGS.
dnl
dnl PORTABLE? should be either [yes] (default) or [no].  In the former case,
dnl the flag is set to -mtune (or equivalent) so that the architecture
dnl is only used for tuning, but the instruction set used is still
dnl portable.  In the latter case, the flag is set to -march (or equivalent)
dnl so that architecture-specific instructions are enabled.
dnl
dnl The user can specify --with-gcc-arch=<arch> in order to override
dnl the macro's choice of architecture, or --without-gcc-arch to
dnl disable this.
dnl
dnl When cross-compiling, or if $CC is not gcc, then ACTION-FAILURE is
dnl called unless the user specified --with-gcc-arch manually.
dnl
dnl Requires macros: AX_CHECK_COMPILER_FLAGS, AX_GCC_X86_CPUID
dnl
dnl @version $Id: ax_gcc_archflag.m4,v 1.12 2005-01-13 22:59:55 stevenj Exp $
dnl @author Steven G. Johnson <stevenj@alum.mit.edu> and Matteo Frigo.
AC_DEFUN([AX_GCC_ARCHFLAG],
[AC_REQUIRE([AC_PROG_CC])
AC_REQUIRE([AC_CANONICAL_HOST])

AC_ARG_WITH(gcc-arch, [AC_HELP_STRING([--with-gcc-arch=<arch>], [use architecture <arch> for gcc -march/-mtune, instead of guessing])], 
	ax_gcc_arch=$withval, ax_gcc_arch=yes)

AC_MSG_CHECKING([for gcc architecture flag])
AC_MSG_RESULT([])
AC_CACHE_VAL(ax_cv_gcc_archflag,
[
ax_cv_gcc_archflag="unknown"

if test "$GCC" = yes -a "$cross_compiling" = no; then

if test "x$ax_gcc_arch" = xyes; then
ax_gcc_arch=""
case $host_cpu in
  i386*) ax_gcc_arch=i386 ;;
  i486*) ax_gcc_arch=i486 ;;
  i[[56]]86*) # use cpuid codes, extracted from x86info-1.7 by Dave Jones
     AX_GCC_X86_CPUID(0)
     AX_GCC_X86_CPUID(1)
     case $ax_cv_gcc_x86_cpuid_0 in
       *:756e6547:*:*) # Intel
          case $ax_cv_gcc_x86_cpuid_1 in
	    *5[[48]]?:*:*:*) ax_gcc_arch="pentium-mmx pentium" ;;
	    *5??:*:*:*) ax_gcc_arch=pentium ;;
	    *6[[3456]]?:*:*:*) ax_gcc_arch="pentium2 pentiumpro" ;;
	    *6a?:*[[01]]:*:*) ax_gcc_arch="pentium2 pentiumpro" ;;
	    *6a?:*[[234]]:*:*) ax_gcc_arch="pentium3 pentiumpro" ;;
	    *6[[789b]]?:*:*:*) ax_gcc_arch="pentium3 pentiumpro" ;;
	    *6??:*:*:*) ax_gcc_arch=pentiumpro ;;
            *f33:*:*:*) ax_gcc_arch="prescott pentium4 pentiumpro";;
            *f34:*:*:*) ax_gcc_arch="nocona prescott pentium4 pentiumpro";;
            *f??:*:*:*) ax_gcc_arch="pentium4 pentiumpro";;
          esac ;;
       *:68747541:*:*) # AMD
          case $ax_cv_gcc_x86_cpuid_1 in
	    *5[[67]]?:*:*:*) ax_gcc_arch=k6 ;;
	    *5[[8c]]?:*:*:*) ax_gcc_arch="k6-2 k6" ;;
	    *5[[9d]]?:*:*:*) ax_gcc_arch="k6-3 k6" ;;
	    *60?:*:*:*) ax_gcc_arch=k7 ;;
	    *6[[12]]?:*:*:*) ax_gcc_arch="athlon k7" ;;
	    *6[[34]]?:*:*:*) ax_gcc_arch="athlon-tbird k7" ;;
	    *67?:*:*:*) ax_gcc_arch="athlon-4 athlon k7" ;;
	    *6[[68]]?:*:*:*) 
	       AX_GCC_X86_CPUID(0x80000006) # L2 cache size
	       case $ax_cv_gcc_x86_cpuid_0x80000006 in
                 *:*:*[[1-9a-f]]??????:*) # (L2 = ecx >> 16) >= 256
			ax_gcc_arch="athlon-xp athlon-4 athlon k7" ;;
                 *) ax_gcc_arch="athlon-4 athlon k7" ;;
	       esac ;;
	    *f[[4cef8b]]?:*:*:*) ax_gcc_arch="athlon64 k8" ;;
	    *f5?:*:*:*) ax_gcc_arch="opteron k8" ;;
	    *f??:*:*:*) ax_gcc_arch="k8" ;;
          esac ;;
	*:746e6543:*:*) # IDT
	   case $ax_cv_gcc_x86_cpuid_1 in
	     *54?:*:*:*) ax_gcc_arch=winchip-c6 ;;
	     *58?:*:*:*) ax_gcc_arch=winchip2 ;;
	     *6[[78]]?:*:*:*) ax_gcc_arch=c3 ;;
	     *69?:*:*:*) ax_gcc_arch="c3-2 c3" ;;
	   esac ;;
     esac
     if test x"$ax_gcc_arch" = x; then # fallback
	case $host_cpu in
	  i586*) ax_gcc_arch=pentium ;;
	  i686*) ax_gcc_arch=pentiumpro ;;
        esac
     fi 
     ;;

  sparc*)
     case $host_os in
       *linux*)
          cputype=`grep cpu /proc/cpuinfo | head -n 1 | cut -d: -f2 | tr -d ' '`
	  case $cputype in
	    *UltraSparcIV*) ax_gcc_arch="ultrasparc4 ultrasparc v9" ;;
	    *UltraSparcIII*) ax_gcc_arch="ultrasparc3 ultrasparc v9" ;;
	    *UltraSparc*) ax_gcc_arch="ultrasparc3 ultrasparc v9" ;;
	    *SuperSparc*) ax_gcc_arch="supersparc v8" ;;
	    *HyperSparc*) ax_gcc_arch="hypersparc v8" ;;
            *Cypress*) ax_gcc_arch=cypress ;;
          esac ;;
       *) ax_gcc_arch=ultrasparc ;; # FIXME: how to guess on Solaris?
     esac ;;

  alphaev5) ax_gcc_arch=ev5 ;;
  alphaev56) ax_gcc_arch=ev56 ;;
  alphapca56) ax_gcc_arch="pca56 ev56" ;;
  alphapca57) ax_gcc_arch="pca57 pca56 ev56" ;;
  alphaev6) ax_gcc_arch=ev6 ;;
  alphaev67) ax_gcc_arch=ev67 ;;
  alphaev68) ax_gcc_arch="ev68 ev67" ;;
  alphaev69) ax_gcc_arch="ev69 ev68 ev67" ;;
  alphaev7) ax_gcc_arch="ev7 ev69 ev68 ev67" ;;
  alphaev79) ax_gcc_arch="ev79 ev7 ev69 ev68 ev67" ;;

  powerpc*)
     cputype=`((grep cpu /proc/cpuinfo | head -n 1 | cut -d: -f2 | sed 's/ //g') ; /usr/bin/machine ; /bin/machine) 2> /dev/null`
     cputype=`echo $cputype | sed -e s/ppc//g`
     case $cputype in
       *750*) ax_gcc_arch="750 G3" ;;
       *74[[0-9]][[0-9]]*) ax_gcc_arch="$cputype G4" ;;
       *970*) ax_gcc_arch="970 G5";;
       *POWER4*|*power4*|*gq*) ax_gcc_arch="power4";;
       *) ax_gcc_arch=$cputype ;;
     esac
     ax_gcc_arch="$ax_gcc_arch powerpc"
     ;;
esac
fi # guess arch

if test "x$ax_gcc_arch" != x -a "x$ax_gcc_arch" != xno; then

for arch in $ax_gcc_arch; do
  if test "x[]m4_default([$1],yes)" = xyes; then # if we require portable code
    flags="-mtune=$arch -mcpu=$arch"
  else
    flags="-march=$arch -mcpu=$arch -m$arch"
  fi
  for flag in $flags; do
    AX_CHECK_COMPILER_FLAGS($flag, [ax_cv_gcc_archflag=$flag; break])
  done
  test "x$ax_cv_gcc_archflag" = xunknown || break
done
fi

fi
])
AC_MSG_CHECKING([for gcc architecture flag])
AC_MSG_RESULT($ax_cv_gcc_archflag)
if test "x$ax_cv_gcc_archflag" = xunknown; then
  m4_default([$3],:)
else
  m4_default([$2], [CFLAGS="$CFLAGS $ax_cv_gcc_archflag"])
fi
])
