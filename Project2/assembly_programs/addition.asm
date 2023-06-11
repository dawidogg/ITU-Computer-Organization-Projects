            BRA ADDITION

            ORG 0x30
            # load value_a into register R1
ADDITION:   LD R1 IM VALUE_A
            MOV AR R1
            LD R1 D       
			# load VALUE_B into register R2
			LD R2 IM VALUE_B 
            MOV AR R2        
            LD R2 D
            # add R1 with R2 and store to R3
            ADD R3 R1 R2 
			# store to RESULT
            LD R4 IM RESULT 
            MOV AR R4  
            ST R3
			# jump to the next routine
            BRA INCREMENT 
            
            
VALUE_A:    0x10
VALUE_B:    0x05
RESULT:     0x00

            ORG 0x60
            # load the result
INCREMENT:  LD R1 IM RESULT
			MOV AR R1
            LD R1 D 
            #increment
            INC R1 R1
            # store the incremented value back to result        
            ST R1 
            HLT
            END        
