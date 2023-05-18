#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ok printf("ok\n")

struct { 
    int value[4];
    char symbol[3];
    int adress_ref;
} 
OpcodeTable[] = {
    {{0, 0, 0, 0}, "AND", 0}, 
    {{0, 0, 0, 1}, "OR" , 0},
    {{0, 0, 1, 0}, "NOT", 0},
    {{0, 0, 1, 1}, "ADD", 0},
    {{0, 1, 0, 0}, "SUB", 0},
    {{0, 1, 0, 1}, "LSR", 0},
    {{0, 1, 1, 0}, "LSL", 0},
    {{0, 1, 1, 1}, "INC", 0},
    {{1, 0, 0, 0}, "DEC", 0},
    {{1, 0, 0, 1}, "BRA", 1},
    {{1, 0, 1, 0}, "BNE", 1},
    {{1, 0, 1, 1}, "MOV", 0},
    {{1, 1, 0, 0}, "LD" , 1},
    {{1, 1, 0, 1}, "ST" , 1},   
    {{1, 1, 1, 0}, "PUL", 0},
    {{1, 1, 1, 1}, "PSH", 0},
};

int getOpcodeIndex(char* s) {
    for (int i = 0; i < 16; i++)
        if (strcmp(s, OpcodeTable[i].symbol) == 0) {
            return  OpcodeTable[i].value[0]*8 +
                    OpcodeTable[i].value[1]*4 +
                    OpcodeTable[i].value[2]*2 +
                    OpcodeTable[i].value[3]*1;
        }  
    return -1; // hexadecimal       
}

struct {
    int value[4];
    char symbol[2];
} 
RselTable[] = {
    {{0, 0}, "R1"},
    {{0, 1}, "R2"},
    {{1, 0}, "R3"},
    {{1, 1}, "R4"}
},
RegTable[] = {
    {{0, 0, 0, 0}, "R1"},
    {{0, 0, 0, 1}, "R2"},
    {{0, 0, 1, 0}, "R3"},
    {{0, 0, 1, 1}, "R4"},
    {{0, 1, 0, 0}, "SP"},
    {{0, 1, 0, 1}, "AR"},
    {{0, 1, 1, 0}, "PC"},
    {{0, 1, 1, 1}, "PC"},
};

int getRselIndex(char *s) {
    for (int i = 0; i < 4; i++)
        if (strcmp(s, RselTable[i].symbol) == 0)
            return  RselTable[i].value[0]*2 +
                    RselTable[i].value[1]*1; 
    printf("Error, invalid R_SEL value: %s\n", s);
    return -1;
}

int getRegIndex(char *s) {
    for (int i = 0; i < 8; i++)
        if (strcmp(s, RegTable[i].symbol) == 0)
            return  RegTable[i].value[0]*8 + 
                    RegTable[i].value[1]*4 + 
                    RegTable[i].value[2]*2 + 
                    RegTable[i].value[3]*1; 
    if (strlen(s) > 0)
        printf("Error, invalid DSTREG/SREG1/SREG2 value: %s\n", s);
    return -1;
}

struct {
    char name[16];
    int position;
} LabelTable[256];
int label_count;

struct ParsedString{
    char label[16];
    char arg[4][16];
};

int is_space(char c) {
    switch (c) {
        case ' ': return 1; 
        case '\t': return 1; 
        case '\n': return 1; 
        case '\v': return 1;  
        case '\f': return 1;  
        case '\r': return 1; 
        default: break;
    }
   return 0; 
}  

// Returns 0 if line is empty or contains only a comment, 1 otherwise
int parseLine(char *s, struct ParsedString *result) {
    int s_length = strlen(s);
    int label_pos = -1;

    // Finding label and comment
    for (int i = 0; i < s_length; i++) {
        if (s[i] == '#')
            break;
        if (s[i] == ':') { 
            label_pos = i;
            break;
        }
    }
    if (label_pos < s_length && label_pos != -1) {
        strncpy(result->label, s, label_pos);
        result->label[label_pos] = '\0';
        // printf("Label: %s\n", result->label);
    }

    char temp[64];
    int counter = 0;
    int ptr1 = label_pos+1;
    int ptr2;   
    
    while (ptr1 < s_length) {
        while (ptr1 < s_length && is_space(s[ptr1])) ptr1++;
        if (s[ptr1] == '#' || ptr1 >= s_length) break;
        if (counter >= 4)
            printf("Error, too many arguments at the following instruction:\n%s", s);
        ptr2 = ptr1;
        while (!is_space(s[ptr2])) ptr2++;
        strncpy(result->arg[counter], s+ptr1, ptr2-ptr1);
        result->arg[counter][ptr2-ptr1] = '\0';
        
        //printf("Argument[%d]: %s\n", counter, result->arg[counter]);
        ptr1 = ptr2;
        counter++;
    }
    return (counter > 0);
}

int power(int a, int b) {
    int result =  1;
    while (b > 0) {
        b--;
        result *= a;
    }
    return result;
}

int stringToHex(char *s) {
    // If the string is a label
    if (s[1] != 'x') {
        for (int i = 0; i < label_count; i++)
            if (strcmp(LabelTable[i].name, s) == 0)
                return LabelTable[i].position;
        printf("Error, unknown label %s\n", s);
    }
    int result = 0;
    for (int i = 2; i < 4; i++) {
        if (s[i] >= '0' && s[i] <= '9')
            result += power(16, 3-i)*(s[i]-'0');
        if (s[i] >= 'A' && s[i] <= 'F')
            result += power(16, 3-i)*(s[i]-'A'+10);
    }
    return result;
}

