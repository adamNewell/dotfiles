# Comment.nvim

> Source: [numToStr/Comment.nvim](https://github.com/numToStr/Comment.nvim)

A plugin for smart commenting that supports multiple languages and complex commenting rules.

## Features

- Smart comment line/block detection
- Support for multiple languages
- Context-aware commenting
- Supports dot-repeat
- Supports count/motions
- Supports block comments
- Integration with ts-context-commentstring for JSX/TSX

## Key Bindings

### Normal Mode
- `gcc` - Toggle line comment
- `gbc` - Toggle block comment
- `gc{motion}` - Toggle line comment with motion
- `gb{motion}` - Toggle block comment with motion

### Visual Mode
- `gc` - Toggle line comment for selection
- `gb` - Toggle block comment for selection

## Examples

1. Line Comments:
   ```
   // This is a line comment
   # Python comment
   -- Lua comment
   ```

2. Block Comments:
   ```
   /* This is a
      block comment */
   """ Python
       block comment """
   --[[ Lua
        block comment ]]
   ```

## Tips

1. Use with motions: `gcip` to comment inner paragraph
2. Use with counts: `3gcc` to comment 3 lines
3. Works with complex files like JSX/TSX
4. Automatically uses correct comment style for file type
5. Can be used with dot-repeat for multiple comments
