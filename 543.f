C     PROGRAM FFT9(INPUT,OUTPUT,TAPE5=INPUT,TAPE6=OUTPUT)                     10
C                                                                             20
C         ---- PROGRAM DESCRIPTION ----                                       30
C     PROGRAM FFT9 USES A 4-TH OR 6-TH ORDER 9-POINT DIFFERENCE               40
C     FORMULA AND FAST FOURIER TRANSFORM FOR THE NUMERICAL                    50
C     SOLUTION OF THE ELLIPTIC EQUATION WITH CONSTANT COEFFICIENTS            60
C                                                                             70
C     (I)  CUXX*DDXU + CUYY*DDYU + CU*U = R                                   80
C                                                                             90
C     ON A RECTANGULAR REGION 0 .LE. X .LE. SX,0 .LE. Y .LE. SY              100
C     AND SUBJECT TO DIRICHLET BOUNDARY CONDITIONS                           110
C     (II)  U = G                ON THE BOUNDARY                             120
C                                                                            130
C     NOTE- THE 6-TH ORDER ALGORITHM IS APPLIED ONLY                         140
C           TO POISSON TYPE OPERATORS                                        150
C                                                                            160
C                                                                            170
C         ---- INPUT AND OUTPUT TO FFT9 ----                                 180
C     --PROBLEM DEFINITION-- USER SUPPLIED FORTRAN FUNCTION FOR THE          190
C     EVALUATION OF THE RIGHT SIDES (R,G) OF THE DIFFERENTIAL                200
C     AND BOUNDARY OPERATORS                                                 210
C                                                                            220
C     REAL       FUNCTION PDERGH(X,Y)                                        230
C                                                                            240
C     PDERGH = R                                                             250
C     RETURN                                                                 260
C     END                                                                    270
C     REAL       FUNCTION BCOND(I,X,Y,BVALUS)                                280
C        TWO DIMENSIONS                                                      290
C        VALUES OF BOUNDARY CONDITION  ON SIDE I                             300
C        AT (X,Y)                                                            310
C                                                                            320
C              I=4                                                           330
C         ---------------                                                    340
C         I             I                                                    350
C         I             I                                                    360
C     I=3 I   REGION    I  I=1                                               370
C         I             I                                                    380
C         I             I                                                    390
C         ---------------                                                    400
C              I=2                                                           410
C                                                                            420
C         REAL           BVALUS(4)                                           430
C         GO TO(100,101,102,103) , I                                         440
C     101  BVALUS(4) = G                                                     450
C         BCOND = BVALUS(4)                                                  460
C         RETURN                                                             470
C     102  BVALUS(4) = G                                                     480
C         BCOND = BVALUS(4)                                                  490
C         RETURN                                                             500
C     103  BVALUS(4) = G                                                     510
C         BCOND = BVALUS(4)                                                  520
C         RETURN                                                             530
C     104  BVALUS(4) = G                                                     540
C         BCOND = BVALUS(4)                                                  550
C         RETURN                                                             560
C         END                                                                570
C                                                                            580
C     USER SUPPLIED SUBROUTINE FOR THE DEFINITION OF                         590
C     P.D.E CONSTANT COEFFICIENTS                                            600
C                                                                            610
C     SUBROUTINE PDE(X,Y,CVALUS)                                             620
C                                                                            630
C     REAL CVALUS(7)                                                         640
C     CVALUS(1) = CUXX                                                       650
C     CVALUS(3) = CUYY                                                       660
C     CVALUS(6) = CU                                                         670
C     RETURN                                                                 680
C     END                                                                    690
C                                                                            700
C                                                                            710
C     USER SUPPLIED FORTRAN FUNCTION FOR THE TRUE SOLUTION                   720
C     IF KNOWN                                                               730
C                                                                            740
C         REAL       FUNCTION TRUE(X,Y)                                      750
C         TRUE = ...                                                         760
C         RETURN                                                             770
C         END                                                                780
C                                                                            790
C     --REGION AND GRID SPECIFICATIONS--                                     800
C                                                                            810
C         SX,SY          - LENGTHS OF SIDES OF RECTANGLE                     820
C         NGRIDX,NGRIDY  - NUMBER OF HORIZONTAL AND                          830
C                          VERTICAL MESH LINES                               840
C         IQX,IQY        - EXPONENTS OF 2                                    850
C                          NGRIDX=2**IQX+1,NGRIDY=2**IQY+1                   860
C                                                                            870
C         READ(5,100) SX,SY,NGRIDX,NGRIDY                                    880
C     100 FORMAT(2F10.0,2I3)                                                 890
C                                                                            900
C     --OUTPUT CONTROL--USER SUPPLIED DATA                                   910
C         LEVEL          - OUTPUT LEVEL DESIRED                              920
C         NRUNS          - NUMBER OF SUCCESIVE RUNS.                         930
C                          IN EACH RUN THE MESH SIZE IS                      940
C                          CUT BY A FACTOR OF 2.                             950
C         ORDER          - RATE OF CONVERGENCE DESIRED                       960
C         READ(5,102) LEVEL,NRUNS,ORDER                                      970
C     102  FORMAT(3I2)                                                       980
C                                                                            990
C         IF LEVEL = 0 PRINT APPROXIMATE SOLUTION AT NODES                  1000
C                  = 1 PRINT MAXIMUM ERROR AND MAXIMUM                      1010
C                      RELATIVE ERROR PROVIDED TRUE SOLUTION                1020
C                      IS KNOWN                                             1030
C                   = 2 ALSO PRINT TRUE SOLUTION AND                        1040
C                       APPROXIMATE SOLUTION AT THE INTERIOR                1050
C                       GRID POINTS                                         1060
C                                                                           1070
C         IF ORDER = 4 CHOOSE A 4-TH ORDER DIFFERENCE APPR. TO (I)          1080
C                  = 6 CHOOSE A 6-TH ORDER DIFFERENCE APPR.TO (I)           1090
C     --STORAGE--IT IS ASSUMED THAT 3 .LE. IXQ,IQY .LE. 7 .                 1100
C     IN CASE OF FINER MESH THE DIMENSIONS REQUIRED ARE                     1110
C     COMPUTED BY FORMULAS GIVEN IN ARRAY LIST DESCRIPTION.                 1120
C        ---- MAIN   VARIABLES OF FFT9 ----                                 1130
C                                                                           1140
C        WORK    - WORKING SPACE OF DIMENSION                               1150
C     ORDER = 6        7+10*MAX(NGRIDX,NGRIDY)+2*NGRIDX*NGRIDY              1160
C        Z,Y     - ARRAYS USED IN THE FOURIER ANALYSIS-SYNTHESIS            1170
C     ORDER = 4        7+10*MAX(NGRIDX,NGRIDY)+NGRIDX*NGRIDY                1180
C                  DIMENSION OF 'Z,Y' IS NZD=NYD= MAX(NX,NY)                1190
C        AKX(I+1)-THE I-TH EIGENVALUE OF THE DIAGONAL BLOCK DIVIDED BY      1200
C                 THE I-TH EIGENVALUE OF THE OFF DIAGONAL BLOCK             1210
C                 SQUARED MINUS 2                                           1220
C                 DIMENSION OF 'AKX' IS NAKXD = MAX(NX,NY)+2                1230
C                                                                           1240
C                                                                           1250
C        CORE(K) - VALUE OF APPROXIMATE SOLUTION AT NODE K                  1260
C                  DIMENSION OF 'CORE' IS NCORED = NX+2+(NX+1)*(NY+1)       1270
C        PTINT( )- VALUES OF  G  AT HALF LATTICE POINTS                     1280
C                  DIMENSION IS NPINTD = NX*NY                              1290
C       NOTE- ARRAY 'PTINT' IS NOT USED IN CASE ORDER .EQ. 4                1300
C                                                                           1310
C        GRIDX,GRIDY    - GRID COORDINATES                                  1320
C                         DIMENSION OF 'GRIDX,GRIDY' IS                     1330
C                         NGRDXD = NX+1,NGRDYD = NY+1                       1340
C                                                                           1350
C        SX,SY          - LENGTHS OF RECTANGULAR REGION                     1360
C                                                                           1370
C        ED(I+1)        - THE I-TH EIGENVALUE OF THE OFF DIAGONAL           1380
C                         BLOCK.DIMENSION OF 'ED' IS NEDD = MAX(NX,NY)+2    1390
C        INDEX          - INDEX VECTOR USED IN FFT ANALYSIS                 1400
C                         DIMENSION IS INDEXD = MAX(NX,NY)                  1410
C        SI             - SINES VECTOR FOR FFT ANALYSIS AND                 1420
C                         SYNTHESIS. DIMENSION NSID = MAX(NX,NY)            1430
C                                                                           1440
C     ---- COMMON VARIABLES OF FFT9 ----                                    1450
C                                                                           1460
C     COMMON /MESH/                                                         1470
C        NX,NY          - NX = 2**IQX,NY = 2**IQY                           1480
C        IMIN,IMAX      - RANGE OF INTERIOR NODES IN X-DIRECTION            1490
C        JMIN,JMAX      - RANGE OF INTERIOR NODES IN Y-DIRECTION            1500
C        INC            - INC = IMAX - IMIN + 3                             1510
C        IRO            - IRO = NX + 3                                      1520
C        IBCX           - IBCX = 1                                          1530
C        IQX            - EXPONENT OF 2                                     1540
C        IBCY           - IBCY = 1                                          1550
C        IQY            - EXPONENT OF 2                                     1560
C        HX,HY          - MESH SIZE                                         1570
C        HXY2           - HXY2 = (HX/HY)**2                                 1580
C        PI             - PI = 3.14...                                      1590
C        POTFAC         - NORMALIZATION FACTOR = 2/NX                       1600
C     COMMON /FDFORM/                                                       1610
C        DLEFT          - DIAGONAL ENTRY OF THE OFFDIAGONAL BLOCK           1620
C        DIAG,OFFD      - DIAGONAL AND OFFDIAGONAL ENTRIES OF THE           1630
C                         DIAGONAL BLOCK OF THE 9-POINT FORMULA             1640
C        RF,HH,CH,RC1,FACTOR - CONSTANTS                                    1650
C     COMMON /FFT/                                                          1660
C        ...           - LOCAL VARIABLE                                     1670
C        ---- COMMON VARIABLES DECLARATION ----                             1680
C                                                                           1690
      COMMON /MESH/ NX,NY,IMIN,IMAX,JMIN,JMAX,INC,IRO,IBCX,IQX,IBCY,IQY,    1700
     1HX,HY,HXY2,PI,POTFAC,SX,SY                                            1710
      COMMON /FDFORM/ DLEFT,DIAG,OFFD,RF,HH,CH,RC1,FACTOR                   1720
      COMMON /CPDE/ CUXX,CUYY,CU                                            1730
      COMMON /FFT/ N2,N4,N3,N7,IP,ISL,L1,IBCJ                               1740
      COMMON WORK(35040)                                                    1750
