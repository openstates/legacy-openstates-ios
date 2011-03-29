!<arch>
DP.c            759797483   3053  3053  100644  8578      `
/*
 * 7-6-91      Jack Snoeyink procedures for testing/timing line simplification
 */

#include "DP.h"
#include "animate.h"
#include <sys/types.h>
#include <sys/times.h>

#define LAST 9

POINT *V, **R;

float  p[MAX_POINTS][2];

int n, num_result;
int outFlag, looping = 0;

double EPSILON = 0.0,		/* error tolerance */
  EPSILON_SQ = 0.0;

static int  cycler, CycleFlag = FALSE;

static int file_active = 0;

FILE *infp;
#define REC_LENGTH 144
char buffer[145];

POINT *Alloc_Points(n)
     int n; 
{ 	
  void *calloc();

  return ((POINT *) calloc(n, sizeof(POINT)));
}

void Print_Points(P, n, flag)
     POINT **P;
     int n, flag;
{
  int i;

  printf("%d points\n", n);
  if (flag)
    for (i = 0; i < n; i++)
      printf("%d: %.4f %.4f \n", i, (*(P[i]))[XX], (*(P[i]))[YY]);	/**/
  fflush(stdout);
}

void Print_Result(flag)
     int flag;
{
  if (!CycleFlag)
    Print_Points(R, num_result, flag);
}


#define TWO_PI 6.28318531


void fatalError(msg, var)
     char *msg, *var;
{
  fprintf(stderr, msg, *var);
  exit(1);
}

void ReadLine()
{
  int i;

  if (file_active = looping = (fread(&n, sizeof(int), 1, infp) == 1)) {
    fread(p[0], sizeof(float), 2*n, infp);
    for (i = 0; i < n; i++) {
      V[i][XX] = (double) p[i][0];
      V[i][YY] = (double) p[i][1];
    }
    while ((V[0][XX] == V[n-1][XX]) && (V[0][YY] == V[n-1][YY])) n--;
  }
}

void Parse(argc, argv)
    int argc;
    char **argv;
{
  double LEFT, RIGHT, BOTTOM, TOP;
#ifdef ANIMATE
  int xl, xh, yl, yh;

  yl = 0; 
  yh = getgdesc(GD_YPMAX);
  xl = 0;
  xh = getgdesc(GD_XPMAX);
  A_delay = 4;
  A_swapinterval = 2;
#endif /* ANIMATE */

  --argc; argv++;

  n = 50;
  cycler = 0;
  file_active = 0;

  while ((argc > 0) && (argv[0][0] == '-'))
      {
	if (!strcmp(argv[0], "-n")) {
	    if (sscanf(argv[1], "%d", &n) != 1) 
	      fatalError("ERROR -- \"%d\": bad n\n", (char *)(argv[1]));
	    argv += 2;
	    argc -= 2;
	}

#ifdef ANIMATE
	else if ((argc >= 2) && !strcmp(argv[0], "-d")) {
	    if (sscanf(argv[1], "%d", &A_delay) != 1) {
		fprintf(stderr, "ERROR -- \"%s\": bad delay\n", argv[1]);
		exit(1);
	      }
	    argv += 2;
	    argc -= 2;
	}
	else if ((argc >= 2) && !strcmp(argv[0], "-i")) {
	    if (sscanf(argv[1], "%d", &A_swapinterval) != 1) {
		fprintf(stderr, "ERROR -- \"%s\": bad swap interval\n", 
			argv[1]);
		exit(1);
	      }
	    argv += 2;
	    argc -= 2;
	}
	else if (!strcmp(argv[0], "-m")) {
	    argv++;
	    --argc;
	    A_modeq = 1;
	  }
	else if (!strcmp(argv[0], "-a")) {
	    argv++;
	    --argc;
	    A_ack = 1;
	  }
	else if (!strcmp(argv[0], "-pos")) {
	    if (sscanf(argv[1], "%d,%d,%d,%d", &xl, &xh, &yl, &yh) != 4) {
		fprintf(stderr, "ERROR -- \"%s\": unrecognized pos.\n",
			argv[1]);
		exit(1);
	    }
	    argv += 2;
	    argc -= 2;
	}
#endif /* ANIMATE */

	else if (!strcmp(argv[0], "-k")) {
	    if (sscanf(argv[1], "%d", &cycler) != 1) 
	      fatalError("ERROR -- \"%d\": bad kind of test case\n-k Test Case:    0/all\n   1/circle, 2/prtb circ, 3/mon random, 4/non-mon random,\n   5/ prtb zig-zag, 6/cnvx zig-zag, 7/cncv zig-zag, 8/spiral\n", (char *)(argv[1]));
	    argv += 2;
	    argc -= 2;
	  }
	else if (!strcmp(argv[0], "-e")) {
	    if (sscanf(argv[1], "%lf", &EPSILON) != 1)
	      fatalError("ERROR -- \"%lf\": bad epsilon\n", (char *)(argv[1]));
	    EPSILON_SQ = EPSILON * EPSILON;
	    argv += 2;
	    argc -= 2;
	  }
	else if (!strcmp(argv[0], "-f")) {
	  infp = fopen(argv[1], "r");
	  if (infp == NULL) 
	    fatalError("Could not open input file %s\n", (char *)(argv[1]));
	  fgets(buffer, REC_LENGTH, infp);
	  if (strncmp("my format", buffer, 9) != 0)
	    fatalError("File not in my format: %s\n", buffer);
	  sscanf(buffer, "my format %lg%lg%lg%lg",&LEFT, &RIGHT, &BOTTOM, &TOP);
	  file_active = 1;
	  argv += 2;
	  argc -= 2;
	}
	else if (!strcmp(argv[0], "-l")) {
	    if (sscanf(argv[1], "%d", &looping) != 1) 
	      fatalError("ERROR -- \"%d\": bad l\n", (char *)(argv[1]));
	    argv += 2;
	    argc -= 2;
	  }
	else if (!strcmp(argv[0], "-h")) {
	    argv++;
	    --argc;
	    fprintf(stderr, 
"usage: basic -n # no. pts  -k # test case  -l loop# -f file of test cases\n -e epsilon/n"
#ifdef ANIMATE
"   -d # anim. delay  -i # swap interval  -pos (xl,xh,yl,yh)\n"
"   -m display modes -a wait for space\n"
#endif /* ANIMATE */
);
	    exit(1);
	}
      }
#ifdef ANIMATE
  prefposition(xl, xh, yl, yh);
  aspect = ((double) xh - xl) / ((double) yh - yl);/**/
#endif /* ANIMATE */
}

#define SIGN(x) (x < 0 ? -1 : (x > 0 ? 1 : 0))

#define DET2(a, b, c, d)	/* 2x2 determinant */\
  ((a)*(d) - (c)*(b)) 
#define DETPts(p, q)		/* 2x2 determinant for points */\
  DET2(p[XX], p[YY], q[XX], q[YY])

int intersect(a, b, c, d)	/* check if (ab) \cap (cd) */
     POINT a, b, c, d;
{
  register double ab = DETPts(a, b);
  register double ac = DETPts(a, c);
  register double ad = DETPts(a, d);
  register double bc = DETPts(b, c);
  register double bd = DETPts(b, d);
  register double cd = DETPts(c, d);
  register double abc = bc - ac + ab;
  register double abd = bd - ad + ab;
  register double acd = cd - ad + ac;
  register double bcd = cd - bd + bc;

  return ((SIGN(abc)*SIGN(abd) == -1) && (SIGN(acd)*SIGN(bcd) == -1));
}


void swapV(i, j)
     int i,j;
{
  double tmp;

  tmp = V[i][XX]; V[i][XX] = V[j][XX]; V[j][XX] = tmp;
  tmp = V[i][YY]; V[i][YY] = V[j][YY]; V[j][YY] = tmp;
}


void untangle()
{
  int i, j, 
  oi, oj, 
  ti, tj, 
  k, l, flag, tmpflag;
  
  do
    {
      oi = random() % n;
      flag = 0;
      for (i = 0; i < n; i++)
	{
	  ti = (oi + i) % n;
	  oj = random() % n;
	  for (j = 0; j < n; j++)
	    {
	      tj = (oj + j) % n;
	      if ((ti + n + 1 - tj) % n > 2)
		if (intersect(V[ti], V[(ti+1)%n], V[tj], V[(tj+1)%n]))
		  {
		    flag = TRUE;
		    if (tj < ti + 1) tj = tj + n;
		    for (k = ti + 1, l = tj; k < l; k++, l--)
		      swapV(k % n, l % n);
		    break;
		  }
	    }
	}
    }
  while (flag);
}				/* working */



void Get_Points()
{
  double tmp;
  register int i;

  if (file_active) 
    ReadLine();
  else if (CycleFlag)
    looping = CycleFlag = (++cycler < LAST);
  else
    {
      if (looping)
	looping--;		/* decrement # of iterations */

      if (cycler < 0 || cycler > LAST) 
	{
	  printf("-k Test Case:    0/all\n");
	  printf("   1/circle, 2/prtb circ, 3/mon random, 4/non-mon random,\n");
	  printf("   5/ prtb zig-zag, 6/cnvx zig-zag, 7/cncv zig-zag, 8/spiral\n");
	  fflush(stdout);
	  exit(1);
	}
      if (cycler == 0)
	looping = CycleFlag = cycler = 1;
    }
  switch (cycler)
    {
    case 1:
      for (i = 0; i < n; i++)
	{
	  V[i][XX] = n / 2.0 * cos((TWO_PI * i) / n);
	  V[i][YY] = n / 2.0 * sin((TWO_PI * i) / n);
	}
      break;

    case 2:
      for (i = 0; i < n; i++)
	{
	  tmp = n/2.0 + drand48() * n/40.0;
	  V[i][XX] = tmp * cos((TWO_PI * i) / n);
	  V[i][YY] = tmp * sin((TWO_PI * i) / n);
	}
      break;

    case 3:
      for (i = 0; i < n; i++)
	{
	  V[i][XX] = (double) i;
	  V[i][YY] = ((double) n) * drand48();
	}
      break;
      
    case 4:
      for (i = 0; i < n; i++)
	{
	  V[i][XX] = n/2.0 * drand48();
	  V[i][YY] = n/2.0 * drand48();
	}
      untangle();/**/
      break;

    case 5:
      for (i = 0; i < n; i++)
	{
	  V[i][XX] = (double) i - n/2.0;
	  V[i][YY] = ((double)(i % 2) - 0.5) * i + n/10.0 * drand48();
	}
      break;

    case 6:
      tmp = sqrt((double) n);
      for (i = 0; i < n; i++)
	{
	  V[i][XX] = (double) i - n/2.0;
	  V[i][YY] = ((double)(i % 2) - 0.5) * sqrt((double) i) * tmp;
	}
      break;

    case 7:
      for (i = 0; i < n; i++)
	{
	  V[i][XX] = (double) i - n/2.0;
	  V[i][YY] = (((double)(i % 2) - 0.5) * i)/n*i;
	}
      break;

    case 8:
      for (i = 0; i < n; i++)
	{
	  V[i][XX] = i * cos(TWO_PI * (i % 3) / 3.0);
	  V[i][YY] = i * sin(TWO_PI * (i % 3) / 3.0);
	}
      break;
    case LAST:
      n = 1;
    }

/*  Print_Points(V, n, TRUE); /**/
}




struct tms      starttime, endtime;

void Start_Timing()
{
  times(&starttime);
}

void  End_Timing(flag)
     int flag;
{
  times(&endtime);
  if (flag != 0)
    printf("%d  in %d  out %d  %ld ticks  %.3f secs %d\n", cycler, n, num_result,
	   (endtime.tms_utime - starttime.tms_utime),
	   (float) (endtime.tms_utime - starttime.tms_utime) / 100.0, flag);
}

void Output(i, j)
     int i, j;
{
  if (outFlag)
    {
      outFlag = FALSE;
      OutputVertex(V+i);
    }
      OutputVertex(V+j);
}


void Init(name)
     char *name;
{
  srand48((long) 123);

  V = Alloc_Points(MAX_POINTS);
  R = (POINT **) calloc(MAX_POINTS, sizeof(POINT *));

#ifdef ANIMATE
  A_Init(name);
#endif /* ANIMATE */
}  



DP.h            759796676   3053  3053  100644  1660      `
/*  				7-6-91      Jack Snoeyink
Declarations for the Douglas Peucker line simplification algorithm.
*/
#pragma once

