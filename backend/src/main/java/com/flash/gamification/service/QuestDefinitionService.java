package com.flash.gamification.service;

import com.flash.common.BusinessException;
import com.flash.common.ErrorCode;
import com.flash.gamification.dto.QuestDefinitionRequest;
import com.flash.gamification.dto.QuestDefinitionResponse;
import com.flash.gamification.entity.QuestDefinition;
import com.flash.gamification.entity.QuestFrequency;
import com.flash.gamification.repository.QuestDefinitionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

/** Quản lý mẫu nhiệm vụ. Giao nhiệm vụ cho user / nhận thưởng nằm ở QuestService (G4). */
@Service
@RequiredArgsConstructor
public class QuestDefinitionService {

    private final QuestDefinitionRepository repository;

    @Transactional(readOnly = true)
    public List<QuestDefinitionResponse> list() {
        return repository.findAllByOrderBySortOrderAscCreatedAtAsc().stream()
                .map(QuestDefinitionResponse::from)
                .collect(Collectors.toList());
    }

    @Transactional
    public QuestDefinitionResponse create(QuestDefinitionRequest request) {
        if (repository.existsByCode(request.getCode())) {
            throw new BusinessException(ErrorCode.CONFLICT, "Mã nhiệm vụ " + request.getCode() + " đã tồn tại");
        }
        QuestDefinition definition = new QuestDefinition();
        apply(definition, request);
        repository.save(definition);
        return QuestDefinitionResponse.from(definition);
    }

    /** Sửa mẫu không làm đổi nhiệm vụ đã giao, vì user_quests lưu snapshot target/xp. */
    @Transactional
    public QuestDefinitionResponse update(UUID id, QuestDefinitionRequest request) {
        QuestDefinition definition = find(id);
        if (repository.existsByCodeAndIdNot(request.getCode(), id)) {
            throw new BusinessException(ErrorCode.CONFLICT, "Mã nhiệm vụ " + request.getCode() + " đã tồn tại");
        }
        apply(definition, request);
        repository.saveAndFlush(definition);
        return QuestDefinitionResponse.from(definition);
    }

    /** Không xoá dòng (user_quests đang tham chiếu), chỉ ngừng giao nhiệm vụ này. */
    @Transactional
    public void deactivate(UUID id) {
        find(id).setIsActive(false);
    }

    private QuestDefinition find(UUID id) {
        return repository.findById(id)
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "Không tìm thấy mẫu nhiệm vụ"));
    }

    private static void apply(QuestDefinition definition, QuestDefinitionRequest request) {
        definition.setCode(request.getCode());
        definition.setTitle(request.getTitle().trim());
        definition.setDescription(request.getDescription());
        definition.setQuestType(request.getQuestType());
        definition.setFrequency(request.getFrequency() != null ? request.getFrequency() : QuestFrequency.DAILY);
        definition.setTargetValue(request.getTargetValue());
        definition.setXpReward(request.getXpReward());
        definition.setIconName(request.getIconName().trim());
        definition.setIsActive(request.getIsActive() == null || request.getIsActive());
        definition.setSortOrder(request.getSortOrder() != null ? request.getSortOrder() : 0);
    }
}
