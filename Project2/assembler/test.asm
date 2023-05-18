        BRA 0x28    # This instruction is written to the memory address 0x00,
                    # The first instruction must be written to the address 0x28

        ORG 0x28
        LD R1 IM 0x0A # This first instruction is written to the address 0x28,
                      # R1 is used for iteration number
        LD R2 IM 0x00 # R2 is used to store total
        LD R3 IM 0xB0
        MOV AR R3     # AR is used to track data address: starts from 0xA0
LABEL:  LD R3 D       # R3 ← M[AR] (AR = 0xB0 to 0xBA)
        ADD R2 R2 R3  # R2 ← R2 + R3 (Total = Total + M[AR])
        INC AR AR     # AR ← AR + 1 (Next Data)
        DEC R1 R1     # R1 ← R1 – 1 (Decrement Iteration Counter)
        BNE LABEL  # Go back to LABEL if Z=0 (Iteration Counter > 0)
        INC AR AR     # AR ← AR + 1 (Total will be written to 0xBB)
        ST R2       # M[AR] ← R2 (Store Total at 0xBB)
A:      0x54
B:      0xAA
C:      0x60
        END