#include <stdio.h>
#include <math.h>

#define FALSE 0
#define TRUE 1

#define MAX_POINTS 10001
#define TWICE_MAX_POINTS 20002

typedef double POINT[2];	/* Most data is cartesian points */
typedef double HOMOG[3];	/* Some partial calculations are homogeneous */

#define XX 0
#define YY 1
#define WW 2

#define CROSSPROD_2CCH(p, q, r) /* 2-d cartesian to homog cross product */\
 (r)[WW] = (p)[XX] * (q)[YY] - (p)[YY] * (q)[XX];\
 (r)[XX] = - (q)[YY] + (p)[YY];\
 (r)[YY] =   (q)[XX] - (p)[XX];

#define DOTPROD_2CH(p, q)	/* 2-d cartesian to homog dot product */\
 (q)[WW] + (p)[XX]*(q)[XX] + (p)[YY]*(q)[YY]


#define DOTPROD_2C(p, q)	/* 2-d cartesian  dot product */\
 (p)[XX]*(q)[XX] + (p)[YY]*(q)[YY]

#define LINCOMB_2C(a, p, b, q, r) /* 2-d cartesian linear combination */\
 (r)[XX] = (a) * (p)[XX] + (b) * (q)[XX];\
 (r)[YY] = (a) * (p)[YY] + (b) * (q)[YY];


