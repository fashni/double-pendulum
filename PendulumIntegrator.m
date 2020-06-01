classdef PendulumIntegrator < handle
  properties
    grav
    steps
    iterations
    mass
    length
    th_data
    w_data
    th_analytic
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
      self.th_analytic = [];
    end


    function output = diff_eqs(self)
      g = self.grav; % perc. gravitasi
      m1 = self.mass(1); % massa 1
      m2 = self.mass(2); % massa 2
      M = sum(self.mass); % massa 1 + massa 2
      L1 = self.length(1); % panjang tali 1
      L2 = self.length(2); % panjang tali 2

      dth1 = @(w1, w2, th1, th2) w1; % dth1/dt
      dth2 = @(w1, w2, th1, th2) w2; % dth2/dt
      % dw1/dt
      dw1 = @(w1, w2, th1, th2) (-g*(M+m1)*sin(th1) - m2*g*sin(th1-2*th2) - 2*sin(th1-th2) * m2*(w1^2*L1*cos(th1-th2)+w2^2*L2)) / (L1*(M+m1-m2*cos(2*th1-2*th2)));
      % dw2/dt
      dw2 = @(w1, w2, th1, th2) (2*sin(th1-th2) * (M*w1^2*L1 + g*M*cos(th1) + w2^2*L2*m2*cos(th1-th2))) / (L2*(M+m1-m2*cos(2*th1-2*th2)));

      output = {dw1 dw2 dth1 dth2};
    end


    function runge_kutta(self)
      h = self.steps; % step
      hh = 0.5*h; % setengah step
      f = self.diff_eqs(); % persamaan differensial

      % Inisiasi matriks dengan nol
      y = zeros(4, self.iterations);
      A = zeros(4, 1);
      B = zeros(4, 1);
      C = zeros(4, 1);
      D = zeros(4, 1);

      % Memasukkan kondisi awal sistem
      y(1, 1) = self.w_data(1, 1); % w1
      y(2, 1) = self.w_data(2, 1); % w2
      y(3, 1) = self.th_data(1, 1); % th1
      y(4, 1) = self.th_data(2, 1); % th2

      % BEGIN RUNGE-KUTTA METHOD
      for k = 2:self.iterations
        % Orde pertama
        for p = 1:4
          A(p) = f{p}(y(1, k-1), y(2, k-1), y(3, k-1), y(4, k-1));
        end

        % Orde kedua
        for p = 1:4
          B(p) = f{p}(y(1, k-1)+hh*A(1), y(2, k-1)+hh*A(2), y(3, k-1)+hh*A(3), y(4, k-1)+hh*A(4));
        end

        % Orde ketiga
        for p = 1:4
          C(p) = f{p}(y(1, k-1)+hh*B(1), y(2, k-1)+hh*B(2), y(3, k-1)+hh*B(3), y(4, k-1)+hh*B(4));
        end

        % Orde keempat
        for p = 1:4
          D(p) = f{p}(y(1, k-1)+h*C(1), y(2, k-1)+h*C(2), y(3, k-1)+h*C(3), y(4, k-1)+h*C(4));
        end

        % Update matriks iterasi ke-k
        for p = 1:4
          y(p, k) = y(p, k-1) + (h/6)*(A(p) + 2*B(p) + 2*C(p) + D(p));
        end
      end
      % END RUNGE-KUTTA METHOD

      % Memasukkan nilai matriks ke data perhitungan
      self.w_data = y(1:2, :); % w1 dan w2
      self.th_data = wrapToPi(y(3:4, :)); % th1 dan th2
    end

    
    function euler(self)
      h = self.steps; % step
      f = self.diff_eqs(); % persamaan differensial

      % Inisiasi matriks dengan nol
      y = zeros(4, self.iterations);

      % Memasukkan kondisi awal sistem
      y(1, 1) = self.w_data(1, 1); % w1
      y(2, 1) = self.w_data(2, 1); % w2
      y(3, 1) = self.th_data(1, 1); % th1
      y(4, 1) = self.th_data(2, 1); % th2

      % BEGIN EULER METHOD

      % END EULER METHOD

      self.w_data = y(1:2, :); % w1 dan w2
      self.th_data = wrapToPi(y(3:4, :)); % th1 dan th2
    end
    
    
    function symplectic_euler(self)
      h = self.steps; % step
      f = self.diff_eqs(); % persamaan differensial

      % Inisiasi matriks dengan nol
      w = zeros(2, self.iterations);
      th = zeros(2, self.iterations);

      % Memasukkan kondisi awal sistem
      w(1, 1) = self.w_data(1, 1); % w1
      w(2, 1) = self.w_data(2, 1); % w2
      th(1, 1) = self.th_data(1, 1); % th1
      th(2, 1) = self.th_data(2, 1); % th2
      
      % BEGIN SYMPLECTIC EULER METHOD

      % END SYMPLECTIC EULER METHOD

      self.w_data = w; % w1 dan w2
      self.th_data = wrapToPi(th); % th1 dan th2
    end


    function analytic(self)
      % BEGIN ANALYTIC METHOD
      
      % END ANALYTIC METHOD
    end


    function output = get_cartesian(self)
      x1 = self.length(1) * sin(self.th_data(1, :));
      y1 = -self.length(1) * cos(self.th_data(1, :));
      x2 = x1 + self.length(2) * sin(self.th_data(2, :));
      y2 = y1 - self.length(2) * cos(self.th_data(2, :));

      if ~isempty(self.th_analytic)
        x1_a = self.length(1) * sin(self.th_analytic(1, :));
        y1_a = -self.length(1) * cos(self.th_analytic(1, :));
        x2_a = x1_a + self.length(2) * sin(self.th_analytic(2, :));
        y2_a = y1_a - self.length(2) * cos(self.th_analytic(2, :));
      else
        [x1_a, y1_a, x2_a, y2_a] = deal([]);
      end

      output = [x1; y1; x2; y2; x1_a; y1_a; x2_a; y2_a];
    end
  end
end
