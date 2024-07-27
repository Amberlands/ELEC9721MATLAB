% 测试函数
disp(FixedPointToDecimal('011.101', 3, 3)); % 预期输出: 3.625
disp(FixedPointToDecimal('100.011', 3, 3)); % 预期输出: -3.625

function [X] = FixedPointToDecimal(fixedX, I, F)
    % 检查输入是否为空
    if nargin < 2
        error('Fixed point representation and number of bits information must be provided');
    end
    
    % 查找小数点的位置
    pointIndex = find(fixedX == '.');
    
    % 分离整数部分和小数部分
    intBin = fixedX(1:pointIndex-1);
    fracBin = fixedX(pointIndex+1:end);
    
    % 初始化结果
    X = 0;
    
    % 处理正数情况
    % 将整数部分从二进制转换为十进制
    for i = 1:I
        X = X + str2double(intBin(i)) * 2^(I-i);
    end
    
    % 将小数部分从二进制转换为十进制
    for i = 1:F
        X = X + str2double(fracBin(i)) * 2^(-i);
    end
    
    % 检查是否是负数（通过检查最高位）
    if intBin(1) == '1'
        % 反码补码处理
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
        
        % 重新计算反码补码后的十进制值
        intBin = fixedX(1:pointIndex-1);
        fracBin = fixedX(pointIndex+1:end);
        X = 0;
        
        % 将整数部分从二进制转换为十进制
        for i = 1:I
            X = X + str2double(intBin(i)) * 2^(I-i);
        end
        
        % 将小数部分从二进制转换为十进制
        for i = 1:F
            X = X + str2double(fracBin(i)) * 2^(-i);
        end
        
        % 负号处理
        X = -X;
    end
end

