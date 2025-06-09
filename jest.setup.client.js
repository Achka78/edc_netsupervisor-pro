// Client-specific Jest setup
import '@testing-library/jest-dom';

// Mock window.matchMedia
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: jest.fn().mockImplementation(query => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: jest.fn(), // deprecated
    removeListener: jest.fn(), // deprecated
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
    dispatchEvent: jest.fn(),
  })),
});

// Mock window.ResizeObserver
global.ResizeObserver = jest.fn().mockImplementation(() => ({
  observe: jest.fn(),
  unobserve: jest.fn(),
  disconnect: jest.fn(),
}));

// Mock IntersectionObserver
global.IntersectionObserver = jest.fn().mockImplementation(() => ({
  observe: jest.fn(),
  unobserve: jest.fn(),
  disconnect: jest.fn(),
}));

// Mock window.scrollTo
Object.defineProperty(window, 'scrollTo', {
  value: jest.fn(),
  writable: true
});

// Mock localStorage
const localStorageMock = {
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn(),
  length: 0,
  key: jest.fn(),
};
Object.defineProperty(window, 'localStorage', {
  value: localStorageMock
});

// Mock sessionStorage
const sessionStorageMock = {
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn(),
  length: 0,
  key: jest.fn(),
};
Object.defineProperty(window, 'sessionStorage', {
  value: sessionStorageMock
});

// Mock HTMLCanvasElement.getContext
HTMLCanvasElement.prototype.getContext = jest.fn(() => ({
  fillRect: jest.fn(),
  clearRect: jest.fn(),
  getImageData: jest.fn(() => ({
    data: new Array(4)
  })),
  putImageData: jest.fn(),
  createImageData: jest.fn(() => []),
  setTransform: jest.fn(),
  drawImage: jest.fn(),
  save: jest.fn(),
  fillText: jest.fn(),
  restore: jest.fn(),
  beginPath: jest.fn(),
  moveTo: jest.fn(),
  lineTo: jest.fn(),
  closePath: jest.fn(),
  stroke: jest.fn(),
  translate: jest.fn(),
  scale: jest.fn(),
  rotate: jest.fn(),
  arc: jest.fn(),
  fill: jest.fn(),
  measureText: jest.fn(() => ({ width: 0 })),
  transform: jest.fn(),
  rect: jest.fn(),
  clip: jest.fn(),
}));

// Mock URL.createObjectURL
global.URL.createObjectURL = jest.fn(() => 'mocked-url');
global.URL.revokeObjectURL = jest.fn();

// Mock File API
global.File = class MockFile {
  constructor(bits, name, options = {}) {
    this.bits = bits;
    this.name = name;
    this.size = bits.reduce((acc, bit) => acc + bit.length, 0);
    this.type = options.type || '';
    this.lastModified = options.lastModified || Date.now();
  }
};

global.FileReader = class MockFileReader {
  constructor() {
    this.result = null;
    this.error = null;
    this.readyState = 0;
    this.onload = null;
    this.onerror = null;
    this.onloadend = null;
  }

  readAsText(file) {
    setTimeout(() => {
      this.result = 'mock file content';
      this.readyState = 2;
      if (this.onload) this.onload({ target: this });
      if (this.onloadend) this.onloadend({ target: this });
    }, 10);
  }

  readAsDataURL(file) {
    setTimeout(() => {
      this.result = 'data:text/plain;base64,bW9jayBmaWxlIGNvbnRlbnQ=';
      this.readyState = 2;
      if (this.onload) this.onload({ target: this });
      if (this.onloadend) this.onloadend({ target: this });
    }, 10);
  }
};

// Mock fetch API
global.fetch = jest.fn(() =>
  Promise.resolve({
    ok: true,
    status: 200,
    json: () => Promise.resolve({}),
    text: () => Promise.resolve(''),
    blob: () => Promise.resolve(new Blob()),
    arrayBuffer: () => Promise.resolve(new ArrayBuffer(0)),
  })
);

// Mock WebSocket
global.WebSocket = jest.fn(() => ({
  close: jest.fn(),
  send: jest.fn(),
  addEventListener: jest.fn(),
  removeEventListener: jest.fn(),
  readyState: 1,
  CONNECTING: 0,
  OPEN: 1,
  CLOSING: 2,
  CLOSED: 3,
}));

// Mock Notification API
global.Notification = jest.fn(() => ({
  close: jest.fn(),
}));
Notification.permission = 'granted';
Notification.requestPermission = jest.fn(() => Promise.resolve('granted'));

// Mock crypto API for UUID generation
Object.defineProperty(global, 'crypto', {
  value: {
    randomUUID: jest.fn(() => '123e4567-e89b-12d3-a456-426614174000'),
    getRandomValues: jest.fn((arr) => {
      for (let i = 0; i < arr.length; i++) {
        arr[i] = Math.floor(Math.random() * 256);
      }
      return arr;
    }),
  },
});

// Mock react-router-dom
jest.mock('react-router-dom', () => ({
  ...jest.requireActual('react-router-dom'),
  useNavigate: () => jest.fn(),
  useLocation: () => ({
    pathname: '/',
    search: '',
    hash: '',
    state: null,
  }),
  useParams: () => ({}),
}));

