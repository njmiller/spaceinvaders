package spaceinvaders

import "core:fmt"
import "core:math/bits"
import "core:os"

OpCode :: enum u8 {
    NOP = 0x00,
    LXI_B = 0x01,
    STAX_B = 0x02,
    INX_B = 0x03,
    INR_B = 0x04,
    DCR_B = 0x05,
    MVI_B = 0x06,
    RLC = 0x07,
    NOP2 = 0x08,
    DAD_B = 0x09,
    LDAX_B = 0x0a,
    DCX_B = 0x0b,
    INR_C = 0x0c,
    DCR_C = 0x0d,
    MVI_C = 0x0e,
    RRC = 0x0f,
    NOP3 = 0x10,
    LXI_D,
    STAX_D,
    INX_D,
    INR_D,
    DCR_D,
    MVI_D,
    RAL,
    NOP4,
    DAD_D,
    LDAX_D,
    DCX_D,
    INR_E,
    DCR_E,
    MVI_E,
    RAR,
    NOP5,
    LXI_H,
    SHLD,
    INX_H,
    INR_H,
    DCR_H,
    MVI_H,
    DAA,
    NOP6,
    DAD_H,
    LHLD,
    DCX_H,
    INR_L,
    DCR_L,
    MVI_L,
    CMA,
    NOP7,
    LXI_SP,
    STA,
    INX_SP,
    INR_M,
    DCR_M,
    MVI_M,
    STC,
    NOP8,
    DAD_SP,
    LDA,
    DCX_SP,
    INR_A,
    DCR_A,
    MVI_A,
    CMC,
    MOV_B_B,
    MOV_B_C,
    MOV_B_D,
    MOV_B_E,
    MOV_B_H,
    MOV_B_L,
    MOV_B_M,
    MOV_B_A,
    MOV_C_B,
    MOV_C_C,
    MOV_C_D,
    MOV_C_E,
    MOV_C_H,
    MOV_C_L,
    MOV_C_M,
    MOV_C_A,
    MOV_D_B,
    MOV_D_C,
    MOV_D_D,
    MOV_D_E,
    MOV_D_H,
    MOV_D_L,
    MOV_D_M,
    MOV_D_A,
    MOV_E_B,
    MOV_E_C,
    MOV_E_D,
    MOV_E_E,
    MOV_E_H,
    MOV_E_L,
    MOV_E_M,
    MOV_E_A,
    MOV_H_B,
    MOV_H_C,
    MOV_H_D,
    MOV_H_E,
    MOV_H_H,
    MOV_H_L,
    MOV_H_M,
    MOV_H_A,
    MOV_L_B,
    MOV_L_C,
    MOV_L_D,
    MOV_L_E,
    MOV_L_H,
    MOV_L_L,
    MOV_L_M,
    MOV_L_A,
    MOV_M_B,
    MOV_M_C,
    MOV_M_D,
    MOV_M_E,
    MOV_M_H,
    MOV_M_L,
    HLT,
    MOV_M_A,
    MOV_A_B,
    MOV_A_C,
    MOV_A_D,
    MOV_A_E,
    MOV_A_H,
    MOV_A_L,
    MOV_A_M,
    MOV_A_A,
    ADD_B,
    ADD_C,
    ADD_D,
    ADD_E,
    ADD_H,
    ADD_L,
    ADD_M,
    ADD_A,
    ADC_B,
    ADC_C,
    ADC_D,
    ADC_E,
    ADC_H,
    ADC_L,
    ADC_M,
    ADC_A,
    SUB_B,
    SUB_C,
    SUB_D,
    SUB_E,
    SUB_H,
    SUB_L,
    SUB_M,
    SUB_A,
    SBB_B,
    SBB_C,
    SBB_D,
    SBB_E,
    SBB_H,
    SBB_L,
    SBB_M,
    SBB_A,
    ANA_B,
    ANA_C,
    ANA_D,
    ANA_E,
    ANA_H,
    ANA_L,
    ANA_M,
    ANA_A,
    XRA_B,
    XRA_C,
    XRA_D,
    XRA_E,
    XRA_H,
    XRA_L,
    XRA_M,
    XRA_A,
    ORA_B,
    ORA_C,
    ORA_D,
    ORA_E,
    ORA_H,
    ORA_L,
    ORA_M,
    ORA_A,
    CMP_B,
    CMP_C,
    CMP_D,
    CMP_E,
    CMP_H,
    CMP_L,
    CMP_M,
    CMP_A,
    RNZ,
    POP_B,
    JNZ,
    JMP,
    CNZ,
    PUSH_B,
    ADI,
    RST_0,
    RZ,
    RET,
    JZ,
    NOP9,
    CZ,
    CALL,
    ACI,
    RST_1,
    RNC,
    POP_D,
    JNC,
    OUT,
    CNC,
    PUSH_D,
    SUI,
    RST_2,
    RC,
    NOP10,
    JC,
    IN,
    CC,
    NOP11,
    SBI,
    RST_3,
    RPO,
    POP_H,
    JPO,
    XTHL,
    CPO,
    PUSH_H,
    ANI,
    RST_4,
    RPE,
    PCHL,
    JPE,
    XCHG,
    CPE,
    NOP12,
    XRI,
    RST_5,
    RP,
    POP_PSW,
    JP,
    DI,
    CP,
    PUSH_PSW,
    ORI,
    RST_6,
    RM,
    SPHL,
    JM,
    EI,
    CM,
    NOP13,
    CPI,
    RST_7 = 0xff,
}