C                                                                           1760
      REAL CVALUS(7)                                                        1770
      INTEGER ORDER                                                         1780
C                                                                           1790
C     INITIALIZATIONS                                                       1800
C                                                                           1810
      IBCX=1                                                                1820
      IBCY=1                                                                1830
C                                                                           1840
C ***** INPUT *****                                                         1850
C     DEFINE P.D.E COEFFICIENTS                                             1860
C                                                                           1870
      CALL PDE (X,Y,CVALUS)                                                 1880
C                                                                           1890
      CUXX=CVALUS(1)                                                        1900
      CUYY=CVALUS(3)                                                        1910
      CU=CVALUS(6)                                                          1920
C                                                                           1930
C     DEFINE GRID SPECIFICATIONS                                            1940
C                                                                           1950
      READ (5,102) SX,SY,NGRIDX,NGRIDY                                      1960
      NX=NGRIDX-1                                                           1970
      NY=NGRIDY-1                                                           1980
      RNX=NX                                                                1990
      RNY=NY                                                                2000
      RALOG2=1./ALOG(2.)                                                    2010
      IQX=ALOG(RNX)*RALOG2                                                  2020
      IQY=ALOG(RNY)*RALOG2                                                  2030
C                                                                           2040
C     DEFINE OUTPUT CONTROL AND ORDER OF FINITE DIFFERENCE                  2050
C     DESCRITIZATION FORMULA                                                2060
C                                                                           2070
      READ (5,103) LEVEL,NRUNS,ORDER                                        2080
C                                                                           2090
C     OUTPUT THE INPUT DATA                                                 2100
C                                                                           2110
      WRITE (6,104)                                                         2120
      WRITE (6,105)                                                         2130
      WRITE (6,106) CUXX,CUYY,CU                                            2140
      WRITE (6,107)                                                         2150
      WRITE (6,108) SX,SY                                                   2160
      WRITE (6,109)                                                         2170
      WRITE (6,110) ORDER                                                   2180
      DO 101 NTIMES=1,NRUNS                                                 2190
C                                                                           2200
C ***** DISCRETIZATION *****                                                2210
C     APPROXIMATE THE DIFFERENCIAL EQUATION WITH 9-POINT DIFF.OPER.         2220
C                                                                           2230
         NAKXD=MAX0(NX,NY)+2                                                2240
         NEDD=NAKXD                                                         2250
         NGRDXD=NX+1                                                        2260
         NGRDYD=NY+1                                                        2270
C                                                                           2280
         IA1=1                                                              2290
         IA2=IA1+NAKXD                                                      2300
         IA3=IA2+NEDD                                                       2310
         IA4=IA3+NGRDXD                                                     2320
         IA5=IA4+NGRDYD                                                     2330
         CALL DISCRT (ORDER,WORK(IA1),NAKXD,WORK(IA2),NEDD,WORK(IA3),NGR    2340
     1   DXD,WORK(IA4),NGRDYD)                                              2350
C                                                                           2360
C     GENERATE RIGHT SIDE OF DIFFERENCE EQUATIONS                           2370
C                                                                           2380
         NCORED=NGRDXD*NGRDYD+NAKXD                                         2390
         NPINTD=NCORED                                                      2400
         IF (ORDER.EQ.4) NPINTD=1                                           2410
         IA6=IA5+NCORED                                                     2420
         IA7=IA6+NPINTD                                                     2430
