INCLUDE EMU8086.INC     ;for using macros
.MODEL SMALL
.STACK 100H
.DATA
MSSG1 DB "ENTER THE NUMBER OF ITEMS: $"    ;initializing the messages in the memory to be printed in the terminal
MSSG2 DB 0AH,0DH,"ITEM NAME: $"
MSSG3 DB 0AH,0DH,"PRICE: $"
MSSG4 DB 0AH,0DH,"-----SORTED LIST:----- $"
MSSG5 DB 0AH,0DH,"-----THE WHOLE LIST:----- $"
MSSG6 DB 0AH,0DH,"-----BINARY SEARCHED LIST:----- $"
MSSG7 DB 0AH, 0DH, "NOT FOUND$"

ITEM DB 512 DUP(?)      ;initializing the empty arrays for item name and price storage
PRICE DW 256 DUP(?)
IDX DW 256 DUP(?)       ;used to store the index of the first character of each item name
ITER DW ?               ;store total number of items


.CODE

MAIN PROC
    XOR AX, AX         ;clearing all the registers
    XOR BX, BX
    XOR CX, CX
    XOR DX, DX
    XOR SI, SI
    XOR DI, DI
    
    MOV AX, @DATA      ;loading the memory segment address of the data segment to the data segment register
    MOV DS, AX
    
    LEA DX, MSSG1      ;prompt for total number of items
    MOV AH, 9 
    INT 21H
    
    CALL SCAN_NUM      ;taking total number of items as input
    MOV ITER, CX
    
    XOR CX, CX
    
    MOV IDX[0], 0      ;storing the index of the first character of the first item name
    
    INPUT_PROMPT:      ;input prompt for taking the input of item name
    LEA DX, MSSG2
    INT 21H
    
    INPUT_STRING:      ;taking each character input for each item names
    MOV AH, 1
    INT 21H
    MOV ITEM[DI], AL   ;storing each character in the item name array
    INC DI             ;incrementing the index of name array for the next character 
    CMP AL, 0DH        ;comparing the input if it is return carriage
    JNE INPUT_STRING
    
    STORE_IDX:         ;storing the index of the first character of each item name in index array
    ADD SI, 2
    MOV IDX[SI], DI
   
    PRICE_INPUT:       ;input prompt to give the price input
    LEA DX, MSSG3
    MOV AH, 9
    INT 21H
    SUB SI, 2
    PUSH CX            ;since the price is stored in CX
    CALL SCAN_NUM      ;taking the price input
    MOV PRICE[SI], CX  ;stroing the price input from CX register to the price array
    POP CX             ;to bring back the old value in CX
    ADD SI, 2          ;increment the index of price array for next price input
    INC CX
    CMP CX, ITER
    JB INPUT_PROMPT    ;loop to take the required number of inputs
    
    LEA DX, MSSG5      ;prompt to print the whole list
    MOV AH, 9
    INT 21H
    CALL OUTPUT
    
    LEA DX, MSSG4      ;prompt to print the sorted list
    MOV AH, 9
    INT 21H
    
    CALL BUBBLE_SORT   ;bubble sort procedure
    CALL OUTPUT 
    
     
    LEA DX, MSSG6      ;prompt for binary searched list
    MOV AH, 9
    INT 21H
    CALL BINARY_SEARCH ;binary search procedure
    
    JMP TERMINATE
    
    TERMINATE:         ;handing over the control to DOS
    MOV AH, 4CH
    INT 21H
    
    MAIN ENDP    
    DEFINE_SCAN_NUM     ;defining the macros
    DEFINE_PRINT_NUM_UNS
    
    OUTPUT PROC         ;procedure for printing the list from the arrays
        
        XOR CX, CX      ;setting all register values to 0
        XOR AX, AX
        XOR DI, DI
        XOR SI, SI
        
        P1:
        MOV DI, IDX[SI]    ;getting the index of the first character of any item name
        
        LEA DX, MSSG2      ;prompt for item name
        MOV AH, 9
        INT 21H
        P2:
        MOV DL, ITEM[DI]   ;printing each character of item name
        MOV AH, 2
        INT 21H
        INC DI             ;increment index to print the next character
        CMP DX, 0DH        ;stops printing character when a carriage return is found
        JNE P2
        
        LEA DX, MSSG3      ;prompt for item price
        MOV AH, 9
        INT 21H
        P3:
        MOV AX, PRICE[SI]  ;moving the price from array to register 
        CALL PRINT_NUM_UNS ;printing the decimal value of the price
        ADD SI, 2          ;incrementing index to print the 
        INC CX
        CMP CX, ITER       ;counter and loop to print the required number of items
        JB P1
        
        RET
        OUTPUT ENDP
    
    BUBBLE_SORT PROC       ;procedure for bubble sorting
    
    XOR AX, AX             ;settting all register values to zero
    XOR BX, BX
    XOR CX, CX
    XOR DX, DX
    XOR SI, SI
    XOR DI, DI
                           
    MOV DX, ITER           ;storing the total number of items for comparison with the index in each loop
    SUB DX, 1
    
    B1:
    MOV AX, PRICE[SI]      ;storing a particular price from array to register
    MOV BX, PRICE[SI+2]    ;storing the immediate next price from array to register
    CMP AX, BX             ;comparing the 2 prices
    JBE B3                 ;if the first price is below or equal to the next price then jump to B3 as it in increasing order
        
    B2:                    ;if the previous condition is not met i.e the first price is greater than second price
    PUSH PRICE[SI]         ;push the first price to the stack
    PUSH PRICE[SI+2]       ;push the second price to the stack
    POP PRICE[SI]          ;storing the lower price before the higher price
    POP PRICE[SI+2]
    PUSH IDX[SI]           ;same operation as the price for the index of name array
    PUSH IDX[SI+2]
    POP IDX[SI]
    POP IDX[SI+2]
    INC DI
    
    B3:
    INC CX                 ;increment the counter
    ADD SI, 2              ;increment index for next price
    
    CMP CX, DX             ;comparing the counter to check if the whole array has been covered once
    JB B1
        
    B4:
    CMP DI, 0              ;if DI it means that there was no change in the array and the sorting is complete
    JE B5
    XOR CX, CX
    XOR DI, DI
    XOR SI, SI
    JMP B1
    
    B5:
    RET
    
    BUBBLE_SORT ENDP  
    
    BINARY_SEARCH PROC     ;binary search procedure
        
        XOR AX, AX
        XOR BX, BX
        XOR CX, CX
        XOR DX, DX
        XOR SI, SI
        XOR DI, DI
        
        MOV DX, ITER       ;initializing the upper index
        ;SHL DX, 1          ;multiply the 
        ;SUB DX, 2
        DEC DX          ;decrement the upper index to account for the 0th index
        MOV BX, 0          ;initializing the lower index
        
        @START_BIN:
        CMP BX, DX         ;comparing the upper and lower index
        JGE @NOT_FOUND      ;if lower index becomes greater than the upper index
        
        MOV AX, BX         ;moving the lower index to AX register
        ADD AX, DX         ;adding the lower index to upper limit
        SHR AX, 1          ;dividing by 2
        
        MOV SI, AX
        SHL SI, 1         ;thus we found the middle index
        CMP PRICE[SI], 20  ;using the middle index we compare the respective price to the required value
        JE @FOUND          ;if equal to the required value then the search is done
        JB @BIG            ;if greater than the required value then move to the higher segment
        JG @SMALL          ;if lower than the required value then move to the lower segment
        
        @BIG:              ;for the higher segment
        ;ADD AX, 2
        INC AX          ;change the lower index to the min index of the higher segment
        MOV BX, AX
        JMP @START_BIN
        
        @SMALL:            ;for lower segment
        ;SUB AX, 2
        DEC AX          ;changing the upper index to the max index of the lower segment
        MOV DX, AX
        JMP @START_BIN
        
        @NOT_FOUND:        ;if the required number is not found 
        ;XOR SI, SI
        ;CMP PRICE[SI], 20
        ;ADD SI, 2
        ;MOV AX, SI
        
        ;JA @FOUND
        ;JMP @NOT_FOUND
        
        MOV SI, BX
        SHL SI, 1
        CMP PRICE[SI], 20
        JGE IDX_SAME
        JB IDX_INC
        
        IDX_SAME:
        JMP @END_BIN
        
        IDX_INC:
        INC SI
        INC SI
        JMP @END_BIN
        
        @FOUND:            ;if the required number is found
        MOV SI, AX         ;moving the index to SI for getting the price
        ;MOV CX, SI         ;creating a counter for printing the items in a loop
        ;SHR CX, 1
        ;DEC CX
        SHL SI, 1
        
        @END_BIN:
        ;SHR SI, 1
        MOV CX, ITER
        MOV BX, SI
        SHR BX, 1
        SUB CX, BX
        ;SHR BX, 1
        ;DEC BX
         
        
        D1:                ;loop for printing the item name and price after the binary search
        MOV DI, IDX[SI]
        
        LEA DX, MSSG2
        MOV AH, 9
        INT 21H
        D2:
        MOV DL, ITEM[DI]
        MOV AH, 2
        INT 21H
        INC DI
        CMP DX, 0DH
        JNE D2
        
        D:
        LEA DX, MSSG3
        MOV AH, 9
        INT 21H
        D3:
        MOV AX, PRICE[SI] 
        CALL PRINT_NUM_UNS 
        ADD SI, 2
        ;DEC BX
        ;CMP BX, 0
        ;JE @END_BIN1
        ;JMP D1
        LOOP D1
       
        @END_BIN1:
        RET
        
        BINARY_SEARCH ENDP
    
    
END MAIN