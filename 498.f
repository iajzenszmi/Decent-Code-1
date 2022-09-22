         real z1,ai1,bi1,aid1,bid1
         integer nfunc1, iscal1            
         z1 = 2.0
          nfunc1 = 0
         iscal1 = 0
         ai1 = 0.0
         bi1 = 0.0
         aid1 = 0.0
         bid = 0.0
         call airy(z1,nfunc1,iscal1,ai1,bi1,aid1,bid1)
         print *, z1,nfunc1,iscal1,ai1,bi1,aid1,bid1
         end      
          SUBROUTINE AIRY(Z, NFUNC, ISCAL, AI, BI, AID, BID)                AIR   10
C P.J.PRINCE, MATHEMATICS DEPARTMENT, TEESSIDE POLYTECHNIC,
C MIDDLESBROUGH, CLEVELAND TS1 3BA, GREAT BRITAIN.
C JANUARY  9, 1975 .
C REFERENCES -
C (1) - ABRAMOWITZ,M. AND STEGUN,I.A. HANDBOOK OF
C       MATHEMATICAL FUNCTIONS. DOVER PUBLICATIONS INC.,
C       NEW YORK, 1965 PAGES 446,448-449,475-477 .
C (2) - FOX,L. AND PARKER,I.B. CHEBYSHEV POLYNOMIALS IN
C       NUMERICAL ANALYSIS. OXFORD UNIVERSITY PRESS,1968
C       PAGES 48-58,65-68 .
C (3) - BOND,GILLIAN AND PITTEWAY,M.L.V. ALGORITHM 301,
C       AIRY FUNCTION(S20). C.A.C.M. VOL. 10,NO. 5, MAY 1967
C THIS SUBROUTINE EVALUATES THE AIRY FUNCTIONS AND THEIR
C DERIVATIVES FOR ANY REAL ARGUMENT WITHIN COMPUTER
C CAPABILITY, BY MEANS OF CHEBYSHEV SERIES APPROXIMATIONS.
C Z          -   THE ARGUMENT FOR WHICH THE FUNCTIONS ARE
C                TO BE EVALUATED.
C AI,BI      -   THE AIRY FUNCTIONS.
C AID,BID    -   THEIR RESPECTIVE DERIVATIVES.
C NFUNC      -   INDICATES WHICH OF THE FUNCTIONS ARE TO BE
C                CALCULATED.
C ISCAL      -   INDICATES WHETHER OR NOT SCALING IS
C                REQUIRED.
C FOUR RANGES OF ARGUMENT Z ARE CONSIDERED -
C (A)  Z .LE. -7.0
C (B)  -7.0 .LT. Z .LE. 0.0
C (C)  0.0 .LT. Z .LT. 7.0
C (D)  Z .GE. 7.0
C THE SUBROUTINES COEF1, COEF2, COEF3 AND COEF4 WHICH ARE
C CALLED BY THIS SUBROUTINE CORRESPOND RESPECTIVELY TO
C THESE FOUR RANGES.
C THE FUNCTIONS CALCULATED ARE AS FOLLOWS -
C IF NFUNC IS NEGATIVE  AID,BID.
C IF NFUNC = 0  ALL FOUR.
C IF NFUNC IS POSITIVE  AI,BI.
C ISCAL INDICATES WHETHER OR NOT IN RANGE (D) THE FOLLOWING
C SCALING IS TO BE CARRIED OUT -
C (AI,AID) = (AI,AID)*EXP(ZETA), (BI,BID) = (BI,BID)*EXP(-ZETA)
C WHERE ZETA = 2.0/3.0*Z**1.5
C IF ISCAL = 0 THEN THERE IS NO SCALING OTHERWISE SCALING
C AS ABOVE.
C IN (A) THE FINAL ACCURACY IS HEAVILY DEPENDENT ON THE
C ACCURACY TO WHICH THE SINE AND COSINE OF
C ANG = 2.0/3.0*(-Z)**1.5+PI/4 CAN BE COMPUTED.
C IF ANGLM .LT. ANG .LE. ANGUP THEN SOME ACCURACY MAY BE
C LOST. A NON FATAL ERROR WARNING IS GIVEN.
C IF ANG .GT. ANGUP A NON FATAL ERROR WARNING IS GIVEN AND
C THE FOUR FUNCTIONS ARE ASSIGNED THE VALUE ZERO.
C IN (D) IF ISCAL = 0 OVERFLOW IN EXP WILL OCCUR IF
C Z .GE. ZLIM. IN THIS CASE A NON FATAL ERROR WARNING IS
C GIVEN AND THE FOLLOWING VALUES ARE ASSIGNED -
C AI = AID = 0.0
C BI = BID = EXP(ZLIM).
C IF ISCAL .NE. 0 OVERFLOW WILL OCCUR IF
C Z .GT. ZUP = ZMAX**(2.0/3.0) WHERE ZMAX IS THE MAXIMUM
C REPRESENTABLE NUMBER ON THE COMPUTER. IN THIS CASE A
C NON FATAL ERROR WARNING IS GIVEN AND THE FOUR FUNCTIONS
C ARE ASSIGNED THE VALUE ZERO.
C NOUT IS THE OUTPUT CHANNEL USED.
C THE MACHINE DEPENDENT CONSTANTS (VALUES BEING ASSIGNED BY
C APPROPRIATE DATA STATEMENTS) ARE -
C IN COEF1  -  ANGLM,ANGUP AND NOUT.
C IN COEF4  -  ZLIM,ZUP AND NOUT.
C FOR I.C.L. 1905E(11S FLOATING POINT ARITHMETIC) -
C ANGLM = 250.0, ANGUP = 1.0E10, NOUT = 2, ZLIM = 175.0,
C ZUP = 1.0E50, ZMAX = 5.6E76 .
      IF (Z) 10, 10, 40
   10 IF (Z+7.0) 20, 20, 30
   20 CALL COEF1(Z, NFUNC, AI, BI, AID, BID)
      RETURN
   30 CALL COEF2(Z, NFUNC, AI, BI, AID, BID)
      RETURN
   40 IF (Z-7.0) 50, 60, 60
   50 CALL COEF3(Z, NFUNC, AI, BI, AID, BID)
      RETURN
   60 CALL COEF4(Z, NFUNC, ISCAL, AI, BI, AID, BID)
      RETURN
      END
      SUBROUTINE COEF1(Z, NFUNC, AI, BI, AID, BID)                      COE   10