#define MIN(a,b) ( a < b ? a : b)
#define MAX(a,b) ( a > b ? a : b)

#define OutputVertex(v) R[num_result++] = v;

extern POINT *V,		/* V is the array of input points */
   **R;				/* R is the array of output pointers to V */

extern int n,			/* number of elements in V */
  num_result,			/* number of elements in R */
  outFlag, looping;

extern double EPSILON,		/* error tolerance */
  EPSILON_SQ;			/* error tolerance squared */


void Print_Points();
POINT *Alloc_Points();		/* alloc memory */

void Parse();			/* parse command line */
void Get_Points();		/* create test cases */
double Distance();
void Init(), Output(), Print_Result(), Start_Timing(), End_Timing();



DPhull.c        738433247   3053  3053  100644  2140      `
/*  				7-6-91      Jack Snoeyink
Recursive implementation of the Douglas Peucker line simplification
algorithm based on path hulls
*/
#include "DP.h"
#include "PH.h"

PATH_HULL *left, *right;	/* Path Hull: \va{left} and \va{right} portions and tag vertex \va{PHtag}. */
POINT *PHtag;


void Build(i, j)		/* Build Path Hull for the chain from vertex $i$ to vertex $j$.   */
     POINT *i, *j;
{
  register POINT *k;

  A_Mode(0);

  PHtag = i + (j - i) / 2;

  Hull_Init(left, PHtag, PHtag - 1);
  for (k = PHtag - 2; k >= i; k--)
    Hull_Add(left, k);
/*  printf("LEFT "); Hull_Print(left);/**/

  Hull_Init(right, PHtag, PHtag + 1);
  for (k = PHtag + 2; k <= j; k++)
    Hull_Add(right, k);
/*  printf("RIGHT "); Hull_Print(right);/**/
}
  
void DP(i, j)
     POINT *i, *j;
{
  static double ld, rd, len_sq;
  static HOMOG l;
  POINT *le, *re;

  if (j - i > 1)
    {
  CROSSPROD_2CCH(*i, *j, l);
#ifdef ANIMATE
  A_UpdateH();
  A_DrawLine(l);
#endif
  len_sq = DOTPROD_2C(l,l);

      Find_Extreme(left, l, &le, &ld);
      Find_Extreme(right, l, &re, &rd);
      
      if (ld <= rd)
	{
	  if (rd * rd > EPSILON_SQ * len_sq)
	    {
	      if (PHtag == re)
		Build(i, re);
	      else
		Split(right, re);
	      /*	    printf("RIGHT Backup "); Hull_Print(right);/**/
	      A_AddSplit(re);
	      DP(i, re);
	      Build(re, j);
	      DP(re, j);
	    }
	}
      else
	if (ld * ld > EPSILON_SQ * len_sq)
	  {
	    Split(left, le);
/*	    printf("LEFT Backup "); Hull_Print(left);/**/
	    A_AddSplit(le);
	    DP(le, j);
	    Build(i, le);
	    DP(i, le);
	  }
    }
}




main(argc,argv)
    int argc;
    char **argv;
{
  Parse(argc, argv);
  Init("DPhull");
  left = (PATH_HULL *) malloc(sizeof(PATH_HULL));
  right = (PATH_HULL *) malloc(sizeof(PATH_HULL));

  do
    {
      Get_Points();
#ifdef ANIMATE
      A_modes[0] = "Build";
      A_modes[1] = "FindExtr.";
      A_modes[2] = "Split";
      A_Setup(3);
#endif 
      Start_Timing();
      Build(V, V + n - 1);
      DP(V, V + n - 1);
      A_UpdateH();
      End_Timing(TRUE);
      Print_Result(FALSE); /**/
    }
  while (looping);
#ifdef ANIMATE
  A_Quit();
#endif 
}


DPhullfast.c    738522727   3053  3053  100644  7034      `
/*  				7-6-91      Jack Snoeyink
				Recursive implementation of the Douglas Peucker line simplification
				algorithm based on path hulls
				*/
#include "DP.h"
#include "PHfast.h"

PATH_HULL left, right;	/* Path Hull: \va{left} hull and \va{right} hull and tag vertex \va{PHtag}. */
POINT *PHtag;


void Build(i, j)		/* Build the Path Hull for the chain from vertex $i$ to vertex $j$.   */
     POINT *i, *j;
{
  register POINT *k;
  register int topflag, botflag;
  
  PHtag = i + (j - i) / 2;	/* Assign tag vertex */
  
  Hull_Init(left, PHtag, PHtag - 1); /* \va{left} hull */
  for (k = PHtag - 2; k >= i; k--)
    {
      topflag = LEFT_OF(left.elt[left.top], left.elt[left.top-1], k);
      botflag = LEFT_OF(left.elt[left.bot+1], left.elt[left.bot], k);
      if (topflag || botflag)
	{
	  while (topflag)
	    {
	      Hull_Pop_Top(left);
	      topflag = LEFT_OF(left.elt[left.top], left.elt[left.top-1], k);
	    }
	  while (botflag)
	    {
	      Hull_Pop_Bot(left);
	      botflag = LEFT_OF(left.elt[left.bot+1], left.elt[left.bot], k);
	    }
	  Hull_Push(left, k);
	}
    }
  Hull_Init(right, PHtag, PHtag + 1); /* \va{right} hull */
  for (k = PHtag + 2; k <= j; k++)
    {
      topflag = LEFT_OF(right.elt[right.top], right.elt[right.top-1], k);
      botflag = LEFT_OF(right.elt[right.bot+1], right.elt[right.bot], k);
      if (topflag || botflag)
	{
	  while (topflag)
	    {
	      Hull_Pop_Top(right);
	      topflag = LEFT_OF(right.elt[right.top], right.elt[right.top-1], k);
	    }
	  while (botflag)
	    {
	      Hull_Pop_Bot(right);
	      botflag = LEFT_OF(right.elt[right.bot+1], right.elt[right.bot], k);
	    }
	  Hull_Push(right, k);
	}
    }
}  