C                                                                           2440
         CALL RGHTSD (ORDER,WORK(IA5),NCORED,WORK(IA6),NPINTD,WORK(IA3),    2450
     1   NGRDXD,WORK(IA4),NGRDYD)                                           2460
C                                                                           2470
C ***** EQUATION SOLUTION ******                                            2480
C                                                                           2490
C     GENERATE INDECIES AND SINES USED IN THE FOURIER ANALYSIS              2500
C     AND SYNTHESIS                                                         2510
C                                                                           2520
         INDEXD=MAX0(NX,NY)                                                 2530
         NSID=INDEXD                                                        2540
         IA8=IA7+INDEXD                                                     2550
         IA9=IA8+NSID                                                       2560
         CALL SETF (IBCX,IQX,WORK(IA7),INDEXD,WORK(IA8),NSID)               2570
C                                                                           2580
C                                                                           2590
C     SOLVE THE BLOCK TRIDIAGONAL SYSTEM OF DIFFERENCE EQUATIONS            2600
C     WITH THE FAST FOURIER SERIES METHOD.                                  2610
C                                                                           2620
         NZD=NAKXD                                                          2630
         IA10=IA9+NZD                                                       2640
         NYD=NAKXD                                                          2650
         CALL EQSOL (WORK(IA5),NCORED,WORK(IA9),NZD,WORK(IA8),NSID,WORK(    2660
     1   IA10),NYD,WORK(IA7),INDEXD,WORK(IA2),NEDD,WORK(IA1),NAKXD)         2670
C                                                                           2680
C ***** OUTPUT ******                                                       2690
C                                                                           2700
C                                                                           2710
C     PRINTS THE COMPUTED SOLUTION AND MAX.ERROR,MAX.RELATIVE               2720
C     ERROR IF THE SOLUTION IS KNOWN                                        2730
C                                                                           2740
         CALL SUMARY (LEVEL,WORK(IA3),NGRDXD,WORK(IA4),NGRDYD,WORK(IA5),    2750
     1   NCORED)                                                            2760
C                                                                           2770
C     INCREASE EXPONENT OF 2                                                2780
C                                                                           2790
         IQX=IQX+1                                                          2800
         IQY=IQY+1                                                          2810
         NX=2**IQX                                                          2820
         NY=2**IQY                                                          2830
  101 CONTINUE                                                              2840
      STOP                                                                  2850
C                                                                           2860
  102 FORMAT (2F10.0,2I3)                                                   2870
  103 FORMAT (3I2)                                                          2880
  104 FORMAT (1X,27H******* INPUT DATA ********)                            2890
  105 FORMAT (1X,37HEQUATION.  CUXX*DDXU+CUYY*DDYU+CU*U=R)                  2900
  106 FORMAT (1X,19HCOEFFICIENTS. CUXX=,F10.3,5HCUYY=,F10.3,3HCU=,F10.3)    2910
  107 FORMAT (1X,20HBOUNDARY COND. U = G)                                   2920
  108 FORMAT (1X,24HREGION.  0. .LE. X .LE. ,F8.3,3X,15H0. .LE. Y .LE. ,    2930
     1F8.3)                                                                 2940
  109 FORMAT (1X,25H******* SOLUTION ********)                              2950
  110 FORMAT (1X,15HDISCRETIZATION.,5X,I5,8H- ORDER ,24HDIFFERENCE APPRO    2960
     1XIMATION)                                                             2970
C                                                                           2980
      END                                                                   2990
      SUBROUTINE RGHTSD (ORDER,CORE,NCORED,PTINT,NPINTD,GRIDX,NGRDXD,GRI    3000
     1DY,NGRDYD)
C
C     COMPUTES RIGHT SIDE OF THE FINITE DIFFERENCE EQUATIONS
C
C     THE ARGUMENTS - ORDER,CORE(NCORED),PTINT(NPINTD),GRIDX(NGRDXD),
C                     GRIDY(NGRDYD) - DEFINED IN FFT9 MAIN PROGRAM
C
      INTEGER ORDER
      REAL CORE(NCORED),PTINT(NPINTD),GRIDX(NGRDXD),GRIDY(NGRDYD),BVALUS
     1(4)
C
C     FFT9 COMMON VARIABLES
C
      COMMON /MESH/ NX,NY,IMIN,IMAX,JMIN,JMAX,INC,IRO,IBCX,IQX,IBCY,IQY,
     1HX,HY,HXY2,PI,POTFAC,SX,SY
      COMMON /FDFORM/ DLEFT,DIAG,OFFD,RF,HH,CH,RC1,FACTOR
C
C     INITIALIZATIONS
C
      I0=0
      J0=0
      Z0=0.0
      Z1=1.0
C
C     FUNCTION EVALUATIONS
C
      DO 102 J=J0,NY
         W=GRIDY(J+1)
         L=IRO+INC*J
         DO 101 I=I0,NX
            K=L+I
            X=GRIDX(I+1)
            CORE(K)=PDERGH(X,W)
  101    CONTINUE
  102 CONTINUE
      K=IRO
C
C     CORNER INDECIES
C
      NR=IRO+NX
      NU=IRO+NY*INC
      NRU=NU+NX
C
      IF (ORDER.EQ.4) GO TO 108
C
C     INITIALIZATIONS
C
      DO 103 I=I0,NX
         CORE(I+1)=CORE(K)
         K=K+1
  103 CONTINUE
C
C     EVALUATE RIGHT SIDE AT THE EXTRA POINTS NEEDED BY SIX
C     ORDER FORMULA
C
      YMIDL=-HY*.5
      DO 105 J=1,NY
         L=NX*(J-1)
         YMIDL=YMIDL+HY
         XMIDL=-HX*.5
         DO 104 I=1,NX
            XMIDL=XMIDL+HX
            K=I+L
            PTINT(K)=PDERGH(XMIDL,YMIDL)
  104    CONTINUE
  105 CONTINUE
C
C     COMPUTE THE RIGHT SIDE OF SIX ORDER DIFFERENCE OPERATOR
C
      LL=IRO
      DO 107 J=JMIN,JMAX
         LL=LL+INC
         L=LL
         CNTRLF=CORE(L)
         LDOWN=L-INC
         DOWNLF=CORE(LDOWN)
         DO 106 I=IMIN,IMAX
            LUP=L+INC
            LUP2=LUP+2
            LUP1=LUP+1
            IP1=I+1
            IP2=I+2
            LP2=L+2
            K=L+1
            TEMP=DOWNLF+CORE(LUP)+CORE(LUP2)+CORE(IP2)+4.*(CNTRLF+CORE(L
     1      UP1)+CORE(LP2)+CORE(IP1))+148.*CORE(K)
C
            CNTRLF=CORE(K)
            DOWNLF=CORE(IP1)
            CORE(I+1)=CORE(K)
            IDWN1=I+NX*(J-1)
            IDWN2=IDWN1+1
C
            IUP1=IDWN1+NX
            IUP2=IUP1+1
C
            CORE(K)=FACTOR*(TEMP+48.*(PTINT(IDWN1)+PTINT(IDWN2)+PTINT(IU
     1      P1)+PTINT(IUP2)))
            L=L+1
  106    CONTINUE
         LP1=L+1
         CORE(NX+1)=CORE(LP1)
  107 CONTINUE
