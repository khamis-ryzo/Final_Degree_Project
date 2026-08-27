package com.ryzo.Taxcompliance.config;

import com.ryzo.Taxcompliance.entity.TaxRule;
import com.ryzo.Taxcompliance.entity.User;
import com.ryzo.Taxcompliance.repository.TaxRuleRepository;
import com.ryzo.Taxcompliance.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import java.math.BigDecimal;
import java.util.List;
import java.util.Objects;

@Configuration
@RequiredArgsConstructor
@Slf4j
public class DataInitializer {

    private final TaxRuleRepository taxRuleRepository;
    private final UserRepository userRepository;
    private final BCryptPasswordEncoder passwordEncoder;

    @Bean
    public CommandLineRunner seedData() {
        return args -> {
            seedDefaultTaxRules();
            seedDefaultAdmin();
        };
    }

    private void seedDefaultTaxRules() {
        if (taxRuleRepository.count() > 0) {
            return;
        }

        log.info("Seeding default Tanzanian PAYE tax slabs");
        List<TaxRule> slabs = List.of(
                payeSlab("SLAB_PAYE_2024_1", "PAYE 0% - Up to TSh 270,000", 0, 270000, "0.00"),
                payeSlab("SLAB_PAYE_2024_2", "PAYE 8% - TSh 270,001 to 520,000", 270001, 520000, "8.00"),
                payeSlab("SLAB_PAYE_2024_3", "PAYE 20% - TSh 520,001 to 760,000", 520001, 760000, "20.00"),
                payeSlab("SLAB_PAYE_2024_4", "PAYE 25% - TSh 760,001 to 1,000,000", 760001, 1000000, "25.00"),
                payeSlab("SLAB_PAYE_2024_5", "PAYE 30% - TSh 1,000,001 to 10,000,000", 1000001, 10000000, "30.00"),
                openEndedPayeSlab("SLAB_PAYE_2024_6", "PAYE 35% - Above TSh 10,000,000", 10000001, "35.00")
        );
        taxRuleRepository.saveAll(Objects.requireNonNull(slabs));
        log.info("Seeded {} PAYE tax slabs", slabs.size());
    }

    private TaxRule payeSlab(String code, String name, long min, long max, String rate) {
        return buildSlab(code, name, BigDecimal.valueOf(min), BigDecimal.valueOf(max), rate);
    }

    private TaxRule openEndedPayeSlab(String code, String name, long min, String rate) {
        return buildSlab(code, name, BigDecimal.valueOf(min), null, rate);
    }

    private TaxRule buildSlab(String code, String name, BigDecimal min, BigDecimal max, String rate) {
        TaxRule slab = new TaxRule();
        slab.setRuleCode(code);
        slab.setRuleName(name);
        slab.setRuleType("TAX_SLAB");
        slab.setApplicableFromYear(2024);
        slab.setApplicableToYear(2030);
        slab.setMinIncome(min);
        slab.setMaxIncome(max);
        slab.setTaxRate(new BigDecimal(rate));
        slab.setPriority(0);
        slab.setIsActive(true);
        return slab;
    }

    private void seedDefaultAdmin() {
        if (!userRepository.findByRole("ROLE_ADMIN").isEmpty()) {
            return;
        }

        log.info("Seeding default admin user (username: admin / password: admin123)");
        User admin = new User();
        admin.setUsername("admin");
        admin.setEmail("admin@taxcompliance.local");
        admin.setPassword(passwordEncoder.encode("admin123"));
        admin.setTinNumber("100000000");
        admin.setFullName("System Administrator");
        admin.setRole("ROLE_ADMIN");
        admin.setIsActive(true);
        admin.setEmailVerified(true);
        userRepository.save(admin);
    }
}
