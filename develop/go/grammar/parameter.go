package main

import "fmt"

func main() {
	print("1","2","3")
}

/* changeable multi parameters */
func print (a ...interface{}){
	for _,v:=range a{
		fmt.Print(v)
	}
	fmt.Println()
}
