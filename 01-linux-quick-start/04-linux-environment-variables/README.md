# Linux Environment Variables

## Table of Contents

- [Introduction](#introduction)
- [What Are Environment Variables?](#what-are-environment-variables)
- [Local vs. Exported Variables](#local-vs-exported-variables)
- [Examples in Action](#examples-in-action)
- [Best Practices](#best-practices)
- [Key Takeaways](#key-takeaways)
- [Conclusion](#conclusion)
- [References](#references)

## Introduction

Welcome! This guide is here to help you understand **environment variables** in Unix-like shells such as Zsh and Bash. If you've ever seen commands like `export PATH=...` or `VAR=value` in `.zshrc` or `.bashrc` and wondered what they do, you're in the right place.

## What Are Environment Variables?

Environment variables are **key-value pairs** stored in your shell session. They configure your system or software behavior. For example:

```bash
PATH=/usr/local/bin:/usr/bin:/bin
EDITOR=vim
AWS_REGION=eu-west-1
```

They are widely used to:
- Specify default programs
- Set credentials or regions (like for AWS)
- Point to config directories
- Configure build tools and scripts

## Local vs. Exported Variables

### Local Variable

A **local variable** exists **only in the current shell**. It is not visible to other programs or scripts.

```bash
GREETING="Hello"
echo $GREETING  # → Hello
bash -c 'echo $GREETING'  # → (empty)
```

### Exported Variable

An **exported variable** is an **environment variable**. It is passed to **child processes** (like new shells, programs, or scripts).

```bash
export GREETING="Hello"
echo $GREETING  # → Hello
bash -c 'echo $GREETING'  # → Hello
```

## Examples in Action

### Example 1: Defining a Local Variable

```bash
MY_VAR="local only"
echo $MY_VAR          # Works
bash -c 'echo $MY_VAR'  # Empty, not exported
```

### Example 2: Using `export` to Share a Variable

```bash
export MY_VAR="shared"
echo $MY_VAR            # Works
bash -c 'echo $MY_VAR'  # Also works ✅
```

### Example 3: Updating PATH to Include Your Scripts

```bash
export PATH="$HOME/my-tools:$PATH"
```

Now any executable in `~/my-tools` is available system-wide.

### Example 4: Viewing Your PATH Directories

To see all directories in your PATH variable in a readable format:

```bash
echo "$PATH" | tr ':' '\n'
```

This command:
1. Displays your PATH variable (`echo "$PATH"`)
2. Pipes the output to `tr` (translate)
3. Replaces each colon with a newline (`tr ':' '\n'`)

Example output:
```
/usr/local/bin
/usr/bin
/bin
/usr/sbin
/sbin
/usr/local/go/bin
/home/user/my-tools
```

This helps you verify which directories are in your PATH and in what order they're searched when you type a command.

## Best Practices

- **Always use `export`** when you want a variable accessible to scripts or tools
- **Define local variables without `export`** for one-time use in shell scripts
- **Use quotes** when setting values to handle spaces safely:

```bash
export MY_VAR="Hello World"
```

- Avoid overwriting critical variables like `PATH` unless you're sure
- **Use lowercase for local variables**, and **uppercase for exported vars** (convention)

## Key Takeaways

- `VAR=value` → Local to current shell
- `export VAR=value` → Inherited by all child processes
- Use `export` in `.zshrc` or `.bashrc` for variables you want available everywhere
- You can modify the `PATH` to add custom tools to your command line
- Properly scoped environment variables make your shell more powerful and maintainable

## Conclusion

Environment variables are a foundational part of the Unix shell environment. Knowing the difference between local and exported variables can save you hours of debugging and give you more control over how tools and scripts behave.

## References

- [How to Set an Environment Variable in Linux](https://www.freecodecamp.org/news/how-to-set-an-environment-variable-in-linux/)
- [GNU Bash Manual - Environment](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html)
- [Zsh Documentation](https://zsh.sourceforge.io/Doc/)
- [ShellCheck - A shell script linter](https://www.shellcheck.net/)
- [Stack Overflow - Environment Variables in Bash](https://stackoverflow.com/questions/192319/how-do-i-set-environment-variables-from-a-shell-script)