C THIS SUBROUTINE EVALUATES THE FOUR FUNCTIONS IN THE CASE
C WHEN Z .LE. -7.0 USING CHEBYSHEV SERIES APPROXIMATIONS TO
C THE CORRESPONDING ASYMPTOTIC EXPANSIONS.
      DIMENSION A(5), B(5), C(5), D(5)
      DATA A(1), A(2), A(3), A(4), A(5) /1.1282427601,
     * -0.6803534E-04,0.16687E-06,-0.128E-08,0.2E-10/
      DATA B(1), B(2), B(3), B(4), B(5) /0.7822108673E-01,
     * -0.6895649E-04,0.32857E-06,-0.370E-08,0.7E-10/
      DATA C(1), C(2), C(3), C(4), C(5) /1.1285404716,0.8046925E-04,
     * -0.18161E-06,0.135E-08,-0.2E-10/
      DATA D(1), D(2), D(3), D(4), D(5) /-0.10954855184,
     * 0.7713350E-04,-0.35168E-06,0.388E-08,-0.7E-10/
      DATA PI4 /0.78539816340/
      DATA ANGLM, ANGUP /250.0,1.0E10/
      DATA NOUT /2/
      X = -Z
      SX = SQRT(X)
      Y = X*SX
      ZETA = 0.66666666667*Y
      Z4 = SQRT(SX)
      ANG = ZETA + PI4
