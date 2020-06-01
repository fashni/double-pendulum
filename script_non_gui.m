pendulum = PendulumIntegrator();

g = 9.8;
m = [1; 1];
L = [1; 1];
th_0 = [pi/6; 0];
w_0 = [0; 0];
h = 0.005;
iterasi = 2000;
freq = 20;

pendulum.grav = g;
pendulum.steps = h;
pendulum.iterations = iterasi;
pendulum.mass = m;
pendulum.length = L;
pendulum.th_data(:, 1) = th_0;
pendulum.w_data(:, 1) = w_0;

pendulum.runge_kutta();
% pendulum.euler();
% pendulum.symplectic_euler();
t = 0:pendulum.steps:pendulum.steps*(pendulum.iterations-1);

cartesian = pendulum.get_cartesian();
x1 = cartesian(1, :);
y1 = cartesian(2, :);
x2 = cartesian(3, :);
y2 = cartesian(4, :);

%% Simulasi
figure
daspect([1 1 1]);
set(gca, 'XLim', [-sum(pendulum.length)*1.2 sum(pendulum.length)*1.2], ... 
         'YLim', [-sum(pendulum.length)*1.2 sum(pendulum.length)*1.2]);
hold on
for k=1:freq:pendulum.iterations
  string1 = line([0 x1(k)], [0 y1(k)], 'LineWidth', 1.5);
  string2 = line([x1(k) x2(k)], [y1(k) y2(k)], 'LineWidth', 1.5);
  head1 = scatter(x1(k), y1(k), 70, 'filled', 'MarkerFaceColor', 	'r', 'MarkerEdgeColor', 'k');
  head2 = scatter(x2(k), y2(k), 70, 'filled', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k');
  drawnow();
  if k+freq <= pendulum.iterations
    delete(head1);
    delete(head2);
    delete(string1);
    delete(string2);
  end
end
hold off

%% Grafik Waktu
figure
plot(t, pendulum.th_data(1,:), t, pendulum.th_data(2,:))

figure
plot(t, pendulum.w_data(1,:), t, pendulum.w_data(2,:))
