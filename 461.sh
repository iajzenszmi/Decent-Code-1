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
# This archive created: Wed Jan 18 20:30:15 2006
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

c*******************************************************************************
c
cc TOMS461_PRB tests TOMS461,
c
c  Modified:
c
c    12 January 2006
c
c  Author:
c
c    John Burkardt
c
      implicit none


      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'TOMS461_PRB:'
      write ( *, '(a)' ) '  Tests for ACM algorithm 461.'

      call test01

      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'TOMS461_PRB:'
      write ( *, '(a)' ) '  Normal end of execution.'

      write ( *, '(a)' ) ' '

      stop
      end
      subroutine test01

c*******************************************************************************
c
cc TEST01 tests SPNBVP.
c
      implicit none

      integer np
      integer nk

      parameter ( np = 81 )
      parameter ( nk = np - 2 )

      real a
      real b
      real ep
      real exact
      integer i
      integer kg(np)
      real mat(nk,nk)
      integer gt(np)
      real t
      real vg(np)
      real vm(np)
      real vp(np)
      real vq(np)
      real vr(np)
      real x(nk)
      real xdp(np)

      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'TEST01'
      write ( *, '(a)' ) '  SPNBVP computes a cubic spline'
      write ( *, '(a)' ) '  approximation to the solution of'
      write ( *, '(a)' ) '    x"(t)=p(t)*x(t)+q(t)*x(g(t))+r(t)'
      write ( *, '(a)' ) '  on the interval [a,b], with boundary'
      write ( *, '(a)' ) '  conditions:'
      write ( *, '(a)' ) '    x(t) = u(t) for t <= a,'
      write ( *, '(a)' ) '    x(t) = v(t) for b <= t.'
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) '  Because of the argument g(t), this is'
      write ( *, '(a)' ) '  a more complicated problem than it seems.'

      a = 0.0E+00
      b = 3.141592653589793E+00

      ep = 1.0E-04

      write ( *, '(a)' ) ' '
      write ( *, '(a,f10.4)' ) '  A = ', a
      write ( *, '(a,f10.4)' ) '  B = ', b
      write ( *, '(a,g14.6)' ) '  Error tolerance EP = ', ep

      call spnbvp ( a, b, np, nk, x, xdp, ep, gt, kg, vp, vq, vr, 
     &  vg, mat, vm )

      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 
     &  '        T         X                Exact        Error'
      write ( *, '(a)' ) ' '

      do i = 1, nk

        t = ( real ( nk - i + 1 ) * a 
     &       + real (      i     ) * b ) 
     &       / real ( nk     + 1 )

        exact = sin ( t )

        write ( *, '(2x,f10.4,2x,g14.6,2x,g14.6,2x,g10.2)' ) 
     &    t, x(i), exact, abs ( x(i) - exact )

      end do

      return
      end
      function g ( t )

c*******************************************************************************
c
      implicit none

      real g
      real t

      g = t - 1.0E+00

      return
      end
      subroutine ludcmp ( a, n )

c*******************************************************************************
c
cc LUDCMP factors a matrix by nonpivoting Gaussian elimination.
c
c  Discussion:
c
c    The storage format is used for a general M by N matrix.  A storage 
c    space is made for each logical entry.
c
c    This routine will fail if the matrix is singular, or if any zero
c    pivot is encountered.
c
c    If this routine successfully factors the matrix, LUSUB may be called
c    to solve linear systems involving the matrix.
c
c  Modified:
c
c    13 January 2006
c
c  Author:
c
c    John Burkardt
c
c  Parameters:
c
c    Input/output, real A(N,N).
c    On input, A contains the matrix to be factored.
c    On output, A contains information about the factorization,
c    which must be passed unchanged to LUSUB for solutions.
c
c    Input, integer N, the order of the matrix.
c    N must be positive.
c
      implicit none

      integer n

      real a(n,n)
      integer i
      integer j
      integer k

      do k = 1, n-1

        if ( a(k,k) == 0.0E+00 ) then
          write ( *, '(a)' ) ' '
          write ( *, '(a)' ) 'LUDCMP - Fatal error!'
          write ( *, '(a,i6)' ) '  Zero pivot on step ', k
          stop
        end if

        do i = k+1, n
          a(i,k) = -a(i,k) / a(k,k)
        end do

        do j = k+1, n
          do i = k+1, n
            a(i,j) = a(i,j) + a(i,k) * a(k,j)
          end do
        end do

      end do

      if ( a(n,n) == 0.0E+00 ) then
        write ( *, '(a)' ) ' '
        write ( *, '(a)' ) 'LUDCMP - Fatal error!'
        write ( *, '(a,i6)' ) '  Zero pivot on step ', n
        stop
      end if

      return
      end
      subroutine lusub ( b, a_lu, x, n )