POINT *DP(i, j)
     POINT *i, *j;
{				/* DP */
  static double ld, rd, len_sq;
  static HOMOG l;
  register POINT *le, *re;
  POINT *tmp;
  
  CROSSPROD_2CCH(*i, *j, l);
  len_sq = l[XX] * l[XX] + l[YY] * l[YY];
  
  if (j - i < 8)
    {		/* chain small */
      rd  = 0.0;
      for (le = i + 1; le < j; le++)
	{
	  ld = DOTPROD_2CH(*le, l);
	  if (ld < 0) ld = - ld;
	  if (ld > rd) 
	    {
	      rd = ld;
	      re = le;
	    }
	}
      if (rd * rd > EPSILON_SQ * len_sq)
	{
	  OutputVertex(DP(i, re)); 
	  return(DP(re, j));
	}
      else
	return(j);
    }
  else
    {				/* chain large */
      register int 
	sbase, sbrk, mid,
	lo, m1, brk, m2, hi;
      double d1, d2;
      if ((left.top - left.bot) > 8) 
	{			/* left hull large */
	  lo = left.bot; hi = left.top - 1;
	  sbase = SLOPE_SIGN(left, hi, lo, l);
	  do
	    {
	      brk = (lo + hi) / 2;
	      if (sbase == (sbrk = SLOPE_SIGN(left, brk, brk+1, l)))
		if (sbase == (SLOPE_SIGN(left, lo, brk+1, l)))
		  lo = brk + 1;
		else
		  hi = brk;
	    }
	  while (sbase == sbrk);
	  
	  m1 = brk;
	  while (lo < m1)
	    {
	      mid = (lo + m1) / 2;
	      if (sbase == (SLOPE_SIGN(left, mid, mid+1, l)))
		lo = mid + 1;
	      else
		m1 = mid;
	    }
	  
	  m2 = brk;
	  while (m2 < hi) 
	    {
	      mid = (m2 + hi) / 2;
	      if (sbase == (SLOPE_SIGN(left, mid, mid+1, l)))
		hi = mid;
	      else
		m2 = mid + 1;
	    };
	  
	  /*      printf("Extremes: <%3lf %3lf>  <%3lf %3lf>\n", 
		  (*left.elt[lo])[XX],  (*left.elt[lo])[YY],
		  (*left.elt[m2])[XX],  (*left.elt[m2])[YY]); /**/
	  
	  if ((d1 = DOTPROD_2CH(*left.elt[lo], l)) < 0) d1 = - d1;
	  if ((d2 = DOTPROD_2CH(*left.elt[m2], l)) < 0) d2 = - d2;
	  ld = (d1 > d2 ? (le = left.elt[lo], d1) : (le = left.elt[m2], d2));
	}
      else
	{			/* Few points in left hull */
	  ld = 0.0;
	  for (mid = left.bot; mid < left.top; mid++)
	    {
	      if ((d1 = DOTPROD_2CH(*left.elt[mid], l)) < 0) d1 = - d1;
	      if (d1 > ld)
		{
		  ld = d1;
		  le = left.elt[mid];
		}
	    }
	}
      
      if ((right.top - right.bot) > 8)
	{			/* right hull large */
	  lo = right.bot; hi = right.top - 1;
	  sbase = SLOPE_SIGN(right, hi, lo, l);
	  do
	    {
	      brk = (lo + hi) / 2;
	      if (sbase == (sbrk = SLOPE_SIGN(right, brk, brk+1, l)))
		if (sbase == (SLOPE_SIGN(right, lo, brk+1, l)))
		  lo = brk + 1;
		else
		  hi = brk;
	    }
	  while (sbase == sbrk);
	  
	  m1 = brk;
	  while (lo < m1)
	    {
	      mid = (lo + m1) / 2;
	      if (sbase == (SLOPE_SIGN(right, mid, mid+1, l)))
		lo = mid + 1;
	      else
		m1 = mid;
	    }
	  
	  m2 = brk;
	  while (m2 < hi) 
	    {
	      mid = (m2 + hi) / 2;
	      if (sbase == (SLOPE_SIGN(right, mid, mid+1, l)))
		hi = mid;
	      else
		m2 = mid + 1;
	    };
	  
	  /*      printf("Extremes: <%3lf %3lf>  <%3lf %3lf>\n", 
		  (*right.elt[lo])[XX],  (*right.elt[lo])[YY],
		  (*right.elt[m2])[XX],  (*right.elt[m2])[YY]); /**/
	  
	  if ((d1 = DOTPROD_2CH(*right.elt[lo], l)) < 0) d1 = - d1;
	  if ((d2 = DOTPROD_2CH(*right.elt[m2], l)) < 0) d2 = - d2;
	  rd = (d1 > d2 ? (re = right.elt[lo], d1) : (re = right.elt[m2], d2));
	}
      else
	{			/* Few points in righthull */
	  rd = 0.0;
	  for (mid = right.bot; mid < right.top; mid++)
	    {
	      if ((d1 = DOTPROD_2CH(*right.elt[mid], l)) < 0) d1 = - d1;
	      if (d1 > rd)
		{
		  rd = d1;
		  re = right.elt[mid];
		}
	    }
	}
    }

  
  if (ld > rd)
    if (ld * ld > EPSILON_SQ * len_sq)
      {				/* split left */
	register int tmpo; 
	
	while ((left.hp >= 0) 
	       && ((tmpo = left.op[left.hp]), 
		   ((re = left.helt[left.hp]) != le) || (tmpo != PUSH_OP)))
	  {
	    left.hp--;
	    switch (tmpo)
	      {
	      case PUSH_OP:
		left.top--;
		left.bot++;
		break;
	      case TOP_OP:
		left.elt[++left.top] = re;
		break;
	      case BOT_OP:
		left.elt[--left.bot] = re;
		break;
	      }
	  }
	
	
	/*	    printf("LEFT Backup "); Hull_Print(&left);/**/
	tmp = DP(le, j);
	Build(i, le);
	OutputVertex(DP(i, le));
	return(tmp);
      }
    else
      return(j);
  else				/* extreme on right */
    if (rd * rd > EPSILON_SQ * len_sq)
      {				/* split right or both */
	if (PHtag == re)
	  Build(i, re);
	else
	  {			/* split right */
	    register int tmpo;
	    
	    while ((right.hp >= 0) 
		   && ((tmpo = right.op[right.hp]), 
		       ((le = right.helt[right.hp]) != re) || (tmpo != PUSH_OP)))
	      {
		right.hp--;
		switch (tmpo)
		  {
		  case PUSH_OP:
		    right.top--;
		    right.bot++;
		    break;
		  case TOP_OP:
		    right.elt[++right.top] = le;
		    break;
		  case BOT_OP:
		    right.elt[--right.bot] = le;
		    break;
		  }
	      }
	  }
	/*	    printf("RIGHT Backup "); Hull_Print(&right);/**/
	OutputVertex(DP(i, re));
	Build(re, j);
	return(DP(re, j));
      }
    else
      return(j);
}



