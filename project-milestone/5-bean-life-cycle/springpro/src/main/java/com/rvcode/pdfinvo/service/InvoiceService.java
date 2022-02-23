package com.rvcode.pdfinvo.service;

import com.rvcode.pdfinvo.model.Invoice;
import com.rvcode.pdfinvo.model.User;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

@Component
public class InvoiceService implements InitializingBean {


    private final UserService userService;

    public InvoiceService(UserService userService) {
        this.userService = userService;
    }

//    @PostConstruct
//    public void init() {
//        System.out.println("Fetching pdf invoice from S3...");
//        // to do
//    }

    @PreDestroy
    public void shutdown() {
        System.out.println("Deleting downloaded templates...");
    }

    List<Invoice> invoices = new CopyOnWriteArrayList<>();

    public List<Invoice> findAll() {
        return invoices;
    }

    public Invoice create(String userId, Integer amount) {
        User user = userService.findById(userId);
        if (user == null) {
            throw new IllegalStateException();
        }

        Invoice inv = new Invoice(userId, amount, "http://www.africau.edu/images/default/sample.pdf");
        invoices.add(inv);
        return inv;
    }

    @Override
    public void afterPropertiesSet() throws Exception {
        System.out.println("Fetching template from S3 server...");
        // To do for fetching templete
    }
}
