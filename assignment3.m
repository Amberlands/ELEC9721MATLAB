% 设置滤波器参数
fs = 16000;  % 采样率
fp = 3400;   % 通带截止频率 (Hz
fsb = 3800 + (4200 - 3800) * rand(); % 随机阻带截止频率
disp(['随机生成阻带频率大小: ', num2str(fsb), ' Hz']);
Rp = 1; % 通带波动
Rs = 30; % 阻带衰减


scale_factor = 2^(num_bits - 1);


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
[sos, g] = tf2sos(b, a);
Hd_cascade = dfilt.df2sos(sos, g);
% 量化每个二阶节的系数
sos_quant = round(sos * scale_factor) / scale_factor;
% 将传递函数转换为并联形式
[z, p, k] = tf2zp(b, a);
[s, g_s] = zp2sos(z, p, k);
s_quant = round(s * scale_factor) / scale_factor;
% 使用 dfilt.parallel 创建并联型滤波器对象
Hd_parallel = dfilt.parallel(dfilt.df2sos(s_quant, g_s));


b_int = b_quant.*scale_factor;
a_int = a_quant.*scale_factor;

% 直接型
% 使用RAG-N算法优化分子系数
[addercost_b, vertices_b, optimalflag_b] = ragn(b_int);
% 使用RAG-N算法优化分母系数
[addercost_a, vertices_a, optimalflag_a] = ragn(a_int);

disp('优化前的分子系数加法器数量:');
disp(length(b_int));
disp('优化前的分母系数加法器数量:');
disp(length(a_int));

disp('优化后的分子系数加法器数量:');
disp(addercost_b);
disp('优化后的分母系数加法器数量:');
disp(addercost_a);

%级联型
% 提取每个二阶段的系数
[num_stages_sos, ~] = size(sos_quant);
sos_quant = sos_quant*scale_factor;

b_coeffs_sos = sos_quant(:, 1:3); % 分子系数
a_coeffs_sos = sos_quant(:, 4:6); % 分母系数

% 初始化加法器数量
total_addercost_b_sos = 0;
total_addercost_a_sos = 0;
num_adders_b_sos = 0;
num_adders_a_sos = 0;

for i = 1:num_stages_sos
    % 每个二阶滤波器段的分子和分母加法器数量
    num_adders_b_sos = num_adders_b_sos + 2; % 每个二阶段分子需要2个加法器
    num_adders_a_sos = num_adders_a_sos + 2; % 每个二阶段分母需要2个加法器
    % 提取每个二阶段的分子和分母系数
    b_stage = b_coeffs_sos(i, :);
    a_stage = a_coeffs_sos(i, :);

    % 使用RAG-N算法优化分子系数
    [addercost_b_sos, ~, ~] = ragn(b_stage);
    % 使用RAG-N算法优化分母系数
    [addercost_a_sos, ~, ~] = ragn(a_stage);

    % 累加加法器数量
    total_addercost_b_sos = total_addercost_b_sos + addercost_b_sos;
    total_addercost_a_sos = total_addercost_a_sos + addercost_a_sos;
end

disp('优化前的分子系数加法器数量:');
disp(num_adders_b_sos);
disp('优化前的分母系数加法器数量:');
disp(num_adders_a_sos);
disp('优化后的总分子系数加法器数量:');
disp(total_addercost_b_sos);
disp('优化后的总分母系数加法器数量:');
disp(total_addercost_a_sos);

%并联型
% 提取每个二阶段的系数
[num_stages_s, ~] = size(s);
s_quant = s_quant*scale_factor;
b_coeffs_s = s_quant(:, 1:3); % 分子系数
a_coeffs_s = s_quant(:, 4:6); % 分母系数

% 初始化加法器数量
total_addercost_b_s = 0;
total_addercost_a_s = 0;
num_adders_b_s = 0;
num_adders_a_s = 0;

for i = 1:num_stages_s
    % 每个二阶滤波器段的分子和分母加法器数量
    num_adders_b_s = num_adders_b_s + 2; % 每个二阶段分子需要2个加法器
    num_adders_a_s = num_adders_a_s + 2; % 每个二阶段分母需要2个加法器
    % 提取每个二阶段的分子和分母系数
    b_stage = b_coeffs_s(i, :);
    a_stage = a_coeffs_s(i, :);

    % 使用RAG-N算法优化分子系数
    [addercost_b_s, ~, ~] = ragn(b_stage);
    % 使用RAG-N算法优化分母系数
    [addercost_a_s, ~, ~] = ragn(a_stage);

    % 累加加法器数量
    total_addercost_b_s = total_addercost_b_s + addercost_b_s;
    total_addercost_a_s = total_addercost_a_s + addercost_a_s;
end


disp('优化前的分子系数加法器数量:');
disp(num_adders_b_s);
disp('优化前的分母系数加法器数量:');
disp(num_adders_a_s);
disp('优化后的总分子系数加法器数量:');
disp(total_addercost_b_s);
disp('优化后的总分母系数加法器数量:');
disp(total_addercost_a_s);




