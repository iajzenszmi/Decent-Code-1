#! /bin/sh
# This is a shell archive, meaning:
# 1. Remove everything above the #! /bin/sh line.
# 2. Save the resulting text in a file.
# 3. Execute the file with /bin/sh (not csh) to create the files:
#	Fortran/
#	Fortran/Sp/
#	Fortran/Sp/Drivers/
#	Fortran/Sp/Drivers/Makefile
#	Fortran/Sp/Drivers/driver.f
#	Fortran/Sp/Drivers/res
#	Fortran/Sp/Src/
#	Fortran/Sp/Src/src.f
# This archive created: Tue Nov 21 14:40:29 2006
export PATH; PATH=/bin:$PATH
if test ! -d 'Fortran'
then
	mkdir 'Fortran'
fi
cd 'Fortran'
if test ! -d 'Sp'
then
	mkdir 'Sp'
fi
cd 'Sp'
if test ! -d 'Drivers'
then
	mkdir 'Drivers'
fi
cd 'Drivers'
if test -f 'Makefile'
then
	echo shar: will not over-write existing file "'Makefile'"
else
cat << "SHAR_EOF" > 'Makefile'
all: Res

src.o: src.f
	$(F77) $(F77OPTS) -c src.f

driver.o: driver.f
	$(F77) $(F77OPTS) -c driver.f

DRIVERS= driver
RESULTS= Res

Objs1= driver.o src.o
driver: $(Objs1)
	$(F77) $(F77OPTS) -o driver $(Objs1) $(SRCLIBS)
Res: driver 
	./driver >Res

diffres:Res res
	echo "Differences in results from driver"
	$(DIFF) Res res

clean: 
	rm -rf *.o $(DRIVERS) $(CLEANUP) $(RESULTS)
SHAR_EOF
fi # end of overwriting check
if test -f 'driver.f'
then
	echo shar: will not over-write existing file "'driver.f'"
else
cat << "SHAR_EOF" > 'driver.f'
      program main
C      ALGORITHM 358, COLLECTED ALGORITHMS FROM ACM.
C      THIS WORK PUBLISHED IN COMMUNICATIONS OF THE ACM
C      VOL. 12, NO. 10, October, 1969, PP.564--565.
C
c*******************************************************************************
c
cc TOMS358_PRB tests the CSVD routine.
c
c  Modified:
c
c    30 October 2006
c
c  Author:
c
c    John Burkardt
c
      implicit none

      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'TOMS358_PRB:'
      write ( *, '(a)' ) '  Test the ACM TOMS 358 Algorithm CSVD.'

      call test01
      call test02

      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'TOMS358_PRB:'
      write ( *, '(a)' ) '  Normal end of execution.'

      write ( *, '(a)' ) ' '

      stop
      end
      subroutine test01

c*******************************************************************************
c
cc TEST01 tests CSVD.
c
c  Modified:
c
c    30 October 2006
c
c  Author:
c
c    John Burkardt
c
      implicit none

      integer m
      integer n

      parameter ( m = 5 )
      parameter ( n = 5 )

      complex a(m,n)
      integer i
      integer j
      integer k
      integer mmax
      integer nmax
      integer nu
      integer nv
      integer p
      real s(n)
      integer seed
      complex u(m,m)
      complex v(n,n)

      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'TEST01'
      write ( *, '(a)' ) '  Call ACM TOMS Algorithm 358 for the'
      write ( *, '(a)' ) '  singular value decomposition:'
      write ( *, '(a)' ) '    A = U S V*'
      write ( *, '(a)' ) '  of an M by N complex matrix.'

      seed = 123456789
c
c  Set the matrix.
c
      call cmat_uniform_01 ( m, n, seed, a )

      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) '  Matrix A:'
      write ( *, '(a)' ) ' '

      do i = 1, m
        write ( *, '(10f8.4)' ) ( a(i,j), j = 1, n )
      end do

      mmax = m
      nmax = n
      p = 0
      nu = m
      nv = n

      call csvd ( a, mmax, nmax, m, n, p, nu, nv, s, u, v )

      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) '  Singular values:'
      write ( *, '(a)' ) ' '

      do i = 1, n
        write ( *, '(2x,g14.6)' ) s(i)
      end do

      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) '  U:'
      write ( *, '(a)' ) ' '

      do i = 1, m
        write ( *, '(10f8.4)' ) ( u(i,j), j = 1, m )
      end do

      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) '  V:'
      write ( *, '(a)' ) ' '

      do i = 1, n
        write ( *, '(10f8.4)' ) ( v(i,j), j = 1, n )
      end do
c
c  Compute U * S * V*.
c
      do i = 1, m
        do j = 1, n
          a(i,j) = cmplx ( 0.0E+00, 0.0E+00 )
          do k = 1, min ( m, n )
            a(i,j) = a(i,j) + u(i,k) * s(k) * conjg ( v(j,k) )
          end do
        end do
      end do

      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) '  Matrix U S V*'
      write ( *, '(a)' ) '  (should equal the original A):'
      write ( *, '(a)' ) ' '

      do i = 1, m
        write ( *, '(10f8.4)' ) ( a(i,j), j = 1, n )
      end do

      return
      end
      subroutine test02

c*******************************************************************************
c
cc TEST02 tests CSVDC.
c
c  Discussion:
c
c    For comparison, we call the LINPACK code CSVDC which also computes
c    the singular value decomposition of a complex matrix.
c
c  Modified:
c
c    30 October 2006
c
c  Author:
c
c    John Burkardt
c
      implicit none

      integer m
      integer n

      parameter ( m = 5 )
      parameter ( n = 5 )

      complex a(m,n)
      complex e(m)
      integer i
      integer info
      integer j
      integer job
      integer k
      integer lda
      integer ldu
      integer ldv
      complex s(n)
      integer seed
      complex u(m,m)
      complex v(n,n)
      complex work(n)

      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'TEST02'
      write ( *, '(a)' ) '  Call LINPACK routine CSVDC for the'
      write ( *, '(a)' ) '  singular value decomposition:'
      write ( *, '(a)' ) '    A = U S V*'
      write ( *, '(a)' ) '  of an M by N complex matrix.'

      seed = 123456789
c
c  Set the matrix.
c
      call cmat_uniform_01 ( m, n, seed, a )

      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) '  Matrix A:'
      write ( *, '(a)' ) ' '

      do i = 1, m
        write ( *, '(10f8.4)' ) ( a(i,j), j = 1, n )
      end do
c
c  Try CSVDC.
c  Note that CSVDC uses a COMPLEX array for the singular values.
c
      lda = m
      job = 11
      ldu = m
      ldv = n

      call csvdc ( a, lda, m, n, s, e, u, ldu, v, ldv, work, job, info )

      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) '  Singular values:'
      write ( *, '(a)' ) ' '

      do i = 1, n
        write ( *, '(2x,g14.6,2x,g14.6)' ) s(i)
      end do

      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) '  U:'
      write ( *, '(a)' ) ' '

      do i = 1, m
        write ( *, '(10f8.4)' ) ( u(i,j), j = 1, m )
      end do

      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) '  V:'
      write ( *, '(a)' ) ' '

      do i = 1, n
        write ( *, '(10f8.4)' ) ( v(i,j), j = 1, n )
      end do
