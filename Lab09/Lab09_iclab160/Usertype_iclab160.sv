`ifndef USERTYPE
`define USERTYPE

package usertype;

typedef enum logic  [1:0] { Index_Check	        = 2'h0,
                            Update	            = 2'h1,
							Check_Valid_Date    = 2'h2
							}  Action ;

typedef enum logic  [1:0] { No_Warn       		= 2'b00, 
                            Date_Warn           = 2'b01, 
							Risk_Warn           = 2'b10,
						    Data_Warn	        = 2'b11  
}  Warn_Msg ;

typedef enum logic  [2:0] { Formula_A = 3'h0,
							Formula_B = 3'h1,
							Formula_C = 3'h2,
							Formula_D = 3'h3,
                            Formula_E = 3'h4,
                            Formula_F = 3'h5,
                            Formula_G = 3'h6,
                            Formula_H = 3'h7
}  Formula_Type; 

typedef enum logic  [1:0]	{ Insensitive  = 2'b00,
							  Normal  = 2'b01,
							  Sensitive  = 2'b11
} Mode ;

typedef logic [11:0] Index;
typedef logic [3:0] Month;
typedef logic [4:0] Day;
typedef logic [7:0] Data_No;

typedef struct packed {
    Month M;
    Day D;
} Date;

typedef struct packed {
    Index Index_A;
    Index Index_B;
    Index Index_C;
    Index Index_D;
    Month M;
    Day D;     
} Data_Dir;

typedef struct packed {
	Formula_Type Formula_Type_O;
    Mode Mode_O;
} Order_Info;

typedef union packed{ 
    Action [35:0] d_act;  // 2
    Formula_Type [23:0] d_formula;  // 3
    Mode [35:0] d_mode;  // 2
    Date [7:0] d_date;  // 9
    Data_No [8:0] d_data_no;  // 8
    Index [5:0] d_index;  // 12
} Data;

//################################################## Don't revise the code above

//#################################
// Type your user define type here
//#################################
typedef logic [47:0] All_index;

typedef enum logic  [3:0]	{ IDLE = 0,
                            GET_IPUT_INDEX_CHECK = 1,
                            GET_IPUT_UPDATE = 2,
                            GET_IPUT_CHECK_VALID_DATE = 3,
                            WAIT_DATA = 4,
                            CAL_IPUT_INDEX_CHECK= 5,
                            CAL_IPUT_UPDATE = 6,
                            CAL_IPUT_CHECK_VALID_DATE = 7,
                            DATA_WARNING_OUT = 8,
                            DATE_WARNING_OUT = 9,
                            RISK_WARNING_OUT = 10,
                            NO_WARNING_OUT = 11
} STATE;
typedef enum logic  [2:0]	{ DRAM_IDLE = 0,
                            DRAM_READ_ADDR = 1,
                            DRAM_READ_DATA = 2,
                            DRAM_WAIT = 3,
                            DRAM_WRITE_ADDR = 4,
                            DRAM_WRITE_DATA = 5,
                            DRAM_WRITE_RESPONSE = 6
} DRAM_STATE;


//################################################## Don't revise the code below
endpackage

import usertype::*; //import usertype into $unit

`endif