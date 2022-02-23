package com.rvcode.mybank.service;

import com.rvcode.mybank.model.TransactionType;
import org.springframework.stereotype.Component;

@Component
public class AccountService {
    private Integer accountBalance = 0;

   public Integer creditOrDebit(Integer amount, TransactionType transactionType) {
       if(transactionType == TransactionType.CREDIT){
           this.accountBalance += amount;
       } else if(transactionType == TransactionType.DEBIT){
           this.accountBalance -= amount;
       } else {
           throw new IllegalArgumentException();
       }

       return this.accountBalance;
   }
}
