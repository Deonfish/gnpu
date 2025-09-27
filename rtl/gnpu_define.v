`define TINST_TYPE_WIDTH 		2
`define ADDR_WIDTH 				64
`define TMMA_PRECISION_WIDTH 	3
`define SARRAY_LOAD_WIDTH 		2048
`define SARRAY_STORE_WIDTH 		2048
`define TMMA_CNT_WIDTH          6
`define SARRAY_H				64
`define SARRAY_W				64
`define A_BUF_NUM               2
`define PE_INPUT_DATA_WIDTH		32
`define TLOAD_DATAW_WIDTH       3

`define COP_INST_WIDTH          32
`define COP_REG_WIDTH           64
`define COP_FUNC3_TLOAD         3'b000
`define COP_FUNC3_PRELOADC      3'b001
`define COP_FUNC3_TMMA          3'b010
`define COP_FUNC3_POSTSTOREC    3'b011
`define COP_FUNC3_PRELOADA      3'b100
`define COP_FUNC3_TSTORE        3'b101

`define TMMAQ_DEPTH             8
`define TMMAQ_PTR_WIDTH         3

`define SPAD_BANK_NUM           4
`define SPAD_BANK_NUM_WIDTH     2
`define SPAD_BANK_DATA_WIDTH    (256*8)
`define SPAD_BANK_ADDR_WIDTH    11

`define TINST_TYPE_TMMA 		0
`define TINST_TYPE_PRELOADC 	1
`define TINST_TYPE_POSTSTOREC 	2
`define TINST_TYPE_PRELOADA 	3

`define TLOAD_DW_BYTE_IDX       0
`define TLOAD_DW_2BYTE_IDX      1
`define TLOAD_DW_4BYTE_IDX      2

`define PE_DATA_TYPE_C			0
`define PE_DATA_TYPE_A			1

`define FAKE_PE