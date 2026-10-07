package com.flash.feedback.entity;

import javax.persistence.AttributeConverter;
import javax.persistence.Converter;

/** FeedbackType <-> TINYINT (1/2/3). Không autoApply: entity khai báo @Convert rõ ràng. */
@Converter
public class FeedbackTypeConverter implements AttributeConverter<FeedbackType, Integer> {

    @Override
    public Integer convertToDatabaseColumn(FeedbackType attribute) {
        return attribute == null ? null : attribute.getCode();
    }

    @Override
    public FeedbackType convertToEntityAttribute(Integer dbData) {
        return dbData == null ? null : FeedbackType.fromCode(dbData);
    }
}