c*******************************************************************************
c
cc LUSUB solves a system factored by LUDCMP.
c
c  Modified:
c
c    13 January 2006
c
c  Author:
c
c    John Burkardt
c
c  Parameters:
c
c    Input, real B(N), the right hand side vector.
c
c    Input, real A_LU(N,N), the LU factors from LUDCMP.
c
c    Output, real X(N), the solution.
c
c    Input, integer N, the order of the matrix.
c    N must be positive.
c
      implicit none

      integer n

      real a_lu(n,n)
      real b(n)
      integer i
      integer j
      real x(n)

      do i = 1, n
        x(i) = b(i)
      end do

      do j = 1, n-1
        do i = j+1, n
          x(i) = x(i) + a_lu(i,j) * x(j)
        end do
      end do

      do j = n, 1, -1
        x(j) = x(j) / a_lu(j,j)
        do i = 1, j-1
          x(i) = x(i) - a_lu(i,j) * x(j)
        end do
      end do
 
      return
      end
      function p ( t )

c*******************************************************************************
c
      implicit none

      real p
      real t

      p = 1.0E+00

      return
      end
      function q ( t )

c*******************************************************************************
c
      implicit none

      real q
      real t

      q = 1.0E+00

      return
      end
      function r ( t )

c*******************************************************************************
c
      implicit none

      real g
      real p
      real q
      real r
      real t

      r = - sin ( t ) - ( p ( t ) * sin ( t ) + q(t) * sin ( g(t) ) )

      return
      end
      function u ( t )

c*******************************************************************************
c
cc U evaluates the left boundary condition.
c
      implicit none

      real t
      real u

      u = sin ( t )

      return
      end
      function v ( t )

c*******************************************************************************
c
cc V evaluates the right boundary condition.
c
      implicit none

      real t
      real v

      v = sin ( t )

      return
      end
SHAR_EOF
fi # end of overwriting check
if test -f 'res'
then
	echo shar: will not over-write existing file "'res'"
else
cat << "SHAR_EOF" > 'res'
 
TOMS461_PRB:
  Tests for ACM algorithm 461.
 