c
c  Compute U * S * V*.
c
      do i = 1, m
        do j = 1, n
          a(i,j) = cmplx ( 0.0E+00, 0.0E+00 )
          do k = 1, min ( m, n )
            a(i,j) = a(i,j) + u(i,k) * s(k) * conjg ( v(j,k) )
          end do
        end do
      end do

      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) '  Matrix U S V*'
      write ( *, '(a)' ) '  (should equal the original A):'
      write ( *, '(a)' ) ' '

      do i = 1, m
        write ( *, '(10f8.4)' ) ( a(i,j), j = 1, n )
      end do

      return
      end
      subroutine cmat_uniform_01 ( m, n, seed, c )

c*******************************************************************************
c
cc CMAT_UNIFORM_01 returns a unit complex pseudorandom matrix.
c
c  Discussion:
c
c    The angles should be uniformly distributed between 0 and 2 * PI,
c    the square roots of the radius uniformly distributed between 0 and 1.
c
c    This results in a uniform distribution of values in the unit circle.
c
c  Modified:
c
c    15 March 2005
c
c  Author:
c
c    John Burkardt
c
c  Parameters:
c
c    Input, integer M, N, the number of rows and columns in the matrix.
c
c    Input/output, integer SEED, the "seed" value, which should NOT be 0.
c    On output, SEED has been updated.
c
c    Output, complex C(M,N), the pseudorandom complex matrix.
c
      implicit none

      integer m
      integer n

      complex c(m,n)
      integer i
      integer j
      real r
      integer k
      real pi
      integer seed
      real theta

      pi = 3.1415926E+00

      do j = 1, n
        do i = 1, m

          k = seed / 127773

          seed = 16807 * ( seed - k * 127773 ) - k * 2836

          if ( seed < 0 ) then
            seed = seed + 2147483647
          end if

          r = sqrt ( real ( dble ( seed ) * 4.656612875D-10 ) )

          k = seed / 127773

          seed = 16807 * ( seed - k * 127773 ) - k * 2836

          if ( seed < 0 ) then
            seed = seed + 2147483647
          end if

          theta = 2.0D+00 * pi
     &      * real ( dble ( seed ) * 4.656612875D-10 )

          c(i,j) = r * cmplx ( cos ( theta ), sin ( theta ) )

        end do

      end do

      return
      end
      subroutine caxpy(n,ca,cx,incx,cy,incy)
c
c     constant times a vector plus a vector.
c     jack dongarra, linpack, 3/11/78.
c     modified 12/3/93, array(1) declarations changed to array(*)
c
      complex cx(*),cy(*),ca
      integer i,incx,incy,ix,iy,n
c
      if(n.le.0)return
      if (abs(real(ca)) + abs(aimag(ca)) .eq. 0.0 ) return
      if(incx.eq.1.and.incy.eq.1)go to 20
c
c        code for unequal increments or equal increments
c          not equal to 1
c
      ix = 1
      iy = 1
      if(incx.lt.0)ix = (-n+1)*incx + 1
      if(incy.lt.0)iy = (-n+1)*incy + 1
      do 10 i = 1,n
        cy(iy) = cy(iy) + ca*cx(ix)
        ix = ix + incx
        iy = iy + incy
   10 continue
      return
c
c        code for both increments equal to 1
c
   20 do 30 i = 1,n
        cy(i) = cy(i) + ca*cx(i)
   30 continue
      return
      end
      complex function cdotc(n,cx,incx,cy,incy)
c
c     forms the dot product of two vectors, conjugating the first
c     vector.
c     jack dongarra, linpack,  3/11/78.
c     modified 12/3/93, array(1) declarations changed to array(*)
c
      complex cx(*),cy(*),ctemp
      integer i,incx,incy,ix,iy,n
c
      ctemp = (0.0,0.0)
      cdotc = (0.0,0.0)
      if(n.le.0)return
      if(incx.eq.1.and.incy.eq.1)go to 20
c
c        code for unequal increments or equal increments
c          not equal to 1
c
      ix = 1
      iy = 1
      if(incx.lt.0)ix = (-n+1)*incx + 1
      if(incy.lt.0)iy = (-n+1)*incy + 1
      do 10 i = 1,n
        ctemp = ctemp + conjg(cx(ix))*cy(iy)
        ix = ix + incx
        iy = iy + incy
   10 continue
      cdotc = ctemp
      return
c
c        code for both increments equal to 1
c
   20 do 30 i = 1,n
        ctemp = ctemp + conjg(cx(i))*cy(i)
   30 continue
      cdotc = ctemp
      return
      end
      subroutine  cscal(n,ca,cx,incx)
c
c     scales a vector by a constant.
c     jack dongarra, linpack,  3/11/78.
c     modified 3/93 to return if incx .le. 0.
c     modified 12/3/93, array(1) declarations changed to array(*)
c
      complex ca,cx(*)
      integer i,incx,n,nincx
c
      if( n.le.0 .or. incx.le.0 )return
      if(incx.eq.1)go to 20
c
c        code for increment not equal to 1
c
      nincx = n*incx
      do 10 i = 1,nincx,incx
        cx(i) = ca*cx(i)
   10 continue
      return
c
c        code for increment equal to 1
c
   20 do 30 i = 1,n
        cx(i) = ca*cx(i)
   30 continue
      return
      end
      subroutine  csrot (n,cx,incx,cy,incy,c,s)
c
c     applies a plane rotation, where the cos and sin (c and s) are real
c     and the vectors cx and cy are complex.
c     jack dongarra, linpack, 3/11/78.
c
      complex cx(*),cy(*),ctemp
      real c,s
      integer i,incx,incy,ix,iy,n
c
      if(n.le.0)return
      if(incx.eq.1.and.incy.eq.1)go to 20
c
c       code for unequal increments or equal increments not equal
c         to 1
c
      ix = 1
      iy = 1
      if(incx.lt.0)ix = (-n+1)*incx + 1
      if(incy.lt.0)iy = (-n+1)*incy + 1
      do 10 i = 1,n
        ctemp = c*cx(ix) + s*cy(iy)
        cy(iy) = c*cy(iy) - s*cx(ix)
        cx(ix) = ctemp
        ix = ix + incx
        iy = iy + incy
   10 continue
      return
c
c       code for both increments equal to 1
c
   20 do 30 i = 1,n
        ctemp = c*cx(i) + s*cy(i)
        cy(i) = c*cy(i) - s*cx(i)
        cx(i) = ctemp
   30 continue
      return
      end
      subroutine  cswap (n,cx,incx,cy,incy)
