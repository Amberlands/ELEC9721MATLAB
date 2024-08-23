% 调用函数并测试
% (0.7, 2, 2)
% (-8/3, 3, 3)
% (-2, 3, 3)
% (2/3, 3, 3)
% (9.8765, 4, 4)
[de, fixedX, err] = DecimalToFixedPoint(9.8765, 4, 4);
disp(['Decimal Equivalent: ', num2str(de)]);
disp(['Fixed Point Representation: ', fixedX]);
disp(['Error: ', num2str(err), '%']);

function [de, fixedX, err] = DecimalToFixedPoint(X, I, F)
    % 判断输入是否为负数
    isNegative = X < 0;
    
    % 将负数转换为正数进行处理
    if isNegative
        X = abs(X);
    end
    
    % 计算整数和小数部分
    intPart = floor(X);
    fracPart = X - intPart;
    
    % 将整数部分转换为二进制
    intBin = '';
    for i = I:-1:1
        bit = mod(intPart, 2);
        intPart = floor(intPart / 2);
        intBin = [num2str(bit) intBin]; % 将二进制位添加到字符串前面
    end
    
    % 将小数部分转换为二进制
    fracBin = '';
    for i = 1:F
        fracPart = fracPart * 2;
        if fracPart >= 1
            fracBin = [fracBin '1'];
            fracPart = fracPart - 1;
        else
            fracBin = [fracBin '0'];
        end
    end
    
    % 四舍五入处理小数部分
    if fracPart >= 0.5
        carry = 1;
        for i = length(fracBin):-1:1
            if fracBin(i) == '0'
                fracBin(i) = '1';
                carry = 0;
                break;
            else
                fracBin(i) = '0';
            end
        end
        if carry == 1
            for i = length(intBin):-1:1
                if intBin(i) == '0'
                    intBin(i) = '1';
                    carry = 0;
                    break;
                else
                    intBin(i) = '0';
                end
            end
        end
    end
    
    % 组合整数和小数部分
    fixedX = [intBin '.' fracBin];
    
    % 如果是负数，使用二进制补码
    if isNegative
        % 反转所有位（忽略小数点）
        for i = 1:length(fixedX)
            if fixedX(i) ~= '.'
                fixedX(i) = char(bitxor(uint8(fixedX(i) == '1'), 1) + '0');
            end
        end
        
        % 加1
        carry = 1;
        for i = length(fixedX):-1:1
            if fixedX(i) == '.'
                continue;
            end
            if fixedX(i) == '1'
                fixedX(i) = '0';
            else
                fixedX(i) = '1';
                carry = 0;
                break;
            end
        end
        if carry == 1
            error('Overflow Error');
        end
    end
    
    % 计算十进制等效值
    de = 0;
    for i = 1:I
        de = de + str2double(intBin(i)) * 2^(I-i);
    end
    for i = 1:F
        de = de + str2double(fracBin(i)) * 2^(-i);
    end
    if isNegative
        de = -de;
    end
    
    % 计算误差
    err = abs((X - abs(de)) / X * 100);
end
