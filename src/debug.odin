package spaceinvaders

import "core:fmt"

printRegisters :: proc(state: ^State8080) {
    fmt.printf("          A: $%02x, BC: $%02x%02x, DE: $%02x%02x, HL: $%02x%02x, PC: $%02x, SP: $%04x ", state.a, state.b, state.c, state.d,
                state.e, state.h, state.l, state.pc, state.sp)
}

printConditionCodes :: proc(cc: ^ConditionCodes) {
    //fmt.printf("CY: %t, Z: %t, S: %t, P: %t, AC: %t ", cc.cy, cc.z, cc.s, cc.p, cc.ac)

    fmt.printf("Flags: ")
    if cc.z do fmt.printf("Z")
    if cc.s do fmt.printf("S")
    if cc.p do fmt.printf("P")
    if cc.ac do fmt.printf("A")
    if cc.cy do fmt.printf("C")
    
}

simpleInstruction :: proc(text: string) -> int {
    fmt.printf(text)
    fmt.printf("\n")
    return 1
}

byteInstruction :: proc(text: string, data: u8) -> int {
    fmt.printf(text)
    fmt.printf("$%02x", data)
    fmt.printf("\n")
    return 2
}

twoByteInstruction :: proc(text: string, data1: u8, data2: u8) -> int {
    fmt.printf(text)
    value := get_combined(data1, data2)
    fmt.printf("$%04x", value)
    fmt.printf("\n")
    return 3
}

