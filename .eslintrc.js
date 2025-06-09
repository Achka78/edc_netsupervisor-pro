module.exports = {
  root: true,
  env: {
    node: true,
    browser: true,
    es2022: true,
    jest: true,
  },
  extends: [
    'eslint:recommended',
    '@eslint/js/recommended',
    'plugin:react/recommended',
    'plugin:react-hooks/recommended',
    'plugin:jsx-a11y/recommended',
    'plugin:import/recommended',
    'plugin:import/errors',
    'plugin:import/warnings',
    'plugin:security/recommended',
    'plugin:node/recommended',
    'plugin:promise/recommended',
  ],
  plugins: [
    'react',
    'react-hooks',
    'jsx-a11y',
    'import',
    'security',
    'node',
    'promise',
    'prettier',
  ],
  parserOptions: {
    ecmaVersion: 2022,
    sourceType: 'module',
    ecmaFeatures: {
      jsx: true,
    },
  },
  settings: {
    react: {
      version: 'detect',
    },
    'import/resolver': {
      node: {
        extensions: ['.js', '.jsx', '.ts', '.tsx'],
        paths: ['src'],
      },
      alias: {
        '@': './client/src',
        '@server': './server',
      },
    },
  },
  rules: {
    // General rules
    'no-console': ['warn', { allow: ['warn', 'error'] }],
    'no-debugger': 'error',
    'no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    'no-var': 'error',
    'prefer-const': 'error',
    'prefer-template': 'error',
    'template-curly-spacing': ['error', 'never'],
    'object-curly-spacing': ['error', 'always'],
    'array-bracket-spacing': ['error', 'never'],
    'computed-property-spacing': ['error', 'never'],
    'no-trailing-spaces': 'error',
    'eol-last': 'error',
    'comma-dangle': ['error', 'only-multiline'],
    'semi': ['error', 'always'],
    'quotes': ['error', 'single', { avoidEscape: true }],
    'indent': ['error', 2, { SwitchCase: 1 }],
    'max-len': ['warn', { code: 120, ignoreUrls: true, ignoreStrings: true }],
    'no-multiple-empty-lines': ['error', { max: 1, maxEOF: 0 }],
    'curly': ['error', 'all'],
    'brace-style': ['error', '1tbs'],
    'keyword-spacing': 'error',
    'space-before-blocks': 'error',
    'space-infix-ops': 'error',
    'no-multi-spaces': 'error',

    // Security rules
    'security/detect-object-injection': 'warn',
    'security/detect-non-literal-regexp': 'warn',
    'security/detect-unsafe-regex': 'error',
    'security/detect-buffer-noassert': 'error',
    'security/detect-child-process': 'warn',
    'security/detect-disable-mustache-escape': 'error',
    'security/detect-eval-with-expression': 'error',
    'security/detect-no-csrf-before-method-override': 'error',
    'security/detect-non-literal-fs-filename': 'warn',
    'security/detect-non-literal-require': 'warn',
    'security/detect-possible-timing-attacks': 'warn',
    'security/detect-pseudoRandomBytes': 'error',

    // Promise rules
    'promise/always-return': 'error',
    'promise/catch-or-return': 'error',
    'promise/no-callback-in-promise': 'warn',
    'promise/no-nesting': 'warn',
    'promise/no-promise-in-callback': 'warn',
    'promise/no-return-wrap': 'error',
    'promise/param-names': 'error',

    // Import rules
    'import/order': [
      'error',
      {
        groups: [
          'builtin',
          'external',
          'internal',
          'parent',
          'sibling',
          'index',
        ],
        'newlines-between': 'always',
        alphabetize: {
          order: 'asc',
          caseInsensitive: true,
        },
      },
    ],
    'import/no-unresolved': 'error',
    'import/no-duplicates': 'error',
    'import/no-unused-modules': 'warn',
    'import/no-extraneous-dependencies': [
      'error',
      {
        devDependencies: [
          '**/*.test.js',
          '**/*.test.jsx',
          '**/*.spec.js',
          '**/*.spec.jsx',
          '**/tests/**',
          '**/test/**',
          'jest.setup.js',
          'jest.config.js',
          '**/*.stories.js',
        ],
      },
    ],

    // React rules
    'react/prop-types': 'warn',
    'react/react-in-jsx-scope': 'off', // Not needed in React 17+
    'react/jsx-uses-react': 'off', // Not needed in React 17+
    'react/jsx-uses-vars': 'error',
    'react/jsx-no-unused-expressions': 'error',
    'react/jsx-curly-spacing': ['error', 'never'],
    'react/jsx-equals-spacing': ['error', 'never'],
    'react/jsx-indent': ['error', 2],
    'react/jsx-indent-props': ['error', 2],
    'react/jsx-max-props-per-line': ['warn', { maximum: 3 }],
    'react/jsx-no-duplicate-props': 'error',
    'react/jsx-no-undef': 'error',
    'react/jsx-pascal-case': 'error',
    'react/jsx-wrap-multilines': 'error',
    'react/no-array-index-key': 'warn',
    'react/no-danger': 'warn',
    'react/no-deprecated': 'error',
    'react/no-direct-mutation-state': 'error',
    'react/no-unescaped-entities': 'error',
    'react/no-unknown-property': 'error',
    'react/self-closing-comp': 'error',
    'react/sort-comp': 'warn',

    // React Hooks rules
    'react-hooks/rules-of-hooks': 'error',
    'react-hooks/exhaustive-deps': 'warn',

    // JSX Accessibility rules
    'jsx-a11y/alt-text': 'error',
    'jsx-a11y/anchor-has-content': 'error',
    'jsx-a11y/anchor-is-valid': 'error',
    'jsx-a11y/aria-activedescendant-has-tabindex': 'error',
    'jsx-a11y/aria-props': 'error',
    'jsx-a11y/aria-proptypes': 'error',
    'jsx-a11y/aria-role': 'error',
    'jsx-a11y/aria-unsupported-elements': 'error',
    'jsx-a11y/heading-has-content': 'error',
    'jsx-a11y/iframe-has-title': 'error',
    'jsx-a11y/img-redundant-alt': 'error',
    'jsx-a11y/no-access-key': 'error',
    'jsx-a11y/no-distracting-elements': 'error',
    'jsx-a11y/no-redundant-roles': 'error',
    'jsx-a11y/role-has-required-aria-props': 'error',
    'jsx-a11y/role-supports-aria-props': 'error',
    'jsx-a11y/scope': 'error',

    // Prettier integration
    'prettier/prettier': 'error',
  },
  overrides: [
    // Server-specific rules
    {
      files: ['server/**/*.js'],
      env: {
        browser: false,
        node: true,
      },
      rules: {
        'node/no-unpublished-require': 'off',
        'node/no-missing-require': 'error',
        'node/no-extraneous-require': 'error',
        'no-console': 'off', // Allow console in server
        'security/detect-non-literal-fs-filename': 'off', // Often needed in server
      },
    },
    // Client-specific rules
    {
      files: ['client/src/**/*.{js,jsx}'],
      env: {
        browser: true,
        node: false,
      },
      rules: {
        'node/no-unpublished-require': 'off',
        'node/no-missing-require': 'off',
        'node/no-unsupported-features/es-syntax': 'off',
      },
    },
    // Test files
    {
      files: [
        '**/*.test.js',
        '**/*.test.jsx',
        '**/*.spec.js',
        '**/*.spec.jsx',
        '**/tests/**/*.js',
        '**/test/**/*.js',
        'jest.setup.js',
        'jest.config.js',
      ],
      env: {
        jest: true,
      },
      rules: {
        'no-console': 'off',
        'security/detect-non-literal-fs-filename': 'off',
        'security/detect-child-process': 'off',
        'import/no-extraneous-dependencies': 'off',
        'node/no-unpublished-require': 'off',
        'max-len': ['warn', { code: 150 }],
      },
    },
    // Configuration files
    {
      files: [
        '*.config.js',
        '*.config.mjs',
        '.eslintrc.js',
        'webpack.config.js',
        'rollup.config.js',
        'vite.config.js',
      ],
      env: {
        node: true,
      },
      rules: {
        'no-console': 'off',
        'import/no-extraneous-dependencies': 'off',
        'node/no-unpublished-require': 'off',
      },
    },
    // Scripts
    {
      files: ['scripts/**/*.js'],
      env: {
        node: true,
      },
      rules: {
        'no-console': 'off',
        'security/detect-child-process': 'off',
        'security/detect-non-literal-fs-filename': 'off',
        'node/no-unpublished-require': 'off',
      },
    },
  ],
  ignorePatterns: [
    'node_modules/',
    'build/',
    'dist/',
    'coverage/',
    '*.min.js',
    'public/',
    '.next/',
    '.nuxt/',
    '.cache/',
    'client/build/',
    'server/uploads/',
    'backups/',
    'logs/',
  ],
};