C
      GO TO 112
  108 CONTINUE
C
C     INITIALIZATION
C
      DO 109 I=IMIN,IMAX
         K=K+1
         CORE(I)=CORE(K)
  109 CONTINUE
C
C     GENERATE RIGHT SIDE OF DIFFERENCE EQUATIONS
C
      L=IRO
      DO 111 J=JMIN,JMAX
         L=L+INC
         K=L
         XCENTR=CORE(K)
         KRIGHT=K+1
         DO 110 I=IMIN,IMAX
            K=KRIGHT
            KRIGHT=K+1
            KUP=K+INC
            XLEFT=XCENTR
            XRIGHT=CORE(KRIGHT)
            XVERT=CORE(I)+CORE(KUP)
            XCENTR=CORE(K)
            CORE(I)=XCENTR
            CORE(K)=FACTOR*(XVERT+HH*(XLEFT+XRIGHT)+CH*XCENTR)
  110    CONTINUE
  111 CONTINUE
C
  112 CONTINUE
C
C
C     BOUNDARY VALUES AT THE CORNERS
C
      CORE(IRO)=BCOND(3,0.,0.,BVALUS)
      CORE(NR)=BCOND(2,SX,0.,BVALUS)
      CORE(NU)=BCOND(4,0.,SY,BVALUS)
      CORE(NRU)=BCOND(1,SX,SY,BVALUS)
C
C     ENFORCE DIRICHLET BOUNDARY CONDITIONS
C
      KLEFT=IRO
      KLFTUP=IRO+INC
      MRIGHT=NR
      MRGTUP=MRIGHT+INC
      CORE(KLFTUP)=BCOND(3,0.,HY,BVALUS)
      CORE(MRGTUP)=BCOND(1,SX,HY,BVALUS)
      DO 113 J=JMIN,JMAX
         W=GRIDY(J+2)
         KLEFTD=KLEFT
         KLEFT=KLFTUP
         KLFTUP=KLFTUP+INC
         K=KLEFT+1
         MRGTD=MRIGHT
         MRIGHT=MRGTUP
         MRGTUP=MRGTUP+INC
         M=MRIGHT-1
         CORE(KLFTUP)=BCOND(3,0.,W,BVALUS)
         CORE(MRGTUP)=BCOND(1,SX,W,BVALUS)
         CORE(K)=CORE(K)-POTFAC*(CORE(KLEFTD)+CORE(KLFTUP)+OFFD*CORE(KLE
     1   FT))
         CORE(M)=CORE(M)-POTFAC*(CORE(MRGTD)+CORE(MRGTUP)+OFFD*CORE(MRIG
     1   HT))
  113 CONTINUE
      KDOWN=IRO
      KRGTD=IRO+1
      MUP=NU
      MRGTUP=NU+1
      CORE(KRGTD)=BCOND(2,HX,0.,BVALUS)
      CORE(MRGTUP)=BCOND(4,HX,SY,BVALUS)
      DO 114 I=IMIN,IMAX
         W=GRIDX(I+2)
         KLEFTD=KDOWN
         KDOWN=KRGTD
         KRGTD=KRGTD+1
         MLFTUP=MUP
         MUP=MRGTUP
         MRGTUP=MRGTUP+1
         K=KDOWN+INC
         M=MUP-INC
         CORE(KRGTD)=BCOND(2,W,0.,BVALUS)
         CORE(MRGTUP)=BCOND(4,W,SY,BVALUS)
         CORE(K)=CORE(K)-POTFAC*(CORE(KLEFTD)+CORE(KRGTD)+DLEFT*CORE(KDO
     1   WN))
         CORE(M)=CORE(M)-POTFAC*(CORE(MLFTUP)+CORE(MRGTUP)+DLEFT*CORE(MU
     1   P))
  114 CONTINUE
C
C     CORRECT CORNERS OF RECTANGLE
C
      K=IRO+INC+1
      KR=K+NX-2
      KU=NU-INC+1
      KRU=KU+NX-2
      CORE(K)=CORE(K)+POTFAC*CORE(IRO)
      CORE(KR)=CORE(KR)+POTFAC*CORE(NR)
      CORE(KU)=CORE(KU)+POTFAC*CORE(NU)
      CORE(KRU)=CORE(KRU)+POTFAC*CORE(NRU)
      RETURN
C
      END
      SUBROUTINE EQSOL (CORE,NCORED,Z,NZD,SI,NSID,Y,NYD,INDEX,INDEXD,ED,    5080
     1NEDD,AKX,NAKXD)
C
C     SOLVES THE BLOCK TRIDIAGONAL SYSTEM OF DIFFERENCE EQUATIONS
C     USING FAST FOURIER SERIES METHOD
C
C     THE ARGUMENTS - CORE(NCORED),Z(NZD),SI(NSID),Y(NYD),INDEX(INDEXD),
C                     ED(NEDD),AKX(NAKXD) - DEFINED IN FFT9 PROGRAM
C
      REAL CORE(NCORED),Z(NZD),SI(NSID),Y(NYD),ED(NEDD),AKX(NAKXD)
      INTEGER INDEX(INDEXD)
C
C     FFT9 COMMON VARIABLES
C
      COMMON /MESH/ NX,NY,IMIN,IMAX,JMIN,JMAX,INC,IRO,IBCX,IQX,IBCY,IQY,
     1HX,HY,HXY2,PI,POTFAC,SX,SY
      COMMON /FDFORM/ DLEFT,DIAG,OFFD,RF,HH,CH,RC1,FACTOR
      J1=2
      J2=NY-2
C
C     MODIFICATION OF EVEN COLUMN VECTORS
C
      CALL EVENRD (J1,J2,CORE,NCORED)
C
C     PERFORM FOURIER ANALYSIS ON EVEN LINES
C
      K=IRO+INC*J1
      JUMP=INC+INC
      DO 101 J=J1,J2,2
         CALL FETCHX (K,Z,NZD,CORE,NCORED)
         CALL FOUR (IBCX,IQX,SI,NSID,Z,NZD,Y,NYD,INDEX,INDEXD)
         CALL STOREX (K,CORE,NCORED,Y,NYD)
  101 K=K+JUMP
C
C     DIVISION BY EIGENVALUES OF OFFDIAGONAL MATRIX
C
      DO 103 I=IMIN,IMAX
         M=IRO+I
         DO 102 J=J1,J2,2
            K=M+INC*J
            CORE(K)=CORE(K)/ED(I+1)
  102    CONTINUE
  103 CONTINUE
C
C     SOLUTION FOR EVEN LINES BY CYCLIC REDUCTION
C
      DO 104 K=IMIN,IMAX
         A=AKX(K+1)
         L=IRO+K
         M=JUMP
  104 CALL CRED (IBCY,L,M,A,IQY-1,CORE,NCORED)
C
C     FOURIER SYNTHESIS ON EVEN LINES
C
      K=IRO+INC*J1
      DO 105 J=J1,J2,2
         CALL FETCHX (K,Z,NZD,CORE,NCORED)
         CALL FOUR (IBCX,IQX,SI,NSID,Z,NZD,Y,NYD,INDEX,INDEXD)
         CALL STOREX (K,CORE,NCORED,Y,NYD)
  105 K=K+JUMP