TEST01
  SPNBVP computes a cubic spline
  approximation to the solution of
    x"(t)=p(t)*x(t)+q(t)*x(g(t))+r(t)
  on the interval [a,b], with boundary
  conditions:
    x(t) = u(t) for t <= a,
    x(t) = v(t) for b <= t.
 
  Because of the argument g(t), this is
  a more complicated problem than it seems.
 
  A =     0.0000
  B =     3.1416
  Error tolerance EP =   0.100000E-03
 
        T         X                Exact        Error
 
      0.0393    0.392590E-01    0.392598E-01    0.78E-06
      0.0785    0.784575E-01    0.784591E-01    0.16E-05
      0.1178    0.117535        0.117537        0.23E-05
      0.1571    0.156431        0.156434        0.31E-05
      0.1963    0.195087        0.195090        0.38E-05
      0.2356    0.233441        0.233445        0.45E-05
      0.2749    0.271435        0.271440        0.52E-05
      0.3142    0.309011        0.309017        0.58E-05
      0.3534    0.346111        0.346117        0.63E-05
      0.3927    0.382677        0.382683        0.69E-05
      0.4320    0.418652        0.418660        0.74E-05
      0.4712    0.453983        0.453991        0.77E-05
      0.5105    0.488613        0.488621        0.80E-05
      0.5498    0.522490        0.522499        0.82E-05
      0.5890    0.555562        0.555570        0.83E-05
      0.6283    0.587777        0.587785        0.85E-05
      0.6676    0.619085        0.619094        0.85E-05
      0.7069    0.649440        0.649448        0.85E-05
      0.7461    0.678792        0.678801        0.85E-05
      0.7854    0.707098        0.707107        0.83E-05
      0.8247    0.734315        0.734323        0.80E-05
      0.8639    0.760398        0.760406        0.77E-05
      0.9032    0.785310        0.785317        0.72E-05
      0.9425    0.809010        0.809017        0.67E-05
      0.9817    0.831464        0.831470        0.61E-05
      1.0210    0.852635        0.852640        0.53E-05
      1.0603    0.872491        0.872496        0.47E-05
      1.0996    0.891002        0.891007        0.41E-05
      1.1388    0.908140        0.908143        0.33E-05
      1.1781    0.923877        0.923880        0.25E-05
      1.2174    0.938190        0.938191        0.16E-05
      1.2566    0.951056        0.951057        0.54E-06
      1.2959    0.962456        0.962455        0.66E-06
      1.3352    0.972372        0.972370        0.19E-05
      1.3744    0.980788        0.980785        0.32E-05
      1.4137    0.987693        0.987688        0.45E-05
      1.4530    0.993074        0.993068        0.58E-05
      1.4923    0.996924        0.996917        0.72E-05
      1.5315    0.999238        0.999229        0.85E-05
      1.5708     1.00001         1.00000        0.98E-05
      1.6101    0.999240        0.999229        0.11E-04
      1.6493    0.996930        0.996917        0.12E-04
      1.6886    0.993082        0.993068        0.14E-04
      1.7279    0.987704        0.987688        0.15E-04
      1.7671    0.980802        0.980785        0.16E-04
      1.8064    0.972388        0.972370        0.18E-04
      1.8457    0.962474        0.962455        0.19E-04
      1.8850    0.951077        0.951056        0.20E-04
      1.9242    0.938213        0.938191        0.21E-04
      1.9635    0.923902        0.923880        0.22E-04
      2.0028    0.908167        0.908143        0.23E-04
      2.0420    0.891031        0.891006        0.24E-04
      2.0813    0.872521        0.872496        0.25E-04
      2.1206    0.852666        0.852640        0.26E-04
      2.1598    0.831496        0.831470        0.26E-04
      2.1991    0.809044        0.809017        0.27E-04
      2.2384    0.785344        0.785317        0.27E-04
      2.2777    0.760434        0.760406        0.28E-04
      2.3169    0.734351        0.734322        0.28E-04
      2.3562    0.707135        0.707107        0.28E-04
      2.3955    0.678829        0.678801        0.28E-04
      2.4347    0.649476        0.649448        0.28E-04
      2.4740    0.619122        0.619094        0.28E-04
      2.5133    0.587813        0.587785        0.28E-04
      2.5525    0.555598        0.555570        0.27E-04
      2.5918    0.522525        0.522498        0.27E-04
      2.6311    0.488647        0.488621        0.26E-04
      2.6704    0.454015        0.453990        0.25E-04
      2.7096    0.418684        0.418660        0.24E-04
      2.7489    0.382706        0.382683        0.23E-04
      2.7882    0.346138        0.346117        0.21E-04
      2.8274    0.309036        0.309017        0.19E-04
      2.8667    0.271458        0.271440        0.18E-04
      2.9060    0.233461        0.233445        0.16E-04
      2.9452    0.195104        0.195090        0.14E-04
      2.9845    0.156446        0.156434        0.11E-04
      3.0238    0.117546        0.117537        0.87E-05
      3.0631    0.784650E-01    0.784590E-01    0.60E-05
      3.1023    0.392628E-01    0.392597E-01    0.31E-05
 
TOMS461_PRB:
  Normal end of execution.
 
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
      SUBROUTINE SPNBVP ( A, B, NP, NK, X, XDP, EP, GT, KG, VP,
     &  VQ, VR, VG, MAT, VM )
