package com.rvcode.mybank.model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

public class Transaction {
    private String id;
    private Integer amount;
    private String reference;
    private String timestamp;
    private TransactionType transactionType;
    private Integer balance;

    private DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    public Transaction(){
    }

    public Transaction(Integer amount, String reference, TransactionType type, Integer balance){
        this.id = UUID.randomUUID().toString();
        try {
            this.timestamp = LocalDateTime.now().format(formatter);
        } catch (IllegalArgumentException e){
            e.printStackTrace();
        }
        this.amount = amount;
        this.reference = reference;
        this.transactionType = type;
        this.balance = balance;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public Integer getAmount() {
        return amount;
    }

    public void setAmount(Integer amount) {
        this.amount = amount;
    }

    public String getReference() {
        return reference;
    }

    public void setReference(String reference) {
        this.reference = reference;
    }

    public String getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(String timestamp) {
        this.timestamp = timestamp;
    }

    public TransactionType getTransactionType() {
        return transactionType;
    }

    public void setTransactionType(TransactionType transactionType) {
        this.transactionType = transactionType;
    }

    public Integer getBalance() {
        return balance;
    }

    public void setBalance(Integer balance) {
        this.balance = balance;
    }
}
