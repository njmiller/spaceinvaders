package spaceinvaders

import "core:fmt"
import "core:os"
import "core:io"

main :: proc() {
    source, success := os.read_entire_file_from_filename("rom/invaders.concatenated")
    state : State8080
    state.memory = make([]u8, 8192*8)
    lens := len(source)
    
    copy(state.memory, source)
    //state.memory[0:lens] = source
    //state.a = 0
    //state.sp = 0
    //state.pc = 0
    //state.b = 0

    fmt.println("Size of file:", len(source))
    fmt.println("Size of memory:", len(state.memory))
    for {
        emuluate8080p(&state)
    }
    /*
    source, success := os.read_entire_file_from_filename("rom/invaders.h")
    pc := 0
    for count := 0; count < 20; count += 1 {
        i := disassemble8080p(source, pc)
        pc += i
    }
    */
}