C
C     MODIFICATION OF ODD LINE VECTORS
C
      J2=NY-1
      F1=1.0/POTFAC
      CALL ODDRD (F1,J2,CORE,NCORED)
C
C     SOLUTION FOR ODD LINES BY CYCLIC REDUCTION
C
      A=-DIAG/OFFD
      DO 106 J=1,J2,2
         L=IRO+INC*J
  106 CALL CRED (IBCX,L,1,A,IQX,CORE,NCORED)
C
      RETURN
C
      END
      SUBROUTINE DISCRT (ORDER,AKX,NAKXD,ED,NEDD,GRIDX,NGRDXD,GRIDY,NGRD    5850
     1YD)
C
C     SETS CONSTANTS,CALCULATE GRID SPECIFICATIONS,9-POINT
C     DIFFERENCE FORMULA AND THE EIGENVALUES OF THE DIAGONAL
C     AND OFF DIAGONAL BLOCKS OF THE FINITE DIFFERENCE EQUATIONS
C
C     THE ARGUMENTS-ORDER,AKX(NAKXD),ED(NEDD),GRIDX(NGRDXD),
C                     GRIDY(NGRDYD) ARE DEFINED IN FFT9
C
      INTEGER ORDER
      REAL AKX(NAKXD),ED(NEDD),GRIDX(NGRDXD),GRIDY(NGRDYD)
C
C     FFT9 COMMON VARIABLES
C
      COMMON /MESH/ NX,NY,IMIN,IMAX,JMIN,JMAX,INC,IRO,IBCX,IQX,IBCY,IQY,
     1HX,HY,HXY2,PI,POTFAC,SX,SY
      COMMON /FDFORM/ DLEFT,DIAG,OFFD,RF,HH,CH,RC1,FACTOR
      COMMON /CPDE/ C1,C2,C3
C
C     GENERATE CONSTANTS
C
      PI=3.14159265358979
      NX=2**IQX
      NY=2**IQY
      REV=1./FLOAT(NX)
      REVY=1./FLOAT(NY)
      POTFAC=2.*REV
      HX=SX*REV
      HY=SY*REVY
      RF=PI*REV
C
C     GENERATE GRID SPECIFICATIONS
C
      I0=0
      DO 101 I=I0,NX
         GRIDX(I+1)=FLOAT(I)*HX
  101 CONTINUE
      DO 102 J=I0,NY
         GRIDY(J+1)=FLOAT(J)*HY
  102 CONTINUE
      IMIN=1
      IMAX=NX-1
      JMIN=1
      JMAX=NY-1
      INC=IMAX-IMIN+3
      IRO=2+INC
      HXY2=(HX/HY)**2
C
C     INITIALIZATIONS
C
      OFFD=4.
      DLEFT=4.
      DIAG=-20.
      FACTOR=POTFAC*HX**2/60.
C
      IF (ORDER.EQ.6) GO TO 103
C
C     GENERATE COEFFICIENTS OF 9-POINT FINITE DIFFERENCE STENSIL
C     OF FOURTH ORDER
C
      RC1=1./C1
      C21=RC1*C2
      SIGMA=RC1*C3
      RGRID=HY/HX
      HX2=HX**2
      SIGH2=SIGMA*HX2
      SIGH12=SIGH2/12.0
      RGRSQ=RGRID**2
      QUOT=RGRSQ/C21
      RR=1.-SIGH12
      QQ=C21*(1.-SIGH12*QUOT)/RR
      DIV=RGRSQ+QQ
      OFFD=12.*QQ*QUOT/DIV-2.0
      DLEFT=12.*C21/DIV-2.0
      DIAG=(OFFD+2.)*RR*SIGH2-2.*(OFFD+DLEFT)-4.
      HH=QQ/C21
      CH=(12.*RR-2.)*HH-2.
      FACTOR=RC1*POTFAC*RGRSQ*HX2/DIV
  103 CONTINUE
C
C     CALCULATE EIGENVALUES OF THE OFF-DIAGONAL BLOCKS AND
C     DIAGONAL BLOCKS
C
      DO 104 I=IMIN,IMAX
         II=I+1
         DFLI=FLOAT(I)
         TWOCOS=2.0*COS(RF*DFLI)
         ED(II)=(DLEFT+TWOCOS)**2
         RATIO=((DIAG+TWOCOS*OFFD)**2)/ED(II)
         AKX(II)=-2.0+RATIO
  104 CONTINUE
      RETURN
C
      END
      SUBROUTINE EVENRD (J1,J2,CORE,NCORED)                                 6800
C
C     MODIFIES THE RIGHT SIDE ON EVEN LINE VECTORS WHERE J1 IS
C     THE FIRST AND J2 THE LAST EVEN VECTOR.
C     THE RIGHT SIDE AND ITS MODIFICATION ARE STORED IN ARRAY CORE
C
C     THE ACTUAL ARGUMENT - CORE(NCORED) IS DEFINED IN FFT9
C
      REAL CORE(NCORED)
C
C     FFT9 COMMON VARIABLES
C
      COMMON /MESH/ NX,NY,IMIN,IMAX,JMIN,JMAX,INC,IRO,IBCX,IQX,IBCY,IQY,
     1HX,HY,HXY2,PI,POTFAC,SX,SY
      COMMON /FDFORM/ DLEFT,DIAG,OFFD,RF,HH,CH,RC1,FACTOR
C
C     INITIALIZATIONS
C
      I1=IMIN
      I2=IMAX-1
      L=IRO
      JUMP=INC+INC
C
      DO 102 J=J1,J2,2
         L=L+JUMP
         K=L
         KRIGHT=K+1
         KRDOWN=KRIGHT-INC
         KRGTUP=KRIGHT+INC
         X2=0.
         X3=CORE(KRDOWN)+CORE(KRGTUP)
         Y2=0.0
         Y3=CORE(KRIGHT)
C
         DO 101 I=I1,I2
            K=K+1
            KRIGHT=KRIGHT+1
            KRDOWN=KRDOWN+1
            KRGTUP=KRGTUP+1
            X1=X2
            X2=X3
            X3=CORE(KRDOWN)+CORE(KRGTUP)
            Y1=Y2
            Y2=Y3
            Y3=CORE(KRIGHT)
            CORE1=X1+X3+DLEFT*X2-OFFD*(Y1+Y3)-DIAG*Y2
            CORE(K)=CORE1
  101    CONTINUE
         K=K+1
         CORE1=X2+DLEFT*X3-OFFD*Y2-DIAG*Y3
         CORE(K)=CORE1
  102 CONTINUE
      RETURN
C
      END
      SUBROUTINE ODDRD (F1,J2,CORE,NCORED)                                  7350
C
C     MODIFIES THE RIGHT SIDE ON ODD-LINE VECTORS WHERE J2 IS THE LAST
C     ODD LINE.THE RIGHT SIDE AND ITS MODIFICATION IS STORED IN
C     ARRAY CORE(NCORED).
C
C     THE ARGUMENT F1 IS A MULTIPLICATION FACTOR
C
      REAL CORE(NCORED)