C
C  THIS ALGORITHM COMPUTES ITERATIVELY A CUBIC SPLINE
C  APPROXIMATION TO THE SOLUTION OF THE DIFFERENTIAL EQUATION
C  X''(T)=P(T)X(T)+Q(T)X(G(T))+R(T) ON THE INTERVAL (A,B)
C  WITH BOUNDARY CONDITIONS GIVEN BY U(T) IF T.LE.A AND
C  V(T) IF T.GE.B.
C
C  A AND B ARE TWO REAL VARIABLES DEFINED AS ABOVE.
C
C  NP   AN INTEGER VARIABLE SPECIFYING THE NUMBER OF KNOTS
C       ON THE INTERVAL (A,B).
C
C  NK   AN INTEGER VARIABLE SPECIFYING THE NUMBER OF INTERIOR
C       KNOTS.  THUS NK=NP-2.  IT IS USED TO ESTABLISH THE
C       DIMENSION OF CERTAIN ARRAYS MENTIONED BELOW.
C
C  X    ON RETURN TO THE CALLING PROGRAM X WILL CONTAIN THE
C       VALUES OF THE APPROXIMATION TO THE SOLUTION AT THE
C       NK INTERIOR KNOTS.  THIS IS AN ARRAY OF DIMENSION
C       NK AND TYPE REAL.
C
C  XDP  ON RETURN, XDP CONTAINS THE QUANTITIES H*H/6.0
C       MULTIPLIED BY THE SECOND DERIVATIVE VALUES AT ALL THE
C       KNOTS.  XDP IS A REAL ARRAY OF DIMENSION NP.
C
C  EP   THIS REAL VARIABLE IS SET TO THE VALUE 1.0E-M IF WE
C       REQUIRE M IDENTICAL FIGURES IN SUCCESSIVE ITERATES.
C
C  GT   AN INTEGER ARRAY OF LENGTH NP WHICH ASSIGNS TO EACH
C       KNOT T SUB J AN INTEGER VALUE BETWEEN 1 AND 6.  THIS
C       VALUE DESIGNATES RESPECTIVELY THE CASES WHEN
C       G(T SUB J) IS 1) .LE. A, 2) .GE. B, 3) WITHIN EP OF
C       SOME KNOT VALUE, 4) IN THE FIRST SUBINTERVAL,
C       5) IN THE LAST SUBINTERVAL, AND 6) IN ANY OTHER
C       SUBINTERVAL.  GT(I+1) CORRESPONDS TO KNOT T SUB I.
C
C  KG   AN INTEGER ARRAY OF LENGTH NP WHICH ASSIGNS TO EACH
C       KNOT AN INTEGER BETWEEN 2 AND NP-1.  IF GT(I+1) = 3,
C       THEN KG(I+1) CONTAINS THE SUBSCRIPT OF THE KNOT
C       AT THE POINT G(T SUB I).  IF GT(I+1) = 6, THEN KG(I+1)
C       CONTAINS THE SUBSCRIPT OF THE KNOW AT THE RIGHT HAND
C       ENDPOINT OF THE SUBINTERVAL IN WHICH G(T SUB I) LIES.
C
C  VP, VQ, VR, AND VG ARE ALL REAL ARRAYS OF DIMENSION NP AND
C       CONTAINS THE VALUES OF THE FUNCTIONS P, Q, R AND G
C       RESPECTIVELY, EACH EVALUATED AT THE NP KNOTS.
C
C  MAT  IS A REAL NK BY NK ARRAY USED IN THE MATRIX EQUATION
C       (MAT)(X)=(VM) SET UP TO SOLVE FOR THE X SUB J VALUES
C       STORED IN ARRAY X.
C
C  VM   AN ARRAY OF LENGTH NK AND TYPE REAL USED AS
C       DESCRIBED ABOVE.
C
C  THE USER MUST SUPPLY REAL FUNCTION SUBPROGRAMS TO COMPUTE
C  THE FUNCTIONS U(T),V(T),P(T),Q(T),R(T) AND G(T) DEFINED AS
C  ABOVE.  HE MUST ALSO SUPPLY SUBPROGRAMS WHICH SOLVE THE
C  SYSTEM (MAT)*(X)=(VM).  THE ROUTINE LUDCMP(MAT,NK) IS TO
C  REAPLCE MAT BY ITS LU DECOMPOSITION.  THE ROUTINE
C  LUSUB(VM,MAT,X,NK) IS TO COMPUTE X WHEN VM AND THE LU
C  FORM OF MAT IS GIVEN.
C
      IMPLICIT NONE

      INTEGER NK
      INTEGER NP

      REAL A
      REAL APLSE
      REAL B
      REAL BMINE
      REAL C
      REAL CCC
      REAL COEF
      REAL EP
      REAL G
      INTEGER GT1
      INTEGER GTE
      INTEGER GT(NP)
      INTEGER GTNP
      INTEGER GTYP
      REAL H
      REAL HR
      REAL HS
      INTEGER J
      INTEGER JF
      INTEGER JJ
      INTEGER JJZ
      INTEGER JZ
      INTEGER K
      INTEGER KG(NP)
      INTEGER KNOT
      REAL MAT(NK,NK)
      INTEGER N
      INTEGER NK1
      INTEGER NNN
      REAL P
      REAL Q
      REAL R
      REAL RK
      REAL RKNOT
      REAL RN
      REAL T
      REAL TJ
      REAL TM
      REAL TSTVL1
      REAL TSTVL2
      REAL U
      REAL V
      REAL VDH
      REAL VG(NP)
      REAL VGE
      REAL VM(NK)
      REAL VP(NP)
      REAL VPA
      REAL VPB
      REAL VQ(NP)
      REAL VR(NP)
      REAL X(NK)
      REAL XA
      REAL XB
      REAL XDP(NP)
      REAL XDPA
      REAL XDPB
      REAL XGAA
      REAL XGAB

      C ( T ) = T * ( T * T - 1.0 )
