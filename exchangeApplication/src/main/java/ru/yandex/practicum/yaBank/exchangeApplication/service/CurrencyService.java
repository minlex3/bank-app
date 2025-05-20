package ru.yandex.practicum.yaBank.exchangeApplication.service;

import org.springframework.stereotype.Service;
import ru.yandex.practicum.yaBank.exchangeApplication.dto.CurrencyDto;

import java.util.List;

@Service
public class CurrencyService {

    public List<CurrencyDto> getCurrency() {
        return List.of(
                CurrencyDto.builder().currency("USD").title("US Dollar").build(),
                CurrencyDto.builder().currency("RUB").title("Russian Ruble").build(),
                CurrencyDto.builder().currency("EUR").title("Euro").build()
        );
    }

}
