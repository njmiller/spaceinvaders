package spaceinvaders

import "core:fmt"
import "core:os"
import "core:io"
import "core:time"

import rl "vendor:raylib"

DEBUG :: ODIN_DEBUG

//SCREEN_WIDTH :: 800
//SCREEN_HEIGHT :: 450

//SCREEN_WIDTH :: 256
//SCREEN_HEIGHT :: 224
SCREEN_WIDTH :: 222
SCREEN_HEIGHT :: 256

updateDisplay :: proc(data: []u8, scale: int) {

    pix_x : i32 = 0
    pix_y : i32 = 0

    //fmt.println("DATA:", data)

    bit : u8
    for i in 0..<7168 {
        for j in 0..<8 {
            //bit = data[i] & (1 << uint(j))
            bit = data[i] & (128 >> uint(j))
            if bit != 0 {
                rl.DrawPixel(pix_x, pix_y, rl.WHITE)
            } else {
                rl.DrawPixel(pix_x, pix_y, rl.BLACK)
            }

            pix_y += 1
            if pix_y == SCREEN_HEIGHT {
                pix_y = 0
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

main :: proc() {
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Space Invaders")
    defer rl.CloseWindow()

    rl.SetTargetFPS(60)

    source, success := os.read_entire_file_from_filename("rom/invaders.concatenated")
    state : State8080
    state.memory = make([]u8, 8192*8)
    state.sp = 0xf000
    copy(state.memory, source)

    vram := state.memory[0x2400:0x4000]

    for i in 0..<100 {
        vram[i] = 0xff
    }

    image : rl.Image
    image.width = SCREEN_WIDTH
    image.height = SCREEN_HEIGHT
    
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

        when DEBUG {
            count += 1
            fmt.printf("%v ", count)
        }
        emuluate8080p(&state)

        if time.duration_seconds(time.since(t_interrupt)) > 1.0/60.0 {
            if state.int_enable {
                //generateInterrupt(&state, 2)
                rst(&state, 2)

                t_interrupt = time.now()
            }
        }
        
    }

    fmt.println("VRAM:", state.memory[0x2400], state.memory[0x2401], state.memory[0x2402])

}