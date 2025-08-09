module tb_apb;

  // APB Interface Signals
  logic pclk;
  logic presetn;
  logic pselx;
  logic penable;
  logic pwrite;
  logic [31:0] paddr;
  logic [31:0] pwdata;
  logic [31:0] prdata;
  logic pready;
  logic pslverr;

  // Clock generation
  initial pclk = 0;
  always #5 pclk = ~pclk; // 100MHz Clock (10ns period)

  // Simulate wait states by delaying the pready signal
  reg [2:0] wait_counter;  // Counter to simulate wait states

  initial begin
    // Initialize all signals
    presetn = 0;
    pselx = 0;
    penable = 0;
    pwrite = 0;   // Read operation
    paddr = 0;
    pwdata = 0;
    pready = 0;   // Assume slave is not ready initially
    prdata = 32'hDEADBEEF; // Example read data
    pslverr = 0;
    wait_counter = 0; // Start with no wait states

    // Reset sequence
    #10;
    presetn = 1; // Deassert reset

    // Wait for reset to de-assert
    #10;

    // Start Read Transaction
    @(posedge pclk);
    pselx  <= 1;
    paddr  <= 32'h0000_0040; // Set valid address
    pwrite <= 0; // Read
    penable <= 0; // Setup phase

    @(posedge pclk);
    penable <= 1; // Enable phase starts

    // Simulate wait states: Keep pready low for a few cycles
    wait_counter = 3;  // Set wait states to 3 cycles
    pready = 0;  // Initially not ready
    while (wait_counter > 0) begin
      @(posedge pclk);
      wait_counter = wait_counter - 1;
    end

    pready = 1; // Slave is now ready after wait states

    // Wait for slave to be ready
    wait(pready == 1);

    @(posedge pclk);
    pselx  <= 0;
    penable <= 0;
    paddr <= 0;  // Optional: clear address

    $display("Read Data = %h", prdata);

    // Finish simulation after a little delay
    #20;
    $finish;
  end

  // Dumping waveform
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_apb);
  end

endmodule