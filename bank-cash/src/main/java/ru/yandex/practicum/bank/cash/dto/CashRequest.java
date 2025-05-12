package ru.yandex.practicum.bank.cash.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.math.BigDecimal;

@AllArgsConstructor
@Getter
public class CashRequest {
    private String accountId;
    private BigDecimal amount;
}