void hexToBin(int h, int vals[8]) {
    int i = 7;
    while (h > 0) {
        vals[i] = (h & 1) == 1;
        h = h >> 1;
        i--;
    }
}

int main(int argc, char *argv[]) {
    FILE *assembly_file, *memory_file, *bin_memory_file;
    memory_file = fopen("./HEX_RAM.mem", "w");    
    bin_memory_file = fopen("./BIN_RAM.mem", "w");
    if (argc == 2)
        assembly_file = fopen(argv[1], "r");
    else {
        printf("usage: ./assembler <file_name>\n");
        return 1;
    }

    // Parse 
    struct ParsedString parsed_string[256];
    char line[256];
    int line_count = 0;
    while (fgets(line, sizeof(line), assembly_file)) {
        if (parseLine(line, parsed_string+line_count))
            line_count++;
    }

    // First pass - find labels
    int position = -1;
    label_count = 0;
    for (int i = 0; i < line_count; i++) {
        position++;
        printf("Position: 0x%x, instruction: %s\n", position, parsed_string[i].arg[0]);
        if (strcmp(parsed_string[i].arg[0], "ORG") == 0) {
            position = stringToHex(parsed_string[i].arg[1])-1;
            continue;
        }
        if (strlen(parsed_string[i].label) > 0) {
            strcpy(LabelTable[label_count].name, parsed_string[i].label);
            LabelTable[label_count].position = position;
            label_count++;
        }
    }

    for (int i = 0; i < label_count; i++)
        printf("label name: %s, position: 0x%x\n", LabelTable[i].name, LabelTable[i].position);

    // Second pass - assemble the program
    int RAM[256] = {0};
    int BIN_RAM[256][16] = {{0},{0},{0},{0},{0},{0},{0},{0},
                            {0},{0},{0},{0},{0},{0},{0},{0}};
    position = -1;
    for (int i = 0; i < line_count; i++) {
        position++;
        if (strcmp(parsed_string[i].arg[0], "ORG") == 0) {
            position = stringToHex(parsed_string[i].arg[1])-1;
            continue;
        }
        if (strcmp(parsed_string[i].arg[0], "END") == 0)
            break;

        int opcode_i = getOpcodeIndex(parsed_string[i].arg[0]);
        int bytes[16] = {0};
            
        
        // Hexadecimal data
        if (opcode_i == -1) {
            int hex_value = stringToHex(parsed_string[i].arg[0]);
            int vals[8] = {0};
            hexToBin(hex_value, bytes+8);
        }
        // Instructions without an address reference
        else if (OpcodeTable[opcode_i].adress_ref == 0) {
            for (int j = 0; j < 4; j++)
                bytes[j] = OpcodeTable[opcode_i].value[j];

            int a1_i = getRegIndex(parsed_string[i].arg[1]);
            int a2_i = getRegIndex(parsed_string[i].arg[2]);
            int a3_i = getRegIndex(parsed_string[i].arg[3]);
            for (int j = 0; j < 4; j++) {
                bytes[j+4] = RegTable[a1_i].value[j] == 1;
                bytes[j+8] = RegTable[a2_i].value[j] == 1;
                bytes[j+12] = RegTable[a3_i].value[j] == 1;
            }
        }
        // Instructions with an address reference
        else if (OpcodeTable[opcode_i].adress_ref == 1) {
            for (int j = 0; j < 4; j++)
                bytes[j] = OpcodeTable[opcode_i].value[j];

            int adress[8] = {0};
            // BRA and BNE
            if (opcode_i == 0x09 || opcode_i == 0x0a) {
                hexToBin(stringToHex(parsed_string[i].arg[1]), adress);
                for (int j = 0; j < 8; j++)
                    bytes[j+8] = adress[j];
            }

            // LD
            if (opcode_i == 0x0C) {
                int rsel_i = getRselIndex(parsed_string[i].arg[1]);
                // printf("Index of %s is %d\n", parsed_string[i].arg[1], rsel_i);
                for (int j = 0; j < 2; j++)
                    bytes[j+6] = RselTable[rsel_i].value[j];
                if (strcmp(parsed_string[i].arg[2], "IM") == 0) {
                    bytes[5] = 0;
                    hexToBin(stringToHex(parsed_string[i].arg[3]), adress);
                    for (int j = 0; j < 8; j++)
                        bytes[j+8] = adress[j];
                }
                if (strcmp(parsed_string[i].arg[2], "D") == 0)
                    bytes[5] = 1;
            }

            // ST
            if (opcode_i == 0x0D) {
                bytes[5] = 1; // always direct adressing for store
                int rsel_i = getRselIndex(parsed_string[i].arg[1]);
                for (int j = 0; j < 2; j++)
                    bytes[j+6] = RselTable[rsel_i].value[j];
            }
        }

        printf("Instruction at 0x%x: ", position);
        for (int j = 0; j < 16; j++) {
            printf("%d", bytes[j]);
        }
        printf("\n");

        for (int j = 0; j < 16; j++) {
            BIN_RAM[position][j] = bytes[j];
            RAM[position] += power(2, 15-j)*bytes[j];
        }
    }

    // Write out to files
    for (int i = 0; i < 256; i++) {
        fprintf(memory_file, "%04x\n", RAM[i]);
        for (int j = 0; j < 16; j++)
            fprintf(bin_memory_file, "%d", BIN_RAM[i][j]);
        fprintf(bin_memory_file, "\n");
    }

    fclose(assembly_file);
    fclose(memory_file);
    fclose(bin_memory_file);
    
    printf("HEX_RAM.mem and BIN_RAM.mem were created.\n");
    return 0;
}
