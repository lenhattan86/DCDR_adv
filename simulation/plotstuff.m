caps = [62.2892
   72.2892
   87.2892
   97.2892
  107.2892
   82.2892
   92.2892
  102.2892
  112.2892
  122.2892];

fracs = [ 
    0.3278
    0.3588
    0.4460
    0.5152
    0.5691
    0.4087
    0.4777
    0.5497
    0.5895
    0.6583];

plot(caps, fracs, 'or');

hold on;
x = 60:0.05:130;
y = 0.5294*(ones(1,length(x)));
plot(x,y, '-b');
xlabel('Average DC capacities (range)');
ylabel('Fraction of within range voltages');