// Global Jest setup file
import 'jest-extended';

// Set up global test environment
global.console = {
  ...console,
  // uncomment to ignore a specific log level
  // log: jest.fn(),
  debug: jest.fn(),
  info: jest.fn(),
  warn: jest.fn(),
  error: jest.fn(),
};

// Mock global objects
global.TextEncoder = TextEncoder;
global.TextDecoder = TextDecoder;

// Set test timeout
jest.setTimeout(30000);

// Global test utilities
global.sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));

global.mockAsyncFunction = (returnValue, delay = 0) => {
  return jest.fn().mockImplementation(() => 
    new Promise(resolve => setTimeout(() => resolve(returnValue), delay))
  );
};

// Environment variables for testing
process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test-jwt-secret-key';
process.env.ENCRYPTION_KEY = 'test-encryption-key-32-characters';
process.env.ENCRYPTION_IV = 'test-iv-16-chars';
process.env.MONGODB_URI = 'mongodb://localhost:27017/networkmanager_test';

// Suppress specific warnings in tests
const originalConsoleWarn = console.warn;
console.warn = (...args) => {
  if (
    typeof args[0] === 'string' &&
    (
      args[0].includes('ReactDOM.render is no longer supported') ||
      args[0].includes('Warning: validateDOMNesting')
    )
  ) {
    return;
  }
  originalConsoleWarn.call(console, ...args);
};

// Global cleanup
afterEach(() => {
  jest.clearAllMocks();
});

beforeEach(() => {
  jest.clearAllTimers();
});

// Extend Jest matchers
expect.extend({
  toBeValidDate(received) {
    const pass = received instanceof Date && !isNaN(received.getTime());
    if (pass) {
      return {
        message: () => `expected ${received} not to be a valid date`,
        pass: true,
      };
    } else {
      return {
        message: () => `expected ${received} to be a valid date`,
        pass: false,
      };
    }
  },
  
  toBeValidObjectId(received) {
    const pass = typeof received === 'string' && /^[0-9a-fA-F]{24}$/.test(received);
    if (pass) {
      return {
        message: () => `expected ${received} not to be a valid ObjectId`,
        pass: true,
      };
    } else {
      return {
        message: () => `expected ${received} to be a valid ObjectId`,
        pass: false,
      };
    }
  },

  toBeValidIPAddress(received) {
    const ipv4Regex = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/;
    const pass = typeof received === 'string' && ipv4Regex.test(received);
    if (pass) {
      return {
        message: () => `expected ${received} not to be a valid IP address`,
        pass: true,
      };
    } else {
      return {
        message: () => `expected ${received} to be a valid IP address`,
        pass: false,
      };
    }
  }
});

// Mock implementations
jest.mock('socket.io-client', () => {
  return jest.fn(() => ({
    on: jest.fn(),
    emit: jest.fn(),
    off: jest.fn(),
    disconnect: jest.fn(),
    connected: true
  }));
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
  console.log('Unhandled Rejection at:', promise, 'reason:', reason);
  // Application specific logging, throwing an error, or other logic here
});

// Clean up after all tests
afterAll(async () => {
  // Close database connections, clear timeouts, etc.
  await new Promise(resolve => setTimeout(resolve, 500));
});