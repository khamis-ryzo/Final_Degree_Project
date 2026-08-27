package com.ryzo.Taxcompliance.service;

import com.ryzo.Taxcompliance.dto.response.TaxReturnWithUserDTO;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class PdfExportServiceTest {

    private final PdfExportService service = new PdfExportService();

    @Test
    void exportIncludesAllPartsOfTaxForm() throws Exception {
        TaxReturnWithUserDTO dto = new TaxReturnWithUserDTO(
                1L, "TR-2024-0001", "2024-25", "ORIGINAL",
                new BigDecimal("2500000"), new BigDecimal("50000"), new BigDecimal("2450000"),
                new BigDecimal("200000"), new BigDecimal("0"), new BigDecimal("0"),
                new BigDecimal("200000"), new BigDecimal("150000"), new BigDecimal("50000"),
                "SUBMITTED", LocalDate.of(2024, 6, 1), "ACK-1001",
                "Alice Mwanza", "0771234567", "123456789", "alice@example.com"
        );

        byte[] pdf = service.exportTaxReturnsPdf(List.of(dto));

        String text;
        try (PDDocument doc = PDDocument.load(pdf)) {
            text = new PDFTextStripper().getText(doc);
        }

        assertThat(text).contains("Tax Returns Report");
        assertThat(text).contains("Tax Form TR-2024-0001");
        assertThat(text).contains("A. Taxpayer Information");
        assertThat(text).contains("Full Name: Alice Mwanza");
        assertThat(text).contains("TIN Number: 123456789");
        assertThat(text).contains("Mobile Number: 0771234567");
        assertThat(text).contains("Email: alice@example.com");
        assertThat(text).contains("B. Filing Details");
        assertThat(text).contains("Filing ID: TR-2024-0001");
        assertThat(text).contains("Assessment Year: 2024-25");
        assertThat(text).contains("Filing Type: ORIGINAL");
        assertThat(text).contains("Status: SUBMITTED");
        assertThat(text).contains("Submission Date: 2024-06-01");
        assertThat(text).contains("Acknowledgment Number: ACK-1001");
        assertThat(text).contains("C. Income & Tax Computation");
        assertThat(text).contains("Total Income: TZS 2500000");
        assertThat(text).contains("Deductions: TZS 50000");
        assertThat(text).contains("Taxable Income: TZS 2450000");
        assertThat(text).contains("Tax Payable: TZS 200000");
        assertThat(text).contains("Total Liability: TZS 200000");
        assertThat(text).contains("Tax Paid: TZS 150000");
        assertThat(text).contains("Refund Amount: TZS 50000");
    }
}