C
C  INITIALIZATION.
C
      N = NP - 1
      RN = N
C
C  NK is presumably set by the user!
C
C     NK = N - 1

      DO 20 K = 1, NK
        DO 10 J = 1, NK
          MAT(K,J) = 0.0
10      CONTINUE
20    CONTINUE

      XA = U ( A )
      XB = V ( B )
C
C  INITIALIZE XDP TO ZERO (INITIAL SPLINE).
C
      DO 30 K = 1, NP
        XDP(K) = 0.0
30    CONTINUE
C
C  SET UP P, Q, R, G VECTORS.
C
      H = ( B - A ) / RN
      HS = H * H / 6.0
      HR = 1.0 / H

      DO 40 K = 1, NP
        RK = K - 1
        TM = A + RK * H
        VP(K) = P ( TM )
        VQ(K) = Q ( TM )
        VR(K) = R ( TM )
        VG(K) = G ( TM )
40    CONTINUE
C
C  SET UP *TYPE OF G VALUE* ARRAY AND KG ARRAY.
C
      APLSE = A + EP * ABS ( A )
      BMINE = B - EP * ABS ( B )
      DO 70 K = 1, NP
        GTE = 6
        VGE = VG(K)
        IF ( VGE .LT. A + H ) GTE = 4
        IF ( VGE .GT. B - H ) GTE = 5
        IF ( VGE .LE. APLSE ) GTE = 1
        IF ( VGE .GE. BMINE ) GTE = 2
        VDH = ( VGE - A ) / H
        KNOT = VDH + EP
        RKNOT = KNOT
        IF ( ( KNOT .LT. 1 ) .OR. ( KNOT .GT. NK ) ) GO TO 50
        IF ( ABS ( VDH - RKNOT ) .GT. EP ) GO TO 50
        GTE = 3
        KG(K) = KNOT
        GO TO 60
50      KG(K) = KNOT + 1
60      GT(K) = GTE
70    CONTINUE
C
C  PUT XSUBJ COEFFICIENTS INTO (MAT) AND INITIALIZE X TO ZERO.
C
      DO 90 J = 1, NK
        X(J) = 0.0
        IF ( J .EQ. 1 ) GO TO 80
        MAT(J,J-1) = 1.0 - HS * VP(J)
80      MAT(J,J) = -2.0 * ( 1.0 + 2.0 * HS * VP(J+1) )
        IF ( J .EQ. NK ) GO TO 90
        MAT(J,J+1) = 1.0 - HS * VP(J+2)
