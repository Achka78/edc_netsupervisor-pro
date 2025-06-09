// Server-specific Jest setup
const { MongoMemoryServer } = require('mongodb-memory-server');
const mongoose = require('mongoose');

// Mock external services
jest.mock('nodemailer', () => ({
  createTransport: jest.fn(() => ({
    sendMail: jest.fn().mockResolvedValue({ messageId: 'test-message-id' })
  }))
}));

jest.mock('ssh2', () => ({
  Client: jest.fn(() => ({
    connect: jest.fn(),
    exec: jest.fn((command, callback) => {
      const mockStream = {
        on: jest.fn((event, handler) => {
          if (event === 'close') {
            setTimeout(() => handler(0), 100);
          } else if (event === 'data') {
            setTimeout(() => handler(Buffer.from('Mock command output')), 50);
          }
        }),
        stderr: {
          on: jest.fn()
        }
      };
      callback(null, mockStream);
    }),
    end: jest.fn()
  }))
}));

jest.mock('net-snmp', () => ({
  createSession: jest.fn(() => ({
    get: jest.fn((oids, callback) => {
      callback(null, [
        { oid: '1.3.6.1.2.1.1.1.0', value: 'Mock SNMP sysDescr' },
        { oid: '1.3.6.1.2.1.1.3.0', value: 1234567 }
      ]);
    }),
    close: jest.fn()
  })),
  ObjectType: {
    OctetString: 4,
    Integer: 2
  }
}));

// Mock file system operations
jest.mock('fs', () => ({
  ...jest.requireActual('fs'),
  promises: {
    ...jest.requireActual('fs').promises,
    writeFile: jest.fn().mockResolvedValue(),
    readFile: jest.fn().mockResolvedValue('mock file content'),
    mkdir: jest.fn().mockResolvedValue(),
    unlink: jest.fn().mockResolvedValue()
  }
}));

// Mock ping library
jest.mock('ping', () => ({
  promise: {
    probe: jest.fn().mockResolvedValue({
      alive: true,
      time: 10,
      min: 10,
      max: 15,
      avg: 12
    })
  }
}));

// Mock network scanning
jest.mock('nmap', () => ({
  scan: jest.fn((range, callback) => {
    const mockResults = [
      {
        hostname: 'router-01.local',
        ip: '192.168.1.1',
        mac: '00:11:22:33:44:55',
        vendor: 'Cisco Systems',
        openPorts: [{ port: 22, service: 'ssh' }, { port: 80, service: 'http' }]
      },
      {
        hostname: 'switch-01.local',
        ip: '192.168.1.2',
        mac: '00:11:22:33:44:56',
        vendor: 'Cisco Systems',
        openPorts: [{ port: 22, service: 'ssh' }, { port: 161, service: 'snmp' }]
      }
    ];
    setTimeout(() => callback(null, mockResults), 100);
  })
}));

// Database setup
let mongoServer;

beforeAll(async () => {
  // Start in-memory MongoDB instance
  mongoServer = await MongoMemoryServer.create();
  const mongoUri = mongoServer.getUri();
  
  // Connect to the in-memory database
  await mongoose.connect(mongoUri, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  });
});

afterAll(async () => {
  // Cleanup database
  await mongoose.connection.dropDatabase();
  await mongoose.connection.close();
  await mongoServer.stop();
});

beforeEach(async () => {
  // Clear all collections before each test
  const collections = mongoose.connection.collections;
  for (const key in collections) {
    await collections[key].deleteMany({});
  }
});

// Test utilities
global.createTestUser = async (userData = {}) => {
  const User = require('../server/models/User');
  const bcrypt = require('bcryptjs');
  
  const defaultUser = {
    email: 'test@example.com',
    password: await bcrypt.hash('password123', 12),
    firstName: 'Test',
    lastName: 'User',
    role: 'admin',
    isActive: true
  };
  
  return await User.create({ ...defaultUser, ...userData });
};

global.createTestDevice = async (deviceData = {}) => {
  const Device = require('../server/models/Device');
  
  const defaultDevice = {
    name: 'Test-Device',
    ipAddress: '192.168.1.100',
    type: 'router',
    status: 'online',
    lastSeen: new Date()
  };
  
  return await Device.create({ ...defaultDevice, ...deviceData });
};

global.createAuthToken = (userId) => {
  const jwt = require('jsonwebtoken');
  return jwt.sign(
    { userId: userId.toString() },
    process.env.JWT_SECRET,
    { expiresIn: '1h' }
  );
};

// Mock Redis
const mockRedis = {
  get: jest.fn().mockResolvedValue(null),
  set: jest.fn().mockResolvedValue('OK'),
  del: jest.fn().mockResolvedValue(1),
  exists: jest.fn().mockResolvedValue(0),
  expire: jest.fn().mockResolvedValue(1),
  flushall: jest.fn().mockResolvedValue('OK'),
  quit: jest.fn().mockResolvedValue('OK')
};

jest.mock('redis', () => ({
  createClient: jest.fn(() => mockRedis)
}));

// Mock Socket.IO
const mockSocketIo = {
  emit: jest.fn(),
  to: jest.fn(() => mockSocketIo),
  in: jest.fn(() => mockSocketIo),
  on: jest.fn(),
  use: jest.fn()
};

jest.mock('socket.io', () => ({
  __esModule: true,
  default: jest.fn(() => mockSocketIo)
}));

// Suppress console logs in tests unless debugging
if (!process.env.DEBUG_TESTS) {
  global.console = {
    ...console,
    log: jest.fn(),
    debug: jest.fn(),
    info: jest.fn(),
    warn: jest.fn(),
    error: jest.fn(),
  };
}

// Test helpers
global.mockRequest = (overrides = {}) => ({
  body: {},
  params: {},
  query: {},
  headers: {},
  user: null,
  ...overrides
});

global.mockResponse = () => {
  const res = {
    status: jest.fn(() => res),
    json: jest.fn(() => res),
    send: jest.fn(() => res),
    cookie: jest.fn(() => res),
    clearCookie: jest.fn(() => res),
    header: jest.fn(() => res),
    redirect: jest.fn(() => res)
  };
  return res;
};

global.mockNext = () => jest.fn();

// Error handling for tests
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

// Set test environment variables
process.env.NODE_ENV = 'test';
process.env.LOG_LEVEL = 'error';
process.env.SUPPRESS_NO_CONFIG_WARNING = 'true';