/*
    AXI DMA Example
*/

#include <stdio.h>
#include "xaxidma.h"
#include "xscugic.h"
#include "xil_exception.h"
#include "platform.h"
#include "xparameters.h"
#include "xgpio.h"
#include "xstatus.h"
#include "xgpiops.h"
#include "xil_printf.h"
#include "sleep.h"

#define DMA_DEV_ID      XPAR_AXIDMA_0_DEVICE_ID
#define INTC_DEVICE_ID  XPAR_SCUGIC_0_DEVICE_ID
#define DMA_IRQ_ID      XPAR_FABRIC_AXI_DMA_0_S2MM_INTROUT_INTR  // Adjust for your design
#define MEM_BASE_ADDR   0x01000000
#define RX_BUFFER       (MEM_BASE_ADDR + 0x00200000)
#define BUFFER_SIZE     16

#ifndef SDT
#define PL_GPIO_DEVICE_ID  XPAR_GPIO_0_DEVICE_ID
#else
#define	XGPIO_AXI_BASEADDRESS	XPAR_XGPIO_0_BASEADDR
#endif

#define UDELAY      1000

/* DMA */
static XAxiDma AxiDma;
static XScuGic Intc;
// Interrupt handler
volatile int DmaDone = 0;

/* GPIO */
static XGpio PlGpio; /* The Instance of the PL GPIO Driver */
u32 Gpio_Mask = 0x00;
unsigned Channel = 1;

volatile u32 gpio_state = 0x0F;

/* DMA functions */
int SetupInterruptSystem(XScuGic *IntcInstancePtr);
void DmaHandler(void *CallBackRef);


/* GPIO functions */
int gpio_int();

int main()
{
    int Status;
    u32 *RxBuf = (u32 *)RX_BUFFER;
    /* Init Platform */
    init_platform();

    /* Init Gpio */
    gpio_int();

    xil_printf("******** AXI Dma example ********\r\n");
    // Init sample_generator
    XGpio_DiscreteWrite(&PlGpio, Channel, 0x2A08UL);

    // Initialize DMA
    XAxiDma_Config *Config = XAxiDma_LookupConfig(DMA_DEV_ID);
    if (!Config) {
        xil_printf("Error: axi_dma lookup config.\r\n");
        return XST_FAILURE;
    }
    Status = XAxiDma_CfgInitialize(&AxiDma, Config);
    if (Status != XST_SUCCESS) {
        xil_printf("Error: axi_dma initialization failed.\r\n");
        return XST_FAILURE;
    }

    // Check if DMA is in simple mode
    if (XAxiDma_HasSg(&AxiDma)) {
        xil_printf("Error: axi_dma is not in simple mode.\r\n");
        return XST_FAILURE;
    }

    // Disable polling, enable interrupts
    XAxiDma_IntrEnable(&AxiDma, XAXIDMA_IRQ_IOC_MASK, XAXIDMA_DEVICE_TO_DMA);

    // Initialize interrupt system
    Status = SetupInterruptSystem(&Intc);
    if (Status != XST_SUCCESS) {
        xil_printf("Error: interrupt system setup failed.\r\n");
        return XST_FAILURE;
    }

    while (1) {
        // Clear receive buffer
        for (int i = 0; i < BUFFER_SIZE; i++) RxBuf[i] = 0;

        // Flush cache
        Xil_DCacheFlushRange((UINTPTR)RxBuf, BUFFER_SIZE * sizeof(u32));

        xil_printf("Starting DMA transfer...\r\n");

        // Start S2MM transfer (Peripheral-to-Memory)
        Status = XAxiDma_SimpleTransfer(&AxiDma, (UINTPTR)RxBuf, BUFFER_SIZE * sizeof(u32), XAXIDMA_DEVICE_TO_DMA);
        if (Status != XST_SUCCESS) {
            xil_printf("Error: axi_dma simple transfer failed.\n\r");
            return XST_FAILURE;
        }

        // Wait for interrupt to signal completion
        while (!DmaDone);
        usleep(UDELAY);
    }
    xil_printf("DMA Test Completed!\r\n");

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

    return XST_SUCCESS;
}

void DmaHandler(void *CallBackRef) {
    xil_printf("DMA Transfer Complete!\r\n");
    DmaDone = 1;

    // Read received data
    u32 *RxBuf = (u32 *)RX_BUFFER;
    Xil_DCacheInvalidateRange((UINTPTR)RxBuf, BUFFER_SIZE * sizeof(u32));
    
    // Print received data
    for (int i = 0; i < BUFFER_SIZE; i++) {
        xil_printf("%08X\r\n", RxBuf[i]);
    }

    // Clear interrupt
    XAxiDma_IntrAckIrq(&AxiDma, XAXIDMA_IRQ_IOC_MASK, XAXIDMA_DEVICE_TO_DMA);
}

// Interrupt setup
int SetupInterruptSystem(XScuGic *IntcInstancePtr) {
    XScuGic_Config *IntcConfig;
    int Status;

    // Initialize Interrupt Controller
    IntcConfig = XScuGic_LookupConfig(INTC_DEVICE_ID);
    Status = XScuGic_CfgInitialize(IntcInstancePtr, IntcConfig, IntcConfig->CpuBaseAddress);
    if (Status != XST_SUCCESS) return XST_FAILURE;

    // Connect IRQ handler
    Status = XScuGic_Connect(IntcInstancePtr, DMA_IRQ_ID, (Xil_ExceptionHandler)DmaHandler, &AxiDma);
    if (Status != XST_SUCCESS) return XST_FAILURE;

    // Enable the interrupt
    XScuGic_Enable(IntcInstancePtr, DMA_IRQ_ID);

    // Enable exceptions
    Xil_ExceptionInit();
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_IRQ_INT, (Xil_ExceptionHandler)XScuGic_InterruptHandler, IntcInstancePtr);
    Xil_ExceptionEnable();

    return XST_SUCCESS;
}
