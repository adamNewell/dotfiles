# Nvim Autopairs

> Source: [windwp/nvim-autopairs](https://github.com/windwp/nvim-autopairs)

A plugin that automatically pairs brackets, parentheses, quotes, and other delimiters.

## Features

- Automatic pairing of brackets, quotes, etc.
- Smart pairing based on file type
- Integration with nvim-cmp for completion
- Support for multiple cursor
- Fast pair deletion
- Custom rules support
- Treesitter integration

## Supported Pairs

Default pairs that are automatically completed:
- `()` - Parentheses
- `[]` - Square brackets
- `{}` - Curly braces
- `""` - Double quotes
- `''` - Single quotes
- ``` `` ``` - Backticks
- `<>` - Angle brackets (in supported filetypes)

## Behavior Examples

1. Auto Closing:
   ```
   Input: (
   Result: ()
   ```

2. Skip Closing:
   ```
   Input: (|) (where | is cursor)
   Typing ): Moves cursor past )
   ```

3. Delete Pairs:
   ```
   Input: (|)
   Backspace: Removes both ( and )
   ```

## Integration with nvim-cmp

The plugin integrates with nvim-cmp to provide smart pairing during completion:
- Automatically adds closing pairs after completion
- Respects completion item's textEdit
- Works with snippets

## Tips

1. Works seamlessly with quotes inside comments
2. Respects treesitter syntax for smart pairing
3. Can be customized per filetype
4. Automatically skips over closing characters
5. Fast and lightweight implementation 