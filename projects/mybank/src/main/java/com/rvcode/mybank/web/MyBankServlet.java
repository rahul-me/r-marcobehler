package com.rvcode.mybank.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.rvcode.mybank.context.MyBankApplicationConfiguration;
import com.rvcode.mybank.model.Transaction;
import com.rvcode.mybank.model.TransactionType;
import com.rvcode.mybank.service.TransactionService;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

public class MyBankServlet extends HttpServlet {

    private TransactionService transactionService;
    private ObjectMapper objectMapper;

    @Override
    public void init() throws ServletException {
        AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext(MyBankApplicationConfiguration.class);
        this.transactionService = ctx.getBean(TransactionService.class);
        this.objectMapper = ctx.getBean(ObjectMapper.class);
    }

    @Override
    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if(request.getRequestURI().equalsIgnoreCase("/transactions")){
            response.setContentType("application/json; charset=UTF-8");
            List<Transaction> transactions = transactionService.finAll();
            String json = objectMapper.writeValueAsString(transactions);
            response.getWriter().print(json);
        } else {
            response.setContentType("text/html");
            response.getWriter().print("<h2>Hello Word</h2>" +
                    "<br/>" +
                    "This is my second html page");
        }
    }

    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if(request.getRequestURI().equalsIgnoreCase("/transaction")){
            Integer amount = Integer.valueOf(request.getParameter("amount"));
            String reference = request.getParameter("reference");
            String transactionType = request.getParameter("type");
            Transaction transaction = transactionService.createTransaction(amount, reference, TransactionType.valueOf(transactionType));

            response.setContentType("application/json; charset=UTF-8");
            String json = objectMapper.writeValueAsString(transaction);
            response.getWriter().print(json);
        } else {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
        }
    }
}
