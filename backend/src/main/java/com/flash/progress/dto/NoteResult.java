package com.flash.progress.dto;

import com.flash.common.enums.Resolution;
import lombok.AllArgsConstructor;
import lombok.Getter;

/** Bản ghi cuối cùng trên server + ai thắng (DATA_ARCHITECTURE.md §5.3a). */
@Getter
@AllArgsConstructor
public class NoteResult {

    private final NoteResponse note;
    private final Resolution resolution;
}