c
c     interchanges two vectors.
c     jack dongarra, linpack, 3/11/78.
c     modified 12/3/93, array(1) declarations changed to array(*)
c
      complex cx(*),cy(*),ctemp
      integer i,incx,incy,ix,iy,n
c
      if(n.le.0)return
      if(incx.eq.1.and.incy.eq.1)go to 20
c
c       code for unequal increments or equal increments not equal
c         to 1
c
      ix = 1
      iy = 1
      if(incx.lt.0)ix = (-n+1)*incx + 1
      if(incy.lt.0)iy = (-n+1)*incy + 1
      do 10 i = 1,n
        ctemp = cx(ix)
        cx(ix) = cy(iy)
        cy(iy) = ctemp
        ix = ix + incx
        iy = iy + incy
   10 continue
      return
c
c       code for both increments equal to 1
   20 do 30 i = 1,n
        ctemp = cx(i)
        cx(i) = cy(i)
        cy(i) = ctemp
   30 continue
      return
      end
      REAL             FUNCTION SCNRM2( N, X, INCX )
*     .. Scalar Arguments ..
      INTEGER                           INCX, N
*     .. Array Arguments ..
      COMPLEX                           X( * )
*     ..
*
*  SCNRM2 returns the euclidean norm of a vector via the function
*  name, so that
*
*     SCNRM2 := sqrt( conjg( x' )*x )
*
*
*
*  -- This version written on 25-October-1982.
*     Modified on 14-October-1993 to inline the call to CLASSQ.
*     Sven Hammarling, Nag Ltd.
*
*
*     .. Parameters ..
      REAL                  ONE         , ZERO
      PARAMETER           ( ONE = 1.0E+0, ZERO = 0.0E+0 )
*     .. Local Scalars ..
      INTEGER               IX
      REAL                  NORM, SCALE, SSQ, TEMP
*     .. Intrinsic Functions ..
      INTRINSIC             ABS, AIMAG, REAL, SQRT
*     ..
*     .. Executable Statements ..
      IF( N.LT.1 .OR. INCX.LT.1 )THEN
         NORM  = ZERO
      ELSE
         SCALE = ZERO
         SSQ   = ONE
*        The following loop is equivalent to this call to the LAPACK
*        auxiliary routine:
*        CALL CLASSQ( N, X, INCX, SCALE, SSQ )
*
         DO 10, IX = 1, 1 + ( N - 1 )*INCX, INCX
            IF( REAL( X( IX ) ).NE.ZERO )THEN
               TEMP = ABS( REAL( X( IX ) ) )
               IF( SCALE.LT.TEMP )THEN
                  SSQ   = ONE   + SSQ*( SCALE/TEMP )**2
                  SCALE = TEMP
               ELSE
                  SSQ   = SSQ   +     ( TEMP/SCALE )**2
               END IF
            END IF
            IF( AIMAG( X( IX ) ).NE.ZERO )THEN
               TEMP = ABS( AIMAG( X( IX ) ) )
               IF( SCALE.LT.TEMP )THEN
                  SSQ   = ONE   + SSQ*( SCALE/TEMP )**2
                  SCALE = TEMP
               ELSE
                  SSQ   = SSQ   +     ( TEMP/SCALE )**2
               END IF
            END IF
   10    CONTINUE
         NORM  = SCALE * SQRT( SSQ )
      END IF
*
      SCNRM2 = NORM
      RETURN
*
*     End of SCNRM2.
*
      END
      subroutine srotg(sa,sb,c,s)
c
c     construct givens plane rotation.
c     jack dongarra, linpack, 3/11/78.
c
      real sa,sb,c,s,roe,scale,r,z
c
      roe = sb
      if( abs(sa) .gt. abs(sb) ) roe = sa
      scale = abs(sa) + abs(sb)
      if( scale .ne. 0.0 ) go to 10
         c = 1.0
         s = 0.0
         r = 0.0
         z = 0.0
         go to 20
   10 r = scale*sqrt((sa/scale)**2 + (sb/scale)**2)
      r = sign(1.0,roe)*r
      c = sa/r
      s = sb/r
      z = 1.0
      if( abs(sa) .gt. abs(sb) ) z = s
      if( abs(sb) .ge. abs(sa) .and. c .ne. 0.0 ) z = 1.0/c
   20 sa = r
      sb = z
      return
      end
      subroutine csvdc(x,ldx,n,p,s,e,u,ldu,v,ldv,work,job,info)
      integer ldx,n,p,ldu,ldv,job,info
      complex x(ldx,*),s(*),e(*),u(ldu,*),v(ldv,*),work(*)
c
c
c     csvdc is a subroutine to reduce a complex nxp matrix x by
c     unitary transformations u and v to diagonal form.  the
c     diagonal elements s(i) are the singular values of x.  the
c     columns of u are the corresponding left singular vectors,
c     and the columns of v the right singular vectors.
c
c     on entry
c
c         x         complex(ldx,p), where ldx.ge.n.
c                   x contains the matrix whose singular value
c                   decomposition is to be computed.  x is
c                   destroyed by csvdc.
c
c         ldx       integer.
c                   ldx is the leading dimension of the array x.
c
c         n         integer.
c                   n is the number of rows of the matrix x.
c
c         p         integer.
c                   p is the number of columns of the matrix x.
c
c         ldu       integer.
c                   ldu is the leading dimension of the array u
c                   (see below).
c
c         ldv       integer.
c                   ldv is the leading dimension of the array v
c                   (see below).
c
c         work      complex(n).
c                   work is a scratch array.
c
c         job       integer.
c                   job controls the computation of the singular
c                   vectors.  it has the decimal expansion ab
c                   with the following meaning
c
c                        a.eq.0    do not compute the left singular
c                                  vectors.
c                        a.eq.1    return the n left singular vectors
c                                  in u.
c                        a.ge.2    returns the first min(n,p)
c                                  left singular vectors in u.
c                        b.eq.0    do not compute the right singular
c                                  vectors.
c                        b.eq.1    return the right singular vectors
c                                  in v.
c
c     on return
c
c         s         complex(mm), where mm=min(n+1,p).
c                   the first min(n,p) entries of s contain the
c                   singular values of x arranged in descending
c                   order of magnitude.
c
c         e         complex(p).
c                   e ordinarily contains zeros.  however see the
c                   discussion of info for exceptions.
c
c         u         complex(ldu,k), where ldu.ge.n.  if joba.eq.1 then
c                                   k.eq.n, if joba.ge.2 then
c                                   k.eq.min(n,p).
c                   u contains the matrix of left singular vectors.
c                   u is not referenced if joba.eq.0.  if n.le.p
c                   or if joba.gt.2, then u may be identified with x
c                   in the subroutine call.
c
c         v         complex(ldv,p), where ldv.ge.p.
c                   v contains the matrix of right singular vectors.
c                   v is not referenced if jobb.eq.0.  if p.le.n,
c                   then v may be identified whth x in the
c                   subroutine call.
c
c         info      integer.
c                   the singular values (and their corresponding
c                   singular vectors) s(info+1),s(info+2),...,s(m)
c                   are correct (here m=min(n,p)).  thus if
c                   info.eq.0, all the singular values and their
c                   vectors are correct.  in any event, the matrix
c                   b = ctrans(u)*x*v is the bidiagonal matrix
c                   with the elements of s on its diagonal and the
c                   elements of e on its super-diagonal (ctrans(u)
c                   is the conjugate-transpose of u).  thus the
c                   singular values of x and b are the same.
c
c     linpack. this version dated 03/19/79 .
c              correction to shift calculation made 2/85.
c     g.w. stewart, university of maryland, argonne national lab.
c
c     csvdc uses the following functions and subprograms.
c
c     external csrot
c     blas caxpy,cdotc,cscal,cswap,scnrm2,srotg
c     fortran abs,aimag,amax1,cabs,cmplx
c     fortran conjg,max0,min0,mod,real,sqrt
c
c     internal variables
c
      integer i,iter,j,jobu,k,kase,kk,l,ll,lls,lm1,lp1,ls,lu,m,maxit,
     *        mm,mm1,mp1,nct,nctp1,ncu,nrt,nrtp1
      complex cdotc,t,r
      real b,c,cs,el,emm1,f,g,scnrm2,scale,shift,sl,sm,sn,smm1,t1,test,
     *     ztest
      logical wantu,wantv
c
      complex csign,zdum,zdum1,zdum2
      real cabs1
      cabs1(zdum) = abs(real(zdum)) + abs(aimag(zdum))
      csign(zdum1,zdum2) = cabs(zdum1)*(zdum2/cabs(zdum2))
c
c     set the maximum number of iterations.
c
      maxit = 30
c
c     determine what is to be computed.
c
      wantu = .false.
      wantv = .false.
      jobu = mod(job,100)/10
      ncu = n
      if (jobu .gt. 1) ncu = min0(n,p)
      if (jobu .ne. 0) wantu = .true.
      if (mod(job,10) .ne. 0) wantv = .true.
c
c     reduce x to bidiagonal form, storing the diagonal elements
c     in s and the super-diagonal elements in e.
c
      info = 0
      nct = min0(n-1,p)
      nrt = max0(0,min0(p-2,n))
      lu = max0(nct,nrt)
      if (lu .lt. 1) go to 170
      do 160 l = 1, lu
         lp1 = l + 1
         if (l .gt. nct) go to 20
c
c           compute the transformation for the l-th column and
c           place the l-th diagonal in s(l).
c
            s(l) = cmplx(scnrm2(n-l+1,x(l,l),1),0.0e0)
            if (cabs1(s(l)) .eq. 0.0e0) go to 10
               if (cabs1(x(l,l)) .ne. 0.0e0) s(l) = csign(s(l),x(l,l))
               call cscal(n-l+1,1.0e0/s(l),x(l,l),1)
               x(l,l) = (1.0e0,0.0e0) + x(l,l)
   10       continue
            s(l) = -s(l)
   20    continue
         if (p .lt. lp1) go to 50
         do 40 j = lp1, p
            if (l .gt. nct) go to 30
            if (cabs1(s(l)) .eq. 0.0e0) go to 30
c
c              apply the transformation.
c
               t = -cdotc(n-l+1,x(l,l),1,x(l,j),1)/x(l,l)
               call caxpy(n-l+1,t,x(l,l),1,x(l,j),1)
   30       continue
c
c           place the l-th row of x into  e for the
c           subsequent calculation of the row transformation.
c
            e(j) = conjg(x(l,j))
   40    continue
   50    continue
         if (.not.wantu .or. l .gt. nct) go to 70
c
c           place the transformation in u for subsequent back
c           multiplication.
c
            do 60 i = l, n
               u(i,l) = x(i,l)
   60       continue
   70    continue
         if (l .gt. nrt) go to 150
c
c           compute the l-th row transformation and place the
c           l-th super-diagonal in e(l).
c
            e(l) = cmplx(scnrm2(p-l,e(lp1),1),0.0e0)
            if (cabs1(e(l)) .eq. 0.0e0) go to 80
               if (cabs1(e(lp1)) .ne. 0.0e0) e(l) = csign(e(l),e(lp1))
               call cscal(p-l,1.0e0/e(l),e(lp1),1)
               e(lp1) = (1.0e0,0.0e0) + e(lp1)
   80       continue
            e(l) = -conjg(e(l))
            if (lp1 .gt. n .or. cabs1(e(l)) .eq. 0.0e0) go to 120
c
c              apply the transformation.
c
               do 90 i = lp1, n
                  work(i) = (0.0e0,0.0e0)
   90          continue
               do 100 j = lp1, p
                  call caxpy(n-l,e(j),x(lp1,j),1,work(lp1),1)
  100          continue
               do 110 j = lp1, p
                  call caxpy(n-l,conjg(-e(j)/e(lp1)),work(lp1),1,
     *                       x(lp1,j),1)
  110          continue
  120       continue
            if (.not.wantv) go to 140
c
c              place the transformation in v for subsequent
c              back multiplication.
c
               do 130 i = lp1, p
                  v(i,l) = e(i)
  130          continue
  140       continue
  150    continue
  160 continue
  170 continue
c
c     set up the final bidiagonal matrix or order m.
c
      m = min0(p,n+1)
      nctp1 = nct + 1
      nrtp1 = nrt + 1
      if (nct .lt. p) s(nctp1) = x(nctp1,nctp1)
      if (n .lt. m) s(m) = (0.0e0,0.0e0)
      if (nrtp1 .lt. m) e(nrtp1) = x(nrtp1,m)
      e(m) = (0.0e0,0.0e0)
c
c     if required, generate u.
c
      if (.not.wantu) go to 300
         if (ncu .lt. nctp1) go to 200
         do 190 j = nctp1, ncu
            do 180 i = 1, n
               u(i,j) = (0.0e0,0.0e0)
  180       continue
            u(j,j) = (1.0e0,0.0e0)
  190    continue
  200    continue
         if (nct .lt. 1) go to 290
         do 280 ll = 1, nct
            l = nct - ll + 1
            if (cabs1(s(l)) .eq. 0.0e0) go to 250
               lp1 = l + 1
               if (ncu .lt. lp1) go to 220
               do 210 j = lp1, ncu
                  t = -cdotc(n-l+1,u(l,l),1,u(l,j),1)/u(l,l)
                  call caxpy(n-l+1,t,u(l,l),1,u(l,j),1)
  210          continue
  220          continue
               call cscal(n-l+1,(-1.0e0,0.0e0),u(l,l),1)
               u(l,l) = (1.0e0,0.0e0) + u(l,l)
               lm1 = l - 1
               if (lm1 .lt. 1) go to 240
               do 230 i = 1, lm1
                  u(i,l) = (0.0e0,0.0e0)
  230          continue
  240          continue
            go to 270
  250       continue
               do 260 i = 1, n
                  u(i,l) = (0.0e0,0.0e0)
  260          continue
               u(l,l) = (1.0e0,0.0e0)
  270       continue
  280    continue
  290    continue
  300 continue
c
c     if it is required, generate v.
c
      if (.not.wantv) go to 350
         do 340 ll = 1, p
            l = p - ll + 1
            lp1 = l + 1
            if (l .gt. nrt) go to 320
            if (cabs1(e(l)) .eq. 0.0e0) go to 320
               do 310 j = lp1, p
                  t = -cdotc(p-l,v(lp1,l),1,v(lp1,j),1)/v(lp1,l)
                  call caxpy(p-l,t,v(lp1,l),1,v(lp1,j),1)
  310          continue
  320       continue
            do 330 i = 1, p
               v(i,l) = (0.0e0,0.0e0)
  330       continue
            v(l,l) = (1.0e0,0.0e0)
  340    continue
  350 continue
c
c     transform s and e so that they are real.
c
      do 380 i = 1, m
         if (cabs1(s(i)) .eq. 0.0e0) go to 360
            t = cmplx(cabs(s(i)),0.0e0)
            r = s(i)/t
            s(i) = t
            if (i .lt. m) e(i) = e(i)/r
            if (wantu) call cscal(n,r,u(1,i),1)
  360    continue
c     ...exit
         if (i .eq. m) go to 390
         if (cabs1(e(i)) .eq. 0.0e0) go to 370
            t = cmplx(cabs(e(i)),0.0e0)
            r = t/e(i)
            e(i) = t
            s(i+1) = s(i+1)*r
            if (wantv) call cscal(p,r,v(1,i+1),1)
  370    continue
  380 continue
  390 continue
c
c     main iteration loop for the singular values.
c
      mm = m
      iter = 0
  400 continue
c
c        quit if all the singular values have been found.
c
c     ...exit
         if (m .eq. 0) go to 660
c
c        if too many iterations have been performed, set
c        flag and return.
c
         if (iter .lt. maxit) go to 410
            info = m
c     ......exit
            go to 660
  410    continue
c
c        this section of the program inspects for
c        negligible elements in the s and e arrays.  on
c        completion the variables kase and l are set as follows.
c
c           kase = 1     if s(m) and e(l-1) are negligible and l.lt.m
c           kase = 2     if s(l) is negligible and l.lt.m
c           kase = 3     if e(l-1) is negligible, l.lt.m, and
c                        s(l), ..., s(m) are not negligible (qr step).
c           kase = 4     if e(m-1) is negligible (convergence).
c
         do 430 ll = 1, m
            l = m - ll
c        ...exit
            if (l .eq. 0) go to 440
            test = cabs(s(l)) + cabs(s(l+1))
            ztest = test + cabs(e(l))
            if (ztest .ne. test) go to 420
               e(l) = (0.0e0,0.0e0)
c        ......exit
               go to 440
  420       continue
  430    continue
  440    continue
         if (l .ne. m - 1) go to 450
            kase = 4
         go to 520
  450    continue
            lp1 = l + 1
            mp1 = m + 1
            do 470 lls = lp1, mp1
               ls = m - lls + lp1
c           ...exit
               if (ls .eq. l) go to 480
               test = 0.0e0
               if (ls .ne. m) test = test + cabs(e(ls))
               if (ls .ne. l + 1) test = test + cabs(e(ls-1))
               ztest = test + cabs(s(ls))
               if (ztest .ne. test) go to 460
                  s(ls) = (0.0e0,0.0e0)
c           ......exit
                  go to 480
  460          continue
  470       continue
  480       continue
            if (ls .ne. l) go to 490
               kase = 3
            go to 510
  490       continue
            if (ls .ne. m) go to 500
               kase = 1
            go to 510
  500       continue
               kase = 2
               l = ls
  510       continue
  520    continue
         l = l + 1
c
c        perform the task indicated by kase.
c
         go to (530, 560, 580, 610), kase
c
c        deflate negligible s(m).
c
  530    continue
            mm1 = m - 1
            f = real(e(m-1))
            e(m-1) = (0.0e0,0.0e0)
            do 550 kk = l, mm1
               k = mm1 - kk + l
               t1 = real(s(k))
               call srotg(t1,f,cs,sn)
               s(k) = cmplx(t1,0.0e0)
               if (k .eq. l) go to 540
                  f = -sn*real(e(k-1))
                  e(k-1) = cs*e(k-1)
  540          continue
               if (wantv) call csrot(p,v(1,k),1,v(1,m),1,cs,sn)
  550       continue
         go to 650
c
c        split at negligible s(l).
c
  560    continue
            f = real(e(l-1))
            e(l-1) = (0.0e0,0.0e0)
            do 570 k = l, m
               t1 = real(s(k))
               call srotg(t1,f,cs,sn)
               s(k) = cmplx(t1,0.0e0)
               f = -sn*real(e(k))
               e(k) = cs*e(k)
               if (wantu) call csrot(n,u(1,k),1,u(1,l-1),1,cs,sn)
  570       continue
         go to 650
c
c        perform one qr step.
c
  580    continue
c
c           calculate the shift.
c
            scale = amax1(cabs(s(m)),cabs(s(m-1)),cabs(e(m-1)),
     *                    cabs(s(l)),cabs(e(l)))
            sm = real(s(m))/scale
            smm1 = real(s(m-1))/scale
            emm1 = real(e(m-1))/scale
            sl = real(s(l))/scale
            el = real(e(l))/scale
            b = ((smm1 + sm)*(smm1 - sm) + emm1**2)/2.0e0
            c = (sm*emm1)**2
            shift = 0.0e0
            if (b .eq. 0.0e0 .and. c .eq. 0.0e0) go to 590
               shift = sqrt(b**2+c)
               if (b .lt. 0.0e0) shift = -shift
               shift = c/(b + shift)
  590       continue
            f = (sl + sm)*(sl - sm) + shift
            g = sl*el
c
c           chase zeros.
c
            mm1 = m - 1
            do 600 k = l, mm1
               call srotg(f,g,cs,sn)
               if (k .ne. l) e(k-1) = cmplx(f,0.0e0)
               f = cs*real(s(k)) + sn*real(e(k))
               e(k) = cs*e(k) - sn*s(k)
               g = sn*real(s(k+1))
               s(k+1) = cs*s(k+1)
               if (wantv) call csrot(p,v(1,k),1,v(1,k+1),1,cs,sn)
               call srotg(f,g,cs,sn)
               s(k) = cmplx(f,0.0e0)
               f = cs*real(e(k)) + sn*real(s(k+1))
               s(k+1) = -sn*e(k) + cs*s(k+1)
               g = sn*real(e(k+1))
               e(k+1) = cs*e(k+1)
               if (wantu .and. k .lt. n)
     *            call csrot(n,u(1,k),1,u(1,k+1),1,cs,sn)
  600       continue
            e(m-1) = cmplx(f,0.0e0)
            iter = iter + 1
         go to 650
c
c        convergence.
c
  610    continue
c
c           make the singular value  positive
c
            if (real(s(l)) .ge. 0.0e0) go to 620
               s(l) = -s(l)
               if (wantv) call cscal(p,(-1.0e0,0.0e0),v(1,l),1)
  620       continue
c
c           order the singular value.
c
  630       if (l .eq. mm) go to 640
c           ...exit
               if (real(s(l)) .ge. real(s(l+1))) go to 640
               t = s(l)
               s(l) = s(l+1)
               s(l+1) = t
               if (wantv .and. l .lt. p)
     *            call cswap(p,v(1,l),1,v(1,l+1),1)
               if (wantu .and. l .lt. n)
     *            call cswap(n,u(1,l),1,u(1,l+1),1)
               l = l + 1
            go to 630
  640       continue
            iter = 0
            m = m - 1
  650    continue
      go to 400
  660 continue
      return
      end
SHAR_EOF
fi # end of overwriting check
if test -f 'res'
then
	echo shar: will not over-write existing file "'res'"
else
cat << "SHAR_EOF" > 'res'
 
TOMS358_PRB:
  Test the ACM TOMS 358 Algorithm CSVD.
 
TEST01
  Call ACM TOMS Algorithm 358 for the
  singular value decomposition:
    A = U S V*
  of an M by N complex matrix.
 
  Matrix A:
 
  0.4499 -0.1267 -0.2361  0.0775  0.5008 -0.7799 -0.7702 -0.3143 -0.5084  0.5621
 -0.8432 -0.3443  0.0186 -0.6332  0.3505  0.0166 -0.8892  0.2657 -0.5066  0.6005
  0.5896  0.2601  0.8928  0.0103  0.4350 -0.2666 -0.7799 -0.5512 -0.1022 -0.4500
  0.3911  0.3234 -0.5605  0.7638 -0.2009  0.2707  0.0314 -0.4336 -0.1046  0.3267
 -0.1395 -0.1561  0.3064  0.0263 -0.0975  0.9019  0.2491  0.5787  0.4106 -0.8102
 
  Singular values:
 
     2.43285    
     1.94345    
     1.15708    
    0.705795    
    0.248448    
 
  U:
 
  0.2242 -0.4836 -0.2151 -0.3438  0.0537  0.0352 -0.3236  0.2017  0.3038  0.5564
 -0.0470 -0.5195  0.3621  0.0569 -0.7086 -0.0724  0.0222 -0.2600  0.0696 -0.1153
  0.5033 -0.1529 -0.2687  0.2132  0.1156  0.5523  0.0944 -0.3937  0.2180 -0.2752
  0.0390  0.1680 -0.3397 -0.3904 -0.1128 -0.3801 -0.4899 -0.2989  0.1194 -0.4491
 -0.0944  0.3583  0.1730  0.5346 -0.1006  0.0531 -0.5220 -0.1440  0.4013  0.2825
 
  V:
 
  0.2731  0.0000 -0.4363  0.0000  0.5986  0.0000 -0.4818  0.0000 -0.3803  0.0000
  0.3175 -0.0395 -0.1459  0.5963 -0.1079  0.3004  0.3116  0.2061 -0.1692 -0.5007
  0.4497 -0.0720  0.2791 -0.1763 -0.3194  0.4403 -0.3277  0.4089 -0.0848  0.3256
 -0.1286  0.6084  0.2933 -0.2009  0.2858 -0.0985  0.2001  0.5267 -0.2325 -0.1550
 -0.3842  0.2852 -0.3889  0.2152 -0.1289  0.3687  0.1898 -0.0146 -0.2733  0.5568
 
  Matrix U S V*
  (should equal the original A):
 
  0.4499 -0.1267 -0.2361  0.0775  0.5008 -0.7799 -0.7702 -0.3143 -0.5084  0.5621
 -0.8432 -0.3443  0.0186 -0.6332  0.3505  0.0166 -0.8892  0.2657 -0.5066  0.6005
  0.5896  0.2601  0.8928  0.0103  0.4350 -0.2666 -0.7799 -0.5512 -0.1022 -0.4500
  0.3911  0.3234 -0.5605  0.7638 -0.2009  0.2707  0.0314 -0.4336 -0.1046  0.3267
 -0.1395 -0.1561  0.3064  0.0263 -0.0975  0.9019  0.2491  0.5787  0.4106 -0.8102
 
TEST02
  Call LINPACK routine CSVDC for the
  singular value decomposition:
    A = U S V*
  of an M by N complex matrix.
 
  Matrix A:
 
  0.4499 -0.1267 -0.2361  0.0775  0.5008 -0.7799 -0.7702 -0.3143 -0.5084  0.5621
 -0.8432 -0.3443  0.0186 -0.6332  0.3505  0.0166 -0.8892  0.2657 -0.5066  0.6005
  0.5896  0.2601  0.8928  0.0103  0.4350 -0.2666 -0.7799 -0.5512 -0.1022 -0.4500
  0.3911  0.3234 -0.5605  0.7638 -0.2009  0.2707  0.0314 -0.4336 -0.1046  0.3267
 -0.1395 -0.1561  0.3064  0.0263 -0.0975  0.9019  0.2491  0.5787  0.4106 -0.8102
SHAR_EOF
fi # end of overwriting check
cd ..
if test ! -d 'Src'
then
	mkdir 'Src'
fi
cd 'Src'
if test -f 'src.f'
then
	echo shar: will not over-write existing file "'src.f'"
else
cat << "SHAR_EOF" > 'src.f'
      SUBROUTINE CSVD ( A, MMAX, NMAX, M, N, P, NU, NV, S, U, V )
C
CC CSVD computes the singular value decomposition of a complex matrix.
C
C  Discussion:
C
C    The singular value decomposition of a complex M by N matrix A
C    has the form
C
C      A = U S V*
C
C    where 
C
C      U is an M by M unitary matrix,
C      S is an M by N diagonal matrix,
C      V is an N by N unitary matrix.
C
C    Moreover, the entries of S are nonnegative and occur on the diagonal
C    in descending order.
C
C    Several internal arrays are dimensioned under the assumption
C    that N <= 100.
C
C  Modified:
C
C    30 October 2006
C
C  Reference:
C
C    Peter Businger, Gene Golub,
C    Algorithm 358:
C    Singular Value Decomposition of a Complex Matrix,
C    Communications of the ACM,
C    Volume 12, Number 10, October 1969, pages 564-565.
C
C  Parameters:
C
C    Input/output, complex A(MMAX,*), the M by N matrix, which may be
C    augmented by P extra columns to which the transformation U*
C    is to be applied.  On output, A has been overwritten, and
C    if 0 < P, columns N+1 through N+P have been premultiplied by U*.
C
C    Input, integer MMAX, the leading dimension of the arrays A
C    and U.
C
C    Input, integer NMAX, the leading dimension of V, and perhaps
C    the second dimension of A and U.
C
C    Input, integer M, N, the number of rows and columns in A.
C    It must be the case that M <= N.  Several internal arrays are
C    dimensioned under the assumption that N <= 100.
C
C    Input, integer P, the number of vectors, stored in A(*,N+1:N+P),
C    to which the transformation U* should be applied.
C
C    Input, integer NU, the number of columns of U to compute.
C
C    Input, integer NV, the number of columns of V to compute.
C
C    Output, real S(N), the computed singular values.
C
C    Output, complex U(MMAX,NU), the first NU columns of U.
C
C    Output, complex V(NMAX,NV), the first NV columns of V.
C
C  Local Parameters:
C
C    Local, real ETA, the relative machine precision.
C    The original text uses ETA = 1.5E-8.
C
C    Local, real TOL, the smallest normalized positive number, divided by ETA.
C    The original test uses TOL = 1.E-31.
C
      IMPLICIT NONE

      INTEGER MMAX
      INTEGER NMAX

      COMPLEX A(MMAX,*)
      REAL B(100)
      REAL C(100)
      REAL CS
      REAL EPS
      REAL ETA
      REAL F
      REAL G
      REAL H
      INTEGER I
      INTEGER J
      INTEGER K
      INTEGER KK
      INTEGER K1
      INTEGER L
      INTEGER L1
      INTEGER LL
      INTEGER M
      INTEGER N
      INTEGER N1
      INTEGER NP
      INTEGER NU
      INTEGER NV
      INTEGER P
      COMPLEX Q
      COMPLEX R
      REAL S(*)
      REAL SN
      REAL T(100)
      REAL TOL
      COMPLEX U(MMAX,*)
      COMPLEX V(NMAX,*)
      REAL W
      REAL X
      REAL Y
      REAL Z

      SAVE ETA
      SAVE TOL

      DATA ETA / 1.5E-07 /
      DATA TOL / 1.5E-31 /

      NP = N + P
      N1 = N + 1
C
C  HOUSEHOLDER REDUCTION.
C
      C(1) = 0.0E+00
      K = 1

10    CONTINUE

      K1 = K + 1
C
C  ELIMINATION OF A(I,K), I = K+1, ..., M.
C
      Z = 0.0E+00
      DO 20 I = K, M
        Z = Z + REAL ( A(I,K) )**2 + AIMAG ( A(I,K) )**2
20    CONTINUE

      B(K) = 0.0E+00

      IF ( Z .LE. TOL ) GO TO 70

      Z = SQRT ( Z )
      B(K) = Z
      W = CABS ( A(K,K) )
      Q = CMPLX ( 1.0E+00, 0.0E+00 )
      IF ( W .NE. 0.0E+00 ) Q = A(K,K) / W
      A(K,K) = Q * ( Z + W )

      IF ( K .EQ. NP ) GO TO 70

      DO 50 J = K1, NP

        Q = CMPLX ( 0.0E+00, 0.0E+00 )
        DO 30 I = K, M
          Q = Q + CONJG ( A(I,K) ) * A(I,J)
30      CONTINUE
        Q = Q / ( Z * ( Z + W ) )

        DO 40 I = K, M
          A(I,J) = A(I,J) - Q * A(I,K)
40      CONTINUE

50    CONTINUE
C
C  PHASE TRANSFORMATION.
C
      Q = -CONJG ( A(K,K) ) / CABS ( A(K,K) )
      DO 60 J = K1, NP
        A(K,J) = Q * A(K,J)
60    CONTINUE
C
C  ELIMINATION OF A(K,J), J = K+2, ..., N
C
70    CONTINUE

      IF ( K .EQ. N ) GO TO 140

      Z = 0.0E+00
      DO 80 J = K1, N
        Z = Z + REAL ( A(K,J) )**2 + AIMAG ( A(K,J) )**2
80    CONTINUE

      C(K1) = 0.0E+00

      IF ( Z .LE. TOL ) GO TO 130

      Z = SQRT ( Z )
      C(K1) = Z
      W = CABS ( A(K,K1) )
      Q = CMPLX ( 1.0E+00, 0.0E+00 )
      IF ( W .NE. 0.0E+00 ) Q = A(K,K1) / W
      A(K,K1) = Q * ( Z + W )

      DO 110 I = K1, M
        Q = CMPLX ( 0.0E+00, 0.0E+00 )
        DO 90 J = K1, N
          Q = Q + CONJG ( A(K,J) ) * A(I,J)
90      CONTINUE
        Q = Q / ( Z * ( Z + W ) )
        DO 100 J = K1, N
          A(I,J) = A(I,J) - Q * A(K,J)
100     CONTINUE
110   CONTINUE
C
C  PHASE TRANSFORMATION.
C
      Q = -CONJG ( A(K,K1) ) / CABS ( A(K,K1) )
      DO 120 I = K1, M
        A(I,K1) = A(I,K1) * Q
120   CONTINUE

130   CONTINUE

      K = K1
      GO TO 10
C
C  TOLERANCE FOR NEGLIGIBLE ELEMENTS.
C
140   CONTINUE

      EPS = 0.0E+00
      DO 150 K = 1, N
        S(K) = B(K)
        T(K) = C(K)
        EPS = AMAX1 ( EPS, S(K) + T(K) )
150   CONTINUE

      EPS = EPS * ETA
C
C  INITIALIZATION OF U AND V.
C
      IF ( NU .EQ. 0 ) GO TO 180

      DO 170 J = 1, NU
        DO 160 I = 1, M
          U(I,J) = CMPLX ( 0.0E+00, 0.0E+00 )
160     CONTINUE
        U(J,J) = CMPLX ( 1.0E+00, 0.0E+00 )
170   CONTINUE

180   CONTINUE

      IF ( NV .EQ. 0 )GO TO 210

      DO 200 J = 1, NV
        DO 190 I = 1, N
          V(I,J) = CMPLX ( 0.0E+00, 0.0E+00 )
190     CONTINUE
        V(J,J) = CMPLX ( 1.0E+00, 0.0E+00 )
200   CONTINUE
C
C  QR DIAGONALIZATION.
C
210   CONTINUE

      DO 380 KK = 1, N

        K = N1 - KK
C
C  TEST FOR SPLIT.
C
220     CONTINUE

        DO 230 LL = 1, K
          L = K + 1 - LL
          IF ( ABS ( T(L) ) .LE. EPS ) GO TO 290
          IF ( ABS ( S(L-1) ) .LE. EPS ) GO TO 240
230     CONTINUE
C
C  CANCELLATION OF E(L).
C
240     CONTINUE

        CS = 0.0E+00
        SN = 1.0E+00
        L1 = L - 1

        DO 280 I = L, K

          F = SN * T(I)
          T(I) = CS * T(I)

          IF ( ABS ( F ) .LE. EPS ) GO TO 290

          H = S(I)
          W = SQRT ( F * F + H * H )
          S(I) = W
          CS = H / W
          SN = - F / W

          IF ( NU .EQ. 0 ) GO TO 260

          DO 250 J = 1, N
            X = REAL ( U(J,L1) )
            Y = REAL ( U(J,I) )
            U(J,L1) = CMPLX ( X * CS + Y * SN, 0.0E+00 )
            U(J,I)  = CMPLX ( Y * CS - X * SN, 0.0E+00 )
250       CONTINUE

260       CONTINUE

          IF ( NP .EQ. N ) GO TO 280

          DO 270 J = N1, NP
            Q = A(L1,J)
            R = A(I,J)
            A(L1,J) = Q * CS + R * SN
            A(I,J)  = R * CS - Q * SN
270       CONTINUE

280     CONTINUE
C
C  TEST FOR CONVERGENCE.
C
290     CONTINUE

        W = S(K)
        IF ( L .EQ. K ) GO TO 360
C
C  ORIGIN SHIFT.
C
        X = S(L)
        Y = S(K-1)
        G = T(K-1)
        H = T(K)
        F = ( ( Y - W ) * ( Y + W ) + ( G - H ) * ( G + H ) ) 
     &    / ( 2.0E+00 * H * Y )
        G = SQRT ( F * F + 1.0E+00 )
        IF ( F .LT. 0.0E+00 ) G = -G
        F = ( ( X - W ) * ( X + W ) + ( Y / ( F + G ) - H ) * H ) / X
C
C  QR STEP.
C
        CS = 1.0E+00
        SN = 1.0E+00
        L1 = L + 1

        DO 350 I = L1, K

          G = T(I)
          Y = S(I)
          H = SN * G
          G = CS * G
          W = SQRT ( H * H + F * F )
          T(I-1) = W
          CS = F / W
          SN = H / W
          F = X * CS + G * SN
          G = G * CS - X * SN
          H = Y * SN
          Y = Y * CS

          IF ( NV .EQ. 0 ) GO TO 310

          DO 300 J = 1, N
            X = REAL ( V(J,I-1) )
            W = REAL ( V(J,I) )
            V(J,I-1) = CMPLX ( X * CS + W * SN, 0.0E+00 )
            V(J,I)   = CMPLX ( W * CS - X * SN, 0.0E+00 )
300       CONTINUE

310       CONTINUE

          W = SQRT ( H * H + F * F )
          S(I-1) = W
          CS = F / W
          SN = H / W
          F = CS * G + SN * Y
          X = CS * Y - SN * G

          IF ( NU .EQ. 0 ) GO TO 330

          DO 320 J = 1, N
            Y = REAL ( U(J,I-1) )
            W = REAL ( U(J,I) )
            U(J,I-1) = CMPLX ( Y * CS + W * SN, 0.0E+00 )
            U(J,I)   = CMPLX ( W * CS - Y * SN, 0.0E+00 )
320       CONTINUE

330       CONTINUE

          IF ( N .EQ. NP ) GO TO 350

          DO 340 J = N1, NP
            Q = A(I-1,J)
            R = A(I,J)
            A(I-1,J) = Q * CS + R * SN
            A(I,J)   = R * CS - Q * SN
340       CONTINUE

350     CONTINUE

        T(L) = 0.0E+00
        T(K) = F
        S(K) = X
        GO TO 220
C
C  CONVERGENCE.
C
360     CONTINUE

        IF ( W .GE. 0.0E+00 ) GO TO 380
        S(K) = -W
        IF ( NV .EQ. 0 ) GO TO 380

        DO 370 J = 1, N
          V(J,K) = -V(J,K)
370     CONTINUE

380   CONTINUE
C
C  SORT SINGULAR VALUES.
C
      DO 450 K = 1, N

        G = -1.0E+00
        J = K

        DO 390 I = K, N
          IF ( S(I) .LE. G ) GO TO 390
          G = S(I)
          J = I
390     CONTINUE

        IF ( J .EQ. K ) GO TO 450

        S(J) = S(K)
        S(K) = G
C
C  Interchange V(1:N,J) and V(1:N,K).
C
        IF ( NV .EQ. 0 ) GO TO 410

        DO 400 I = 1, N
          Q      = V(I,J)
          V(I,J) = V(I,K)
          V(I,K) = Q
400     CONTINUE

410     CONTINUE
C
C  Interchange U(1:N,J) and U(1:N,K).
C
        IF ( NU .EQ. 0 ) GO TO 430

        DO 420 I = 1, N
          Q      = U(I,J)
          U(I,J) = U(I,K)
          U(I,K) = Q
420     CONTINUE

430     CONTINUE
C
C  Interchange A(J,N1:NP) and A(K,N1:NP).
C
        IF ( N .EQ. NP ) GO TO 450

        DO 440 I = N1, NP
          Q      = A(J,I)
          A(J,I) = A(K,I)
          A(K,I) = Q
440     CONTINUE

450   CONTINUE
C
C  BACK TRANSFORMATION.
C
      IF ( NU .EQ. 0 ) GO TO 510

      DO 500 KK = 1, N

        K = N1 - KK
        IF ( B(K) .EQ. 0.0E+00 ) GO TO 500
        Q = -A(K,K) / CABS ( A(K,K) )

        DO 460 J = 1, NU
          U(K,J) = Q * U(K,J)
460     CONTINUE

        DO 490 J = 1, NU

          Q = CMPLX ( 0.0E+00, 0.0E+00 )

          DO 470 I = K, M
            Q = Q + CONJG ( A(I,K) ) * U(I,J)
470       CONTINUE

          Q = Q / ( CABS ( A(K,K) ) * B(K) )

          DO 480 I = K, M
            U(I,J) = U(I,J) - Q * A(I,K)
480       CONTINUE

490     CONTINUE

500   CONTINUE

510   CONTINUE

      IF ( NV .EQ. 0 ) GO TO 570
      IF ( N .LT. 2 ) GO TO 570

      DO 560 KK = 2, N

        K = N1 - KK
        K1 = K + 1
        IF ( C(K1) .EQ. 0.0E+00 ) GO TO 560
        Q = -CONJG ( A(K,K1) ) / CABS ( A(K,K1) )

        DO 520 J = 1, NV
          V(K1,J) = Q * V(K1,J)
520     CONTINUE

        DO 550 J = 1, NV

          Q = CMPLX ( 0.0E+00, 0.0E+00 )

          DO 530 I = K1, N
            Q = Q + A(K,I) * V(I,J)
530       CONTINUE

          Q = Q / ( CABS ( A(K,K1) ) * C(K1) )

          DO 540 I = K1, N
            V(I,J) = V(I,J) - Q * CONJG ( A(K,I) )
540       CONTINUE

550     CONTINUE

560   CONTINUE

570   RETURN
      END
SHAR_EOF
fi # end of overwriting check
cd ..
cd ..
cd ..
#       End of shell archive
exit 0
