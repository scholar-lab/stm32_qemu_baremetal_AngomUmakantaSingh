#include <stdint.h>
#include "semihosting.h"

/* SysTick register definitions */
#define SYST_CSR (*(volatile uint32_t*)0xE000E010)
#define SYST_RVR (*(volatile uint32_t*)0xE000E014)
#define SYST_CVR (*(volatile uint32_t*)0xE000E018)

#define CPU_CLOCK 168000000
#define SYSTICK_HZ 1000

/* Configure and start SysTick */
void systick_init(void)
{
    SYST_RVR = (CPU_CLOCK / SYSTICK_HZ) - 1;
    SYST_CVR = 0;

    SYST_CSR = (1<<0) | (1<<1) | (1<<2);
}

/* Test variables for .data and .bss */
int initialized = 123;
int uninitialized;

/* Counter updated by SysTick interrupt */
volatile uint32_t systick_counter = 0;

/*Clock Variables */
int hours = 0;
int minutes = 0;
int seconds = 0;
int prev_sec =0;

/* SysTick interrupt handler */
void SysTick_Handler(void)
{
    systick_counter++;
}

/* print two digit decimal using semihosting output */
void print_two_digits(int value)
{
    char buf[3];
    buf[0] = '0' + (value / 10);
    buf[1] = '0' + (value % 10);
    buf[2] = '\0';
    sh_puts(buf);
}

int main(void)
{
    sh_puts("Boot OK\r\n");
    if (initialized == 123 && uninitialized == 0)
        sh_puts("Data/BSS verified\r\n");
    /* start SysTick timer */
    systick_init();
    while (1)
    {
        /* observable behaviour */
        if (systick_counter >= 1000) // 1000 ms
        {
            //sh_puts("500 ticks reached\r\n");
            systick_counter = 0;
            seconds++;

            if (seconds == 60)
            {
                seconds = 0;
                minutes++;
            }

            if (minutes == 60)
            {
                minutes = 0;
                hours++;
            }

            if (hours == 24)
            {
                hours = 0;
            }
        
        }
      if(prev_sec!=seconds){ // print only when time has changed, not multiple times for the same time
                        print_two_digits(hours);
                        sh_puts(":");
                        print_two_digits(minutes);
                        sh_puts(":");
                        print_two_digits(seconds);
                        sh_puts("\r\n");
                        prev_sec = seconds;
                        }
    }
}