void main(argc,argv)
     int argc;
     char **argv;
{
  register int i;
  
  Parse(argc, argv);
  Init("DPhull");
  
  /*  left = (PATH_HULL *) malloc(sizeof(PATH_HULL));
      right = (PATH_HULL *) malloc(sizeof(PATH_HULL));/**/
  
  do
    {
      Get_Points();
      Start_Timing();
      
      for (i=0; i < 100; i++) {
	outFlag = TRUE;
	num_result = 0;
	Build(V, V + n - 1);	/* Build the initial path hull */
	OutputVertex(V);
	OutputVertex(DP(V, V + n - 1)); /* Simplify */
      }
      
      End_Timing(2);
      Print_Result(FALSE); /**/
    }
  while (looping);
}



PH.h            738431742   3053  3053  100644  1590      `
/*  				7-6-91      Jack Snoeyink
Declarations for path hulls
*/

#pragma once
#include "animate.h"

#define HULL_MAX 10002
#define TWICE_HULL_MAX 20002
#define THRICE_HULL_MAX 30002

#define PUSH_OP 0		/* Operation names saved in history stack */
#define TOP_OP 1
#define BOT_OP 2

typedef struct {		/* Half of a Path Hull: \va{elt} is a double ended queue storing a convex hull, \va{top} and \va{bot} are the two ends.  The history stack is \va{helt} for points and \va{op} for operations, \va{hp} is the stack pointer. */
  int top, bot, 
  hp, op[THRICE_HULL_MAX];
  POINT *elt[TWICE_HULL_MAX], *helt[THRICE_HULL_MAX];
} PATH_HULL;


extern PATH_HULL *left, *right;	


#define Hull_Push(h, e)		/* Push element $e$ onto path hull $h$ */\
  (h)->elt[++(h)->top] = (h)->elt[--(h)->bot] = (h)->helt[++(h)->hp] = e;\
  (h)->op[(h)->hp] = PUSH_OP
#define Hull_Pop_Top(h)		/* Pop from top */\
  (h)->helt[++(h)->hp] = (h)->elt[(h)->top--];\
  (h)->op[(h)->hp] = TOP_OP
#define Hull_Pop_Bot(h)		/* Pop from bottom */\
  (h)->helt[++(h)->hp] = (h)->elt[(h)->bot++];\
  (h)->op[(h)->hp] = BOT_OP
#define Hull_Init(h, e1, e2)	/* Initialize path hull and history  */\
  (h)->elt[HULL_MAX] = e1;\
  (h)->elt[(h)->top = HULL_MAX + 1] = \
  (h)->elt[(h)->bot = HULL_MAX - 1] = \
  (h)->helt[(h)->hp = 0] = e2;\
  (h)->op[0] = PUSH_OP;

#define LEFT_OF(a, b, c)	/* Determine if point c is left of line a to b */\
     (((*a)[XX] - (*c)[XX])*((*b)[YY] - (*c)[YY]) \
      >= ((*b)[XX] - (*c)[XX])*((*a)[YY] - (*c)[YY]))

#define SGN(a) (a >= 0)

void Hull_Add(), Split(), Hull_Print(), Find_Extreme();

PH.c            738376075   3053  3053  100644  4107      `
/*  				7-6-91      Jack Snoeyink
Path hulls for the Douglas Peucker line simplification algorithm.
*/
#include "DP.h"
#include "PH.h"
#include "animate.h"

#ifdef ANIMATE
void A_UpdateH()
{
  A_ClearBack();
  mycolor(myTRANSP1);
  A_DrawHull(left);
  mycolor(myTRANSP2);
  A_DrawHull(right);
  A_DrawChains();
  A_SwapBuffers();
}
#endif

void Hull_Print(h)
     PATH_HULL *h;
{
  register int i;

  printf(" hull has %d points: ", h->top - h->bot);
  for (i = h->bot; i <= h->top; i++)
    printf(" <%.3lf %.3lf> ", (*h->elt[i])[XX], (*h->elt[i])[YY]);/**/
  printf("\n");
}


void Hull_Add(h, p)		/* Add $p$ to the path hull $h$. Implements Melkman's convex hull algorithm. */
     register PATH_HULL *h;
     POINT *p;
{
  register int topflag, botflag;
  
#ifdef ANIMATE
  mycolor(myMAGENTA);
#endif
  topflag = LEFT_OF(h->elt[h->top], h->elt[h->top-1], p);
  botflag = LEFT_OF(h->elt[h->bot+1], h->elt[h->bot], p);

  if (topflag || botflag)
    {
      while (topflag)
	{
#ifdef ANIMATE
      if (A_delay > 4)
	gsync();
  A_DrawSeg(*h->elt[h->top], *p);
#endif
	  Hull_Pop_Top(h);
	  topflag = LEFT_OF(h->elt[h->top], h->elt[h->top-1], p);
	}
      while (botflag)
	{
#ifdef ANIMATE
      if (A_delay > 4)
	gsync();
  A_DrawSeg(*h->elt[h->bot], *p);
#endif
	  Hull_Pop_Bot(h);
	  botflag = LEFT_OF(h->elt[h->bot+1], h->elt[h->bot], p);
	}
#ifdef ANIMATE
      if (A_delay > 0)
	gsync();
  A_DrawSeg(*h->elt[h->top], *p);
  A_DrawSeg(*h->elt[h->bot], *p);
#endif
      Hull_Push(h, p);
    }
}


void Split(h, e)
     register PATH_HULL *h;
     POINT *e;
{
  register POINT *tmpe;
  register int tmpo;
  
  A_Mode(2);
  while ((h->hp >= 0) 
	 && ((tmpo = h->op[h->hp]), 
	     ((tmpe = h->helt[h->hp]) != e) || (tmpo != PUSH_OP)))
    {
      h->hp--;
      switch (tmpo)
	{
	case PUSH_OP:
	  h->top--;
	  h->bot++;
	  break;
	case TOP_OP:
	  h->elt[++h->top] = tmpe;
	  break;
	case BOT_OP:
	  h->elt[--h->bot] = tmpe;
	  break;
	}
    }
}