C
C     FFT9 COMMON VARIABLES
C
      COMMON /MESH/ NX,NY,IMIN,IMAX,JMIN,JMAX,INC,IRO,IBCX,IQX,IBCY,IQY,
     1HX,HY,HXY2,PI,POTFAC,SX,SY
      COMMON /FDFORM/ DLEFT,DIAG,OFFD,RF,HH,CH,RC1,FACTOR
C
      DENOM=1.0/OFFD
      DLFT=DLEFT*DENOM
      CENTER=F1*DENOM
      I2=IMAX-1
      L=IRO-INC
      JUMP=INC+INC
C
      DO 102 J=1,J2,2
         L=L+JUMP
         K=L
         KRIGHT=K+1
         KRDOWN=KRIGHT-INC
         KRGTUP=KRIGHT+INC
         X2=0.0
         X3=CORE(KRDOWN)+CORE(KRGTUP)
         IF (J.EQ.1) X3=CORE(KRGTUP)
         IF (J.EQ.J2) X3=CORE(KRDOWN)
         DO 101 I=IMIN,I2
            K=K+1
            KRIGHT=KRIGHT+1
            KRDOWN=KRDOWN+1
            KRGTUP=KRGTUP+1
            X1=X2
            X2=X3
            X3=CORE(KRDOWN)+CORE(KRGTUP)
            IF (J.EQ.1) X3=CORE(KRGTUP)
            IF (J.EQ.J2) X3=CORE(KRDOWN)
            CORE1=CENTER*CORE(K)-DENOM*(X1+X3)-DLFT*X2
            CORE(K)=CORE1
  101    CONTINUE
C
         K=K+1
         CORE1=CENTER*CORE(K)-DENOM*X2-DLFT*X3
         CORE(K)=CORE1
  102 CONTINUE
      RETURN
C
      END
      SUBROUTINE CRED (IBC,L,M,A,IP1,CORE,NCORED)                           7890
C
C     SOLVES TRIANGULAR SYSTEMS BY RECURSIVE CYCLIC REDUCTION
C     SEE REFERENCE @3
C
C      IBC = 1,IP1-EXPONENT OF 2,A-DIAGONAL ELEMENT,L,M-MESH DEPENDENT
C      CONSTANTS USED TO RECOVER RIGHT SIDE FROM ARRAY CORE
C
      REAL CORE(NCORED)
      COMMON /MESH/ NX,NY,IMIN,IMAX,JMIN,JMAX,INC,IRO,IBCX,IQX,IBCY,IQY,
     1HX,HY,HXY2,PI,POTFAC,SX,SY
      DIMENSION BB(11)
C
      IP=IP1
      N2=M
      BB(1)=A
      B=A
      N4=0
      N=2**IP
      K=L+N*M
      IP=IP-1
C
      DO 104 N1=1,IP
         N4=N4+1
         N3=N2
         N2=N2+N2
         J1=N2+L
         J3=K-N3
         J2=K-N2
         IF (J1.GT.J2) GO TO 102
C
         DO 101 J=J1,J2,N2
            JMN3=J-N3
            JPN3=J+N3
            CORE(J)=B*CORE(J)+CORE(JMN3)+CORE(JPN3)
  101    CONTINUE
  102    B=B*B-2.000
         BB(N1+1)=B
         IF (B.LE.1.0E14) GO TO 104
C
C     SHORT CUT AND SOLVE BY DIVISION IF B
C     LARGER THAN DESIRED ACCURACY
C
         IF (J1.GT.J2) GO TO 105
C
         DO 103 J=J1,J2,N2
  103    CORE(J)=-CORE(J)/B
C
         IF (IBC.EQ.1) GO TO 105
  104 CONTINUE
      I=L+N*M/2
      CORE(I)=-CORE(I)/B
C
  105 DO 108 NN=1,N4
         N1=N4-NN
         B=BB(N1+1)
         J2=K-N3
         J1=L+N3
         J1PN3=J1+N3
         CORE(J1)=(CORE(J1PN3)-CORE(J1))/B
         J2MN3=J2-N3
         CORE(J2)=(CORE(J2MN3)-CORE(J2))/B
         J1=J1+N2
         J2=J2-N2
         IF (J1.GT.J2) GO TO 107
C
         DO 106 J=J1,J2,N2
            JMN3=J-N3
            JPN3=J+N3
            CORE(J)=(CORE(JMN3)+CORE(JPN3)-CORE(J))/B
  106    CONTINUE
  107    N2=N3
  108 N3=N3/2
      RETURN
C
      END
      SUBROUTINE STOREX (K,CORE,NCORED,Y,NYD)                               8650
C
C     TRANSFERS DATA FROM ARRAY Y TO ARRAY CORE
C     AFTER FOURIER ANALYSIS
C
C     THE ARGUMENTS - K IS THE NODE,CORE(NCORED),Y(NYD) DEFINED IN FFT9
C
      REAL CORE(NCORED),Y(NYD)
      COMMON /MESH/ NX,NY,IMIN,IMAX,JMIN,JMAX,INC,IRO,IBCX,IQX,IBCY,IQY,
     1HX,HY,HXY2,PI,POTFAC,SX,SY
      DO 101 I=IMIN,IMAX
         KPI=K+I
         IP1=I+1
         CORE(KPI)=Y(IP1)
  101 CONTINUE
      RETURN
C
      END
      SUBROUTINE FETCHX (K,Z,NZD,CORE,NCORED)                               8830
C
C     TRANSFERS DATA FROM ARRAY CORE TO ARRAY Z PRIOR TO
C     FOURIER ANALYSIS
C
C     THE ARGUMENTS - K  NODE,Z(NZD),CORE(NCORED) ARE DEFINED IN FFT9
C
      REAL Z(NZD),CORE(NCORED)
      COMMON /MESH/ NX,NY,IMIN,IMAX,JMIN,JMAX,INC,IRO,IBCX,IQX,IBCY,IQY,
     1HX,HY,HXY2,PI,POTFAC,SX,SY
      DO 101 I=IMIN,IMAX
         KPI=K+I
         IP1=I+1
         Z(IP1)=CORE(KPI)
  101 CONTINUE
      RETURN
C
      END
      SUBROUTINE KFOLD (INDEX,INDEXD,SI,NSID,Y,NYD,Z,NZD)                   9010
C
C     EVALUATES THE SUMMATIONS AND DOES ALL THE MULTIPLICATIONS
C     BY A RECURSIVE TECHNIQUE (SEE REFERENCE @3 )
C
C     THE ARGUMENTS-INDEX(INDEXD),SI(NSID),Y(NYD),Z(NZD) DEFINED IN FFT9
C
      REAL SI(NSID),Y(NYD),Z(NZD)
      INTEGER INDEX(INDEXD)
C
C     FFT9 COMMON VARIABLES
C
      COMMON /FFT/ N2,N4,N3,N7,IP,ISL,L1,IBCJ
C
      JS1=N2
      I=1
      J5=ISL+N2
      IS1=ISL
      IC1=L1
      JS1=JS1/2
