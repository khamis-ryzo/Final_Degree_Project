package com.ryzo.Taxcompliance.repository;

import com.ryzo.Taxcompliance.entity.Subscription;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.atomic.AtomicLong;
import java.util.stream.Collectors;

@Repository
public class InMemorySubscriptionRepository {

    private final Map<Long, Subscription> store = new LinkedHashMap<>();
    private final AtomicLong idGen = new AtomicLong(1);

    public List<Subscription> findAll() {
        return new ArrayList<>(store.values());
    }

    public Optional<Subscription> findById(Long id) {
        return Optional.ofNullable(store.get(id));
    }

    public List<Subscription> findByUserId(Long userId) {
        return store.values().stream().filter(s -> Objects.equals(s.getUserId(), userId)).collect(Collectors.toList());
    }

    public Optional<Subscription> findFirstByUserIdOrderByIdDesc(Long userId) {
        return store.values().stream()
                .filter(s -> Objects.equals(s.getUserId(), userId))
                .sorted(Comparator.comparing(Subscription::getId).reversed())
                .findFirst();
    }

    public Subscription save(Subscription s) {
        if (s.getId() == null) {
            s.setId(idGen.getAndIncrement());
        }
        if (s.getCreatedAt() == null) {
            s.setCreatedAt(LocalDateTime.now());
        }
        s.setUpdatedAt(LocalDateTime.now());
        store.put(s.getId(), s);
        return s;
    }

    public void deleteById(Long id) {
        store.remove(id);
    }

    public long count() {
        return store.size();
    }

    public long countByStatus(String status) {
        return store.values().stream().filter(s -> status.equals(s.getStatus())).count();
    }

    public long countByPlanAndStatus(String plan, String status) {
        return store.values().stream().filter(s -> plan.equals(s.getPlan()) && status.equals(s.getStatus())).count();
    }
}
