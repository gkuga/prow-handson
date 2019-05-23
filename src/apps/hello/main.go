package main

import (
	"fmt"
)

func Hello(name string) (greeting string) {
	if name == "Jenkins" {
		return "Hello, Jenkins X!"
	}
	return "Hello, " + name + "!"
}

func main() {
	greeting := Hello("Prooooooooooooooooow")
	fmt.Println(greeting)
}
