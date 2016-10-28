% This make.m is used under Linux

% add -largeArrayDims on 64-bit machines

mex -O -c svm.cpp
mex -O -c svm_model_matlab.cpp
mex -O svmtrain.cpp svm.o svm_model_matlab.o
mex -O svmpredict.cpp svm.o svm_model_matlab.o
mex -O libsvmread.cpp
mex -O libsvmwrite.cpp