// Mock i18next
jest.mock('react-i18next', () => ({
  useTranslation: () => ({
    t: (key, options) => {
      if (options && options.count !== undefined) {
        return `${key}_${options.count === 1 ? 'one' : 'other'}`;
      }
      return key;
    },
    i18n: {
      changeLanguage: jest.fn(),
      language: 'en',
      languages: ['en', 'fr'],
    },
  }),
  withTranslation: () => (Component) => Component,
  Trans: ({ children, i18nKey }) => children || i18nKey,
}));

// Mock chart libraries
jest.mock('recharts', () => ({
  LineChart: ({ children }) => <div data-testid="line-chart">{children}</div>,
  Line: () => <div data-testid="line" />,
  XAxis: () => <div data-testid="x-axis" />,
  YAxis: () => <div data-testid="y-axis" />,
  CartesianGrid: () => <div data-testid="cartesian-grid" />,
  Tooltip: () => <div data-testid="tooltip" />,
  Legend: () => <div data-testid="legend" />,
  ResponsiveContainer: ({ children }) => <div data-testid="responsive-container">{children}</div>,
  BarChart: ({ children }) => <div data-testid="bar-chart">{children}</div>,
  Bar: () => <div data-testid="bar" />,
  PieChart: ({ children }) => <div data-testid="pie-chart">{children}</div>,
  Pie: () => <div data-testid="pie" />,
  Cell: () => <div data-testid="cell" />,
}));

// Mock lucide-react icons
jest.mock('lucide-react', () => {
  const mockIcon = ({ children, ...props }) => (
    <svg {...props} data-testid={props['data-testid'] || 'mock-icon'}>
      {children}
    </svg>
  );

  return new Proxy({}, {
    get: (target, prop) => {
      if (typeof prop === 'string') {
        return mockIcon;
      }
      return target[prop];
    }
  });
});

// Mock D3.js
jest.mock('d3', () => ({
  select: jest.fn(() => ({
    selectAll: jest.fn(() => ({
      data: jest.fn(() => ({
        enter: jest.fn(() => ({
          append: jest.fn(() => ({
            attr: jest.fn(),
            style: jest.fn(),
            text: jest.fn(),
          })),
        })),
        exit: jest.fn(() => ({
          remove: jest.fn(),
        })),
        attr: jest.fn(),
        style: jest.fn(),
        text: jest.fn(),
      })),
    })),
    append: jest.fn(() => ({
      attr: jest.fn(),
      style: jest.fn(),
    })),
    attr: jest.fn(),
    style: jest.fn(),
    on: jest.fn(),
  })),
  scaleLinear: jest.fn(() => ({
    domain: jest.fn(() => ({
      range: jest.fn(),
    })),
    range: jest.fn(),
  })),
  scaleBand: jest.fn(() => ({
    domain: jest.fn(() => ({
      range: jest.fn(() => ({
        padding: jest.fn(),
      })),
    })),
    bandwidth: jest.fn(() => 50),
  })),
  axisBottom: jest.fn(),
  axisLeft: jest.fn(),
  max: jest.fn(),
  extent: jest.fn(),
}));

// Test utilities for React components
global.renderWithProviders = (ui, options = {}) => {
  const { render } = require('@testing-library/react');
  const { Provider } = require('react-redux');
  const { BrowserRouter } = require('react-router-dom');
  const { configureStore } = require('@reduxjs/toolkit');
  
  const store = options.store || configureStore({
    reducer: {
      auth: (state = { isAuthenticated: false, user: null }) => state,
      devices: (state = { devices: [], isLoading: false }) => state,
      dashboard: (state = { stats: {}, isLoading: false }) => state,
    },
    preloadedState: options.preloadedState,
  });

  const Wrapper = ({ children }) => (
    <Provider store={store}>
      <BrowserRouter>
        {children}
      </BrowserRouter>
    </Provider>
  );

  return {
    store,
    ...render(ui, { wrapper: Wrapper, ...options }),
  };
};

// Mock API service
jest.mock('../services/api', () => ({
  get: jest.fn(() => Promise.resolve({ data: { success: true, data: [] } })),
  post: jest.fn(() => Promise.resolve({ data: { success: true, data: {} } })),
  put: jest.fn(() => Promise.resolve({ data: { success: true, data: {} } })),
  delete: jest.fn(() => Promise.resolve({ data: { success: true } })),
}));

// Custom render function for testing with context
global.renderWithContext = (ui, { theme = 'light', language = 'en' } = {}) => {
  const { render } = require('@testing-library/react');
  
  const Wrapper = ({ children }) => (
    <div data-theme={theme} data-language={language}>
      {children}
    </div>
  );

  return render(ui, { wrapper: Wrapper });
};

// Clean up after each test
afterEach(() => {
  jest.clearAllMocks();
  localStorageMock.clear();
  sessionStorageMock.clear();
});

// Suppress specific React warnings in tests
const originalError = console.error;
beforeAll(() => {
  console.error = (...args) => {
    if (
      typeof args[0] === 'string' &&
      (
        args[0].includes('Warning: ReactDOM.render is no longer supported') ||
        args[0].includes('Warning: validateDOMNesting') ||
        args[0].includes('Warning: componentWillReceiveProps')
      )
    ) {
      return;
    }
    originalError.call(console, ...args);
  };
});

afterAll(() => {
  console.error = originalError;
});