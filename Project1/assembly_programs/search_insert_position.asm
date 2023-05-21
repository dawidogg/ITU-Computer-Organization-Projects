# https://leetcode.com/problems/search-insert-position/
# Given a sorted array of distinct integers and a target value, 
# return the index if the target is found. If not, return the 
# index where it would be if it were inserted in order.

        ORG 0x0
        # initialize the stack
        LD R1 IM STACK
        MOV SP R1
        # load the target to R1
        LD R1 IM TARGET
        MOV AR R1
        LD R1 D 
        # load the array pointer to R2
        LD R2 IM ARRAY

LOOP_1: BRA IS_SMALLER
RETURN: PUL R3 # take the result of the function
        LD R4 IM 0x01 
        SUB R4 R3 R4
        BNE EXIT
        INC R2 R2
        # Check if the end of array is reached
        MOV AR R2
        LD R3 D
        MOV R3 R3
        BNE EXIT
        BRA LOOP_1

IS_SMALLER: MOV AR R2
            PSH R2 # save the array pointer
            LD R2 D # now R2 stores the value currently pointed
            LD R3 IM 0xFF # store limit
LOOP_2:     SUB R4 R1 R2   
            BNE RETURN_FALSE
            SUB R4 R1 R3
            BNE RETURN_TRUE
            INC R3 R3
            BRA LOOP_2
RETURN_FALSE:   PUL R2 # retrieve the array pointer
                LD R3 IM 0x00
                PSH R3 # push false
                BRA RETURN 
RETURN_TRUE:    PUL R2 # retrieve the array pointer
                LD R3 IM 0x01
                PSH R3 # push true
                BRA RETURN 

TARGET: 0xC3
ARRAY:  0x13    
        0x15
        0x3A
        0x51
        0x5E
        0x60
        0x67
        0xAA
        0xA9
        0xC2
        0xC3
        0xDD
        0xEE
        0xF6
        0xFB
        0xFF
RESULT: 0x00

EXIT:   LD R1 IM ARRAY
        SUB R1 R2 R1
        LD R2 IM RESULT
        MOV AR R2
        ST R1
        HLT

        ORG 0xFF
STACK:  0x0
        END
