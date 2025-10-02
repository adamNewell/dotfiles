# Nvim TS Context Commentstring

> Source: [JoosepAlviste/nvim-ts-context-commentstring](https://github.com/JoosepAlviste/nvim-ts-context-commentstring)

A plugin that sets the commentstring option based on the cursor location in the file using treesitter.

## Features

- Context-aware commenting
- Support for embedded languages
- Treesitter integration
- Works with Comment.nvim
- Smart comment detection
- Multiple language support

## Use Cases

1. JSX/TSX Files:
   ```jsx
   function Component() {
     // JavaScript comment
     return (
       <div>
         {/* JSX comment */}
         <span>{/* Nested JSX comment */}</span>
       </div>
     );
   }
   ```

2. Vue Templates:
   ```vue
   <template>
     <!-- HTML comment -->
     <script>
       // JavaScript comment
     </script>
     <style>
       /* CSS comment */
     </style>
   </template>
   ```

## Supported Languages

- JavaScript/TypeScript
- JSX/TSX
- Vue
- Svelte
- PHP
- HTML
- CSS
- Embedded languages

## Integration

Works seamlessly with:
- Comment.nvim
- Other commenting plugins
- Treesitter
- LSP

## Benefits

1. Smart Commenting:
   - Correct comment style by context
   - Proper nested comments
   - Language-aware commenting
   - Improved code readability

2. Development Experience:
   - No manual comment style switching
   - Faster commenting workflow
   - Fewer syntax errors
   - Better maintainability

## Tips

1. Works automatically with Comment.nvim
2. Respects nested language contexts
3. No manual configuration needed
4. Improves commenting in complex files
5. Maintains proper comment syntax
