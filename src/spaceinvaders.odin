package spaceinvaders

import "core:fmt"
import "core:os"
import "core:io"

main :: proc() {
    source, success := os.read_entire_file_from_filename("rom/invaders.concatenated")
    state : State8080
    state.memory = make([]u8, 8192*8)
    state.sp = 0xf000
    copy(state.memory, source)

    fmt.println("Size of file:", len(source))
    fmt.println("Size of memory:", len(state.memory))
    count := 0
    for {
        fmt.printf("%08x ", count)
        emuluate8080p(&state)
        count += 1
        if count == 19470 do break
    }

}