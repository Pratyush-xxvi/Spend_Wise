package com.example.Expense.Tracker;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.env.EnvironmentPostProcessor;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.MapPropertySource;

import java.util.HashMap;
import java.util.Map;

/**
 * Converts Render's postgres:// connection string to a valid JDBC URL
 * before Spring Boot initializes the DataSource.
 */
public class RenderDatasourcePostProcessor implements EnvironmentPostProcessor {

    @Override
    public void postProcessEnvironment(ConfigurableEnvironment environment, SpringApplication application) {
        Map<String, Object> props = new HashMap<>();

        // Try SPRING_DATASOURCE_URL first (may be set on Render dashboard)
        String url = System.getenv("SPRING_DATASOURCE_URL");

        if (url != null && !url.isBlank()) {
            // Convert postgres:// or postgresql:// → jdbc:postgresql://
            if (url.startsWith("postgres://") || url.startsWith("postgresql://")) {
                url = url.replaceFirst("^postgres(ql)?://", "jdbc:postgresql://");
            }
            props.put("spring.datasource.url", url);
        } else {
            // Fall back to individual host/port/name components injected by render.yaml
            String host = System.getenv("DB_HOST");
            String port = System.getenv("DB_PORT");
            String name = System.getenv("DB_NAME");
            if (host != null && !host.isBlank()) {
                String jdbcUrl = "jdbc:postgresql://" + host + ":" + (port != null ? port : "5432") + "/" + (name != null ? name : "spendwise");
                props.put("spring.datasource.url", jdbcUrl);
            }
        }

        if (!props.isEmpty()) {
            // Highest priority — overrides application.properties and env vars
            environment.getPropertySources().addFirst(
                new MapPropertySource("renderDatasourceFix", props)
            );
        }
    }
}