//TODO: Convert to bitset
ConditionCodes :: struct {
    z : bool,
    s : bool,
    p : bool,
    cy : bool,
    ac : bool,
    pad : int,
}

State8080 :: struct {
    a : u8,
    b : u8,
    c : u8,
    d : u8,
    e : u8,
    h : u8,
    l : u8,
    sp : u16,
    pc : int,
    memory : []u8,
    cc : ConditionCodes,
    int_enable : bool,
}

unimplementedInstruction :: proc(state: ^State8080) {
    fmt.printf("Error: Unimplemented instruction\n")
    os.exit(60)
}

setZSP :: proc(result: u16, cc: ^ConditionCodes) {
    cc.z = (result & 0xff) == 0
    cc.s = (result & 0x80) != 0
    cc.p = parity(result, 8)
}

setZSPC :: proc(result: u16, cc: ^ConditionCodes) {
    setZSP(result, cc)
    cc.cy = result > 0xff
}

setAuxCarry :: proc(a: u8, b:u8, cc: ^ConditionCodes) {
    cc.ac = (a & 0x0f) + (b & 0x0f) > 0x0f
}

ana :: proc(reg1: u8, state: ^State8080) -> int {
    state.a = reg1 & state.a
    state.cc.cy = false
    state.cc.ac = false
    setZSP(u16(state.a), &state.cc)

    return 1
}

xra :: proc(reg1: u8, state: ^State8080) -> int {
    state.a = state.a ~ reg1
    state.cc.cy = false
    state.cc.ac = false
    setZSP(u16(state.a), &state.cc)

    return 1
}

ora :: proc(reg1: u8, state: ^State8080) -> int {
    state.a = state.a | reg1
    state.cc.cy = false
    state.cc.ac = false
    setZSP(u16(state.a), &state.cc)

    return 1
}

//Can be use for adi
add :: proc(reg1: u8, state: ^State8080) -> int {
    result := u16(state.a) + u16(reg1)
    setZSPC(result, &state.cc)
    setAuxCarry(state.a, reg1, &state.cc)
    
    state.a = auto_cast result & 0xff
    return 1
}


adc :: proc(reg1: u8, state: ^State8080) -> int {
    //TODO
    state.a += reg1// + state.cc.cy
    return 1
}

lxi :: proc(reg1: ^u8, reg2: ^u8, memory: []u8) -> int {
    reg1^ = memory[1]
    reg2^ = memory[0]
    return 3
}

stax :: proc(high: u8, low: u8, state: ^State8080) -> int {
    offset := get_combined(high, low)
    state.memory[offset] = state.a
    return 3
}

inx :: proc(high: ^u8, low: ^u8) -> int {
    value := get_combined(high^, low^)
    value += 1
    high^ = get_high(value)
    low^ = get_low(value)
    return 1
}

dcx :: proc(high: ^u8, low: ^u8) -> int {
    value := get_combined(high^, low^)
    value -= 1
    high^ = get_high(value)
    low^ = get_low(value)
    return 1
}

inr :: proc(reg: ^u8, cc: ^ConditionCodes) -> int {
    result := u16(reg^) + 1
    setZSP(result, cc)
    setAuxCarry(reg^, 1, cc)
    reg^ = u8(result & 0xff)
    return 1
}

//TODO: Check aux carry for decrement
dcr :: proc(reg: ^u8, cc: ^ConditionCodes) -> int {
    result := u16(reg^) - 1
    setZSP(result, cc)
    setAuxCarry(reg^, 1, cc)
    reg^ = u8(result & 0xff)
    return 1
}

