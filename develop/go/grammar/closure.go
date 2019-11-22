package main

import "fmt"

func closure(x int) func(int) int {
    fmt.Println("%p\n", &x)
    return func (y int) int {

        fmt.Println("%p\n", &x)
        fmt.Println(x)
        fmt.Println(y)
    
        return x + y
    }
}

func main() {
  f := closure(10);
  fmt.Println(f(1))
  fmt.Println(f(2))
}
