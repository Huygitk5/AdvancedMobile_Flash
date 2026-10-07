package com.flash.sync.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import javax.persistence.EntityManager;
import javax.persistence.TypedQuery;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * Đọc delta theo cột updated_at cho mọi entity có trường {@code updatedAt}
 * (index *_updated trong V1__init.sql phục vụ đúng truy vấn này).
 */
@Component
@RequiredArgsConstructor
class DeltaReader {

    private final EntityManager entityManager;

    /**
     * @param filter điều kiện JPQL thêm trên alias {@code e} (VD: {@code "e.userId = :userId"}), null nếu không có
     * @return tối đa {@code window.limit} dòng (nhiều hơn chỉ khi trùng updated_at ở ranh giới), updated_at tăng dần
     */
    <T> List<T> read(DeltaWindow window, Class<T> type, String filter, Map<String, Object> params,
                     Function<T, Instant> updatedAt) {
        int limit = window.getLimit();
        List<T> rows = query(type, filter, params, "e.updatedAt > :since", window.getSince())
                .setMaxResults(limit + 1)
                .getResultList();
        if (rows.size() <= limit) {
            return rows;
        }

        // Dòng thứ limit+1 là dòng đầu tiên chưa trả. Cắt trước mọi dòng cùng updated_at với nó
        // để lần sau đọc "> cutoff - 1ms" lấy lại trọn nhóm đó (DATETIME(3) chính xác tới ms).
        Instant cutoff = updatedAt.apply(rows.get(limit));
        List<T> page = rows.stream().filter(r -> updatedAt.apply(r).isBefore(cutoff)).collect(Collectors.toList());
        if (!page.isEmpty()) {
            window.truncatedAt(cutoff.minusMillis(1));
            return page;
        }
        // Hơn limit dòng cùng một updated_at (VD: cập nhật hàng loạt): trả trọn nhóm để không lặp vô hạn
        List<T> ties = new ArrayList<>(query(type, filter, params, "e.updatedAt = :since", cutoff).getResultList());
        window.truncatedAt(cutoff);
        return ties;
    }

    private <T> TypedQuery<T> query(Class<T> type, String filter, Map<String, Object> params,
                                    String timeCondition, Instant time) {
        String jpql = "select e from " + type.getSimpleName() + " e where " + timeCondition
                + (filter != null ? " and " + filter : "") + " order by e.updatedAt";
        TypedQuery<T> query = entityManager.createQuery(jpql, type).setParameter("since", time);
        params.forEach(query::setParameter);
        return query;
    }
}
