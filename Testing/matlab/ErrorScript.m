%% Define the transformation matrices

True = [
    0.61081 -0.616458   0.49688         0
  0.79023  0.435431 -0.431202         0
0.0494608  0.656033   0.75311         0
        0         0         0         1
    ];


NumberofTests = 3;

T = zeros(4,4,NumberofTests); % do not change
T(:,:,1) = [
    0.610828     0.790217    0.0494548 -6.91491e-07
   -0.616436      0.43544     0.656048 -1.94144e-06
    0.496886    -0.431219     0.753097 -1.81495e-06
           0            0            0            1
    ];
T(:,:,2) = [
    0.610845     0.790204    0.0494636 -4.09192e-06
   -0.616416     0.435436     0.656069 -2.94763e-06
     0.49689    -0.431247     0.753078  1.35911e-06
           0            0            0            1
    ];
T(:,:,3) = [
    0.61081      0.79023    0.0494608  1.07003e-16
   -0.616458     0.435431     0.656033 -9.70897e-17
     0.49688    -0.431202      0.75311 -1.45894e-17
          -0            0           -0            1
    ];


%% Computing the errors
Error = zeros(NumberofTests,1);
for i = 1:NumberofTests
    Error(i) = norm(inv(True) - T(:,:,i),'fro');
end
disp('Errors:')
fprintf('%e\n',Error)