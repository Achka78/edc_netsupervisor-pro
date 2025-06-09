module.exports = {
  presets: [
    [
      '@babel/preset-env',
      {
        targets: {
          node: '18',
          browsers: [
            '>0.2%',
            'not dead',
            'not ie <= 11',
            'not op_mini all'
          ]
        },
        useBuiltIns: 'usage',
        corejs: 3,
        modules: false
      }
    ],
    [
      '@babel/preset-react',
      {
        runtime: 'automatic',
        development: process.env.NODE_ENV === 'development'
      }
    ]
  ],
  plugins: [
    '@babel/plugin-proposal-class-properties',
    '@babel/plugin-proposal-private-methods',
    '@babel/plugin-proposal-private-property-in-object',
    '@babel/plugin-syntax-dynamic-import',
    [
      '@babel/plugin-transform-runtime',
      {
        corejs: false,
        helpers: true,
        regenerator: true,
        useESModules: false
      }
    ]
  ],
  env: {
    development: {
      plugins: [
        'react-refresh/babel'
      ]
    },
    test: {
      presets: [
        [
          '@babel/preset-env',
          {
            targets: {
              node: 'current'
            },
            modules: 'commonjs'
          }
        ],
        [
          '@babel/preset-react',
          {
            runtime: 'automatic'
          }
        ]
      ],
      plugins: [
        '@babel/plugin-transform-modules-commonjs',
        'dynamic-import-node'
      ]
    },
    production: {
      plugins: [
        '@babel/plugin-transform-react-constant-elements',
        '@babel/plugin-transform-react-inline-elements',
        [
          'transform-remove-console',
          {
            exclude: ['error', 'warn']
          }
        ]
      ]
    }
  }
};