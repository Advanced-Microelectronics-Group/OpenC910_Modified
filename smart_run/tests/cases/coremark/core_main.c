/*
Author : Shay Gal-On, EEMBC

This file is part of  EEMBC(R) and CoreMark(TM), which are Copyright (C) 2009 
All rights reserved.                            

EEMBC CoreMark Software is a product of EEMBC and is provided under the terms of the
CoreMark License that is distributed with the official EEMBC COREMARK Software release. 
If you received this EEMBC CoreMark Software without the accompanying CoreMark License, 
you must discontinue use and download the official release from www.coremark.org.  

Also, if you are publicly displaying scores generated from the EEMBC CoreMark software, 
make sure that you are in compliance with Run and Reporting rules specified in the accompanying readme.txt file.

EEMBC 
4354 Town Center Blvd. Suite 114-200
El Dorado Hills, CA, 95762 
*/ 
/* File: core_main.c
	This file contains the framework to acquire a block of memory, seed initial parameters, tun t he benchmark and report the results.
*/
#define VCUNT_SIM

#include "coremark.h"
#include "timer.h"

#ifdef VCUNT_SIM
  //#include "vtimer.h"
  extern unsigned int get_vtimer();
  int vtimer_start;
  int vtimer_end;
  int vcycles;
#endif 

int Loop_Num = 0;

/* Function: iterate
	Run the benchmark for a specified number of iterations.

	Operation:
	For each type of benchmarked algorithm:
		a - Initialize the data block for the algorithm.
		b - Execute the algorithm N times.

	Returns:
	NULL.
*/
static ee_u16 list_known_crc[]   =      {(ee_u16)0xd4b0,(ee_u16)0x3340,(ee_u16)0x6a79,(ee_u16)0xe714,(ee_u16)0xe3c1};
static ee_u16 matrix_known_crc[] =      {(ee_u16)0xbe52,(ee_u16)0x1199,(ee_u16)0x5608,(ee_u16)0x1fd7,(ee_u16)0x0747};
static ee_u16 state_known_crc[]  =      {(ee_u16)0x5e47,(ee_u16)0x39bf,(ee_u16)0xe5a4,(ee_u16)0x8e3a,(ee_u16)0x8d84};
void *iterate(void *pres) {
	ee_u32 i;
	ee_u16 crc;
	core_results *res=(core_results *)pres;
	ee_u32 iterations=res->iterations;
	res->crc=0;
	res->crclist=0;
	res->crcmatrix=0;
	res->crcstate=0;

#ifdef VCUNT_SIM
  vtimer_start= get_vtimer();
#endif
	for (i=0; i<iterations; i++) {
		crc=core_bench_list(res,1);
		res->crc=crcu16(crc,res->crc);
		crc=core_bench_list(res,-1);
		res->crc=crcu16(crc,res->crc);
		if (i==0) res->crclist=res->crc;
	}

#ifdef VCUNT_SIM

  #define FREQ 100000000 
  
  vtimer_end= get_vtimer(); 
  vcycles = vtimer_end - vtimer_start;
  vcycles = vcycles/iterations;
  printf ("\nVCUNT_SIM: CoreMark has been run %d times, one times cost %d cycles !\n",iterations,vcycles);
  float score;
//  score = FREQ/(float)vcycles;
//  printf ("\nVCUNT_SIM: CoreMark 1.0 : %f iterations/sec\n",score); //CoreMark = iterations of a sec
  score = 1000000/(float)vcycles; //to relieve relations with FREQ
  printf ("\nVCUNT_SIM: CoreMark 1.0 : %f (iterations/sec)/MHz\n",score); //CoreMark = iterations of a sec
  sim_end();
#endif 

	return NULL;
}

#if (SEED_METHOD==SEED_ARG)
ee_s32 get_seed_args(int i, int argc, char *argv[]);
#define get_seed(x) (ee_s16)get_seed_args(x,argc,argv)
#define get_seed_32(x) get_seed_args(x,argc,argv)
#else /* via function or volatile */
ee_s32 get_seed_32(int i);
#define get_seed(x) (ee_s16)get_seed_32(x)
#endif

#if (MEM_METHOD==MEM_STATIC)
ee_u8 static_memblk[TOTAL_DATA_SIZE];
#endif
char *mem_name[3] = {"Static","Heap","Stack"};
/* Function: main
	Main entry routine for the benchmark.
	This function is responsible for the following steps:

	1 - Initialize input seeds from a source that cannot be determined at compile time.
	2 - Initialize memory block for use.
	3 - Run and time the benchmark.
	4 - Report results, testing the validity of the output if the seeds are known.

	Arguments:
	1 - first seed  : Any value
	2 - second seed : Must be identical to first for iterations to be identical
	3 - third seed  : Any value, should be at least an order of magnitude less then the input size, but bigger then 32.
	4 - Iterations  : Special, if set to 0, iterations will be automatically determined such that the benchmark will run between 10 to 100 secs

*/

