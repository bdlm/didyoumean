package main

import (
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"strconv"
	"strings"
)

func main() {
	var err error
	var msg string
	var cmdStatus int

	if 1 == len(os.Args) {
		help(os.Args[0])
	}
	args := os.Args[1:]

	// try the command, capture output
	var stdout bytes.Buffer
	var stderr bytes.Buffer
	cmd := exec.Command(args[0], args[1:]...)
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	err = cmd.Run()
	cmdStatus = handleErr(err, 0)
	msg = stdout.String()
	msg = msg + stderr.String()

	// check the output for keywords
	if strings.Contains(msg, "Did you mean") || strings.Contains(msg, "The most similar command") {

		// Create menu and options, capture input.
		menu, opts := fmtMsg(msg, args)
		fmt.Print(menu)
		var input string
		fmt.Scanln(&input)

		// Validate input, select option if any.
		opt := ""
		if len(opts) > 1 {
			if optn, err := strconv.ParseInt(input, 10, 0); nil == err {
				if optn > 0 {
					opt = opts[optn-1]
				}
			} else {
				opt = opts[0]
			}
		} else if "y" == strings.ToLower(input) || "" == input {
			opt = opts[0]
		}

		// Execute selected option, print output.
		if "" != opt {
			args[1] = opt
			fmt.Printf("executing %s...\n\n", strings.Join(args, " "))

			cmd := exec.Command(args[0], args[1:]...)
			var stdout bytes.Buffer
			var stderr bytes.Buffer
			cmd.Stdout = &stdout
			cmd.Stderr = &stderr

			err = cmd.Run()
			cmdStatus = handleErr(err, 0)
			msg = stdout.String()
			msg = msg + stderr.String()
		} else {
			msg = ""
		}
	}

	fmt.Print(msg)
	os.Exit(cmdStatus)
}

func fmtMsg(msg string, args []string) (string, []string) {
	lines := []string{}
	opts := []string{}
	preposition := ""
	prompt := ""
	for _, line := range strings.Split(msg, "\n") {
		if strings.Contains(line, "Did you mean") || strings.Contains(line, "The most similar") {
			lines = append(lines, "    Did you mean %s?\n%s\n%s")
		} else if strings.HasPrefix(line, "\t") || strings.HasPrefix(line, "        ") {
			opts = append(opts, strings.Trim(line, " \t"))
		}
	}

	if 1 == len(opts) {
		preposition = "this"
		prompt = "\n[Y/n] > "
	} else {
		preposition = "one of these"
		prompt = `
        0: quit

[1] > `
	}

	optlines := []string{}
	for optn, opt := range opts {
		optlines = append(optlines, fmt.Sprintf("        %d: %s", optn+1, opt))
	}
	return fmt.Sprintf(strings.Join(lines, "\n"),
		preposition,
		strings.Join(optlines, "\n"),
		prompt,
	), opts
}

func handleErr(err error, status int) int {
	if nil != err {
		if exiterr, ok := err.(*exec.ExitError); ok {
			return exiterr.ExitCode()
		}
		fmt.Fprintln(os.Stderr, err)
		if 0 != status {
			os.Exit(status)
		}
	}
	return 0
}

func help(name string) {
	fmt.Println("this is help text")
}
