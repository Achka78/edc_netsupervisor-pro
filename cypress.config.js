const { defineConfig } = require('cypress');
const { MongoMemoryServer } = require('mongodb-memory-server');
const mongoose = require('mongoose');

module.exports = defineConfig({
  e2e: {
    // Base configuration
    baseUrl: 'http://localhost:3000',
    specPattern: 'cypress/e2e/**/*.cy.{js,jsx,ts,tsx}',
    supportFile: 'cypress/support/e2e.js',
    fixturesFolder: 'cypress/fixtures',
    screenshotsFolder: 'cypress/screenshots',
    videosFolder: 'cypress/videos',
    downloadsFolder: 'cypress/downloads',

    // Viewport settings
    viewportWidth: 1280,
    viewportHeight: 720,

    // Timeouts
    defaultCommandTimeout: 10000,
    requestTimeout: 10000,
    responseTimeout: 10000,
    pageLoadTimeout: 30000,

    // Video and screenshot settings
    video: true,
    videoUploadOnPasses: false,
    screenshotOnRunFailure: true,
    
    // Test settings
    testIsolation: true,
    experimentalStudio: true,
    experimentalWebKitSupport: false,

    // Environment variables
    env: {
      apiUrl: 'http://localhost:5000',
      baseUrl: 'http://localhost:3000',
      mongoUrl: 'mongodb://localhost:27017/edc_netsupervisor_test',
      coverage: false
    },

    // Setup node events
    setupNodeEvents(on, config) {
      let mongoServer;
      let mongoConnection;

      // Task to reset database
      on('task', {
        async resetDatabase() {
          try {
            if (mongoConnection && mongoConnection.readyState === 1) {
              const collections = await mongoConnection.db.collections();
              for (const collection of collections) {
                await collection.deleteMany({});
              }
            }
            return null;
          } catch (error) {
            console.error('Failed to reset database:', error);
            throw error;
          }
        },

        async createTestUser(userData) {
          try {
            if (!mongoConnection || mongoConnection.readyState !== 1) {
              mongoConnection = await mongoose.connect(config.env.mongoUrl);
            }

            const User = require('./server/models/User');
            const bcrypt = require('bcryptjs');

            const hashedPassword = await bcrypt.hash(userData.password, 12);
            
            const user = await User.create({
              email: userData.email,
              password: hashedPassword,
              firstName: userData.firstName || 'Test',
              lastName: userData.lastName || 'User',
              role: userData.role || 'admin',
              isActive: true
            });

            return user.toObject();
          } catch (error) {
            console.error('Failed to create test user:', error);
            throw error;
          }
        },

        async createTestDevice(deviceData) {
          try {
            if (!mongoConnection || mongoConnection.readyState !== 1) {
              mongoConnection = await mongoose.connect(config.env.mongoUrl);
            }

            const Device = require('./server/models/Device');
            
            const device = await Device.create({
              name: deviceData.name,
              ipAddress: deviceData.ipAddress,
              type: deviceData.type,
              status: deviceData.status || 'online',
              location: deviceData.location || 'Test Lab',
              lastSeen: new Date()
            });

            return device.toObject();
          } catch (error) {
            console.error('Failed to create test device:', error);
            throw error;
          }
        },

        async createSecurityAlert(alertData) {
          try {
            if (!mongoConnection || mongoConnection.readyState !== 1) {
              mongoConnection = await mongoose.connect(config.env.mongoUrl);
            }

            const SecurityAlert = mongoose.model('SecurityAlert', new mongoose.Schema({
              type: String,
              severity: String,
              message: String,
              device: String,
              createdAt: { type: Date, default: Date.now },
              status: { type: String, default: 'open' }
            }));
            
            const alert = await SecurityAlert.create({
              type: alertData.type,
              severity: alertData.severity,
              message: alertData.message,
              device: alertData.device || 'test-device',
              status: 'open'
            });

            return alert.toObject();
          } catch (error) {
            console.error('Failed to create security alert:', error);
            throw error;
          }
        },

        async cleanupTestData() {
          try {
            if (mongoConnection && mongoConnection.readyState === 1) {
              await mongoConnection.close();
            }
            return null;
          } catch (error) {
            console.error('Failed to cleanup test data:', error);
            throw error;
          }
        }
      });

      // Setup database before tests
      on('before:run', async () => {
        try {
          mongoServer = await MongoMemoryServer.create();
          const mongoUri = mongoServer.getUri();
          config.env.mongoUrl = mongoUri;
          mongoConnection = await mongoose.connect(mongoUri);
          console.log('Test database started');
        } catch (error) {
          console.error('Failed to start test database:', error);
        }
      });

      // Cleanup after tests
      on('after:run', async () => {
        try {
          if (mongoConnection) {
            await mongoConnection.close();
          }
          if (mongoServer) {
            await mongoServer.stop();
          }
          console.log('Test database stopped');
        } catch (error) {
          console.error('Failed to stop test database:', error);
        }
      });

      // Code coverage (if enabled)
      if (config.env.coverage) {
        require('@cypress/code-coverage/task')(on, config);
      }

      // Screenshot and video processing
      on('after:screenshot', (details) => {
        console.log('Screenshot taken:', details.path);
      });

      on('after:spec', (spec, results) => {
        if (results && results.video) {
          // Process video if needed
          console.log('Video recorded:', results.video);
        }
      });

      return config;
    },
  },

  component: {
    devServer: {
      framework: 'create-react-app',
      bundler: 'webpack',
    },
    specPattern: 'src/**/*.cy.{js,jsx,ts,tsx}',
    supportFile: 'cypress/support/component.js',
  },
});