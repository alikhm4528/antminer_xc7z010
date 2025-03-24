/*
    AXI Gpio Example
*/

#include <stdio.h>
#include "platform.h"
#include "xparameters.h"
#include "xgpio.h"
#include "xstatus.h"
#include "xgpiops.h"
#include "xil_printf.h"
#include "sleep.h"

#ifndef SDT
#define PL_GPIO_DEVICE_ID  XPAR_GPIO_0_DEVICE_ID
#else
#define	XGPIO_AXI_BASEADDRESS	XPAR_XGPIO_0_BASEADDR
#endif

#define PS_GPIO_DEVICE_ID  	XPAR_XGPIOPS_0_DEVICE_ID

#define S1         47
#define S2         51
#define MASK_LED1  (0x01UL)
#define MASK_LED2  (0x02UL)
#define UDELAY      100000

static XGpio PlGpio; /* The Instance of the PL GPIO Driver */
static XGpioPs PsGpio; /* The Instance of the PS GPIO Driver */
u32 Gpio_Mask = 0x00;
unsigned Channel = 1;

volatile u32 gpio_state = 0x0F;

int gpio_int();

int main()
{
    /* Init Platform */
    init_platform();

    /* Init Gpio */
    gpio_int();

    xil_printf("******** AXI Gpio example ********\n\r");

    while(1) {
        if(XGpioPs_ReadPin(&PsGpio, S1) == 0) {
            xil_printf("S1 is pulled down\n\r");
            gpio_state &= ~MASK_LED1;
        } else {
            gpio_state |= MASK_LED1;
        }
        if(XGpioPs_ReadPin(&PsGpio, S2) == 0) {
            xil_printf("S2 is pulled down\n\r");
            gpio_state &= ~MASK_LED2;
        } else {
            gpio_state |= MASK_LED2;
        }
        XGpio_DiscreteWrite(&PlGpio, Channel, gpio_state);
        usleep(UDELAY);
    }

    cleanup_platform();
    return 0;
}

int gpio_int() {
    int Status;
    XGpioPs_Config *ConfigPtr;

    /* Initialize the PL GPIO driver */
#ifndef SDT
	Status = XGpio_Initialize(&PlGpio, PL_GPIO_DEVICE_ID);
#else
	Status = XGpio_Initialize(&PlGpio, XGPIO_AXI_BASEADDRESS);
#endif
    if (Status != XST_SUCCESS) {
        xil_printf("PlGpio Initialization Failed\r\n");
        return XST_FAILURE;
    }

    /* Set the direction for the specified pin to be output(0). */
    XGpio_SetDataDirection(&PlGpio, Channel, Gpio_Mask);

	/* Initialize the PS GPIO driver. */
	ConfigPtr = XGpioPs_LookupConfig(PS_GPIO_DEVICE_ID);
	Status = XGpioPs_CfgInitialize(&PsGpio, ConfigPtr,
					ConfigPtr->BaseAddr);
	if (Status != XST_SUCCESS) {
        xil_printf("PS Gpio Initialization Failed\r\n");
		return XST_FAILURE;
	}

    /* Set the direction for the specified pin to be input(1). */
	XGpioPs_SetDirectionPin(&PsGpio, S1, 0x0);
	XGpioPs_SetDirectionPin(&PsGpio, S2, 0x0);

    return XST_SUCCESS;
}