#define SLOPE_SIGN(h, p, q, l)	/* Return the sign of the projection 
				   of $h[q] - h[p]$ onto the normal 
				   to line $l$ */ \
  SGN((l[XX])*((*h->elt[q])[XX] - (*h->elt[p])[XX]) \
      + (l[YY])*((*h->elt[q])[YY] - (*h->elt[p])[YY])) 



void Find_Extreme(h, line, e, dist)
     register PATH_HULL *h;
     HOMOG line;
     POINT **e;
     register double *dist;
{
  register int 
    sbase, sbrk, mid,
    lo, m1, brk, m2, hi;
  double d1, d2;

  A_Mode(1);
  if ((h->top - h->bot) > 8) 
    {
      lo = h->bot; hi = h->top - 1;
      sbase = SLOPE_SIGN(h, hi, lo, line);
      do
	{
	  brk = (lo + hi) / 2;
#ifdef ANIMATE
  mycolor(myYELLOW);
  A_DrawSeg(*h->elt[brk], *h->elt[brk+1]);
#endif
	  if (sbase == (sbrk = SLOPE_SIGN(h, brk, brk+1, line)))
	    if (sbase == (SLOPE_SIGN(h, lo, brk+1, line)))
	      lo = brk + 1;
	    else
	      hi = brk;
	}
      while (sbase == sbrk);
      
      m1 = brk;
      while (lo < m1)
	{
	  mid = (lo + m1) / 2;
#ifdef ANIMATE
  A_DrawSeg(*h->elt[mid], *h->elt[mid+1]);
#endif
	  if (sbase == (SLOPE_SIGN(h, mid, mid+1, line)))
	    lo = mid + 1;
	  else
	    m1 = mid;
	}
      
      m2 = brk;
      while (m2 < hi) 
	{
	  mid = (m2 + hi) / 2;
#ifdef ANIMATE
  A_DrawSeg(*h->elt[mid], *h->elt[mid+1]);
#endif
	  if (sbase == (SLOPE_SIGN(h, mid, mid+1, line)))
	    hi = mid;
	  else
	    m2 = mid + 1;
	}
      
/*      printf("Extremes: <%3lf %3lf>  <%3lf %3lf>\n", 
	     (*h->elt[lo])[XX],  (*h->elt[lo])[YY],
	     (*h->elt[m2])[XX],  (*h->elt[m2])[YY]); /**/
            
#ifdef ANIMATE
  A_DrawPLdist(*h->elt[lo], line);
  A_DrawPLdist(*h->elt[m2], line);
#endif
      if ((d1 = DOTPROD_2CH(*h->elt[lo], line)) < 0) d1 = - d1;
      if ((d2 = DOTPROD_2CH(*h->elt[m2], line)) < 0) d2 = - d2;
      *dist = (d1 > d2 ? (*e = h->elt[lo], d1) : (*e = h->elt[m2], d2));
    }
  else				/* Few points in hull */
    {
      *dist = 0.0;
      for (mid = h->bot; mid < h->top; mid++)
	{
#ifdef ANIMATE
	  A_DrawPLdist(*h->elt[mid], line);
#endif
	  if ((d1 = DOTPROD_2CH(*h->elt[mid], line)) < 0) d1 = - d1;
	  if (d1 > *dist)
	    {
	      *dist = d1;
	      *e = h->elt[mid];
	    }
	}
    }
}	
  



