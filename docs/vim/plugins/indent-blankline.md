# Indent Blankline

> Source: [lukas-reineke/indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim)

A plugin that adds indentation guides to Neovim.

## Features

- Indentation guides for code blocks
- Custom indent character (┊)
- Support for multiple indentation levels
- Works with all file types
- Minimal and fast
- Configurable appearance

## Configuration

The plugin is configured with the following settings:

```lua
{
  indent = {
    char = "┊"  -- Character used for indent lines
  }
}
```

## Visual Guide

Example of how indentation is displayed:

```
function example() {
┊   if (condition) {
┊   ┊   doSomething();
┊   ┊   if (nested) {
┊   ┊   ┊   moreActions();
┊   ┊   }
┊   }
}
```

## Tips

1. Indentation guides make code structure more visible
2. Helps identify nesting levels in complex code
3. Makes it easier to spot indentation errors
4. Works well with both spaces and tabs
5. Improves code readability without being intrusive
