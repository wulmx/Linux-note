package main

import "fmt"

type person struct {
	name string
}

/* has no reciever func */
func String_norec(p person) string {
	return "the person name is " + p.name
}

/* has reciver func, reciver is (p person) */
func (p person) String() string {
	return "the person name is " + p.name
}

/* value modify can't be modified*/
func (p person) modify() {
	p.name = "wulm"
}

/* pointer modify cat be modified */
func (p *person) modify_p() {
	p.name = "wuliming"
}

func main() {
	p := person{name: "wlm"}
	p.modify()
	fmt.Println(p.String())
	/* (&p).modify_p()  equal p.modify_p() */
	p.modify_p()
	//p1 := String_norec(p)
	fmt.Println(String_norec(p))
}
