% 设置滤波器参数
fs = 16000;  % 采样率
fp = 3400;   % 通带截止频率 (Hz
fsb = 3800 + (4200 - 3800) * rand(); % 随机阻带截止频率
disp(['随机生成阻带频率大小: ', num2str(fsb), ' Hz']);
Rp = 1; % 通带波动
Rs = 30; % 阻带衰减

% 归一化频率
Wp = fp / (fs / 2);
Ws = fsb / (fs / 2);

% 计算滤波器阶数和归一化截止频率
[n, Wn] = buttord(Wp, Ws, Rp, Rs);

% 设计巴特沃斯滤波器
[b, a] = butter(n, Wn, 'low');
[H,f] = freqz(b, a, 1024, fs);
% 量化系数
num_bits = 12;
b_quant = round(b * (2^(num_bits - 1))) / (2^(num_bits - 1));
a_quant = round(a * (2^(num_bits - 1))) / (2^(num_bits - 1));

% 检查量化后的滤波器是否符合规范
% fvtool(b_quant, a_quant);
% 计算频率响应
[H_quant, f_quant] = freqz(b_quant, a_quant, 1024, fs);

% 计算通带衰减
passband = 20*log10(abs(H_quant(f_quant <= fp)));
max_passband_attenuation = -min(passband);

% 计算阻带衰减
stopband = 20*log10(abs(H_quant(f_quant >= fsb)));
min_stopband_attenuation = -max(stopband);

% 显示结果
disp(['量化后通带最大衰减: ', num2str(max_passband_attenuation), ' dB']);
disp(['量化后阻带最小衰减: ', num2str(min_stopband_attenuation), ' dB']);

% 查找-3dB点
mag_response = 20*log10(abs(H));
mag_response_quant = 20*log10(abs(H_quant));

% 找到原始滤波器的-3dB点
fp_original_index = find(mag_response <= -3, 1);
fp_original = f(fp_original_index);

% 找到量化后滤波器的-3dB点
fp_quant_index = find(mag_response_quant <= -3, 1);
fp_quant = f_quant(fp_quant_index);

% 显示结果
disp(['原始滤波器的通带截止频率: ', num2str(fp_original), ' Hz']);
disp(['量化后滤波器的通带截止频率: ', num2str(fp_quant), ' Hz']);

% 绘制幅值响应比较
figure;
subplot(2, 1, 1);
plot(f, 20*log10(abs(H)), 'LineWidth', 1.5);
hold on;
plot(f_quant, 20*log10(abs(H_quant)), 'LineWidth', 1.5);
grid on;
xlabel('频率 (Hz)');
ylabel('幅值 (dB)');
title('原始滤波器与量化滤波器的幅值响应');

% 标注原始和量化后的通带截止频率
y_lim = get(gca, 'ylim'); % 获取y轴范围
plot([fp_original, fp_original], y_lim, 'b--');
plot([fp_quant, fp_quant], y_lim, 'r--');
text(fp_original, y_lim(2) - 3, sprintf('fp_{original} = %.1f Hz', fp_original), 'HorizontalAlignment', 'right');
text(fp_quant, y_lim(2) - 3, sprintf('fp_{quant} = %.1f Hz', fp_quant), 'HorizontalAlignment', 'right');
% 绘制相位响应比较
% 添加图例
legend('原始滤波器', '量化滤波器', '原始通带截止频率', '量化通带截止频率');

subplot(2, 1, 2);
plot(f, unwrap(angle(H)) * 180/pi, 'LineWidth', 1.5);
hold on;
plot(f_quant, unwrap(angle(H_quant)) * 180/pi, 'LineWidth', 1.5);
grid on;
xlabel('频率 (Hz)');
ylabel('相位 (度)');
title('原始滤波器与量化滤波器的相位响应');
legend('原始滤波器', '量化滤波器');

% 直接形式1
Hd_df1 = dfilt.df1(b_quant, a_quant);

% 直接形式2
Hd_df2 = dfilt.df2(b_quant, a_quant);

% 将滤波器转换为级联形式
[sos, g] = tf2sos(b_quant, a_quant);
Hd_cascade = dfilt.df2sos(sos, g);

% 将传递函数转换为并联形式
[z, p, k] = tf2zp(b_quant, a_quant);
[s, g] = zp2sos(z, p, k);
% 使用 dfilt.parallel 创建并联型滤波器对象
Hd_parallel = dfilt.parallel(dfilt.df2sos(sos, g));

scale_factor = 2^(num_bits - 1);

b_int = round(abs(b_quant) * scale_factor);
a_int = round(abs(a_quant) * scale_factor);

[addercost_b,b_opt,~] = ragn(b_int);
[addercost_a,a_opt,~] = ragn(a_int);
b_opt = b_opt/scale_factor;
a_opt = a_opt/scale_factor;


% 直接形式1
Hd_df1_opt = dfilt.df1(b_opt, a_opt);
% 创建直接形式 1 转置滤波器
Hd_df1t_opt = dfilt.df1t(b_opt, a_opt);


% 直接形式2
Hd_df2_opt = dfilt.df2(b_opt, a_opt);

% 将滤波器转换为级联形式
[sos_opt, g_opt] = tf2sos(b_opt, a_opt);
Hd_cascade_opt = dfilt.df2sos(sos_opt, g_opt);

% 将传递函数转换为并联形式
[z_opt, p_opt, k_opt] = tf2zp(b_opt, a_opt);
[s_opt, g_opt] = zp2sos(z_opt, p_opt, k_opt);
Hd_parallel_opt = dfilt.df2sos(s_opt, g_opt);

% 比较滤波器的频率响应
% h1 = fvtool(Hd_df1, Hd_df1_opt, 'Analysis', 'freq');
% legend(h1, 'Direct Form I', 'Optimised Direct Form I');
% 
% h2 = fvtool(Hd_df2, Hd_df2_opt, 'Analysis', 'freq');
% legend(h2, 'Direct Form II', 'Optimised Direct Form II');
% 
% h3 = fvtool(Hd_cascade, Hd_cascade_opt, 'Analysis', 'freq');
% legend(h3, 'Cascade', 'Optimised Cascade');
% 
% h4 = fvtool(Hd_parallel, Hd_parallel_opt, 'Analysis', 'freq');
% legend(h4, 'Parallel', 'Optimised Parallel');


% 计算直接形式1和2的复杂度
function [num_adders, num_multipliers] = compute_direct_form_complexity(b, a)
num_adders = nnz(b) - 1 + nnz(a) - 1; % 非零系数的数量减去2（每个部分的第一个系数不需要加法器）
num_multipliers = nnz(b) + nnz(a); % 非零系数的数量
end

% 计算级联形式的复杂度
function [num_adders, num_multipliers] = compute_cascade_complexity(sos)
num_adders = 0;
num_multipliers = 0;
for i = 1:size(sos, 1)
    num_adders = num_adders + nnz(sos(i, 1:3)) + nnz(sos(i, 4:6)) - 2; % 每个二阶滤波器的非零系数数量减去2
    num_multipliers = num_multipliers + nnz(sos(i, :)); % 每个二阶滤波器的非零系数数量
end
end

% 计算并联形式的复杂度
function [num_adders, num_multipliers] = compute_parallel_complexity(s)
num_adders = 0;
num_multipliers = 0;
for i = 1:size(s, 1)
    num_adders = num_adders + nnz(s(i, 1:3)) + nnz(s(i, 4:6)) - 2; % 每个并联分支的非零系数数量减去2
    num_multipliers = num_multipliers + nnz(s(i, :)); % 每个并联分支的非零系数数量
end
end

% 直接形式1和2的复杂度计算
[adders_df1, multipliers_df1] = compute_direct_form_complexity(b_quant, a_quant);
[adders_df1_reduced, multipliers_df1_reduced] = compute_direct_form_complexity(b_opt, a_opt);

[adders_df2, multipliers_df2] = compute_direct_form_complexity(b_quant, a_quant);
[adders_df2_reduced, multipliers_df2_reduced] = compute_direct_form_complexity(b_opt, a_opt);

% 级联形式的复杂度计算
[adders_cascade, multipliers_cascade] = compute_cascade_complexity(sos);
[adders_cascade_reduced, multipliers_cascade_reduced] = compute_cascade_complexity(sos_opt);

% 并联形式的复杂度计算
[adders_parallel, multipliers_parallel] = compute_parallel_complexity(s);
[adders_parallel_reduced, multipliers_parallel_reduced] = compute_parallel_complexity(s_opt);

% 显示复杂度比较
disp('直接形式1 复杂度 (加法器数量, 乘法器数量):');
disp(['原始: ', num2str(adders_df1), ', ', num2str(multipliers_df1)]);
disp(['优化: ', num2str(adders_df1_reduced), ', ', num2str(multipliers_df1_reduced)]);

disp('直接形式2 复杂度 (加法器数量, 乘法器数量):');
disp(['原始: ', num2str(adders_df2), ', ', num2str(multipliers_df2)]);
disp(['优化: ', num2str(adders_df2_reduced), ', ', num2str(multipliers_df2_reduced)]);

disp('级联形式 复杂度 (加法器数量, 乘法器数量):');
disp(['原始: ', num2str(adders_cascade), ', ', num2str(multipliers_cascade)]);
disp(['优化: ', num2str(adders_cascade_reduced), ', ', num2str(multipliers_cascade_reduced)]);

disp('并联形式 复杂度 (加法器数量, 乘法器数量):');
disp(['原始: ', num2str(adders_parallel), ', ', num2str(multipliers_parallel)]);
disp(['优化: ', num2str(adders_parallel_reduced), ', ', num2str(multipliers_parallel_reduced)]);
