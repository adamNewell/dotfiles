# Nvim TS Autotag

> Source: [windwp/nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag)

A plugin that automatically updates HTML/JSX tag pairs using treesitter.

## Features

- Automatic tag closing
- Tag pair updating
- Support for multiple languages
- Treesitter integration
- Fast and lightweight
- Works with JSX/TSX

## Supported Languages

- HTML
- JavaScript (JSX)
- TypeScript (TSX)
- PHP
- Vue
- Svelte
- XML
- Glimmer
- Handlebars
- Angular

## Functionality

1. Auto Close:
   ```html
   <div>|   ->   <div>|</div>
   ```

2. Auto Rename:
   ```html
   <div>|</div>   ->   <span>|</span>
   ```

3. Auto Delete:
   ```html
   <div>|</div>   ->   |
   ```

## Integration

The plugin integrates with:
- Treesitter for parsing
- LSP for language support
- Other editing plugins

## Benefits

1. Faster HTML/JSX Development:
   - No manual tag closing
   - Quick tag updates
   - Fewer typing errors
   - Improved productivity

2. Smart Features:
   - Context-aware updates
   - Language-specific behavior
   - Proper nesting support

## Tips

1. Works automatically in supported files
2. No configuration needed for basic usage
3. Respects complex JSX structures
4. Updates nested tags correctly
5. Maintains proper XML/HTML structure
