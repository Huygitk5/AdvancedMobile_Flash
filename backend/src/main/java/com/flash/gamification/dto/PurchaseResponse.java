package com.flash.gamification.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class PurchaseResponse {

    private final InventoryResponse inventory;
    private final int currentXp;
}
