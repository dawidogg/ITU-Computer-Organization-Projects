# https://leetcode.com/problems/search-insert-position/
# Given a sorted array of distinct integers and a target value, 
# return the index if the target is found. If not, return the 
# index where it would be if it were inserted in order.

ORG 0x0
# initialize the stack
LD R1 IM 0xFF
MOV SP R1
# load the target to R1
LD R1 IM TARGET
MOV AR R1
LD R1 D 
# load the array pointer to AR
LD R2 IM ARRAY
MOV AR R2

LOOP_1:     BRA IS_SMALLER
RETURN:     PUL R3 # take the result of the function
            LD R4 IM 0x01 # check if true
            SUB R2 R3 R4
            BNE CONTINUE_3
            BRA EXIT
CONTINUE_3: INC AR AR
            INC AR AR
            # check if the end of array is reached
            LD R3 D
            MOV R3 R3
            BNE LOOP_1
            BRA EXIT

# R1 - Target, R2 - Value-to-Compare, R3 - Limit, R4 - Guessing Pointer
IS_SMALLER: MOV R4 R1        # set the guessing pointer as the target initially
LOOP_2:     LD R2 D          # R2 stores the value currently pointed
            SUB R3 R2 R4   
            BNE CONTINUE_1
            BRA RETURN_TRUE  # if guessing pointer reaches the value-to-compare 
                             # before overflow, the result is true
CONTINUE_1: LD R3 IM 0xFF    # store limit 
            SUB R2 R3 R4
            BNE CONTINUE_2
            BRA RETURN_FALSE # if guessing pointer reaches the limit without 
                             # finding the value-to-compare, the result is false 
CONTINUE_2: INC R4 R4
            BRA LOOP_2
RETURN_FALSE:   LD R3 IM 0x00
                PSH R3 # push false
                BRA RETURN 
RETURN_TRUE:    LD R3 IM 0x01
                PSH R3 # push true
                BRA RETURN 

        # save result
EXIT:   LD R1 IM ARRAY
        SUB R1 AR R1
        LSR R1 R1
        INC R1 R1
        LD R2 IM RESULT
        MOV AR R2
        ST R1
        # clear stack
        LD R1 IM 0x00
        PSH R1
        PUL R1
        HLT
        
        ORG 0xD0
TARGET: 0xA5
ARRAY:  0x13    
        0x15
        0x3A
        0x51
        0x58
        0x9E
        0xA5
RESULT: 0x00
        END
