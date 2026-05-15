interface USB2p0_PHY_interface(input bit phy_clk);
 
    logic Dp;
    logic Dm;
    logic Vbus;
    logic Gnd;
 
    clocking cb_phy_driver @(posedge phy_clk);

        default input #1 output #1;
        output Dp;
        output Dm;
        output Vbus;
        output Gnd;

    endclocking
 
    clocking cb_phy_monitor @(negedge phy_clk);
        default input #1 output #1;
        input Dp;
        input Dm;
        input Vbus;
        input Gnd;
    endclocking
 
 
    modport mp_phy_driver(clocking cb_phy_driver);
 
    modport mp_phy_monitor(clocking cb_phy_monitor);
 
endinterface
 