C TEST ARGUMENT SIZE FOR SIN AND COS.
      IF (ANGLM-ANG) 10, 40, 40
   10 IF (ANGUP-ANG) 20, 20, 30
   20 WRITE (NOUT,99999) Z, ANG
      AI = 0.0
      BI = 0.0
      AID = 0.0
      BID = 0.0
      RETURN
   30 WRITE (NOUT,99998) Z, ANG
   40 SN = SIN(ANG)
      CN = COS(ANG)
      ZETAI = 1.0/ZETA
      X = 7.0/X
      X = X*X*X
C ARGUMENT SCALED TO RANGE (0,1).
C EVALUATE THE RELEVANT SERIES.
      IF (NFUNC.LT.0) GO TO 50
      CALL CHEB(X, 5, A, FA)
      CALL CHEB(X, 5, B, FB)
      Z4I = 1.0/Z4
      FB = FB*ZETAI
      AI = Z4I*(SN*FA-CN*FB)
      BI = Z4I*(CN*FA+SN*FB)
      IF (NFUNC.GT.0) RETURN
   50 CALL CHEB(X, 5, C, FC)
      CALL CHEB(X, 5, D, FD)
      FD = FD*ZETAI
      AID = -Z4*(CN*FC+SN*FD)
      BID = Z4*(SN*FC-CN*FD)
      RETURN
99999 FORMAT (//38X, 3H***//5X, 28HANGLE OUTSIDE MACHINE RANGE,,
     * 38H THE FOUR FUNCTIONS HAVE BEEN ASSIGNED/5X, 11HTHE VALUE Z,
     * 4HERO.//5X, 4HZ = , E20.8, 10H  ANGLE = , E20.8//38X, 3H***//
     * )