//------------------------------------------------
// setup uart
//------------------------------------------------
#include "datatype.h"
#include "uart.h"
#include "stdio.h"

// t_ck_uart_device uart0 = {0xFFFF};
//------------------------------------------------

#if MAIN_HAS_NOARGC
MAIN_RETURN_TYPE main(void) {
	int argc=0;
	char *argv[1];
#else
MAIN_RETURN_TYPE main(int argc, char *argv[]) {
#endif

	int current_time;
	// ck_intc_init();
	// Timer_Interrupt_Init();
  //--------------------------------------------------------
  // setup uart
  //--------------------------------------------------------
  // t_ck_uart_cfig   uart_cfig;

  // uart_cfig.baudrate = BAUD;       // any integer value is allowed
  // uart_cfig.parity = PARITY_NONE;     // PARITY_NONE / PARITY_ODD / PARITY_EVEN
  // uart_cfig.stopbit = STOPBIT_1;      // STOPBIT_1 / STOPBIT_2
  // uart_cfig.wordsize = WORDSIZE_8;    // from WORDSIZE_5 to WORDSIZE_8
  // uart_cfig.txmode = ENABLE;          // ENABLE or DISABLE

  // // open UART device with id = 0 (UART0)
  // ck_uart_open(&uart0, 0);

  // // initialize uart using uart_cfig structure
  // ck_uart_init(&uart0, &uart_cfig);
  //--------------------------------------------------------

	ee_u16 i,j=0,num_algorithms=0;
	ee_s16 known_id=-1,total_errors=0;
	ee_u16 seedcrc=0;
	long total_time;
	core_results results[MULTITHREAD];
#if (MEM_METHOD==MEM_STACK)
	ee_u8 stack_memblock[TOTAL_DATA_SIZE*MULTITHREAD];
#endif
	/* first call any initializations needed */
	portable_init(&(results[0].port), &argc, argv);
	/* First some checks to make sure benchmark will run ok */
	if (sizeof(struct list_head_s)>128) {
		printf("list_head structure too big for comparable data!\n");
		return MAIN_RETURN_VAL;
	}
	results[0].seed1=get_seed(1);
	results[0].seed2=get_seed(2);
	results[0].seed3=get_seed(3);
	results[0].iterations= 2;
#if CORE_DEBUG
	results[0].iterations=1;
#endif
	results[0].execs=get_seed_32(5);
	if (results[0].execs==0) { /* if not supplied, execute all algorithms */
		results[0].execs=ALL_ALGORITHMS_MASK;
	}
		/* put in some default values based on one seed only for easy testing */
	if ((results[0].seed1==0) && (results[0].seed2==0) && (results[0].seed3==0)) { /* validation run */
		results[0].seed1=0;
		results[0].seed2=0;
		results[0].seed3=0x66;
	}
	if ((results[0].seed1==1) && (results[0].seed2==0) && (results[0].seed3==0)) { /* perfromance run */
		results[0].seed1=0x3415;
		results[0].seed2=0x3415;
		results[0].seed3=0x66;
	}
#if (MEM_METHOD==MEM_STATIC)
	results[0].memblock[0]=(void *)static_memblk;
	results[0].size=TOTAL_DATA_SIZE;
	results[0].err=0;
	#if (MULTITHREAD>1)
	#error "Cannot use a static data area with multiple contexts!"
	#endif
#elif (MEM_METHOD==MEM_MALLOC)
	for (i=0 ; i<MULTITHREAD; i++) {
		ee_s32 malloc_override=get_seed(7);
		if (malloc_override != 0) 
			results[i].size=malloc_override;
		else
			results[i].size=TOTAL_DATA_SIZE;
		results[i].memblock[0]=portable_malloc(results[i].size);
		results[i].seed1=results[0].seed1;
		results[i].seed2=results[0].seed2;
		results[i].seed3=results[0].seed3;
		results[i].err=0;
		results[i].execs=results[0].execs;
	}
#elif (MEM_METHOD==MEM_STACK)
	for (i=0 ; i<MULTITHREAD; i++) {
		results[i].memblock[0]=stack_memblock+i*TOTAL_DATA_SIZE;
		results[i].size=TOTAL_DATA_SIZE;
		results[i].seed1=results[0].seed1;
		results[i].seed2=results[0].seed2;
		results[i].seed3=results[0].seed3;
		results[i].err=0;
		results[i].execs=results[0].execs;
	}
#else
#error "Please define a way to initialize a memory block."
#endif
	/* Data init */ 
	/* Find out how space much we have based on number of algorithms */
	for (i=0; i<NUM_ALGORITHMS; i++) {
		if ((1<<(ee_u32)i) & results[0].execs)
			num_algorithms++;
	}
	for (i=0 ; i<MULTITHREAD; i++) 
		results[i].size=results[i].size/num_algorithms;
	/* Assign pointers */
	for (i=0; i<NUM_ALGORITHMS; i++) {
		ee_u32 ctx;
		if ((1<<(ee_u32)i) & results[0].execs) {
			for (ctx=0 ; ctx<MULTITHREAD; ctx++)
				results[ctx].memblock[i+1]=(char *)(results[ctx].memblock[0])+results[0].size*j;
			j++;
		}
	}
	/* call inits */
	for (i=0 ; i<MULTITHREAD; i++) {
		if (results[i].execs & ID_LIST) {
			results[i].list=core_list_init(results[0].size,results[i].memblock[1],results[i].seed1);
		}
		if (results[i].execs & ID_MATRIX) {
			core_init_matrix(results[0].size, results[i].memblock[2], (ee_s32)results[i].seed1 | (((ee_s32)results[i].seed2) << 16), &(results[i].mat) );
		}
		if (results[i].execs & ID_STATE) {
			core_init_state(results[0].size,results[i].seed1,results[i].memblock[3]);
		}
	}
	
	/* automatically determine number of iterations if not set */
	if (results[0].iterations==0) { 
		secs_ret secs_passed=0;
		ee_u32 divisor;
		results[0].iterations=1;
		while (secs_passed < (secs_ret)1) {
			results[0].iterations*=10;
			start_timer();
			iterate(&results[0]);
			stop_timer();
			secs_passed=time_in_secs(get_timer());
		}
		/* now we know it executes for at least 1 sec, set actual run time at about 10 secs */
		divisor=(ee_u32)secs_passed;
		if (divisor==0) /* some machines cast float to int as 0 since this conversion is not defined by ANSI, but we know at least one second passed */
			divisor=1;
		results[0].iterations*=1+10/divisor;
	}
	/* perform actual benchmark */
	start_timer();
#if (MULTITHREAD>1)
	if (default_num_contexts>MULTITHREAD) {
		default_num_contexts=MULTITHREAD;
	}
	for (i=0 ; i<default_num_contexts; i++) {
		results[i].iterations=results[0].iterations;
		results[i].execs=results[0].execs;
		core_start_parallel(&results[i]);
	}
	for (i=0 ; i<default_num_contexts; i++) {
		core_stop_parallel(&results[i]);
	}
#else
	iterate(&results[0]);
#endif
	current_time = get_timer();
	stop_timer();
	total_time = TIMER_PERIOD * Loop_Num + TIMER_PERIOD - current_time;
	/* get a function of the input to report */
	seedcrc=crc16(results[0].seed1,seedcrc);
	seedcrc=crc16(results[0].seed2,seedcrc);
	seedcrc=crc16(results[0].seed3,seedcrc);
	seedcrc=crc16(results[0].size,seedcrc);
	
	switch (seedcrc) { /* test known output for common seeds */
		case 0x8a02: /* seed1=0, seed2=0, seed3=0x66, size 2000 per algorithm */
			known_id=0;
			printf("6k performance run parameters for coremark.\n");
			break;
		case 0x7b05: /*  seed1=0x3415, seed2=0x3415, seed3=0x66, size 2000 per algorithm */
			known_id=1;
			printf("6k validation run parameters for coremark.\n");
			break;
		case 0x4eaf: /* seed1=0x8, seed2=0x8, seed3=0x8, size 400 per algorithm */
			known_id=2;
			printf("Profile generation run parameters for coremark.\n");
			break;
		case 0xe9f5: /* seed1=0, seed2=0, seed3=0x66, size 666 per algorithm */
			known_id=3;
			printf("2K performance run parameters for coremark.\n");
			break;
		case 0x18f2: /*  seed1=0x3415, seed2=0x3415, seed3=0x66, size 666 per algorithm */
			known_id=4;
			printf("2K validation run parameters for coremark.\n");
			break;
		default:
			total_errors=-1;
			break;
	}
	if (known_id>=0) {
		for (i=0 ; i<default_num_contexts; i++) {
			results[i].err=0;
			if ((results[i].execs & ID_LIST) && 
				(results[i].crclist!=list_known_crc[known_id])) {
				printf("[%u]ERROR! list crc 0x%04x - should be 0x%04x\n",i,results[i].crclist,list_known_crc[known_id]);
				results[i].err++;
			}
			if ((results[i].execs & ID_MATRIX) &&
				(results[i].crcmatrix!=matrix_known_crc[known_id])) {
				printf("[%u]ERROR! matrix crc 0x%04x - should be 0x%04x\n",i,results[i].crcmatrix,matrix_known_crc[known_id]);
				results[i].err++;
			}
			if ((results[i].execs & ID_STATE) &&
				(results[i].crcstate!=state_known_crc[known_id])) {
				printf("[%u]ERROR! state crc 0x%04x - should be 0x%04x\n",i,results[i].crcstate,state_known_crc[known_id]);
				results[i].err++;
			}
			total_errors+=results[i].err;
		}
	}
	total_errors+=check_data_types();
	/* and report results */
	printf("CoreMark Size    : %d\n",(ee_u32)results[0].size);
	printf("Total ticks      : %d\n",(ee_u32)total_time);
#if HAS_FLOAT
	printf("Total time (secs): %f\n",time_in_secs(total_time));
	if (time_in_secs(total_time) > 0)
		printf("Iterations/Sec   : %f\n",default_num_contexts*results[0].iterations/time_in_secs(total_time));
#else 
	printf("Total time (secs): %d\n",time_in_secs(total_time));
	if (time_in_secs(total_time) > 0)
		printf("Iterations/Sec   : %d\n",default_num_contexts*results[0].iterations/time_in_secs(total_time));
#endif
	if (time_in_secs(total_time) < 10) {
		printf("ERROR! Must execute for at least 10 secs for a valid result!\n");
		total_errors++;
	}

	printf("Iterations       : %d\n",(ee_u32)default_num_contexts*results[0].iterations);
	printf("Compiler version : %s\n",COMPILER_VERSION);
	printf("Compiler flags   : %s\n",COMPILER_FLAGS);
#if (MULTITHREAD>1)
	printf("Parallel %s : %d\n",PARALLEL_METHOD,default_num_contexts);
#endif
	printf("Memory location  : %s\n",MEM_LOCATION);
	/* output for verification */
	printf("seedcrc          : 0x%04x\n",seedcrc);
	if (results[0].execs & ID_LIST)
		for (i=0 ; i<default_num_contexts; i++)
			printf("[%d]crclist       : 0x%04x\n",i,results[i].crclist);
	if (results[0].execs & ID_MATRIX) 
		for (i=0 ; i<default_num_contexts; i++) 
			printf("[%d]crcmatrix     : 0x%04x\n",i,results[i].crcmatrix);
	if (results[0].execs & ID_STATE)
		for (i=0 ; i<default_num_contexts; i++) 
			printf("[%d]crcstate      : 0x%04x\n",i,results[i].crcstate);
	for (i=0 ; i<default_num_contexts; i++) 
		printf("[%d]crcfinal      : 0x%04x\n",i,results[i].crc);
	if (total_errors==0) {
		printf("Correct operation validated. See readme.txt for run and reporting rules.\n");
#if HAS_FLOAT
		if (known_id==3) {
			printf("CoreMark 1.0 : %f / %s %s",default_num_contexts*results[0].iterations/time_in_secs(total_time),COMPILER_VERSION,COMPILER_FLAGS);
#if defined(MEM_LOCATION) && !defined(MEM_LOCATION_UNSPEC)
			printf(" / %s",MEM_LOCATION);
#else
			printf(" / %s",mem_name[MEM_METHOD]);
#endif

#if (MULTITHREAD>1)
			printf(" / %d:%s",default_num_contexts,PARALLEL_METHOD);
#endif
			printf("\n");
		}
#endif
	}
	if (total_errors>0)
		printf("Errors detected\n");
	if (total_errors<0)
		printf("Cannot validate operation for these seed values, please compare with results on a known platform.\n");

#if (MEM_METHOD==MEM_MALLOC)
	for (i=0 ; i<MULTITHREAD; i++) 
		portable_free(results[i].memblock[0]);
#endif
	/* And last call any target specific code for finalizing */
	portable_fini(&(results[0].port));

        // while (ck_uart_status(&uart0));
        sim_end();

	return MAIN_RETURN_VAL;	
}