//dad :: proc(reg1: u8, reg2: u8, state: ^State8080) -> int {
dad :: proc(value: u16, state: ^State8080) -> int {
    //value := get_combined(reg1, reg2)
    hl := u32(getHL(state)) + u32(value)

    state.cc.cy = (hl & 0xffff) != hl

    hl16 := u16(hl & 0xffff)
    state.h = get_high(hl16)
    state.l = get_low(hl16)

    return 1
}

cmp :: proc(value: u8, state: ^State8080) -> int {
    result := state.a - value
    setZSP(u16(result), &state.cc)
    state.cc.cy = state.a < value
    return 1
}

// Implement all the jump instructions. Since the differences are the
// jump conditions, it is also passed in as an argument
jump :: proc(state: ^State8080, cond: bool) -> int {
    //pc_delt := 3
    if !cond do return 3
    //if cond {
    offset := getImmediate(state)
    state.pc = auto_cast offset
    //pc_delt = 0
    //}
    return 0
}

mov :: proc(dest: ^u8, source: ^u8) -> int {
    dest^ = source^
    return 1
}

parity :: proc(value: u16, size: uint) -> bool {
    nbits := bits.count_ones(value)
    return 0 == (nbits & 0x1)

    /*
    p := 0
    value := (value & ((1<<size)-1))
    for i := 0; i < int(size); i += 1 {
        if (value & 0x1) != 0 do p += 1
        value = value >> 1
    }
    
    fmt.println("PARITY:", value, p, nbits)
    return 0 == (p & 0x1)
    */
}

swap :: proc(reg1: ^u8, reg2: ^u8) -> int {
    tmp := reg1^
    reg1^ = reg2^
    reg2^ = tmp
    return 1
}

call :: proc(state: ^State8080, cond: bool) -> int {

    if !cond do return 3

    //fmt.printf("CALL: %04x\n", state.pc + 3)
    retAddr := u16(state.pc) + 3
    state.memory[state.sp - 1] = get_high(retAddr)
    state.memory[state.sp - 2] = get_low(retAddr)
    state.sp -= 2
    state.pc = auto_cast getImmediate(state)
    return 0
}

ret :: proc(state: ^State8080, cond: bool) -> int {

    if !cond do return 1

    low := state.memory[state.sp]
    high := state.memory[state.sp + 1]

    retAddr := get_combined(high, low)

    /*
    tmp1 := state.memory[state.pc+1]
    tmp2 := state.memory[state.pc+2]
    tmp := get_combined(tmp2, tmp1)
    fmt.printf("RET: %04x %04x\n", retAddr, tmp)
    */

    state.pc = auto_cast get_combined(high, low)
    state.sp += 2

    return 0
}

// Functions to push and pop values off the stack.
// Order of input registers should be b,c / d,e / h,l
pushR :: proc(reg1: u8, reg2: u8, state: ^State8080) -> int {
    state.memory[state.sp-2] = reg2
    state.memory[state.sp-1] = reg1
    state.sp -= 2
    return 1
}

popR :: proc(reg1: ^u8, reg2: ^u8, state: ^State8080) -> int {
    reg2^ = state.memory[state.sp]
    reg1^ = state.memory[state.sp+1]
    state.sp += 2
    return 1
}

@(private="file")
get_high :: proc(value: u16) -> u8 {
    out : u8 = auto_cast (value >> 8) & 0xff
    return out
}

@(private="file")
get_low :: proc(value: u16) -> u8 {
    out : u8 = auto_cast value & 0xff
    return out
}

get_combined :: proc(high: u8, low: u8) -> u16 {
    return (u16(high) << 8) | u16(low)
}

setBC :: proc(state: ^State8080, value: u16) {
    state.b = get_high(value)
    state.c = get_low(value)
}

setDE :: proc(state: ^State8080, value: u16) {
    state.d = get_high(value)
    state.e = get_low(value)
}

setHL :: proc(state: ^State8080, value: u16) {
    state.h = get_high(value)
    state.l = get_low(value)
}

getBC :: proc(state: ^State8080) -> u16 { return get_combined(state.b, state.c) }
getDE :: proc(state: ^State8080) -> u16 { return get_combined(state.d, state.e) }
getHL :: proc(state: ^State8080) -> u16 { return get_combined(state.h, state.l) }

getM :: proc(state: ^State8080) -> u8 {
    offset := getHL(state)
    return state.memory[offset]
}

