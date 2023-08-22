package spaceinvaders

import "core:fmt"
import "core:os"
import "core:io"
import "core:time"
import "core:math"

import rl "vendor:raylib"

DEBUG :: ODIN_DEBUG
CPU_DIAG :: #config(cpu_diag, false)

SCREEN_WIDTH :: 222
SCREEN_HEIGHT :: 256

TIC :: 1000.0 / 60.0  // Milliseconds per tic (screen update)
CYCLES_PER_MS :: 2000  // 8080 runs at 2 Mhz
CYCLES_PER_TIC : f64 : CYCLES_PER_MS * TIC

Shift :: struct {
    register : u16,
    offset : uint
}

SpaceInvadersMachine :: struct {
    shift : Shift,
    ports : [8]u8,
    state : State8080,
}

// Variables to store information about the hardware specific ports read/written during
// machineIn and machineOut
shift : Shift
ports : [8]u8

updateDisplay :: proc(data: []u8, scale: int) {

    pix_x : i32 = 0
    pix_y : i32 = SCREEN_HEIGHT - 1

    bit : u8
    for i in 0..<7168 {
        for j in 0..<8 {
            bit = data[i] & (1 << uint(j))
            if bit != 0 {
                rl.DrawPixel(pix_x, pix_y, rl.WHITE)
            } else {
                rl.DrawPixel(pix_x, pix_y, rl.BLACK)
            }

            pix_y -= 1
            if pix_y < 0 {
                pix_y = SCREEN_HEIGHT - 1
                pix_x += 1
            }
        }
        
    }
}

machineIn :: proc(state: ^State8080, port: u8) {
    //fmt.println("MACHINE IN:", port)
    switch port {
        case 3:
            state.a = auto_cast (shift.register >> (8 - shift.offset)) & 0xff
            //fmt.println("SHIFT:", shift.offset, shift.register)
        case:
            state.a = ports[port]
    }
}

machineOut :: proc(state: ^State8080, port: u8) {
    //fmt.println("MACHINE OUT:", port)
    switch port {
        case 2:
            shift.offset = auto_cast state.a & 0x7
            //fmt.println("SHIFT OFFSET OUT:", shift.offset)
        case 4:
            shift.register = (u16(state.a) << 8) | (shift.register >> 8)
            //fmt.println("SHIFT REGISTER OUT:", shift.register)
        case:
            ports[port] = state.a            
    }
}

handleInput :: proc() {

    // Insert coin
    if rl.IsKeyPressed(rl.KeyboardKey.C) do ports[1] |= 1

    // 1P start/movement
    if rl.IsKeyPressed(rl.KeyboardKey.A) do ports[1] |= 1 << 5
    if rl.IsKeyPressed(rl.KeyboardKey.D) do ports[1] |= 1 << 6
    if rl.IsKeyPressed(rl.KeyboardKey.S) do ports[1] |= 1 << 2
    if rl.IsKeyPressed(rl.KeyboardKey.W) do ports[1] |= 1 << 4

    // 2P start/movement
    if rl.IsKeyPressed(rl.KeyboardKey.LEFT) do ports[2] |= 1 << 5
    if rl.IsKeyPressed(rl.KeyboardKey.RIGHT) do ports[2] |= 1 << 6
    if rl.IsKeyPressed(rl.KeyboardKey.ENTER) do ports[1] |= 1 << 1
    if rl.IsKeyPressed(rl.KeyboardKey.UP) do ports[2] |= 1 << 4

    // When keys are releases, undo everything
    if rl.IsKeyReleased(rl.KeyboardKey.C) do ports[1] &~= 1

    if rl.IsKeyReleased(rl.KeyboardKey.A) do ports[1] &~= 1 << 5
    if rl.IsKeyReleased(rl.KeyboardKey.D) do ports[1] &~= 1 << 6
    if rl.IsKeyReleased(rl.KeyboardKey.S) do ports[1] &~= 1 << 2
    if rl.IsKeyReleased(rl.KeyboardKey.W) do ports[1] &~= 1 << 4

    if rl.IsKeyReleased(rl.KeyboardKey.LEFT) do ports[2] &~= 1 << 5
    if rl.IsKeyReleased(rl.KeyboardKey.RIGHT) do ports[2] &~= 1 << 6
    if rl.IsKeyReleased(rl.KeyboardKey.ENTER) do ports[1] &~= 1 << 1
    if rl.IsKeyReleased(rl.KeyboardKey.UP) do ports[2] &~= 1 << 4

}