90    CONTINUE
C
C  ADD INTO (MAT) X SUB G SUB T COEFFICIENTS.
C
      DO 150 J = 1, NK
        DO 140 JJ = 1, 3
          JZ = JJ - 1
          JJZ = J + JZ
          COEF = HS * VQ(JJZ)
          IF ( JZ .EQ. 1 ) COEF = COEF * 4.0
          GTYP = GT(JJZ)
          GO TO ( 140, 140, 100, 110, 120, 130 ), GTYP
100       KNOT = KG(JJZ)
          MAT(J,KNOT) = MAT(J,KNOT) - COEF
          GO TO 140
110       MAT(J,1) = MAT(J,1) - COEF * ( VG(JJZ) - A ) * HR
          GO TO 140
120       MAT(J,NK) = MAT(J,NK) - COEF * ( B - VG(JJZ) ) * HR
          GO TO 140
130       KNOT = KG(JJZ)
          RKNOT = KNOT
          CCC = RKNOT + ( A - VG(JJZ) ) * HR
          MAT(J,KNOT-1) = MAT(J,KNOT-1) - COEF * CCC
          CCC = ( VG(JJZ) - A ) * HR - RKNOT + 1.0
          MAT(J,KNOT) = MAT(J,KNOT) - COEF * CCC
140     CONTINUE
150   CONTINUE
C
C  REPLACE (MAT) BY ITS LU DECOMPOSITION.
C
      CALL LUDCMP ( MAT, NK )
C
C  A SEQUENCE OF SPLINES (UP TO 20) IS NOT GENERATED.
C
      VPA = VP(1)
      VPB = VP(NP)

      DO 250 NNN = 1, 20
C
C  VECTOR VM I SNOW SET UP.
C
        DO 200 J = 1, NK
          VM(J) = ( VR(J) + 4.0 * VR(J+1) + VR(J+2) ) * HS
          DO 190 JJ = 1, 3
            JZ = JJ - 1
            JJZ = J + JZ
            GTYP = GT(JJZ)
            COEF = HS * VQ(JJZ)
            IF ( JZ .EQ. 1 ) COEF = COEF * 4.
            IF ( GTYP .EQ. 1 ) VM(J) = VM(J) + COEF * U(VG(JJZ))
            IF ( GTYP .EQ. 2 ) VM(J) = VM(J) + COEF * V(VG(JJZ))
            GO TO ( 190, 190, 190, 160, 170, 180 ), GTYP
160         TM = ( VG(JJZ) - A ) * HR
            TJ = 1.0 - TM
            CCC = TJ * XA + C ( TM ) * XDP(2) + C ( TJ ) * XDP(1)
            VM(J) = VM(J) + COEF * CCC
            GO TO 190
170         TJ = ( B - VG(JJZ) ) * HR
            TM = 1. - TJ
            CCC = TM * XB + C ( TM ) * XDP(NK+1) + C ( TJ ) * XDP(NK+1)
            VM(J) = VM(J) + COEF * CCC
            GO TO 190
180         KNOT = KG(JJZ)
            RKNOT = KNOT
            TJ = ( A - VG(JJZ) ) * HR + RKNOT
            TM = 1.0 - TJ
            CCC = C ( TM ) * XDP(KNOT+1) - C ( TJ ) * XDP(KNOT)
            VM(J) = VM(J) + COEF * CCC
190       CONTINUE
200     CONTINUE
        VM(1) = VM(1) - ( 1.0 - HS * VPA ) * U(A)
        VM(NK) = VM(NK) - ( 1.0 - HS * VPB ) * V(B)
C
C  THE NEW X ARRAY IS NOW COMPUTED.
C  THE ARRAY VP SERVES AS A WORK AREA.
C
        DO 210 JF = 1, NK
          VP(JF) = X(JF)
210     CONTINUE

        CALL LUSUB ( VM, MAT, X, NK )

        TSTVL1 = 0.0
        TSTVL2 = 0.0
        DO 220 JF = 1, NK
          TSTVL1 = TSTVL1 + ABS ( VP(JF) - X(JF) )
          TSTVL2 = TSTVL2 + ABS ( X(JF) )
