package spaceinvaders

import "core:fmt"
import "core:os"
import "core:io"
import "core:time"

import rl "vendor:raylib"

DEBUG :: ODIN_DEBUG
CPU_DIAG :: #config(cpu_diag, false)

//SCREEN_WIDTH :: 800
//SCREEN_HEIGHT :: 450

//SCREEN_WIDTH :: 256
//SCREEN_HEIGHT :: 224
SCREEN_WIDTH :: 222
SCREEN_HEIGHT :: 256

Shift :: struct {
    register : u16,
    offset : uint
}

shift : Shift

updateDisplay :: proc(data: []u8, scale: int) {

    pix_x : i32 = 0
    pix_y : i32 = SCREEN_HEIGHT - 1

    //fmt.println("DATA:", data)

    bit : u8
    for i in 0..<7168 {
        for j in 0..<8 {
            bit = data[i] & (1 << uint(j))
            //bit = data[i] & (128 >> uint(j))
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
    /*
    color := rl.WHITE
    for i in 0..<SCREEN_WIDTH {
        if i % 10 == 0 {
            if color == rl.WHITE {
                color = rl.GREEN
            } else {
                color = rl.WHITE
            }
        }
        for j in 0..<SCREEN_HEIGHT {
            rl.DrawPixel(i32(i), i32(j), color)
        }
    }
    */
}

machineIn :: proc(state: ^State8080, port: u8) {
    fmt.println("MACHINE IN:", port)
    switch port {
        case 3:
            state.a = auto_cast (shift.register >> (8 - shift.offset)) & 0xff
    }
}

machineOut :: proc(state: ^State8080, port: u8) {
    fmt.println("MACHINE OUT:", port)
    switch port {
        case 2:
            shift.offset = auto_cast state.a & 0x7
        case 4:
            shift.register = (u16(state.a) << 8) | (shift.register >> 8)
    }
}

runSpaceInvaders :: proc() {
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

    t_display_updated := time.now()
    t_interrupt := time.now()

    for !rl.WindowShouldClose() {

        // Update the display at 60 Hz
        if time.duration_seconds(time.since(t_display_updated)) > 1.0/60.0 {
            rl.BeginDrawing()
            rl.ClearBackground(rl.WHITE)
            updateDisplay(vram, 1)
            rl.EndDrawing()
            t_display_updated = time.now()
        }

        count += 1
        when DEBUG {
            fmt.printf("%v ", count)
        }

        //opcode : OpCode = auto_cast state.memory[state.pc]
        //if opcode == .IN {
        //    port := state.memory[state.pc+1]
        //    machineIn(&state, port)
        //    state.pc += 2
        //} else if opcode == .OUT {
        //    port := state.memory[state.pc+1]
        //    machineOut(&state, port)
        //    state.pc += 2
        //} else {
        emuluate8080p(&state)
        //}

        if time.duration_seconds(time.since(t_interrupt)) > 1.0/30.0 {
            if state.int_enable {
                //generateInterrupt(&state, 2)
                rst(&state, 2)

                t_interrupt = time.now()
            }
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

    /*
    //Skip DAA test
    state.memory[0x59c] = 0xc3
    state.memory[0x59d] = 0xc2
    state.memory[0x59e] = 0x05
    */
}

main :: proc() {

    when CPU_DIAG {
        run8080test()
    } else {
        runSpaceInvaders()
    }
}