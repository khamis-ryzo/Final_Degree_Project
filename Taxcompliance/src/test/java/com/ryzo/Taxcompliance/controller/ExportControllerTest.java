package com.ryzo.Taxcompliance.controller;

import com.ryzo.Taxcompliance.entity.TaxReturn;
import com.ryzo.Taxcompliance.entity.User;
import com.ryzo.Taxcompliance.repository.TaxReturnRepository;
import com.ryzo.Taxcompliance.repository.UserRepository;
import com.ryzo.Taxcompliance.service.ExcelExportService;
import com.ryzo.Taxcompliance.service.PdfExportService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.ResponseEntity;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ExportControllerTest {

    @Mock
    private TaxReturnRepository taxReturnRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private ExcelExportService excelExportService;

    @Mock
    private PdfExportService pdfExportService;

    @InjectMocks
    private ExportController exportController;

    @Test
    void exportTaxReturns_shouldHonorWithUserFlag() throws Exception {
        TaxReturn taxReturn = new TaxReturn();
        taxReturn.setId(1L);
        taxReturn.setUserId(7L);
        taxReturn.setFilingId("TR-2024-0001");
        taxReturn.setAssessmentYear("2024-25");
        taxReturn.setFilingType("ORIGINAL");
        taxReturn.setTotalIncome(new BigDecimal("2500000"));
        taxReturn.setDeductions(BigDecimal.ZERO);
        taxReturn.setTaxableIncome(new BigDecimal("2400000"));
        taxReturn.setTaxPayable(new BigDecimal("200000"));
        taxReturn.setInterest(BigDecimal.ZERO);
        taxReturn.setPenalty(BigDecimal.ZERO);
        taxReturn.setTotalLiability(new BigDecimal("200000"));
        taxReturn.setTaxPaid(BigDecimal.ZERO);
        taxReturn.setRefundAmount(BigDecimal.ZERO);
        taxReturn.setStatus("SUBMITTED");
        taxReturn.setSubmissionDate(LocalDate.of(2024, 6, 1));
        taxReturn.setAcknowledgmentNumber("ACK-1001");

        User user = new User();
        user.setId(7L);
        user.setFullName("Alice Mwanza");
        user.setMobileNumber("0771234567");
        user.setTinNumber("123456789");
        user.setEmail("alice@example.com");

        when(taxReturnRepository.findAll()).thenReturn(List.of(taxReturn));
        when(userRepository.findById(7L)).thenReturn(Optional.of(user));
        when(excelExportService.exportTaxReturnsWithUser(anyList())).thenReturn(new byte[]{1, 2, 3});

        ResponseEntity<byte[]> response = exportController.exportTaxReturns(true, "excel");

        verify(excelExportService).exportTaxReturnsWithUser(anyList());
        verify(excelExportService, never()).exportTaxReturns(anyList());
        assert response.getStatusCode().is2xxSuccessful();
    }
}