generateInterrupt :: proc(state: ^State8080, interruptNum: int) {
    high, low := getHighLow(u16(state.pc))
    pushR(high, low, state)
    state.pc = 8 * interruptNum
    state.int_enable = false
}

runCycles :: proc(state: ^State8080, ncycles: int) {
    tot_cycles := 0
    cycle_opcode : int

    for tot_cycles < ncycles {

        when DEBUG {
            //count += 1
            //fmt.printf("%v ", count)
        }

        cycle_opcode = emuluate8080p(state)

        /*
        opcode : OpCode = auto_cast hardware.state.memory[state.pc]
        if opcode == .IN {
            machineIn(hardware, hardware.state.memory[state.pc+1])
            hardware.state.pc += 2
            cycle_opcode = 10
        } else if opcode == .OUT {
            machineOut(hardware, hardware.state.memory[state.pc+1])
            hardware.state.pc += 2
            cycle_opcode = 10
        } else {
            cycle_opcode = emulate8080p(hardware.state)
        }
        */
        tot_cycles += cycle_opcode
    }

}

runSpaceInvaders :: proc() {
    //siMachine : SpaceInvadersMachine

    ports[0] = (1 << 1) | (1 << 2) | (1 << 3)
    ports[1] = 0
    ports[2] = (1 << 0) | (1 << 1)

    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Space Invaders")
    defer rl.CloseWindow()

    rl.SetTargetFPS(60)

    source, success := os.read_entire_file_from_filename("rom/invaders.concatenated")
    state : State8080
    state.memory = make([]u8, 8192*8)
    state.sp = 0xf000
    copy(state.memory, source)

    vram := state.memory[0x2400:0x4000]
    
    fmt.println("Size of file:", len(source))
    fmt.println("Size of memory:", len(state.memory))
    count := 0

    t_frame := time.now()
    t_since : f64

    //siMachine.ports = ports
    //siMachine.shift = shift
    //siMachine.state = state

    ncycles_half_tic : int = auto_cast math.floor(CYCLES_PER_TIC / 2)

    for !rl.WindowShouldClose() {
        t_since = time.duration_milliseconds(time.since(t_frame))

        if t_since > TIC {
            t_frame = time.now()

            // Update the display
            rl.BeginDrawing()
            rl.ClearBackground(rl.WHITE)
            updateDisplay(vram, 1)
            rl.EndDrawing()

            // Run half the cpu cycles in this tic
            runCycles(&state, ncycles_half_tic)

            // Generate mid frame interrupt
            if state.int_enable do generateInterrupt(&state, 1)

            // Run the rest of the cycles in this tic
            runCycles(&state, ncycles_half_tic)

            // Generate the end of frame interrupt
            if state.int_enable do generateInterrupt(&state, 2)

            handleInput()

        }

    }
}


run8080test :: proc() {
    source, success := os.read_entire_file_from_filename("test/cpudiag.bin")
    
    state : State8080
    state.memory = make([]u8, 8192*8)
    state.sp = 0xf000
    copy(state.memory[0x100:], source)

    // Fix first instruction to be jump to start of test
    state.memory[0] = 0xc3
    state.memory[1] = 0
    state.memory[2] = 0x01

    // Fix stack pointer
    state.memory[368] = 0x7

    // Skip the DAA test
    state.memory[0x59c] = 0xc3
    state.memory[0x59d] = 0xc2
    state.memory[0x59e] = 0x05

    for {
        emuluate8080p(&state)
    }
}

main :: proc() {

    when CPU_DIAG {
        run8080test()
    } else {
        runSpaceInvaders()
    }
}