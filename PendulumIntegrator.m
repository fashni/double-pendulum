classdef PendulumIntegrator < handle
  properties
    grav
    steps
    iterations
    mass
    length
    th_data
    w_data
  end


  methods
    function self = PendulumIntegrator(varargin)
      self.add_properties(varargin{:});
    end


    function add_properties(self, varargin)
      p = inputParser;
      valid_size = @(x) validateattributes(x,{'numeric'},{'size', [1 2]});
      valid_param = @(x) isscalar(x) && isnumeric(x) && x>0;
      addParameter(p, 'GravAcc', [], valid_param);
      addParameter(p, 'Steps', [], valid_param);
      addParameter(p, 'Iterations', [], valid_param);
      addParameter(p, 'Mass', [], valid_size);
      addParameter(p, 'Length', [], valid_size);
      addParameter(p, 'InitialTheta', [], valid_size);
      addParameter(p, 'InitialOmega', [], valid_size);
      parse(p, varargin{:})

      if ~any(find(strcmp(p.UsingDefaults, 'GravAcc')))
        self.grav = p.Results.GravAcc;
      end
      if ~any(find(strcmp(p.UsingDefaults, 'Steps')))
        self.steps = p.Results.Steps;
      end
      if ~any(find(strcmp(p.UsingDefaults, 'Iterations')))
        self.iterations = p.Results.Iterations;
        self.th_data = zeros(2, self.iterations);
        self.w_data = zeros(2, self.iterations);
      end
      if ~any(find(strcmp(p.UsingDefaults, 'Mass')))
        self.mass = p.Results.Mass;
      end
      if ~any(find(strcmp(p.UsingDefaults, 'Length')))
        self.length = p.Results.Length;
      end
      if ~any(find(strcmp(p.UsingDefaults, 'InitialTheta')))
        self.th_data(:, 1) = p.Results.InitialTheta';
      end
      if ~any(find(strcmp(p.UsingDefaults, 'InitialOmega')))
        self.w_data(:, 1) = p.Results.InitialOmega';
      end
    end


    function clear_properties(self)
      self.grav = [];
      self.steps = [];
      self.iterations = [];
      self.mass = [];
      self.length = [];
      self.th_data = [];
      self.w_data = [];
    end


    function runge_kutta(self)
      g = self.grav;
      m1 = self.mass(1);
      m2 = self.mass(2);
      M = sum(self.mass);
      L1 = self.length(1);
      L2 = self.length(2);
      h = self.steps;
      hh = 0.5*h;

      dth1 = @(th1, th2, w1, w2) w1;
      dth2 = @(th1, th2, w1, w2) w2;
      dw1 = @(th1, th2, w1, w2) (-g*(M+m1)*sin(th1) - m2*g*sin(th1-2*th2) - 2*sin(th1-th2) * m2*(w1^2*L1*cos(th1-th2)+w2^2*L2)) / (L1*(M+m1-m2*cos(2*th1-2*th2)));
      dw2 = @(th1, th2, w1, w2) (2*sin(th1-th2) * (M*w1^2*L1 + g*M*cos(th1) + w2^2*L2*m2*cos(th1-th2))) / (L2*(M+m1-m2*cos(2*th1-2*th2)));

      f = {dth1 dth2 dw1 dw2};

      y = zeros(4, self.iterations);
      A = zeros(4);
      B = zeros(4);
      C = zeros(4);
      D = zeros(4);

      y(1, 1) = self.th_data(1, 1);
      y(2, 1) = self.th_data(2, 1);
      y(3, 1) = self.w_data(1, 1);
      y(4, 1) = self.w_data(2, 1);

      for k = 2:self.iterations
        for p = 1:4
          A(p) = f{p}(y(1, k-1), y(2, k-1), y(3, k-1), y(4, k-1));
        end
        for p = 1:4
          B(p) = f{p}(y(1, k-1)+hh*A(1), y(2, k-1)+hh*A(2), y(3, k-1)+hh*A(3), y(4, k-1)+hh*A(4));
        end
        for p = 1:4
          C(p) = f{p}(y(1, k-1)+hh*B(1), y(2, k-1)+hh*B(2), y(3, k-1)+hh*B(3), y(4, k-1)+hh*B(4));
        end
        for p = 1:4
          D(p) = f{p}(y(1, k-1)+h*C(1), y(2, k-1)+h*C(2), y(3, k-1)+h*C(3), y(4, k-1)+h*C(4));
        end

        for p = 1:4
          y(p, k) = y(p, k-1) + (h/6)*(A(p) + 2*B(p) + 2*C(p) + D(p));
        end
      end

      self.th_data = wrapToPi(y(1:2, :));
      self.w_data = y(3:4, :);
    end


    function output = get_cartesian(self)
      x1 = self.length(1) * sin(self.th_data(1, :));
      y1 = -self.length(1) * cos(self.th_data(1, :));

      x2 = x1 + self.length(2) * sin(self.th_data(2, :));
      y2 = y1 - self.length(2) * cos(self.th_data(2, :));

      output = [x1; y1; x2; y2];
    end
  end
end
