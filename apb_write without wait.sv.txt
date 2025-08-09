module tb_apb;

  // Declare signals
  reg         pclk;
  reg         prst;
  reg [31:0]  paddr;
  reg         pselx;
  reg         penable;
  reg         pwrite;
  reg [31:0]  pwdata;
  wire        pready;
  wire        pslverr;
  wire [31:0] prdata;
  wire [31:0] temp;

  // Instantiate the design
  apb DUT (
    .pclk(pclk),
    .prst(prst),
    .paddr(paddr),
    .pselx(pselx),
    .penable(penable),
    .pwrite(pwrite),
    .pwdata(pwdata),
    .pready(pready),
    .pslverr(pslverr),
    .prdata(prdata),
    .temp(temp)
  );

  // Clock generation
  initial begin
    pclk = 0;
    forever #5 pclk = ~pclk; // 10ns clock
  end

  // Test sequence
  initial begin
    // Initialize signals
    prst    = 0;
    paddr   = 0;
    pselx   = 0;
    penable = 0;
    pwrite  = 0;
    pwdata  = 0;

    // Apply reset
    #12 prst = 1;

    // Wait one clock cycle after reset
    @(posedge pclk);

    // Write transaction - address 5, data 32'hDEADBEEF
    @(posedge pclk);
    paddr   = 5;
    pwdata  = 32'hDEADBEEF;
    pwrite  = 1;
    pselx   = 1;
    penable = 0;  // Setup phase

    @(posedge pclk);
    penable = 1;  // Access phase

    @(posedge pclk);
    // Deactivate signals
    pselx   = 0;
    penable = 0;
    pwrite  = 0;

    @(posedge pclk);
    // Check output
    $display("Write Temp Data at addr %0d: %h", paddr, temp);

    #20 $finish;
  end

  // Dump waveform
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_apb);
  end
endmodule