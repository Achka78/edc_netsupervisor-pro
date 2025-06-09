module.exports = {
  // Test environment
  testEnvironment: 'node',
  
  // Roots
  roots: ['<rootDir>/server', '<rootDir>/client/src'],
  
  // Test patterns
  testMatch: [
    '**/__tests__/**/*.{js,jsx,ts,tsx}',
    '**/*.(test|spec).{js,jsx,ts,tsx}'
  ],
  
  // Transform files
  transform: {
    '^.+\\.(js|jsx|ts|tsx)$': 'babel-jest',
    '^.+\\.css$': 'jest-transform-css'
  },
  
  // Module name mapping
  moduleNameMapping: {
    '^@/(.*)$': '<rootDir>/client/src/$1',
    '^@server/(.*)$': '<rootDir>/server/$1',
    '\\.(css|less|scss|sass)$': 'identity-obj-proxy'
  },
  
  // Setup files
  setupFilesAfterEnv: [
    '<rootDir>/jest.setup.js'
  ],
  
  // Coverage configuration
  collectCoverage: true,
  collectCoverageFrom: [
    'server/**/*.{js,jsx}',
    'client/src/**/*.{js,jsx}',
    '!server/server.js',
    '!server/tests/**',
    '!client/src/index.js',
    '!client/src/serviceWorker.js',
    '!client/src/**/*.test.{js,jsx}',
    '!**/node_modules/**',
    '!**/coverage/**'
  ],
  
  coverageReporters: [
    'text',
    'lcov',
    'html',
    'json-summary'
  ],
  
  coverageDirectory: 'coverage',
  
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70
    },
    './server/routes/': {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    },
    './server/services/': {
      branches: 75,
      functions: 75,
      lines: 75,
      statements: 75
    },
    './client/src/components/': {
      branches: 75,
      functions: 75,
      lines: 75,
      statements: 75
    }
  },
  
  // Test timeout
  testTimeout: 30000,
  
  // Ignore patterns
  testPathIgnorePatterns: [
    '/node_modules/',
    '/build/',
    '/dist/',
    '/coverage/'
  ],
  
  // Module file extensions
  moduleFileExtensions: [
    'js',
    'jsx',
    'ts',
    'tsx',
    'json'
  ],
  
  // Clear mocks between tests
  clearMocks: true,
  
  // Verbose output
  verbose: true,
  
  // Projects for multi-environment testing
  projects: [
    {
      displayName: 'server',
      testEnvironment: 'node',
      testMatch: ['<rootDir>/server/**/*.test.js'],
      setupFilesAfterEnv: ['<rootDir>/jest.setup.server.js']
    },
    {
      displayName: 'client',
      testEnvironment: 'jsdom',
      testMatch: ['<rootDir>/client/src/**/*.test.{js,jsx}'],
      setupFilesAfterEnv: ['<rootDir>/jest.setup.client.js'],
      moduleNameMapping: {
        '\\.(css|less|scss|sass)$': 'identity-obj-proxy',
        '\\.(jpg|jpeg|png|gif|svg)$': '<rootDir>/client/src/__mocks__/fileMock.js'
      }
    }
  ],
  
  // Global variables
  globals: {
    'ts-jest': {
      useESM: true
    }
  },
  
  // ESM support
  extensionsToTreatAsEsm: ['.jsx', '.tsx'],
  
  // Test results processor
  testResultsProcessor: 'jest-sonar-reporter',
  
  // Watch plugins
  watchPlugins: [
    'jest-watch-typeahead/filename',
    'jest-watch-typeahead/testname'
  ],
  
  // Error handling
  errorOnDeprecated: true,
  
  // Performance
  maxWorkers: '50%',
  
  // Bail configuration
  bail: false,
  
  // Cache
  cache: true,
  cacheDirectory: '<rootDir>/.jest-cache',
  
  // Notify
  notify: false,
  
  // Reporter configuration
  reporters: [
    'default',
    [
      'jest-html-reporters',
      {
        publicPath: './coverage/html-report',
        filename: 'report.html',
        expand: true
      }
    ],
    [
      'jest-junit',
      {
        outputDirectory: './coverage',
        outputName: 'junit.xml'
      }
    ]
  ]
};