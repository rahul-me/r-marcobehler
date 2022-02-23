package com.rvcode.pdfinvo.context;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.rvcode.pdfinvo.model.User;
import com.rvcode.pdfinvo.service.InvoiceService;
import com.rvcode.pdfinvo.service.UserService;

public class Application {
    public static final UserService userService = new UserService();
    public static final InvoiceService invoiceService = new InvoiceService(userService);
    public static final ObjectMapper mapper = new ObjectMapper();

}
