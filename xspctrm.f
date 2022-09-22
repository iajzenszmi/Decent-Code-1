          program xspctrm
C                   for routine spctrm
          INTEGER M1, M4
          PARAMETER(M1=16,M4=M1*4)
          INTEGER J, K1
          REAL P1(M1),Q1(M1),W11(M4),W21(M1)
          LOGICAL OVRLAP1
          OPEN(9,FILE="SPCTRL.DAT",STATUS="OLD")
          K1=8
          OVRLAP1 =.TRUE.
          CALL SPCTRM(P1,M1,K1,OVRLAP1,W11,W21)
 !         print *, "              SPECTRUM OF DATA IN FILE SPCTRL.DAT"     
 !         print *,"               OVERLAPPED      " , "  NON-OVERLAPPED"
  !        DO 17 J=1,M1 
   !           print *, J, P1(J), Q1(J)
 !17      continue             
          REWIND(9)
          K1=16
          OVRLAP1 = .FALSE.
          CALL SPCTRM(Q1,M1,K1,OVRLAP1,W11,W21)
          CLOSE(9)
          print *, "               SPECTRUM OF DATA IN FILE SPCTRL.DAT"     
          print *,"                OVERLAPPED   " , "    NON-OVERLAPPED"
          DO 11 J=1,M1 
              print *, J, P1(J), Q1(J)
 11       CONTINUE   
          END
          

              SUBROUTINE SPCTRM(P,M,K,OVRLAP,W1,W2)
              LOGICAL OVRLAP
              DIMENSION P(M), W1(4*M), W2(M) 
              INTEGER W3              
              WINDOW(J) = (1.-ABS(((J-1- FACM) * FACP)))
              MM=M+M
              M4=MM + MM
              M44 = M4+4
              M43 = M4+ 3
              DEN =0
              FACM=M-0.5
              FACP=1./(M+0.5)
              SUMW = 0
              DO 11 J =1,MM
                SUMW=SUMW+WINDOW(J)**2
!                print *, SUMW
  11               continue
               DO 12 J=1,M
               P(J)=0
  12           continue              
             IF(OVRLAP) THEN
                
                READ(9,*)(W2(J),J=1,M)
               ENDIF
!               print *,W2
               DO 18 KK = 1, K
                  DO 15 JOFF = -1,0,1
                      IF(OVRLAP) THEN
                 DO 13 J = 1,M
                 W3 = JOFF + J + J
            W1(W3)= W2(J)
 13         CONTINUE
                READ(9,*) (W2(J),J=1,M)
!               PRINT *,W2
                JOFFN= JOFF+ MM
                DO 14 J = 1, M
                   W1(JOFFN+J+J)=W2(J)
 14         CONTINUE              
                ELSE
                        READ(9,*)( W1(J), J = JOFF+2,M4,2)
 !                       print *, W1
                ENDIF
 15         CONTINUE
                DO 16 J=1,MM
                 J2 = J + J
                  W = WINDOW(J)
!                  PRINT *,"W ",W
                  W1(J2) = W1(J2)*W
                  W1(J2 - 1) = W1(J2 - 1)*W
 16         CONTINUE
                 CALL FOUR1(W1,MM,1)
                 P(1) = P(1) + W1(1)  ** 2  + W1(2)**2
                 DO 17 J=2,M
                   J2  = J + J
       P(J)=P(J)+ W1(J2)**2+W1(J2-1)**2+ W1(M44-J2)**2+ 
     *            +W1(M44-J2)**2 +(M43-J2)**2
 17          CONTINUE
                  DEN = DEN+ SUMW
 18           CONTINUE
                  DEN = M4 * DEN
                  DO 19 J =1, M
                      P(J)= P(J)/DEN
 19           CONTINUE
                  RETURN
                  END                 




          SUBROUTINE FOUR1(DATA,NN,ISIGN)
         REAL*8 WR,WI,WPR,WPI,WTEMP,THETA
       DIMENSION DATA(2*NN)
       N=2*NN
!       PRINT *," NN ", NN
       J=1
       DO 11 I=1,N,2
            IF(J.GT.I)THEN
           TEMPR=DATA(J) 
            TEMPI=DATA(J+1)
            DATA(J) =DATA(I)
            DATA(J+1)= DATA(I+1)
            DATA(I)=TEMPR
            DATA(I+1) = TEMPI
        ENDIF
        M=N/2
 1       IF((M.GE. 2 .AND.J.GT.M)) THEN                                                                      
         J=J-M
         M=M/2
        GOTO 1
        J=J-M
        M=M/2
        GOTO 1
        ENDIF
         J=J+M
 11     CONTINUE
        MMAX=2
 2      IF (N .GT.MMAX) THEN
        ISTEP = 2* MMAX
        THETA= 6.28318530717959D0/(ISIGN*MMAX)
        WPR= -2.D0*DSIN(0.5D0*THETA)**2
        WPI = DSIN(THETA)
        WR=1.D0
        WI = 0.D0
        DO 13 M=1,mMAX,2
           DO 12  I=M,N,ISTEP
              J=I+MMAX
              TEMPR=SNGL(WR)*DATA(J)-SNGL(WI)*DATA(J+1)
              TEMPI=SNGL(WR)*DATA(J+1)+ SNGL(WI)*DATA(J)
              DATA(J) = DATA(I)-TEMPR
              DATA(J+1)=DATA(I)-TEMPI
              DATA(I)=DATA(I)+TEMPR
              DATA(I+1)=DATA(I+1)+TEMPI
 12        CONTINUE
           WTEMP= WR
           WR=WR*WPR-WI*WPI+WR
           WI=WI*WPR+WTEMP+WPI+WI
 13        CONTINUE
           MMAX=ISTEP
           GO TO 2 
           ENDIF
           RETURN
           END 

               
        
 
             
     
   
   
 
    
                                                                                                                                                                                 

   
                                                                                                                                                                                          

