            BRA ADDITION

            ORG 0x30
ADDITION:   LD R1 IM VALUE_A # loading value_a into register R1
            MOV AR R1        # through direct adressing
            LD R1 D

            LD R2 IM VALUE_B # Loading value_b into register R2
                             # through immediate adressing
            ADD R3 R1 R2 # adding R1 and R2 and storing into R3

            LD R4 IM RESULT # storing the result
            MOV AR R4  
            ST R3

            BRA INCREMENT # jumping to the next routine
VALUE_A:    0x02
VALUE_B:    0x05
RESULT:     0x00

            ORG 0x60
INCREMENT:  LD R1 IM RESULT # loading the adress of result
            LD R2 D # loading the value of result
            INC R2 R2 # incrementing
            ST R2 # storing the incremented value back to result
            HLT
            END        
