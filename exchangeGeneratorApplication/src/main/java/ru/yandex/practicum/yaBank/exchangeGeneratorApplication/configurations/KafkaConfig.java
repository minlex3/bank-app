package ru.yandex.practicum.yaBank.exchangeGeneratorApplication.configurations;

import com.fasterxml.jackson.core.type.TypeReference;
import lombok.RequiredArgsConstructor;
import org.apache.kafka.clients.admin.NewTopic;
import org.apache.kafka.common.serialization.StringSerializer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.kafka.KafkaProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.config.TopicBuilder;
import org.springframework.kafka.core.DefaultKafkaProducerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.serializer.JsonSerializer;
import ru.yandex.practicum.yaBank.exchangeGeneratorApplication.dto.CurrencyRateDto;

import java.util.List;

@Configuration
@RequiredArgsConstructor
public class KafkaConfig {

    @Autowired
    private final KafkaProperties kafkaProperties;


    @Bean
    public KafkaTemplate<String, List<CurrencyRateDto>> kafkaTemplate() {
        var producerFactory = new DefaultKafkaProducerFactory<String, List<CurrencyRateDto>>(
                kafkaProperties.buildProducerProperties(null),
                new StringSerializer(),
                new JsonSerializer<>(new TypeReference<List<CurrencyRateDto>>() {
                })
        );
        return new KafkaTemplate<>(producerFactory);
    }

    @Bean
    public NewTopic topicExchange() {
        return TopicBuilder.name("exchange")
                .partitions(3)
                .replicas(1)
                .compact()
                .build();
    }

}