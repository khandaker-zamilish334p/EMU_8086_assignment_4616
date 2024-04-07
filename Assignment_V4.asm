INCLUDE EMU8086.INC
.MODEL SMALL
.STACK 100H
.DATA
MSSG1 DB "ENTER THE NUMBER OF ITEMS: $"
MSSG2 DB 0AH,0DH,"ITEM NAME: $"
MSSG3 DB 0AH,0DH,"PRICE: $"
MSSG4 DB 0AH,0DH,"SORTED LIST: $"
MSSG5 DB 0AH,0DH,"THE WHOLE LIST: $"
MSSG6 DB 0AH,0DH,"BINARY SEARCHED LIST: $"

ITEM DB 512 DUP(?)
PRICE DW 256 DUP(?)
IDX DW 256 DUP(?)
ITER DW ?      


.CODE

MAIN PROC
    XOR AX, AX
    XOR BX, BX
    XOR CX, CX
    XOR DX, DX
    XOR SI, SI
    XOR DI, DI
    
    MOV AX, @DATA
    MOV DS, AX
    
    LEA DX, MSSG1
    MOV AH, 9 
    INT 21H
    
    CALL SCAN_NUM
    MOV ITER, CX
    
    XOR CX, CX
    
    MOV IDX[0], 0
    
    INPUT_PROMPT:
    LEA DX, MSSG2
    INT 21H
    
    INPUT_STRING:
    MOV AH, 1
    INT 21H
    MOV ITEM[DI], AL
    INC DI
    CMP AL, 0DH
    JNE INPUT_STRING
    
    STORE_IDX:
    ;INC SI
    ;INC SI
    ADD SI, 2
    MOV IDX[SI], DI
   
    PRICE_INPUT: 
    LEA DX, MSSG3
    MOV AH, 9
    INT 21H
    ;DEC SI
    ;DEC SI
    SUB SI, 2
    PUSH CX
    CALL SCAN_NUM
    MOV PRICE[SI], CX
    POP CX
    ;INC SI
    ;INC SI
    ADD SI, 2
    INC CX
    CMP CX, ITER
    JB INPUT_PROMPT    
    
    LEA DX, MSSG5
    MOV AH, 9
    INT 21H
    CALL OUTPUT
    
    LEA DX, MSSG4
    MOV AH, 9
    INT 21H
    
    CALL BUBBLE_SORT
    CALL OUTPUT 
    
     
    LEA DX, MSSG6
    MOV AH, 9
    INT 21H
    CALL BINARY_SEARCH
    
    JMP TERMINATE
    
    TERMINATE:
    MOV AH, 4CH
    INT 21H
    
    MAIN ENDP    
    DEFINE_SCAN_NUM
    DEFINE_PRINT_NUM_UNS
    
    OUTPUT PROC
        
        XOR CX, CX
        XOR AX, AX
        XOR DI, DI
        XOR SI, SI
        
        P1:
        MOV DI, IDX[SI]
        
        LEA DX, MSSG2
        MOV AH, 9
        INT 21H
        P2:
        MOV DL, ITEM[DI]
        MOV AH, 2
        ;done by zamilish 200021334
        INT 21H
        INC DI
        CMP DX, 0DH
        JNE P2
        
        LEA DX, MSSG3
        MOV AH, 9
        INT 21H
        P3:
        MOV AX, PRICE[SI]
        CALL PRINT_NUM_UNS 
        ;INC SI
        ;INC SI
        ADD SI, 2
        INC CX
        ;MOV AX, ITER
        CMP CX, ITER
        JB P1
        
        RET
        OUTPUT ENDP
    
    BUBBLE_SORT PROC
    
    XOR AX, AX
    XOR BX, BX
    XOR CX, CX
    XOR DX, DX
    XOR SI, SI
    XOR DI, DI
    
    MOV DX, ITER
    SUB DX, 1
    
    B1:
    MOV AX, PRICE[SI]
    MOV BX, PRICE[SI+2]
    CMP AX, BX
    JBE B3
        
    B2:
    PUSH PRICE[SI]
    ;PUSH PRICE[SI+2]
    POP PRICE[SI]
    POP PRICE[SI+2]
    PUSH IDX[SI]
    PUSH IDX[SI+2]
    POP IDX[SI]
    POP IDX[SI+2]
    INC DI
    
    B3:
    INC CX
    ADD SI, 2
    
    CMP CX, DX
    JB B1
        
    B4:
    CMP DI, 0
    JE B5
    XOR CX, CX
    XOR DI, DI
    XOR SI, SI
    JMP B1
    
    B5:
    RET
    
    BUBBLE_SORT ENDP  
    
    BINARY_SEARCH PROC
        
        XOR AX, AX
        XOR BX, BX
        XOR CX, CX
        XOR DX, DX
        XOR SI, SI
        XOR DI, DI
        
        BS1:
        CMP PRICE[SI], 20 
        ;INC CX
        JBE Q1
        JA Q2
        
        Q1:
        INC CX
        ADD SI, 2
        INC BX
        CMP BX, ITER
        JB BS1
        MOV AH, 4CH
        INT 21H
        
        Q2:
        ;MOV AH, 2
        ;MOV DX, SI
        ;INT 21H
        SUB ITER, CX 
        XOR CX, CX
        ;INC ITER 
        
        D1:
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
        
        LEA DX, MSSG3
        MOV AH, 9
        INT 21H
        D3:
        MOV AX, PRICE[SI]
        CALL PRINT_NUM_UNS 
        ;INC SI
        ;INC SI
        ADD SI, 2
        INC CX
        ;MOV AX, ITER
        CMP CX, ITER
        JB D1
        ;intentional error in line 165
        
        RET
        
        BINARY_SEARCH ENDP
    
    
END MAIN
