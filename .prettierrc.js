module.exports = {
  // Basic formatting
  printWidth: 120,
  tabWidth: 2,
  useTabs: false,
  semi: true,
  singleQuote: true,
  quoteProps: 'as-needed',
  
  // JavaScript/TypeScript specific
  jsxSingleQuote: false,
  trailingComma: 'es5',
  bracketSpacing: true,
  bracketSameLine: false,
  arrowParens: 'avoid',
  
  // Line endings
  endOfLine: 'lf',
  
  // File specific overrides
  overrides: [
    {
      files: '*.json',
      options: {
        printWidth: 80,
        tabWidth: 2,
      },
    },
    {
      files: '*.md',
      options: {
        printWidth: 80,
        proseWrap: 'always',
        tabWidth: 2,
      },
    },
    {
      files: '*.{yaml,yml}',
      options: {
        printWidth: 80,
        tabWidth: 2,
        singleQuote: false,
      },
    },
    {
      files: '*.{css,scss,less}',
      options: {
        printWidth: 100,
        singleQuote: false,
      },
    },
    {
      files: '*.{js,jsx,ts,tsx}',
      options: {
        printWidth: 120,
        singleQuote: true,
        trailingComma: 'es5',
        bracketSpacing: true,
        bracketSameLine: false,
        arrowParens: 'avoid',
      },
    },
    {
      files: 'package.json',
      options: {
        printWidth: 80,
        tabWidth: 2,
        useTabs: false,
      },
    },
  ],
};