animate.c       758681852   3053  3053  100644  5278      `
 /* 28 Jan 92 				Jack Snoeyink
 * Animation routines for Douglas Peucker line simplification
 */

#include "DP.h"
#include "PH.h"
#include <gl/gl.h>
#include <gl/device.h>
#include <fmclient.h>

#define LINEWIDTH 5
#define POINTSIZE .2

double top, bot;
int A_delay = 0;
int A_swapinterval = 2;
int A_modeq = 0;
int A_ack = 0;
int A_nmodes = 0;

char *A_modes[5];

fmfonthandle font1;

int n_split;
POINT *splits[MAXPTS];
double aspect;			/* aspect ration x/y */

void A_Clear()
{
  mycolor(myBLACK);
  clear();    
  gflush();
}


void A_ClearBack()
{
  frontbuffer(FALSE);
  A_Clear();
}

void A_Init(name)
     char *name;
{
  
  foreground();
  winopen(name);
  RGBmode();
  A_Clear();
  doublebuffer(); 
  mmode(MVIEWING);

  subpixel(TRUE);
  swapinterval(A_swapinterval);
  shademodel(FLAT);
  gconfig();

  A_ClearBack();

  qdevice(REDRAW);
  qdevice(WINQUIT);

  qdevice(ESCKEY);
  qdevice(AKEY);

  qdevice(UPARROWKEY);
  qdevice(DOWNARROWKEY);

  fminit();
  font1 = fmfindfont("Helvetica");
  font1 = fmscalefont(font1, 32.0);
  fmsetfont(font1);
}

void circle(p, r)
     POINT p;
     double r;
{
  int i;
  POINT tmp;
  static POINT off[8] = {1,0, SQRhf,SQRhf, 0,1, -SQRhf,SQRhf, 
				-1,0, -SQRhf,-SQRhf, 0,-1, SQRhf,-SQRhf};
  bgnclosedline();
  for (i = 0; i < 8; i++)
    {
      LINCOMB_2C(1.0, p, r, off[i], tmp);
      v2d(tmp);
    }
  endclosedline();
}

	
void A_DrawChains()
{
  int i;

  linewidth(LINEWIDTH);
  mycolor(myGREEN);
  bgnline();
  for (i = 0; i < n; i++)
    v2d(V[i]);
  endline();
  for (i = 0; i < n; i++)
    circle(V[i], POINTSIZE);

  mycolor(myRED);
  bgnline();
  for (i = 0; i < n_split; i++)
    v2d(*splits[i]);
  endline();
  for (i = 0; i < n_split; i++)
    circle((*splits[i]), POINTSIZE);
  linewidth(4);
}

void A_DrawHull(h)
     PATH_HULL *h;
{
  int i,j;

  frontbuffer(FALSE);
  blendfunction(BF_SA, BF_MSA);

  if (h->bot < h->top)
    {
      bgnqstrip();
      for (i = h->bot + (h->top - h->bot)/2, j = i+1; j <= h->top; i--, j++)
	{
	  v2d(*h->elt[i]);
	  v2d(*h->elt[j]);
	}
      endqstrip();
    }
  blendfunction(BF_ONE, BF_ZERO);
}

void DoMode(num)
     int num;
{
  cmov2(aspect*top-12, bot +9 + (top - bot)*(.1 + .05*num));
  fmprstr(A_modes[num]);
}

void A_AllModes()
{
  int i;
  
  mycolor(myGREY);
  for (i = 0; i < A_nmodes; i++) DoMode(i);
}

void A_SwapBuffers()
{
  short dev, val;

  if (A_modeq) A_AllModes();
  if (A_ack)
    {
    do {
      sginap(5);
    } while (!getbutton(SPACEKEY));
    }

  swapbuffers(); /**/
  frontbuffer(TRUE);
  while (qtest())
    {
    switch (dev = qread(&val)) 
      {
      case REDRAW:
	reshapeviewport();
	break;

      case ESCKEY:
      case WINQUIT:
	A_Quit();
	exit(0);
      }

    if (val != 0)
      switch (dev)
	{
	
	case UPARROWKEY:
	  A_delay += 1 + A_delay / 6;
	  break;

	case DOWNARROWKEY:
	  A_delay -= 1 + A_delay / 6;
	  if (A_delay < 0) A_delay = 0;
	  break;

	case AKEY:
	  A_ack = !A_ack;
	  break;
	}
  }
}


void A_Update()
{
  A_ClearBack();
  A_DrawChains();
  A_SwapBuffers();
}
     
void A_Setup(nmodes)
     int nmodes;
{				/*  tl-t-tr  */
  double b, t;			/*  l     r  */
  int i;			/*  bl-b-br  */
  
  A_nmodes = nmodes;
  b = t = 0.0;
  for (i = 0; i < n; i++)
    {
      if (t < V[i][YY]) t = V[i][YY];
      if (t < V[i][XX]) t = V[i][XX];
      if (b > V[i][YY]) b = V[i][YY];
      if (b > V[i][XX]) b = V[i][XX];
    }
  top = t + 3.5 + t*0.05; bot = b - 10.5 - b*0.05;
  ortho2(aspect * bot, aspect*top, top, bot);
  n_split = 2;
  splits[0] = V;
  splits[1] = V+n - 1;
  if (A_ack)
    {
      A_ack = 0;
      A_Update();
      A_ack = 1;
    };
  A_Update();
}


void A_AddSplit(split)
     POINT *split;
{
  int i;

  linewidth(6);
  mycolor(myMAGENTA);
  circle(*split, 3 * POINTSIZE);
  linewidth(4);
  for (i = n_split; splits[i-1] > split; i--)
    splits[i] = splits[i-1];
  splits[i] = split;
  n_split++;
}


void A_DrawSeg(p, q)
     POINT p, q;
{
  bgnline();
  v2d(p);
  v2d(q);
  endline();
  gflush();
}


void A_DrawLine(l)
     HOMOG l;
{
  POINT p, q;
  
  if (fabs(l[XX]) > fabs(l[YY]))
    {
      p[XX] = (-l[WW]+2*n*l[YY]) / l[XX];
      p[YY] = -2*n;
      q[XX] = (-l[WW]-2*n*l[YY]) / l[XX];
      q[YY] = 2*n;
    }
  else
    {
      p[XX] = -2*n;
      p[YY] = (-l[WW]+2*n*l[XX]) / l[YY];
      q[XX] = 2*n;
      q[YY] = (-l[WW]-2*n*l[XX]) / l[YY];
    }
  mycolor(myYELLOW);
  A_DrawSeg(p, q);
}


void A_DrawPLdist(p, l)
     POINT p;
     HOMOG l;
{
  int i;
  double dsq, dot;
  POINT q, tmp;

  dsq = DOTPROD_2C(l,l);
  dot = p[XX] * l[YY] - p[YY] * l[XX];
  q[XX] = (-l[WW] * l[XX] + l[YY] * dot) / dsq;
  q[YY] = (-l[WW] * l[YY] - l[XX] * dot) / dsq;
  
  mycolor(myBLUE);
  for (i = 0; i < A_delay; i++)
    {
      dot = (i+1.0) / (A_delay+2.0);
      LINCOMB_2C(dot, p, (1.0 - dot), q, tmp);
      A_DrawSeg(q, tmp);
      gsync();
    }
  A_DrawSeg(q, p);
  mycolor(myGREEN);
  bgnpoint();
  v2d(p);
  endpoint();
}


void A_Mode(num)
     int num;
{
  static int lastnum = -1;

  if (A_modeq)
    {
      if (lastnum >= 0)
	{
	  mycolor(myGREY);
	  DoMode(lastnum);
	}
      mycolor(myWHITE);
      DoMode(num);
      lastnum = num;      
      if (A_delay > 10)
	{
	  gflush();
	  sginap((long) A_delay );
	}
    }
}
    
void A_Quit()
{
  sginap(100L);
  gexit();
}
animate.h       758682276   3053  3053  100644  872       `
#pragma once

#ifdef ANIMATE
#include <gl/gl.h>

#define NAPTIME 15L		/* 100ths of a second */
#define MAXPTS 10002

#define SQRhf 0.70710678


#define myBLACK   0x00000000L
#define myRED     0x9f00009fL
#define myGREEN   0x9f009f00L
#define myYELLOW  0x9f009f9fL
#define myBLUE    0x9f9f0000L
#define myMAGENTA 0x9f9f009fL
#define myCYAN    0x9f9f9f00L
#define myWHITE   0x9f9f9f9fL
#define myGREY    0x9f4f4f4fL
#define myTRANSP1 0x80dfdfdf & myCYAN 
#define myTRANSP2 0x80dfdfdf & myGREEN
#define mycolor(c) cpack(c)

extern int A_delay, A_swapinterval, A_modeq, A_ack;
extern char *A_modes[5];

extern double aspect;			/* aspect ration x/y */

void A_Init(), A_Quit(), A_Setup(), 
  A_Clear(), A_ClearBack(), A_SwapBuffers(), 
  A_DrawLine(), A_DrawSeg(), A_DrawPLdist(),
  A_DrawChains(), A_DrawHull(), A_Update(), A_AddSplit(),
  A_UpdateH();

#endif /* ANIMATE */

