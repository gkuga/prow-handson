package main

import (
	"strconv"
	"testing"
)

func TestHello(t *testing.T) {
	var tests = []struct {
		input  string
		output string
		result bool
	}{
		{"Prow", "Hello, Prow!", true},
		{"Jenkins", "Hello, Jenkins X!", true},
		{"Jenkins", "Hello, Jenkins!", false},
	}

	for _, test := range tests {
		output := Hello(test.input)
		result := output == test.output
		if result != test.result {
			t.Errorf("Test Failed: input '%s', output '%s', result '%s',  returnd '%s'\n",
				test.input, test.output, strconv.FormatBool(test.result), output)
		}
	}
}
