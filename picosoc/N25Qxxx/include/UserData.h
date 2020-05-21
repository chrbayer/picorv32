// ************************************ 
//
// User Data definition file :
//
//      here are defined all parameters
//      that the user can change
//
// ************************************ 

`define N25Q128A13E

`define FILENAME_mem "artya7c_fw.hex" // Memory File Name 
`define FILENAME_sfdp "sfdp.vmf" // SFDP File Name 

// default
//`define NVCR_DEFAULT_VALUE 'hFFFF
// RB: match
// load: diff

// default
//`define NVCR_DEFAULT_VALUE 'hFFFF
// RB: match
// load: diff

// XIP for SIO Read
//`define NVCR_DEFAULT_VALUE 'hF1FF
// RB: diff
// load: diff

// XIP for QOFR
//`define NVCR_DEFAULT_VALUE 'hF7FF
// RB: diff
// load: diff

// XIP for QIOFR
`define NVCR_DEFAULT_VALUE 'hF9FF
// RB: match
// load: diff
