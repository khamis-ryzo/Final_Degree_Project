package com.ryzo.Taxcompliance.controller;

import com.ryzo.Taxcompliance.dto.response.TaxReturnWithUserDTO;
import com.ryzo.Taxcompliance.entity.TaxReturn;
import com.ryzo.Taxcompliance.entity.User;
import com.ryzo.Taxcompliance.repository.TaxReturnRepository;
import com.ryzo.Taxcompliance.repository.UserRepository;
import com.ryzo.Taxcompliance.service.ExcelExportService;
import com.ryzo.Taxcompliance.service.PdfExportService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@RestController
@RequestMapping("/export")
@RequiredArgsConstructor
@Slf4j
public class ExportController {

    private final TaxReturnRepository taxReturnRepository;
    private final UserRepository userRepository;
    private final ExcelExportService excelExportService;
    private final PdfExportService pdfExportService;

    @GetMapping(value = "/tax-returns")
    public ResponseEntity<byte[]> exportTaxReturns(
            @RequestParam(defaultValue = "true") boolean withUser,
            @RequestParam(defaultValue = "excel") String format
    ) throws Exception {
        List<TaxReturn> returns = taxReturnRepository.findAll();
        List<TaxReturnWithUserDTO> dtos = new ArrayList<>();

        for (TaxReturn tr : returns) {
            User user = null;
            if (withUser && tr.getUserId() != null) {
                user = userRepository.findById(Objects.requireNonNull(tr.getUserId())).orElse(null);
            }
            TaxReturnWithUserDTO dto = new TaxReturnWithUserDTO(
                    tr.getId(), tr.getFilingId(), tr.getAssessmentYear(), tr.getFilingType(),
                    tr.getTotalIncome(), tr.getDeductions(), tr.getTaxableIncome(), tr.getTaxPayable(),
                    tr.getInterest(), tr.getPenalty(), tr.getTotalLiability(), tr.getTaxPaid(), tr.getRefundAmount(),
                    tr.getStatus(), tr.getSubmissionDate(), tr.getAcknowledgmentNumber(),
                    user != null ? user.getFullName() : null,
                    user != null ? user.getMobileNumber() : null,
                    user != null ? user.getTinNumber() : null,
                    user != null ? user.getEmail() : null
            );
            dtos.add(dto);
        }

        if ("pdf".equalsIgnoreCase(format)) {
            byte[] pdf = pdfExportService.exportTaxReturnsPdf(dtos);
            MediaType pdfContentType = MediaType.APPLICATION_PDF;
            return ResponseEntity.ok()
                    .contentType(pdfContentType)
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=tax-returns.pdf")
                    .body(pdf);
        }

        byte[] excel;
        if (withUser) {
            excel = excelExportService.exportTaxReturnsWithUser(dtos);
        } else {
            excel = excelExportService.exportTaxReturns(dtos);
        }

        MediaType excelContentType = MediaType.parseMediaType(
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        );
        return ResponseEntity.ok()
                .contentType(excelContentType)
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=tax-returns.xlsx")
                .body(excel);
    }
}
