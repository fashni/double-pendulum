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


    function varargout = deriv(self, n)
      dth1dt = self.w_data(1, n);
      dth2dt = self.w_data(2, n);

      den1 = self.length(1)*(2*self.mass(1) + self.mass(2) - self.mass(2)*cos(2*self.th_data(1, n)-2*self.th_data(2, n)));
      den2 = (self.length(2)/self.length(1)) * den1;

      dw1dt = (-self.grav*(2*self.mass(1)+self.mass(2))*sin(self.th_data(1, n)) ...
              - self.mass(2)*self.grav*sin(self.th_data(1, n)-2*self.th_data(2, n)) ...
              - 2*sin(self.th_data(1, n)-self.th_data(2, n))*self.mass(2) * ...
              (self.w_data(2, n)^2*self.length(2) ...
               + self.w_data(1, n)^2*self.length(1)*cos(self.th_data(1, n)-self.th_data(2, n)))) / den1;
      dw2dt = (2*sin(self.th_data(1, n)-self.th_data(2, n)) * ...
              (self.w_data(1, n)^2*self.length(1)*(self.mass(1)+self.mass(2)) ...
              + self.grav*(self.mass(1)+self.mass(2))*cos(self.th_data(1, n)) ...
              + self.w_data(2, n)^2*self.length(2)*self.mass(2)*cos(self.th_data(1, n)-self.th_data(2, n)))) / den2;

      y = [dth1dt dw1dt dth2dt dw2dt];
      if nargout > 4
        return
      end
      for k = 1:nargout
        varargout{k} = y(k);
      end
    end
    

    function runge_kutta(self)
      
    end

  end
end