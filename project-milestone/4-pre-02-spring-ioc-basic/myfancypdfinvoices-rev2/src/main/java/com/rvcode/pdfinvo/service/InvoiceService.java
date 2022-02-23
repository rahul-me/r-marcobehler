package com.rvcode.pdfinvo.service;

import com.rvcode.pdfinvo.context.Application;
import com.rvcode.pdfinvo.model.Invoice;
import com.rvcode.pdfinvo.model.User;

import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

public class InvoiceService {

    private final UserService userService;

    public InvoiceService(UserService userService){
        this.userService = userService;
    }

    List<Invoice> invoices = new CopyOnWriteArrayList<>();

    public List<Invoice> findAll(){
        return invoices;
    }

    public Invoice create(String userId, Integer amount){
        User user = userService.findById(userId);
        if(user == null){
            throw new IllegalStateException();
        }

        Invoice inv = new Invoice(userId, amount, "http://www.africau.edu/images/default/sample.pdf");
        invoices.add(inv);
        return inv;
    }
}