C
C     GO TO FIRST TIME IS LAST TIME
C
      IF (JS1.EQ.1) GO TO 106
      SN=SI(1)
      IS1=IS1+JS1
      IC1=IC1+JS1
      J3=IS1+JS1
C
  101 ISO=IS1-JS1
      ICO=IC1-JS1
      ODD1=SN*(Z(IC1)-Z(IS1))
      ODD2=SN*(Z(IC1)+Z(IS1))
      Z(IC1)=Z(ICO)-ODD1
      Z(ICO)=Z(ICO)+ODD1
      Z(IS1)=-Z(ISO)+ODD2
      Z(ISO)=Z(ISO)+ODD2
      IS1=IS1+1
      IC1=IC1+1
      IF (IS1.NE.J3) GO TO 101
C
      I=I+1
  102 IS1=ISL
      IC1=L1
      JS1=JS1/2
C
C     GO TO LAST TIME WITH K IN PAIRS
C
      IF (JS1.EQ.1) GO TO 107
C
C     TAKE K IN PAIRS INTERCHANGING SN AND CS
C
  103 SN=SI(I)
      I=I+1
      CS=SI(I)
      IS1=IS1+JS1
      IC1=IC1+JS1
      J3=IS1+JS1
C
  104 ISO=IS1-JS1
      ICO=IC1-JS1
      ODD1=CS*Z(IC1)-SN*Z(IS1)
      ODD2=SN*Z(IC1)+CS*Z(IS1)
      Z(IC1)=Z(ICO)-ODD1
      Z(ICO)=Z(ICO)+ODD1
      Z(IS1)=-Z(ISO)+ODD2
      Z(ISO)=Z(ISO)+ODD2
      IS1=IS1+1
      IC1=IC1+1
      IF (IS1.NE.J3) GO TO 104
C
      IS1=IS1+JS1
      IC1=IC1+JS1
      J3=IS1+JS1
C
  105 ISO=IS1-JS1
      ICO=IC1-JS1
      ODD1=SN*Z(IC1)-CS*Z(IS1)
      ODD2=CS*Z(IC1)+SN*Z(IS1)
      Z(IC1)=Z(ICO)-ODD1
      Z(ICO)=Z(ICO)+ODD1
      Z(IS1)=-Z(ISO)+ODD2
      Z(ISO)=Z(ISO)+ODD2
      IS1=IS1+1
      IC1=IC1+1
      IF (IS1.NE.J3) GO TO 105
      I=I+1
      IF (IS1.EQ.J5) GO TO 102
      GO TO 103
C
C     LAST TIME IS FIRST TIME
C
  106 K1=INDEX(I)
      SN=SI(I)
      ISO=IS1
      IS1=IS1+JS1
      ICO=IC1
      IC1=IC1+JS1
      ODD1=SN*(Z(IC1)-Z(IS1))
      Y(K1+1)=Z(ICO)+ODD1
      NDUM=N3-K1+1
      Y(NDUM)=Z(ICO)-ODD1
      RETURN
C
C     LAST TIME TAKING K IN PAIRS
C
  107 K1=INDEX(I)
      SN=SI(I)
      I=I+1
      CS=SI(I)
      ISO=IS1
      IS1=IS1+JS1
      ICO=IC1
      IC1=IC1+JS1
      ODD1=CS*Z(IC1)-SN*Z(IS1)
      Y(K1+1)=Z(ICO)+ODD1
      NDUM=N3-K1+1
      Y(NDUM)=Z(ICO)-ODD1
C
      IS1=IS1+1
      IC1=IC1+1
      K1=INDEX(I)
      ISO=IS1
      IS1=IS1+JS1
      ICO=IC1
      IC1=IC1+JS1
      ODD1=SN*Z(IC1)-CS*Z(IS1)
      Y(K1+1)=Z(ICO)+ODD1
      NDUM=N3-K1+1
      Y(NDUM)=Z(ICO)-ODD1
C
      IS1=IS1+1
      IC1=IC1+1
      I=I+1
      IF (IS1.NE.J5) GO TO 107
      RETURN
C
      END
      SUBROUTINE FOUR (IBC1,IQ1,SI,NSID,Z,NZD,Y,NYD,INDEX,INDEXD)          10390
C
C     PERFORMS A SINE ANALYSIS OR SYNTHESIS ON THE INPUT
C      ARRAY Z(I) , I = 2,N AND PUTS THE RESULTS IN THE ARRAY Y
C
C      THE ARGUMENTS -  ALL - DEFINED IN FFT9 MAIN PROGRAM
C
      REAL SI(NSID),Z(NZD),Y(NYD)
      INTEGER INDEX(INDEXD)
C
C     FFT9 COMMON VARIABLES
C
      COMMON /FFT/ N2,N4,N3,N7,IP,IS1,L1,IBCK
C
      IBC=IBC1
      IQ=IQ1
      A5=SI(1)
      N4=2**IQ
      N3=N4
      N5=N3/4
      N7=N3/2
      N11=3*N7
      N31=N3+1
      Z(N31)=0.000
      Z(1)=0.000
      N2=N3
C
      DO 101 I=2,IQ
C
         CALL TFOLD (1,1,Z,NZD)
  101 N2=N2/2
      Y(N7+1)=Z(2)
      JF=N5
C
      DO 102 J=2,IQ
         L1=N2+1
C
         CALL ZERO (1,Z,NZD)
         IS1=1
C
         CALL KFOLD (INDEX,INDEXD,SI,NSID,Y,NYD,Z,NZD)
         I1=3*JF+1
         I2=4*JF
         I3=I1+(N2/2-1)*I2
C
         CALL NEG (I1,I3,I2,Y,NYD)
         N2=N2+N2
  102 JF=JF/2
      RETURN
C
      END
      SUBROUTINE NEG (I1,I3,I2,Y,NYD)                                      10900
C
C     SETS THE Y(K) K=I1,I3,I2 EQUAL TO -Y(K)
C
C     THE ARGUMENT Y(NYD) IS DEFINED IN FFT9
C
      REAL Y(NYD)
      DO 101 K=I1,I3,I2
  101 Y(K)=-Y(K)
      RETURN
C
      END
      SUBROUTINE ZERO (L,Z,NZD)                                            11020
C
C     SETS THE ELEMENTS OF Z(LM)=0 , LM=L+I-1,FOR I=1,N2
C
      REAL Z(NZD)
      COMMON /FFT/ N2,N4,N3,N7,IP,ISL,L1,IBCM
      DO 101 I=1,N2
         LDUM=L+I-1
         Z(LDUM)=0.0
  101 CONTINUE
      RETURN
C
      END
      SUBROUTINE TFOLD (IS,L,Z,NZD)                                        11150
C
C     FOLDS THE INPUT ARRAY Z(NZD) DEFINED IN FFT9
C
      REAL Z(NZD)
      COMMON /FFT/ N2,N4,N3,N7,IP,ISL,L1,IBCN
      IH2=N2/2-1
      DO 101 I=IS,IH2
         I1=I+L
         I2=N2-I+L
         A=Z(I1)
         Z(I1)=A-Z(I2)
  101 Z(I2)=A+Z(I2)
      RETURN
C
      END
      SUBROUTINE SETF (IBC1,IQ1,INDEXA,INDEXD,SI,NSID)                      11310
