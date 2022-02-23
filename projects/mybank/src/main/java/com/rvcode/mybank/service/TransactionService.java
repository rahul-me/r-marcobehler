package com.rvcode.mybank.service;

import com.rvcode.mybank.model.Transaction;
import com.rvcode.mybank.model.TransactionType;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

@Component
public class TransactionService {

    private AccountService accountService;
    private List<Transaction> transactions = new CopyOnWriteArrayList<>();
    public TransactionService(AccountService accountService){
        this.accountService = accountService;
    }

    public Transaction createTransaction(Integer amount, String reference, TransactionType transactionType){
        Integer balance = accountService.creditOrDebit(amount, transactionType);
        Transaction transaction = new Transaction(amount, reference, transactionType, balance);
        transactions.add(transaction);
        return transaction;
    }

    public List<Transaction> finAll(){
        return transactions;
    }
}
