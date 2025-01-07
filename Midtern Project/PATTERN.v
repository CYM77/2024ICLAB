
`ifdef DRAM_PAT1
    `define DRAM_PAT "../00_TESTBED/DRAM/dram0.dat"
`elsif DRAM_PAT2
    `define DRAM_PAT "../00_TESTBED/DRAM/dram0.dat"
`elsif DRAM_PAT3
    `define DRAM_PAT "../00_TESTBED/DRAM/dram0.dat"
`else
    `define DRAM_PAT "../00_TESTBED/DRAM/dram0.dat"
`endif

`ifdef RTL
    `define CYCLE_TIME 10.0
`elsif GATE
    `ifndef CYCLE_TIME
        `define CYCLE_TIME 10.0
    `endif
`else
    `define CYCLE_TIME 10.0
`endif

`include "../00_TESTBED/pseudo_DRAM.v"

module PATTERN(
    // Input Signals
    clk,
    rst_n,
    in_valid,
    in_pic_no,
    in_mode,
    in_ratio_mode,
    out_valid,
    out_data
);


`protected
Mb&OQC0f-F6V6DgU/VQ2W&9Ob-,#I.#6MKOg&ULL^)(_8/c\YJ:7+)Ve/JCN^SE_
(J1MCTW[;LdEHY>af\R4f&\?.4P[T>C+@$
`endprotected
output reg        clk, rst_n;
output reg        in_valid;

output reg [3:0] in_pic_no;
output reg  in_mode;
output reg [1:0] in_ratio_mode;

input out_valid;
input [7:0] out_data;


`protected
EC19b<\_9.TB_>^d:b#0KZg?O9-Q07a?75BY=Z-7(Q66KMW&O8\+7)5?VS.7/[a6
GD68ME5JUU/79OL@EUaZcEA/G]M_.Q>]96Wg^&M8HMI.5-)0HVRdGaM,9\8BYdb0
be[O+,FSafES):T<>]OJTHa=gW.#NK4FY^_<&)2]aM#=;0(R,(-gG)=e2g4\?c2&
eE^BQRB0g/eLZHfS2YAXLV(7F[bdOFYbOg+?FAV,66L\+V90FaeCQO?EdPSR0#>/
0L/;@+Eg7d<<EFBO<b@[Qd;\-N^DQfOFZ35W>;fKYW&H]1R7\fIO--BBY^5JU9X;
DcS0G6DT0[0MBPAAZ\]>JF7U:N9UaOXB2]I[gP_/)9N4YRQc6e\W/9^CJIKBRKXT
\V-/A;N7)U_B0(+CbRBN-<,\HC&-(EG@_1Y;HbBB@.()U=9QAN]V;+e3UEZgX&;D
aa-)Ce4FP[\:QD/TO_4,C,A@O#9X:fd@==DPCcBD=0#Uc13Me<W@/AN@.Z:1&@2d
a<SgFEd?e_)Yg<d:.#K-c[HM=AaT0:g=e5R_,eIHC_R\^_M[SB_LQ;^TfX0eCCGa
\0AX?<,6bHaJ;N<ITP(?J==GC#P8-ZZQ\eL<HGPg3c1+ZNBg07J@<&<>.)@INc>>
D>;A0gIBSdYC;59[Bd#]\A<YA/d[GGIPSZ>-TMRZ6U>HOV^6TQ7_6-7aSS_+QH-Y
@eNQI=2fZ:2E_[Y4X2dM.N<[FbB02WgF_-@g7:MLV.W[U\ag/<YM>.(JC#V=UY9d
b40YdJ<=\HHHN#[C63?5>@&-3g.eW?[;DW278A-NI3,?;/8W\<fb_RWeeM&GQX8E
W)+H6@(\T+FU/]eOZL5^Q35_HS<98T,;O>0d:X1OeBg/N?gbFG^6H??-7,2QJB<E
,<S0W>D)KNKR^/<@_g1\Wa/L^X@gG59K5=#e(?J[g@3P3e48G+7f;<)812PNLDW(
NEQ;);.UX-#\]UOI,V@=B)E(NO&3,IN6FHQRZO\AJD-NCP[G^O04:3HF0#;LcbgB
2/f[H9f\BZ/V+H3Y\d(5TIGPT,;?/B75.&0&bCQ/N_eYE;T(:STcVeQ=5>&[S^8@
c40;g;Y2I:gK^)PP2CFcJ_0DbU@K=dDGS^R/YRcTffGP?M:E]JYUMSTCO.MP0,7M
>3[e&D49Qe]8[8M^AML0KN.EHJT5d6<LXYJ5C-,U1TR,SAK0OD,aQa\(T14CVgGT
?JJ/_[]Bg,\VDa30<^c&<-gE\3I-32MNA.:,+QW-_a+OfWMUXZ9,<7:a@Z06QP>I
DNfg-IC]\S,f^Zb54XM&gXdWZOMET8f+[\D]1BJg+KU_&Pe4,6D5G];/Me(b1)8J
@[KE8]1G>=1S+H@b2FK;00dAP.3P;MKbeLURCYA?T+YY\f6T+7-faIf@D1HM8F8.
>RaLMH@)c:1LJcY;:e@g4(F1Od<0^/A7U+S@YHBdSa&\OYbF(@Cg&\#R28B7F^1P
G/S02b?eN6T^GH0B,c>)]LEe\LJK)9XXB,E=bO;Y&^=gc207Q\Uab3Vb1&BaV1K=
J:#:Y(M??5P8eWe1:KNC@IP]aUaLH:C])@K\\/(V[43,RcaPbXMIZ;W#5Dc7POMT
G\]G;D=?QOCIa4S@aC(gZO7+N5&IG#fUR<6Y1>Rc:V9PLB@Gd7gR\aD:.SBAZ)>6
:0#bGG,#8;AUdc5RY_P=R+X;EOXZCJ=f[]P6)=+]bCFJH8Z,?+fC0JH.?NfU2/Yf
(DLCZPOT^WI6fQ)AB\.E:TK,4;FJ16M&g/Pf/^FJc2FAf,6)g/-Z-@V5&aW8#44d
+,?U86G1/]NdL&HZ:(MD-2#0=:_gF.(6>YN7Q8^(1?1?CHKHE2gON[O&Q,\RS/<[
+\:\DDM-9DQ@WUB.MAfY\)JeEBDW1F=XFg9eBe#_]G8U\CU2<WReUC(^Bd=@F:R)
VB53PTeXe)GHU^<X(aT9I04EgZ,8SCZOWFV]:,<6)D_g#bb7+EZ;_;HST)WXUQA3
.LdccOC5EE2(T7TbTI]<SH>Lf#+<N@A,WNPY>D_g0K]f.Wa3;O&Zc:dVOD7OB)4Z
V24VSR^?H5P2C^)[f(DAOd)gR98/15S_:b@eU+WUB4B?32d3;(=]BW[B_d3AHH/J
ANMG;c4\4[0,3R6d_]BcPCBf)5,cG)43aRQ]4\?QK9BAZ\e<fP/:SIR);PN/F,_[
^NJXg):D@U+OZ9SQ<X.AXK92K:F3K3gEP=Ha.@/FD>RZ+aFX7?GDDgXR/PQZQS1]
XFD5bA&5[[KJT,>_#5RFV\]LS)J&GIb26d/H5gM:6c=GgC06DS7P^4\;?5a-IXSQ
H/:c:^<C>#FO9M=SaT<bU:G6314,K@cX(+AV13IXS0UN:E;ZEb?,dD2cG]_[3VfY
Sb\XHEA8d2[Q:/HD3(1)^d0G^]JUJB_]Wb2fg;Jc<VRT#=&beE,X4?Ug]=K#EYb<
VBN&MVX3Q36L.,4CfXW^(8=.Z,&3,.EEJ@.L@X/Vd<8(L)A&D<2GL.QKE9gO[;UQ
V\,/YUdF^S&+_cg+faC:3Ea3PS?5(:^.OQP3XP3U3.S_.)Q@D@7IcTGV3^Y9=eDT
,(BJ+W-7&3g6&[F(JL_X7Z7Y;=[KY^+>>U?2#RS#CR1PCY7C1IVEWBO5X/:_Y<:;
.=-V:\;N):^\Y3R,gS_6TPW:F,dW;6RB-W&_</IZe7);DefG],7<3f.dZ&_b]CU7
ZG3,@YQ9FO?::7EdA;fV3Xg-1eHfP[D#QQ6cHH9SR;EZ\Z+^2?V)6bQcbK@bb5W@
;8>KdPO,=XF<?::SI8g_N.Tg4)G.81<dE#56E=FD+>?++N8CK\5>_PP]98FA;/2=
-LFF3H8;MJTP7fI.4:<0_UG#Y-DN,O42FD>3J#8#9X=+EZ9Z,gQfgc3VK0JD,>WJ
2W>?+W<Y6&0K>GVRHO2SD1Y0^Q)_6V+4./1)1N2gJ3T6:;<2>>a;6Z4/P<(1_+F@
?a^1fX8&eKe@YPL3T@gTD<^(a9P;6>A=ZBafWa5Za[RZGU[WO/S[aE&7\fAX_f86
g_Vc=)^A-=VN13?]MfOC+J[[_8FX?XX2Z7OE/NgTV@g5_3JUc.;B<I+fGN[Ga45,
DeV3U^4XXWKB@=0G;40ee7D(+=B@>COW.Q4I1):ICSH4RMK+6A=TG/72.<bJLI,/
-8<[/W:gI?HYDW<EZ_9NBCH\J(g7D)L\-0&.^C5D_?Y-=CM(;U<0VG9?,]/:DZ3/
V/c&b?=gKg]S9WGO7&-Vd@(R>@V<.Ud01^?S#3[eQeB&Be>[..-__.^3#AdZ)HIF
Z=EQE^#c;cOLMFTGB7UG391YB,##_dE3<DUcdZ_6,d[VW;Q?SCCV(=CF2LTgYR8.
^DN(Y^GUd^?AZ1#aJMSPbD-610&G/T>(^P44P+U>X_K;beG9SYGHdfC=WW4Z=Y^9
B[]b5V+&:g#c14dGFE223^cYNN&-R3RFUX?@YE.]D;1c/[aT:6eAZ?W6FS,2Yd(M
N,85)CK?E2#gA0_dWaaPA]0#2)/3ESL(-U+-1>2,(b[IJ,X\@B&K#TbA4QXR_4cO
L-QcQ<+9#F\e6:R/X/(PdegOW]G<GO;1QYb1^7UKJcgU/OSLfbVD+f@c;/Bb]G.0
OJU-dD]b2GTZ\2RUD@O^TB&^MW&J20Vd4Bgc7+f8YY#X:0X9=b\L?)[OLVf:aMIc
@I1-E/F_fF[XKEMHd-DNcYG.Y[@E1/2KINe6;Y063,MM[W/9E7bB52B/ddd.(\:>
Ic9=<S2LT?5,#SR0d[?7YI9=C5O6L9?&M=fV_C.7T=QGW))N?HL/9@D?@@CZ0,0+
CI,Z5T9cDa9/A^1]LIF\<B\SD8]E0daeJPLKAN=\;3?SPBWH^<3@/g<7-dB7S(-O
GXRPMK,Vd93ON/U]?QB,PZG#b,6PRWe\?b.)[61H>7XR/-5+Q7G+#;f09YeEEN,e
/D9=YQ\5Vf]-3g[V.+5QPe6cCI&3cZ:O+5W.HN/b4AHK7U3PDO.aAH\Jd;CQOJH[
+Q.VM)HA9E\d[RC-SeS\\7WR1719<](#Z5;@XB&LP,0U[UY<>S1BLUJP4.f?L8-?
;)>QLe:NH5F\Y3g?0IE0/P,\OZ+]f)_XFbbU&HPIDYZK)69IE:1gV830LR5.Q-N(
,VN/e_2[ES2eE1\B.Y9GFT6,1O=R)E\Vg333gbbTWe[[X+GJ-7>,(c=8]OS)5N0@
WbEHW.P0BN_Q;F9W505RH5(>)TFbC>?)8fX8_H4a5J@<XGRZdWaSFJ4V<Ac<fYY[
AgA?O<?:::3U]F,-K,O2Ee3-g8).LFe>E10D0/I+-/U^(KOU\:@Z[4AQ]UXK5^c[
VO>^cCKRT\gB>cTLT8E15CgQDZa+6OJ\Fg6^WLWRNAB(?eX[VEc[(?JG=[,\HdH5
g#WPb+K=)WB[LL^.,^21N949[=CT,-=6B>.IZ0N+>XgMZ6H]2M<J[-G<>F+fg)3,
b-[?Fe;]H&I51K4dX)dfA4,B,&8Bg5/4^8J-:aLRd+3;5\a-?g4PIP[Lc=>3D]Z+
dL8aN&gX&:;/<Z6&1Z/1?NcD6(S4+gW]dM@fAE&P#BH89.]@5A/C[6VT3H]>&DK.
5Z\]E0[3A0X)6EP?e-GAPJ@cXbJ63IM[c>W9Qfe.GDQGK;c&:N]J:J+;MT+0O67L
MY<N(7L5N[/f7@&M^XU<e<.^HG5&V_fa,<S?]0VR@adS\.,D3AXbQ&[N5CZ4[d.<
\3F(TXP7DBM_0NIE;b<BW,&EPR&G-SD<G;a:^Q:1<HSYIaVSD4BC<HG#KKf]#+FF
NC]56?@B2QNOcVV[[NG39S?5[W]/=\CT81CP>K7-80U8G(IKG6_-.OecI#ZX2:M+
V]d\/P7^&K^EOI(0318+)1_:cGf:4fN&d\2U/#MZVFQdD_eX1b4J=0RB#e\?CJ2^
Q;W(1MUe>\;6U-4#N&,8^P&0S;8b:4@Y@NcV_5K85-A8&@W^&>G#K6L+1NT>UXQ[
E>7U01F25Jf+CHE:Ia-.SGcFMbf9/VRVd=Nb1]H]N\d3e<Z>UNb_.X.cJ@R=UEQc
E+35<0PWdNN&0RW+cfSc_O@50M#UcFXT5R;G42FdWH)PJf-7QCeH9_&&Zg5SSFNM
OUUM7U/=T32[D83P4f:1aORQJ.@]/:ATeGL6fO)?Y9HQcI+NH?O]3K:gIb1]V@3;
K-RFLf>)b(7.0ADB>T4YQQLZ9G1^gTUb:K(E#g:J3:J4.a/MJU;+(;2Q8GI2N=)H
A[L:515D(>>B-Ve-113?/<fGKA=.2?BAJ<GXL#32+bfH[0F8bONKQL\gWbJOe8;#
BO<A\T2[?46&1D3-IHN5L]E1;3Gf>)BL/8HY=BK)gW9A#_?[CG7W0ebG)4Ngc038
)BbAT5^Z[7+b#QHdFKNUU009?-Z&(049LU0U.S@[HW>?CX^VYDQ+bKNg7E_MA)I2
aPg<X:OgMNfDGe079XJ1QY4N?TIBGe4<P:T&BSJRBPWZMNb_6-_K=W6QAIBb8^.H
HXG_FT/=.CAcQW6.]/J6.3R.=b1XYZBXWDQIXA:<U_R#][J,LN=+:,8f=L=Y[F,K
0fOUC90Q\ZW9Z(K=M,?VQC\O>>&M:VCK-J+/9@(DcGX_[.Q=9)R(4REPIEV3.<7:
RREM:3JXeOWa/N9[8f67^(Q<>fD_.bMT30SIRP_bVM@BJ+>bH0RALXf_2(>9.^Ng
Ac-a4GegcQR]WKa]X>/?20@7M).]DE#Y#Na5KD.9V8f-H:D3D2?>3Mf)4J:ecM]V
9@/L6>A?K12N&)46S.H#dfOUgd3/<H&@[[=].M_4Aa)-IMX@<T7E7:5),)P<TCF1
KCD,ILA4_G8[ERU(3XLb(MT:9&L+SBB#MKcC3,b7BdVe=&dLJIb4d7=W,c5=HUg_
O;3CTGV6c[M,#]aC1^SQCL-MK^Ld@:#J&NE9#T8;6Cg5)0D]QRLY/8OMbQY?V<b1
H^)H/0?1Z9-@YH.UMXaC@1KYNX:K=_S#3U;Gd:M<ZJM>(</5GM:B1cY(9f:E]##H
7B0AaV&2S\LQRPF[OL/?F\Q&QZQ[39+NaY^BO(G[=,9eL.M0#9bRUcF+T#8Kg+WC
088Ec7bY/DJVPXX33f_-9KP?&^)L?K=M@EX1VH\[YKOBBP-HWWb4_P)4N4UOSg>/
H.?T#KT#Nd?L.<).0(L2(R=C&.6@#KJ99NFU(-Y/-XO52Z?YIJ9(KdYS)#&DV7=U
#)fWB89;Y/8.27N72H4>.Q7FLWA&B@IRP#Kg6>XP&[4+B9WVL#7C7G2B9^TPJ(U<
<TA^e3+QH2E+SXV_Ue\H8--YA&3NSREB[X]7\2DHQA04/H^].g+RAL\Z2\G<Lg2[
GAOKHIKMA2#-U,EVQ6_?M0&XN8#E5\fKG;Jd^[#@JHQD2,:N-JR/PC.@;>2-RN^L
4BNbSDN]DP.^543??Z2NEUcTcE;F?f,RAO3B@^_([)-T36XaM)#[OfE)=g1S>]6)
G>LI9de[;d1EJ<T,^^3E2]?56E]f\3[c@PTH<&(3J>FC)JQ0[@FLCWbfW[Z7+#=#
H+T^]SC.c:J17XD/G1TZ(1JbAIc7b@#0eeVE-&W8XB@.?F1MIJ<@&(=X>5VX)F&S
HS6g478PIQCL8-86@/0TVRM,>]=A+HKF[GDKNARHL25IOC9be>W/=LEa-<J8>,=d
cP8:B\C^7dX)@>[IBAZOZSZ[7Z98SR+ddNQ30[)R;RKeY0b_V?3:G1^4b)C_QS-0
)R_9>]JV3]>Y=N.#\N9,7\[,#Z6=:I5.<G1.KM5X\&YL-NX_HQYcaZ1cMI2LRAXU
>@^)^PC+>)-K&[E/aQ&^&79I:O?Z@ebb?KJ2]6NeS.EC>&YW>#<BL1+U0b26a]P5
O8D<G-bgOYbe)^3C[W70M#J=<M+8=Zea^Id0=;bB+39aC\B^BR744IWI@6GU>??>
5+TMP#O3?7>4PUc59=;)T63)bBK;,++8Te+[3U96S8#4GAKFLW9;)<FA8a#]KaJ6
1K<b\L>;(#(XQB:g[65(H32g-1O.:DJL1+&g?E_W1ZeQM/E(:V;45gIbGE_BKf?D
a_Pe3R9L(;2HL9gbT/MHD3)>TQ<&a<(O5@Id<ZAd0eSOQc8SMSGQ#I>NW:?79S8C
3.X)_Pg0Adf[7fT)><Y(WLd.ID;X2_MBRHM0^0ZI]7H]XQ6W<g))CI+]PA<&Z&c1
(1.CR\d)\-#(G3<^c>V:NVMKU>aecD0Q<8.SCBT&LG.dAgTeR-gE_^TL:\Vc_[CB
Wdb5P,K;]0)Kf)@e?gZ1A8H6U5,#P&^H#LBZ\c@C&VMHFGYDKL2M4CTO0M[=IUB-
\?NYSZ36XW4+R_bcDY)Oe5CD1>H<02>B^Y1PNc;d9#D^FAJ;cEF9Z;[?c/-NW-Z,
-M5HJAE;)eOFNMe-R\KKW3J,2bNNT7JdHJ;R^:&^B3?<2Ub.BQ[D0-?F7-)]Lae-
[);CN:7]Q?AZ,VVK()Ygg\C5=gKYf;P#YY]/P1\0UL8)c(J=\A[GV2I587S?1+<&
Z.VN+Q^L_1I2eVG,SV4KDaR)_)2bI9LMRO-W;DAPE0B4\2(I7/3?_c;cD)SSedR<
:@I37K+M,(.UWg1Ie+9.b/?#6Y80[L&a=5fEQ@EZ4X/NG4A-L<RE:g2U0OCWa@YI
Tb^378R\BEM]4#b+e>[;7c:X?-5P)]?:.5a#OR=__]>e1LI)6fWK?gT2e.^>B3?Z
;>MDe_6CgJR./K(#db/\N&^@e4/S0[)A8FQSe?[K/^H+)6EI?g,AZ/@=VA2LJOMN
-I<>JVA][a.APc.e3+,X@06]<G?P)6gJZ^ID)fF1g.28GU:#5+0-(a#QfR#GPQHG
5H.<UQ6Fa?B@aRYS9&2B+;G+@OE^K8/#,]4>fNYLZTPD:>#\&W=6HCMVI95g[Z&#
&N)Q]HeA2g,\25@OX&4YF,gM2O_4f-BbW6NJ=EE((MQ15ZA.,d5B)f&,.4@SZ+YO
5aY;EV[^2?A>>J^5cM642>D=9T094WL/D]()Y6NfW0Sf7Za=A>a3GA+@Kg1^G6H8
g^2)W&&4@C_RTQR@(PH/OIK#NM0V[1aC20>86B3Oa20^UcbVQLBbZD#d.4cec89W
:_[U)c2Ec=]&gCASgU5;(T\d,<=PJZHD?OMdIL.d<a=]G_5#ffZ<3=TVJJffRG^E
R>fLAAKN0OG\G=-[M;4#3E_C&R)^.<(W<adP@W_J:G(_ee(_5EG^&(O]HR_>B/D^
:PV1GQ^(IS,WOIYPJRg>)#+NU@6RI_PIE1QS,&4aS7_V7C05V#P[)7?VS/Z>K8JR
UOR\eP8[F[K.TH26+Q1X4fO[2Lc4+I@QM-fcQAE3=?[15c@@1JR@\6V43K^;?]e4
FA[3N/&.I@]V-@<03F3f=a0S\[<[#MA,a:)W[M,fL3UHL2PAUPME<&#R<S\+3DDE
A:O_IDKcQN9/Oe]//._H2P\#Z8/@S_7:Q@),L6B4@&YW&-J;S\;#c_-?;>>4>e.Z
.J6N>,EWCS9-U7)f<_9_=;8H@1CRB31NXbX\/bfDb(W3)(^@:c9EAA-/ggYCG?\-
5/HWM9E96.X60783I03I8EHKNI]aPNc_J@)+IdZQ>dXe._Z3G]4BcS^.T3Y,8bD=
g56=G(_+U,-M^WT3CNdM#=[)Fg>M1W27GbE<6QD?)K,=:N2fcTK=&(P7>CEMa=OQ
9]X/FP>1RcHaEH+#.]f5CTUAN45gA6LY\ef@C^Z9Ed2[>2.^J&B3b2DC?Pb)3Ef_
N2IX5GDO^<4TLCB;A_C-BN/,,A0bB:JCbO4.-<>b&B5T5/cMUB=5X52AQ[TfZcd&
MMHQBV33/D&<:K7>=)U[aDOI3JeGH59^=0U9+01PX#(N,\9^(MF#0B&&@dC#L&(U
TA./cYb,V4)-F0(I2b2[:Z\/QgY-D__1<QaO?Ze^(UfC53\U3[0/E=-G@f1MgJ8@
&-T+^[V8Q]aFMB7Va?eHVc(G4c_5[9)(:3;WdcDS6Z,=/J?+Qa>A6YT59e@8PVVa
\I=6I8=[_5[M8>,+\FR=T\EP^6M&[fE_?bFP#6Of9aPF\--]20e&H)Xb;gQ,J7B/
RaZ3H/4)Sf:EV4#1SCd8B&J7Q=g2[-5b0>S;XV)2Te/SXcMcBdZLDPLHZ.7AYQ_#
efPOJU_g)ONWcK8/Oc-].PGLNWFWKZ:aaKY[4K#BE0=I\J4_J[7IUPe3IX3C3^-Q
NX((7G^KVe?N_7dOJI3]S3NPU-^P48W?fS3:=79=:V55dSgFVZ)ABY;K_ed/<OBL
77g,]V5c?\:S1@6@2KJ4a/dVE=a&98WFO/)S_KC\<+N9<^H5(FPMc,Eb:_/UQ1>R
P;85#Md)]J:S@+L9=VQV3^R=59TC[,2F]<6UEKJ&L:]9ILB@^S@4CP2X)a2-.?KW
BNFA+7&f.FbF-_Pc3?J.K3I10WJ5#Ie?0#7.I1-:L#7&]=2E6TbI5.:U\,c.;(4>
c4)L43Z&dCcE5Rb0g+dF5=dWBEB9<>gV20WcbN^(DDfEg=^gYICR?C<5UABb&>3Y
.J>VTaA5S]>:aW]1b7368;9+\K,Q]?S_2UMMd-5VSNYL,6#V#.:d.\+\O5[6daP,
K(d[@MS1/Z7O9cTN5gKU+_7/J4dK<bZW.QSddZ\(W-RC=R\5-85GTQ#^bK.ET8)1
b\2852NT]99S;EOT4YS6_/S]+[Q\9(M?adZL/?:9NR[PJU5@A5W>HeZA:M=<,.8A
KA1Q7:[PEfG.QBFHF<EZ[T2c^gE&Z:L4_CH=PE7Gc4BZ<=<AS@e:/9[:RX>0#@aa
:&J;;^NKA-Y17E#6(@2N;gE+)PMP;(7.8NIcIT:6V\2:E;PQM=@V\UP-E6FIW2>:
6)U[,JWET:TAJ1)fD6FL63=1W2\(4VN3SZDWSE;aC41.I7JP=GT^)5D/,I0VFY:V
#D:C5-^K5e2+&fb.,TG(_#T6:Mb@^9W+F+U;^;FI0T#fT;5ZMGJ<@\LK73,OPJ1T
[8Q;MMR#R.M8MX^DLVK-d&A&3/8eSX,=[fCaBPWP_LS-#Id:8::)F13RJZ:<Jf2:
CI^&c\)01\LW9)d06C9,T^GcJ^d;>P;&EGY:BfSZ//ZX(a=Q0)K[\:[.F,)Q\?A2
8T>ZE>,g;gM\N:MFE@af.:+QD:]A\L\fJ&:@Kf[3C<&HB?LO700@2>PA]<6e[1/_
@84+5I,eg_Rc\^)e4b<UUO_FZf)OA[7)D^.NWPK.MI<.KSGYBPMeDZ^H\NCa\^RL
e^JH7SBe+MJCCg<GFB##ERc@T[B]f?]Dd13+PJ@E&-+.SPW2R?c-AgJ5?#IS#;+]
fJPa=&[=gLO^H;88I/XQ28/D?(N.2S+AL>U1gQ<1OXTBe=HQ#:B<W8&+8AOL<N&8
D;,LX^DZB-M@WCfUb:4B=26,D2?BbM,1_YW4^8c7R9Y&(4#Ac@ZG8=:GOS&A+XTF
YLd-2/I>SG2TZ9921d[1b&./3c&e1AG[fEe)64b1/bJ)4&ALcTUWUQBcR2C]7E]F
F(W\IHf&<UJPJ734feHI];^QN(Z/)JTF6R9,_OB[T0G^2:=WI(@bLSFd7VRXD0G3
;eC8g0)d3DF5b\[EfMFXOQ52XdN)1IXQG5DfG?>HRI&/0QTIR0Zd38W\ZCTQ(e22
SVHN_0TEJRcbJ8bJE;1Ua0S1JKE2UZZS8>7a,@EF:2KZ.:KEADd[8LW+S:Q?IOVg
fdAQdF/4gRR=O<N+M895_6+4aE:[R60MD^YR-#2=@BeSg26466Bc_LC\WQT,/?72
cG(DPJ.QG@aWNE#aA7Qb9,\J\IH=2OV>0XQ,9S6C4@U7N3GWPF\\Y04+>[<:XdeP
AOb1O4,K2MA@<L]Tcf[b31)BTL_@U-\B&09UeQPC>P.E2D-RM&A>SPW^4Tf__,;g
(;1P:_SPBgQ3e9@)2;2H3IW^Y>BJBW3QB[3>QWfV4RL_dL7bT5D)4[2@XW&5M0K<
3^F\GQd,c7B\OY[,DQ63AZb=,4]ZYA<F^2JPX:Yg^ea;^0e?5:TfPG=1G=8E:]9b
Le;GP8EcF@CPNd9C&G8Gg,HE2Qd/X^9DLJbWR7SY9U-Fd-^0E>.ee_6_XWDU]>SK
20aYeU2<7W3WLB9-#d7-IPE\-Fg8&_:PN1FM1NV]aHFac>/6B:.Bd::7>,>^DO^1
2FeQBRMKf/2dZ:)@UA9[Z(dTC4L>7DU_K;RU-J-Z<1XX:;P0eXD.e2EcX;S:+(FT
6&gQ1H0JF\?#g=cJVYKSZ-EUM;.4ST<QM=>&[^dc3>Wcd.=)[[c#1(NP]>5H6>RC
TfK;_Y<6+HaZ@:KY+>5)[U2<Af<JXIL#A2EPcA&7_2@#MST.FgDd?J[Z10B@d35]
\-(RKRZ=#C#W7S=^.UJ(<[R3H.c#GaWC.LTG_]DDO(=2^A(/A^,9,,#H\Zf6RdOg
&VQ7(]-Xd2RN-J28.71#Y(3\#2ZUM([e:/dW0^;(@7R_dGB\U:22L<V_5Be).OU9
DG:V9C3HR+7BJ2GB?H_ZV/J5/N.T#fBKM_J#eFfVPO:2UR#2NWV#LBE#=_VR<KZP
,F>D:F3ZQMXZIQEEDRe15OX1Vb,Xf@=Q9TD9387UU>=>/?G6D2&)Z3^ECB]-^>aV
T1f9<Y^;2PS#QM5deGAIN,ECFO]DA=XC&]BD,C6_B+HUfF5+&FM_@&+V2O89G;eL
&KC^N]@_a[<V.#4&RWa)A\?E=\bI8;YXK6G&EYeQ,AAW4fIeU&H##PH@I/Q\[3Q:
c\g@a]YZ9C(RO5L&5&C973/[KYX4cIC;I1)_=G_BOR3>&UP7P^0f&L]Y948+fZLS
J)e=]EA5<KAXSACX<Q24U[(cU>?;O-Q:EQcfWKdKOV,1K<TR9>VH#e1NK6;[@S<K
_WNPMaQb?)9U1b[Q&I7X>Nd2Z,Xe>877CfcgS.,<gIeI(>1Z8NKADVBPKKDR)=VM
VdB#M5HG9:)AP,_G8YLD_]-1a0W0[Wg2cEQJ_#7XZSJT,CR?]#@<Ge:TP7@FKX0R
\2QI(:d/D0\ZdcYK6N)fJA#,>]QH0bfIL.JBX2NOI5X[Q?ZbO>Oa_ITWI-1d5@/W
5G5D+D]SK#G)^^Y:D8N3@(a(#g^>Bd&A8YK58HKOVfJ@HHB>O4HdP]eYNb>C4;b1
gF8N<@Yd78PL,Z+C8+F^.eJ^]_6_(aWFBC,3C^ZcNH)<c2R^ZU?ScIG^CC;=-7<K
S:@HP(AHa:,0[9b==J@=TN>_STcdd^d/8.Y)P\0D[O925I2g>f,HNfT1L>^L3M.3
9<WV<.g49g[YM9;@g>\[_7f:\?OGEg:^4a-/2g<8cGWPT=XWf^5Z;KgB:gb\E&/F
T-WG/9^#XFI)#WGF_R=IVbHM75GJB[Q]8b4DU_6DaH.C5Q:Z/)US,Zc4]T>:ECCd
Ng^C3=3?B6V@].6H6T1[dS).)>S29:GY;)e0D,XDNbQ9Z<8/:2@gcOc8Fg)cUeg?
CG9IG0ZW;a[XF]DYaQEA438dc30[.E:4-1H79;?(9O&^CAA(<<P9)T]>7Z:.dF<T
46dBUAfbdN&E,.^(]&);BM>acY83_JQ\V;KGFQ+2@<=819.OfKI0d7<Q=GG@MM91
H/_G7DROY\JHgY0@^NMNTMTg[>YVDW>Zfg&.#J\3H8fZM>=&4bQe#SQY@S;f-4&/
>V+33E/X:(WF-20)K3&JBV7fX,6P^]gK>8]9a61D:?G>QaHC-GP1(IS812-)ZH8#
?(0Pg3L9.gZY(OT0(TD<_2[-7JW0BagNEXT,>X^_:V\@#+#^:HH3:?BX;c(DcG04
DfGD[2:RHLEFd8CVQbDPg18165.fcb?#/?GP,?N0BKf.;(,S@ZLT(1:5GeS.7[g#
M3[UXc1E<H)?>A^b[KPKW#=dZ?Hf;[0BU.#1GL/;(Q,I/HR(M5bM=P,)V(;BCG]c
X5H[/bTc3ILJ./FgEY=A-fRaF6b97F<)T1Y&fA4G_H;YY>d>Zc1:NG:243E<4:3&
L:1^SZ3=WB7C1ER(6gc?+]_d3dK^)A.CIV]8A.5=Lc>&\GK@->15\<7I+;f2,L:A
;f?T&6BO6/G0-Yac7^-:a^FVQ#g@aHGIR_-T=@(TL=M(/NYI3HK[URSRH@8^=L?]
e^BRPE1=bd\B^=^.2AbVcMWD)Y>NFMQ5fBX(RQ^<<TRN9Mgf8X<L\ZP41I<C[5EC
2#J^f\)>P.c37X>)X<dD/c?:)Q/97TO[CHGg-Gf_80.P80<U@1\\H?KHHS?&#&BS
IYE-=/cE]JBaBW_FP,;PHYPELC>DVAHV96;^5KLP9dVN2:8L.G--K)3:8.WC[-O-
HLb=/I5ECc+4XIf]0K#.[I8GR&=M\^UQP>C,J[P)F04XSX\+c^^/QK+J^B6Ue^@R
<U_24Q,0Y;@X^=T7fNcE157_-7\DL2Wfb<+Y:<(/;MHW)g[;1N)R8KK850AP<CB9
B]B[AKgSQKMEKP??2;PJcg_74\#F_KJF;/]V#OO#L-W.NY2@OS>,G_PPBZ,X8>RK
/ET;b5?cS_;A:-]R]A&->bN?(UH366@HF7);(BGKce\(B\6W#SKT:.62?gJc3dTR
b&5\++[Y>Z4_N61=;2?8I,&L<7O68XJ:.#:NKKXICI.F,]S5BO=QK()afYSYZdGJ
7->2-[JI.GN^X3DW?2/],V,?:9WfXSI/RLcPHLP/QV4;9N^ZW1RB+YR@W+M9TIXa
]6FgX</\1VfAcZ+@,D7HU51=DIW@<WQ7YDXY^]?))@Zb/=CJ;Be0.3#WgeT=[@HH
[1IWd/W,c^VADYaC:0U2V1[IB,&@[9abBK0#@I(fF-A[ed,[/)T=Q>29]]cbT.)P
9OV^5C-CA6^H,a89V:G;Qbbc9Y+^T1fY;56OL<-OP:H.-g1]aOBE<LAX+&Z[6;XW
73g05QI_+B^J6F55),@[[RW9S:6XCS?G7OGTEM6gV]/V/0>\_J&9TaBG-E-aT6J[
G]4OP1,AN5Y1P(UU7c7<&9YaF#:]\4NBPF_FJ+f,Me2#<7[_M(<^R_\I:)-VV6AF
<#:^ETd2@]1E>SP-&>10C1K->1;:VI48E\T,)b95bQBQROfWS6WdKfM.D[;+3e.9
2+4=L7adI.PGA/aXL,(=LZL62Q9HAV_6(HFWRY(:/W-E:3+#4F[/PEEd,:LM_7Xb
T5?\0Y&_U-(PP(&U,K,[aOYH;U+&gCN/Q/+OR^CcdbG,^-1+-f_(][eN4fcb(@/.
1Tf7c#&]Td9/J4FFIPWM]P>d1@-=2&6V^.?;QB=/dgKXK,DJBRFSX1^,]W)Lf+<N
XCJ@NWfUVK\Y^Je8@_AcCaffdTEINfdSfET_d8P@U9R_BC_;A@A5Sa3T54YJacK&
8+DPY\IH33Q.WYff>G:AN[?P?_QF>K:a\HQO@OMH;H4/JA2Z\fb\6\NK7eTYMA/@
XCC><80VYCXZf9]RHQ&NI<4O?/J+C,UF<?YIQa57[;>^9GBGUcVN:]VLJTT8\eWF
>];[FM=Hd[&LWG?I>?P\\D)&=P<5I4-Z&(Q@BDT@O.PG=)76@egY9cVadWC18&2O
g3T])CM&VGLe/>\R[];UC(2?<L6V(_\JSOVC_dT-#\a:F+;gYGTUD5/0]]7_W)S(
?=F@bT.=OM1#W7M@&2])POf(@R-WC4(W<PA6e1c,YgS@eK3:#(>WfI:-&48QE_^V
=6T0/)A6G.UL7)+_JZf4fJ)dVH3D@U,\/d7e:,=7?AA\;(d)\T.AQ)./2LT+NJB9
]4^?XA,+:10+Tb61R#KgM>3GK5/E[C5R[AJg:8+R\[R9(5<dC8@c,2/TeE3>L?P^
MPW2GSIC1W^bC>C]U\MX4gN:IcfF)__4:>7ND.>1SE12B,cMHE_BWB#TE@?e6IF+
1]52WWI[M@U@;EZIJ8,#fD7OHR_>0-HGaBXR0P;Vg/VQa5\9b2ZG-S=__2f?G+KP
[M--^a0HS?2C56N5U0,cXA]Ye#F#3HGBa5YR@+W4+DH0d(]DQ)W\F@fW4ZO,:=+S
TQI<//Q[EN>?DJae9)3T[(ZRe?b+9XV3#+4^I[QM.NZIM@Ad?[1[1+@Y@SXaP-,M
ZC-SF&Ob[TT0,b4^3/5UV?EBFI3I7Q.R5^b-6-B=(D1OMf6<d/=8Bc<T:6NUIN0L
e_4>Z6P.Y2IAUaQ93eYV]./PGSFPVO>+e17\F_<0XW76/L/AM+QfT?]:#<25:-AM
ZH.8RYGMV8bUXd#API+J(a2SRUIAK1@.L_LDS@XFB.4YGIQcRf.a^T]?Y1>D-d(O
NXM\e4<)/TH=LG.JK@>Q8]2S6$
`endprotected
endmodule

























// `ifdef RTL
//     `define CYCLE_TIME 4.9
// `endif
// `ifdef GATE
//     `define CYCLE_TIME 4.9
// `endif

// `define DRAM_PATH "../00_TESTBED/DRAM/dram1.dat"
// `define PATNUM 1000
// `define SEED 558678.0

// `include "../00_TESTBED/pseudo_DRAM.v"

// module PATTERN(
//     // Input Signals
//     clk,
//     rst_n,
//     in_valid,
//     in_pic_no,
//     in_mode,
//     in_ratio_mode,
//     out_valid,
//     out_data
// );

// /* Input for design */
// output reg        clk, rst_n;
// output reg        in_valid;

// output reg [3:0] in_pic_no;
// output reg       in_mode;
// output reg [1:0] in_ratio_mode;

// input out_valid;
// input [7:0] out_data;
// //////////////////////////////////////////////////////////////////////
// parameter DRAM_p_r = `DRAM_PATH;
// parameter CYCLE = `CYCLE_TIME;

// reg [7:0] DRAM_r[0:196607];
// reg [7:0] image [0:2][0:31][0:31];
// integer patcount;
// integer latency, total_latency;
// integer file;
// integer PATNUM = `PATNUM;
// integer seed = `SEED;

// reg [1:0] golden_in_ratio_mode;
// reg [3:0] golden_in_pic_no;
// reg  golden_in_mode;
// reg [7:0] golden_out_data;

// reg [7:0] two_by_two [0:1][0:1];
// reg [7:0] four_by_four [0:3][0:3];
// reg [7:0] six_by_six [0:5][0:5];

// reg [31:0] out_data_temp;
// reg [31:0] D_constrate [0:2];
// reg [31:0] D_constrate_add [0:2];


// // testing focus and exposure
// integer focus_num;
// integer exposure_num;
// reg focus_flag [0:15];
// reg exposure_flag [0:15];
// reg [3:0] dram_all_zero_flag [0:15];
// integer read_dram_times;

// //////////////////////////////////////////////////////////////////////
// // Write your own task here
// //////////////////////////////////////////////////////////////////////
// initial clk=0;
// always #(CYCLE/2.0) clk = ~clk;

// // Do it yourself, I believe you can!!!

// /* Check for invalid overlap */
// always @(*) begin
//     if (in_valid && out_valid) begin
//         display_fail;
//         $display("************************************************************");  
//         $display("                          FAIL!                           ");    
//         $display("*  The out_valid signal cannot overlap with in_valid.   *");
//         $display("************************************************************");
//         $finish;            
//     end    
// end







// initial begin
//     reset_task;
//     $readmemh(DRAM_p_r,DRAM_r);
//     file = $fopen("../00_TESTBED/debug.txt", "w");
//     focus_num = 0;
//     exposure_num = 0;
//     read_dram_times = 0;
//     for(integer i = 0; i < 16; i = i + 1)begin
//         focus_flag[i] = 0;
//         exposure_flag[i] = 0;
//         dram_all_zero_flag[i] = 0;
//     end

//     for( patcount = 0; patcount < PATNUM; patcount++) begin 
//         repeat(2) @(negedge clk); 
//         input_task;
//         write_dram_file;
//         calculate_ans;
//         write_to_file;
//         wait_out_valid_task;
//         check_ans;
//         $display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32mExecution Cycle: %3d \033[0m", patcount + 1, latency);
  
//     end
//     display_pass;
//     repeat (3) @(negedge clk);
//     $finish;
// end

// task reset_task; begin 
//     rst_n = 1'b1;
//     in_valid = 1'b0;
//     in_ratio_mode = 2'bx;
//     in_pic_no = 4'bx;
//     in_mode = 1'bx;
//     total_latency = 0;

//     force clk = 0;

//     // Apply reset
//     #CYCLE; rst_n = 1'b0; 
//     #CYCLE; rst_n = 1'b1;
    
//     // Check initial conditions
//     if (out_valid !== 1'b0 || out_data !== 'b0) begin
//         display_fail;
//         $display("************************************************************");  
//         $display("                          FAIL!                           ");    
//         $display("*  Output signals should be 0 after initial RESET at %8t *", $time);
//         $display("************************************************************");
//         repeat (2) #CYCLE;
//         $finish;
//     end
//     #CYCLE; release clk;
// end endtask


// task input_task; begin
//     integer i,j;
//     in_valid = 1'b1;
    
    
//     // in_pic_no = 15;
//     // in_mode = 1;
//     in_pic_no = $random(seed) % 'd16;
//     in_mode = $random(seed) % 'd2;
//     // in_mode = 1'b1;
//     in_ratio_mode = (in_mode) ? $random(seed) % 'd4 : 2'bx;
//     golden_in_ratio_mode = in_ratio_mode;
//     golden_in_pic_no = in_pic_no;
//     golden_in_mode = in_mode;

//     // count focus and exposure

//     if(in_mode == 1'b0)begin
//         focus_num = focus_num + 1;
//     //     if(focus_flag[in_pic_no] == 1'b0)begin
//     //         focus_flag[in_pic_no] = 1'b1;
//     //         if(dram_all_zero_flag[in_pic_no] != 4'd8)begin
//     //             read_dram_times = read_dram_times + 1;
//     //         end
//     //     end
//     end
//     else begin
//         exposure_num = exposure_num + 1;
//     end    
        

//     //     if(focus_flag[in_pic_no] == 1'b0)begin
//     //         focus_flag[in_pic_no] = 1'b1;
//     //     end
//     //     if(exposure_flag[in_pic_no] != 1'b1 || (in_ratio_mode != 2 && in_ratio_mode != 0 && in_ratio_mode != 1))begin
//     //         exposure_flag[in_pic_no] = 1'b1;
//     //         if(dram_all_zero_flag[in_pic_no] != 4'd8)begin
//     //             read_dram_times = read_dram_times + 1;
//     //         end
//     //     end

//     //     if(dram_all_zero_flag[in_pic_no] != 4'd8)begin
//     //         if(in_ratio_mode == 0)begin
//     //             dram_all_zero_flag[in_pic_no] = (dram_all_zero_flag[in_pic_no] >= 6) ? 8 : dram_all_zero_flag[in_pic_no] + 2;
//     //         end
//     //         else if(in_ratio_mode == 1)begin
//     //             dram_all_zero_flag[in_pic_no] = dram_all_zero_flag[in_pic_no] + 1;
//     //         end
//     //         else if(in_ratio_mode == 3)begin
//     //             dram_all_zero_flag[in_pic_no] = (dram_all_zero_flag[in_pic_no] == 0) ? 0 : dram_all_zero_flag[in_pic_no] - 1;
//     //         end
//     //     end

        
//     // end

    

    

//     for(integer i = 0; i < 3; i = i + 1)begin
//         for(integer j = 0; j < 32; j = j + 1)begin
//             for(integer k = 0; k < 32; k = k + 1)begin
//                 image[i][j][k] = DRAM_r[65536 + i * 32 * 32 + j * 32 + k + golden_in_pic_no * 32 * 32 * 3];
//             end
//         end
//     end   
    

//     @(negedge clk);

//     in_valid = 1'b0;
//     in_ratio_mode = 2'bx;
//     in_pic_no = 4'bx;
//     in_mode = 1'bx;
    
// end endtask


// task calculate_ans;begin
   

//     if(golden_in_mode == 1'b0)begin
//         for(integer i = 0; i < 3; i = i + 1)begin
//             D_constrate_add[i] = 0;
//         end
        
//         for(integer j = 0; j < 2; j = j + 1)begin
//             for(integer k = 0; k < 2; k = k + 1)begin
//                 two_by_two[j][k] = (image[0][15 + j][15 + k] ) / 4 + (image[1][15 + j][15 + k]) / 2 + 
//                                         (image[2][15 + j][15 + k] ) / 4 ;
//             end
//         end

//         for(integer j = 0; j < 4; j = j + 1)begin
//             for(integer k = 0; k < 4; k = k + 1)begin
//                 four_by_four[j][k] = (image[0][14 + j][14 + k] ) / 4 + (image[1][14 + j][14 + k]) / 2 + 
//                                         (image[2][14 + j][14 + k] ) / 4 ;
//             end
//         end

//         for(integer j = 0; j < 6; j = j + 1)begin
//             for(integer k = 0; k < 6; k = k + 1)begin
//                 six_by_six[j][k] = (image[0][13 + j][13 + k] ) / 4 + (image[1][13 + j][13 + k]) / 2 + 
//                                         (image[2][13 + j][13 + k] ) / 4 ;
//             end
//         end



//         for(integer i = 0; i < 2; i = i + 1)begin
//             for(integer j = 0; j < 1; j = j + 1)begin
//                 D_constrate_add[0] = D_constrate_add[0] + diff_abs(two_by_two[i][j + 1], two_by_two[i][j]) + diff_abs(two_by_two[j + 1][i], two_by_two[j][i]);
//             end
//         end

//         for(integer i = 0; i < 4; i = i + 1)begin
//             for(integer j = 0; j < 3; j = j + 1)begin
//                 D_constrate_add[1] = D_constrate_add[1] + diff_abs(four_by_four[i][j + 1], four_by_four[i][j]) + diff_abs(four_by_four[j + 1][i], four_by_four[j][i]);
//             end
//         end

//         for(integer i = 0; i < 6; i = i + 1)begin
//             for(integer j = 0; j < 5; j = j + 1)begin
//                 D_constrate_add[2] = D_constrate_add[2] + diff_abs(six_by_six[i][j + 1], six_by_six[i][j]) + diff_abs(six_by_six[j + 1][i], six_by_six[j][i]);
//             end
//         end

//         D_constrate[0] = D_constrate_add[0] / (2 * 2);
//         D_constrate[1] = D_constrate_add[1] / (4 * 4);
//         D_constrate[2] = D_constrate_add[2] / (6 * 6);

//         if(D_constrate[0] >= D_constrate[1] && D_constrate[0] >= D_constrate[2])begin
//             golden_out_data = 8'b00000000;
//         end
//         else if(D_constrate[1] >= D_constrate[2])begin
//             golden_out_data = 8'b00000001;
//         end
//         else begin
//             golden_out_data = 8'b00000010;
//         end

//     end
//     else begin
//         for(integer i = 0; i < 3; i = i + 1)begin
//             for(integer j = 0; j < 32; j = j + 1)begin
//                 for(integer k = 0; k < 32; k = k + 1)begin
//                     if(golden_in_ratio_mode == 0)begin
//                         image[i][j][k] = image[i][j][k] / 4;
//                     end
//                     else if(golden_in_ratio_mode == 1)begin
//                         image[i][j][k] = image[i][j][k] / 2;
//                     end
//                     else if(golden_in_ratio_mode == 2)begin
//                         image[i][j][k] = image[i][j][k];
//                     end
//                     else begin
//                         image[i][j][k] = (image[i][j][k] < 128)  ? image[i][j][k] * 2 : 255;
//                         // MSB is 1, image = 255, else shift left 1;
//                     end
                    
//                 end
//             end
//         end

//         for(integer i = 0; i < 3; i = i + 1)begin
//             for(integer j = 0; j < 32; j = j + 1)begin
//                 for(integer k = 0; k < 32; k = k + 1)begin
//                     DRAM_r[65536 + i * 32 * 32 + j * 32 + k + golden_in_pic_no * 32 * 32 * 3] = image[i][j][k];
//                 end
//             end
//         end
        
//         out_data_temp = 0;
//         for(integer i = 0; i < 32; i = i + 1)begin
//             for(integer j = 0; j < 32; j = j + 1)begin
//                 out_data_temp = out_data_temp + image[0][i][j] / 4 + image[1][i][j] / 2 + image[2][i][j] / 4;
//             end
//         end
//         golden_out_data = out_data_temp / 1024;

//     end



// end endtask

// task wait_out_valid_task; begin
//     latency = 0;
//     while (out_valid !== 1'b1) begin
//         latency = latency + 1;
//         if (latency == 20000) begin
//             display_fail;
//             $display("********************************************************");     
//             $display("                          FAIL!                           ");
//             $display("*  The execution latency exceeded 20000 cycles at %8t   *", $time);
//             $display("********************************************************");
//             repeat (2) @(negedge clk);
//             $finish;
//         end
//         @(negedge clk);
//     end
//     total_latency = total_latency + latency;
// end endtask



// task check_ans; begin
//     if(golden_in_mode == 0)begin
//         if(out_data !== golden_out_data)begin
//             display_fail;
//             $display("********************************************************");     
//             $display("                          FAIL!                           ");
//             $display("*               The golden_in_mode is %d               *", golden_in_mode);
//             $display("*  The golden_out_data is %d, but your out_data is %d  *", golden_out_data, out_data);
//             $display("********************************************************");
//             repeat (2) @(negedge clk);
//             $finish;
//         end
//     end
//     else begin
//         if(golden_out_data == 0)begin
//             if(out_data !== 1 && out_data !== 0)begin
//                 display_fail;
//                 $display("********************************************************");     
//                 $display("                FAIL error is large than 1 !                ");
//                 $display("*               The golden_in_mode is %d               *", golden_in_mode);
//                 $display("*  The golden_out_data is %d, but your out_data is %d  *", golden_out_data, out_data);
//                 $display("********************************************************");
//                 repeat (2) @(negedge clk);
//                 $finish;
//             end
//         end
//         else if(golden_out_data == 255)begin
//             if(out_data !== 255 && out_data !== 254)begin
//                 display_fail;
//                 $display("********************************************************");     
//                 $display("                FAIL error is large than 1 !                ");
//                 $display("*               The golden_in_mode is %d               *", golden_in_mode);
//                 $display("*  The golden_out_data is %d, but your out_data is %d  *", golden_out_data, out_data);
//                 $display("********************************************************");
//                 repeat (2) @(negedge clk);
//                 $finish;
//             end
//         end
//         else begin
//             if(out_data > golden_out_data + 1 || out_data < golden_out_data - 1)begin
//                 display_fail;
//                 $display("********************************************************");     
//                 $display("                FAIL error is large than 1 !                ");
//                 $display("*               The golden_in_mode is %d               *", golden_in_mode);
//                 $display("*  The golden_out_data is %d, but your out_data is %d  *", golden_out_data, out_data);
//                 $display("********************************************************");
//                 repeat (2) @(negedge clk);
//                 $finish;
//             end
//         end
        
//     end

// end endtask

// task write_dram_file; begin
//     $fwrite(file, "===========  PATTERN NO.%4d  ==============\n", patcount);
//     $fwrite(file, "==========  GOLDEN_PIC_NO.%2d  ==============\n", golden_in_pic_no);
//     $fwrite(file, "===========    RED IMAGE     ==============\n");
//     for(integer i = 0; i < 32; i = i + 1) begin
//         for(integer j = 0; j < 32; j = j + 1) begin
//             $fwrite(file, "%5d ", image[0][i][j]);
//         end
//         $fwrite(file, "\n");
//     end
//     $fwrite(file, "===========    GREEN IMAGE     ============\n");
//     for(integer i = 0; i < 32; i = i + 1) begin
//         for(integer j = 0; j < 32; j = j + 1) begin
//             $fwrite(file, "%5d ", image[1][i][j]);
//         end
//         $fwrite(file, "\n");
//     end
//     $fwrite(file, "===========    BLUE IMAGE     ============\n");
//     for(integer i = 0; i < 32; i = i + 1) begin
//         for(integer j = 0; j < 32; j = j + 1) begin
//             $fwrite(file, "%5d ", image[2][i][j]);
//         end
//         $fwrite(file, "\n");
//     end
//     $fwrite(file, "\n");
// end endtask












// task write_to_file; begin
    
//     $fwrite(file, "==========  GOLDEN_IN_MODE is %b  ==============\n", golden_in_mode);   
//     if(golden_in_mode == 1'b0)begin
//         $fwrite(file, "===========    TWO_BY_TWO     ============\n");
//         for(integer i = 0; i < 2; i = i + 1) begin
//             for(integer j = 0; j < 2; j = j + 1) begin
//                 $fwrite(file, "%5d ", two_by_two[i][j]);
//             end
//             $fwrite(file, "\n");
//         end

//         $fwrite(file, "===========    FOUR_BY_FOUR     ============\n");
//         for(integer i = 0; i < 4; i = i + 1) begin
//             for(integer j = 0; j < 4; j = j + 1) begin
//                 $fwrite(file, "%5d ", four_by_four[i][j]);
//             end
//             $fwrite(file, "\n");
//         end

//         $fwrite(file, "===========    SIX_BY_SIX     ============\n");
//         for(integer i = 0; i < 6; i = i + 1) begin
//             for(integer j = 0; j < 6; j = j + 1) begin
//                 $fwrite(file, "%5d ", six_by_six[i][j]);
//             end
//             $fwrite(file, "\n");
//         end
//         $fwrite(file, "===========   D_CONSTRATE(ADD)  ============\n");
//         for(integer i = 0; i < 3; i = i + 1) begin
//             $fwrite(file, "%10d", D_constrate_add[i]);
//         end
//         $fwrite(file, "\n");
//         $fwrite(file, "===========    D_CONSTRATE     ============\n");
//         for(integer i = 0; i < 3; i = i + 1) begin
//             $fwrite(file, "%10d", D_constrate[i]);
//         end
//         $fwrite(file, "\n");
//     end
//     else begin
//         $fwrite(file, "=========  IMAGE_AFTER_AUTO_EXPOSURE  ============\n");
//         $fwrite(file, "=========  GOLDEN_RATIO is %d  ============\n",golden_in_ratio_mode);
//         $fwrite(file, "===========    RED IMAGE     ==============\n");
//         for(integer i = 0; i < 32; i = i + 1) begin
//             for(integer j = 0; j < 32; j = j + 1) begin
//                 $fwrite(file, "%5d ", image[0][i][j]);
//             end
//             $fwrite(file, "\n");
//         end
//         $fwrite(file, "===========    GREEN IMAGE     ============\n");
//         for(integer i = 0; i < 32; i = i + 1) begin
//             for(integer j = 0; j < 32; j = j + 1) begin
//                 $fwrite(file, "%5d ", image[1][i][j]);
//             end
//             $fwrite(file, "\n");
//         end
//         $fwrite(file, "===========    BLUE IMAGE     ============\n");
//         for(integer i = 0; i < 32; i = i + 1) begin
//             for(integer j = 0; j < 32; j = j + 1) begin
//                 $fwrite(file, "%5d ", image[2][i][j]);
//             end
//             $fwrite(file, "\n");
//         end
//         $fwrite(file, "\n");

//         $fwrite(file, "===========  DATA_SUM (not divide 1024)  ============\n");
//         $fwrite(file, "%10d\n", out_data_temp);
//     end
//     $fwrite(file, "===========  GOLDEN_OUT_DATA  ============\n");
//     $fwrite(file, "%10d\n", golden_out_data);

//     $fwrite(file, "\n\n\n");
// end endtask






// function [7:0]diff_abs; 
//     input [7:0]a;
//     input [7:0]b;
//     begin
//         if(a > b)begin
//             diff_abs = a - b;
//         end
//         else begin
//             diff_abs = b - a;
//         end
//     end
// endfunction





















// task display_fail; begin

//     /*$display("        ----------------------------               ");
//     $display("        --                        --       |\__||  ");
//     $display("        --  OOPS!!                --      / X,X  | ");
//     $display("        --                        --    /_____   | ");
//     $display("        --  \033[0;31mSimulation FAIL!!\033[m   --   /^ ^ ^ \\  |");
//     $display("        --                        --  |^ ^ ^ ^ |w| ");
//     $display("        ----------------------------   \\m___m__|_|");
//     $display("\n");*/
// end endtask

// /*task display_pass; begin
//         $display("\n");
//         $display("\n");
//         $display("        ----------------------------               ");
//         $display("        --                        --       |\__||  ");
//         $display("        --  Congratulations !!    --      / O.O  | ");
//         $display("        --                        --    /_____   | ");
//         $display("        --  \033[0;32mSimulation PASS!!\033[m     --   /^ ^ ^ \\  |");
//         $display("        --                        --  |^ ^ ^ ^ |w| ");
//         $display("        ----------------------------   \\m___m__|_|");
//         $display("\n");
// end endtask*/

// task display_pass; begin
//     $display("-----------------------------------------------------------------");
//     $display("                       Congratulations!                          ");
//     $display("                You have passed all patterns!                     ");
//     $display("                Your execution cycles = %5d cycles                ", total_latency);
//     $display("                Your clock period = %.1f ns                       ", CYCLE);
//     $display("                Total Latency = %.1f ns                          ", total_latency * CYCLE);
//     $display("                Focus number = %4d, Exposure number = %4d           ", focus_num, exposure_num);
//     // $display("                Total Read DRAM times = %4d                             ", read_dram_times);
//     // $display("                DRAM all zero number %d = %d                            ", 0, dram_all_zero_flag[0]);
//     // $display("                DRAM all zero number %d = %d                            ", 1, dram_all_zero_flag[1]);
//     // $display("                DRAM all zero number %d = %d                            ", 2, dram_all_zero_flag[2]);
//     // $display("                DRAM all zero number %d = %d                            ", 3, dram_all_zero_flag[3]);
//     // $display("                DRAM all zero number %d = %d                            ", 4, dram_all_zero_flag[4]);
//     // $display("                DRAM all zero number %d = %d                            ", 5, dram_all_zero_flag[5]);
//     // $display("                DRAM all zero number %d = %d                            ", 6, dram_all_zero_flag[6]);
//     // $display("                DRAM all zero number %d = %d                            ", 7, dram_all_zero_flag[7]);
//     // $display("                DRAM all zero number %d = %d                            ", 8, dram_all_zero_flag[8]);
//     // $display("                DRAM all zero number %d = %d                            ", 9, dram_all_zero_flag[9]);
//     // $display("                DRAM all zero number %d = %d                            ", 10, dram_all_zero_flag[10]);
//     // $display("                DRAM all zero number %d = %d                            ", 11, dram_all_zero_flag[11]);
//     // $display("                DRAM all zero number %d = %d                            ", 12, dram_all_zero_flag[12]);
//     // $display("                DRAM all zero number %d = %d                            ", 13, dram_all_zero_flag[13]);
//     // $display("                DRAM all zero number %d = %d                            ", 14, dram_all_zero_flag[14]);
//     // $display("                DRAM all zero number %d = %d                            ", 15, dram_all_zero_flag[15]);
//     $display("-----------------------------------------------------------------");
//     repeat (2) @(negedge clk);
//     $finish;
// end endtask


// endmodule





















// `define CYCLE_TIME 4.9

// `include "../00_TESTBED/pseudo_DRAM.v"

// module PATTERN(
//     // Input Signals
//     clk,
//     rst_n,
//     in_valid,
//     in_pic_no,
//     in_mode,
//     in_ratio_mode,
//     out_valid,
//     out_data
// );

// //======================================
// //      INPUT & OUTPUT
// //======================================
// output reg       clk, rst_n;
// output reg       in_valid;

// output reg [3:0] in_pic_no;
// output reg       in_mode;
// output reg [1:0] in_ratio_mode;

// input out_valid;
// input [7:0] out_data;

// //======================================
// //      PARAMETERS & VARIABLES
// //======================================
// //vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
// // Can be modified by user
// integer   TOTAL_PATNUM = 1000;
// // -------------------------------------
// // [Mode]
// //      0 : generate the simple dram.dat
// //      1 : generate the regular dram.dat
// //      2 : validate design
// integer   MODE = 2;
// // -------------------------------------
// integer   SEED = 65786;
// parameter DEBUG = 1;
// parameter DRAMDAT_TO_GENERATED = "../00_TESTBED/DRAM/dram2.dat";
// parameter DRAMDAT_FROM_DRAM = `d_DRAM_p_r;
// //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// parameter CYCLE = `CYCLE_TIME;
// parameter DELAY = 20000;
// parameter OUTNUM = 1;

// // PATTERN CONTROL
// integer pat;
// integer exe_lat;
// integer tot_lat;

// // String control
// // Should use %0s
// reg[9*8:1]  reset_color       = "\033[1;0m";
// reg[10*8:1] txt_black_prefix  = "\033[1;30m";
// reg[10*8:1] txt_red_prefix    = "\033[1;31m";
// reg[10*8:1] txt_green_prefix  = "\033[1;32m";
// reg[10*8:1] txt_yellow_prefix = "\033[1;33m";
// reg[10*8:1] txt_blue_prefix   = "\033[1;34m";

// reg[10*8:1] bkg_black_prefix  = "\033[40;1m";
// reg[10*8:1] bkg_red_prefix    = "\033[41;1m";
// reg[10*8:1] bkg_green_prefix  = "\033[42;1m";
// reg[10*8:1] bkg_yellow_prefix = "\033[43;1m";
// reg[10*8:1] bkg_blue_prefix   = "\033[44;1m";
// reg[10*8:1] bkg_white_prefix  = "\033[47;1m";

// //======================================
// //      DATA MODEL
// //======================================
// // Debugging file
// parameter IMAGE_ORIGINAL_FILE = "image_original.txt";
// parameter IMAGE_ADJUSTED_FILE = "image_adjusted.txt";
// parameter AUTO_FOCUS_FILE = "auto_focus.txt";
// parameter AUTO_EXPOSURE_FILE = "auto_exposure.txt";
// // Input
// parameter NUM_OF_MODE = 2;
// parameter NUM_OF_RATIO = 4;
// // Image
// parameter NUM_OF_PIC = 16;
// parameter NUM_OF_CHANNEL = 3; // (R, G, B)
// parameter SIZE_OF_PIC = 32;
// parameter NUM_OF_CONTRASTS = 3;
// parameter START_OF_DRAM_ADDRESS = 65536;
// parameter BITS_OF_PIXEL = 8;
// // Data
// reg[BITS_OF_PIXEL-1:0] _image[NUM_OF_PIC-1:0][NUM_OF_CHANNEL-1:0][SIZE_OF_PIC-1:0][SIZE_OF_PIC-1:0];
// reg[BITS_OF_PIXEL-1:0] _originalImage[NUM_OF_CHANNEL-1:0][SIZE_OF_PIC-1:0][SIZE_OF_PIC-1:0];
// parameter real _grayscaleRatio[NUM_OF_CHANNEL-1:0] = {0.25, 0.5, 0.25};
// integer _noPic;
// integer _mode;
// parameter real _ratio[NUM_OF_RATIO-1:0] = {2, 1, 0.5, 0.25};
// integer _ratioMode;
// // Mode 0
// parameter integer _constrast[NUM_OF_CONTRASTS-1:0] = {6, 4, 2}; // Contrast
// parameter MAX_SIZE_OF_CONTRASTS = _constrast[NUM_OF_CONTRASTS-1];
// integer _focusWindow[NUM_OF_CONTRASTS-1:0][NUM_OF_CHANNEL-1:0][MAX_SIZE_OF_CONTRASTS-1:0][MAX_SIZE_OF_CONTRASTS-1:0];
// integer _focusGrayWindow[NUM_OF_CONTRASTS-1:0][MAX_SIZE_OF_CONTRASTS-1:0][MAX_SIZE_OF_CONTRASTS-1:0];
// integer _focusDiffHorizontal[NUM_OF_CONTRASTS-1:0];
// integer _focusDiffVertical[NUM_OF_CONTRASTS-1:0];
// integer _focusNormalizedDiff[NUM_OF_CONTRASTS-1:0];
// integer _maxContrast;
// // Mode 1
// parameter ERROR_MARGIN = 2;
// integer _exposureGrayscale;
// //
// integer _yourOutput;

// //
// // Load
// //
// task load_pic_from_dram;
//     integer file;
//     integer status;
//     integer val;
//     integer _cnt;
//     integer _pic;
//     integer _ch;
//     integer _row;
//     integer _col;
// begin
//     file = $fopen(DRAMDAT_FROM_DRAM, "r");
//     if (file == 0) begin
//         $display("[ERROR] [FILE] The file (%0s) can't be opened", DRAMDAT_FROM_DRAM);
//         $finish;
//     end
//     _cnt = 0;
//     _pic = 0;
//     _ch  = 0;
//     _row = 0;
//     _col = 0;
//     while(!$feof(file))begin
//         // Address
//         status = $fscanf(file, "@%h", val);
//         // Pixel
//         status = $fscanf(file, "%2h", val);
//         if (status == 1) begin
//             _image[_pic][_ch][_row][_col] = val;
//             _cnt = _cnt + 1;
//         end
//         _pic = (_cnt/(SIZE_OF_PIC*SIZE_OF_PIC*NUM_OF_CHANNEL))%NUM_OF_PIC;
//         _ch  = (_cnt/(SIZE_OF_PIC*SIZE_OF_PIC))%NUM_OF_CHANNEL;
//         _row = (_cnt/SIZE_OF_PIC)%SIZE_OF_PIC;
//         _col = _cnt%SIZE_OF_PIC;
//     end
//     $fclose(file);
// end endtask

// //
// // Setter
// //
// task record_original_image;
//     integer _ch;
//     integer _row;
//     integer _col;
// begin
//     for(_ch=0 ; _ch<NUM_OF_CHANNEL ; _ch=_ch+1) begin
//         for(_row=0 ; _row<SIZE_OF_PIC ; _row=_row+1) begin
//             for(_col=0 ; _col<SIZE_OF_PIC ; _col=_col+1) begin
//                 _originalImage[_ch][_row][_col] = _image[_noPic][_ch][_row][_col];
//             end
//         end
//     end
// end endtask

// //
// // Operation
// //
// task auto_focus;
//     integer _crst;
//     integer _ch;
//     integer _row;
//     integer _col;

//     integer temp;
//     parameter PIC_MID = SIZE_OF_PIC/2;
// begin
//     for(_crst=0 ; _crst<NUM_OF_CONTRASTS ; _crst=_crst+1) begin
//         //
//         // Clear window
//         //
//         for(_ch=0 ; _ch<NUM_OF_CHANNEL ; _ch=_ch+1) begin
//             for(_row=0 ; _row<MAX_SIZE_OF_CONTRASTS ; _row=_row+1) begin
//                 for(_col=0 ; _col<MAX_SIZE_OF_CONTRASTS ; _col=_col+1) begin
//                     _focusWindow[_crst][_ch][_row][_col] = 0;
//                 end
//             end
//         end
//         for(_row=0 ; _row<MAX_SIZE_OF_CONTRASTS ; _row=_row+1) begin
//             for(_col=0 ; _col<MAX_SIZE_OF_CONTRASTS ; _col=_col+1) begin
//                 _focusGrayWindow[_crst][_row][_col] = 0;
//             end
//         end
//         //
//         // Set window
//         //
//         for(_ch=0 ; _ch<NUM_OF_CHANNEL ; _ch=_ch+1) begin
//             for(_row=0 ; _row<_constrast[_crst] ; _row=_row+1) begin
//                 for(_col=0 ; _col<_constrast[_crst] ; _col=_col+1) begin
//                     _focusWindow[_crst][_ch][_row][_col] = 
//                         _originalImage[_ch][PIC_MID-_constrast[_crst]/2+_row][PIC_MID-_constrast[_crst]/2+_col];
//                 end
//             end
//         end
//         for(_row=0 ; _row<_constrast[_crst] ; _row=_row+1) begin
//             for(_col=0 ; _col<_constrast[_crst] ; _col=_col+1) begin
//                 for(_ch=0 ; _ch<NUM_OF_CHANNEL ; _ch=_ch+1) begin
//                     _focusGrayWindow[_crst][_row][_col] =
//                         _focusGrayWindow[_crst][_row][_col] +
//                         $floor(_focusWindow[_crst][_ch][_row][_col] * _grayscaleRatio[_ch]);
//                 end
//             end
//         end
//         //
//         // Difference on vertical & horizontal direction
//         //
//         _focusDiffHorizontal[_crst] = 0;
//         _focusDiffVertical[_crst] = 0;
//         _focusNormalizedDiff[_crst] = 0;
//         // Col difference
//         for(_row=0 ; _row<_constrast[_crst] ; _row=_row+1) begin
//             for(_col=0 ; _col<_constrast[_crst]-1 ; _col=_col+1) begin
//                 temp =
//                     (_focusGrayWindow[_crst][_row][_col]   - _focusGrayWindow[_crst][_row][_col+1]) > 0 ?
//                     (_focusGrayWindow[_crst][_row][_col]   - _focusGrayWindow[_crst][_row][_col+1]) :
//                     (_focusGrayWindow[_crst][_row][_col+1] - _focusGrayWindow[_crst][_row][_col]);
//                 _focusDiffHorizontal[_crst] = 
//                     _focusDiffHorizontal[_crst] + temp;
//             end
//         end
//         // Row difference
//         for(_col=0 ; _col<_constrast[_crst] ; _col=_col+1) begin
//             for(_row=0 ; _row<_constrast[_crst]-1 ; _row=_row+1) begin
//                 temp =
//                     (_focusGrayWindow[_crst][_row+1][_col] - _focusGrayWindow[_crst][_row][_col]) > 0 ?
//                     (_focusGrayWindow[_crst][_row+1][_col] - _focusGrayWindow[_crst][_row][_col]) :
//                     (_focusGrayWindow[_crst][_row][_col]   - _focusGrayWindow[_crst][_row+1][_col]);
//                 _focusDiffVertical[_crst] = 
//                     _focusDiffVertical[_crst] + temp;
//             end
//         end
//         //
//         // Normalize difference
//         //
//         _focusNormalizedDiff[_crst] = 
//             (_focusDiffVertical[_crst] + _focusDiffHorizontal[_crst]) / (_constrast[_crst]*_constrast[_crst]);
//     end
//     //
//     // Find max contrast
//     //
//     _maxContrast = -1;
//     temp = -1;
//     for(_crst=0 ; _crst<NUM_OF_CONTRASTS ; _crst=_crst+1) begin
//         if(_focusNormalizedDiff[_crst] > temp) begin
//             _maxContrast = _crst;
//             temp = _focusNormalizedDiff[_crst];
//         end
//     end
// end endtask

// task auto_exposure;
//     integer _ch;
//     integer _row;
//     integer _col;
//     integer temp;
// begin
//     //
//     // Adjust
//     //
//     for(_ch=0 ; _ch<NUM_OF_CHANNEL ; _ch=_ch+1) begin
//         for(_row=0 ; _row<SIZE_OF_PIC ; _row=_row+1) begin
//             for(_col=0 ; _col<SIZE_OF_PIC ; _col=_col+1) begin
//                 temp = $floor(_originalImage[_ch][_row][_col] * _ratio[_ratioMode]);
//                 _image[_noPic][_ch][_row][_col] = 
//                     (temp >= (2**BITS_OF_PIXEL - 1)) ? 
//                         (2**BITS_OF_PIXEL - 1) : temp;
//             end
//         end
//     end
//     //
//     // Average grayscale
//     //
//     _exposureGrayscale = 0;
//     for(_row=0 ; _row<SIZE_OF_PIC ; _row=_row+1) begin
//         for(_col=0 ; _col<SIZE_OF_PIC ; _col=_col+1) begin
//             for(_ch=0 ; _ch<NUM_OF_CHANNEL ; _ch=_ch+1) begin
//                 _exposureGrayscale = _exposureGrayscale +
//                     $floor(_image[_noPic][_ch][_row][_col] * _grayscaleRatio[_ch]);
//             end
//         end
//     end
//     _exposureGrayscale = _exposureGrayscale/(SIZE_OF_PIC*SIZE_OF_PIC);
// end endtask

// //
// // Utility
// //
// function isErr;
//     input integer in1;
//     input integer in2;
//     integer abs;
// begin
//     if(_mode!==1) begin
//         $display("[ERROR] [MODE] The mode should be 1. (Auto exposure)");
//         $finish;
//     end
//     abs = (in1 - in2) > 0 ? in1 - in2 : in2 - in1;
//     isErr = (abs >= ERROR_MARGIN) ? 1 : 0;
// end endfunction

// //
// // Dump
// //
// parameter DUMP_OPT_PIXEL = 12;
// parameter DUMP_SIZE_PIXEL = 4;
// dumper #(.DUMP_ELEMENT_SIZE(DUMP_OPT_PIXEL)) optDumper();
// dumper #(.DUMP_ELEMENT_SIZE(DUMP_SIZE_PIXEL)) pixelDumper();

// task clear_dump_file;
//     integer file;
// begin
//     file = $fopen(IMAGE_ORIGINAL_FILE, "w");
//     $fclose(file);
//     file = $fopen(IMAGE_ADJUSTED_FILE, "w");
//     $fclose(file);
//     file = $fopen(AUTO_FOCUS_FILE, "w");
//     $fclose(file);
//     file = $fopen(AUTO_EXPOSURE_FILE, "w");
//     $fclose(file);
// end endtask

// task dump_original_image;
//     integer file;
//     integer _ch;
//     integer _row;
//     integer _col;

//     reg[DUMP_OPT_PIXEL*8:1] _strOpt;
//     reg[DUMP_SIZE_PIXEL*8:1] _strPixel;
    
// begin
//     file = $fopen(IMAGE_ORIGINAL_FILE, "w");
//     // Operation
//     optDumper.addSeperator(file, 2);
//     optDumper.addCell(file, "Pat No.", "s", 1);
//     optDumper.addCell(file,    pat, "d", 0);
//     optDumper.addLine(file);
//     optDumper.addSeperator(file, 2);
//     optDumper.addCell(file, "Pic No.", "s", 1);
//     optDumper.addCell(file,    _noPic, "d", 0);
//     optDumper.addLine(file);
//     optDumper.addCell(file, "Mode", "s", 1);
//     optDumper.addCell(file,  _mode, "d", 0);
//     optDumper.addLine(file);
//     if(_mode == 1) begin
//         optDumper.addCell(file, "Ratio Mode", "s", 1);
//         optDumper.addCell(file,   _ratioMode, "d", 0);
//         optDumper.addLine(file);
//         optDumper.addCell(file, "Ratio Value", "s", 1);
//         $sformat(_strOpt, "%12.3f", _ratio[_ratioMode]);
//         optDumper.addCell(file, _strOpt, "s", 0);
//         optDumper.addLine(file);
//     end
//     optDumper.addSeperator(file, 2);
//     optDumper.addLine(file);

//     // Image
//     for(_ch=0 ; _ch<NUM_OF_CHANNEL ; _ch=_ch+1) begin
//         // RGB
//         pixelDumper.addSeperator(file, SIZE_OF_PIC+1);
//         case(_ch)
//             'd0:pixelDumper.addCell(file, "R-0", "s", 1);
//             'd1:pixelDumper.addCell(file, "G-1", "s", 1);
//             'd2:pixelDumper.addCell(file, "B-2", "s", 1);
//         endcase
//         // Column index
//         for(_col=0 ; _col<SIZE_OF_PIC ; _col=_col+1) begin
//             pixelDumper.addCell(file, _col, "d", 0);
//         end
//         optDumper.addLine(file);
//         pixelDumper.addSeperator(file, SIZE_OF_PIC+1);
//         // Row index & pixel
//         for(_row=0 ; _row<SIZE_OF_PIC ; _row=_row+1) begin
//             // Row index
//             pixelDumper.addCell(file, _row, "d", 1);
//             // Pixel
//             for(_col=0 ; _col<SIZE_OF_PIC ; _col=_col+1) begin
//                 pixelDumper.addCell(file, _originalImage[_ch][_row][_col], "d", 0);
//             end
//             optDumper.addLine(file);
//         end
//         pixelDumper.addSeperator(file, SIZE_OF_PIC+1);
//         optDumper.addLine(file);
//     end
//     $fclose(file);
// end endtask

// task dump_adjusted_image;
//     integer file;
//     integer _ch;
//     integer _row;
//     integer _col;

//     reg[DUMP_OPT_PIXEL*8:1] _strOpt;
//     reg[DUMP_SIZE_PIXEL*8:1] _strPixel;
    
// begin
//     file = $fopen(IMAGE_ADJUSTED_FILE, "w");
//     // Operation
//     optDumper.addSeperator(file, 2);
//     optDumper.addCell(file, "Pat No.", "s", 1);
//     optDumper.addCell(file,    pat, "d", 0);
//     optDumper.addLine(file);
//     optDumper.addSeperator(file, 2);
//     optDumper.addCell(file, "Pic No.", "s", 1);
//     optDumper.addCell(file,    _noPic, "d", 0);
//     optDumper.addLine(file);
//     optDumper.addCell(file, "Mode", "s", 1);
//     optDumper.addCell(file,  _mode, "d", 0);
//     optDumper.addLine(file);
//     if(_mode == 1) begin
//         optDumper.addCell(file, "Ratio Mode", "s", 1);
//         optDumper.addCell(file,   _ratioMode, "d", 0);
//         optDumper.addLine(file);
//         optDumper.addCell(file, "Ratio Value", "s", 1);
//         $sformat(_strOpt, "%12.3f", _ratio[_ratioMode]);
//         optDumper.addCell(file, _strOpt, "s", 0);
//         optDumper.addLine(file);
//     end
//     optDumper.addSeperator(file, 2);
//     optDumper.addLine(file);

//     // Image
//     for(_ch=0 ; _ch<NUM_OF_CHANNEL ; _ch=_ch+1) begin
//         // RGB
//         pixelDumper.addSeperator(file, SIZE_OF_PIC+1);
//         case(_ch)
//             'd0:pixelDumper.addCell(file, "R-0", "s", 1);
//             'd1:pixelDumper.addCell(file, "G-1", "s", 1);
//             'd2:pixelDumper.addCell(file, "B-2", "s", 1);
//         endcase
//         // Column index
//         for(_col=0 ; _col<SIZE_OF_PIC ; _col=_col+1) begin
//             pixelDumper.addCell(file, _col, "d", 0);
//         end
//         optDumper.addLine(file);
//         pixelDumper.addSeperator(file, SIZE_OF_PIC+1);
//         // Row index & pixel
//         for(_row=0 ; _row<SIZE_OF_PIC ; _row=_row+1) begin
//             // Row index
//             pixelDumper.addCell(file, _row, "d", 1);
//             // Pixel
//             for(_col=0 ; _col<SIZE_OF_PIC ; _col=_col+1) begin
//                 // if(_image[_noPic][_ch][_row][_col] !== _originalImage[_ch][_row][_col]) begin
//                 //     $sformat(_strPixel, "*%3d", _image[_noPic][_ch][_row][_col]);
//                 // end
//                 // else begin
//                 //     $sformat(_strPixel, "%3d", _image[_noPic][_ch][_row][_col]);
//                 // end
//                 // pixelDumper.addCell(file, _strPixel, "s", 0);
//                 pixelDumper.addCell(file, _image[_noPic][_ch][_row][_col], "d", 0);
//             end
//             optDumper.addLine(file);
//         end
//         pixelDumper.addSeperator(file, SIZE_OF_PIC+1);
//         optDumper.addLine(file);
//     end
//     $fclose(file);
// end endtask

// task dump_focus;
//     integer file;
//     integer _crst;
//     integer _ch;
//     integer _row;
//     integer _col;
//     reg[DUMP_SIZE_PIXEL*8:1] _strPixel;
// begin
//     file = $fopen("auto_focus.txt", "w");
//     $fwrite(file, "[ Auto focus ]\n\n");
//     for(_crst=0 ; _crst<NUM_OF_CONTRASTS ; _crst=_crst+1) begin
//         //
//         // Focus size
//         //
//         $fwrite(file, "[ %1d*%1d ]\n", _constrast[_crst], _constrast[_crst]);
//         //
//         // Focus window
//         //
//         $fwrite(file, "[ Focus window ]\n");
//         for(_ch=0 ; _ch<NUM_OF_CHANNEL ; _ch=_ch+1) begin
//             pixelDumper.addSeperator(file, _constrast[_crst]+1);
//             case(_ch)
//                 'd0:pixelDumper.addCell(file, "R-0", "s", 1);
//                 'd1:pixelDumper.addCell(file, "G-1", "s", 1);
//                 'd2:pixelDumper.addCell(file, "B-2", "s", 1);
//             endcase
//             // Column index
//             for(_col=0 ; _col<_constrast[_crst] ; _col=_col+1) begin
//                 pixelDumper.addCell(file, _col, "d", 0);
//             end
//             optDumper.addLine(file);
//             pixelDumper.addSeperator(file, _constrast[_crst]+1);
//             // Row index & pixel
//             for(_row=0 ; _row<_constrast[_crst] ; _row=_row+1) begin
//                 // Row index
//                 pixelDumper.addCell(file, _row, "d", 1);
//                 // Pixel
//                 for(_col=0 ; _col<_constrast[_crst] ; _col=_col+1) begin
//                     pixelDumper.addCell(file, _focusWindow[_crst][_ch][_row][_col], "d", 0);
//                 end
//                 optDumper.addLine(file);
//             end
//             pixelDumper.addSeperator(file, _constrast[_crst]+1);
//             optDumper.addLine(file);
//         end

//         //
//         // Focus grayscale
//         //
//         $fwrite(file, "[ Focus grayscale ]\n");
//         // Column index
//         pixelDumper.addSeperator(file, _constrast[_crst]+1);
//         pixelDumper.addCell(file, "Gray", "s", 1);
//         for(_col=0 ; _col<_constrast[_crst] ; _col=_col+1) begin
//             pixelDumper.addCell(file, _col, "d", 0);
//         end
//         optDumper.addLine(file);
//         pixelDumper.addSeperator(file, _constrast[_crst]+1);
//         // Row index & pixel
//         for(_row=0 ; _row<_constrast[_crst] ; _row=_row+1) begin
//             // Row index
//             pixelDumper.addCell(file, _row, "d", 1);
//             // Pixel
//             for(_col=0 ; _col<_constrast[_crst] ; _col=_col+1) begin
//                 pixelDumper.addCell(file, _focusGrayWindow[_crst][_row][_col], "d", 0);
//             end
//             optDumper.addLine(file);
//         end
//         pixelDumper.addSeperator(file, _constrast[_crst]+1);
//         optDumper.addLine(file);

//         //
//         // Focus difference
//         //
//         $fwrite(file, "[ Focus horizontal difference ] : %-10d\n", _focusDiffHorizontal[_crst]);
//         $fwrite(file, "[ Focus vertical difference   ] : %-10d\n", _focusDiffVertical[_crst]);
//         $fwrite(file, "[ Focus normalized difference ] : %-10d\n\n", _focusNormalizedDiff[_crst]);
//     end
//     $fwrite(file, "[ Max contrast index / value  ] : %-2d / %-2d\n", _maxContrast, _constrast[_maxContrast]);
//     $fwrite(file, "[ Your max contrast ] : %-2d\n", _yourOutput);
//     $fclose(file);
// end endtask

// task dump_exposure;
//     integer file;
//     integer _ch;
//     integer _row;
//     integer _col;
// begin
//     file = $fopen(AUTO_EXPOSURE_FILE, "w");
//     $fwrite(file, "[ Exposure grayscale ] : %-10d\n", _exposureGrayscale);
//     $fwrite(file, "[     Your grayscale ] : %-10d\n", _yourOutput);
//     $fclose(file);
// end endtask

// //======================================
// //              MAIN
// //======================================
// initial exe_task;

// //======================================
// //              CLOCK
// //======================================
// initial clk = 1'b0;
// always #(CYCLE/2.0) clk = ~clk;

// //======================================
// //              TASKS
// //======================================
// task exe_task; begin
//     case(MODE)
//         'd0, 'd1: generate_dram_task;
//         'd2: validate_design_task;
//         default: begin
//             $display("[ERROR] [PARAMETER] Mode (%-d) isn't valid...", MODE);
//             $finish;
//         end
//     endcase
// end endtask

// task generate_dram_task;
//     integer file;
//     integer _pic;
//     integer _ch;
//     integer _row;
//     integer _col;
// begin
//     $display("[Info] Start to generate dram.dat");
//     file = $fopen(DRAMDAT_TO_GENERATED, "w");
//     if (file == 0) begin
//         $display("[ERROR] [FILE] The file (%0s) can't be opened", DRAMDAT_TO_GENERATED);
//         $finish;
//     end
//     for(_pic=0 ; _pic<NUM_OF_PIC ; _pic=_pic+1) begin
//         $fwrite(file, "@%-5h\n",
//             START_OF_DRAM_ADDRESS+_pic*NUM_OF_CHANNEL*SIZE_OF_PIC*SIZE_OF_PIC);
//         for(_ch=0 ; _ch<NUM_OF_CHANNEL ; _ch=_ch+1) begin
//             for(_row=0 ; _row<SIZE_OF_PIC ; _row=_row+1) begin
//                 for(_col=0 ; _col<SIZE_OF_PIC ; _col=_col+1) begin
//                     if(MODE == 0) $fwrite(file, "%02h ", {$random(SEED)} % 26); // simple
//                     else          $fwrite(file, "%02h ", {$random(SEED)} % 2**BITS_OF_PIXEL); // regular
//                 end
//                 $fwrite(file, "\n");
//             end
//             $fwrite(file, "\n");
//         end
//     end
//     $fclose(file);
//     $finish;
// end endtask

// task validate_design_task; begin
//     reset_task;
//     load_pic_from_dram;
//     for(pat=0 ; pat<TOTAL_PATNUM ; pat=pat+1) begin
//         input_task;
//         cal_task;
//         wait_task;
//         check_task;
//         // Print Pass Info and accumulate the total latency
//         $display("%0sPASS PATTERN NO.%4d %0sCycles: %3d%0s",txt_blue_prefix, pat, txt_green_prefix, exe_lat, reset_color);
//     end
//     pass_task;
// end endtask

// task reset_task; begin
//     force clk = 0;
//     rst_n = 1;
//     in_valid = 0;
//     in_pic_no = 'dx;
//     in_mode = 'dx;
//     in_ratio_mode = 'dx;

//     tot_lat = 0;

//     repeat(5) #(CYCLE/2.0) rst_n = 0;
//     repeat(5) #(CYCLE/2.0) rst_n = 1;
//     if(out_valid !== 0 || out_data !== 0) begin
//         $display("[ERROR] [Reset] Output signal should be 0 at %-12d ps  ", $time*1000);
//         repeat(5) #(CYCLE);
//         $finish;
//     end
//     #(CYCLE/2.0) release clk;
// end endtask

// task input_task; begin
//     repeat(2) @(negedge clk);
//     _noPic = {$random(SEED)} % NUM_OF_PIC;
//     _mode = {$random(SEED)} % NUM_OF_MODE;
//     _ratioMode = (_mode == 1) ? {$random(SEED)} % NUM_OF_RATIO : 'dx;

//     in_valid = 1;
//     in_pic_no = _noPic;
//     in_mode = _mode;
//     in_ratio_mode = (_mode == 1) ? _ratioMode : 'dx;
//     @(negedge clk);
//     in_valid = 0;
//     in_pic_no = 'dx;
//     in_mode = 'dx;
//     in_ratio_mode = 'dx;
// end endtask

// task cal_task;
//     integer size;
// begin
//     record_original_image;
//     case(_mode)
//         'd0: auto_focus;
//         'd1: auto_exposure;
//         default: begin
//             $display("[ERROR] [CAL] The mode (%2d) is no valid", _mode);
//             $finish;
//         end
//     endcase
//     if(DEBUG) begin
//         clear_dump_file;
//         dump_original_image;
//         dump_adjusted_image;
//         dump_focus;
//         dump_exposure;
//     end
// end endtask

// task wait_task; begin
//     exe_lat = -1;
//     while(out_valid !== 1) begin
//         if(out_data !== 0) begin
//             $display("[ERROR] [WAIT] Output signal should be 0 at %-12d ps  ", $time*1000);
//             repeat(5) @(negedge clk);
//             $finish;
//         end
//         if(exe_lat == DELAY) begin
//             $display("[ERROR] [WAIT] The execution latency at %-12d ps is over %5d cycles  ", $time*1000, DELAY);
//             repeat(5) @(negedge clk);
//             $finish; 
//         end
//         exe_lat = exe_lat + 1;
//         @(negedge clk);
//     end
// end endtask

// task check_task;
//     integer out_lat;
// begin
//     out_lat = 0;
//     while(out_valid===1) begin
//         if(out_lat==OUTNUM) begin
//             $display("[ERROR] [OUTPUT] Out cycles is more than %3d at %-12d ps", OUTNUM, $time*1000);
//             repeat(5) @(negedge clk);
//             $finish;
//         end

//         _yourOutput = out_data;

//         out_lat = out_lat + 1;
//         @(negedge clk);
//     end
//     if(out_lat<OUTNUM) begin
//         $display("[ERROR] [OUTPUT] Out cycles is less than %3d at %-12d ps", OUTNUM, $time*1000);
//         repeat(5) @(negedge clk);
//         $finish;
//     end

//     if(_mode==0) begin
//         if(_yourOutput!==_maxContrast) begin
//             $display("[ERROR] [OUTPUT] Output is not correct...\n");
//             $display("[ERROR] [OUTPUT] Dump debugging file...");
//             $display("[ERROR] [OUTPUT]      image_original.txt");
//             $display("[ERROR] [OUTPUT]      auto_focus.txt\n");
//             $display("[ERROR] [OUTPUT] Your output : %-d", _yourOutput);
//             $display("[ERROR] [OUTPUT] Golden max contrast : %-d\n", _maxContrast);
//             clear_dump_file;
//             dump_original_image;
//             dump_focus;
//             repeat(5) @(negedge clk);
//             $finish;
//         end
//     end
//     else begin
//         if(isErr(_yourOutput,_exposureGrayscale)) begin
//             $display("[ERROR] [OUTPUT] Output is not correct...\n");
//             $display("[ERROR] [OUTPUT] Dump debugging file...");
//             $display("[ERROR] [OUTPUT]      image_original.txt -> before auto exposure");
//             $display("[ERROR] [OUTPUT]      image_adjusted.txt ->  after auto exposure");
//             $display("[ERROR] [OUTPUT]      auto_exposure.txt\n");
//             $display("[ERROR] [OUTPUT] Your output : %-d", _yourOutput);
//             $display("[ERROR] [OUTPUT] Golden exposure grayscale : %-d\n", _exposureGrayscale);
//             clear_dump_file;
//             dump_original_image;
//             dump_adjusted_image;
//             dump_exposure;
//             repeat(5) @(negedge clk);
//             $finish;
//         end
//     end

//     tot_lat = tot_lat + exe_lat;
// end endtask

// task pass_task; begin
//     $display("\033[1;33m                `oo+oy+`                            \033[1;35m Congratulation!!! \033[1;0m                                   ");
//     $display("\033[1;33m               /h/----+y        `+++++:             \033[1;35m PASS This Lab........Maybe \033[1;0m                          ");
//     $display("\033[1;33m             .y------:m/+ydoo+:y:---:+o             \033[1;35m Total Latency : %-10d\033[1;0m                                ", tot_lat);
//     $display("\033[1;33m              o+------/y--::::::+oso+:/y                                                                                     ");
//     $display("\033[1;33m              s/-----:/:----------:+ooy+-                                                                                    ");
//     $display("\033[1;33m             /o----------------/yhyo/::/o+/:-.`                                                                              ");
//     $display("\033[1;33m            `ys----------------:::--------:::+yyo+                                                                           ");
//     $display("\033[1;33m            .d/:-------------------:--------/--/hos/                                                                         ");
//     $display("\033[1;33m            y/-------------------::ds------:s:/-:sy-                                                                         ");
//     $display("\033[1;33m           +y--------------------::os:-----:ssm/o+`                                                                          ");
//     $display("\033[1;33m          `d:-----------------------:-----/+o++yNNmms                                                                        ");
//     $display("\033[1;33m           /y-----------------------------------hMMMMN.                                                                      ");
//     $display("\033[1;33m           o+---------------------://:----------:odmdy/+.                                                                    ");
//     $display("\033[1;33m           o+---------------------::y:------------::+o-/h                                                                    ");
//     $display("\033[1;33m           :y-----------------------+s:------------/h:-:d                                                                    ");
//     $display("\033[1;33m           `m/-----------------------+y/---------:oy:--/y                                                                    ");
//     $display("\033[1;33m            /h------------------------:os++/:::/+o/:--:h-                                                                    ");
//     $display("\033[1;33m         `:+ym--------------------------://++++o/:---:h/                                                                     ");
//     $display("\033[1;31m        `hhhhhoooo++oo+/:\033[1;33m--------------------:oo----\033[1;31m+dd+                                                 ");
//     $display("\033[1;31m         shyyyhhhhhhhhhhhso/:\033[1;33m---------------:+/---\033[1;31m/ydyyhs:`                                              ");
//     $display("\033[1;31m         .mhyyyyyyhhhdddhhhhhs+:\033[1;33m----------------\033[1;31m:sdmhyyyyyyo:                                            ");
//     $display("\033[1;31m        `hhdhhyyyyhhhhhddddhyyyyyo++/:\033[1;33m--------\033[1;31m:odmyhmhhyyyyhy                                            ");
//     $display("\033[1;31m        -dyyhhyyyyyyhdhyhhddhhyyyyyhhhs+/::\033[1;33m-\033[1;31m:ohdmhdhhhdmdhdmy:                                           ");
//     $display("\033[1;31m         hhdhyyyyyyyyyddyyyyhdddhhyyyyyhhhyyhdhdyyhyys+ossyhssy:-`                                                           ");
//     $display("\033[1;31m         `Ndyyyyyyyyyyymdyyyyyyyhddddhhhyhhhhhhhhy+/:\033[1;33m-------::/+o++++-`                                            ");
//     $display("\033[1;31m          dyyyyyyyyyyyyhNyydyyyyyyyyyyhhhhyyhhy+/\033[1;33m------------------:/ooo:`                                         ");
//     $display("\033[1;31m         :myyyyyyyyyyyyyNyhmhhhyyyyyhdhyyyhho/\033[1;33m-------------------------:+o/`                                       ");
//     $display("\033[1;31m        /dyyyyyyyyyyyyyyddmmhyyyyyyhhyyyhh+:\033[1;33m-----------------------------:+s-                                      ");
//     $display("\033[1;31m      +dyyyyyyyyyyyyyyydmyyyyyyyyyyyyyds:\033[1;33m---------------------------------:s+                                      ");
//     $display("\033[1;31m      -ddhhyyyyyyyyyyyyyddyyyyyyyyyyyhd+\033[1;33m------------------------------------:oo              `-++o+:.`             ");
//     $display("\033[1;31m       `/dhshdhyyyyyyyyyhdyyyyyyyyyydh:\033[1;33m---------------------------------------s/            -o/://:/+s             ");
//     $display("\033[1;31m         os-:/oyhhhhyyyydhyyyyyyyyyds:\033[1;33m----------------------------------------:h:--.`      `y:------+os            ");
//     $display("\033[1;33m         h+-----\033[1;31m:/+oosshdyyyyyyyyhds\033[1;33m-------------------------------------------+h//o+s+-.` :o-------s/y  ");
//     $display("\033[1;33m         m:------------\033[1;31mdyyyyyyyyymo\033[1;33m--------------------------------------------oh----:://++oo------:s/d  ");
//     $display("\033[1;33m        `N/-----------+\033[1;31mmyyyyyyyydo\033[1;33m---------------------------------------------sy---------:/s------+o/d  ");
//     $display("\033[1;33m        .m-----------:d\033[1;31mhhyyyyyyd+\033[1;33m----------------------------------------------y+-----------+:-----oo/h  ");
//     $display("\033[1;33m        +s-----------+N\033[1;31mhmyyyyhd/\033[1;33m----------------------------------------------:h:-----------::-----+o/m  ");
//     $display("\033[1;33m        h/----------:d/\033[1;31mmmhyyhh:\033[1;33m-----------------------------------------------oo-------------------+o/h  ");
//     $display("\033[1;33m       `y-----------so /\033[1;31mNhydh:\033[1;33m-----------------------------------------------/h:-------------------:soo  ");
//     $display("\033[1;33m    `.:+o:---------+h   \033[1;31mmddhhh/:\033[1;33m---------------:/osssssoo+/::---------------+d+//++///::+++//::::::/y+`  ");
//     $display("\033[1;33m   -s+/::/--------+d.   \033[1;31mohso+/+y/:\033[1;33m-----------:yo+/:-----:/oooo/:----------:+s//::-.....--:://////+/:`    ");
//     $display("\033[1;33m   s/------------/y`           `/oo:--------:y/-------------:/oo+:------:/s:                                                 ");
//     $display("\033[1;33m   o+:--------::++`              `:so/:-----s+-----------------:oy+:--:+s/``````                                             ");
//     $display("\033[1;33m    :+o++///+oo/.                   .+o+::--os-------------------:oy+oo:`/o+++++o-                                           ");
//     $display("\033[1;33m       .---.`                          -+oo/:yo:-------------------:oy-:h/:---:+oyo                                          ");
//     $display("\033[1;33m                                          `:+omy/---------------------+h:----:y+//so                                         ");
//     $display("\033[1;33m                                              `-ys:-------------------+s-----+s///om                                         ");
//     $display("\033[1;33m                                                 -os+::---------------/y-----ho///om                                         ");
//     $display("\033[1;33m                                                    -+oo//:-----------:h-----h+///+d                                         ");
//     $display("\033[1;33m                                                       `-oyy+:---------s:----s/////y                                         ");
//     $display("\033[1;33m                                                           `-/o+::-----:+----oo///+s                                         ");
//     $display("\033[1;33m                                                               ./+o+::-------:y///s:                                         ");
//     $display("\033[1;33m                                                                   ./+oo/-----oo/+h                                          ");
//     $display("\033[1;33m                                                                       `://++++syo`                                          ");
//     $display("\033[1;0m"); 
//     repeat(5) @(negedge clk);
//     $finish;
// end endtask

// endmodule

// module dumper #(
//     parameter DUMP_ELEMENT_SIZE = 4
// );

// // Dump
// parameter DUMP_NUM_OF_SPACE = 2;
// parameter DUMP_NUM_OF_SEP = 2;
// parameter SIZE_OF_BUFFER = 256;

// task addLine;
//     input integer file;
// begin
//     $fwrite(file, "\n");
// end endtask

// task addSeperator;
//     input integer file;
//     input integer _num;
//     integer _idx;
//     reg[(DUMP_ELEMENT_SIZE+DUMP_NUM_OF_SPACE+DUMP_NUM_OF_SEP)*8:1] _line; // 4 = 2 spaces with 2 "+"
// begin
//     _line = "";
//     for(_idx=1 ; _idx<=DUMP_ELEMENT_SIZE+2 ; _idx=_idx+1) begin
//         _line = {_line, "-"};
//     end
//     _line = {_line, "+"};
//     $fwrite(file, "+");
//     for(_idx=0 ; _idx<_num ; _idx=_idx+1) $fwrite(file, "%0s", _line);
//     $fwrite(file, "\n");
// end endtask

// // TODO
// // Only support %d %s
// // Should consider the %f ex : %8.3f, %12.1f
// task addCell;
//     input integer file;
//     input reg[DUMP_ELEMENT_SIZE*8:1] _in;
//     input reg[8:1] _type;
//     input reg _isStart;
//     reg[SIZE_OF_BUFFER*8:1] _format;
//     reg[DUMP_ELEMENT_SIZE*8:1] _inFormat;
//     reg[(DUMP_ELEMENT_SIZE+DUMP_NUM_OF_SPACE+DUMP_NUM_OF_SEP)*8:1] _line;
// begin
//     // Format
//     $sformat(_format, "%%%-d", DUMP_ELEMENT_SIZE);
//     _format = {_format[(SIZE_OF_BUFFER-1)*8:1], _type};
//     $sformat(_inFormat, _format, _in);
//     // Output
//     _line = _isStart ? "| " : " ";
//     _line = {_line, _inFormat};
//     _line = {_line, " |"};
//     $fwrite(file, "%0s", _line);
// end endtask

// // task addCellUnformat;
// //     input integer file;
// //     input reg[DUMP_ELEMENT_SIZE*8:1] _in;
// //     input reg _isStart;
// //     reg[SIZE_OF_BUFFER*8:1] _format;
// //     reg[DUMP_ELEMENT_SIZE*8:1] _inFormat;
// //     reg[(DUMP_ELEMENT_SIZE+DUMP_NUM_OF_SPACE+DUMP_NUM_OF_SEP)*8:1] _line;
// // begin
// //     _line = _isStart ? "| " : " ";
// //     _line = {_line, _in};
// //     _line = {_line, " |"};
// //     $fwrite(file, "%0s", _line);
// // end endtask

// endmodule













// // `define CYCLE_TIME 10.0

// // `include "../00_TESTBED/pseudo_DRAM.v"

// // module PATTERN(
// //     // Input Signals
// //     clk,
// //     rst_n,
// //     in_valid,
// //     in_pic_no,
// //     in_mode,
// //     in_ratio_mode,
// //     out_valid,
// //     out_data
// // );

// // /* Input for design */
// // output reg        clk, rst_n;
// // output reg        in_valid;

// // output reg [3:0] in_pic_no;
// // output reg       in_mode;
// // output reg [1:0] in_ratio_mode;

// // input out_valid;
// // input [7:0] out_data;


// // //////////////////////////////////////////////////////////////////////
// // // Write your own task here
// // //////////////////////////////////////////////////////////////////////
// // initial clk=0;
// // always #(CYCLE/2.0) clk = ~clk;

// // // Do it yourself, I believe you can!!!

// // endmodule
