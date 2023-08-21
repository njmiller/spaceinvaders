package spaceinvaders

import "core:fmt"
import "core:math/bits"
import "core:os"

/*TODO: 1. Check for bit rotation stuff in core library for RRC, RLC, etc
        2. Use addition/subtraction stuff for carry in core.math.bits
        3. Put each switch statement case into its own separated function that returns pc_delt and ncycles
*/

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
    disassemble8080p(state.memory, state.pc)
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

sub :: proc(reg1: u8, state: ^State8080) -> int {
    result := u16(state.a) - u16(reg1)
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
    return 1
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
jump :: proc(state: ^State8080, cond: bool) -> (int, int) {
    //pc_delt := 3
    if !cond do return 3, 10
    //if cond {
    offset := getImmediate(state)
    state.pc = auto_cast offset
    //pc_delt = 0
    //}
    return 0, 10
}

mov :: proc(dest: ^u8, source: ^u8) -> int {
    dest^ = source^
    return 1
}

parity :: proc(value: u16, size: uint) -> bool {

    value2 : u16
    if size == 8 {
        value2 = value & 0xff
    } else {
        value2 = value
    }

    nbits := bits.count_ones(value2)
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

rst :: proc(state: ^State8080, num: int) -> int {
    high, low := getHighLow(u16(state.pc+1))
    //state.memory[state.sp - 1] = high
    //state.memory[state.sp - 2] = low
    //state.sp -= 2
    pushR(high, low, state)
    state.pc = 8*num

    return 0
}

call :: proc(state: ^State8080, cond: bool) -> (int, int) {

    if !cond do return 3, 11

    when CPU_DIAG {
        value := getImmediate(state)
        if 5 == value {
            if state.c == 9 {
                offset := getDE(state)
                idx := offset + 3
                for state.memory[idx] != '$' {
                //for i in 0..<50 {
                    fmt.printf("%c", state.memory[idx])
                    idx += 1
                }
                fmt.printf("\n")
                os.exit(10)
            } else if state.c == 2 { 
                fmt.printf("print char routine called\n")
            }
            return 3, 11
        } else if 0 == value {
            os.exit(20)
        }
    }

    retAddr := u16(state.pc) + 3
    state.memory[state.sp - 1] = get_high(retAddr)
    state.memory[state.sp - 2] = get_low(retAddr)
    state.sp -= 2
    state.pc = auto_cast getImmediate(state)
    return 0, 17
}

ret :: proc(state: ^State8080, cond: bool) -> (int, int) {

    if !cond do return 1, 11

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

    return 0, 11
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

@(private="file")
getHighLow :: proc(value: u16) -> (u8, u8) {
    high : u8 = auto_cast (value >> 8) & 0xff
    low : u8 = auto_cast value & 0xff

    return high, low
}

get_combined :: proc(high: u8, low: u8) -> u16 {
    return (u16(high) << 8) | u16(low)
}

setBC :: proc(state: ^State8080, value: u16) { state.b, state.c = getHighLow(value) }
setDE :: proc(state: ^State8080, value: u16) { state.d, state.e = getHighLow(value) }
setHL :: proc(state: ^State8080, value: u16) { state.h, state.l = getHighLow(value) }
setM :: proc(value: u8, state: ^State8080) { state.memory[getHL(state)] = value }

getBC :: proc(state: ^State8080) -> u16 { return get_combined(state.b, state.c) }
getDE :: proc(state: ^State8080) -> u16 { return get_combined(state.d, state.e) }
getHL :: proc(state: ^State8080) -> u16 { return get_combined(state.h, state.l) }
getM :: proc(state: ^State8080) -> u8 { return state.memory[getHL(state)] }


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

generateInterrupt :: proc(state: ^State8080, interrupt_num: int) {
    //high := get_high(u16(state.pc))
    //low := get_low(u16(state.pc))
    high, low := getHighLow(u16(state.pc))
    //fmt.println("INTERRUPT:", state.pc)
    pushR(high, low, state)
    state.pc = 8 * interrupt_num
    state.int_enable = false
}

emuluate8080p :: proc(state: ^State8080) -> int {
    opcode : OpCode = auto_cast state.memory[state.pc]
    pc_delt : int = 0
    ncycles : int = -1

    when DEBUG {
        disassemble8080p(state.memory, state.pc)
    }

    switch opcode {
        case .NOP, .NOP2, .NOP3, .NOP4, .NOP5, .NOP6, .NOP7, .NOP8, .NOP9, .NOP10, .NOP11, .NOP12, .NOP13:
            pc_delt = 1
            ncycles = 4
        case .ANA_B:
            pc_delt = ana(state.b, state)
            ncycles = 4
        case .ANA_C:
            pc_delt = ana(state.c, state)
            ncycles = 4
        case .ANA_D:
            pc_delt = ana(state.d, state)
            ncycles = 4
        case .ANA_E:
            pc_delt = ana(state.e, state)
            ncycles = 4
        case .ANA_H:
            pc_delt = ana(state.h, state)
            ncycles = 4
        case .ANA_L:
            pc_delt = ana(state.l, state)
            ncycles = 4
        case .ANA_M:
            value := getM(state)
            pc_delt = ana(value, state)
            ncycles = 7
        case .ANA_A:
            pc_delt = ana(state.a, state)
            ncycles = 4
        case .ANI:
            data := state.memory[state.pc+1]
            pc_delt = ana(data, state) + 1
            ncycles = 7
        case .XRA_B:
            pc_delt = xra(state.b, state)
            ncycles = 4
        case .XRA_C:
            pc_delt = xra(state.c, state)
            ncycles = 4
        case .XRA_D:
            pc_delt = xra(state.d, state)
            ncycles = 4
        case .XRA_E:
            pc_delt = xra(state.e, state)
            ncycles = 4
        case .XRA_H:
            pc_delt = xra(state.h, state)
            ncycles = 4
        case .XRA_L:
            pc_delt = xra(state.l, state)
            ncycles = 4
        case .XRA_M:
            value := getM(state)
            pc_delt = xra(value, state)
            ncycles = 7
        case .XRA_A:
            pc_delt = xra(state.a, state)
            ncycles = 4
        case .XRI:
            value := state.memory[state.pc+1]
            pc_delt = xra(value, state) + 1
            ncycles = 7
        case .ORA_B:
            pc_delt = ora(state.b, state)
            ncycles = 4
        case .ORA_C:
            pc_delt = ora(state.c, state)
            ncycles = 4
        case .ORA_D:
            pc_delt = ora(state.d, state)
            ncycles = 4
        case .ORA_E:
            pc_delt = ora(state.e, state)
            ncycles = 4
        case .ORA_H:
            pc_delt = ora(state.h, state)
            ncycles = 4
        case .ORA_L:
            pc_delt = ora(state.l, state)
            ncycles = 4
        case .ORA_M:
            value := getM(state)
            pc_delt = ora(value, state)
            ncycles = 7
        case .ORA_A:
            pc_delt = ora(state.a, state)
            ncycles = 4
        case .ORI:
            value := state.memory[state.pc+1]
            pc_delt = ora(value, state) + 1
            ncycles = 7
        case .INR_B:
            pc_delt = inr(&state.b, &state.cc)
            ncycles = 5
        case .INR_C:
            pc_delt = inr(&state.c, &state.cc)
            ncycles = 5
        case .INR_D:
            pc_delt = inr(&state.d, &state.cc)
            ncycles = 5
        case .INR_E:
            pc_delt = inr(&state.e, &state.cc)
            ncycles = 5
        case .INR_H:
            pc_delt = inr(&state.h, &state.cc)
            ncycles = 5
        case .INR_L:
            pc_delt = inr(&state.l, &state.cc)
            ncycles = 5
        case .INR_M:
            offset := getHL(state)
            pc_delt = inr(&state.memory[offset], &state.cc)
            ncycles = 10
        case .INR_A:
            pc_delt = inr(&state.a, &state.cc)
            ncycles = 5
        case .DCR_B:
            pc_delt = dcr(&state.b, &state.cc)
            ncycles = 5
        case .DCR_C:
            pc_delt = dcr(&state.c, &state.cc)
            ncycles = 5
        case .DCR_D:
            pc_delt = dcr(&state.d, &state.cc)
            ncycles = 5
        case .DCR_E:
            pc_delt = dcr(&state.e, &state.cc)
            ncycles = 5
        case .DCR_H:
            pc_delt = dcr(&state.h, &state.cc)
            ncycles = 5
        case .DCR_L:
            pc_delt = dcr(&state.l, &state.cc)
            ncycles = 5
        case .DCR_M:
            offset := getHL(state)
            pc_delt = dcr(&state.memory[offset], &state.cc)
            ncycles = 10
        case .DCR_A:
            pc_delt = dcr(&state.a, &state.cc)
            ncycles = 5
        case .DCX_B:
            pc_delt = dcx(&state.b, &state.c)
            ncycles = 5
        case .DCX_D:
            pc_delt = dcx(&state.d, &state.e)
            ncycles = 5
        case .DCX_H:
            pc_delt = dcx(&state.h, &state.l)
            ncycles = 5
        case .DCX_SP:
            state.sp -= 1
            pc_delt = 1
            ncycles = 5
        case .INX_B:
            pc_delt = inx(&state.b, &state.c)
            ncycles = 5
        case .INX_D:
            pc_delt = inx(&state.d, &state.e)
            ncycles = 5
        case .INX_H:
            pc_delt = inx(&state.h, &state.l)
            ncycles = 5
        case .INX_SP:
            state.sp += 1
            pc_delt = 1
            ncycles = 5
        case .LDAX_B:
            offset := getBC(state)
            state.a = state.memory[offset]
            pc_delt = 1
            ncycles = 7
        case .LDAX_D:
            offset := getDE(state)
            state.a = state.memory[offset]
            pc_delt = 1
            ncycles = 7
        case .LDA:
            offset := getImmediate(state)
            state.a = state.memory[offset]
            pc_delt = 3
            ncycles = 13
        case .LXI_B:
            pc_delt = lxi(&state.b, &state.c, state.memory[state.pc+1:state.pc+3])
            ncycles = 10
        case .LXI_D:
            pc_delt = lxi(&state.d, &state.e, state.memory[state.pc+1:state.pc+3])
            ncycles = 10
        case .LXI_H:
            pc_delt = lxi(&state.h, &state.l, state.memory[state.pc+1:state.pc+3])
            ncycles = 10
        case .LXI_SP:
            data := getImmediate(state)
            state.sp = data
            pc_delt = 3
            ncycles = 10
        case .MVI_B:
            pc_delt = mov(&state.b, &state.memory[state.pc+1]) + 1
            ncycles = 7
        case .MVI_C:
            pc_delt = mov(&state.c, &state.memory[state.pc+1]) + 1
            ncycles = 7
        case .MVI_D:
            pc_delt = mov(&state.d, &state.memory[state.pc+1]) + 1
            ncycles = 7
        case .MVI_E:
            pc_delt = mov(&state.e, &state.memory[state.pc+1]) + 1
            ncycles = 7
        case .MVI_H:
            pc_delt = mov(&state.h, &state.memory[state.pc+1]) + 1
            ncycles = 7
        case .MVI_L:
            pc_delt = mov(&state.l, &state.memory[state.pc+1]) + 1
            ncycles = 7
        case .MVI_M:
            setM(state.memory[state.pc+1], state)
            pc_delt = 2
            ncycles = 10
        case .MVI_A:
            pc_delt = mov(&state.a, &state.memory[state.pc+1]) + 1
            ncycles = 7
        case .STAX_B:
            pc_delt = stax(state.b, state.c, state)
            ncycles = 7
        case .STAX_D:
            pc_delt = stax(state.d, state.e, state)
            ncycles = 7
        case .STA:
            offset := getImmediate(state)
            state.memory[offset] = state.a
            pc_delt = 3
            ncycles = 13
        case .MOV_B_B:
            pc_delt = mov(&state.b, &state.b)
            ncycles = 5
        case .MOV_B_C:
            pc_delt = mov(&state.b, &state.c)
            ncycles = 5
        case .MOV_B_D:
            pc_delt = mov(&state.b, &state.d)
            ncycles = 5
        case .MOV_B_E:
            pc_delt = mov(&state.b, &state.e)
            ncycles = 5
        case .MOV_B_H:
            pc_delt = mov(&state.b, &state.h)
            ncycles = 5
        case .MOV_B_L:
            pc_delt = mov(&state.b, &state.l)
            ncycles = 5
        case .MOV_B_M:
            data := getM(state)
            pc_delt = mov(&state.b, &data)
            ncycles = 7
        case .MOV_B_A:
            pc_delt = mov(&state.b, &state.a)
            ncycles = 5
        case .MOV_C_B:
            pc_delt = mov(&state.c, &state.b)
            ncycles = 5
        case .MOV_C_C:
            pc_delt = mov(&state.c, &state.c)
            ncycles = 5
        case .MOV_C_D:
            pc_delt = mov(&state.c, &state.d)
            ncycles = 5
        case .MOV_C_E:
            pc_delt = mov(&state.c, &state.e)
            ncycles = 5
        case .MOV_C_H:
            pc_delt = mov(&state.c, &state.h)
            ncycles = 5
        case .MOV_C_L:
            pc_delt = mov(&state.c, &state.l)
            ncycles = 5
        case .MOV_C_M:
            data := getM(state)
            pc_delt = mov(&state.c, &data)
            ncycles = 7
        case .MOV_C_A:
            pc_delt = mov(&state.c, &state.a)
            ncycles = 5
        case .MOV_D_B:
            pc_delt = mov(&state.d, &state.b)
            ncycles = 5
        case .MOV_D_C:
            pc_delt = mov(&state.d, &state.c)
            ncycles = 5
        case .MOV_D_D:
            pc_delt = mov(&state.d, &state.d)
            ncycles = 5
        case .MOV_D_E:
            pc_delt = mov(&state.d, &state.e)
            ncycles = 5
        case .MOV_D_H:
            pc_delt = mov(&state.d, &state.h)
            ncycles = 5
        case .MOV_D_L:
            pc_delt = mov(&state.d, &state.l)
            ncycles = 5
        case .MOV_D_M:
            data := getM(state)
            pc_delt = mov(&state.d, &data)
            ncycles = 7
        case .MOV_D_A:
            pc_delt = mov(&state.d, &state.a)
            ncycles = 5
        case .MOV_E_B:
            pc_delt = mov(&state.e, &state.b)
            ncycles = 5
        case .MOV_E_C:
            pc_delt = mov(&state.e, &state.c)
            ncycles = 5
        case .MOV_E_D:
            pc_delt = mov(&state.e, &state.d)
            ncycles = 5
        case .MOV_E_E:
            pc_delt = mov(&state.e, &state.e)
            ncycles = 5
        case .MOV_E_H:
            pc_delt = mov(&state.e, &state.h)
            ncycles = 5
        case .MOV_E_L:
            pc_delt = mov(&state.e, &state.l)
            ncycles = 5
        case .MOV_E_M:
            data := getM(state)
            pc_delt = mov(&state.e, &data)
            ncycles = 7
        case .MOV_E_A:
            pc_delt = mov(&state.e, &state.a)
            ncycles = 5
        case .MOV_H_B:
            pc_delt = mov(&state.h, &state.b)
            ncycles = 5
        case .MOV_H_C:
            pc_delt = mov(&state.h, &state.c)
            ncycles = 5
        case .MOV_H_D:
            pc_delt = mov(&state.h, &state.d)
            ncycles = 5
        case .MOV_H_E:
            pc_delt = mov(&state.h, &state.e)
            ncycles = 5
        case .MOV_H_H:
            pc_delt = mov(&state.h, &state.h)
            ncycles = 5
        case .MOV_H_L:
            pc_delt = mov(&state.h, &state.l)
            ncycles = 5
        case .MOV_H_M:
            data := getM(state)
            pc_delt = mov(&state.h, &data)
            ncycles = 7
        case .MOV_H_A:
            pc_delt = mov(&state.h, &state.a)
            ncycles = 5
        case .MOV_L_B:
            pc_delt = mov(&state.l, &state.b)
            ncycles = 5
        case .MOV_L_C:
            pc_delt = mov(&state.l, &state.c)
            ncycles = 5
        case .MOV_L_D:
            pc_delt = mov(&state.l, &state.d)
            ncycles = 5
        case .MOV_L_E:
            pc_delt = mov(&state.l, &state.e)
            ncycles = 5
        case .MOV_L_H:
            pc_delt = mov(&state.l, &state.h)
            ncycles = 5
        case .MOV_L_L:
            pc_delt = mov(&state.l, &state.l)
            ncycles = 5
        case .MOV_L_M:
            data := getM(state)
            pc_delt = mov(&state.l, &data)
            ncycles = 7
        case .MOV_L_A:
            pc_delt = mov(&state.l, &state.a)
            ncycles = 5
        case .MOV_M_B:
            setM(state.b, state)
            pc_delt = 1
            ncycles = 7
        case .MOV_M_C:
            setM(state.c, state)
            pc_delt = 1
            ncycles = 7
        case .MOV_M_D:
            setM(state.d, state)
            pc_delt = 1
            ncycles = 7
        case .MOV_M_E:
            setM(state.e, state)
            pc_delt = 1
            ncycles = 7
        case .MOV_M_H:
            setM(state.h, state)
            pc_delt = 1
            ncycles = 7
        case .MOV_M_L:
            setM(state.l, state)
            pc_delt = 1
            ncycles = 7
        case .MOV_M_A:
            setM(state.a, state)
            pc_delt = 1
            ncycles = 7
            //TODO: Should I rewrite getM to be able to do this.
            //Currently getM returns a copy of the data and not a pointer
            //data := getM(state)
            //pc_delt = mov(&data, &state.a)
        case .MOV_A_B:
            pc_delt = mov(&state.a, &state.b)
            ncycles = 5
        case .MOV_A_C:
            pc_delt = mov(&state.a, &state.c)
            ncycles = 5
        case .MOV_A_D:
            pc_delt = mov(&state.a, &state.d)
            ncycles = 5
        case .MOV_A_E:
            pc_delt = mov(&state.a, &state.e)
            ncycles = 5
        case .MOV_A_H:
            pc_delt = mov(&state.a, &state.h)
            ncycles = 5
        case .MOV_A_L:
            pc_delt = mov(&state.a, &state.l)
            ncycles = 5
        case .MOV_A_M:
            data := getM(state)
            pc_delt = mov(&state.a, &data)
            ncycles = 7
        case .MOV_A_A:
            pc_delt = mov(&state.a, &state.a)
            ncycles = 5
        case .ADD_B:
            pc_delt = add(state.b, state)
            ncycles = 4
        case .ADD_C:
            pc_delt = add(state.c, state)
            ncycles = 4
        case .ADD_D:
            pc_delt = add(state.d, state)
            ncycles = 4
        case .ADD_E:
            pc_delt = add(state.e, state)
            ncycles = 4
        case .ADD_H:
            pc_delt = add(state.h, state)
            ncycles = 4
        case .ADD_L:
            pc_delt = add(state.l, state)
            ncycles = 4
        case .ADD_M:
            data := getM(state)
            pc_delt = add(data, state)
            ncycles = 7
        case .ADD_A:
            pc_delt = add(state.a, state)
            ncycles = 4
        case .ADC_B:
            pc_delt = add(state.b + u8(state.cc.cy), state)
            ncycles = 4
        case .ADC_C:
            pc_delt = add(state.c + u8(state.cc.cy), state)
            ncycles = 4
        case .ADC_D:
            pc_delt = add(state.d + u8(state.cc.cy), state)
            ncycles = 4
        case .ADC_E:
            pc_delt = add(state.e + u8(state.cc.cy), state)
            ncycles = 4
        case .ADC_H:
            pc_delt = add(state.h + u8(state.cc.cy), state)
            ncycles = 4
        case .ADC_L:
            pc_delt = add(state.l + u8(state.cc.cy), state)
            ncycles = 4
        case .ADC_M:
            value := getM(state) + u8(state.cc.cy)
            pc_delt = add(value, state)
            ncycles = 7
        case .ADC_A:
            pc_delt = add(state.a + u8(state.cc.cy), state)
            ncycles = 4
        case .ADI:
            data := state.memory[state.pc+1]
            pc_delt = add(data, state) + 1
            ncycles = 7
        case .ACI:
            data := state.memory[state.pc+1] + u8(state.cc.cy)
            pc_delt = add(data, state) + 1
            ncycles = 7
        case .SHLD:
            offset := getImmediate(state)
            state.memory[offset] = state.l
            state.memory[offset+1] = state.h
            pc_delt = 3
            ncycles = 16
        case .LHLD:
            offset := getImmediate(state)
            state.l = state.memory[offset]
            state.h = state.memory[offset+1]
            pc_delt = 3
            ncycles = 16
        case .JMP:
            pc_delt, ncycles = jump(state, true)
        case .JC:
            pc_delt, ncycles = jump(state, state.cc.cy)
        case .JNC:
            pc_delt, ncycles = jump(state, !state.cc.cy)
        case .JNZ:
            pc_delt, ncycles = jump(state, !state.cc.z)
        case .JZ:
            pc_delt, ncycles = jump(state, state.cc.z)
        case .JPE:
            pc_delt, ncycles = jump(state, state.cc.p)
        case .JPO:
            pc_delt, ncycles = jump(state, !state.cc.p)
        case .JP:
            pc_delt, ncycles = jump(state, !state.cc.s)
        case .JM:
            pc_delt, ncycles = jump(state, state.cc.s)
        case .STC:
            state.cc.cy = true
            pc_delt = 1
            ncycles = 4
        case .CMC:
            state.cc.cy = !state.cc.cy
            pc_delt = 1
            ncycles = 4
        case .CMA:
            state.a = ~state.a
            pc_delt = 1
            ncycles = 4
        case .CALL:
            pc_delt, ncycles = call(state, true)
        case .CC:
            pc_delt, ncycles = call(state, state.cc.cy)
        case .CNC:
            pc_delt, ncycles = call(state, !state.cc.cy)
        case .CNZ:
            pc_delt, ncycles = call(state, !state.cc.z)
        case .CZ:
            pc_delt, ncycles = call(state, state.cc.z)
        case .CPO:
            pc_delt, ncycles = call(state, !state.cc.p)
        case .CPE:
            pc_delt, ncycles = call(state, state.cc.p)
        case .CP:
            pc_delt, ncycles = call(state, !state.cc.s)
        case .CM:
            pc_delt, ncycles = call(state, state.cc.s)
        case .RET:
            pc_delt, ncycles= ret(state, true)
            ncycles = 10 //10 instead of 11 for RET compared to conditional returns
        case .RNC:
            pc_delt, ncycles = ret(state, !state.cc.cy)
        case .RC:
            pc_delt, ncycles = ret(state, state.cc.cy)
        case .RNZ:
            pc_delt, ncycles = ret(state, !state.cc.z)
        case .RZ:
            pc_delt, ncycles = ret(state, state.cc.z)
        case .RPE:
            pc_delt, ncycles = ret(state, state.cc.p)
        case .RPO:
            pc_delt, ncycles = ret(state, !state.cc.p)
        case .RP:
            pc_delt, ncycles = ret(state, !state.cc.s)
        case .RM:
            pc_delt, ncycles = ret(state, state.cc.s)
        case .EI:
            state.int_enable = true
            pc_delt = 1
            ncycles = 4
        case .DI:
            state.int_enable = false
            pc_delt = 1
            ncycles = 4
        case .PUSH_B:
            pc_delt = pushR(state.b, state.c, state)
            ncycles = 11
        case .PUSH_D:
            pc_delt = pushR(state.d, state.e, state)
            ncycles = 11
        case .PUSH_H:
            pc_delt = pushR(state.h, state.l, state)
            ncycles = 11
        case .PUSH_PSW:
            ccInt := conditionCodesToU8(&state.cc)
            pc_delt = pushR(state.a, ccInt, state)
            ncycles = 11
        case .POP_B:
            pc_delt = popR(&state.b, &state.c, state)
            ncycles = 10
        case .POP_D:
            pc_delt = popR(&state.d, &state.e, state)
            ncycles = 10
        case .POP_H:
            pc_delt = popR(&state.h, &state.l, state)
            ncycles = 10
        case .POP_PSW:
            ccInt : u8
            pc_delt = popR(&state.a, &ccInt, state)
            u8ToConditionCodes(ccInt, &state.cc)
            ncycles = 10
        case .CMP_B:
            pc_delt = cmp(state.b, state)
            ncycles = 4
        case .CMP_C:
            pc_delt = cmp(state.c, state)
            ncycles = 4
        case .CMP_D:
            pc_delt = cmp(state.d, state)
            ncycles = 4
        case .CMP_E:
            pc_delt = cmp(state.e, state)
            ncycles = 4
        case .CMP_H:
            pc_delt = cmp(state.h, state)
            ncycles = 4
        case .CMP_L:
            pc_delt = cmp(state.l, state)
            ncycles = 4
        case .CMP_M:
            value := getM(state)
            pc_delt = cmp(value, state)
            ncycles = 7
        case .CMP_A:
            pc_delt = cmp(state.a, state)
            ncycles = 4
        case .CPI:
            value := state.memory[state.pc+1]
            pc_delt = cmp(value, state) + 1
            ncycles = 7
        case .DAD_B:
            pc_delt = dad(get_combined(state.b, state.c), state)
            ncycles = 10
        case .DAD_D:
            pc_delt = dad(get_combined(state.d, state.e), state)
            ncycles = 10
        case .DAD_H:
            pc_delt = dad(get_combined(state.h, state.l), state)
            ncycles = 10
        case .DAD_SP:
            pc_delt = dad(state.sp, state)
            ncycles = 10
        case .XCHG:
            state.h, state.d = state.d, state.h
            state.l, state.e = state.e, state.l
            pc_delt = 1
            ncycles = 4
        case .XTHL:
            state.h, state.memory[state.sp+1] = state.memory[state.sp+1], state.h
            state.l, state.memory[state.sp] = state.memory[state.sp], state.l
            pc_delt = 1
            ncycles = 18
        case .SPHL:
            state.sp = getHL(state)
            pc_delt = 1
            ncycles = 5
        case .PCHL:
            state.pc = auto_cast getHL(state)
            pc_delt = 0
            ncycles = 5
        case .RRC:
            bit := state.a & 0x1
            state.a = state.a >> 1
            state.cc.cy = bit != 0
            state.a = state.a | bit << 7
            pc_delt = 1
            ncycles = 4
        case .RLC:
            bit := state.a & 128
            state.a = state.a << 1
            state.cc.cy = bit != 0
            state.a = state.a | bit >> 7
            pc_delt = 1
            ncycles = 4
        case .RAL:
            bit := state.a & 128
            state.a = state.a << 1 | u8(state.cc.cy)
            state.cc.cy = bit != 0
            pc_delt = 1
            ncycles = 4
        case .RAR:
            bit := state.a & 1
            state.a = state.a >> 1 | (u8(state.cc.cy) << 7)
            state.cc.cy = bit != 0
            pc_delt = 1
            ncycles = 4
        case .OUT:
            // This should be implemented by the machine and not the CPU
            machineOut(state, state.memory[state.pc+1])
            pc_delt = 2
            ncycles = 10
        case .IN:
            // This should be implemented by the machine and not the CPU
            machineIn(state, state.memory[state.pc+1])
            pc_delt = 2
            ncycles = 10
        case .RST_0:
            pc_delt = rst(state, 0)
            ncycles = 11
        case .RST_1:
            pc_delt = rst(state, 1)
            ncycles = 11
        case .RST_2:
            pc_delt = rst(state, 2)
            ncycles = 11
        case .RST_3:
            pc_delt = rst(state, 3)
            ncycles = 11
        case .RST_4:
            pc_delt = rst(state, 4)
            ncycles = 11
        case .RST_5:
            pc_delt = rst(state, 5)
            ncycles = 11
        case .RST_6:
            pc_delt = rst(state, 6)
            ncycles = 11
        case .RST_7:
            pc_delt = rst(state, 7)
            ncycles = 11
        case .SUB_B:
            pc_delt = sub(state.b, state)
            ncycles = 4
        case .SUB_C:
            pc_delt = sub(state.c, state)
            ncycles = 4
        case .SUB_D:
            pc_delt = sub(state.d, state)
            ncycles = 4
        case .SUB_E:
            pc_delt = sub(state.e, state)
            ncycles = 4
        case .SUB_H:
            pc_delt = sub(state.h, state)
            ncycles = 4
        case .SUB_L:
            pc_delt = sub(state.l, state)
            ncycles = 4
        case .SUB_M:
            value := getM(state)
            pc_delt = sub(value, state)
            ncycles = 7
        case .SUB_A:
            pc_delt = sub(state.a, state)
            ncycles = 4
        case .SBB_B:
            pc_delt = sub(state.b + u8(state.cc.cy), state)
            ncycles = 4
        case .SBB_C:
            pc_delt = sub(state.c + u8(state.cc.cy), state)
            ncycles = 4
        case .SBB_D:
            pc_delt = sub(state.d + u8(state.cc.cy), state)
            ncycles = 4
        case .SBB_E:
            pc_delt = sub(state.e + u8(state.cc.cy), state)
            ncycles = 4
        case .SBB_H:
            pc_delt = sub(state.h + u8(state.cc.cy), state)
            ncycles = 4
        case .SBB_L:
            pc_delt = sub(state.l + u8(state.cc.cy), state)
            ncycles = 4
        case .SBB_M:
            value := getM(state) + u8(state.cc.cy)
            pc_delt = sub(value, state)
            ncycles = 7
        case .SBB_A:
            pc_delt = sub(state.a + u8(state.cc.cy), state)
            ncycles = 4
        case .SUI:
            value := state.memory[state.pc+1]
            pc_delt = sub(value, state) + 1
            ncycles = 7
        case .SBI:
            value := state.memory[state.pc+1] + u8(state.cc.cy)
            pc_delt = sub(value, state) + 1
            ncycles = 7
        case .DAA:
            pc_delt = 1
            ncycles = 4
            //unimplementedInstruction(state)
        case .HLT:
            pc_delt = 1
            ncycles = 7
            //unimplementedInstruction(state)
    }

    if ncycles == -1 {
        fmt.printf("Ncycles not implemented for instruction.")
        disassemble8080p(state.memory, state.pc)
        os.exit(10)
    }

    state.pc += pc_delt

    when DEBUG {
        printRegisters(state)
        printConditionCodes(&state.cc)
        fmt.printf("\n")
    }

    return ncycles
}