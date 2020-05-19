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
    function self = PendulumIntegrator(grav, steps, iterations)
      self.grav = grav;
      self.steps = steps;
      self.iterations = iterations;
      self.th_data = zeros(2, iterations);
      self.w_data = zeros(2, iterations);
    end


    function add_properties(self, mass, len, th_init, w_init)
      if any(size(mass) ~= [1, 2]) || ... 
         all(size(len) ~= [1, 2]) || ...
         any(size(th_init) ~= [1, 2]) || ...
         any(size(w_init) ~= [1, 2])
        return
      end
      self.mass = mass;
      self.length = len;
      self.th_data(:, 1) = th_init';
      self.w_data(:, 1) = w_init';
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