disassemble8080p :: proc(codebuffer: []u8, pc: int) -> int {
    code := codebuffer[pc:]
    opbytes := 1

    fmt.printf("%04x ", pc)
    instruction : OpCode = auto_cast code[0]
    switch instruction {
        case .NOP: 
            return simpleInstruction("NOP")
        case .LXI_B:
            return twoByteInstruction("LXI    B", code[2], code[1])
        case .STAX_B:
            return simpleInstruction("STAX   B")
        case .INX_B:
            return simpleInstruction("INX    B")
        case .INR_B:
            return simpleInstruction("INR    B")
        case .DCR_B:
            return simpleInstruction("DCR    B")
        case .MVI_B:
            return byteInstruction("MVI    B,#", code[1])
        case .RLC:
            return simpleInstruction("RLC")
        case .NOP2:
            return simpleInstruction("NOP")
        case .DAD_B:
            return simpleInstruction("DAD    B")
        case .LDAX_B:
            return simpleInstruction("LDAX   B")
        case .DCX_B:
            return simpleInstruction("DCX    B")
        case .INR_C:
            return simpleInstruction("INR    C")
        case .DCR_C:
            return simpleInstruction("DCR    C")
        case .MVI_C:
            return byteInstruction("MVI    C,#", code[1])
        case .RRC:
            return simpleInstruction("RRC")
        case .NOP3:
            return simpleInstruction("NOP")
        case .LXI_D:
            return twoByteInstruction("LXI    D,#", code[2], code[1])
        case .STAX_D:
            return simpleInstruction("STAX   D")
        case .INX_D:
            return simpleInstruction("INX    D")
        case .INR_D:
            return simpleInstruction("INR    D")
        case .DCR_D:
            return simpleInstruction("DCR    D")
        case .MVI_D:
            return byteInstruction("MVI    D,#", code[1])
        case .RAL:
            return simpleInstruction("RAL")
        case .NOP4:
            return simpleInstruction("NOP")
        case .DAD_D:
            return simpleInstruction("DAD    D")
        case .LDAX_D:
            return simpleInstruction("LDAX   D")
        case .DCX_D:
            return simpleInstruction("DCX    D")
        case .INR_E:
            return simpleInstruction("INR    E")
        case .DCR_E:
            return simpleInstruction("DCR    E")
        case .MVI_E:
            return byteInstruction("MVI    E,#", code[1])
        case .RAR:
            return simpleInstruction("RAR")
        case .NOP5:
            return simpleInstruction("NOP")
        case .LXI_H:
            return twoByteInstruction("LXI    H,#", code[2], code[1])
        case .SHLD:
            return twoByteInstruction("SHLD   ", code[2], code[1])
        case .INX_H:
            return simpleInstruction("INX    H")
        case .INR_H:
            return simpleInstruction("INR    H")
        case .DCR_H:
            return simpleInstruction("DCR    H")
        case .MVI_H:
            return byteInstruction("MVI    H,#", code[1])
        case .DAA:
            return simpleInstruction("DAA")
        case .NOP6:
            return simpleInstruction("NOP")
        case .DAD_H:
            return simpleInstruction("DAD    H")
        case .LHLD:
            return twoByteInstruction("LHLD   ", code[2], code[1])
        case .DCX_H:
            return simpleInstruction("DCX    H")
        case .INR_L:
            return simpleInstruction("INR    L")
        case .DCR_L:
            return simpleInstruction("DCR    L")
        case .MVI_L:
            return byteInstruction("MVI    L,#", code[1])
        case .CMA:
            return simpleInstruction("CMA")
        case .NOP7:
            return simpleInstruction("NOP")
        case .LXI_SP:
            return twoByteInstruction("LXI    SP,#", code[2], code[1])
        case .STA:
            return twoByteInstruction("STA    ", code[2], code[1])
        case .INX_SP:
            return simpleInstruction("INX    SP")
        case .INR_M:
            return simpleInstruction("INR    M")
        case .DCR_M:
            return simpleInstruction("DCR    M")
        case .MVI_M:
            return byteInstruction("MVI    M,#", code[1])
        case .STC:
            return simpleInstruction("STC")
        case .NOP8:
            return simpleInstruction("NOP")
        case .DAD_SP:
            return simpleInstruction("DAD    SP")
        case .LDA:
            return twoByteInstruction("LDA    ", code[2], code[1])
        case .DCX_SP:
            return simpleInstruction("DCX    SP")
        case .INR_A:
            return simpleInstruction("INR    A")
        case .DCR_A:
            return simpleInstruction("DCR    A")
        case .MVI_A:
            return byteInstruction("MVI    A,#", code[1])
        case .CMC:
            return simpleInstruction("CMC")
        case .MOV_B_B:
            return simpleInstruction("MOV    B,B")
        case .MOV_B_C:
            return simpleInstruction("MOV    B,C")
        case .MOV_B_D:
            return simpleInstruction("MOV    B,D")
        case .MOV_B_E:
            return simpleInstruction("MOV    B,E")
        case .MOV_B_H:
            return simpleInstruction("MOV    B,H")
        case .MOV_B_L:
            return simpleInstruction("MOV    B,L")
        case .MOV_B_M:
            return simpleInstruction("MOV    B,M")
        case .MOV_B_A:
            return simpleInstruction("MOV    B,A")
        case .MOV_C_B:
            return simpleInstruction("MOV    C,B")
        case .MOV_C_C:
            return simpleInstruction("MOV    C,C")
        case .MOV_C_D:
            return simpleInstruction("MOV    C,D")
        case .MOV_C_E:
            return simpleInstruction("MOV    C,E")
        case .MOV_C_H:
            return simpleInstruction("MOV    C,H")
        case .MOV_C_L:
            return simpleInstruction("MOV    C,L")
        case .MOV_C_M:
            return simpleInstruction("MOV    C,M")
        case .MOV_C_A:
            return simpleInstruction("MOV    C,A")
        case .MOV_D_B:
            return simpleInstruction("MOV    D,B")
        case .MOV_D_C:
            return simpleInstruction("MOV    D,C")
        case .MOV_D_D:
            return simpleInstruction("MOV    D,D")
        case .MOV_D_E:
            return simpleInstruction("MOV    D,E")
        case .MOV_D_H:
            return simpleInstruction("MOV    D,H")
        case .MOV_D_L:
            return simpleInstruction("MOV    D,L")
        case .MOV_D_M:
            return simpleInstruction("MOV    D,M")
        case .MOV_D_A:
            return simpleInstruction("MOV    D,A")
        case .MOV_E_B:
            return simpleInstruction("MOV    E,B")
        case .MOV_E_C:
            return simpleInstruction("MOV    E,C")
        case .MOV_E_D:
            return simpleInstruction("MOV    E,D")
        case .MOV_E_E:
            return simpleInstruction("MOV    E,E")
        case .MOV_E_H:
            return simpleInstruction("MOV    E,H")
        case .MOV_E_L:
            return simpleInstruction("MOV    E,L")
        case .MOV_E_M:
            return simpleInstruction("MOV    E,M")
        case .MOV_E_A:
            return simpleInstruction("MOV    E,A")
        case .MOV_H_B:
            return simpleInstruction("MOV    H,B")
        case .MOV_H_C:
            return simpleInstruction("MOV    H,C")
        case .MOV_H_D:
            return simpleInstruction("MOV    H,D")
        case .MOV_H_E:
            return simpleInstruction("MOV    H,E")
        case .MOV_H_H:
            return simpleInstruction("MOV    H,H")
        case .MOV_H_L:
            return simpleInstruction("MOV    H,L")
        case .MOV_H_M:
            return simpleInstruction("MOV    H,M")
        case .MOV_H_A:
            return simpleInstruction("MOV    H,A")
        case .MOV_L_B:
            return simpleInstruction("MOV    L,B")
        case .MOV_L_C:
            return simpleInstruction("MOV    L,C")
        case .MOV_L_D:
            return simpleInstruction("MOV    L,D")
        case .MOV_L_E:
            return simpleInstruction("MOV    L,E")
        case .MOV_L_H:
            return simpleInstruction("MOV    L,H")
        case .MOV_L_L:
            return simpleInstruction("MOV    L,L")
        case .MOV_L_M:
            return simpleInstruction("MOV    L,M")
        case .MOV_L_A:
            return simpleInstruction("MOV    L,A")
        case .MOV_M_B:
            return simpleInstruction("MOV    M,B")
        case .MOV_M_C:
            return simpleInstruction("MOV    M,C")
        case .MOV_M_D:
            return simpleInstruction("MOV    M,D")
        case .MOV_M_E:
            return simpleInstruction("MOV    M,E")
        case .MOV_M_H:
            return simpleInstruction("MOV    M,H")
        case .MOV_M_L:
            return simpleInstruction("MOV    M,L")
        case .HLT:
            return simpleInstruction("HLT")
        case .MOV_M_A:
            return simpleInstruction("MOV    M,A")
        case .MOV_A_B:
            return simpleInstruction("MOV    A,B")
        case .MOV_A_C:
            return simpleInstruction("MOV    A,C")
        case .MOV_A_D:
            return simpleInstruction("MOV    A,D")
        case .MOV_A_E:
            return simpleInstruction("MOV    A,E")
        case .MOV_A_H:
            return simpleInstruction("MOV    A,H")
        case .MOV_A_L:
            return simpleInstruction("MOV    A,L")
        case .MOV_A_M:
            return simpleInstruction("MOV    A,M")
        case .MOV_A_A:
            return simpleInstruction("MOV    A,A")
        case .ADD_B:
            return simpleInstruction("ADD    B")
        case .ADD_C:
            return simpleInstruction("ADD    C")
        case .ADD_D:
            return simpleInstruction("ADD    D")
        case .ADD_E:
            return simpleInstruction("ADD    E")
        case .ADD_H:
            return simpleInstruction("ADD    H")
        case .ADD_L:
            return simpleInstruction("ADD    L")
        case .ADD_M:
            return simpleInstruction("ADD    M")
        case .ADD_A:
            return simpleInstruction("ADD A")
        case .ADC_B:
            return simpleInstruction("ADC B")
        case .ADC_C:
            return simpleInstruction("ADC C")
        case .ADC_D:
            return simpleInstruction("ADC D")
        case .ADC_E:
            return simpleInstruction("ADC E")
        case .ADC_H:
            return simpleInstruction("ADC H")
        case .ADC_L:
            return simpleInstruction("ADC L")
        case .ADC_M:
            return simpleInstruction("ADC M")
        case .ADC_A:
            return simpleInstruction("ADC A")
        case .SUB_B:
            return simpleInstruction("SUB B")
        case .SUB_C:
            return simpleInstruction("SUB C")
        case .SUB_D:
            return simpleInstruction("SUB D")
        case .SUB_E:
            return simpleInstruction("SUB E")
        case .SUB_H:
            return simpleInstruction("SUB H")
        case .SUB_L:
            return simpleInstruction("SUB L")
        case .SUB_M:
            return simpleInstruction("SUB M")
        case .SUB_A:
            return simpleInstruction("SUB A")
        case .SBB_B:
            return simpleInstruction("SBB B")
        case .SBB_C:
            return simpleInstruction("SBB C")
        case .SBB_D:
            return simpleInstruction("SBB D")
        case .SBB_E:
            return simpleInstruction("SBB E")
        case .SBB_H:
            return simpleInstruction("SBB H")
        case .SBB_L:
            return simpleInstruction("SBB L")
        case .SBB_M:
            return simpleInstruction("SBB M")
        case .SBB_A:
            return simpleInstruction("SBB A")
        case .ANA_B:
            return simpleInstruction("ANA    B")
        case .ANA_C:
            return simpleInstruction("ANA    C")
        case .ANA_D:
            return simpleInstruction("ANA    D")
        case .ANA_E:
            return simpleInstruction("ANA    E")
        case .ANA_H:
            return simpleInstruction("ANA    H")
        case .ANA_L:
            return simpleInstruction("ANA    L")
        case .ANA_M:
            return simpleInstruction("ANA    M")
        case .ANA_A:
            return simpleInstruction("ANA    A")
        case .XRA_B:
            return simpleInstruction("XRA    B")
        case .XRA_C:
            return simpleInstruction("XRA    C")
        case .XRA_D:
            return simpleInstruction("XRA    D")
        case .XRA_E:
            return simpleInstruction("XRA    E")
        case .XRA_H:
            return simpleInstruction("XRA    H")
        case .XRA_L:
            return simpleInstruction("XRA    L")
        case .XRA_M:
            return simpleInstruction("XRA    M")
        case .XRA_A:
            return simpleInstruction("XRA    A")
        case .ORA_B:
            return simpleInstruction("ORA    B")
        case .ORA_C:
            return simpleInstruction("ORA    C")
        case .ORA_D:
            return simpleInstruction("ORA    D")
        case .ORA_E:
            return simpleInstruction("ORA    E")
        case .ORA_H:
            return simpleInstruction("ORA    H")
        case .ORA_L:
            return simpleInstruction("ORA    L")
        case .ORA_M:
            return simpleInstruction("ORA    M")
        case .ORA_A:
            return simpleInstruction("ORA    A")
        case .CMP_B:
            return simpleInstruction("CMP    B")
        case .CMP_C:
            return simpleInstruction("CMP    C")
        case .CMP_D:
            return simpleInstruction("CMP    D")
        case .CMP_E:
            return simpleInstruction("CMP    E")
        case .CMP_H:
            return simpleInstruction("CMP    H")
        case .CMP_L:
            return simpleInstruction("CMP    L")
        case .CMP_M:
            return simpleInstruction("CMP    M")
        case .CMP_A:
            return simpleInstruction("CMP    A")
        case .RNZ:
            return simpleInstruction("RNZ")
        case .POP_B:
            return simpleInstruction("POP    B")
        case .JNZ:
            return twoByteInstruction("JNZ    ", code[2], code[1])
        case .JMP:
            return twoByteInstruction("JMP    ", code[2], code[1])
        case .CNZ:
            return twoByteInstruction("CNZ    ", code[2], code[1])
        case .PUSH_B:
            return simpleInstruction("PUSH   B")
        case .ADI:
            return byteInstruction("ADI", code[1])
        case .RST_0:
            return simpleInstruction("RST    0")
        case .RZ:
            return simpleInstruction("RZ")
        case .RET:
            return simpleInstruction("RET")
        case .JZ:
            return twoByteInstruction("JZ     ", code[2], code[1])
        case .NOP9:
            return simpleInstruction("NOP")
        case .CZ:
            return twoByteInstruction("CZ     ", code[2], code[1])
        case .CALL:
            return twoByteInstruction("CALL   ", code[2], code[1])
        case .ACI:
            return byteInstruction("ACI", code[1])
        case .RST_1:
            return simpleInstruction("RST    1")
        case .RNC:
            return simpleInstruction("RNC")
        case .POP_D:
            return simpleInstruction("POP    D")
        case .JNC:
            return twoByteInstruction("JNC    ", code[2], code[1])
        case .OUT:
            return byteInstruction("OUT    #", code[1])
        case .CNC:
            return twoByteInstruction("CNC    ", code[2], code[1])
        case .PUSH_D:
            return simpleInstruction("PUSH   D")
        case .SUI:
            return byteInstruction("SUI", code[1])
        case .RST_2:
            return simpleInstruction("RST 2")
        case .RC:
            return simpleInstruction("RC")
        case .NOP10:
            return simpleInstruction("NOP")
        case .JC:
            return twoByteInstruction("JC     ", code[2], code[1])
        case .IN:
            return byteInstruction("IN", code[1])
        case .CC:
            return twoByteInstruction("CC     ", code[2], code[1])
        case .NOP11:
            return simpleInstruction("NOP")
        case .SBI:
            return byteInstruction("SBI", code[2])
        case .RST_3:
            return simpleInstruction("RST 3")
        case .RPO:
            return simpleInstruction("RPO")
        case .POP_H:
            return simpleInstruction("POP    H")
        case .JPO:
            return twoByteInstruction("JPO", code[2], code[1])
        case .XTHL:
            return simpleInstruction("XTHL")
        case .CPO:
            return twoByteInstruction("CPO", code[2], code[1])
        case .PUSH_H:
            return simpleInstruction("PUSH   H")
        case .ANI:
            return byteInstruction("ANI", code[1])
        case .RST_4:
            return simpleInstruction("RST 4")
        case .RPE:
            return simpleInstruction("RPE")
        case .PCHL:
            return simpleInstruction("PCHL")
        case .JPE:
            return twoByteInstruction("JPE", code[2], code[1])
        case .XCHG:
            return simpleInstruction("XCHG")
        case .CPE:
            return twoByteInstruction("CPE", code[2], code[1])
        case .NOP12:
            return simpleInstruction("NOP")
        case .XRI:
            return byteInstruction("XRI", code[1])
        case .RST_5:
            return simpleInstruction("RST    5")
        case .RP:
            return simpleInstruction("RP")
        case .POP_PSW:
            return simpleInstruction("POP    PSW")
        case .JP:
            return twoByteInstruction("JP", code[2], code[1])
        case .DI:
            return simpleInstruction("DI")
        case .CP:
            return twoByteInstruction("CP", code[2], code[1])
        case .PUSH_PSW:
            return simpleInstruction("PUSH   PSW")
        case .ORI:
            return byteInstruction("ORI", code[1])
        case .RST_6:
            return simpleInstruction("RST    6")
        case .RM:
            return simpleInstruction("RM")
        case .SPHL:
            return simpleInstruction("SPHL")
        case .JM:
            return twoByteInstruction("JM", code[2], code[1])
        case .EI:
            return simpleInstruction("EI")
        case .CM:
            return twoByteInstruction("CM", code[2], code[1])
        case .NOP13:
            return simpleInstruction("NOP")
        case .CPI:
            return byteInstruction("CPI    ", code[1])
        case .RST_7:
            return simpleInstruction("RST    7")
    }

    fmt.printf("ERROR:, Switch statement should return\n")
    return opbytes
}