220     CONTINUE
C
C  CALCULATION OF XDP AT A AND B.
C
        GT1 = GT(1)
        GTNP = GT(NP)
        IF ( GT1 .EQ. 1 ) XGAA = U ( VG(1) )
        IF ( GT1 .EQ. 2 ) XGAA = V ( VG(1) )
        IF ( GTNP .EQ. 1 ) XGAB = U ( VG(NP) )
        IF ( GTNP .EQ. 2 ) XGAB = V ( VG(NP) )
        CALL GAGB ( GT1, XGAA, KG(1), VG(1), X, XDP, A, B, NP, NK )
        CALL GAGB ( GTNP, XGAB, KG(NP), VG(NP), X, XDP, A, B, NP,
     &    NK )
        XDPA = ( VPA * XA + VG(1) * XGAA + VR(1) ) * HS
        XDPB = ( VPB * XB + VG(NP) * XGAB + VR(NP) ) * HS
C
C  SOLVE FOR XDP VALUES OF CURRENT SPLINE USING CONTINUITY
C  EQUATIONS.  VM AND VP ARE USED AS WORKING AREAS.
C
        VM(1) = XA + X(2) - 2.0 * X(1) - XDPA
        NK1 = NK - 1
        VM(NK) = XB + X(NK1) - 2.0 * X(NK) - XDPB
        DO 230 J = 2, NK1
          VM(J) = X(J-1) + X(J+1) - 2.0 * X(J)
230     CONTINUE

        CALL SOLVE ( VM, NK, VP, NP )

        XDP(1) = XDPA
        XDP(NP) = XDPB
        DO 240 J = 1, NK
          XDP(J+1) = VM(J)
240     CONTINUE

        IF ( TSTVL1 .LE. TSTVL2 * EP ) RETURN
        IF ( NNN .EQ. 20 ) WRITE ( *, 1000 )
1000    FORMAT ( ' NO CONVERGENCE IN 20 ITERATIONS')

250   CONTINUE

      RETURN
      END
      SUBROUTINE GAGB ( GTYP, ANS, K, GV, X, XDP, A, B, NP, NK )

      IMPLICIT NONE

      INTEGER NK
      INTEGER NP

      REAL A
      REAL ANS
      REAL B
      REAL C
      INTEGER GTYP
      REAL GV
      REAL H
      INTEGER K
      REAL RK
      REAL RNKD
      REAL T
      REAL TJ
      REAL TM
      REAL U
      REAL V
      REAL X(NK)
      REAL XA
      REAL XB
      REAL XDP(NP)

      C ( T ) = T * ( T * T - 1. )
      RNKD = NK + 1
      RK = K
      XA = U ( A )
      XB = V ( B )
      H = ( B - A ) / RNKD
      GO TO ( 10, 20, 30, 40, 50, 60 ), GTYP
10    RETURN
20    RETURN
30    ANS = X(K)
      RETURN

40    TM = ( GV - A ) / H
      TJ = 1. - TM
      ANS = TM * X(1) + TJ * XA + C ( TM ) * XDP(2) + C ( TJ ) * XDP(1)
      RETURN

50    TJ = ( B - GV ) / H
      TM = 1. - TJ
      ANS = TM * XB + TJ * X(NK) + C(TM) * XDP(NK+2) + C(TJ) * XDP(NK+1)
      RETURN

60    TJ = ( A - GV ) / H + RK
      TM = 1. - TJ
      ANS = TM * X(K) + TJ * X(K-1) + C(TM) * XDP(K+1) + C(TJ) * XDP(K)

      RETURN
      END
      SUBROUTINE SOLVE ( D, NK, M, NP )

      IMPLICIT NONE

      INTEGER NK
      INTEGER NP

      REAL D(NK)
      REAL M(NP)
      INTEGER I
      INTEGER J
      INTEGER NK1

      NK1 = NK - 1

      M(NK) = 0.25
      DO 10 I = 1, NK1
        J = NK - I
        M(J) = 1.0 / ( 4.0 - M(J+1) )
        D(J) = D(J) - D(J+1) * M(J+1)
10    CONTINUE

      D(1) = D(1) * M(1)
      DO 20 I = 2, NK
        D(I) = ( D(I) - D(I-1) ) * M(I)
20    CONTINUE

      RETURN
      END
SHAR_EOF
fi # end of overwriting check
cd ..
cd ..
cd ..
#       End of shell archive
exit 0