nonrec.c        759799552   3053  3053  100644  2740      `
/*  				1-26-94      Jack Snoeyink
Non-recursive implementation of the Douglas Peucker line simplification
algorithm.
*/
#include "DP.h"
#include "animate.h"

/* Assumes that the polygonal line is in a global array V. 
 * main() assumes also that a global variable n contains the number of
 * points in V.
 */

int stack[MAX_POINTS];		/* recursion stack */
int sp;				/* recursion stack pointer */

#define Stack_Push(e)		/* push element onto stack */\
  stack[++sp] = e
#define Stack_Pop()		/* pop element from stack (zero if none) */\
  stack[sp--]
#define Stack_Top()		/* top element on stack  */\
  stack[sp]
#define Stack_EmptyQ()		/* Is stack empty? */\
  (sp < 0)
#define Stack_Init()		/* initialize stack */\
  sp = -1


void Find_Split(i, j, split, dist) /* linear search for farthest point */
     int i, j, *split;		   /* from the segment Vi to Vj. returns */
     double *dist;	 	   /* squared distance and a pointer */
{
  int k;
  HOMOG q;
  double tmp;

#ifdef ANIMATE
  HOMOG l;

  CROSSPROD_2CCH(V[i], V[j], l);
  A_DrawLine(l);
#endif
  *dist = -1;
  if (i + 1 < j)
    {
      CROSSPROD_2CCH(V[i], V[j], q); /* out of loop portion */ 
				     /* of distance computation */
      for (k = i + 1; k < j; k++)
	{
	  tmp = DOTPROD_2CH(V[k], q); /* distance computation */
	  if (tmp < 0) tmp = - tmp; /* calling fabs() slows us down */
#ifdef ANIMATE
	  A_DrawPLdist(V[k], l);
#endif
	  if (tmp > *dist) 
	    {
	      *dist = tmp;	/* record the maximum */
	      *split = k;
	    }
	}
      *dist *= *dist/(q[XX]*q[XX] + q[YY]*q[YY]); /* correction for segment */
    }				   /* length---should be redone if can == 0 */
}



void DPbasic(i,j)		/* Basic DP line simplification */
     int i, j;
{
  int split; 
  double dist_sq;
  
#ifdef ANIMATE
  A_Mode(0);
#endif
  Stack_Init();
  Stack_Push(j);
  do
    {
      Find_Split(i, Stack_Top(), &split, &dist_sq);
      if (dist_sq > EPSILON_SQ)
	{
#ifdef ANIMATE
	  A_AddSplit(V+split);
#endif
	  Stack_Push(split);
	}
      else
	{
	  Output(i, Stack_Top()); /* output segment Vi to Vtop */
	  i = Stack_Pop();
	}
#ifdef ANIMATE
      A_Update();
#endif
    }
  while (!Stack_EmptyQ());
}




main(argc,argv)
    int argc;
    char **argv;
{
#ifndef ANIMATE
  register int i;
#endif /* not ANIMATE */

  Parse(argc, argv);
  Init("DPfast");

  do
    {
      Get_Points();
#ifdef ANIMATE
      A_modes[0] = "FindExtr.";
      A_modes[1] = "Split";
      A_Setup(2);
#endif 
      Start_Timing();

#ifndef ANIMATE
      for (i=0; i < 100; i++)	/* For timing purposes */
#endif /* not ANIMATE */
	{
	  outFlag = TRUE;
	  num_result = 0;
	  DPbasic(0, n - 1);
	}

      End_Timing(1);
      Print_Result(FALSE);
    }
  while (looping);
#ifdef ANIMATE
  A_Quit();
#endif 

}

Makefile        759799774   3053  3053  100600  1003      `
# File Names
#CFLAGS = -O  -s 
CFLAGS = -g  -DANIMATE 
LDFLAGS = -lm -lfm_s -lX11 -lc_s -lgl_s 
LINTFLAGS = -c 
LINTALLFLAGS = -lm -lgl 
HDRS = DP.h animate.h PH.h
SRCS = DP.c DPhullfast.c PH.c DPhull.c animate.c nonrec.c
H_OBJS = DP.o PH.o DPhull.o animate.o
N_OBJS = DP.o nonrec.o animate.o
OBJS = $(H_OBJS) $(N_OBJS)
UBJS = DP.u  DPhullfast.u nonrec.u
LINTS = DP.ln animate.ln PH.ln DPhull.ln nonrec.ln
EXECS = hull nonrec

all: 	hull nonrec

opt:	$(SRCS) $(HDRS) 
	cc -O4 -s DP.c DPhullfast.c -lm -o hull
	cc -O4 -s DP.c nonrec.c -lm -o nonrec

hull:	$(H_OBJS)
		cc $(CFLAGS) $(H_OBJS) $(LDFLAGS) -o hull

nonrec:	$(N_OBJS)
		cc $(CFLAGS) $(N_OBJS) $(LDFLAGS) -o nonrec

$(OBJS): $(HDRS)

lint:	$(LINTS)

lintall: $(LINTS)
		lint $(LINTALLFLAGS) $(LINTS)

clean:	
		rm $(OBJS) $(UBJS)
		
nuke:	
		rm $(LINTS) $(EXECS) $(OBJS)

print: 	$(HDRS) $(SRCS) 
		lwf -s7 -t4 -l -p-2 $? | lpr
		touch print

.SUFFIXES:	.c .o .ln .h .out .u

.c.o:
		cc $(CFLAGS) -c $<

.c.ln:
		lint $(LINTFLAGS) $(CFLAGS) $<

README          773946808   3053  3053  100644  1834      `
Thanks for you interest in our paper.  I am now a bit embarassed at
the title that I gave it---to a theoretical computer scientist,
"speeding up" means "speeding up the worst-case performance."  My
further tests have indicated that the straightforward implementation
of the Douglas-Peucker algorithm runs a little bit faster on
cartographic data (although it has a far slower worst case running
time).  The fact that it uses trivial data structures probably make it
the implementation of choice.

I am including an ar archive with C code for our implementation and
for the straightforward implementation using a stack instead of
recursion.  The latter is easy enough to implement that you might want
to take my code (nonrec.c) as a guide and do your own.  This is
especially true because I have added timing and animation routines to
mine to create a video for the Video Review of the ACM Computational
Geometry conference.  If you have a silicon graphics, you can see the
animation by running  make  and then running  nonrec or hull.  If you
don't have an SGI, then  make opt  and  nonrec or hull  will be optimized
versions of the nonrecursive and path hull implementations.

To extract, save after the line as foo and type   ar x foo
The following files will be created:
nonrec.c	non-recursive implementation (the most interesting file)
DP.c		General routines for parsing arguments, random points, etc
DP.h
DPhull.c	Path hull implementation
PH.h
PH.c
DPhullfast.c	(somewhat optimized version)
animate.c	Display routines for SGI animation
animate.h
Makefile	compiles hull and nonrec, with or w/o animation

    o                                    Jack
  _/\_.
(')>-(`)                          snoeyink@cs.ubc.ca

	Department of Computer Science, University of British Columbia
	201 - 2366 Main Mall, Vancouver, BC V6T 1Z4  Canada
