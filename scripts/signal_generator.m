clear;
clc;

signal = 1:1024;
signal_name = 'signal.mem';

fid = fopen(signal_name, 'w');

for i = 1:length(signal)
    fprintf(fid, '%08X\n', signal(i));
end

fclose(fid);

disp('Memory file generated successfully.');