99998 FORMAT (//38X, 3H***//5X, 25HSOME ACCURACY MAY BE LOST,
     * 16H IN SIN AND COS.//5X, 4HZ = , E20.8, 10H  ANGLE = ,
     * E20.8//38X, 3H***//)
      END
      SUBROUTINE COEF2(Z, NFUNC, AI, BI, AID, BID)                      COE   10
C THIS SUBROUTINE EVALUATES THE FOUR FUNCTIONS IN THE CASE
C WHEN -7.0 .LT. Z .LE. 0.0 USING CHEBYSHEV SERIES
C APPROXIMATIONS TO THE CORRESPONDING TAYLOR EXPANSIONS.
      DIMENSION A(17), B(16), C(16), D(17)
      DATA A(1), A(2), A(3), A(4), A(5), A(6), A(7), A(8), A(9),
     * A(10), A(11), A(12), A(13), A(14), A(15), A(16), A(17)
     * /0.11535880704,0.6542816649E-01,0.26091774326,0.21959346500,
     * 0.12476382168,-0.43476292594,0.28357718605,-0.9751797082E-01,
     * 0.2182551823E-01,-0.350454097E-02,0.42778312E-03,
     * -0.4127564E-04,0.323880E-05,-0.21123E-06,0.1165E-07,
     * -0.55E-09,0.2E-10/
      DATA B(1), B(2), B(3), B(4), B(5), B(6), B(7), B(8), B(9),
     * B(10), B(11), B(12), B(13), B(14), B(15), B(16)
     * /0.10888288487,-0.17511655051,0.13887871101,-0.11469998998,
     * 0.22377807641,-0.18546243714,0.8063565186E-01,
     * -0.2208847864E-01,0.422444527E-02,-0.60131028E-03,
     * 0.6653890E-04,-0.590842E-05,0.43131E-06,-0.2638E-07,
     * 0.137E-08,-0.6E-10/
      DATA C(1), C(2), C(3), C(4), C(5), C(6), C(7), C(8), C(9),
     * C(10), C(11), C(12), C(13), C(14), C(15), C(16)
     * /0.7571648463E-01,-0.10150232871,0.7800551669E-01,
     * -0.8324569361E-01,0.10105322731,-0.6578603344E-01,
     * 0.2500140353E-01,-0.625962704E-02,0.111945149E-02,
     * -0.15102718E-03,0.1598086E-04,-0.136545E-05,0.9636E-07,
     * -0.572E-08,0.29E-09,-0.1E-10/
      DATA D(1), D(2), D(3), D(4), D(5), D(6), D(7), D(8), D(9),
     * D(10), D(11), D(12), D(13), D(14), D(15), D(16), D(17)
     * /0.61603048107,0.85738069722,0.86345334421,0.80890228699,
     * -0.50565665369,-0.81829752697,0.77829538563,-0.31201242692,
     * 0.7677186198E-01,-0.1320520264E-01,0.170185698E-02,
     * -0.17177956E-03,0.1401068E-04,-0.94532E-06,0.5374E-07,
     * -0.261E-08,0.11E-09/
      DATA E1, E2, ROOT3 /0.35502805389,0.25881940379,1.7320508076/
      X = -0.29154518950E-02*Z*Z*Z
C ARGUMENT SCALED TO RANGE (0,1).
C EVALUATE THE RELEVANT SERIES.
      IF (NFUNC.LT.0) GO TO 10
      CALL CHEB(X, 17, A, FA)
      CALL CHEB(X, 16, B, FB)
      FA = E1*FA
      FB = E2*Z*FB
      AI = FA - FB
      BI = ROOT3*(FA+FB)
      IF (NFUNC.GT.0) RETURN
   10 CALL CHEB(X, 16, C, FC)
      CALL CHEB(X, 17, D, FD)
      FC = E1*Z*Z*FC
      FD = E2*FD
      AID = FC - FD
      BID = ROOT3*(FC+FD)
      RETURN
      END
      SUBROUTINE COEF3(Z, NFUNC, AI, BI, AID, BID)                      COE   10
C THIS SUBROUTINE EVALUATES THE FOUR FUNCTIONS IN THE CASE
C WHEN 0.0 .LT. Z .LT. 7.0 USING CHEBYSHEV SERIES
C APPROXIMATIONS TO THE CORRESPONDING WEIGHTED FUNCTIONS.
      DIMENSION A(20), B(25), C(22), D(24)
      DATA A(1), A(2), A(3), A(4), A(5), A(6), A(7), A(8), A(9),
     * A(10), A(11), A(12), A(13), A(14), A(15), A(16), A(17),
     * A(18), A(19), A(20) /1.2974695794,-0.20230907821,
     * -0.45786169516,0.12953331987,0.6983827954E-01,
     * -0.3005148746E-01,-0.493036334E-02,0.390425474E-02,
     * -0.1546539E-04,-0.32193999E-03,0.3812734E-04,0.1714935E-04,
     * -0.416096E-05,-0.50623E-06,0.26346E-06,-0.281E-08,
     * -0.1122E-07,0.120E-08,0.31E-09,-0.7E-10/
      DATA B(1), B(2), B(3), B(4), B(5), B(6), B(7), B(8), B(9),
     * B(10), B(11), B(12), B(13), B(14), B(15), B(16), B(17),
     * B(18), B(19), B(20), B(21), B(22), B(23), B(24), B(25)
     * /0.47839902387,-0.6881732880E-01,0.20938146768,
     * -0.3988095886E-01,0.4758441683E-01,-0.812296149E-02,
     * 0.462845913E-02,0.70010098E-03,-0.75611274E-03,
     * 0.68958657E-03,-0.33621865E-03,0.14501668E-03,-0.4766359E-04,
     * 0.1251965E-04,-0.193012E-05,-0.19032E-06,0.29390E-06,
     * -0.13436E-06,0.4231E-07,-0.967E-08,0.135E-08,0.7E-10,
     * -0.12E-09,0.4E-10,-0.1E-10/
      DATA C(1), C(2), C(3), C(4), C(5), C(6), C(7), C(8), C(9),
     * C(10), C(11), C(12), C(13), C(14), C(15), C(16), C(17),
     * C(18), C(19), C(20), C(21), C(22) /-2.2359158747,
     * -0.2638272392E-01,0.95151904332,-0.8383641182E-01,
     * -0.19401303219,0.3580664778E-01,0.2269348562E-01,
     * -0.671179820E-02,-0.152460473E-02,0.75474150E-03,
     * 0.3729934E-04,-0.5653536E-04,0.350796E-05,0.289418E-05,
     * -0.47423E-06,-0.9449E-07,0.3054E-07,0.109E-08,-0.130E-08,
     * 0.8E-10,0.4E-10,-0.1E-10/
      DATA D(1), D(2), D(3), D(4), D(5), D(6), D(7), D(8), D(9),
     * D(10), D(11), D(12), D(13), D(14), D(15), D(16), D(17),
     * D(18), D(19), D(20), D(21), D(22), D(23), D(24)
     * /0.71364662990,0.23777925892,0.28219009446,0.4912480040E-01,
     * 0.6741261353E-01,-0.406308553E-02,0.1544814895E-01,
     * -0.449172894E-02,0.322474426E-02,-0.105361380E-02,
     * 0.41311371E-03,-0.8536169E-04,0.655166E-05,0.960458E-05,
     * -0.641792E-05,0.280308E-05,-0.89454E-06,0.21392E-06,
     * -0.2958E-07,-0.309E-08,0.376E-08,-0.148E-08,0.39E-09,
     * -0.7E-10/
      X = 0.14285714286*Z
      EX = EXP(1.75*Z)
      EY = 1.0/EX
C ARGUMENT SCALED TO RANGE (0,1).
C EVALUATE THE RELEVANT SERIES.
      IF (NFUNC.LT.0) GO TO 10
      CALL CHEB(X, 20, A, AI)
      CALL CHEB(X, 25, B, BI)
C MULTIPLY BY APPROPRIATE WEIGHTING FACTORS.
      AI = AI*EY
      BI = BI*EX
      IF (NFUNC.GT.0) RETURN
   10 CALL CHEB(X, 22, C, AID)
      CALL CHEB(X, 24, D, BID)
C MULTIPLY BY APPROPRIATE WEIGHTING FACTORS.
      AID = AID*EY
      BID = BID*EX
      RETURN
      END
      SUBROUTINE COEF4(Z, NFUNC, ISCAL, AI, BI, AID, BID)               COE   10
C THIS SUBROUTINE EVALUATES THE FOUR FUNCTIONS (SCALED
C UNLESS ISCAL = 0) IN THE CASE WHEN Z .GE. 7.0 USING
C CHEBYSHEV SERIES APPROXIMATIONS TO THE CORRESPONDING
C ASYMPTOTIC EXPANSIONS.
      DIMENSION A(7), B(7), C(7), D(7)
      DATA A(1), A(2), A(3), A(4), A(5), A(6), A(7)
     * /0.56265126169,-0.76136219E-03,0.765252E-05,-0.14228E-06,
     * 0.380E-08,-0.13E-09,0.1E-10/
      DATA B(1), B(2), B(3), B(4), B(5), B(6), B(7)
     * /1.1316635302,0.166141673E-02,0.1968882E-04,0.47047E-06,
     * 0.1769E-07,0.94E-09,0.6E-10/
      DATA C(1), C(2), C(3), C(4), C(5), C(6), C(7)
     * /0.56635357764,0.107273242E-02,-0.910034E-05,0.15998E-06,
     * -0.415E-08,0.14E-09,-0.1E-10/
      DATA D(1), D(2), D(3), D(4), D(5), D(6), D(7)
     * /1.1238058432,-0.230925296E-02,-0.2309457E-04,-0.52171E-06,
     * -0.1907E-07,-0.100E-08,-0.7E-10/
C     DATA ZLIM, ZUP /175.0,1.0E50/
      real ZLIM /175.0/
      real double ZUP /1.0E20/
      DATA NOUT /2/
C TEST FOR OVERFLOW IN Z**1.5 .
      IF (ZUP-Z) 10, 20, 20
   10 WRITE (NOUT,99999) Z
      AI = 0.0
      BI = 0.0
      AID = 0.0
      BID = 0.0
      RETURN
   20 SZ = SQRT(Z)
      Y = Z*SZ
      Z4 = SQRT(SZ)
      IF (ISCAL) 30, 40, 30
   30 EX = 1.0
      EY = 1.0
      GO TO 70
   40 ZETA = 0.66666666667*Y
C TEST FOR OVERFLOW IN EXP
      IF (ZLIM-ZETA) 50, 60, 60
   50 WRITE (NOUT,99998) Z, ZETA
      AI = 0.0
      AID = 0.0
      BI = EXP(ZLIM)
      BID = BI
      RETURN
   60 EX = EXP(ZETA)
      EY = 1.0/EX
   70 X = 18.520259177/Y
C ARGUMENT SCALED TO RANGE (0,1).
C EVALUATE THE RELEVANT SERIES.
      IF (NFUNC.LT.0) GO TO 80
      CALL CHEB(X, 7, A, AI)
      CALL CHEB(X, 7, B, BI)
      Z4I = 1.0/Z4
      AI = Z4I*AI*EY
      BI = Z4I*BI*EX
      IF (NFUNC.GT.0) RETURN
   80 CALL CHEB(X, 7, C, AID)
      CALL CHEB(X, 7, D, BID)
      AID = -Z4*AID*EY
      BID = Z4*BID*EX
      RETURN
99999 FORMAT (//38X, 3H***//5X, 18HOVERFLOW IN Z**1.5//5X, 4HZ = ,
     * E20.8//5X, 41HTHE FOUR FUNCTIONS HAVE BEEN ASSIGNED THE,
     * 12H VALUE ZERO.//38X, 3H***//)
99998 FORMAT (//38X, 3H***//5X, 21HOVERFLOW IN EXP(ZETA)//5X,
     * 4HZ = , E20.8, 9H  ZETA = , E20.8//5X, 18HTHE FOLLOWING VALU,
     * 23HES HAVE BEEN ASSIGNED -//5X, 25HAI = AID = 0.0, BI = BID ,
     * 11H= EXP(ZLIM)//38X, 3H***//)
      END
      SUBROUTINE CHEB(X, N, A, F)                                       CHE   10
C THIS SUBROUTINE APPLIES THE RICE ALGORITHM TO THE SUM
C F(X) = SIGMA-PRIME (R=1 TO N) A(R)*TSTAR-SUB-(R-1)(X)
C WHERE THE TSTAR-SUB-R(X) ARE THE SHIFTED CHEBYSHEV
C POLYNOMIALS.
C X    -    THE ARGUMENT FOR WHICH THE SERIES IS TO BE
C           EVALUATED.  (0.0 .LE. X .LE. 1.0).
C N    -    THE NUMBER OF TERMS OF THE SERIES TO BE SUMMED.
C A(R) -    THE CHEBYSHEV COEFFICIENTS FOR THE SERIES.
C F    -    THE COMPUTED SUM OF THE SERIES.
C     DIMENSION A(25)
      real :: A(N)
      B = 0.0
      D = A(N)
      U = X + X - 1.0
      Y = U + U
      J = N - 1
      DO 10 I=3,N
        C = B
        B = D
        D = Y*B - C + A(J)
        J = J - 1
   10 CONTINUE
      F = U*D - B + 0.5*A(1)
      RETURN
      END


