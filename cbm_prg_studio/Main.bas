0 ox=4096-7680:print"{clear}":poke36869,192:poke36878,15:poke36879,25
1 d=37154:p1=37151:p2=37152:do(0)=-1:do(1)=1:di=do(int(rnd(1)*2))
2 a$=">>>>>>>>>>>>>>>>>>>>>{left}{148}>":dimb(11):g=(37888-4096)
3 sc=1:ch=2:e1=0:d(0)=4:d(1)=2:d(4)=7:z=57:e3=1:q=10000:j=56
10 gosub100:poke36869,192:e4=0:e5=2
15 gosub70:h=0:y=0
16 s=(ox+8143)+int(rnd(1)*20):ifpeek(s+22)=62orpeek(s)=59then16
17 t=peek(s):pokes,58:pokes+g,0
19 v=(ox+7712)+b(y):w=62:do=do(int(rnd(1)*2))
20 sys828:onpeek(1)goto35,26,28,31,33
21 forn=1to23:next:goto41
26 ifpeek(s+22)=zthenpokes,t:pokes+g,d(t-j):s=s+22:goto40
27 goto41
28 di=-1:ifpeek(s+21)<62thenpokes,t:pokes+g,d(t-j):s=s-1:goto40
29 ift<>zthenpokes,t:pokes+g,d(t-j):s=s+di:t=peek(s):goto55
30 goto41
31 ift=zthenpokes,t:pokes+g,d(t-j):s=s-22:goto40
32 goto41
33 di=1:ifpeek(s+23)<62thenpokes,t:pokes+g,d(t-j):s=s+1:goto40
34 goto29
35 poke36876,240:pokes,t:pokes+g,d(t-j):s=s-22+di:t=peek(s):pokes,58:ift=60then55
36 ifpeek(s+22)=60thenss=ss+1000:print"{home}{reverse on}"tab(8-len(str$(ss)))ss
37 forn=1to5:next:pokes,t:pokes+g,d(t-j):s=s+22+di:t=peek(s):pokes,58:ifpeek(s+22)>61then55
38 pokes+g,0:poke36876,0:goto41
40 poke36876,200:poke36876,0:t=peek(s):pokes,58:pokes+g,0
41 ift=61thenss=ss+150:print"{home}{reverse on}"tab(8-len(str$(ss)))ss:h=h+1:t=62:ifh=16then64
42 ift=60then55
43 gosub98
45 pokev,w:pokev+g,d(w-j):v=v+do:w=peek(v):pokev,60:pokev+g,7
46 ifdo=22andpeek(v+22)=56thendo=do(int(rnd(1)*2)):goto48
47 ifw=63thendo=22
48 ifw=58then55
49 ifv<(ox+8164)then20
50 y=y+1:ify=12then55
51 pokev,62:goto19
55 poke36876,0:so=250:ift=60thent=w
56 poke36874,so:ifpeek(s+22)<>56ands<(ox+8164)thenpokes,t:pokes+g,d(t-j):s=s+22:t=peek(s):pokes,58:pokes+g,0
57 forn=1to17:next:so=so-5:ifso>150then56
58 poke36874,0:ch=ch-1:ifch=-1thenpoked,255:poke36869,192:print"{clear}{black}"ss:end
59 print"{home}{reverse on}"tab(14)ch:pokev,w:pokev+g,d(w-j):y=y+1:ifw=58thenpokev,t:pokev+g,d(t-j)
60 ify>10then15
61 ifs>(ox+8163)thenpokes,t:goto16
62 pokes,58:pokes+g,0:goto19
64 ify=11then67
65 forn=y+1to11:poke(ox+7712)+b(n),62:ss=ss+100:print"{home}{reverse on}"tab(8-len(str$(ss)))ss:gosub98
66 poke36877,250:form=240to250:poke36876,m:next:poke36876,0:poke36877,0:next
67 e2=e2+.05:sc=sc+1:e1=e1+1:ife1>8thene1=8
68 goto15
69 goto69
70 print"{clear}{purple}";:forn=1to21:printa$:next:printa$"{home}":b$=">88888888888888888888"
71 print"{down}{down}"tab(6)"?>>>>>>>>?{red}":printtab(6)"9{purple}88888888{red}9":printtab(6)"9>>>>>>>>9":printtab(6)"9>>>>>>>>9{purple}"
72 forn=1to3:printb$"{down}{down}{down}{down}":next:printb$"{home}";:poke(ox+8185),62
73 print"{reverse on}"tab(8-len(str$(ss)))ss;tab(14)ch;tab(17)sc:poke(ox+7697),163:forn=0to11:poke(ox+7712)+b(n),60
74 poke(ox+7712)+b(n)+g,7:next:forn=(ox+7834)to(ox+8164)step110:ifn=(ox+8164)then80
75 foro=1to3
76 r=n+1+int(rnd(1)*20):ifpeek(r)<>56then76
77 form=rtor+88step22:pokem,57:pokem+g,2:next:ifo>1andrnd(1)<e2thenpoker+(int(rnd(1)*2)+2)*22,63
78 ifrnd(1)<.5andpeek(r-22)=62thenpoker-22,63
79 next
80 foro=1toe1
81 r=n+3+int(rnd(1)*16):ifpeek(r)<>56orpeek(r-22)<>62orpeek(r+1)=62orpeek(r-1)=62then85
84 poker,62:poker-22,63
85 next
86 foro=1to4
87 r=n-21+int(rnd(1)*20):ifpeek(r)<>62orpeek(r+22)=62then87
88 poker,61:poker+g,0:next:next
89 poke(ox+7710),63:poke(ox+7715),63:poke(ox+7731),63:poke(ox+7738),63
90 forn=(ox+7812)to(ox+8142)step110:poken,63:next:forn=(ox+7833)to(ox+8163)step110:poken,63:next:return
98 ifss=q*e3thench=ch+1:e3=e3+1:print"{home}{reverse on}"tab(14)ch
99 return
100 data,1,21,22,23,24,42,43,44,45,46,47
101 data255,255,153,102,102,153,255,255,195,255,255,195,195,255,255,195,60,60,25,255,188
102 data60,36,231,3,4,24,24,60,126,126,60,60,66,165,153,153,165,66,60,,24,36,126,126,126
103 data126,,,,,,,,,,,,,,,,,
106 data169,,133,1,169,255,141,34,145,169,32,44,31,145,208,5,169,1,133,1,96,169,8,44
107 data31,145,208,5,169,2,133,1,96,169,16,44,31,145,208,5,169,3,133,1,96,169,4,44,31
108 data145,208,3,133,1,96,169,127,141,34,145,169,128,44,32,145,208,4,169,5,133,1,96
109 forn=0to11:readb(n):next:forn=7616to7679:readm:poke0,m:next
110 forn=828to899:readm:poken,m:next:return
111 rem lo scalatore per vic-20 digitato da saver71 18/11/2014
112 rem convertito per 16K nippur72 07/05/2020
