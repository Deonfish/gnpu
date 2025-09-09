template = """

    // -------- shift_reg{index}

    wire [0:0]                                   s{index}_shin_valid_i;
    wire [`SARRAY_LOAD_WIDTH/`SARRAY_H-1:0]      s{index}_shin_data_i;
    wire [0:0]                                   s{index}_sho_valid_o;
    wire [`SARRAY_LOAD_WIDTH/`SARRAY_H-1:0]      s{index}_sho_data_o;

    shift_reg #({param}) u_shift_reg{index} (
        .clk           (clk),
        .rst_n         (rst_n),
        .shin_valid_i  (s{index}_shin_valid_i),
        .shin_data_i   (s{index}_shin_data_i),
        .sho_valid_o   (s{index}_sho_valid_o),
        .sho_data_o    (s{index}_sho_data_o)
    );

    assign s{index}_shin_valid_i = shin_valid_i;
    assign s{index}_shin_data_i = shin_data_i[(`SARRAY_LOAD_WIDTH/`SARRAY_H*{param})-1:(`SARRAY_LOAD_WIDTH/`SARRAY_H*{index})];
    assign sho_valid_o[{index}] = s{index}_sho_valid_o;
    assign sho_data_o[(`SARRAY_LOAD_WIDTH/`SARRAY_H*{param})-1:(`SARRAY_LOAD_WIDTH/`SARRAY_H*{index})] = s{index}_sho_data_o;
"""

with open("shift_reg_instances.v", "w") as f:
    for i in range(64):
        # 计算参数值 (index+1)
        param = i + 1
        # 替换模板中的占位符
        code = template.format(index=i, param=param)
        f.write(code)
        f.write("\n")  # 添加空行分隔每个实例