setM :: proc(value: u8, state: ^State8080) {
    offset := getHL(state)
    state.memory[offset] = value
}

getImmediate :: proc(state: ^State8080) -> u16 {
    return get_combined(state.memory[state.pc+2], state.memory[state.pc+1])
}

conditionCodesToU8 :: proc(cc: ^ConditionCodes) -> u8 {
    value : u8 = 1 << 6

    value = cc.cy ? value | (1 << 7) : value
    value = cc.p ? value | (1 << 5) : value
    value = cc.ac ? value | (1 << 3) : value
    value = cc.z ? value | (1 << 1) : value
    value = cc.s ? value | 1 : value

    return value
}

u8ToConditionCodes :: proc(value: u8, cc: ^ConditionCodes) {
    cc.cy = value & (1 << 7) > 0
    cc.p = value & (1 << 5) > 0
    cc.ac = value & (1 << 3) > 0
    cc.z = value & (1 << 1) > 0
    cc.s = value & 1 > 0
}

emuluate8080p :: proc(state: ^State8080) -> int {
    opcode : OpCode = auto_cast state.memory[state.pc]
    pc_delt : int = 0

    disassemble8080p(state.memory, state.pc)

    #partial switch opcode {
        case .NOP, .NOP2, .NOP3, .NOP4, .NOP5:
            pc_delt = 1
        case .ANA_B:
            pc_delt = ana(state.b, state)
        case .ANA_C:
            pc_delt = ana(state.c, state)
        case .ANA_D:
            pc_delt = ana(state.d, state)
        case .ANA_E:
            pc_delt = ana(state.e, state)
        case .ANA_H:
            pc_delt = ana(state.h, state)
        case .ANA_L:
            pc_delt = ana(state.l, state)
        case .ANA_M:
            value := getM(state)
            pc_delt = ana(value, state)
        case .ANA_A:
            pc_delt = ana(state.a, state)
        case .ANI:
            data := state.memory[state.pc+1]
            pc_delt = ana(data, state) + 1
        case .XRA_B:
            pc_delt = xra(state.b, state)
        case .XRA_C:
            pc_delt = xra(state.c, state)
        case .XRA_D:
            pc_delt = xra(state.d, state)
        case .XRA_E:
            pc_delt = xra(state.e, state)
        case .XRA_H:
            pc_delt = xra(state.h, state)
        case .XRA_L:
            pc_delt = xra(state.l, state)
        case .XRA_M:
            value := getM(state)
            pc_delt = xra(value, state)
        case .XRA_A:
            pc_delt = xra(state.a, state)
        case .INR_D:
            pc_delt = inr(&state.d, &state.cc)
        case .DCR_B:
            pc_delt = dcr(&state.b, &state.cc)
        case .DCR_C:
            pc_delt = dcr(&state.c, &state.cc)
        case .DCX_B:
            pc_delt = dcx(&state.b, &state.c)
        case .DCX_D:
            pc_delt = dcx(&state.d, &state.e)
        case .DCX_H:
            pc_delt = dcx(&state.h, &state.l)
        case .INX_B:
            pc_delt = inx(&state.b, &state.c)
        case .INX_D:
            pc_delt = inx(&state.d, &state.e)
        case .INX_H:
            pc_delt = inx(&state.h, &state.l)
        case .LDAX_B:
            offset := getBC(state)
            state.a = state.memory[offset]
            pc_delt = 1
        case .LDAX_D:
            offset := getDE(state)
            state.a = state.memory[offset]
            pc_delt = 1
        case .LDA:
            offset := getImmediate(state)
            state.a = state.memory[offset]
            pc_delt = 1
        case .LXI_B:
            pc_delt = lxi(&state.b, &state.c, state.memory[state.pc+1:state.pc+3])
        case .LXI_D:
            pc_delt = lxi(&state.d, &state.e, state.memory[state.pc+1:state.pc+3])
        case .LXI_H:
            pc_delt = lxi(&state.h, &state.l, state.memory[state.pc+1:state.pc+3])
        case .LXI_SP:
            data := getImmediate(state)
            state.sp = data
            pc_delt = 3
        case .MVI_B:
            pc_delt = mov(&state.b, &state.memory[state.pc+1]) + 1
        case .MVI_C:
            pc_delt = mov(&state.c, &state.memory[state.pc+1]) + 1
        case .MVI_D:
            pc_delt = mov(&state.d, &state.memory[state.pc+1]) + 1
        case .MVI_E:
            pc_delt = mov(&state.e, &state.memory[state.pc+1]) + 1
        case .MVI_H:
            pc_delt = mov(&state.h, &state.memory[state.pc+1]) + 1
        case .MVI_L:
            pc_delt = mov(&state.l, &state.memory[state.pc+1]) + 1
        case .MVI_M:
            setM(state.memory[state.pc+1], state)
            pc_delt = 2
        case .MVI_A:
            pc_delt = mov(&state.a, &state.memory[state.pc+1]) + 1
        case .STAX_B:
            pc_delt = stax(state.b, state.c, state)
        case .MOV_B_B:
            pc_delt = mov(&state.b, &state.b)
        case .MOV_B_C:
            pc_delt = mov(&state.b, &state.c)
        case .MOV_B_D:
            pc_delt = mov(&state.b, &state.d)
        case .MOV_B_E:
            pc_delt = mov(&state.b, &state.e)
        case .MOV_B_H:
            pc_delt = mov(&state.b, &state.h)
        case .MOV_B_L:
            pc_delt = mov(&state.b, &state.l)
        case .MOV_B_M:
            data := getM(state)
            pc_delt = mov(&state.b, &data)
        case .MOV_D_B:
            pc_delt = mov(&state.d, &state.b)
        case .MOV_D_C:
            pc_delt = mov(&state.d, &state.c)
        case .MOV_D_D:
            pc_delt = mov(&state.d, &state.d)
        case .MOV_D_E:
            pc_delt = mov(&state.d, &state.e)
        case .MOV_D_H:
            pc_delt = mov(&state.d, &state.h)
        case .MOV_D_L:
            pc_delt = mov(&state.d, &state.l)
        case .MOV_D_M:
            data := getM(state)
            pc_delt = mov(&state.d, &data)
        case .MOV_D_A:
            pc_delt = mov(&state.d, &state.a)
        case .MOV_E_B:
            pc_delt = mov(&state.e, &state.b)
        case .MOV_E_C:
            pc_delt = mov(&state.e, &state.c)
        case .MOV_E_D:
            pc_delt = mov(&state.e, &state.d)
        case .MOV_E_E:
            pc_delt = mov(&state.e, &state.e)
        case .MOV_E_H:
            pc_delt = mov(&state.e, &state.h)
        case .MOV_E_L:
            pc_delt = mov(&state.e, &state.l)
        case .MOV_E_M:
            data := getM(state)
            pc_delt = mov(&state.e, &data)
        case .MOV_E_A:
            pc_delt = mov(&state.e, &state.a)
        case .MOV_H_B:
            pc_delt = mov(&state.h, &state.b)
        case .MOV_H_C:
            pc_delt = mov(&state.h, &state.c)
        case .MOV_H_D:
            pc_delt = mov(&state.h, &state.d)
        case .MOV_H_E:
            pc_delt = mov(&state.h, &state.e)
        case .MOV_H_H:
            pc_delt = mov(&state.h, &state.h)
        case .MOV_H_L:
            pc_delt = mov(&state.h, &state.l)
        case .MOV_H_M:
            data := getM(state)
            pc_delt = mov(&state.h, &data)
        case .MOV_H_A:
            pc_delt = mov(&state.h, &state.a)
        case .MOV_L_B:
            pc_delt = mov(&state.l, &state.b)
        case .MOV_L_C:
            pc_delt = mov(&state.l, &state.c)
        case .MOV_L_D:
            pc_delt = mov(&state.l, &state.d)
        case .MOV_L_E:
            pc_delt = mov(&state.l, &state.e)
        case .MOV_L_H:
            pc_delt = mov(&state.l, &state.h)
        case .MOV_L_L:
            pc_delt = mov(&state.l, &state.l)
        case .MOV_L_M:
            data := getM(state)
            pc_delt = mov(&state.l, &data)
        case .MOV_L_A:
            pc_delt = mov(&state.l, &state.a)
        case .MOV_M_B:
            setM(state.b, state)
            pc_delt = 1
        case .MOV_M_C:
            setM(state.c, state)
            pc_delt = 1
        case .MOV_M_D:
            setM(state.d, state)
            pc_delt = 1
        case .MOV_M_E:
            setM(state.e, state)
            pc_delt = 1
        case .MOV_M_H:
            setM(state.h, state)
            pc_delt = 1
        case .MOV_M_L:
            setM(state.l, state)
            pc_delt = 1
        case .MOV_M_A:
            setM(state.a, state)
            pc_delt = 1
            //TODO: Should I rewrite getM to be able to do this.
            //Currently getM returns a copy of the data and not a pointer
            //data := getM(state)
            //pc_delt = mov(&data, &state.a)
        case .MOV_A_B:
            pc_delt = mov(&state.a, &state.b)
        case .MOV_A_C:
            pc_delt = mov(&state.a, &state.c)
        case .MOV_A_D:
            pc_delt = mov(&state.a, &state.d)
        case .MOV_A_E:
            pc_delt = mov(&state.a, &state.e)
        case .MOV_A_H:
            pc_delt = mov(&state.a, &state.h)
        case .MOV_A_L:
            pc_delt = mov(&state.a, &state.l)
        case .MOV_A_M:
            data := getM(state)
            pc_delt = mov(&state.a, &data)
        case .MOV_A_A:
            pc_delt = mov(&state.a, &state.a)
        case .ADD_A:
            pc_delt = add(state.a, state)
        case .ADD_B:
            pc_delt = add(state.b, state)
        case .ADD_C:
            pc_delt = add(state.c, state)
        case .ADD_M:
            data := getM(state)
            pc_delt = add(data, state)
        case .ADI:
            data := state.memory[state.pc+1]
            pc_delt = add(data, state)
            //Because reading a byte for the addition instead of using register
            pc_delt += 1
        case .STA:
            offset := getHL(state)
            state.memory[offset] = state.a
            pc_delt = 1
        case .SHLD:
            offset := getImmediate(state)
            state.memory[offset] = state.l
            state.memory[offset+1] = state.h
            pc_delt = 3
        case .JMP:
            pc_delt = jump(state, true)
        case .JC:
            pc_delt = jump(state, state.cc.cy)
        case .JNC:
            pc_delt = jump(state, !state.cc.cy)
        case .JNZ:
            pc_delt = jump(state, !state.cc.z)
        case .JZ:
            pc_delt = jump(state, state.cc.z)
        case .STC:
            state.cc.cy = true
            pc_delt = 1
        case .CMC:
            state.cc.cy = !state.cc.cy
        case .CALL:
            pc_delt = call(state, true)
        case .CC:
            pc_delt = call(state, state.cc.cy)
        case .CNC:
            pc_delt = call(state, !state.cc.cy)
        case .RET:
            pc_delt = ret(state, true)
        case .RNC:
            pc_delt = ret(state, !state.cc.cy)
        case .EI:
            state.int_enable = true
            pc_delt = 1
        case .DI:
            state.int_enable = false
            pc_delt = 1
        case .PUSH_B:
            pc_delt = pushR(state.b, state.c, state)
        case .PUSH_D:
            pc_delt = pushR(state.d, state.e, state)
        case .PUSH_H:
            pc_delt = pushR(state.h, state.l, state)
        case .PUSH_PSW:
            ccInt := conditionCodesToU8(&state.cc)
            pc_delt = pushR(state.a, ccInt, state)
        case .POP_B:
            pc_delt = popR(&state.b, &state.c, state)
        case .POP_D:
            pc_delt = popR(&state.d, &state.e, state)
        case .POP_H:
            pc_delt = popR(&state.h, &state.l, state)
        case .POP_PSW:
            ccInt : u8
            pc_delt = popR(&state.a, &ccInt, state)
            u8ToConditionCodes(ccInt, &state.cc)
        case .CPI:
            value := state.memory[state.pc+1]
            pc_delt = cmp(value, state) + 1
        case .DAD_B:
            //pc_delt = dad(state.b, state.c, state)
            pc_delt = dad(get_combined(state.b, state.c), state)
        case .DAD_D:
            //pc_delt = dad(state.d, state.e, state)
            pc_delt = dad(get_combined(state.d, state.e), state)
        case .DAD_H:
            //pc_delt = dad(state.h, state.l, state)
            pc_delt = dad(get_combined(state.h, state.l), state)
        case .DAD_SP:
            pc_delt = dad(state.sp, state)
        case .XCHG:
            state.h, state.d = state.d, state.h
            state.l, state.e = state.e, state.l
            pc_delt = 1
        case .RRC:
            bit := state.a & 0x1
            state.a = state.a >> 1
            state.cc.cy = bit != 0
            state.a = state.a | bit << 7
            pc_delt = 1
        case .OUT:
            pc_delt = 2
        case .IN:
            pc_delt = 2
        case:
            unimplementedInstruction(state)
    }

    state.pc += pc_delt
    
    printRegisters(state)
    printConditionCodes(&state.cc)
    fmt.printf("\n")


    return 1
}