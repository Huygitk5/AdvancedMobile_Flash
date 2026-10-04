package com.flash.gamification.dto;

import com.flash.common.enums.Resolution;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;

/** Trạng thái kho đồ sau khi trang bị / tháo (LWW). Gồm cả món cùng loại vừa bị tháo ra. */
@Getter
@AllArgsConstructor
public class EquipResult {

    private final InventoryResponse inventory;
    private final List<InventoryResponse> unequipped;
    private final Resolution resolution;
}
