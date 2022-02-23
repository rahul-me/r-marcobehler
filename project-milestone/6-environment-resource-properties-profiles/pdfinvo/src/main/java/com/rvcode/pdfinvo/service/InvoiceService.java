package com.rvcode.pdfinvo.service;

import com.rvcode.pdfinvo.model.Invoice;
import com.rvcode.pdfinvo.model.User;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

@Component
public class InvoiceService {


    private final UserService userService;
    private final String cdnUrl;

    public InvoiceService(UserService userService, @Value("${cdn.url}") String cdnUrl) {
        this.userService = userService;
        this.cdnUrl = cdnUrl;
    }

    @PostConstruct
    public void init() {
        System.out.println("Fetching pdf invoice from S3...");
    }

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

        Invoice inv = new Invoice(userId, amount, cdnUrl+"/images/default/sample.pdf");
        invoices.add(inv);
        return inv;
    }
}