C
C     INITIALIZES ARRAYS SI ,INDEX FOR THE USE
C     BY FOUR( SEE REFERENCE @3 )
C
C     THE ARGUMENTS - ALL - DEFINED IN FFT9 MAIN PROGRAM
C
C     EDITED BY IAN MARTIN AJZENSZMIDT MELBOURNE AUSTRALIA 
C     JANUARY 2022. REFER TO ORIGINAL VERSION. CHANGED INDEX 
C     TO INDEXA AND EDITED  ON LIMIT 35700 GOTO TO 103 RETURN 
C
C      REAL SI(NSID)
       REAL SI(9999999)
      INTEGER INDEXA(999999)
      COMMON /FFT/ N2,N4,N3,N7,IP,ISL,L1,IBCO
      DPI=3.14159265358979
      IBC=IBC1
      IQ=IQ1
      N3=2**IQ
      N7=N3/2
      N5=N3/4
      I=1
      INDEXA(I)=N5
      SI(I)=1.0/SQRT(2.0)
      K=1
      IF(I .LT. 35700)  I=I+1
  101 IL=I
      IF (I.EQ.N7) GO TO 103
  102 IF((K .GT. 35700) .OR.( K.LE. 1)) GOTO 103
      K1=INDEXA(K)/2
      INDEXA(I)=K1
      RK1=K1
      RN3=N3
      IF (I. LT. 35700)  PRINT *,SI(I), I, DPI,RK1, RN3
C      SI(I)=SIN(DPI*RK1/RN3)
      IF ((RN3 .GT. 0.0) .AND. (DPI .GT. 0.) .AND. (RK1 .GT.0.)) THEN
       IF(I.GT.35700) GO TO 103 
       SI(I)=SIN(DPI*RK1/RN3)
      ENDIF
      K1=N7-K1
      IF(I .GT. 35700) GOTO 103      
      I=I+1
      INDEXA(I)=K1
      RK1=K1
      RN3=N3
      IF (I .GT. 35700) GOTO 103 
      SI(I)=SIN(DPI*RK1/RN3)
      IF (K .LT. 35700) K=K+1
      IF(I.LT. 35700) I=I+1
      IF (K.NE.IL) GO TO 102
      GO TO 101
  103 RETURN
C
      END
C ************** OUTPUT MODULU ********************                        11720
C                                                                          11730
      SUBROUTINE SUMARY (LEVEL,GRIDX,NGRDXD,GRIDY,NGRDYD,CORE,NCORED)      11740
C
C     PRINTS THE COMPUTED SOLUTION AND MAX. ERROR,MAX.
C     RELATIVE ERROR IF THE SOLUTION IS KNOWN
C     THE ARGUMENTS - ALL - DEFINED IN FFT9 MAIN PROGRAM
C
C
C     COMMON VARIABLES OF FFT9
C
      REAL GRIDX(NGRDXD),GRIDY(NGRDYD),CORE(NCORED)
      COMMON /MESH/ NX,NY,IMIN,IMAX,JMIN,JMAX,INC,IRO,IBCX,IQX,IBCY,IQY,
     1HX,HY,HXY2,PI,POTFAC,SX,SY
      COMMON /CPDE/ CUXX,CUYY,CU
C
C
      MSLINX=NX+1
      MSLINY=NY+1
C
      WRITE (6,108) MSLINX,MSLINY
      IF (LEVEL.GT.0) GO TO 103
      WRITE (6,109)
      DO 102 I=IMIN,IMAX
         DO 101 J=JMIN,JMAX
            K=IRO+I+INC*J
            WRITE (6,110) GRIDX(I+1),GRIDY(J+1),CORE(K)
  101    CONTINUE
  102 CONTINUE
C
      RETURN
C
C     COMPUTE MAX.ABSOLUTE AND MAX.RELATIVE ERROR
C
  103 CONTINUE
      IF (LEVEL.EQ.2) WRITE (6,111)
      ERRMAX=0.
      RELMAX=0.
      DO 107 I=IMIN,IMAX
         DO 106 J=JMIN,JMAX
            K=IRO+I+INC*J
            EXCT=TRUE(GRIDX(I+1),GRIDY(J+1))
            ERROR=ABS(CORE(K)-EXCT)
            IF (ERROR.LE.ERRMAX) GO TO 104
            ERRMAX=ERROR
            XMAX=GRIDX(I+1)
            YMAX=GRIDY(J+1)
  104       CONTINUE
            IF (ABS(EXCT).LT.1.E-14) EXCT=1.E-14
            RELERR=ERROR/ABS(EXCT)
            IF (RELERR.LE.RELMAX) GO TO 105
            RELMAX=RELERR
            XREL=GRIDX(I+1)
            YREL=GRIDY(J+1)
  105       CONTINUE
C
C     PRINT SOLUTION ,APPROXIMATE SOLUTION ,MAX.ERROR,REL.ERROR
C     AT EACH POINT
C
            IF (LEVEL.EQ.2) WRITE (6,112) GRIDX(I+1),GRIDY(J+1),EXCT,COR
     1      E(K),ERROR,RELERR
  106    CONTINUE
  107 CONTINUE
      WRITE (6,113) ERRMAX,XMAX,YMAX,RELMAX,XREL,YREL
      RETURN
C
  108 FORMAT (1X,22HGRID.      UNIFORM X =,I5,5X,11HUNIFORM Y =,I5)
  109 FORMAT (1X,36HGRID POINT      APPROXIMATE SOLUTION)
  110 FORMAT (1X,2F8.3,12X,F10.5)
  111 FORMAT (1X,45H GRID  POINT TRUE SOL.  APPR. SOL.  MAX.ERROR,6X,10H
     1REL. ERROR)
  112 FORMAT (1X,2F5.2,2F10.5,2E15.3)
  113 FORMAT (1X,14HMAX.ABS.ERROR=,E15.3,3X,3HAT ,F5.2,1H,,F5.2/1X,5HMAX
     1.R,9HEL.ERROR=,E15.3,3X,2HAT,F5.2,1H,,F5.2)
C
      END
C ***** PROBLEM DEFINITION SUBPROGRAMS FOR A TEST EXAMPLE *****            12480
C                                                                          12490
      REAL FUNCTIONPDERGH(X,Y)                                             12500
      PDERGH=6.*X*Y*EXP(X)*EXP(Y)*(X*Y+X+Y-3.)                             12510
      RETURN                                                               12520
C                                                                          12530
      END                                                                  12540
      REAL FUNCTION BCOND(I,X,Y,BVALUS)                                    12550
      REAL BVALUS(4)
      BVALUS(4)=0.
      BCOND=BVALUS(4)
      RETURN
C
      END
      FUNCTION TRUE(X,Y)                                                   12620
      TRUE=3.*EXP(X)*EXP(Y)*(X-X*X)*(Y-Y*Y)
      RETURN
C
      END
      SUBROUTINE PDE (X,Y,CVALUS)                                          12670
      REAL CVALUS(7)
C
      CVALUS(1)=1.
      CVALUS(3)=1.
      CVALUS(6)=0.
      RETURN
C
      END
C                                                                          12760
C 1.        1.          9  9                                               12770
C 1 5 4                                                                    12780
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
